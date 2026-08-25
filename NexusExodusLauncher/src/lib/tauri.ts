import { invoke } from "@tauri-apps/api/core";
import type { DiagnosticReport, LauncherConfig } from "./types";

export const launcherApi = {
  getConfig: () => invoke<LauncherConfig>("get_config"),
  openGame: () => invoke<void>("open_game"),
  openExternal: () => invoke<void>("open_external_game"),
  getDiagnostics: () => invoke<DiagnosticReport>("get_diagnostics"),
};
