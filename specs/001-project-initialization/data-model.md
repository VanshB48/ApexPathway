# Data Model & Configuration Schemas: Foundations & Secret Hygiene

**Feature**: `001-project-initialization`
**Phase**: Phase 1 Design

## 1. Configuration Schemas

### 1.1 Environment Variable Schema (`EnvironmentConfig`)

Represents all runtime environment variables parsed by backend and frontend.

| Variable Name | Type | Required | Default | Validation Rules / Format | Description |
|---|---|---|---|---|---|
| `SPRING_PROFILES_ACTIVE` | String | No | `dev` | `dev\|test\|prod` | Active Spring Boot execution profile. |
| `SERVER_PORT` | Integer | No | `8080` | `1024..65535` | HTTP server port for backend. |
| `ANGEL_API_KEY` | String | Yes (Prod) | - | Alphanumeric (typically 8–16 chars) | Angel One SmartAPI client API key. |
| `ANGEL_CLIENT_CODE` | String | Yes (Prod) | - | Uppercase alphanumeric (e.g. `V123456`) | Angel One broker client account ID. |
| `ANGEL_PIN` | String | Yes (Prod) | - | 4-digit or 6-digit MPIN | Angel One MPIN for authentication. |
| `ANGEL_TOTP_SECRET` | String | Yes (Prod) | - | Base32 string (16–32 chars) | RFC 6238 TOTP seed secret. |
| `GEMINI_API_KEY` | String | Yes (Prod) | - | Starts with `AIzaSy...` (39 chars) | Google AI Studio Gemini API key. |
| `FINNHUB_API_KEY` | String | Yes (Prod) | - | Alphanumeric token | Finnhub WebSocket and REST API key. |
| `POSTGRES_DB` | String | Yes | `apexpathway` | Identifier string | PostgreSQL database name. |
| `POSTGRES_USER` | String | Yes | `apex` | Identifier string | PostgreSQL username. |
| `POSTGRES_PASSWORD` | String | Yes | `apex_secure_password` | String $\ge 8$ chars | PostgreSQL database password. |
| `POSTGRES_HOST` | String | No | `localhost` | Hostname / IPv4 | PostgreSQL host address. |
| `POSTGRES_PORT` | Integer | No | `5432` | Port number | PostgreSQL TCP port. |
| `MAX_SINGLE_ORDER_VALUE` | Decimal | No | `50000.00` | $> 0.00$ and $\le 100000.00$ | Hard safety cap per order in INR. |
| `MAX_DAILY_TRADES` | Integer | No | `5` | $1..20$ | Maximum allowed trades per calendar day. |
| `STATIC_IP_WHITELIST` | String | No | `127.0.0.1` | Valid IPv4 / CIDR format | Permitted IP whitelist for broker operations. |

---

## 2. Security Entities

### 2.1 SecretPatternRule

Data structure used by the pre-commit scanner to inspect staged diffs.

```yaml
SecretPatternRule:
  type: object
  properties:
    id:
      type: string
      description: Unique identifier for the detection rule.
    name:
      type: string
      description: Human-readable name.
    category:
      type: string
      enum: [blocked_filename, regex_pattern, entropy_check]
    pattern:
      type: string
      description: Regular expression matching forbidden files or contents.
    severity:
      type: string
      enum: [BLOCK, WARN]
```

#### Pre-configured Detection Rules:
1. `RULE_BLOCKED_FILE_ENV`: Blocks any staged file matching `^\.env(\..+)?$` unless exactly `.env.example`.
2. `RULE_BLOCKED_FILE_KEYS`: Blocks any staged file matching `\.(key|pem|p12|pkcs12|jks)$`.
3. `RULE_BLOCKED_FILE_DATA`: Blocks any staged file matching `\.(parquet|db|duckdb|sqlite)$`.
4. `RULE_GEMINI_KEY`: Scans file contents for regex `AIzaSy[A-Za-z0-9_-]{33}`.
5. `RULE_ANGEL_KEY`: Scans file contents for regex `(?i)(ANGEL_API_KEY|ANGEL_TOTP_SECRET)\s*[:=]\s*['"][a-zA-Z0-9_\-\+]{6,}['"]`.
6. `RULE_PRIVATE_KEY`: Scans file contents for regex `-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----`.

---

## 3. Infrastructure Entities

### 3.1 Docker Compose Service Definition

Defines the core services required for the local developer runtime:
- `postgres`: PostgreSQL 16 Alpine container with persistent healthcheck probe and local mount `pgdata`.
