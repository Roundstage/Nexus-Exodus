# Nexus Exodus no Docker

O build compila `DU.dme` dentro de uma etapa isolada com BYOND 516.1686 e
transfere somente o par recém-gerado `DU.dmb`/`DU.rsc` para a imagem final.
Artefatos existentes na máquina host são ignorados, evitando combinar um DMB
novo com um cache RSC antigo.

O `DU.dmb` incorpora as credenciais do HUB. Mantenha o pacote e a imagem em
armazenamento privado e recompile depois de qualquer rotação da senha.

## Iniciar o playtest

1. Configure `SECRETS.dm` localmente, sem registrar credenciais no Git.
2. Configure o roteador TCP do Traefik conforme a seção abaixo.
3. Libere a porta TCP 50000 no firewall da VPS.
4. Execute `docker compose up -d --build` neste diretório.
5. Acompanhe o primeiro startup com `docker compose logs -f`.

O entrypoint copia o par compilado para `/srv/nexus`, que também é o diretório
de trabalho do DreamDaemon. Isso mantém `DU.dmb`, `DU.rsc` e `DU.dyn.rsc` no
mesmo local, como o runtime do BYOND espera. O usuário sem privilégios do
container pode bloquear e atualizar o `DU.rsc`, além de criar o cache dinâmico,
enquanto o restante da imagem continua somente leitura. Quando o hash de
`DU.dmb` ou `DU.rsc` muda, o cache dinâmico antigo é removido e recriado para
não misturar recursos de builds diferentes.

O volume `nexus_state` preserva saves, mapas construídos, uploads e logs entre
atualizações. Faça backup desse volume antes de trocar a imagem. O container
inicia como playtest isolado e habilita os rewards self-service; não reutilize
esse volume posteriormente como servidor live.

Antes de iniciar o DreamDaemon, o entrypoint cria e testa os diretórios
persistentes de personagens, Feats, retratos, músicas e logs. Isso inclui os
caminhos separados de playtest em `data/Playtest`; uma falha de permissão
interrompe o container com o caminho afetado no log, em vez de manter o jogo
online sem conseguir salvar personagens.

Antes de uma atualização, salve o mundo pelo painel de administração. Depois,
atualize o repositório e reconstrua a imagem; não é necessário compilar ou
copiar artefatos manualmente. Nunca publique a imagem no Docker Hub ou em outro
registry público.

## Traefik em host network

O backend do jogo é publicado somente em `127.0.0.1:50001`. O Traefik deve
possuir um entrypoint estático `nexus` em `:50000/tcp` e encaminhá-lo para
`127.0.0.1:50001`. Como BYOND usa TCP sem TLS/SNI, a regra dinâmica precisa ser
``HostSNI(`*`)``; o subdomínio é resolvido pelo DNS, mas não participa da seleção
da rota.

Exemplo de configuração dinâmica:

```yaml
tcp:
  routers:
    nexus-exodus:
      entryPoints:
        - nexus
      rule: "HostSNI(`*`)"
      service: nexus-exodus
  services:
    nexus-exodus:
      loadBalancer:
        servers:
          - address: "127.0.0.1:50001"
```

Conecte com `byond://nexus-exodus.roundstage.net.br:50000`.

## Homologação isolada

Uma segunda instância pode usar outra porta, imagem e volume sem afetar o
playtest principal. O nome de projeto diferente faz o Compose criar um volume
separado:

```sh
NEXUS_BACKEND_PORT=50002 NEXUS_IMAGE_TAG=staging-516.1686 \
	docker compose -p nexus-staging up -d --build
```

A porta de homologação fica restrita ao loopback. Para torná-la pública, crie
outro entrypoint TCP no Traefik. Acompanhe os erros com:

```sh
docker compose -p nexus-staging logs -f
```

Para encerrar somente a homologação, preservando seu volume:

```sh
docker compose -p nexus-staging down
```
