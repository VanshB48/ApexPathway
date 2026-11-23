# ApexPathway — Phase 1: Vision, Scope, Success Criteria & Project Setup

> [!NOTE]
> **Spec-Driven Development (SDD) Guide**
> This document establishes the system boundaries, target criteria, initial project structure, and starter configuration files required to bootstrap Milestone 1.

---

## 1.1 Product Vision & Core Mission

**ApexPathway** is a personal, institutional-grade market terminal built for a solo fintech software engineer. It bridges raw market data, automated regulatory policy tracking, and a Gemini-powered quantitative recommendation engine with 1-click broker execution.

### Key Capabilities
1. **Live Multi-Asset Monitoring:** Real-time sub-second streaming for Indian equities (NSE/BSE via Angel One SmartAPI WebSocket) and global equities (Finnhub WebSocket), plus bond yields and IPO calendars.
2. **Automated Regulatory Intelligence:** Real-time ingestion and natural language classification of SEBI circulars, RBI notifications, Union Budget revisions, and global macro policy shifts.
3. **Hybrid AI Recommendation Engine:** Deterministic Java quantitative models (technicals + fundamentals) blended with Gemini 2.0 Flash policy-impact scoring ($\Delta S_{reg} \in [-20, +20]$) producing actionable trade parameters (Entry, ATR Stop-Loss, $2:1$ Target).
4. **Guarded Trade Execution:** One-click execution through Angel One SmartAPI with human-in-the-loop modal confirmation, hard position sizing interlocks, and a physical emergency Kill Switch.

---

## 1.2 Success Criteria & Acceptance Matrix

| Tier | Target Window | Measurable Acceptance Gate | Validation Test |
|---|---|---|---|
| **Tier 1: Functional** | Month 1–3 | 1. Sub-second quote streaming for Indian and global watchlists.<br>2. 1-click buy/sell order placement verified on Angel One.<br>3. Gemini API chat answers queries using injected portfolio context. | Automated JUnit tests for WebSocket ingestion and order dispatch. |
| **Tier 2: Operational** | Month 3–5 | 1. Terminal acts as primary daily trading interface.<br>2. Saves $\ge 1\text{ hr/day}$ in manual research.<br>3. $\ge 70\%$ of AI-recommended setups pass manual owner review.<br>4. Detects $\ge 80\%$ of major SEBI/RBI circulars within 30 mins. | Audit log evaluation comparing published circular timestamps to DB ingestion timestamps. |
| **Tier 3: Alpha & Risk** | Month 5–6+ | 1. Risk-adjusted Sharpe ratio improves vs pre-tool baseline.<br>2. $\ge 55\%$ win rate on executed recommendations.<br>3. Zero trades violate the 10% single-stock concentration cap.<br>4. Backtest validated over 10+ years with realistic transaction friction. | Vectorized DuckDB backtest output logs. |

---

## 1.3 Scope Boundaries

### In Scope (6-Month MVP)
- Real-time Indian equities (Angel One SmartAPI binary WebSocket).
- Real-time global equities (Finnhub.io WebSocket, top 50 symbols).
- Dockview multi-pane terminal workspace with layout persistence.
- TradingView Lightweight Charts v4 with candlestick and technical indicator overlays (RSI, EMA, SMA, VWAP).
- Scheduled RSS scrapers for SEBI, RBI, and PIB announcements.
- Gemini 2.0 Flash structured entity extraction pipeline.
- Multi-factor Java quantitative scoring engine.
- Daily Morning Briefing generator & source-cited recommendation cards.
- 1-Click trade execution modal with parameter adjustment.
- Hard safety interlocks: ₹50k max trade cap, max 5 trades/day, circuit band checks, and emergency Kill Switch.
- Vectorized 10–12 year historical daily Bhavcopy backtesting engine using embedded DuckDB.

### Explicit Non-Goals (Out of Scope for v1)
- Multi-user / SaaS authentication or billing.
- Autonomous algorithmic trading (every order strictly requires manual click approval).
- Cryptocurrency trading or DeFi integrations.
- Native mobile application (web desktop browser only for v1).
- Commercial distribution or public investment advisory.

---

## 1.4 Project Directory Structure

```text
ApexPathway/
├── .gitignore
├── README.md
├── docker-compose.yml
├── .env.example
├── backend/
│   ├── pom.xml
│   └── src/
│       ├── main/
│       │   ├── java/com/apexpathway/
│       │   │   ├── ApexPathwayApplication.java
│       │   │   ├── auth/              # Angel One TOTP auth daemon
│       │   │   ├── config/            # App, Security, Resilience4j configs
│       │   │   ├── marketdata/        # Angel One & Finnhub WS clients
│       │   │   ├── regulatory/        # RSS scrapers & event models
│       │   │   ├── ai/                # Gemini client & prompt templates
│       │   │   ├── quant/             # Technicals, screeners, backtester
│       │   │   ├── trading/           # Order placement & safety interlocks
│       │   │   └── common/            # DTOs, records, exceptions
│       │   └── resources/
│       │       ├── application.yml
│       │       ├── application-dev.yml
│       │       └── db/migration/      # Flyway SQL migrations
│       └── test/java/com/apexpathway/
├── frontend/
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   ├── index.html
│   └── src/
│       ├── App.tsx
│       ├── components/
│       │   ├── workspace/             # Dockview multi-panel grid
│       │   ├── chart/                 # TradingView Lightweight Charts
│       │   ├── watchlist/             # Ticker list & sparklines
│       │   ├── briefing/              # Daily AI briefing & picks
│       │   ├── trading/               # 1-Click modal & Kill Switch
│       │   └── chat/                  # AI Terminal Chat
│       ├── services/                  # SSE & REST API clients
│       └── types/                     # TypeScript interfaces
├── scripts/
│   └── create_github_issues.ps1
└── specs/
    ├── README.md
    └── ApexPathway-Plan-Phase*.md
```

---

## 1.5 Starter Configuration Code

### 1. Root Environment Configuration (`.env.example`)
```bash
# ==========================================
# ApexPathway Environment Configuration
# NEVER COMMIT REAL KEYS TO SOURCE CONTROL
# ==========================================

# Profile & Server
SPRING_PROFILES_ACTIVE=dev
SERVER_PORT=8080

# Angel One SmartAPI (https://smartapi.angelone.in/)
ANGEL_API_KEY=your_smartapi_key_here
ANGEL_CLIENT_CODE=your_client_code_here
ANGEL_PIN=your_mpin_here
ANGEL_TOTP_SECRET=your_base32_totp_secret_here

# Google Gemini API (https://aistudio.google.com/)
GEMINI_API_KEY=your_gemini_api_key_here

# Finnhub API (https://finnhub.io/)
FINNHUB_API_KEY=your_finnhub_token_here

# Local PostgreSQL Storage
POSTGRES_DB=apexpathway
POSTGRES_USER=apex
POSTGRES_PASSWORD=apex_secure_password
POSTGRES_HOST=localhost
POSTGRES_PORT=5432

# Safety Interlocks
MAX_SINGLE_ORDER_VALUE=50000
MAX_DAILY_TRADES=5
STATIC_IP_WHITELIST=127.0.0.1
```

### 2. Backend Build Descriptor (`backend/pom.xml`)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.3.4</version>
        <relativePath/>
    </parent>
    
    <groupId>com.apexpathway</groupId>
    <artifactId>apexpathway-backend</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <name>ApexPathway Backend Engine</name>
    <description>Financial Market Terminal Core Engine</description>
    
    <properties>
        <java.version>21</java.version>
        <duckdb.version>1.1.1</duckdb.version>
        <langchain4j.version>0.35.0</langchain4j.version>
        <resilience4j.version>2.2.0</resilience4j.version>
        <ta4j.version>0.15</ta4j.version>
    </properties>
    
    <dependencies>
        <!-- Spring Boot Starters -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-websocket</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        
        <!-- PostgreSQL & Flyway -->
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
        </dependency>
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-database-postgresql</artifactId>
        </dependency>
        
        <!-- Embedded Analytical DB (DuckDB) -->
        <dependency>
            <groupId>org.duckdb</groupId>
            <artifactId>duckdb_jdbc</artifactId>
            <version>${duckdb.version}</version>
        </dependency>
        
        <!-- High-Performance Caching -->
        <dependency>
            <groupId>com.github.ben-manes.caffeine</groupId>
            <artifactId>caffeine</artifactId>
        </dependency>
        
        <!-- LangChain4j + Google Gemini API -->
        <dependency>
            <groupId>dev.langchain4j</groupId>
            <artifactId>langchain4j</artifactId>
            <version>${langchain4j.version}</version>
        </dependency>
        <dependency>
            <groupId>dev.langchain4j</groupId>
            <artifactId>langchain4j-google-ai-gemini</artifactId>
            <version>${langchain4j.version}</version>
        </dependency>
        
        <!-- Quantitative Technical Analysis (TA4J) -->
        <dependency>
            <groupId>org.ta4j</groupId>
            <artifactId>ta4j-core</artifactId>
            <version>${ta4j.version}</version>
        </dependency>
        
        <!-- Resilience & Rate Limiting -->
        <dependency>
            <groupId>io.github.resilience4j</groupId>
            <artifactId>resilience4j-spring-boot3</artifactId>
            <version>${resilience4j.version}</version>
        </dependency>
        
        <!-- Network & WebSocket Clients -->
        <dependency>
            <groupId>org.java-websocket</groupId>
            <artifactId>Java-WebSocket</artifactId>
            <version>1.5.7</version>
        </dependency>
        
        <!-- TOTP Generation (RFC 6238) -->
        <dependency>
            <groupId>com.eatthepath</groupId>
            <artifactId>java-otp</artifactId>
            <version>0.4.0</version>
        </dependency>
        
        <!-- RSS Ingestion (Rome) -->
        <dependency>
            <groupId>com.rometools</groupId>
            <artifactId>rome</artifactId>
            <version>2.1.0</version>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

### 3. Frontend Package Descriptor (`frontend/package.json`)
```json
{
  "name": "apexpathway-ui",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0"
  },
  "dependencies": {
    "dockview": "^1.37.1",
    "lightweight-charts": "^4.2.1",
    "lucide-react": "^0.453.0",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-markdown": "^9.0.1",
    "clsx": "^2.1.1",
    "tailwind-merge": "^2.5.4"
  },
  "devDependencies": {
    "@types/react": "^18.3.11",
    "@types/react-dom": "^18.3.0",
    "@vitejs/plugin-react": "^4.3.2",
    "autoprefixer": "^10.4.20",
    "postcss": "^8.4.47",
    "tailwindcss": "^3.4.14",
    "typescript": "^5.6.3",
    "vite": "^5.4.9"
  }
}
```

### 4. Dockerized Infrastructure (`docker-compose.yml`)
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: apexpathway-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: apexpathway
      POSTGRES_USER: apex
      POSTGRES_PASSWORD: apex_secure_password
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U apex -d apexpathway"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  pgdata:
    driver: local
```

---

## 1.6 Phase 1 Implementation Checklist

- [ ] Verify Java 21 LTS (`java --version`) and Node.js 20+ (`node --version`) are active.
- [ ] Initialize `backend/` and `frontend/` folders with the configuration files above.
- [ ] Start PostgreSQL container via `docker compose up -d`.
- [ ] Verify connection to PostgreSQL using `psql` or DBeaver.
- [ ] Copy `.env.example` to `.env.local` and inject actual Angel One and Gemini keys.
- [ ] Run `mvn clean compile` in `backend/` to verify dependency resolution.
- [ ] Run `npm install` and `npm run dev` in `frontend/` to confirm Vite boots.
