# Nexus Exodus no Docker

Este diretório recebe um par `DU.dmb` e `DU.rsc` produzido pela mesma
compilação com BYOND 516.1686. Não copie fontes, `SECRETS.dm`, `.git`,
`HostKeys.txt` ou dados locais para o contexto Docker.

O `DU.dmb` incorpora as credenciais do HUB. Mantenha o pacote e a imagem em
armazenamento privado e recompile depois de qualquer rotação da senha.

## Iniciar o playtest

1. Copie `DU.dmb` e `DU.rsc` para este diretório.
2. Libere a porta TCP 50000 no firewall da VPS.
3. Execute `docker compose up -d --build` neste diretório.
4. Acompanhe o primeiro startup com `docker compose logs -f`.

O volume `nexus_state` preserva saves, mapas construídos, uploads e logs entre
atualizações. Faça backup desse volume antes de trocar a imagem. O container
inicia como playtest isolado e habilita os rewards self-service; não reutilize
esse volume posteriormente como servidor live.

Antes de uma atualização, salve o mundo pelo painel de administração. Depois,
substitua os dois artefatos juntos e reconstrua a imagem. Nunca publique a
imagem no Docker Hub ou em outro registry público.
