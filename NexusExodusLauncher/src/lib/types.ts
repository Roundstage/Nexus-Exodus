export type ServerStatus = "checking" | "online" | "offline" | "unknown";

export interface LauncherConfig {
  environment: "development" | "test" | "production";
  serverName: string;
  webClientUrl: string;
  allowedGameHosts: string[];
  externalBrowserFallback: boolean;
  diagnosticsEnabled: boolean;
  statusUrl?: string;
}

export interface DiagnosticReport {
  launcherVersion: string;
  os: string;
  architecture: string;
  displayServer: string;
  webview: string;
  gameHost: string;
  generatedAt: string;
}
