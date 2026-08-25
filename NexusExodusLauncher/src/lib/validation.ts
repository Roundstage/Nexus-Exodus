import type { LauncherConfig } from "./types";

export function sanitizedHost(rawUrl: string): string {
  try {
    return new URL(rawUrl).host;
  } catch {
    return "invalid";
  }
}

export function isStatusEndpointAllowed(config: LauncherConfig): boolean {
  if (!config.statusUrl) return false;
  try {
    const status = new URL(config.statusUrl);
    const localDevelopment = config.environment === "development"
      && status.protocol === "http:"
      && ["localhost", "127.0.0.1", "::1"].includes(status.hostname);
    return (status.protocol === "https:" || localDevelopment)
      && config.allowedGameHosts.includes(status.hostname);
  } catch {
    return false;
  }
}
