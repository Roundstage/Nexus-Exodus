# Contrato de criação de mundo — Nexus-Exodus

Consolidado em 2026-09-14 a partir das instruções do usuário nesta conversa,
AGENTS.md e dos arquivos atuais. É a memória comum das skills
`byond-city-design` e `byond-terrain-design`. Instruções novas do usuário prevalecem;
datas e contagens abaixo são evidência histórica, não valores a restaurar.

## Direção vigente e diferenças entre planetas

| Tema | Decisão consolidada |
| --- | --- |
| Viltrum | A próxima direção é uma **ecumenópolis moderna**, com continuidade urbana e bairros reconhecíveis. Leia [o brief atual](ViltrumEcumenopolisBrief.md). |
| Terra | Preservar a cidade aprovada no continente oeste. Deserto e continente leste são wilderness; não criar estradas sem destino, cidades adicionais ou rodovias entre continentes. |
| Residências | Casas reconhecíveis colocadas lado a lado, dentro de quadras e alinhadas às calçadas. Torres finas isoladas e grandes lotes vazios foram rejeitados. |
| Edifícios especiais | Hospitais e serviços importantes, além de algumas residências, têm entradas utilizáveis para interiores separados. |
| Roofs | São a estrutura sólida, opaca e com colisão. O turf arquitetônico ocupa o bloco completo de 32×32. |
| Walls | São faces decorativas de fachada; não substituem a estrutura sólida. |
| Interiores atuais | Desde a revisão de 2026-09-08, os 66 interiores de prédios ficam vazios, cada um com um único portal de retorno. A caverna separada não pertence a essa simplificação. Não remobiliar ao executar um gerador antigo. |
| Objetos | Mobiliário/vegetação/props reutilizáveis têm alfa verdadeiro, sem fundo de chão embutido. Colisão é definida separadamente. |
| Relevo | Montanhas, dunas e cachoeiras são turfs exploráveis, com terraços e rampas naturais. Não usar grandes objetos de paisagem nem Stairs_Grass/EarthRiverSteps. |
| Revisão | Usar scripts, DMI e smoke headless. StrongDMM e interfaces Dream Maker/Dream Seeker não são abertos para inspeção; a verificação visual/interativa BYOND fica com o usuário. |

O roteiro `docs/ImprovementPrompts/ViltrumEarthMapRebuild.md` explica a origem da
pipeline, mas foi superado em vários pontos: ordem Earth-first autorizada depois,
casas contíguas, interiores separados, remoção de estradas remotas, rejeição de
stairs, interiores vazios e agora a ecumenópolis. Não execute suas fases antigas
como se fossem a direção atual. Relatórios com 88 casas, 42 salas, escadas
preservadas ou mobiliário de interiores também podem representar etapas antigas.

## Lições observadas → decisões de implementação

| Falha observada | Como impedir a repetição |
| --- | --- |
| Casa invade rua, rua invade casa | Separar reserva do lote, extensão da arte, deslocamento do sprite, colisão e aproximação da porta; testar todas, não apenas a âncora. |
| Casas parecem objetos perdidos no mapa | Definir quadras, frentes contínuas e vizinhos antes de variar sprites; usar praças grandes apenas onde têm função. |
| Rio atravessa a cidade como recorte | Reservar a bacia e margens primeiro, depois ruas e lotes. Preservar a passagem do canal nas pontes. |
| Grama corta rio já desenhado | Construir a união de todos os trechos de água antes de pintar qualquer banco/grama de margem. |
| Ponte de madeira sem sentido na nascente | Desenhar travessia de margem a margem, aproximações, encontros, tabuleiro com material da via, bordas e continuidade hidráulica. |
| Estradas chegam a lugar nenhum | Dar função aos extremos e não conectar continentes para cumprir um grafo artificial. |
| Montanha é só uma imagem | Representar massa, barreiras, terraços, rampas e caverna com turfs; provar caminhos reais. |
| Portas levam a Viltrum em vez do interior | Preservar ordem de mapas e validar área, planeta e Z do destino; testar ida e volta. |
| Wall7 aparece depois do load | Gerador de zonas substituía água por cliff e inundava o próximo tile; respeitar políticas de área em origem e destinos. |
| Edges/waves reaparecem sobre arte pronta | Bloquear as rotinas que adicionam overlays, inclusive chamadas diretas; não apagar overlays legítimos como solução. |
| Atlas passa, jogo fica ruim | Renderizar DMI final a 1x com jogador e exercitar geração tardia em runtime; aprovação visual continua sendo do usuário. |
| Nova geração apaga correções manuais | Comparar hashes e semântica entre saída/chunks; recuperar edições antes de montar. Nunca usar um baseline antigo como restauração implícita. |

## Estado técnico e escrita de mapas

**Atualização após implementação, 2026-09-14:** Viltrum foi reconstruída; leia
[o relatório aplicado](ViltrumEcumenopolis.md). A comparação inicial confirmou
zero diferenças semânticas entre a saída de Viltrum e seus chunks. O autor
preservou os insumos antes de normalizar a serialização. As três políticas de
geração automática agora também estão desativadas em Viltrum. A tabela de hashes
e observação sobre Viltrum sem essas políticas abaixo são o diagnóstico histórico
anterior à implementação, não o estado a restaurar.

Superfícies atuais: 500×500, divididas em 25 chunks de 100×100, cada arquivo com
Z local 1. A é a faixa norte; E, a sul. Coordenadas BYOND crescem para norte,
enquanto as linhas do array/arquivo são serializadas de norte para sul.

`global_x = (coluna-1)*100 + local_x`

`global_y = (4-indice_da_linha)*100 + local_y`, com A=0 até E=4.

Arquivos de manifest:
`src/Maps/PlanetChunks/PLANETA/PLANETAManifest.json`.
Fonte de parser/serialização: `tools/MapAssembly/Dmm.cjs`.
Fonte de montagem/guarda: `tools/MapAssembly/PlanetChunks.cjs`.

Capture cópias/hashes dos insumos, gere em staging e valide antes de aplicar.
Confira novamente os hashes antes da escrita final para detectar edição concorrente.
A opção de descarte de edições manuais não é um atalho de workflow.
Um parser estrito pode rejeitar stacks com múltiplos turfs que BYOND aceita;
preserve o original e investigue a semântica antes de normalizar.

### Checagem somente leitura em 2026-09-14

| Mapa | SHA256 da saída atual | Igual ao metadata? |
| --- | --- | --- |
| Viltrum | 46a615b10d33b5763826c8198033f51ff5eadab1c87aee79d75a0541fe3610a3 | Não |
| SuperEarth | 9f2197326e3a4445bbe71c635830b0c27a953b29df67bf79831016d26c6aafcc | Não |

Antes de construir Viltrum, compare essas saídas com os chunks e recupere as
alterações relevantes. Recalcule tudo na execução: esses hashes não congelam o
trabalho futuro. Nenhum mapa foi regenerado durante a criação das skills.

`CityBuildingChecks.checkInteriors()` passou em leitura: 66 interiores vazios,
22.996 tiles de piso conectados e 66 portais com retorno exato. Uma nova revisão
deve derivar contagens do registro atual, não hardcode esses totais.

## Integração que não pode ser quebrada

Mapas entram em DU.dme nesta ordem antes do bloco gerado de includes:

| Arquivo | Z global |
| --- | --- |
| Map2018.dmm | 1–15 |
| Space2018.dmm | 16–19 |
| Viltrum.dmm | 20 |
| SuperEarth.dmm | 21 |
| CityInteriors.dmm | 22 |

Não escreva o token reservado de início do bloco de includes em comentários
explicativos dentro do DME. Uma menção casual anterior fez o editor apagar o
preâmbulo protegido. Use o teste TestRuntimeMapOrder após alterações de ambiente.
Novos arquivos DM continuam dentro do bloco gerado, conforme AGENTS.md.

Leia constantes/spawns/registro atuais em vez de copiar coordenadas de relatórios.
Preserve chegada, espaço seguro, planetas/áreas, spawn racial, liftoff, respawn,
planeta desativado/restaurado e contexto de scanner/controle planetário.
`CityBuildingDoor.travel/isValidDestination` já protege área/planeta/Z, KO/KB,
proximidade e obstrução. Reutilize o mecanismo; não use target_z isoladamente.

`area/SuperEarth` desativa auto_cliffs, auto_edges e auto_waves. Em 2026-09-14,
`area/Viltrum` ainda não declara essas proteções. Na implementação da ecumenópolis,
estenda deliberadamente a política para o terreno autorado de Viltrum e inclua
testes: GenerateCliffs, GenerateEdges e GenerateShoreWaves são chamados pelo
GenerateZone quando jogadores visitam regiões. Sombras e animações legítimas
precisam continuar preservadas.

## Evidência e comandos

Inspecione os argumentos e efeitos de escrita de cada script antes de rodá-lo.
Não execute Author/Recover de uma etapa histórica com --apply indiscriminadamente.

- `node tools/MapAssembly/AssemblePlanetMaps.cjs Viltrum --check` valida uma
  montagem proposta sem escrever. O guard pode detectar edições manuais; isso
  exige comparação/recuperação, não descarte. Use SuperEarth quando pertinente.
- `node tools/MapAssembly/TestPlanetChunks.cjs Viltrum` verifica a pipeline de
  chunks. Não certifica estética nem uma saída manual posterior.
- `node tools/MapAssembly/TestRuntimeMapOrder.cjs` verifica ordem e markers do DME.
- A função exportada `CityBuildingChecks.checkInteriors()` permite conferir
  interiores sem atualizar o JSON de relatório; a execução direta do arquivo
  escreve esse relatório.
- Auditorias `Audit*Assets.py` verificam assets específicos da revisão. Consulte
  os manifests e CLI atuais; não rotule uma auditoria Earth como prova de Viltrum.
- `tools/Invoke-ByondSmoke.ps1` compila e testa em cópia temporária, com dados
  versionados e limpos, zero erros/warnings e sem runtimes. Acrescente testes de
  zona, porta e circulação quando esses comportamentos mudarem.
- `tools/Test-AssetReferences.ps1 -Strict` e `tools/Test-NamingConventions.ps1
  -PathStrict` verificam referências e paths. Distingua regressão nova de problema
  preexistente; não declare um comando aprovado se ele falhou.

Criar/editar apenas skills e documentação não exige recompilar o jogo. Alterações
reais de assets/mapas/DM exigem verificações pertinentes e o baseline completo.
Smoke temporário não atualiza automaticamente o DU.dmb local nem reinicia o mundo
do usuário. Informe o que foi compilado e deixe a revisão interativa com ele.

## Fontes e referências preservadas

- [Índice das imagens enviadas](References/Conversation20260906/Index.md).
- [Composição urbana](CityDesignReferences.md), [rios e pontes](RiverCityReferences.md),
  [formas naturais](EarthNaturalLandmarksReferences.md).
- [Interiores vazios](CityInteriorSimplification.md), [teletransportes](InteriorTeleportFix.md),
  [geração de margens](EarthRuntimeCliffFix.md).

São referências de forma/composição, não pacotes de arte aprovados para importar.
Mantenha crédito/proveniência e confirme a licença ou autorização do material que
for efetivamente incorporado. Não trate autorização registrada de uma coleção
específica como autorização de todas as imagens mencionadas.
