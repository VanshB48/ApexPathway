# ApexPathway — Phase 6: System Architecture & Implementation Code

> [!NOTE]
> **Spec-Driven Development (SDD) Guide**
> This document specifies the full application bootstrap, the Server-Sent Events tick broadcaster controller, the React 18 multi-panel Dockview workspace, and the TradingView Lightweight Charts canvas wrapper.

---

## 6.1 Backend Entrypoint (`backend/src/main/java/com/apexpathway/ApexPathwayApplication.java`)

```java
package com.apexpathway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class ApexPathwayApplication {

    public static void main(String[] args) {
        // Enable Java 21 Virtual Threads natively for all Web and Task Executions
        System.setProperty("spring.threads.virtual.enabled", "true");
        SpringApplication.run(ApexPathwayApplication.class, args);
    }
}
```

---

## 6.2 Real-Time Tick Broadcaster (`backend/src/main/java/com/apexpathway/marketdata/TickBroadcasterController.java`)

Streams live ticks over HTTP/2 using Server-Sent Events (SSE):

```java
package com.apexpathway.marketdata;

import com.apexpathway.common.dto.DomainModels.MarketTickDto;
import org.springframework.http.MediaType;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

@RestController
@RequestMapping("/api/v1/stream")
@CrossOrigin(origins = "*")
public class TickBroadcasterController {

    private final MarketCache marketCache;
    private final List<SseEmitter> activeEmitters = new CopyOnWriteArrayList<>();

    public TickBroadcasterController(MarketCache marketCache) {
        this.marketCache = marketCache;
    }

    @GetMapping(value = "/ticks", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter streamTicks() {
        SseEmitter emitter = new SseEmitter(0L); // Infinite timeout for persistent stream
        activeEmitters.add(emitter);

        emitter.onCompletion(() -> activeEmitters.remove(emitter));
        emitter.onTimeout(() -> activeEmitters.remove(emitter));
        emitter.onError((e) -> activeEmitters.remove(emitter));

        return emitter;
    }

    @Scheduled(fixedRate = 250) // Push updates at 4Hz to clients
    public void broadcastLatestTicks() {
        if (activeEmitters.isEmpty()) return;

        for (MarketTickDto tick : marketCache.getAllTicks()) {
            for (SseEmitter emitter : activeEmitters) {
                try {
                    emitter.send(SseEmitter.event().name("tick").data(tick));
                } catch (IOException e) {
                    emitter.complete();
                    activeEmitters.remove(emitter);
                }
            }
        }
    }
}
```

---

## 6.3 React 18 Dockview Workspace Layout (`frontend/src/components/workspace/TerminalWorkspace.tsx`)

Enables Bloomberg-style dockable and draggable multi-panel grids:

```tsx
import React from 'react';
import { DockviewReact, DockviewReadyEvent, IDockviewPanelProps } from 'dockview';
import 'dockview/dist/styles/dockview.css';

// Panel components
const ChartPanel: React.FC<IDockviewPanelProps> = () => (
  <div className="h-full bg-slate-950 p-2 text-white">Chart Panel (TradingView)</div>
);
const WatchlistPanel: React.FC<IDockviewPanelProps> = () => (
  <div className="h-full bg-slate-900 p-2 text-white">Watchlist Panel</div>
);
const NewsPanel: React.FC<IDockviewPanelProps> = () => (
  <div className="h-full bg-slate-900 p-2 text-white">Regulatory & News Alerts</div>
);
const BriefingPanel: React.FC<IDockviewPanelProps> = () => (
  <div className="h-full bg-slate-900 p-2 text-white">AI Morning Briefing & Picks</div>
);

export const TerminalWorkspace: React.FC = () => {
  const onReady = (event: DockviewReadyEvent) => {
    // Construct default Wall Street terminal multi-window grid
    const chart = event.api.addPanel({
      id: 'chart_panel',
      component: 'chart',
      title: 'Interactive Chart',
    });

    const watchlist = event.api.addPanel({
      id: 'watchlist_panel',
      component: 'watchlist',
      title: 'Watchlist',
      position: { referencePanel: chart, direction: 'left' },
    });

    const news = event.api.addPanel({
      id: 'news_panel',
      component: 'news',
      title: 'Regulatory Alerts',
      position: { referencePanel: chart, direction: 'below' },
    });

    event.api.addPanel({
      id: 'briefing_panel',
      component: 'briefing',
      title: 'AI Recommendations',
      position: { referencePanel: news, direction: 'right' },
    });
  };

  return (
    <div className="w-screen h-[calc(100vh-48px)] bg-slate-950">
      <DockviewReact
        components={{
          chart: ChartPanel,
          watchlist: WatchlistPanel,
          news: NewsPanel,
          briefing: BriefingPanel,
        }}
        onReady={onReady}
        className="dockview-theme-dark"
      />
    </div>
  );
};
```

---

## 6.4 TradingView Lightweight Charts Wrapper (`frontend/src/components/chart/TradingViewChart.tsx`)

```tsx
import React, { useEffect, useRef } from 'react';
import { createChart, IChartApi, ISeriesApi } from 'lightweight-charts';

interface ChartProps {
  data: { time: string; open: number; high: number; low: number; close: number }[];
}

export const TradingViewChart: React.FC<ChartProps> = ({ data }) => {
  const chartContainerRef = useRef<HTMLDivElement>(null);
  const chartApiRef = useRef<IChartApi | null>(null);
  const seriesRef = useRef<ISeriesApi<'Candlestick'> | null>(null);

  useEffect(() => {
    if (!chartContainerRef.current) return;

    const chart = createChart(chartContainerRef.current, {
      layout: { background: { color: '#020617' }, textColor: '#94a3b8' },
      grid: { vertLines: { color: '#1e293b' }, horzLines: { color: '#1e293b' } },
      width: chartContainerRef.current.clientWidth,
      height: chartContainerRef.current.clientHeight,
    });

    const candlestickSeries = chart.addCandlestickSeries({
      upColor: '#22c55e',
      downColor: '#ef4444',
      borderVisible: false,
      wickUpColor: '#22c55e',
      wickDownColor: '#ef4444',
    });

    candlestickSeries.setData(data as any);
    chartApiRef.current = chart;
    seriesRef.current = candlestickSeries;

    const handleResize = () => {
      if (chartContainerRef.current) {
        chart.applyOptions({
          width: chartContainerRef.current.clientWidth,
          height: chartContainerRef.current.clientHeight,
        });
      }
    };

    window.addEventListener('resize', handleResize);
    return () => {
      window.removeEventListener('resize', handleResize);
      chart.remove();
    };
  }, []);

  return <div ref={chartContainerRef} className="w-full h-full" />;
};
```

---

## 6.5 Phase 6 Implementation Checklist

- [ ] Verify `ApexPathwayApplication.java` boots with virtual threads enabled.
- [ ] Implement `TickBroadcasterController.java` and test with `curl -N http://localhost:8080/api/v1/stream/ticks`.
- [ ] Integrate Dockview in `frontend/src/components/workspace/TerminalWorkspace.tsx`.
- [ ] Embed `TradingViewChart.tsx` and render candlestick data in the chart panel.
