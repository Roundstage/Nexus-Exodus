import { describe, expect, it } from "vitest";
import { isStatusEndpointAllowed, sanitizedHost } from "./validation";

const config = {
  environment: "test" as const,
  serverName: "Nexus",
  webClientUrl: "https://play.example.test/game?token=secret",
  allowedGameHosts: ["play.example.test"],
  externalBrowserFallback: true,
  diagnosticsEnabled: true,
};

describe("launcher URL helpers", () => {
  it("never exposes a query string when displaying a host", () => {
    expect(sanitizedHost(config.webClientUrl)).toBe("play.example.test");
  });

  it("requires an HTTPS allowlisted status endpoint", () => {
    expect(isStatusEndpointAllowed({ ...config, statusUrl: "https://play.example.test/status" })).toBe(true);
    expect(isStatusEndpointAllowed({ ...config, statusUrl: "https://evil.test/status" })).toBe(false);
  });

  it("allows HTTP loopback status only during development", () => {
    const local = { ...config, environment: "development" as const, allowedGameHosts: ["localhost"] };
    expect(isStatusEndpointAllowed({ ...local, statusUrl: "http://localhost:50000/play" })).toBe(true);
    expect(isStatusEndpointAllowed({ ...local, environment: "production", statusUrl: "http://localhost:50000/play" })).toBe(false);
  });
});
