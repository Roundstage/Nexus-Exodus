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

O entrypoint copia o par compilado para `/srv/nexus`, que também é o diretório
de trabalho do DreamDaemon. Isso mantém `DU.dmb`, `DU.rsc` e `DU.dyn.rsc` no
mesmo local, como o runtime do BYOND espera. O usuário sem privilégios do
container pode criar o cache dinâmico, enquanto o restante da imagem continua
somente leitura. Quando o hash de `DU.dmb` ou `DU.rsc` muda, o cache dinâmico
antigo é removido e recriado para não misturar recursos de builds diferentes.

O volume `nexus_state` preserva saves, mapas construídos, uploads e logs entre
atualizações. Faça backup desse volume antes de trocar a imagem. O container
inicia como playtest isolado e habilita os rewards self-service; não reutilize
esse volume posteriormente como servidor live.

Antes de uma atualização, salve o mundo pelo painel de administração. Depois,
substitua os dois artefatos juntos e reconstrua a imagem. Nunca publique a
imagem no Docker Hub ou em outro registry público.

## Homologação isolada

Uma segunda instância pode usar outra porta, imagem e volume sem afetar o
playtest principal. O nome de projeto diferente faz o Compose criar um volume
separado:

```sh
NEXUS_PORT=50001 NEXUS_IMAGE_TAG=staging-516.1686 \
	docker compose -p nexus-staging up -d --build
```

Conecte em `byond://IP_DA_VPS:50001` e acompanhe os erros com:

```sh
docker compose -p nexus-staging logs -f
```

Para encerrar somente a homologação, preservando seu volume:

```sh
docker compose -p nexus-staging down
```
