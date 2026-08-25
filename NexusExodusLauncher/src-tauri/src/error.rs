use thiserror::Error;

#[derive(Debug, Error)]
pub enum LauncherError {
    #[error("a configuração do launcher não pôde ser lida: {0}")]
    Io(#[from] std::io::Error),
    #[error("a configuração do launcher contém JSON inválido: {0}")]
    Json(#[from] serde_json::Error),
    #[error("a URL configurada é inválida")]
    InvalidUrl,
    #[error("credenciais embutidas na URL não são permitidas")]
    CredentialsInUrl,
    #[error("o esquema da URL não é permitido")]
    SchemeNotAllowed,
    #[error("o host '{0}' não está autorizado")]
    HostNotAllowed(String),
    #[error("comando recusado para a janela '{0}'")]
    CallerNotAllowed(String),
    #[error("não foi possível criar a janela do jogo: {0}")]
    Window(String),
    #[error("não foi possível abrir o navegador externo: {0}")]
    ExternalBrowser(String),
}

impl serde::Serialize for LauncherError {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        serializer.serialize_str(&self.to_string())
    }
}
