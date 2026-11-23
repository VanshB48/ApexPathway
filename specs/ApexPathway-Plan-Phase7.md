# ApexPathway — Phase 7: Security, Safety Interlocks & Kill Switch Code

> [!NOTE]
> **Spec-Driven Development (SDD) Guide**
> This document specifies credential encryption, broker communication safety interlocks, circuit breaker rate gates, the emergency physical Kill Switch, and pre-commit secret scanning hooks.

---

## 7.1 Local AES-256-GCM Vault Service (`backend/src/main/java/com/apexpathway/config/AesGcmEncryptionService.java`)

Encrypts sensitive secrets (e.g. TOTP secrets) at rest using AES-256-GCM with PBKDF2 key derivation:

```java
package com.apexpathway.config;

import org.springframework.stereotype.Service;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.ByteBuffer;
import java.security.SecureRandom;
import java.util.Base64;

@Service
public class AesGcmEncryptionService {

    private static final int GCM_IV_LENGTH = 12;
    private static final int GCM_TAG_LENGTH = 128;
    private static final int ITERATIONS = 100_000;
    private static final int KEY_LENGTH = 256;

    public String encrypt(String plainText, String passphrase) throws Exception {
        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);

        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        PBEKeySpec spec = new PBEKeySpec(passphrase.toCharArray(), salt, ITERATIONS, KEY_LENGTH);
        SecretKey secretKey = new SecretKeySpec(factory.generateSecret(spec).getEncoded(), "AES");

        byte[] iv = new byte[GCM_IV_LENGTH];
        new SecureRandom().nextBytes(iv);

        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        cipher.init(Cipher.ENCRYPT_MODE, secretKey, new GCMParameterSpec(GCM_TAG_LENGTH, iv));
        byte[] cipherText = cipher.doFinal(plainText.getBytes());

        ByteBuffer byteBuffer = ByteBuffer.allocate(salt.length + iv.length + cipherText.length);
        byteBuffer.put(salt);
        byteBuffer.put(iv);
        byteBuffer.put(cipherText);

        return Base64.getEncoder().encodeToString(byteBuffer.array());
    }

    public String decrypt(String cipherTextBase64, String passphrase) throws Exception {
        byte[] decoded = Base64.getDecoder().decode(cipherTextBase64);
        ByteBuffer byteBuffer = ByteBuffer.wrap(decoded);

        byte[] salt = new byte[16];
        byteBuffer.get(salt);

        byte[] iv = new byte[GCM_IV_LENGTH];
        byteBuffer.get(iv);

        byte[] cipherText = new byte[byteBuffer.remaining()];
        byteBuffer.get(cipherText);

        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        PBEKeySpec spec = new PBEKeySpec(passphrase.toCharArray(), salt, ITERATIONS, KEY_LENGTH);
        SecretKey secretKey = new SecretKeySpec(factory.generateSecret(spec).getEncoded(), "AES");

        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        cipher.init(Cipher.DECRYPT_MODE, secretKey, new GCMParameterSpec(GCM_TAG_LENGTH, iv));

        return new String(cipher.doFinal(cipherText));
    }
}
```

---

## 7.2 Order Safety Interlock Service (`backend/src/main/java/com/apexpathway/trading/OrderSafetyInterlockService.java`)

Enforces hardcoded financial guardrails prior to sending orders to Angel One:

```java
package com.apexpathway.trading;

import com.apexpathway.common.dto.DomainModels.OrderExecutionRequest;
import com.apexpathway.marketdata.MarketCache;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

@Service
public class OrderSafetyInterlockService {

    private static final Logger log = LoggerFactory.getLogger(OrderSafetyInterlockService.class);

    private final MarketCache marketCache;
    private final AtomicBoolean killSwitchActive = new AtomicBoolean(false);
    private final AtomicInteger dailyTradeCount = new AtomicInteger(0);

    @Value("${apexpathway.safety.max-order-value:50000.0}")
    private double maxOrderValue;

    @Value("${apexpathway.safety.max-daily-trades:5}")
    private int maxDailyTrades;

    public OrderSafetyInterlockService(MarketCache marketCache) {
        this.marketCache = marketCache;
    }

    public void validateOrder(OrderExecutionRequest req) {
        // 1. Kill switch check
        if (killSwitchActive.get()) {
            throw new IllegalStateException("[SAFETY INTERLOCK] Execution blocked: Emergency Kill Switch is ACTIVE.");
        }

        // 2. Maximum single order value check
        double estimatedValue = req.price() * req.quantity();
        if (estimatedValue > maxOrderValue) {
            throw new IllegalArgumentException(String.format(
                "[SAFETY INTERLOCK] Order value ₹%.2f exceeds maximum permitted limit of ₹%.2f",
                estimatedValue, maxOrderValue
            ));
        }

        // 3. Daily frequency limiter check
        if (dailyTradeCount.get() >= maxDailyTrades) {
            throw new IllegalStateException("[SAFETY INTERLOCK] Maximum daily trade quota (" + maxDailyTrades + ") reached.");
        }

        // 4. Stale data check
        marketCache.getLatestTick(req.symbol()).ifPresent(tick -> {
            Duration staleness = Duration.between(tick.timestamp(), Instant.now());
            if (staleness.toMinutes() > 5) {
                throw new IllegalStateException("[SAFETY INTERLOCK] Market data for " + req.symbol() + " is stale (>5m old). Trading locked.");
            }
        });

        dailyTradeCount.incrementAndGet();
        log.info("[SAFETY INTERLOCK] Order validated successfully for {}. Daily count: {}", req.symbol(), dailyTradeCount.get());
    }

    public void triggerKillSwitch() {
        killSwitchActive.set(true);
        log.error("[EMERGENCY KILL SWITCH TRIGGERED] All trading sessions halted.");
    }

    public void resetKillSwitch() {
        killSwitchActive.set(false);
        log.info("[KILL SWITCH RESET] Trading operational status restored.");
    }
}
```

---

## 7.3 Emergency Kill Switch UI Component (`frontend/src/components/trading/KillSwitchButton.tsx`)

```tsx
import React, { useState } from 'react';
import { ShieldAlert, AlertOctagon } from 'lucide-react';

export const KillSwitchButton: React.FC = () => {
  const [triggered, setTriggered] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleKillSwitch = async () => {
    if (!window.confirm("CRITICAL WARNING: This will immediately revoke active broker tokens and lock all order execution. Proceed?")) {
      return;
    }

    setLoading(true);
    try {
      const res = await fetch('/api/v1/trading/kill-switch', { method: 'POST' });
      if (res.ok) {
        setTriggered(true);
        alert("EMERGENCY KILL SWITCH ACTIVATED. System locked.");
      }
    } catch (e) {
      alert("Failed to reach server: " + e);
    } finally {
      setLoading(false);
    }
  };

  return (
    <button
      onClick={handleKillSwitch}
      disabled={loading}
      className={`px-3 py-1.5 rounded flex items-center space-x-1.5 text-xs font-bold transition-all shadow-md ${
        triggered
          ? 'bg-rose-700 text-white animate-pulse'
          : 'bg-red-950 text-red-200 border border-red-700 hover:bg-red-900'
      }`}
    >
      <AlertOctagon className="h-4 w-4 text-red-400" />
      <span>{triggered ? "SYSTEM LOCKED" : "KILL SWITCH"}</span>
    </button>
  );
};
```

---

## 7.4 Pre-Commit Git Secrets Scanner Hook (`.githooks/pre-commit`)

```bash
#!/usr/bin/env bash
# ApexPathway Pre-Commit Secret Scanner
echo "Scanning staged files for accidental credential commits..."

PATTERNS=(
  "AIza[0-9A-Za-z\\-_]{35}"           # Google API Keys
  "[A-Za-z0-9+/=]{44}"                # Base64 tokens / secrets
  "jwtToken"
  "ANGEL_API_KEY"
  "ANGEL_TOTP_SECRET"
  "GEMINI_API_KEY"
)

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

for FILE in $STAGED_FILES; do
  for PATTERN in "${PATTERNS[@]}"; do
    if grep -E "$PATTERN" "$FILE" 2>/dev/null; then
      echo "CRITICAL: Potential secret detected matching pattern '$PATTERN' in $FILE"
      echo "Commit aborted. Please remove sensitive credentials before committing."
      exit 1
    fi
  done
done

echo "Secret check passed. Proceeding with commit."
exit 0
```

---

## 7.5 Phase 7 Implementation Checklist

- [ ] Implement `AesGcmEncryptionService.java` and write roundtrip encrypt/decrypt unit tests.
- [ ] Implement `OrderSafetyInterlockService.java` and test with values exceeding ₹50,000.
- [ ] Implement `KillSwitchButton.tsx` and place in top application header.
- [ ] Enable pre-commit secret hook by running `git config core.hooksPath .githooks`.
