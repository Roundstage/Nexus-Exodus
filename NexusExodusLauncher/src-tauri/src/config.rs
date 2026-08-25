use serde::{Deserialize, Serialize};
use std::{fs, path::Path};
use url::Url;

use crate::error::LauncherError;

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct LauncherConfig {
    pub environment: String,
    pub server_name: String,
    pub web_client_url: String,
    pub allowed_game_hosts: Vec<String>,
    pub external_browser_fallback: bool,
    pub diagnostics_enabled: bool,
    pub status_url: Option<String>,
}

impl LauncherConfig {
    pub fn load(override_path: &Path) -> Result<Self, LauncherError> {
        let bundled = include_str!("../resources/launcher-config.json");
        let contents = if override_path.is_file() {
            fs::read_to_string(override_path)?
        } else {
            bundled.to_owned()
        };
        let config: Self = serde_json::from_str(&contents)?;
        config.validated_game_url()?;
        if let Some(status_url) = &config.status_url {
            config.validate_url(status_url)?;
        }
        Ok(config)
    }

    pub fn validated_game_url(&self) -> Result<Url, LauncherError> {
        self.validate_url(&self.web_client_url)
    }

    pub fn validate_url(&self, raw: &str) -> Result<Url, LauncherError> {
        let url = Url::parse(raw).map_err(|_| LauncherError::InvalidUrl)?;
        if !url.username().is_empty() || url.password().is_some() {
            return Err(LauncherError::CredentialsInUrl);
        }
        let host = url.host_str().ok_or(LauncherError::InvalidUrl)?;
        if !self
            .allowed_game_hosts
            .iter()
            .any(|allowed| allowed == host)
        {
            return Err(LauncherError::HostNotAllowed(host.to_owned()));
        }
        let local_development = self.environment == "development"
            && url.scheme() == "http"
            && matches!(host, "localhost" | "127.0.0.1" | "::1");
        if url.scheme() != "https" && !local_development {
            return Err(LauncherError::SchemeNotAllowed);
        }
        Ok(url)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn config() -> LauncherConfig {
        LauncherConfig {
            environment: "production".into(),
            server_name: "Nexus".into(),
            web_client_url: "https://play.example.test/game?ticket=secret".into(),
            allowed_game_hosts: vec!["play.example.test".into()],
            external_browser_fallback: true,
            diagnostics_enabled: true,
            status_url: None,
        }
    }

    #[test]
    fn accepts_exact_allowlisted_https_host() {
        assert!(config().validated_game_url().is_ok());
    }

    #[test]
    fn rejects_subdomains_and_credentials() {
        let config = config();
        assert!(config
            .validate_url("https://sub.play.example.test/game")
            .is_err());
        assert!(config
            .validate_url("https://user:password@play.example.test/game")
            .is_err());
    }

    #[test]
    fn only_allows_http_for_local_development() {
        let mut config = config();
        config.environment = "development".into();
        config.allowed_game_hosts.push("localhost".into());
        assert!(config.validate_url("http://localhost:8080/game").is_ok());
        config.environment = "production".into();
        assert!(config.validate_url("http://localhost:8080/game").is_err());
    }
}
