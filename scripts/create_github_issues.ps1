# ApexPathway - Automated GitHub Issues Creator Script
# Repository: https://github.com/VanshB48/ApexPathway.git
# Pre-requisite: Run 'gh auth login' before executing this script.

$repo = "VanshB48/ApexPathway"

# Ensure GitHub CLI is in PATH if installed in standard location
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    if (Test-Path "C:\Program Files\GitHub CLI\gh.exe") {
        $env:PATH = "C:\Program Files\GitHub CLI;" + $env:PATH
    }
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "Error: GitHub CLI ('gh') is not found on your system." -ForegroundColor Red
    Write-Host "Please ensure it is installed or restart your terminal." -ForegroundColor Yellow
    exit 1
}

Write-Host "Verifying GitHub CLI authentication for repository: $repo..." -ForegroundColor Cyan
$authCheck = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: GitHub CLI is not authenticated." -ForegroundColor Red
    Write-Host "Please open your terminal and run: gh auth login" -ForegroundColor Yellow
    exit 1
}

$issues = @(
    @{
        title = "Foundations: Project Initialization & Secret Hygiene"
        body = @"
## Overview
Setup the multi-module repository structure for ApexPathway (Java 21 / Spring Boot 3 + React 18 / Vite / TypeScript).

## Tasks
- [ ] Initialize repository structure with backend/ (Java 21, Maven/Gradle) and frontend/ (React, Vite, TS).
- [ ] Configure multi-tier .gitignore to block all .env*, *.key, *.pem, application-secret.properties, *.parquet, *.db.
- [ ] Install pre-commit git-secrets / gitleaks hook to prevent accidental commits of Angel One or Gemini API keys.
- [ ] Create README.md documenting architecture and local development setup.

## Acceptance Criteria
- Clean build passes on both frontend and backend.
- Attempting to commit a fake API key is blocked by git hooks.
"@
        labels = "foundations,security"
    },
    @{
        title = "Broker: Angel One SmartAPI Authentication Daemon"
        body = @"
## Overview
Implement automated daily authentication handshake with Angel One SmartAPI using client code, PIN, and TOTP.

## Tasks
- [ ] Implement RFC 6238 TOTP generator in Java using stored TOTP secret.
- [ ] Build automated login scheduler running daily at 08:30 IST.
- [ ] Retrieve JWT access token and refresh token from Angel One API.
- [ ] Store tokens in secure in-memory cache with thread-safe access.

## Acceptance Criteria
- Backend boots up, authenticates with Angel One SmartAPI, and holds a valid session token.
- Automatic reconnection and token refresh on expiry.
"@
        labels = "broker,backend"
    },
    @{
        title = "Database: PostgreSQL Schemas & Storage Tier Setup"
        body = @"
## Overview
Setup PostgreSQL 16 schema migrations for transactional state tracking.

## Tasks
- [ ] Configure Flyway or Liquibase in Spring Boot.
- [ ] Create schema for `portfolio_holdings` (symbol, quantity, avg_price, current_value, pnl).
- [ ] Create schema for `orders_and_trades` (order_id, symbol, side, qty, price, status, algo_id).
- [ ] Create schema for `regulatory_events` (circular_id, authority, title, summary, impact_json, source_url).
- [ ] Create schema for `ai_recommendations` and `trade_audit_log`.

## Acceptance Criteria
- Database migrations execute cleanly on application startup.
- All foreign keys and audit timestamp triggers verified.
"@
        labels = "database,backend"
    },
    @{
        title = "Monitoring: Broker Connectivity & Healthcheck Endpoint"
        body = @"
## Overview
Provide a unified system health check endpoint for the terminal.

## Tasks
- [ ] Create `/api/v1/health` endpoint.
- [ ] Check Angel One REST API reachability and token validity.
- [ ] Check PostgreSQL connectivity.
- [ ] Check local DuckDB storage status.
- [ ] Expose uptime, active memory, and market open/closed status.

## Acceptance Criteria
- Endpoint returns JSON status with HTTP 200 when all services are healthy, 503 on critical service failure.
"@
        labels = "api,monitoring"
    },
    @{
        title = "UI: Multi-Pane Dockable Workspace Layout (Dockview)"
        body = @"
## Overview
Build the Wall Street-style multi-window dockable terminal workspace in React.

## Tasks
- [ ] Integrate Dockview (or Golden-Layout) in React 18.
- [ ] Create default financial workspace panels: Chart, Watchlist, News Feed, Portfolio, AI Chat.
- [ ] Implement panel drag, drop, split, dock, and minimize functionality.
- [ ] Serialize layout state to localStorage so custom panel layouts persist across browser reloads.

## Acceptance Criteria
- User can resize and rearrange panels freely.
- Layout persists after page refresh.
"@
        labels = "frontend,ui"
    },
    @{
        title = "Market Data: Angel One Real-Time WebSocket & SSE Ingestion"
        body = @"
## Overview
Ingest live Indian market data from Angel One SmartAPI WebSocket and stream ticks to the web terminal.

## Tasks
- [ ] Implement Java WebSocket client connecting to Angel One binary tick stream.
- [ ] Parse binary tick buffers into Java records (`MarketTick`).
- [ ] Update in-memory Caffeine cache with latest LTP, high, low, and volume.
- [ ] Expose Server-Sent Events (SSE) endpoint `/api/v1/stream/ticks` for browser consumption.

## Acceptance Criteria
- Real-time tick latency from broker to browser UI is < 250ms.
- Auto-reconnects with exponential backoff on network drop.
"@
        labels = "market-data,backend"
    },
    @{
        title = "Market Data: Finnhub Global Real-Time Watchlist Stream"
        body = @"
## Overview
Integrate Finnhub.io permanent free WebSocket tier for top US and global stocks.

## Tasks
- [ ] Connect Java backend to Finnhub WebSocket (`wss://ws.finnhub.io`).
- [ ] Subscribe to top 50 global symbols (e.g. SPY, AAPL, MSFT, GOOGL, NVDA, TSLA).
- [ ] Merge global quotes into the unified market tick dispatcher.
- [ ] Display global stock prices and day % change in the Global Watchlist pane.

## Acceptance Criteria
- Global stock ticks stream live during US market hours without exceeding Finnhub free tier limits.
"@
        labels = "market-data,backend"
    },
    @{
        title = "Charts: TradingView Lightweight Charts Integration"
        body = @"
## Overview
Embed interactive financial candlestick charting using TradingView Lightweight Charts v4.

## Tasks
- [ ] Embed TradingView Lightweight Charts in the Chart panel.
- [ ] Support Candlestick, Line, and Volume histogram series.
- [ ] Connect chart to live SSE tick stream for real-time bar updates.
- [ ] Implement technical indicator overlays: SMA (20, 50, 200), EMA, and RSI in sub-pane.
- [ ] Add basic drawing tools: horizontal support/resistance lines and trendlines.

## Acceptance Criteria
- Smooth 60fps chart rendering with instant timeframe switching (1m, 5m, 15m, 1D).
"@
        labels = "charts,frontend"
    },
    @{
        title = "Regulatory: Government Regulatory RSS Ingestion Service"
        body = @"
## Overview
Automate continuous tracking of official Indian regulatory circulars and policy announcements.

## Tasks
- [ ] Build scheduled Spring Boot worker polling SEBI circulars RSS feed every 30 minutes.
- [ ] Add polling for RBI notifications and PIB Ministry releases.
- [ ] Extract clean text, publication date, circular number, and PDF download links.
- [ ] Store deduplicated events in PostgreSQL `regulatory_events`.

## Acceptance Criteria
- New SEBI/RBI circulars are detected, parsed, and persisted within 30 minutes of release.
"@
        labels = "regulatory,backend"
    },
    @{
        title = "AI: Gemini 2.0 Flash Structured Extraction Pipeline"
        body = @"
## Overview
Classify regulatory circulars into structured market impact entities using Google Gemini.

## Tasks
- [ ] Setup LangChain4j with Google Gemini 2.0 Flash API provider.
- [ ] Define structured JSON schema: summary, affected_sectors, affected_tickers, polarity (BULLISH/BEARISH/NEUTRAL), severity (1-5).
- [ ] Compute regulatory impact score adjustment Delta S_reg (-20 to +20).
- [ ] Store structured classification back into PostgreSQL.

## Acceptance Criteria
- Gemini reliably outputs valid JSON matching the schema for every ingested regulatory circular.
"@
        labels = "ai,gemini"
    },
    @{
        title = "News: News Aggregation & Sentiment Scoring"
        body = @"
## Overview
Aggregate financial news headlines and compute sentiment scores for portfolio assets.

## Tasks
- [ ] Ingest financial RSS feeds (Economic Times, LiveMint, Finnhub news).
- [ ] Tag articles with mentioned stock tickers.
- [ ] Run sentiment classification via Gemini (Positive/Neutral/Negative).
- [ ] Render news feed widget in the terminal with ticker search and sentiment badges.

## Acceptance Criteria
- News feed displays fresh headlines with sentiment chips and direct source links.
"@
        labels = "news,ai"
    },
    @{
        title = "UI: Regulatory Alert Card Component"
        body = @"
## Overview
Highlight regulatory events that directly impact stocks held in the owner's portfolio.

## Tasks
- [ ] Cross-reference ingested regulatory events with current Angel One portfolio holdings.
- [ ] Display an urgent Regulatory Alert Card when a held ticker is impacted.
- [ ] Show 2-sentence summary, affected ticker chip, and direct link to official PDF/circular.

## Acceptance Criteria
- Holding HDFCBANK triggers visual alert when an RBI banking circular is ingested.
"@
        labels = "ui,frontend"
    },
    @{
        title = "Quant: Quantitative Multi-Factor Scoring Engine"
        body = @"
## Overview
Implement deterministic stock scoring engine in Java combining technicals, valuation, and regulatory scores.

## Tasks
- [ ] Implement technical scoring service (EMA golden cross, RSI momentum, volume breakout).
- [ ] Implement fundamental valuation scoring (P/E relative to historical median, ROE).
- [ ] Merge regulatory score Delta S_reg into composite score S in [0, 100].
- [ ] Rank universe and select top candidate stocks.

## Acceptance Criteria
- Deterministic calculation runs in < 50ms across 500 stocks.
- Zero mathematical hallucinations (all formulas executed in Java).
"@
        labels = "quant,backend"
    },
    @{
        title = "Quant: User Goal Translation & Constraint Filter"
        body = @"
## Overview
Translate user investment goals into hard screening constraints.

## Tasks
- [ ] Support goal profiles: Capital Preservation, Growth, Dividend Income, High Risk.
- [ ] Enforce hard constraints: Max beta, min market cap, max debt/equity, min dividend yield.
- [ ] Apply sector exclusion filters (e.g. ESG screens).
- [ ] Enforce single-position concentration limits (max 10% of portfolio).

## Acceptance Criteria
- Capital Preservation profile strictly excludes small-cap and high-beta stocks from recommendation candidates.
"@
        labels = "quant,goals"
    },
    @{
        title = "AI: Daily Briefing Generator & Recommendation Cards"
        body = @"
## Overview
Synthesize morning portfolio review, regulatory developments, and concrete stock picks using Gemini.

## Tasks
- [ ] Build daily morning briefing orchestrator (triggered on first login or scheduled at 08:45 IST).
- [ ] Generate 3 sections: Overnight Portfolio Performance, Regulatory Highlights, Top 3-5 Picks.
- [ ] For each pick, compute concrete parameters: Action (BUY/SELL/HOLD), Entry range, Target, Stop-Loss (based on ATR).
- [ ] Render source-cited Markdown recommendation cards in the terminal.

## Acceptance Criteria
- Recommendation cards provide exact entry, target, and stop-loss with minimum 2:1 reward-to-risk ratio.
"@
        labels = "ai,gemini"
    },
    @{
        title = "AI: Interactive Natural Language Chat Terminal Window"
        body = @"
## Overview
Provide interactive AI chat assistant in the terminal with live market and portfolio context.

## Tasks
- [ ] Build WebSocket chat endpoint `/ws/ai-chat`.
- [ ] Stream Gemini 2.0 Flash token responses in real time.
- [ ] Inject current portfolio holdings, market index levels, and recent regulatory events as prompt context.
- [ ] Render markdown chat interface with code and citation formatting.

## Acceptance Criteria
- User can ask 'Why did my portfolio drop today?' and get a sourced explanation citing market and regulatory factors.
"@
        labels = "ai,frontend"
    },
    @{
        title = "Portfolio: Angel One Portfolio & PnL Sync Service"
        body = @"
## Overview
Sync live holdings, positions, and profit/loss metrics from Angel One SmartAPI.

## Tasks
- [ ] Fetch holdings and open positions from Angel One API.
- [ ] Calculate total portfolio value, invested amount, day P&L, and unrealized return %.
- [ ] Support custom stock baskets and compute basket-level performance.
- [ ] Persist daily EOD portfolio snapshots for historical equity tracking.

## Acceptance Criteria
- Portfolio view accurately mirrors the official Angel One mobile app figures in real time.
"@
        labels = "portfolio,broker"
    },
    @{
        title = "Trading: 1-Click 'Approve & Trade' Confirmation Modal"
        body = @"
## Overview
Build the safe one-click trade execution interface for AI-recommended picks.

## Tasks
- [ ] Add 'Approve & Trade' button on every AI recommendation card.
- [ ] Display confirmation modal with symbol, side, order type, quantity, limit price, and stop-loss.
- [ ] Allow manual adjustments of quantity or price before submission.
- [ ] Dispatch order payload to backend execution service upon explicit click.

## Acceptance Criteria
- Orders are NEVER submitted autonomously; explicit user modal confirmation is strictly required.
"@
        labels = "trading,frontend"
    },
    @{
        title = "Safety: Safety Interlocks & Resilience4j Rate Limiters"
        body = @"
## Overview
Implement financial risk interlocks and broker API rate-limiting rules.

## Tasks
- [ ] Implement Resilience4j token-bucket rate limiter: max 8 req/s for orders, 2.5 req/s for data.
- [ ] Enforce hard risk checks: single order value cap (<= ₹50,000), max 5 executed orders per day.
- [ ] Check exchange circuit limit bands before dispatching orders.
- [ ] Verify market data timestamp is < 300s old before permitting trade submission.

## Acceptance Criteria
- Orders violating rate limits or risk caps are rejected before reaching Angel One API.
"@
        labels = "safety,trading"
    },
    @{
        title = "Safety: Emergency Kill Switch System"
        body = @"
## Overview
Implement panic kill switch to halt all trading activities and revoke active sessions instantly.

## Tasks
- [ ] Add prominent red [KILL SWITCH] button in top navigation bar.
- [ ] Hitting button immediately revokes active Angel One session and invalidates JWT token.
- [ ] Call Angel One cancel-all-open-orders endpoint.
- [ ] Disable all order placement buttons across the entire terminal.

## Acceptance Criteria
- Clicking kill switch severs broker connectivity and stops any pending order executions within 500ms.
"@
        labels = "safety,critical"
    },
    @{
        title = "Data: 9-12 Year Historical Data Bootstrap & Ingestion"
        body = @"
## Overview
Bootstrap 10-12 years of historical daily Bhavcopy data into local DuckDB storage for backtesting.

## Tasks
- [ ] Write batch ingestion script pulling historical daily OHLCV for Nifty 500 stocks.
- [ ] Cleanse data: handle stock splits, bonus adjustments, and dividend subtractions.
- [ ] Store data as partitioned Parquet files indexed by DuckDB.
- [ ] Setup daily 18:30 IST sync job to append latest daily Bhavcopy.

## Acceptance Criteria
- 10+ years of daily OHLCV data for 500 stocks queried in < 200ms using DuckDB.
"@
        labels = "data,historical"
    },
    @{
        title = "Backtesting: Vectorized Backtesting Engine with Bias Controls"
        body = @"
## Overview
Implement high-performance backtesting engine for quantitative and AI strategies.

## Tasks
- [ ] Build vectorized backtest runner using in-memory DuckDB queries.
- [ ] Eliminate look-ahead bias by enforcing strict point-in-time timestamping.
- [ ] Model realistic transaction costs: brokerage (₹20), STT (0.1%), exchange fees, and 0.1% slippage.
- [ ] Compute performance metrics: Total Return, CAGR, Sharpe Ratio, Sortino, Max Drawdown.

## Acceptance Criteria
- Backtest runs across 10 years of daily data for 500 stocks in < 5 seconds with realistic cost deductions.
"@
        labels = "backtesting,quant"
    },
    @{
        title = "Analytics: Strategy Analytics & Equity Curve Visualizer"
        body = @"
## Overview
Render backtest visual analytics and trade performance reports in the terminal.

## Tasks
- [ ] Render interactive equity curve chart vs Nifty 50 benchmark.
- [ ] Display monthly/annual returns heatmap.
- [ ] Render trade log table with entry date, exit date, return %, and win/loss tags.
- [ ] Add CSV export button for backtest trade logs.

## Acceptance Criteria
- User can inspect complete strategy performance visually and export trade data to CSV.
"@
        labels = "analytics,frontend"
    },
    @{
        title = "DevOps: Production Hardening & Cloud VPS Deployment"
        body = @"
## Overview
Package ApexPathway with Docker Compose and deploy to cloud VPS with a dedicated Static IP.

## Tasks
- [ ] Create Dockerfile for Spring Boot backend and Vite frontend (served via Nginx).
- [ ] Create docker-compose.yml including PostgreSQL and persistent volume mounts.
- [ ] Deploy to Oracle Cloud Always-Free VM (or local static IP host).
- [ ] Configure Angel One developer dashboard with the static IP address.
- [ ] Execute full end-to-end acceptance test (real-time stream + regulatory alert + 1-click test trade).

## Acceptance Criteria
- Application runs continuously on cloud host with valid static IP and passes all Tier 1/2 success criteria.
"@
        labels = "devops,deployment"
    }
)

Write-Host "Ensuring required labels exist in $repo..." -ForegroundColor Cyan
$allLabels = ($issues | ForEach-Object { $_.labels -split ',' }) | ForEach-Object { $_.Trim() } | Select-Object -Unique
$existingLabels = (gh label list --repo $repo --limit 100 --json name --jq '.[].name' 2>$null)

foreach ($lbl in $allLabels) {
    if ($existingLabels -notcontains $lbl) {
        Write-Host "Creating label: $lbl" -ForegroundColor DarkCyan
        gh label create $lbl --repo $repo --color "0075ca" 2>$null | Out-Null
    }
}

Write-Host "Creating 24 GitHub issues in $repo..." -ForegroundColor Green

foreach ($issue in $issues) {
    Write-Host "Creating issue: $($issue.title)..." -ForegroundColor Yellow
    gh issue create --repo $repo --title $issue.title --body $issue.body --label $issue.labels
    Start-Sleep -Milliseconds 800
}

Write-Host "All 24 GitHub issues created successfully in $repo!" -ForegroundColor Green
