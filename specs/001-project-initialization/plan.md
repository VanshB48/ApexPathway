# Implementation Plan: Foundations: Project Initialization & Secret Hygiene

**Branch**: `001-project-initialization` | **Date**: 2026-11-23 | **Spec**: [specs/001-project-initialization/spec.md](spec.md) | **Issue**: [#1](https://github.com/VanshB48/ApexPathway/issues/1)

**Input**: Feature specification from `/specs/001-project-initialization/spec.md` and GitHub Issue #1.

---

## Summary

Bootstrap the multi-module project foundation for ApexPathway with a Spring Boot 3 / Java 21 backend and a React 18 / Vite / TypeScript frontend. Enforce zero-leakage secret hygiene with an active pre-commit hook and multi-tier `.gitignore` blocking API keys, environment files, and local databases. Provide local container orchestration via `docker-compose.yml`.

---

## Technical Context

**Language/Version**: Java 21 LTS, TypeScript 5.6+, Node.js 20+  
**Primary Dependencies**: 
- Backend: Spring Boot 3.3.4, DuckDB JDBC 1.1.1, LangChain4j 0.35.0, TA4J 0.15, Resilience4j 2.2.0, Caffeine  
- Frontend: React 18.3.1, Vite 5.4.9, Dockview 1.37.1, Lightweight Charts 4.2.1, Tailwind CSS 3.4.14  
**Storage**: PostgreSQL 16 Alpine (via Docker Compose) & DuckDB embedded  
**Testing**: JUnit 5, Spring Boot Test, Vitest  
**Target Platform**: Windows 11 / Linux (Oracle Cloud Always-Free VPS)  
**Project Type**: Multi-module Web Application (Spring Boot API + SPA Desktop Terminal)  
**Performance Goals**: Clean build in under 60 seconds; pre-commit git secret scan latency < 100ms  
**Constraints**: Zero committed credentials; 100% offline-safe secret detection; non-commercial retail posture  
**Scale/Scope**: 2 top-level subprojects (`backend/`, `frontend/`), 4 root config files, 1 pre-commit git hook  

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check Item | Status | Notes |
|---|---|---|---|
| **I. Zero Secret Leakage** | Pre-commit hook & `.gitignore` block `.env*`, `*.key`, `*.pem`, `*.parquet`, `*.db` | **PASS** | Dual-tier hook inspects file names and regex token patterns. |
| **II. Spec-Driven Architecture** | Separation of `backend/` and `frontend/` matching Phase 1 specs | **PASS** | Clean division between Java engine and React terminal workspace. |
| **III. Regulatory & SEBI Compliance** | Static IP and manual order approval assumptions documented in `.env.example` | **PASS** | `STATIC_IP_WHITELIST` included; no automated order loop. |
| **IV. Hard Safety Interlocks** | Trade value caps (`MAX_SINGLE_ORDER_VALUE=50000`, `MAX_DAILY_TRADES=5`) defined | **PASS** | Environment contracts establish default safety boundary. |
| **V. Test-First Quality** | `mvn clean compile` and `npm run build` verification gates established | **PASS** | Automated build verification checklist in `quickstart.md`. |

---

## Project Structure

### Documentation (this feature)

```text
specs/001-project-initialization/
├── spec.md              # Feature specification
├── plan.md              # Technical architecture & implementation blueprint
├── research.md          # Technology decisions & rationale (Phase 0)
├── data-model.md        # Configuration schema & security entities (Phase 1)
├── quickstart.md        # Step-by-step verification guide (Phase 1)
└── contracts/
    └── env-schema.json  # Environment variables JSON contract (Phase 1)
```

### Source Code Layout

```text
ApexPathway/
├── .env.example                               # Template for local environment configuration
├── .gitignore                                 # Multi-tier root ignore patterns
├── docker-compose.yml                         # Local PostgreSQL 16 Alpine service
├── README.md                                  # Architecture, prerequisites, and setup guide
├── scripts/
│   ├── create_github_issues.ps1               # Automated issue creator script
│   └── install-git-hooks.ps1                  # Pre-commit secret hook installer
├── .git/hooks/
│   └── pre-commit                             # Active pre-commit secret detection hook
├── backend/
│   ├── pom.xml                                # Spring Boot 3.3.4 & Java 21 build descriptor
│   └── src/
│       ├── main/
│       │   ├── java/com/apexpathway/
│       │   │   └── ApexPathwayApplication.java# Spring Boot main entry point
│       │   └── resources/
│       │       └── application.yml            # Core backend configuration
│       └── test/java/com/apexpathway/
│           └── ApexPathwayApplicationTests.java
└── frontend/
    ├── package.json                           # React 18, Vite, Dockview, Lightweight Charts
    ├── tsconfig.json                          # Strict TypeScript configuration
    ├── tsconfig.node.json
    ├── vite.config.ts                         # Vite dev server & proxy settings
    ├── tailwind.config.js                     # Tailwind CSS theme
    ├── postcss.config.js
    ├── index.html                             # SPA HTML shell
    └── src/
        ├── main.tsx                           # React entry point
        ├── App.tsx                            # Root application shell
        └── index.css                          # Base Tailwind styling
```

---

## Phase 0: Research & Decisions
*All unknowns clarified in [research.md](research.md).*
- Maven chosen over Gradle for strict dependency resolution and reproducible enterprise auditing.
- Vite 5 + React 18 chosen over Next.js for high-performance client-side multi-dock terminal rendering.
- Native cross-platform pre-commit hook chosen over external dependencies (`git-secrets`, `gitleaks` binaries) for guaranteed zero-dependency operation on Windows.

---

## Phase 1: Design & Contracts
- **Data Model & Schemas**: Detailed in [data-model.md](data-model.md).
- **Contracts**: [contracts/env-schema.json](contracts/env-schema.json).
- **Validation Guide**: [quickstart.md](quickstart.md).

---

## Next Steps

1. Run `/speckit-tasks` to generate the atomic implementation task breakdown (`tasks.md`).
2. Run `/speckit-implement` to scaffold the directory structure, install git hooks, and verify backend and frontend builds.
