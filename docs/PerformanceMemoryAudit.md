# Investigação de CPU e memória — 2026-09-09

## Atualização da base — 2026-09-11

As otimizações foram reaplicadas sobre `main` em `c73df60` na branch
`fix/runtime-performance`. Os relatos de 12 assertions preexistentes nas
rodadas abaixo descrevem a base antiga `7d698b3`, não a main atualizada.

A resolução de conflitos preserva os caminhos completos de assets da main e
a regra atual de Scatter Shot: limpar a seleção não desarma projéteis já
lançados contra o alvo capturado. O teste de homing agora limpa a seleção antes
do callback e exige que o projétil ainda arme e inicie o acompanhamento uma
única vez, mantendo também os testes de proteção contra reutilização do pool.

Validação após a integração:

- BYOND 516.1686/Linux via Docker: compilação com zero erros e zero warnings.
- Smoke com diretório limpo, fixture WEBP e inspector ativo: todas as assertions
  passaram, sem runtimes, incluindo os nove grupos novos de regressão e 30
  segundos de observação após a inicialização completa.
- `Test-NamingConventions.ps1 -PathStrict`: aprovado; sem violações de caminhos.
  O inventário legado de identificadores continua informativo, sem `-Strict`.
- `Test-AssetReferences.ps1 -Strict`: aprovado; 3.509 referências, zero problemas.
- Os scripts de auditoria foram executados em PowerShell/Linux em Docker. O
  smoke usou um harness Linux temporário, não o script Windows. Não há dados
  rastreados em `data/`; a modalidade versionada também começa sem saves.
- Logs e harness desta validação: `/tmp/nexus-performance-pr/`. Não houve teste
  manual com cliente, medição de CPU de produção ou deploy.

Revisão investigada: `7d698b3` (`feat/ki-weapons`, igual ao remoto na atualização).
O histórico remoto foi reescrito; o commit local `88c2453` era equivalente a
`9919b2a`. O estado anterior foi preservado em
`backup/ki-weapons-before-sync-20260909` antes do rebase.

Sintoma confirmado pelo operador: **a RAM permanece normal; apenas a CPU chega
a 100% por períodos prolongados**. Portanto a prioridade é trabalho repetido,
loops sobreviventes e lotes síncronos grandes. A retenção de caches é um achado
secundário e não foi demonstrada como explicação do incidente. A reprodução de
`text_overlay()` é compatível com esse relato: o cache permaneceu com um único
objeto enquanto a atividade duplicou.

## Escopo e limites

Foi realizada uma triagem estática dos 327 arquivos `.dm` de `src/` incluídos
diretamente por `DU.dme` (106.570 linhas). Uma busca lexical, desconsiderando
comentários, identificou aproximadamente 653 loops `while`/`for()` e 123 candidatos
sem `sleep`, `input` ou `alert` explícitos no bloco. Esses números são de triagem,
não de um parser DM: chamadas indiretas, strings e continuações de linha exigem
verificação manual. Um loop finito sem `sleep` não é, por si só, um defeito.

A revisão manual inicial concentrou-se nos candidatos, seus chamadores, inicialização,
loops de jogadores/NPCs, efeitos, projéteis, caches, descarte, salvamento e UI.
Isso não constitui certificação individual de todas as procs nem demonstra
ausência de outros problemas. Não foram acessados o processo, os saves ou os
logs de produção. A investigação inicial não alterou o jogo; a etapa de correção
autorizada posteriormente está registrada abaixo.

## Etapa de correção e continuação da análise

Os achados 1 e 2 foram corrigidos no working tree. Os números de linha das
seções originais abaixo se referem ao commit investigado, antes da correção.

- `text_overlay()` delega a movimentação a `obj/Effect/runFloatingText()`:
  uma tarefa com prazo finito, pertencente ao efeito, que termina mesmo se o
  dono original sair. O `Del()` do efeito invalida a geração antes de armazená-lo
  em cache. A tarefa antiga não move nem exclui uma instância reutilizada.
- As imagens de recompensas usam `runBountyPreview()` com prazo e geração,
  substituindo o loop e o timer independentes. O descarte invalida a tarefa.
- `runEffectLifecycleSmokeTests()` cobre retorno ao cache, imobilidade após
  expiração, reutilização antes de uma retomada e substituição de prévias.

Validação no BYOND 516.1686 via Docker:

- Compilação completa: zero erros, zero warnings.
- Testes novos: nenhuma falha e marcador `NEXUS_EFFECT_LIFECYCLE_TESTS_PASSED`.
- Experimento isolado original repetido com a correção: `pixel_y_delta=0`
  após expiração e novamente após reutilização do mesmo objeto. Antes eram
  respectivamente `12` e `24` na mesma janela de observação.
- Smoke completo comparado com uma compilação limpa de `git archive 7d698b3`:
  ambos apresentam as mesmas **12 falhas** de assertions, sem falhas adicionais
  na versão corrigida. Elas envolvem os controles do chat, aparência de Ki Fist,
  raio/dano/budget de Genki Dama e Supernova, ciclo de Anger e tier de pré-requisito
  de Ki Weapons. O baseline completo permanece reprovado; o marcador geral
  `NEXUS_SMOKE_TESTS_PASSED` sozinho não é suficiente, pois os runtimes das
  assertions não impedem o chamador de continuar até ele.
- Usada a fixture WEBP definida por `Invoke-ByondSmoke.ps1`, com o inspector
  externo ativo, para não confundir falta de fixture com regressão.
- Esta revisão não tem arquivos `data/` rastreados; os ambientes de runtime
  foram criados limpos. Não foram usados saves de produção. O script PowerShell
  de Windows não foi executado; a verificação usou o runtime Linux 516.1686.
- O servidor de teste foi observado por mais de 30 segundos após a inicialização.
  Os containers de teste foram encerrados; não foi feito deploy.

Logs da comparação nesta sessão: `/tmp/nexus-cpu-smoke.dYRKNM/baseline.log`
e `/tmp/nexus-cpu-smoke.dYRKNM/final.log`. A reprodução mínima ficou em
`/tmp/nexus-memory-audit.uk9QPX/Audit.dme`.

## Segunda rodada — tarefas de projéteis reciclados

Corrigidos no working tree após autorização para continuar:

- `Beam()` verifica a geração da utilização do projétil antes de cada ciclo.
  Devolver um beam ao pool e retirá-lo antes da retomada não mantém sua tarefa
  anterior de colisão executando.
- `startBlastLifecycle()` protege os callbacks de registro, aparência e o timer
  de borda. O identificador é separado de `projectile_flight_id`, pois homing
  pode reiniciar o voo dentro de uma mesma utilização.
- `Meteor_fly()` invalida voos anteriores ao iniciar outro voo e ao descartar
  o meteoro; verifica geração e cache também após o movimento/colisão.
- `castScatterShot()` usa `trackScatterShotTarget()`, que protege homing,
  acompanhamento de alvo e descarte aleatório contra reutilização, inclusive
  pelo mesmo dono. A perda do alvo interrompe o voo anterior.
- A continuação encontrou também `DeleteNoWait()` usado na colisão de tiros.
  O override de `/obj/Blast` captura a geração antes de esperar, impedindo que
  o descarte adiado exclua uma utilização posterior do mesmo objeto.

`runPooledProjectileSmokeTests()` cobre esses caminhos com os pools reais e
probes de colisão/movimento. Uma imagem anterior às correções desta rodada
reproduziu três assertions adicionais: colisões de beam após reciclagem,
movimentos extras de meteoro e exclusão de um tiro reutilizado pelo timer de
borda. Os testes também verificam que homing e timers da utilização atual
continuam funcionando; não se limitam a exigir inatividade.

Validação no BYOND 516.1686: compilação sem erros ou warnings; testes novos
sem runtimes. A comparação passou de 15 assertions na reprodução anterior
(12 preexistentes + 3 reproduções) para as mesmas 12 assertions do baseline.
O smoke completo, portanto, continua reprovado por problemas preexistentes.

Logs desta rodada: `/tmp/nexus-projectile-audit.CmyGiz/before.log` e
`/tmp/nexus-projectile-audit.CmyGiz/final.log`. Esses testes verificam ciclo de
vida, não substituem combate manual nem medição do processo em produção.

### Continuação da triagem — pendências

- `Timed_Delete()` em `Combat/Skills.dm` espera e exclui sem identificar a
  utilização. Há chamadores envolvendo pools de partes de corpo e crateras;
  é necessário testar descarte antecipado/reuso e tornar a liberação
  idempotente por pool. Alterar genericamente para “o último timer vence”
  poderia mudar a semântica de timers concorrentes legítimos.
- `Initialize_Learnable_Skills_List()` em `PlayerMechanics/Learn.dm` instancia
  todos os tipos de `/obj` antes de filtrar `Cost_To_Learn`. A ferramenta admin
  `manageLearnableSkills()` ainda chama essa proc: construtores de objetos que
  não são habilidades podem iniciar tarefas e criar objetos desnecessários.
  A opção Remove também instancia itens a cada interação. Revisar valores
  definidos em construtores antes de trocar por filtragem dos valores iniciais.
- `G_tick()` em `PathfindTest.dm` não encerra o ticker ao esgotar o caminho ou
  perder o alvo em determinados modos. Não foram encontrados chamadores de
  gameplay externos dos walkers contínuos; prioridade baixa até confirmar uso.

Esses achados não comprovam a causa dos 100% de CPU em produção. Em particular,
tarefas antigas podem operar sobre poucas instâncias reutilizadas sem aumento
perceptível da RAM. Os demais achados originais abaixo continuam pendentes,
salvo os itens 1 e 2 já corrigidos na primeira rodada.

## Terceira rodada — investigação de caminhos ativos

Nesta rodada foram feitos diagnósticos em uma cópia temporária do working
tree, sem novas alterações no código de gameplay. Os patches das rodadas
anteriores foram preservados. Não foi acessado o servidor de produção.

### A. Alto — efeito de lunge mantém o acompanhamento do dono anterior

Em `Combat/Melee.dm`, `Get_lunge_drawback_graphic()` retira a instância do pool;
`Lunge_Graphic/Del()` a devolve sem destruí-la. `Lunge_stick_to()` testa somente
`z` e o dono e retoma a cada `world.tick_lag`. Não há identidade por utilização.
Além disso, `Lunge_go()` tem sua própria sequência com pausas e exclusão final,
também sem identidade por utilização.

Reprodução com o pool real: iniciar o acompanhamento, devolver o objeto,
retirá-lo novamente e colocá-lo em outro turf antes da retomada. Após quatro
ticks, a mesma instância havia saído da nova posição e voltado ao dono antigo:
`same_object=1`, `stayed_at_new_position=0`, `followed_old_owner=1`.

O chamador `Do_lunge_drawback_animation()` é ativo no combate. A reprodução
forçou o momento da reciclagem, não mediu a frequência desse interleaving em
lutas reais. A correção precisa proteger tanto acompanhamento quanto animação
e descarte, como nos beams; apenas conferir `z` não basta.

### B. Alto — menus administrativos executam construtores sem necessidade

`Initialize_Learnable_Skills_List()` instancia cada tipo de objeto antes de
filtrar seu custo. A reprodução executou a proc real, com `usr` apontando para
um mob de teste: o construtor de um probe sem custo foi chamado e
`CollectedSouls` do usuário aumentou em **1**, por causa de
`Contract_Soul/New()`. O catálogo resultante tinha 66 entradas. Portanto não
é apenas uma suspeita de custo: há efeito colateral de gameplay antes de
selecionar qualquer habilidade. Sem `usr`, uma primeira execução diagnóstica
gerou `Cannot read null.CollectedSouls`; não confundir esse erro do teste com
o comportamento do menu admin, onde o usuário existe.

O snapshot continha 1.329 tipos de `/obj` (incluindo dois probes adicionados
somente no teste); 66 tinham custo inicial não nulo. A execução final com
usuário de teste válido terminou sem runtimes, apesar do efeito colateral.

A busca encontrou o mesmo padrão em `Admin/Admin.dm`:

- `giveItem()` zera `Give_List` a cada abertura e instancia todos os objetos
  que correspondem ao texto de busca, antes de verificar `Givable`.
- `make()` faz o mesmo para `Makeable`; na seção de mobs instancia **todos os
  tipos de mob antes mesmo de filtrar pela busca**.
- `referenceObject = 1` é atribuído após `new`, tarde demais para impedir
  efeitos síncronos do construtor. Cancelar o menu não desfaz esses efeitos.

As duas ferramentas foram verificadas estaticamente; não houve interação
manual com seus menus. A limpeza das listas não é uma chamada de destruição,
e objetos podem ter se registrado em listas globais ou iniciado tarefas.
Não foi demonstrado que todo objeto criado fica retido para sempre.
Priorizar catálogos de metadados/tipos e instanciar somente a escolha final.
Há exemplos de filtragem inicial já usados em `registerLegacySkills()` e na
montagem das árvores de progressão. Preservar nomes customizados, permissões
e compatibilidade com habilidades cujo construtor altera seus atributos.

### C. Médio — progressão repete varreduras de inventário sem mudanças

`execute_player_actions()` chama `process_player_action_cycle(TRUE)` a cada
100 decissegundos. `syncProgressionTrees()` varre o catálogo completo e, para
cada recompensa de habilidade, `hasExactProgressionRewardObject()` percorre
o inventário; recompensas possuídas ainda podem provocar outra consulta em
`applyProgressionNodeReward()`.

Foi instrumentada somente a contagem de visitas no loop real de
`hasExactProgressionRewardObject()`. Após aquecer/migrar o personagem de teste,
uma nova sincronização sem mudanças produziu:

| Objetos no inventário | Nós no catálogo | Visitas a objetos por sincronização |
| ---: | ---: | ---: |
| 1 | 485 | 265 |
| 100 | 485 | 25.510 |
| 500 | 485 | 127.510 |

Os objetos adicionais eram probes neutros; o primeiro objeto foi obtido na
inicialização da progressão. São contagens de operações, não milissegundos
nem percentuais de CPU. O custo inclui buscas por igualdade exata de tipo,
não buscas por subtipos. Um índice temporário por tipo, construído uma vez por
sincronização, pode preservar essa regra e evitar as varreduras repetidas;
ele deve ser atualizado quando a própria sincronização acrescentar skills.
Passar a atualização exclusivamente por eventos exige revisar também
ensino, administração, remoção de habilidades e carregamento de saves.

Outro trabalho repetido no mesmo ciclo: tanto `syncProgressionTrees()` quanto
`syncTechnologyProgression()` chamam `normalizeIndividualScienceItems()`.
Ela recria listas e busca cada blueprint linearmente em `tech_list`, mesmo
sem alterações. Esse custo adicional foi identificado no código, não medido
pela contagem acima.

### D. Médio — fade antigo de cratera e timer genérico atingem o próximo uso

`Crater/SmallCraterDel()` inicia animação e espera 21 decissegundos antes de
guardar no pool, sem guarda de descarte em andamento. No teste, duas chamadas
de `del` separadas por cinco ticks criaram dois fades; o primeiro liberou a
cratera, a fábrica reutilizou-a, e o segundo retirou a nova utilização do mapa.
Resultado: `same_object=1`, `active_before_old_fade=1`,
`active_after_old_fade=0`, `cached=1`.

Também foi reproduzido o risco de `Timed_Delete()` com `/obj/Effect` real:
um timer foi agendado, o efeito devolvido ao cache e reutilizado antes de
expirar; o timer antigo o devolveu ao cache novamente. O teste selecionou
explicitamente a mesma instância, pois a fábrica de efeitos escolhe ao acaso.
Isso confirma descarte indevido, não um loop infinito no próprio timer.

Há chamadores ativos de crateras em melee, projéteis e buffs, e de
`Timed_Delete()` em efeitos de Ultra Instinct, afterimages e partes de corpo.
`BigCraterDel()` e `Explosion/Explosion()` apresentam tarefas adiadas similares,
ainda sem reprodução específica nesta rodada. Corrigir por ciclo de vida de
cada pool, incluindo descarte idempotente; não apenas encurtar os timers.

### E. Dependente de carga — Sense e salvamento

- O Sense percorre as setas de cada observador a cada 2,5 decissegundos. A
  lista contém os demais jogadores da área, inclusive quando a seta está
  invisível. Há cache de posição, visibilidade e aparência, mas a iteração
  permanece. Com P observadores ativos na mesma área, o caso de todos
  possuírem as P−1 setas implica aproximadamente `4 × P × (P−1)` visitas por
  segundo de jogo, além dos readouts. Essa é uma estimativa estrutural, não
  um benchmark; o engine pode arredondar o intervalo ao tick e jogadores
  inativos pausam. Medir por área antes de reduzir alcance/frequência.
- `saveWorldRepeat()` dispara a cada 72 minutos. `mapSave()` percorre `Turfs`
  sem pausas explícitas e escreve segmentos de 20.000 entradas. O
  `set background` de `saveItems()` não se aplica a `mapSave()`. Correlacionar
  os episódios com as mensagens de salvamento e tamanho de `Turfs`/saves;
  não há evidência de que esse seja o incidente relatado.

### Validação e limites desta rodada

O snapshot diagnóstico compilou no BYOND 516.1686 com zero erros e warnings,
e executou em containers sem rede. O harness substituiu a chamada do smoke
por diagnósticos: **não é uma nova aprovação do smoke completo**, que mantém
as 12 falhas preexistentes já registradas. A contagem de tipos do snapshot
inclui os dois tipos de probe adicionados apenas nele.

Fontes e harness: `/tmp/nexus-perf-investigation.7k6ZpQ/`, especialmente
`src/Code/Tests/PerformanceInvestigation.dm`. Resultados finais:
`/tmp/nexus-perf-investigation.7k6ZpQ/final.log`. As contagens de inventário
vieram de instrumentação da proc, sem substituí-la por um algoritmo simulado.
Os testes de descarte forçam reutilização antecipada; não medem sua taxa em
produção. Não houve deploy, alteração de saves reais ou mudança de gameplay
nesta rodada. Os containers diagnósticos foram encerrados ao concluir a coleta.

## Quarta rodada — correções após autorização

Os itens A–D da terceira rodada receberam correções no working tree. As
reproduções acima descrevem o comportamento anterior, não o estado corrigido.

- **Lunge:** animação, acompanhamento e exclusão verificam a mesma utilização.
  Iniciar outra animação ou devolver o objeto ao pool invalida tarefas antigas.
- **Descarte:** `Timed_Delete()` captura `deferred_delete_generation`. A base
  `obj/Del()`, o cache genérico e os pools de efeitos, partes de corpo,
  crateras, explosões e blasts invalidam esse identificador ao liberar/reusar.
  Timers concorrentes na mesma utilização mantêm o primeiro prazo válido;
  agendar um timer posterior não adia a exclusão anterior.
- **Crateras:** fades passam a ser idempotentes. O segundo `del` não agenda
  outra animação de descarte. Crescimento e expiração de crateras grandes
  também são protegidos contra reutilização.
- **Pools especializados:** inserções repetidas de efeitos/partes de
  corpo/explosões são deduplicadas. `reallyDelete` permite destruição efetiva
  desses visuais e de crateras/lunge, removendo a instância do pool.
- **Menus administrativos:** `GiveItem` e `Make` usam listas locais de
  metadados, sem instanciar objetos ou mobs para mostrar opções. A escolha
  final é que executa o construtor. Nomes iniciais e caminhos completos
  distinguem tipos homônimos; a busca de mobs aceita nome inicial ou caminho,
  não nomes aleatórios gerados por construtores. As restrições de tipos,
  roupas, `Rank` e a exceção de Auto Shadow Spar foram preservadas.
- **Habilidades aprendíveis:** `Learnable_Skills` agora armazena tipos, e os
  dois caminhos administrativos deixam de construir amostras. Foi removido
  somente o menu legado inalcançável após o `return` de `Learn()`; a interface
  ativa de Progression Trees não foi trocada.
- **Progressão:** um índice local por tipo exato substitui as varreduras de
  inventário a cada consulta. É reconstruído na próxima sincronização e
  após concessões de skills/magia dentro da sincronização atual. Chamadores
  sem índice mantêm a consulta direta original.

O teste com inventário de 500 objetos agora registra **500 itens indexados,
265 consultas ao índice e zero consultas sem índice**, em vez das 127.510
visitas anteriores. Não é uma medição de redução percentual da CPU total.

`runPerformanceCatalogSmokeTests()` e `runDeferredLifecycleSmokeTests()` foram
adicionados ao smoke. Cobrem restrições/busca dos menus, ausência de chamadas
de construtores, tipos exatos, itens removidos e concessões sem duplicação,
reuso antes de animações/timers, liberação idempotente e expiração normal.
As fixtures que precisam de uma instância específica a colocam na frente do
pool antes de usar a fábrica real, evitando depender da ordem dos outros
efeitos criados pelos testes de combate.

Validação no BYOND 516.1686/Linux via Docker: zero erros e warnings de
compilação. As duas rodadas completas passaram nos testes novos e apresentaram
exatamente as mesmas 12 assertions preexistentes de `7d698b3`, sem regressões
adicionais. O smoke geral continua reprovado por essas falhas; seus marcadores
de conclusão não significam aprovação completa. A versão final inclui também
testes de partes de corpo, afterimages e animação de explosões. Logs:
`/tmp/nexus-performance-round4.NzIkHG/first.log` e
`/tmp/nexus-performance-round4.NzIkHG/final.log`.
Após mais de 30 segundos de observação pós-inicialização, a lista de runtimes
continuou idêntica ao baseline. Os containers desta rodada foram encerrados.

Continuam pendentes a normalização repetida de blueprints, a carga do Sense,
os salvamentos e os demais achados originais. O novo identificador não
instrumenta automaticamente todos os overrides legados de `Del()` nem todos
os callbacks escritos com `spawn`; outros pools precisam de revisão explícita.
Não foi feito deploy nem validação interativa de combate/menus em cliente.

## Quinta rodada — blueprints, Sense e revisão do salvamento

### Correções implementadas

- **Blueprints:** `getNormalizedScienceBlueprintList()` resolve os tipos
  solicitados em uma passagem compartilhada por `tech_list`, em vez de fazer
  uma busca linear para cada tipo. Preserva ordem, primeiro objeto canônico,
  tipos desconhecidos e remoção de duplicatas/entradas inválidas. O resultado
  continua sendo uma lista nova, sem modificar a entrada. O índice é local à
  chamada: substituições e reordenações do catálogo, inclusive sem mudar seu
  tamanho, são observadas imediatamente. As duas chamadas de normalização
  no ciclo periódico continuam existindo, agora com custo linear por chamada;
  não foi introduzido cache persistente nem controle de invalidação incompleto.
- **Readouts do Sense:** o poder do observador é calculado uma vez por lote,
  compartilhando somente esse valor durante a atualização atual. O poder dos
  alvos continua sendo calculado ao atualizar. HTML/maptext só é reconstruído
  quando a porcentagem muda ou a imagem está vazia; offsets só são escritos
  quando mudam. O estado por alvo é removido junto com o readout e na limpeza
  geral, inclusive sem cliente.
- **Setas do Sense:** a posição do observador é calculada uma vez por lote de
  setas, e a transformação de escala não é refeita quando o tamanho é igual.
  Uma reconciliação que já atualizou todos os readouts agenda o próximo prazo,
  evitando uma segunda atualização completa no mesmo tick.

Não foram alterados alcance, regras de visibilidade, limites de porcentagem,
penalidade de KO nem intervalos regulares. O custo proporcional ao número de
pares observador/alvo continua existindo; esta rodada remove trabalho
redundante dentro desses caminhos, não elimina sua dependência da lotação.

### Medições e testes

Em snapshot isolado, o catálogo inicializado tinha 125 entradas/tipos. A
normalização anterior realizou **7.875 visitas ao catálogo**; a nova realizou
**125**, com zero diferenças de resultado ou ordem. A versão anterior foi
executada diretamente no snapshot pré-correção; a nova implementação foi
incluída nele com outro nome para comparar o mesmo estado. As visitas foram
contadas dentro dos respectivos loops, não inferidas de duração de parede.
Isso não significa redução de 63 vezes na CPU total: ainda há as passagens
pela lista de blueprints, alocações e o restante do jogo.

`runBlueprintSenseWorkSmokeTests()` cobre canonicidade, duplicatas, tipos
desconhecidos, entradas inválidas, catálogo reordenado com mesmo tamanho e
preservação da lista original. No Sense, cobre KO, zero, teto de 999%, offsets,
escala, remoção/limpeza e atualização compartilhada. Em **100 atualizações
idênticas de um readout**, houve zero reescritas de aparência e zero recálculos
da magnitude do observador já fornecida ao lote. A magnitude do alvo continua
sendo calculada. Os testes usam imagens nativas, mas não um cliente conectado:
renderização e visibilidade interativa continuam exigindo validação manual.

Compilação BYOND 516.1686/Linux: zero erros e warnings. Os testes novos passaram;
o smoke completo apresentou exatamente as mesmas 12 assertions preexistentes
do baseline, sem novas falhas. Portanto o baseline completo continua reprovado.
Logs e harness em `/tmp/nexus-performance-round5.OzOqFI/`, incluindo
`benchmark.log`, `final.log` e `src/Code/Tests/BlueprintWorkAudit.dm`.
Após mais de 30 segundos de observação pós-inicialização, a lista de runtimes
continuou idêntica ao baseline. Os containers desta rodada foram encerrados;
não foi feito deploy nem acessado o processo de produção.

### Salvamento — mantido sem alterações nesta rodada

A revisão confirmou que `mapSave()` é chamada pelo salvamento periódico,
comandos administrativos, wipe/reset e `saveWorld()`, que também é aguardada
pelos fluxos de reboot e shutdown. Há `spawn` e pausas em torno dessas
chamadas. Introduzir pausas no meio da varredura/escrita permitiria novas
intercalações entre saves; uma guarda que simplesmente retorna quando já
existe um save poderia permitir reboot antes da conclusão necessária.

O próximo passo de persistência deve coordenar escritores e espera dos
chamadores, testar requisições concorrentes e definir uma captura consistente
dos dados antes de adicionar orçamento por tick. O manifest e os segmentos
devem continuar concordando quando há interrupção/falha. Esta é uma exigência
para a futura alteração, não evidência de corrupção atualmente reproduzida.
Sem saves/carga de produção, não foi atribuído ao salvamento o episódio de CPU.
Nenhum formato de save, ritmo de gravação ou rotina de reboot foi alterado.

## Sexta a oitava rodadas — término de trabalho e descarte em lotes

Após a autorização para investigar e corrigir iterativamente, foram aplicadas
três rodadas incrementais, sem deploy ou alterações nos dados de produção:

- **Wall of Flame:** `NexusFlameField` passa a ter um único processador e
  destruição real. Limpa dono e tabelas de pulsos e não pode entrar no cache
  genérico de visuais. Local/dono ausentes ou descarte lógico encerram o campo;
  duração não finita usa o padrão. O teste cobre expiração e exclusão antecipada.
- **Auras:** os dois workers da aura comum e de Ultra Instinct param quando
  `deleted` é marcado. A espera pela coleta física não prolonga a animação.
- **Leech:** rejeita quantidade não positiva/não finita, repete a validação
  depois dos modificadores e rejeita magnitudes para as quais subtrair um não
  produz avanço. O antigo `while(N)` poderia nunca terminar com valor negativo.
  A fórmula de ganho e o arredondamento probabilístico dos valores válidos
  permanecem. Isto não resolve ainda o custo de lotes positivos muito grandes.
- **Orbs:** busca limitada a 1.024 coordenadas e retorno explícito de null;
  resolve o turf antes de construir a orb. `Del()` remove os registros das duas
  listas e a desativação percorre uma cópia. Se as áreas válidas forem muito
  esparsas, a rodada pode terminar sem preencher as quatro orbs; não há garantia
  de localização válida dentro do orçamento nem retry automático novo.
- **Descarte:** logout usa enqueue idempotente com invalidação dos callbacks
  e uma cópia de `contents`. A fila pendente usa índice de leitura e compactação,
  em vez de procurar/remover cada item da lista inteira. O worker processa até
  25 entradas por intervalo de dez ticks. As duas filas limitam pedidos a 250
  entradas e interrompem o lote em 80% de `world.tick_usage`, após progresso.
  O descarte solicitado por `saveWorld()` também cede um tick entre lotes;
  continua aguardando o agendamento da fila, não os internos assíncronos dos
  destrutores. O orçamento não interrompe um destrutor isolado custoso.
- **Meteoros administrativos:** a seleção `pick(factory(), factory())`
  requisitava dois objetos e só utilizava um. Agora escolhe o tipo primeiro.
  A lista de turfs de raio 40 é construída uma vez por comando, não uma vez
  por meteoro; a criação cede tempo a cada dez objetos ou ao atingir 80% do tick.
  O log registra a quantidade realmente criada. Para N meteoros e T turfs,
  a varredura explícita cai de N×T para T e as requisições ao cache de 2N para N;
  isso é contagem de trabalho do código, não medição da CPU em produção.

### Validação desta sequência

A sexta rodada compilou com BYOND 516.1686 sem erros/warnings e seus novos
testes passaram. O smoke completo produziu exatamente as mesmas 12 mensagens
de runtime de assertions do baseline. Log:
`/tmp/nexus-performance-round6.wNGqLF/round6.log`.

Na sétima rodada, duas verificações de FIFO inicialmente guardavam referências
de objetos como resultado de `&&`; a exclusão posterior convertia o resultado
guardado em null. Os testes foram corrigidos para guardar booleanos explícitos.
O marcador geral de sucesso não foi tratado como evidência suficiente: os
runtimes completos continuaram sendo comparados ao baseline.

A oitava rodada final (`nexus-exodus:performance-round8`, imagem
`3a5c4f80f2fd`) compilou com zero erros e zero warnings. Passaram os testes
novos de limites, efeitos especializados, fila pendente e meteoros, além dos
testes de desempenho adicionados nas rodadas anteriores. O log completo
`/tmp/nexus-performance-round6.wNGqLF/round8.log` contém exatamente as mesmas
12 mensagens de assertions do baseline, sem novas mensagens de runtime.
`git diff --check` também passou. O smoke global permanece reprovado pelas
falhas preexistentes; não foi declarado verde. A validação foi headless em
Docker/Linux isolado, não gameplay manual com clientes nem o script Windows.
Os containers de smoke desta sequência foram encerrados após a coleta; o
servidor local já existente não foi alterado.

### Riscos que permanecem abertos

`mapSave()` mantém sua implementação e formato: introduzir yield nos escritores
requer coordenar save, wipe e reboot e testar consistência entre manifest e
segmentos. O lote de descarte ao final de `saveWorld()` foi melhorado, mas não
constitui otimização da serialização do mapa. `Leech()` ainda precisa de medição
e processamento seguro dos lotes grandes válidos, considerando o estado
temporário do alvo e `isSparring`. Foram encontrados outros caminhos legados
de criação administrativa e buscas aleatórias que merecem uma próxima rodada;
não foram declarados como causa de produção ou corrigidos sem validação.

## Achados prioritários originais

### 1. Alto — loops de textos flutuantes sobrevivem ao efeito (reproduzido)

- `src/Code/CoreFunctions/MainWorld.dm:480`, `text_overlay()`.
- `src/Code/VisualEffects/EffectCache.dm:31`, `/obj/Effect/Del()`.
- Chamadores ativos: `src/Code/Application/Movement/MovementInput.dm:275`
  e `src/Code/Combat/NexusSpecialStyles.dm:246`.

Cada chamada cria `spawn while(i)` atualizando `pixel_y` a cada `sleep(4)`.
Depois do prazo, `del(i)` apenas coloca o efeito em `effect_cache`; o override
de `Del()` não chama o destrutor padrão. Portanto `i` continua existindo e o
loop permanece vivo. Ao reutilizar esse efeito, os loops antigos continuam
alterando-o junto com o novo loop. O número de tarefas pode crescer com o uso,
mesmo que o tamanho do cache permaneça constante.

Em um cenário de N tarefas sobreviventes, há aproximadamente 2,5 × N retomadas
por segundo de tempo de jogo, sem contar o custo das alterações de aparência.
Essa estimativa não é uma medição de CPU de produção.

Reprodução isolada em Docker, sem rede externa, no BYOND **516.1686**:
o teste incluiu o `EffectCache.dm` real, uma cópia da proc `text_overlay()` e
dependências mínimas. Compilou com zero erros e zero warnings. Em janelas de
12 decissegundos após a expiração:

```text
AUDIT version=516.1686
AUDIT after_expiry cache=1 loc= pixel_y_delta=12
AUDIT after_reuse same_object=1 cache=1 pixel_y_delta=24
AUDIT after_owner_deleted pixel_y_delta=0
```

Ou seja, o efeito já estava sem localização; a atividade continuou e dobrou
após a segunda utilização. Excluir efetivamente o dono encerrou as tarefas.
O processo isolado foi encerrado pelo timeout de 15 segundos após emitir os
resultados. Isso não foi um smoke test completo do servidor.

Correção proposta: limitar o loop à duração e à geração específica do efeito,
ou substituir o movimento incremental por uma animação com duração finita.
Apenas testar `loc`/`z` não protege contra reutilização entre duas retomadas.

### 2. Alto — imagens de recompensas repetem o mesmo padrão

- `src/Code/PlayerMechanics/Inventory.dm:910`, visualização da recompensa.
- `src/Code/BackgroundCode/ObjectCache.dm:8`, cache de `/obj/Bounty_Picture`.
- `src/Code/Infrastructure/ObjectLifecycle.dm:74`, caminho para `CacheObject()`.

O bloco cria `spawn while(O)` para girar a imagem e agenda `del(O)` após 100
ticks. A imagem é armazenada em cache, portanto o loop continua e pode se
acumular com novas consultas. O `src` da tarefa é o objeto que fornece a
interação; sair da janela não é condição de encerramento.

Achado por encadeamento estático; não houve reprodução integral da interface.
Aplicar prazo/generation token e invalidar tarefas no retorno ao cache.

### 3. Alto — Wall of Flame alimenta um cache sem limite e retém referências

- `src/Code/Combat/NexusSpecialStyles.dm:55`, criação de até cinco campos por uso.
- Mesmo arquivo, `:208`, `/obj/Effect/NexusFlameField`.
- `src/Code/VisualEffects/EffectCache.dm:31`.

Os campos são sempre criados com `new`, mas, ao expirar, o `Del()` herdado os
guarda no cache genérico. O descarte não limpa `owner`, `next_pulse_by_target`
nem `pulses_by_target`; `ResetVars()` só é chamado quando algum consumidor
retira um efeito do cache. Não existe limite de retenção nesse cache.

Assim, usos sucessivos sem consumo suficiente pelo `GetEffect()` podem aumentar
a retenção de campos e de suas referências. O pool também mistura o subtipo
`NexusFlameField` com efeitos genéricos. O tamanho efetivo em produção depende
da relação entre criação e reutilização; não foi medido.

Correção proposta: destruir realmente os campos especializados ou usar um pool
separado e limitado, com limpeza de referências ao liberar o objeto.

### 4. Médio — filas de descarte podem acumular trabalho mais rápido que drenam

- `src/Code/Infrastructure/ObjectLifecycle.dm:84`, fila geral.
- Mesmo arquivo, `:137`, `DeletePendingObjectsLoop()`.
- `src/Code/Infrastructure/MobLifecycle.dm:64`, itens de mobs excluídos.
- `src/Code/Races/UltraInstinct.dm:261`, auras com dois loops por objeto.

O coletor geral inspeciona por padrão 25 entradas a cada 10 ticks (~25/s).
A fila de itens faz uma exclusão a cada 5 ticks, com pausa adicional entre
passagens (~2/s ou menos). Nenhuma das filas possui limite de entrada ou
controle adaptativo. Sob criação/descarte sustentados acima dessas taxas,
o backlog cresce. Alguns objetos enfileirados ainda executam loops `while(src)`
até a exclusão efetiva, ampliando o custo da fila.

Isso é uma hipótese de sobrecarga dependente da taxa de eventos, não prova de
vazamento permanente. Medir tamanho pendente e taxa de entrada/saída antes de
alterar o orçamento; aumentar o lote indiscriminadamente pode causar picos.

### 5. Médio — caches especializados sem teto de retenção

Além de `effect_cache`, há pools sem limite explícito em:

- `src/Code/VisualEffects/ExplosionEffects.dm:33` (`explosion_cache`).
- `src/Code/Transformations/Kaioken.dm:163` (`body_part_cache`).
- `src/Code/ProjectileSystem/Blasts.dm:1466` e `:1549` (crateras).
- `src/Code/UI/DamageIndicators.dm:60` (`damage_indicator_cache`).

Um cache estável no pico de concorrência não deve ser confundido com vazamento.
Entretanto, esses pools não devolvem o excesso após uma carga excepcional.
Alguns descartes também não impedem chamadas repetidas ou invalidam timers
antigos. Convém estabelecer teto, liberação idempotente e identidade por uso.

### 6. Médio — buscas aleatórias sem limite (gatilho depende do estado do mapa)

- `src/Code/WorldMechanics/BaseOrbs.dm:64`, `GetRandomOrbLoc()`: repete até
  encontrar área com `has_resources`; chamado por `GenerateBPOrbs()` na
  inicialização. Sem área válida, não há término normal nem pausa explícita.
- `src/Code/CoreFunctions/Map.dm:3060`, `DespawnRespawn()` de
  `Planet_Restore_Crystal`: repete até encontrar turf não denso.
- `src/Code/CoreFunctions/MonsterAIRevamp2019.dm:190`, `Find_Location()`:
  busca sem teto e ainda pode chamar a si própria após encontrar posição.

Para as duas últimas, a busca no código não encontrou chamadores externos
diretos ativos (a referência a `Find_Location()` é a própria recursão).
Portanto não devem ser apresentadas como causa comprovada do incidente.
Os checks do engine podem abortar uma execução excessiva; isso também seria
um runtime a procurar em `Errors.log`, não uma recuperação correta da lógica.

Correção proposta: orçamento de tentativas, saída explícita de falha e seleção
a partir de candidatos válidos quando possível.

### 7. Médio — ganho de atributos pode executar lotes grandes sem ceder tempo

- `src/Code/PlayerMechanics/Train.dm:495`, `Leech()`.
- `src/Code/Combat/Skills.dm:538`, chamada com 5.000 unidades.
- `src/Code/PlayerMechanics/Zenkai.dm:32`, quantidade multiplicada por parâmetros.

`Leech()` transforma a quantidade e processa uma iteração por unidade, sem
orçamento de trabalho nem pausa explícita. Há chamadas legítimas com milhares
de unidades. Isso pode explicar um pico associado a uma ação, mas não demonstra
acúmulo de memória. Medir custo e quantidade real; qualquer processamento em
lotes precisa preservar o cálculo e o estado dos personagens entre retomadas.

## Proteções existentes verificadas

O cache genérico de objetos já tem teto de 250 por tipo; projéteis têm teto de
500, corpos de 100 e indicadores de Sense de 500. O loop principal de ações
tem guarda contra duplicação. Movimento tem limite de passos de compensação;
o A* da biblioteca tem limite de expansões; o scanner planetário usa fila única
e cede tempo por orçamento de tick. Essas proteções reduzem riscos específicos,
mas não cobrem o cache separado de `/obj/Effect`.

`Start_core_loops()` também merece revisão caso seja reativada: o timer de feats
continua fora da área e não tem guarda de instância. Não foram encontrados
chamadores diretos externos dessa proc, portanto foi excluída das prioridades.

## Como relacionar os achados com produção

1. Registrar commit e build BYOND realmente implantados, horário do episódio,
   jogadores presentes, ação associada e uptime.
2. Capturar CPU do processo/container e RSS ao longo do tempo, junto de
   `world.cpu`, `world.tick_usage` e contagens de filas/caches. CPU de sistema
   e indicadores do engine não são métricas intercambiáveis.
3. No profiler de procs do BYOND, comparar um intervalo saudável com o episódio:
   `text_overlay`, sua atividade suspensa, visualização de recompensas,
   efeitos, `Leech`, IA, beams, salvamento e destrutores.
4. Para a fila geral, usar o tamanho pendente a partir de
   `garbage_collection_head`, não apenas `garbage_collect.len` (pode conter
   prefixo já processado). A contagem de efeitos em cache, isoladamente, não
   detecta o problema de tarefas demonstrado no achado 1.
5. Examinar `Errors.log`, `data/Logs` e `data/Bugs` do período por runtimes e
   loops abortados. Reproduzir carga em ambiente separado com o mesmo build.

A relação entre descarte e sobrevivência das tarefas foi conferida na
[referência oficial do BYOND — Del, del, sleep e spawn](https://www.byond.com/docs/ref/info.html).
O defeito do achado 1 está reproduzido; atribuir a ele os episódios de produção
ainda exige correlação com essas medidas.
