# Feature Specification: Foundations: Project Initialization & Secret Hygiene

**Feature Branch**: `001-project-initialization`
**Created**: 2026-11-23
**Status**: Ready
**GitHub Issue**: [#1 Foundations: Project Initialization & Secret Hygiene](https://github.com/VanshB48/ApexPathway/issues/1)
**Input**: Setup the multi-module repository structure for ApexPathway (Java 21 / Spring Boot 3 + React 18 / Vite / TypeScript), configure multi-tier .gitignore, install pre-commit git hooks to prevent secret leakage, and create README with development setup.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Multi-Tier Clean Repository Bootstrapping (Priority: P1)

As a solo fintech engineer, I want the multi-module project directory initialized with clean Java 21 / Spring Boot backend and React 18 / Vite frontend builds, so that I have a consistent, compile-ready developer environment for the entire platform.

**Why this priority**: Essential foundation for all subsequent 23 features; without valid build descriptors and directory layouts, development cannot proceed.

**Independent Test**:
- Run `mvn clean compile` in `backend/` and verify build succeeds without missing dependencies.
- Run `npm install && npm run build` in `frontend/` and verify Vite produces production assets.

**Acceptance Scenarios**:
1. **Given** a freshly cloned or initialized repository, **When** developer inspects directory structure, **Then** `backend/`, `frontend/`, `specs/`, and root orchestration files (`docker-compose.yml`, `.env.example`) exist in expected paths.
2. **Given** valid Java 21 and Node.js environments, **When** developer compiles backend and frontend, **Then** zero compilation errors or unresolved package references occur.

---

### User Story 2 - Secret Leakage Prevention & Pre-Commit Git Hooks (Priority: P1)

As a solo fintech engineer holding real broker credentials and AI API keys, I want git hooks and comprehensive ignore rules that block committing any secret or credential file, so that proprietary keys (Angel One, Gemini, Finnhub, DB passwords) are never committed to GitHub.

**Why this priority**: Financial broker and AI keys pose direct financial and security liability if exposed; secret hygiene must be enforced before any code containing connection logic is staged.

**Independent Test**:
- Create a test commit containing a simulated Angel One API key or staging a `.env` file; verify git pre-commit hook rejects the commit and outputs a warning.

**Acceptance Scenarios**:
1. **Given** staged `.env`, `.env.local`, `*.key`, `*.pem`, `*.parquet`, or `*.db` files, **When** running `git commit`, **Then** git blocks execution with a clear diagnostic message.
2. **Given** a file containing pattern `ANGEL_API_KEY=...` or `AIzaSy...`, **When** staging and attempting commit, **Then** pre-commit secret detection aborts the commit.

---

### User Story 3 - Local Infrastructure & Docker Compose Containerization (Priority: P2)

As a developer, I want a standardized `docker-compose.yml` providing a local PostgreSQL 16 database with health check definitions and persistent volume mappings, so that storage services can be started reliably with a single command.

**Why this priority**: PostgreSQL is required by Spring Boot JPA and Flyway migration services in upcoming Phase 1 tasks.

**Independent Test**:
- Run `docker compose config` and verify valid service configuration and volume declarations.

**Acceptance Scenarios**:
1. **Given** Docker is available, **When** running `docker compose up -d postgres`, **Then** the container spins up on port `5432` and passes health check `pg_isready`.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Repository MUST contain `backend/` initialized with Maven (`pom.xml`) configuring Java 21, Spring Boot 3.3.4, DuckDB JDBC, LangChain4j, TA4J, and Resilience4j.
- **FR-002**: Repository MUST contain `frontend/` initialized with Vite, React 18, TypeScript, Tailwind CSS, Lucide icons, and Dockview.
- **FR-003**: Root `.gitignore` MUST block all `.env`, `.env.*` (except `.env.example`), `*.key`, `*.pem`, `application-secret.properties`, DuckDB files (`*.db`, `*.parquet`), logs, and IDE caches.
- **FR-004**: Pre-commit hook MUST be installed in `.git/hooks/pre-commit` to scan for high-entropy tokens and known secret keywords (Angel One, Gemini, API tokens).
- **FR-005**: Root `.env.example` MUST document all environment variables required by backend and frontend without exposing real values.
- **FR-006**: Root `docker-compose.yml` MUST declare PostgreSQL 16 Alpine with persistent volume `pgdata` and healthcheck.
- **FR-007**: Root `README.md` MUST provide step-by-step local development setup, prerequisites (Java 21, Node.js 20+, Docker), and architecture summary.

### Edge Cases

- **EC-001**: Missing Java 21 or Node 20 runtime on host machine during build verification.
- **EC-002**: Developer bypassing pre-commit hook using `git commit --no-verify`; addressed by documenting git-secrets/gitleaks verification in CI/CD pipeline.
- **EC-003**: Windows PowerShell path separation vs bash execution in `.git/hooks/pre-commit`.
