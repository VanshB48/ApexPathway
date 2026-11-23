# ApexPathway 🚀

> **Institutional-Grade Market Terminal for Indian & Global Markets**  
> Built with Java 21 LTS / Spring Boot 3, React 18 / TypeScript / Vite, and Google Gemini 2.0 Flash.

---

## Overview

**ApexPathway** is a personal, Wall Street-style market terminal designed to provide institutional-grade market data visualization, automated regulatory intelligence, and goal-aware AI stock recommendations with one-click broker execution.

- **Markets Covered:** Indian Equities (NSE/BSE via Angel One SmartAPI), Global Equities (Finnhub real-time WebSocket), Bonds, and IPO calendars.
- **AI Recommendation Engine:** Hybrid quantitative Java scoring engine coupled with Gemini 2.0 Flash for parsing regulatory shifts and delivering source-cited recommendations.
- **Budget:** 100% Free-Tier Architecture (₹0 / month).
- **Execution:** 1-Click order placement via Angel One SmartAPI with human-in-the-loop confirmation and an emergency Kill Switch.
- **Safety Interlocks:** ₹50,000 max single trade cap, max 5 trades/day, circuit band monitoring, and zero autonomous trading.

---

## Architecture & Project Structure

```text
ApexPathway/
├── .env.example               # Environment variables configuration template
├── .gitignore                 # Multi-tier secret and artifact ignore rules
├── docker-compose.yml         # Local PostgreSQL 16 Alpine container
├── backend/                   # Java 21 / Spring Boot 3 Core Engine
│   ├── pom.xml                # Spring Boot 3.3.4, DuckDB, LangChain4j, TA4J, Resilience4j
│   └── src/
│       ├── main/java/com/apexpathway/
│       └── main/resources/application.yml
├── frontend/                  # React 18 / TypeScript / Vite / Dockview UI
│   ├── package.json           # Dockview, Lightweight Charts v4, Lucide React, Tailwind
│   ├── vite.config.ts         # Proxy settings to backend on :8080
│   └── src/
├── scripts/                   # Automation & security scripts
│   ├── create_github_issues.ps1 # GitHub issues creator
│   ├── install-git-hooks.ps1  # Pre-commit hook installer
│   └── pre-commit-hook.ps1    # Active secret leakage scanner
└── specs/                     # Spec-Driven Development specifications
    ├── 001-project-initialization/ # Active feature specifications & plan
    └── ApexPathway-Plan-Phase*.md # Architectural baseline phases 1–10
```

---

## Local Development Quickstart

### 1. Prerequisites
- **Java 21 LTS** (`java --version`)
- **Apache Maven 3.9+** (`mvn --version`)
- **Node.js 20+ & npm 10+** (`node --version`)
- **Docker & Docker Compose** (Optional for local PostgreSQL)

### 2. Secret Hygiene Setup
Install the active pre-commit hook to prevent accidental secret leakage:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/install-git-hooks.ps1
```

Copy the environment template:
```powershell
Copy-Item .env.example .env.local
```

### 3. Start Local Infrastructure
```powershell
docker compose up -d postgres
```

### 4. Run Backend Engine
```powershell
cd backend
mvn clean compile
mvn test
mvn spring-boot:run
```

### 5. Run Frontend Terminal
```powershell
cd frontend
npm install
npm run dev
```
Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## Spec-Driven Development (SDD) Workflow

ApexPathway strictly follows **Spec-Driven Development (SDD)** managed via Spec Kit:
- **Project Constitution**: [`.specify/memory/constitution.md`](.specify/memory/constitution.md)
- **Active Feature Specs**: [`specs/001-project-initialization/`](specs/001-project-initialization/)
- **Specifications Index**: [`specs/README.md`](specs/README.md)
