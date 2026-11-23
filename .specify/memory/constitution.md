# ApexPathway Project Constitution

## Core Principles

### I. Zero Secret Leakage (Strict Pre-Commit & Environment Isolation)
- Real broker credentials (Angel One API key, MPIN, TOTP secret), AI API keys (Gemini), and market data tokens (Finnhub) MUST NEVER be committed to version control.
- Pre-commit hooks (`gitleaks` / custom regex scanner) are strictly mandatory and must reject any commit containing staged secrets, `.env`, `.pem`, `.key`, or secret properties files.
- Configuration must strictly read credentials from local environment variables (`.env.local` or OS environment), never hardcoded or stored in default config files.

### II. Spec-Driven Architecture & Clean Separation
- Every implementation must trace back to specifications in `/specs/` and corresponding GitHub issues.
- Separation of concerns is non-negotiable: Backend (`backend/` in Java 21, Spring Boot 3) acts as the analytical, regulatory, and broker engine; Frontend (`frontend/` in React 18, Vite, TypeScript, Tailwind) acts as the interactive market terminal UI (Dockview).

### III. Regulatory & SEBI Compliance (Human-in-the-Loop)
- Autonomous trading is strictly prohibited. Every order dispatch MUST require explicit human confirmation via interactive UI modal.
- Fixed static IP adherence for broker SmartAPI connectivity must be maintained.
- System operates exclusively as a personal research and execution terminal (non-commercial, solo retail investor posture).

### IV. Hard Safety Interlocks & Circuit Protections
- Built-in trade caps: Maximum single order value of ₹50,000, maximum 5 trades per day.
- Circuit breaker / kill switch: A physical and software emergency Kill Switch must immediately abort active streams and cancel pending orders.
- Resilience4j rate limiting must protect broker SmartAPI endpoints from quota exhaustion.

### V. Test-First Quality & Build Integrity
- Both `backend/` and `frontend/` must maintain clean, reproducible build passes (`mvn clean test`, `npm run build`).
- Automated tests (JUnit 5 for backend, Vitest/React Testing Library for frontend) must validate core contracts before merge.

## Technology Standards & Constraints
- **Backend**: Java 21 LTS, Spring Boot 3.3.x, Maven, DuckDB JDBC, PostgreSQL 16, LangChain4j (Gemini 2.0 Flash), TA4J, Resilience4j.
- **Frontend**: Node.js 20+, React 18, Vite 5+, TypeScript 5+, Dockview, TradingView Lightweight Charts v4, Tailwind CSS.
- **Infrastructure**: Docker & Docker Compose for PostgreSQL 16 storage tier.

## Governance
- This constitution supersedes informal preferences. Any architectural change affecting safety interlocks, secret storage, or broker communication requires an explicit constitution amendment.

**Version**: 1.0.0 | **Ratified**: 2026-11-23 | **Last Amended**: 2026-11-23
