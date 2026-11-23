# ApexPathway — Phases 9 & 10: Consolidated Master Blueprint & CI/CD

> [!NOTE]
> **Spec-Driven Development (SDD) Guide**
> This final document consolidates the complete architecture, deployment runbooks, GitHub Actions CI/CD workflow, and direct mapping of all 24 GitHub issues to the codebase.

---

## 10.1 GitHub Actions CI Pipeline (`.github/workflows/ci.yml`)

Ensures code quality, secret scanning, and automated test execution on every pull request to `main`:

```yaml
name: ApexPathway CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  backend-test:
    name: Backend Tests & Build (Java 21)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'temurin'
          cache: maven

      - name: Build and Test Backend
        run: |
          cd backend
          mvn clean verify -B

  frontend-test:
    name: Frontend Lint & Build (Node 20)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json

      - name: Install & Build Frontend
        run: |
          cd frontend
          npm ci
          npm run build

  secret-scan:
    name: Gitleaks Secret Scanner
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 10.2 Production Multi-Container Orchestration (`docker-compose.prod.yml`)

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: apexpathway-postgres-prod
    restart: always
    environment:
      POSTGRES_DB: apexpathway
      POSTGRES_USER: apex
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-apex_secure_password}
    volumes:
      - pgdata_prod:/var/lib/postgresql/data
    networks:
      - apex-net

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: apexpathway-backend-prod
    restart: always
    env_file:
      - .env.local
    environment:
      SPRING_PROFILES_ACTIVE: prod
      POSTGRES_HOST: postgres
    ports:
      - "8080:8080"
    volumes:
      - duckdb_data:/app/data
    depends_on:
      - postgres
    networks:
      - apex-net

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: apexpathway-frontend-prod
    restart: always
    ports:
      - "80:80"
    depends_on:
      - backend
    networks:
      - apex-net

networks:
  apex-net:
    driver: bridge

volumes:
  pgdata_prod:
  duckdb_data:
```

---

## 10.3 24 GitHub Issues to Code Implementation Mapping

| Issue # | Title | Primary Java/TS Code File | Milestone |
|---|---|---|---|
| **#1** | Foundations: Project Initialization & Secret Hygiene | `backend/pom.xml`, `.githooks/pre-commit` | M1 |
| **#2** | Broker: Angel One SmartAPI Authentication Daemon | `com.apexpathway.auth.TotpGenerator` | M1 |
| **#3** | Database: PostgreSQL Schemas & Storage Tier Setup | `src/main/resources/db/migration/V1__init.sql` | M1 |
| **#4** | Monitoring: Broker Connectivity & Healthcheck Endpoint | `com.apexpathway.api.HealthController` | M1 |
| **#5** | UI: Multi-Pane Dockable Workspace Layout (Dockview) | `frontend/src/components/workspace/TerminalWorkspace.tsx` | M2 |
| **#6** | Market Data: Angel One Real-Time WebSocket & SSE | `com.apexpathway.marketdata.AngelOneWebSocketClient` | M2 |
| **#7** | Market Data: Finnhub Global Real-Time Watchlist | `com.apexpathway.marketdata.FinnhubWebSocketClient` | M2 |
| **#8** | Charts: TradingView Lightweight Charts Integration | `frontend/src/components/chart/TradingViewChart.tsx` | M2 |
| **#9** | Regulatory: Government Regulatory RSS Ingestion Service | `com.apexpathway.regulatory.RegulatoryRssIngestionService` | M3 |
| **#10** | AI: Gemini 2.0 Flash Structured Extraction Pipeline | `com.apexpathway.ai.GeminiRegulatoryService` | M3 |
| **#11** | News: News Aggregation & Sentiment Scoring | `com.apexpathway.regulatory.NewsSentimentService` | M3 |
| **#12** | UI: Regulatory Alert Card Component | `frontend/src/components/regulatory/RegulatoryAlertCard.tsx` | M3 |
| **#13** | Quant: Quantitative Multi-Factor Scoring Engine | `com.apexpathway.quant.TechnicalScoringService` | M4 |
| **#14** | Quant: User Goal Translation & Constraint Filter | `com.apexpathway.quant.GoalConstraintFilter` | M4 |
| **#15** | AI: Daily Briefing Generator & Recommendation Cards | `com.apexpathway.ai.DailyBriefingService` | M4 |
| **#16** | AI: Interactive Natural Language Chat Terminal | `com.apexpathway.ai.AiChatWebSocketHandler` | M4 |
| **#17** | Portfolio: Angel One Portfolio & PnL Sync Service | `com.apexpathway.trading.PortfolioSyncService` | M5 |
| **#18** | Trading: 1-Click 'Approve & Trade' Confirmation Modal | `frontend/src/components/trading/TradeConfirmationModal.tsx` | M5 |
| **#19** | Safety: Safety Interlocks & Resilience4j Limiters | `com.apexpathway.trading.OrderSafetyInterlockService` | M5 |
| **#20** | Safety: Emergency Kill Switch System | `frontend/src/components/trading/KillSwitchButton.tsx` | M5 |
| **#21** | Data: 9-12 Year Historical Data Bootstrap & Ingestion | `com.apexpathway.quant.DuckDbStorageService` | M6 |
| **#22** | Backtesting: Vectorized Backtesting Engine | `com.apexpathway.quant.VectorizedBacktestEngine` | M6 |
| **#23** | Analytics: Strategy Analytics & Equity Curve Visualizer | `frontend/src/components/analytics/BacktestDashboard.tsx` | M6 |
| **#24** | DevOps: Production Hardening & Cloud VPS Deployment | `docker-compose.prod.yml`, `.env.local` | M6 |

---

## 10.4 Immediate Runbook: Day 1 Kickoff

1. **Verify Developer Tooling:**
   ```powershell
   java --version   # Must report 21+
   node --version   # Must report 20+
   docker --version # Engine active
   gh --version     # GitHub CLI 2.105+
   ```
2. **Authorize GitHub:**
   ```powershell
   gh auth login
   ```
3. **Dispatch Automated GitHub Issues:**
   ```powershell
   cd D:\projects\ApexPathway\scripts
   .\create_github_issues.ps1
   ```
4. **Begin Milestone 1 Execution:**
   - Clone/open `D:\projects\ApexPathway` in your IDE.
   - Follow `specs/ApexPathway-Plan-Phase1.md` Section 1.5 to configure starter files.
   - Pick **Issue #1** (`Project Initialization & Secret Hygiene`) to begin coding.
