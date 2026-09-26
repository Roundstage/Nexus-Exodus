# Nexus Exodus no Docker

O build compila `DU.dme` dentro de uma etapa isolada com BYOND 516.1686 e
transfere somente o par recém-gerado `DU.dmb`/`DU.rsc` para a imagem final.
Artefatos existentes na máquina host são ignorados, evitando combinar um DMB
novo com um cache RSC antigo.

O `DU.dmb` incorpora as credenciais do HUB. Mantenha o pacote e a imagem em
armazenamento privado e recompile depois de qualquer rotação da senha.

## Desenvolvimento local no Linux

O modo local não precisa de Traefik. Instale Docker Engine com o plugin Compose
e execute, a partir da raiz do repositório:

```sh
./tools/Invoke-NexusLocalDocker.sh up
./tools/Invoke-NexusLocalDocker.sh logs
```

O comando publica somente no loopback do host:

- protocolo BYOND e página WebClient: `127.0.0.1:50000`;
- entrada do navegador/launcher: `http://localhost:50000/play`.

O Dream Daemon é iniciado com `-webclient`. O launcher de desenvolvimento já
aponta para essa URL e permite HTTP apenas por ser um endereço loopback no
ambiente `development`. Nenhuma porta fica acessível na LAN ou na internet.

Use `./tools/Invoke-NexusLocalDocker.sh status` para verificar o healthcheck e
`./tools/Invoke-NexusLocalDocker.sh down` para encerrar. O volume
`nexus-local_nexus_live_state` preserva os dados locais; `down` não o remove.
O runtime local também usa `live`, com recompensas de playtest desligadas.

## Iniciar o servidor live

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

O volume `nexus_live_state` preserva saves, mapas construídos, uploads e logs
entre atualizações. Faça backup desse volume antes de trocar a imagem. O
container inicia com `nexus_environment=live&nexus_playtest_rewards=0` e a tag
padrão é `live-516.1686`.

A mudança de nome cria um volume live novo. O antigo `nexus_state` de playtest
permanece separado, sem migração automática de personagens ou estado do mundo.
Reaplique no volume novo os administradores, bans, regras e logs que desejar
manter. A preservação automática descrita abaixo se aplica ao `Pwipe` dentro
do mesmo volume; a troca de volume não copia arquivos.

O comando administrativo **Pwipe** agora sempre limpa todo o progresso de jogo:
personagens, Feats, economia, facções e cargos (inclusive Grand Regent), itens,
construções e alterações do mapa. Ele registra um pedido persistente e reinicia
em 10 segundos. A limpeza ocorre antes de carregar os saves no próximo startup,
mantendo administração, bans, regras e logs. **Pwipe Settings** apenas explica
essa política; não existem opções para preservar Feats, itens ou construções.
Veja o escopo e a recuperação de falhas em [Wipe completo](../../docs/FullWipe.md).

Antes de iniciar o DreamDaemon, o entrypoint cria e testa os diretórios
persistentes de personagens, Feats, retratos, músicas e logs. Isso inclui os
caminhos separados de playtest em `data/Playtest`; uma falha de permissão
interrompe o container com o caminho afetado no log, em vez de manter o jogo
online sem conseguir salvar personagens.

Antes de uma atualização, salve o mundo pelo painel de administração. Depois,
atualize o repositório e reconstrua a imagem; não é necessário compilar ou
copiar artefatos manualmente. Nunca publique a imagem no Docker Hub ou em outro
registry público.

As alterações no **Server Control Panel** são gravadas imediatamente nos arquivos
`Misc`, `GAIN`, `Year` e `Votes`, dentro do volume `/srv/nexus`. Não dependem do
autosave do mundo, cujo intervalo é de 72 minutos. Essa correção exige reconstruir
a imagem; configurações que já voltaram ao padrão devem ser reaplicadas depois
da atualização. Reinícios e recriações devem continuar usando o mesmo volume.

O entrypoint também inicia um inspetor binário local antes do DreamDaemon.
Ele valida WEBP/WEBM enviados para perfis por assinatura, dimensões, tamanho e
SHA-1 dentro do mesmo volume privado; nenhum arquivo ou URL é enviado a um
serviço externo. O container falha no startup se o inspetor não ficar pronto.
Nos logs, as linhas `Profile media inspector is ready.` e
`Persistent runtime directories are ready.` confirmam as duas precondições.

## Investigar CPU alta na VPS

O build também oferece telemetria interna com rotação e capturas do profiler
pelo comando de admin **CPU Diagnostics**. Veja [o procedimento completo](../../docs/CpuDiagnostics.md).
O coletor do host descrito abaixo funciona imediatamente, sem reconstruir a imagem.

O campo `Processor` do jogo exibe `world.cpu`: a fração do tick usada por procs
e envio de informações do mapa, conforme a [referência do BYOND](https://www.byond.com/docs/ref/#/world/var/cpu).
Ele não substitui a medição do processo no Linux. CPU baixa nesse campo com
CPU alta no host exige distinguir o DreamDaemon, suas threads, o inspetor
Python e os processos do Docker antes de atribuir a causa ao código do jogo
ou ao container. `world.map_cpu` já é parte de `world.cpu`, não uma parcela
extra a somar.

Com o container em execução, rode **na própria VPS**, na raiz do repositório:

```sh
sh tools/Measure-NexusDockerCpu.sh
```

Se houver mais de um container Nexus, informe o nome explicitamente:

```sh
sh tools/Measure-NexusDockerCpu.sh docker-nexus-exodus-1
```

O script usa o socket local do Docker e comandos de leitura. Não instala
pacotes, inicia containers, reinicia o jogo ou altera saves. Também pode ser
usado com o container parado para consultar a configuração; nesse caso,
informa que não há amostra de CPU. Não é necessário reconstruir a imagem.

A coleta dura aproximadamente 20 segundos, além do tempo de resposta do
Docker. Ela mostra arquitetura do host/imagem, limites de CPU, reinícios,
consumo agregado, processos do host, threads do container e contadores de
throttling disponíveis. Registre o `Processor` do jogo durante essa mesma
janela. Para guardar o relatório, redirecione a saída para um arquivo fora do
repositório. O script não coleta saves, variáveis de ambiente ou logs de
jogadores. Use a configuração padrão do `top` (nomes dos processos, sem
argumentos) para obter os campos descritos abaixo.

Como interpretar:

- No `top` com o modo Irix padrão, 100% corresponde a uma CPU lógica ocupada;
  não significa necessariamente todas as CPUs da VPS. O modo Solaris divide
  esse valor pelo número de CPUs. A configuração pessoal do `top` pode mudar
  esse modo.
- Ignore o primeiro quadro do `top` por threads e compare os três seguintes.
  A tabela de `docker top` serve para identificar PIDs; seu `%CPU` é uma média
  desde o início do processo, não a mesma janela dos quadros seguintes.
- Uma thread do DreamDaemon alta, com `Processor` baixo na mesma janela,
  direciona a investigação para trabalho do engine fora dessa métrica. Isso
  ainda não identifica qual rotina nem comprova defeito do Docker.
- Python alto direciona a investigação para o inspetor de mídia. `dockerd` ou
  `docker-proxy` altos no quadro do host direcionam a investigação para o
  serviço Docker, logs ou rede. Os nomes das threads podem ser truncados.
- Esta imagem força `linux/amd64`. Host ARM com imagem AMD64 exige emulação;
  compare a arquitetura informada pelo **daemon Docker** com a imagem. A
  [documentação do Docker](https://docs.docker.com/build/building/multi-platform/)
  descreve o custo possível de emular uma arquitetura diferente.
- Compare os contadores `nr_throttled`/`throttled_usec` (ou `throttled_time` em
  cgroup v1) antes/depois. Crescimento indica limitação de CPU nessa janela.
  Valores ausentes dependem do layout/permissões do cgroup; não equivalem a
  zero. Quotas de grupos ancestrais da VPS também podem limitar o processo.

Se o servidor ficar responsivo com CPU alta, preserve uma coleta antes de
reiniciar. Processos muito breves entre quadros podem não aparecer; o total
do container ainda inclui esse trabalho. Uma coleta durante o startup também
deve ser distinguida do consumo sustentado após o mundo terminar de carregar.

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
servidor live principal. O nome de projeto diferente faz o Compose criar um volume
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
