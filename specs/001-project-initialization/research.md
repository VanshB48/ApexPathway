# Research & Decisions: Foundations & Secret Hygiene

**Feature**: `001-project-initialization`
**Date**: 2026-11-23
**Status**: Completed

## 1. Build System & Language Toolchains

### Decision: Maven vs Gradle for Backend
- **Decision**: Apache Maven (`backend/pom.xml`) with Spring Boot Starter Parent `3.3.4` and Java 21 LTS.
- **Rationale**: 
  - Strict XML dependency specifications align with enterprise-grade fintech auditing.
  - Native parent POM management ensures clean alignment between Spring Boot 3.3.4, Flyway 10, Resilience4j 2.2, and Caffeine cache.
  - Direct compatibility with standard CI environments without requiring Gradle daemon management on Windows.
- **Alternatives Considered**: Gradle (Kotlin/Groovy DSL) was considered for faster daemon builds, but standard Maven was selected for consistency, explicit plugin configurations, and zero Gradle wrapper drift.

### Decision: Vite + TypeScript for Frontend
- **Decision**: Vite 5.x with React 18 and TypeScript 5.x.
- **Rationale**:
  - Near-instant Hot Module Replacement (HMR) essential for high-frequency dashboard development.
  - First-class support for ES modules and modern bundlers needed for `@tradingview/lightweight-charts` and `dockview`.
  - Zero-config TypeScript transpilation.
- **Alternatives Considered**: Next.js was evaluated, but ApexPathway is an authenticated local/cloud single-user desktop workstation interface; Next.js SSR adds unnecessary deployment complexity and server overhead.

---

## 2. Secret Hygiene & Pre-Commit Protection

### Decision: Dual-Tier Git Pre-Commit Hook (Native Shell Hook + Gitleaks Pattern Matching)
- **Decision**: Implement a cross-platform pre-commit hook script (`scripts/pre-commit-hook.ps1` and `.git/hooks/pre-commit`) scanning staged diffs for:
  1. Blocked filenames: `.env`, `.env.local`, `*.key`, `*.pem`, `*.parquet`, `*.db`, `application-secret.properties`.
  2. Secret regex patterns:
     - Google Gemini API key: `AIzaSy[A-Za-z0-9_-]{33}`
     - Angel One MPIN / API key patterns: `ANGEL_API_KEY\s*=\s*['"][^'"]+['"]`
     - Generic JWT / Bearer tokens / Private keys (`-----BEGIN PRIVATE KEY-----`)
- **Rationale**:
  - Standalone git hook runs without requiring external globally installed binary packages (like python-pre-commit or brew), ensuring out-of-the-box protection on fresh Windows git clones.
  - Fast staged-diff parsing (< 100ms) with zero latency impact on routine commits.
- **Alternatives Considered**: `git-secrets` (requires separate AWS CLI tool / bash dependency on Windows), `gitleaks` standalone executable (requires PATH installation). The lightweight native hook ensures guaranteed enforcement.

---

## 3. Local Storage Tier

### Decision: PostgreSQL 16 Alpine via Docker Compose
- **Decision**: Run PostgreSQL 16 in a lightweight container managed by `docker-compose.yml`.
- **Rationale**:
  - Matches production hosting environment (Oracle Cloud VPS / local container).
  - Native support for Flyway versioned migrations and future TimescaleDB / pgvector extensions if needed.
- **Alternatives Considered**: H2 In-Memory DB (insufficient for testing PostgreSQL dialect-specific constraints and concurrent broker quote transactions).

---

## Summary of Technical Clarifications
All items in Technical Context have been resolved with zero remaining `NEEDS CLARIFICATION` items.
