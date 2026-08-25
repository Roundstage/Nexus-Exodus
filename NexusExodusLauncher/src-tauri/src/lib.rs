mod config;
mod error;

use config::LauncherConfig;
use error::LauncherError;
use serde::Serialize;
use std::{
    fs::OpenOptions,
    io::Write,
    path::PathBuf,
    time::{SystemTime, UNIX_EPOCH},
};
use tauri::{AppHandle, Manager, WebviewUrl, WebviewWindow, WebviewWindowBuilder};

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct DiagnosticReport {
    launcher_version: &'static str,
    os: &'static str,
    architecture: &'static str,
    display_server: String,
    webview: &'static str,
    game_host: String,
    generated_at: String,
}

fn ensure_launcher(window: &WebviewWindow) -> Result<(), LauncherError> {
    if window.label() != "launcher" {
        return Err(LauncherError::CallerNotAllowed(window.label().to_owned()));
    }
    Ok(())
}

fn override_path(app: &AppHandle) -> PathBuf {
    app.path()
        .app_config_dir()
        .unwrap_or_else(|_| PathBuf::from("."))
        .join("launcher-config.json")
}

fn load_config(app: &AppHandle) -> Result<LauncherConfig, LauncherError> {
    LauncherConfig::load(&override_path(app))
}

fn log_event(app: &AppHandle, component: &str, message: &str) {
    let Ok(log_dir) = app.path().app_log_dir() else {
        return;
    };
    if std::fs::create_dir_all(&log_dir).is_err() {
        return;
    }
    let path = log_dir.join("launcher.log");
    let Ok(metadata) = std::fs::metadata(&path) else {
        append_log(&path, component, message);
        return;
    };
    if metadata.len() < 1_000_000 {
        append_log(&path, component, message);
    }
}

fn append_log(path: &std::path::Path, component: &str, message: &str) {
    let timestamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);
    if let Ok(mut file) = OpenOptions::new().create(true).append(true).open(path) {
        let _ = writeln!(file, "{{\"timestamp\":{timestamp},\"level\":\"INFO\",\"component\":{component:?},\"message\":{message:?}}}");
    }
}

#[tauri::command]
fn get_config(window: WebviewWindow, app: AppHandle) -> Result<LauncherConfig, LauncherError> {
    ensure_launcher(&window)?;
    load_config(&app)
}

#[tauri::command]
fn open_game(window: WebviewWindow, app: AppHandle) -> Result<(), LauncherError> {
    ensure_launcher(&window)?;
    if let Some(game) = app.get_webview_window("game") {
        game.show()
            .map_err(|error| LauncherError::Window(error.to_string()))?;
        game.set_focus()
            .map_err(|error| LauncherError::Window(error.to_string()))?;
        return Ok(());
    }

    let config = load_config(&app)?;
    let game_url = config.validated_game_url()?;
    let navigation_config = config.clone();
    let correlation_id = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis())
        .unwrap_or(0);
    log_event(
        &app,
        "game_window",
        &format!(
            "opening correlation_id={correlation_id} host={}",
            game_url.host_str().unwrap_or("unknown")
        ),
    );

    WebviewWindowBuilder::new(&app, "game", WebviewUrl::External(game_url))
        .title("Nexus Exodus")
        .inner_size(1280.0, 800.0)
        .min_inner_size(960.0, 600.0)
        .resizable(true)
        .on_navigation(move |url| navigation_config.validate_url(url.as_str()).is_ok())
        .build()
        .map_err(|error| LauncherError::Window(error.to_string()))?;
    Ok(())
}

#[tauri::command]
fn open_external_game(window: WebviewWindow, app: AppHandle) -> Result<(), LauncherError> {
    ensure_launcher(&window)?;
    let config = load_config(&app)?;
    if !config.external_browser_fallback {
        return Err(LauncherError::ExternalBrowser(
            "fallback desabilitado".into(),
        ));
    }
    let url = config.validated_game_url()?;
    open::that(url.as_str()).map_err(|error| LauncherError::ExternalBrowser(error.to_string()))
}

#[tauri::command]
fn get_diagnostics(
    window: WebviewWindow,
    app: AppHandle,
) -> Result<DiagnosticReport, LauncherError> {
    ensure_launcher(&window)?;
    let config = load_config(&app)?;
    let url = config.validated_game_url()?;
    let display_server = if std::env::var_os("WAYLAND_DISPLAY").is_some() {
        "Wayland"
    } else if std::env::var_os("DISPLAY").is_some() {
        "X11"
    } else {
        "unknown"
    };
    Ok(DiagnosticReport {
        launcher_version: env!("CARGO_PKG_VERSION"),
        os: std::env::consts::OS,
        architecture: std::env::consts::ARCH,
        display_server: display_server.into(),
        webview: if cfg!(target_os = "windows") {
            "WebView2"
        } else if cfg!(target_os = "linux") {
            "WebKitGTK"
        } else {
            "system webview"
        },
        game_host: url.host_str().unwrap_or("unknown").to_owned(),
        generated_at: SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .map(|d| d.as_secs().to_string())
            .unwrap_or_else(|_| "unknown".into()),
    })
}

pub fn run() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            get_config,
            open_game,
            open_external_game,
            get_diagnostics
        ])
        .on_window_event(|window, event| {
            if window.label() == "launcher" && matches!(event, tauri::WindowEvent::Destroyed) {
                if let Some(game) = window.app_handle().get_webview_window("game") {
                    let _ = game.close();
                }
            }
        })
        .run(tauri::generate_context!())
        .expect("failed to run Nexus Exodus launcher");
}
