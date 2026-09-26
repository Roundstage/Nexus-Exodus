# Diagnóstico de picos de CPU

## Coletar agora, sem reiniciar

Na raiz do repositório **na VPS**, durante um pico:

```sh
sh tools/Measure-NexusDockerCpu.sh > /tmp/nexus-cpu.txt
```

Se houver mais de um container Nexus, passe seu nome como argumento. Repita
durante um período saudável, usando outro arquivo. O coletor existente consulta
o socket Docker local e leva aproximadamente 20 segundos. Registre também o
horário e se os jogadores conseguiam se mover. Não é necessário instalar esta
alteração no jogo para usar o coletor do host.

`99.1% DreamDaemon` no `top` padrão significa aproximadamente um núcleo lógico
ocupado, não todos os núcleos da VPS. `TIME+` é CPU acumulada. Esse dado isolado
não identifica uma proc. Docker já executa sobre o kernel Linux: compare quotas,
throttling, arquitetura host/imagem, threads e CPU steal antes de atribuir o
problema ao container. O Compose versionado não define quota de CPU, mas a
configuração efetiva e limites ancestrais podem ser diferentes.

## Registro interno após instalar o novo build

`CpuDiagnostics.dm` inicia uma única tarefa ao final de `initialize()`. A cada
5 segundos de jogo grava em `data/Logs/cpu-telemetry.jsonl`:

- Horário UTC, tempo do mundo e intervalo real entre amostras.
- `world.cpu`, `world.map_cpu`, `world.tick_usage` no instante da amostra e FPS.
- Contagens das listas de clientes, jogadores, projéteis e alvos com status.
- Trabalho pendente nas filas de exclusão, descontando o prefixo já consumido.
- Tamanhos de caches de efeitos, explosões e indicadores, e fila de mapas.

As leituras usam os tamanhos das listas existentes; não percorrem o mapa nem
inventariam objetos. Uma entrada `spike` marca CPU >=80%, tick amostrado >=90%
ou atraso >=2 segundos além dos 5 segundos esperados. A duração real usa
`timeofday` e trata a passagem pela meia-noite UTC. A amostragem pode perder
picos curtos, e `tick_usage_sample` não representa o máximo do intervalo.
`map_cpu` já está incluído em `cpu`; não some os dois.

O arquivo gira ao atingir aproximadamente 2 MiB, mantendo apenas uma cópia
`.previous`. O limite pode ser ultrapassado pelo tamanho de uma entrada.
O buffer em memória mantém as últimas 20 amostras. Não são gravados nomes,
chaves de jogadores, mensagens, endereços ou saves.

## Capturar as procs

Como admin nível 5, abra **CPU Diagnostics** na categoria Admin. Se necessário,
use o **Legacy Verb Finder** do painel Admin e busque `cpuDiagnostics`:

1. **Capture 30 seconds** registra um intervalo normal ou um pico presente.
2. **Enable automatic profiles** arma capturas nos gatilhos acima até o reboot.
3. **Disable automatic profiles** desarma e exporta qualquer captura ativa.
4. **Status** informa CPU, captura ativa e tempo restante do cooldown.

O profiler fica desligado por padrão, pois tem custo adicional. Cada captura
usa o profiler nativo do BYOND, guarda as 20 amostras anteriores e os estados
inicial/final, e encerra no primeiro ciclo de amostragem após 30 segundos reais
(normalmente 30–35 segundos; pode atrasar mais sob sobrecarga). Há um intervalo
mínimo de 5 minutos após o fim entre capturas, inclusive manuais. Reiniciar uma
captura limpa os contadores anteriores do profiler nativo: não use outra sessão
de profiling em paralelo.

São mantidos até seis arquivos `data/Logs/cpu-profile-1.json` a
`cpu-profile-6.json`, sobrescritos em rodízio. Cada documento é limitado a 2 MiB;
uma exportação maior é rejeitada, sem cortar o JSON. A gravação usa um arquivo
temporário `.next`; falhas e o resultado `saved` aparecem no evento `profile_end`
e, em caso de falha, no log do servidor. Um slot antigo pode permanecer se a
nova gravação falhar: confira horário e `saved`. Os arquivos registram também
a versão real do BYOND; guarde a identificação da imagem/commit implantados
junto do relatório do host.

No JSON, `procs` contém a saída nativa do BYOND: compare principalmente `self`,
`total` e `calls` entre janelas de duração semelhante. `total` inclui chamadas
filhas; não some esses valores como se fossem custos independentes. O profiler
de procs não atribui todo o trabalho interno do engine: CPU alta no host com
pouco custo nas procs exige correlacionar `map_cpu`, threads e outras métricas.

Para manter o profiling automático após reboot, acrescente
`&nexus_cpu_profile=1` à string **existente** de `-params` do DreamDaemon,
preservando os parâmetros de ambiente/recompensas. `nexus_cpu_monitor=0`
desabilita completamente o monitor na inicialização. Não é preciso mudar
esses parâmetros para usar o comando de admin.

No Docker padrão, os arquivos ficam no volume persistente, em
`/srv/nexus/data/Logs/`. Para exportar, substitua `NOME_DO_CONTAINER` pelo nome
real e escolha um diretório local de destino:

```sh
docker cp NOME_DO_CONTAINER:/srv/nexus/data/Logs/cpu-telemetry.jsonl /tmp/nexus-cpu-telemetry.jsonl
docker cp NOME_DO_CONTAINER:/srv/nexus/data/Logs/cpu-profile-1.json /tmp/nexus-cpu-profile-1.json
```

Todos os monitores escritos em DM dependem de o engine voltar a executar procs.
Um travamento completo também interrompe a coleta e o encerramento da captura;
nessa situação, o coletor externo continua sendo necessário. A detecção de um
pico inicia o profiler **depois** do gatilho, portanto uma operação isolada que
já terminou pode não aparecer nele. RAM estável e caches pequenos também não
descartam loops repetidos. Os achados históricos em `PerformanceMemoryAudit.md`
não comprovam a causa do episódio atual.

Referências: [profiler e métricas do BYOND](https://www.byond.com/docs/ref/#/world/proc/Profile),
[campos do top](https://www.man7.org/linux/man-pages/man1/top.1.html),
[limites de recursos do Docker](https://docs.docker.com/engine/containers/resource_constraints/).
