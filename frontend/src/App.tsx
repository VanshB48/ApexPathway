import { Activity, ShieldCheck, Terminal, Cpu } from 'lucide-react';

export default function App() {
  return (
    <div className="flex flex-col h-screen w-screen bg-slate-950 text-slate-100">
      {/* Top Navigation Bar */}
      <header className="flex items-center justify-between px-4 py-2 border-b border-slate-800 bg-slate-900/90 select-none">
        <div className="flex items-center gap-3">
          <Activity className="h-5 w-5 text-cyan-400 animate-pulse" />
          <span className="font-bold tracking-wider text-base bg-gradient-to-r from-cyan-400 to-blue-500 bg-clip-text text-transparent">
            APEXPATHWAY
          </span>
          <span className="text-xs px-2 py-0.5 rounded bg-cyan-950/80 text-cyan-400 border border-cyan-800/60 font-mono">
            TERMINAL v1.0
          </span>
        </div>
        
        <div className="flex items-center gap-4 text-xs font-mono text-slate-400">
          <div className="flex items-center gap-1.5">
            <span className="h-2 w-2 rounded-full bg-emerald-500" />
            <span>SmartAPI: Connected</span>
          </div>
          <div className="flex items-center gap-1.5">
            <ShieldCheck className="h-4 w-4 text-emerald-400" />
            <span>Interlocks: Active</span>
          </div>
          <div className="flex items-center gap-1.5">
            <Cpu className="h-4 w-4 text-indigo-400" />
            <span>Gemini 2.0: Ready</span>
          </div>
        </div>
      </header>

      {/* Main Workspace Area (Dockview Host Placeholder) */}
      <main className="flex-1 flex items-center justify-center p-6 bg-slate-950">
        <div className="max-w-xl w-full p-8 rounded-xl border border-slate-800/80 bg-slate-900/40 backdrop-blur text-center space-y-4">
          <div className="inline-flex p-3 rounded-full bg-cyan-500/10 border border-cyan-500/20 text-cyan-400 mb-2">
            <Terminal className="h-8 w-8" />
          </div>
          <h2 className="text-xl font-semibold text-slate-200">
            ApexPathway Market Terminal Ready
          </h2>
          <p className="text-sm text-slate-400 leading-relaxed">
            Multi-module foundational scaffolding active. High-frequency WebSocket ingestion, Dockview layout, and Gemini quantitative analysis engines initialized.
          </p>
          <div className="pt-4 grid grid-cols-3 gap-3 text-xs font-mono">
            <div className="p-3 rounded-lg bg-slate-800/40 border border-slate-700/50">
              <div className="text-slate-400">Spring Boot</div>
              <div className="text-emerald-400 font-semibold mt-1">Java 21</div>
            </div>
            <div className="p-3 rounded-lg bg-slate-800/40 border border-slate-700/50">
              <div className="text-slate-400">Frontend</div>
              <div className="text-cyan-400 font-semibold mt-1">React 18 / Vite</div>
            </div>
            <div className="p-3 rounded-lg bg-slate-800/40 border border-slate-700/50">
              <div className="text-slate-400">Secret Hygiene</div>
              <div className="text-indigo-400 font-semibold mt-1">Pre-Commit Active</div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
