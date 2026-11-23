# Tasks: Foundations: Project Initialization & Secret Hygiene

**Feature**: `001-project-initialization`
**Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md) | **Issue**: [#1](https://github.com/VanshB48/ApexPathway/issues/1)

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Mapped to user stories (`US1`, `US2`, `US3`)

---

## Phase 1: Setup (Root Configuration & Baseline)

- [x] T001 Create root `.env.example` defining all environment variable templates per `contracts/env-schema.json`
- [x] T002 [P] Configure root `.gitignore` blocking `.env*`, `*.key`, `*.pem`, `*.parquet`, `*.db`, `application-secret.properties`, node_modules, and target directories
- [x] T003 [P] Update root `README.md` with multi-module architecture, prerequisites (Java 21, Node 20+, Docker), and local development guide

---

## Phase 2: User Story 2 - Secret Leakage Prevention & Pre-Commit Hook (Priority: P1) 🛡️

**Goal**: Guarantee that no real API keys, credentials, or private files can be committed to git.

- [x] T004 [US2] Create cross-platform pre-commit hook script in `scripts/pre-commit-hook.ps1` implementing `SecretPatternRule` checks
- [x] T005 [US2] Create hook installer script in `scripts/install-git-hooks.ps1` to link/copy pre-commit hook into `.git/hooks/pre-commit`
- [x] T006 [US2] Install `.git/hooks/pre-commit` and verify executable permissions
- [x] T007 [US2] Run negative test: simulate staging a dummy API key and verify commit is blocked

---

## Phase 3: User Story 1 - Multi-Tier Clean Repository Bootstrapping (Priority: P1) 🎯 MVP

**Goal**: Initialize `backend/` and `frontend/` subprojects and achieve clean, passing builds on both.

### Backend (Spring Boot 3 / Java 21)
- [x] T008 [P] [US1] Create `backend/pom.xml` with Spring Boot 3.3.4 parent, Java 21, DuckDB, LangChain4j, TA4J, Resilience4j, and test dependencies
- [x] T009 [P] [US1] Create `backend/src/main/resources/application.yml` and `application-dev.yml` configuring server port and logging
- [x] T010 [US1] Create Spring Boot main class `backend/src/main/java/com/apexpathway/ApexPathwayApplication.java`
- [x] T011 [US1] Create baseline context test `backend/src/test/java/com/apexpathway/ApexPathwayApplicationTests.java`
- [x] T012 [US1] Execute `mvn clean compile` in `backend/` to verify dependency resolution and compilation

### Frontend (React 18 / Vite / TypeScript / Tailwind)
- [x] T013 [P] [US1] Create `frontend/package.json` with dependencies (React 18, Dockview, Lightweight Charts, Lucide, Tailwind)
- [x] T014 [P] [US1] Create `frontend/tsconfig.json` and `frontend/tsconfig.node.json` for strict TypeScript checking
- [x] T015 [P] [US1] Create `frontend/vite.config.ts`, `frontend/tailwind.config.js`, and `frontend/postcss.config.js`
- [x] T016 [P] [US1] Create `frontend/index.html` and `frontend/src/index.css`
- [x] T017 [US1] Create `frontend/src/main.tsx` and `frontend/src/App.tsx`
- [x] T018 [US1] Execute `npm install` and `npm run build` in `frontend/` to verify bundle generation

---

## Phase 4: User Story 3 - Local Infrastructure & Containerization (Priority: P2)

**Goal**: Provide local PostgreSQL container orchestration.

- [x] T019 [US3] Create root `docker-compose.yml` defining PostgreSQL 16 Alpine with persistent volume and health check probe

---

## Phase 5: Verification & Acceptance

- [x] T020 Run complete verification scenario from `quickstart.md`
- [x] T021 Stage and commit initialized foundation files to git
