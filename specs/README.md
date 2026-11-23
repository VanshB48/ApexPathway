# ApexPathway Specifications & Architecture Documentation

This directory contains the foundational specifications for **ApexPathway**, designed to support **Spec-Driven Development (SDD)**. Every feature, service, data model, and API endpoint implemented in the codebase traces directly to these specifications.

## Specification Index

| Document | Phase | Focus Areas |
|---|---|---|
| **[Phase 1: Vision & Scope](ApexPathway-Plan-Phase1.md)** | Phase 1 | Problem statement, 3-tiered success criteria, v1 boundaries, explicit non-goals. |
| **[Phase 2: Features & Requirements](ApexPathway-Plan-Phase2.md)** | Phase 2 | 19 detailed feature specs across 5 modules, acceptance criteria, dependencies, effort estimates. |
| **[Phase 3: Regulatory & Compliance](ApexPathway-Plan-Phase3.md)** | Phase 3 | SEBI retail algorithmic trading compliance, DPDP Act exemption, Angel One terms, Static IP mandate. |
| **[Phase 4: Data Strategy](ApexPathway-Plan-Phase4.md)** | Phase 4 | Zero-cost data sources (Angel One SmartAPI, Finnhub free WebSocket, DuckDB 10-12 yr Bhavcopy). |
| **[Phase 5: AI Engine Design](ApexPathway-Plan-Phase5.md)** | Phase 5 | Hybrid Java Quant + Gemini 2.0 Flash engine, regulatory scoring $\Delta S_{reg}$, trade parameters, guardrails. |
| **[Phase 6: System Architecture](ApexPathway-Plan-Phase6.md)** | Phase 6 | Java 21 / Spring Boot 3 + React / Vite / TypeScript, Dockview layout, TradingView charts, Resilience4j. |
| **[Phase 7: Security & Risk](ApexPathway-Plan-Phase7.md)** | Phase 7 | Secret hygiene, privacy firewalls, trade interlocks, emergency kill switch, comprehensive risk register. |
| **[Phase 8: Roadmap & Budget](ApexPathway-Plan-Phase8.md)** | Phase 8 | 6-month phased delivery (24 weeks @ 15-20 hrs/week), ₹0/month budget breakdown, 6 milestone gates. |
| **[Phases 9 & 10: Consolidated Plan & Issues](ApexPathway-Plan-Phase9-10.md)** | Phases 9–10 | Non-commercial posture, Assumptions Register, 30/60/90-day plan, glossary, and 24-issue breakdown. |

---

## Spec-Driven Development Workflow

When implementing code for this repository:
1. **Locate the Feature Specification:** Reference the corresponding feature definition in `ApexPathway-Plan-Phase2.md` and technical design in `ApexPathway-Plan-Phase5.md` / `ApexPathway-Plan-Phase6.md`.
2. **Verify Acceptance Criteria:** Every pull request or commit must satisfy the explicit acceptance criteria listed in the spec.
3. **Check Safety & Interlocks:** Trading and data code must adhere to the guardrails defined in `ApexPathway-Plan-Phase7.md` (e.g. rate limits, concentration caps, stale data warnings).
4. **Update GitHub Issue:** Reference the corresponding issue from the 24 issues created in `scripts/create_github_issues.ps1`.
