import { useEffect, useMemo, useState } from "react";
import { launcherApi } from "../lib/tauri";
import { isStatusEndpointAllowed, sanitizedHost } from "../lib/validation";
import type { DiagnosticReport, LauncherConfig, ServerStatus } from "../lib/types";

const statusLabels: Record<ServerStatus, string> = {
  checking: "Verificando",
  online: "Online",
  offline: "Offline",
  unknown: "Indeterminado",
};

export function App() {
  const [config, setConfig] = useState<LauncherConfig>();
  const [status, setStatus] = useState<ServerStatus>("checking");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [diagnostics, setDiagnostics] = useState<DiagnosticReport>();

  useEffect(() => {
    launcherApi.getConfig().then(setConfig).catch((reason) => {
      setStatus("unknown");
      setError(String(reason));
    });
  }, []);

  useEffect(() => {
    if (!config) return;
    if (!isStatusEndpointAllowed(config)) {
      setStatus("unknown");
      return;
    }
    const controller = new AbortController();
    const timeout = window.setTimeout(() => controller.abort(), 5000);
    fetch(config.statusUrl!, { method: "GET", signal: controller.signal, cache: "no-store" })
      .then((response) => setStatus(response.ok ? "online" : "offline"))
      .catch(() => setStatus("offline"))
      .finally(() => window.clearTimeout(timeout));
    return () => {
      controller.abort();
      window.clearTimeout(timeout);
    };
  }, [config]);

  const diagnosticText = useMemo(
    () => diagnostics ? Object.entries(diagnostics).map(([key, value]) => `${key}: ${value}`).join("\n") : "",
    [diagnostics],
  );

  async function run(action: () => Promise<unknown>) {
    setBusy(true);
    setError("");
    try {
      await action();
    } catch (reason) {
      setError(String(reason));
    } finally {
      setBusy(false);
    }
  }

  async function copyDiagnostics() {
    const report = diagnostics ?? await launcherApi.getDiagnostics();
    setDiagnostics(report);
    await navigator.clipboard.writeText(Object.entries(report).map(([key, value]) => `${key}: ${value}`).join("\n"));
  }

  return (
    <main className="shell">
      <section className="hero">
        <p className="eyebrow">NEXUS EXODUS</p>
        <h1>Entre no campo de batalha</h1>
        <p className="lede">Protótipo WebClient — nenhuma instalação do Dream Seeker é necessária.</p>
      </section>

      <section className="panel" aria-live="polite">
        <div>
          <span className={`status status-${status}`} />
          <strong>{config?.serverName ?? "Carregando configuração"}</strong>
          <small>{statusLabels[status]}{config ? ` · ${sanitizedHost(config.webClientUrl)}` : ""}</small>
        </div>
        <button className="primary" disabled={!config || busy} onClick={() => run(launcherApi.openGame)}>
          {busy ? "Abrindo…" : "Jogar"}
        </button>
      </section>

      {error && <div className="error" role="alert">{error}</div>}

      <section className="actions">
        {config?.externalBrowserFallback && (
          <button disabled={busy} onClick={() => run(launcherApi.openExternal)}>Abrir no navegador</button>
        )}
        {config?.diagnosticsEnabled && (
          <button disabled={busy} onClick={() => run(copyDiagnostics)}>Copiar diagnóstico</button>
        )}
      </section>

      {diagnosticText && <pre>{diagnosticText}</pre>}
      <footer>Launcher {diagnostics?.launcherVersion ?? "0.1.0"} · {config?.environment ?? "inicializando"}</footer>
    </main>
  );
}
