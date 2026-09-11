# Plano: Classic completo e utilizável em combate

Data: 2026-09-07. Estado: implementação realizada; validações e limites registrados em [ClassicHudTesting.md](ClassicHudTesting.md). A proposta aprovada abaixo é mantida como referência dos requisitos.

## Objetivo e correção de escopo

O Classic precisa permitir jogar com as mesmas funções disponíveis em Side + Tabs, acompanhar o inimigo em tempo real, ler o chat e identificar as próprias técnicas e seus cooldowns durante a luta. A economia de espaço deve ser avaliada com essas informações abertas simultaneamente.

O experimento de substituir globalmente as tabs por painéis destacáveis foi retirado, conforme solicitado. Esta proposta usa os acessos da HUD existente e define comportamentos específicos para cada necessidade. A estrutura e a arte finais serão validadas com uma cena de combate antes de outra implementação ampla.

## Diagnóstico confirmado no código e nas imagens

- `src/Code/CoreFunctions/StatpanelTabs.dm`: a atualização suplementar de `mob/Stat()` depende do modo `side_tabs`. Ocultar a área nativa remove o acesso visual aos verbos e às informações que ainda dependem dela.
- `src/Code/UI/ActionHud.dm`: Inventário, Skills, Sense e World compartilham `client.nexus_player_menu`. Abrir outra seção substitui o menu anterior; clicar novamente na seção atual fecha a janela. Sense e seus detalhes, portanto, não são um monitor independente de combate.
- `Stat_Sense_Tab()` contém informações do alvo, inclusive build, condicionadas ao Sense, scanner, raça e configurações do jogo. As telas novas têm uma implementação separada e precisam ser comparadas campo a campo com essa origem.
- `src/Code/UI/HudLibrary.dm`: no Classic, o chat usa objetos da HUD com `maptext`. `getVisibleMessageCount()` estima a quantidade de mensagens pela altura, sem medir o texto após a quebra de linhas. Cabeçalho, canais e rodapé consomem 68 unidades da altura lógica; o redimensionamento ocorre por incrementos em botões. Alterar apenas o CSS do chat lateral não corrige esse caminho.
- `src/Code/UI/Hotkeys.dm` e `HotkeyEditor.dm`: existem vínculos de teclas, persistência e execução compartilhada por `executeNexusHotkeyAction()`. Essa base pode alimentar uma barra visível. Os cooldowns das técnicas usam campos e relógios diferentes, incluindo `world.time` e `world.realtime`; a barra precisa consultar o estado correto de cada técnica.

## Comportamento proposto

### 1. Acesso completo pela HUD

O botão Menu passa a oferecer uma lista compacta e pesquisável de funções, com os nomes que os jogadores já conhecem. Serve também de acesso às categorias ainda sem uma tela própria. As funções mais usadas continuam nos ícones existentes.

| Conteúdo atual | Acesso proposto no Classic | Requisito de cobertura |
| --- | --- | --- |
| Other e demais verbos visíveis | Menu → Ações, agrupadas por categoria | Mesmos comandos e disponibilidade do personagem no contexto atual. |
| Playtest | Menu → Playtest | Disponível no ambiente e para o personagem em que os verbos atuais são permitidos; não presumir que seja exclusivo de admins. |
| Sagas | Menu → Sagas | Informações, participantes, prazos e ações atualmente acessíveis. |
| Factions / leagues | Menu → Factions | Lista de facções, membros, cargos, territórios e ações dos objetos de facção. |
| Stats | Character → Stats | Conferir também os estados dinâmicos da tab Stats, além da ficha atual. |
| Inventory / Items | Ícone Inventário | Recursos, itens, uso, exame e demais ações atualmente permitidas; conferir os menus de contexto. |
| Skills | Ícone Skills | Biblioteca completa para consultar, organizar e colocar técnicas na barra. |
| Sense / Scan / informações do alvo | Ícone Sense e seleção de alvo | Monitor persistente, descrito abaixo. |
| Science / Build | Ícone Build e acesso complementar no Menu | Conferir tecnologia, recursos, custos e ações com as telas existentes. |
| Modules, Souls, Smell, Radar, Nav, Ship, Looting | Menu → categoria contextual | Manter acesso quando as respectivas condições de personagem, equipamento, nave ou saque existirem. |
| World, Who, Admin, Inspect | Acesso administrativo existente, com entradas complementares | Dados e ações conforme o nível de acesso atual. |

Essa é a matriz inicial. Antes de considerar a cobertura concluída, comparar as categorias, os dados e as ações visíveis em Side + Tabs com o mesmo personagem no Classic, incluindo entradas dinâmicas e verbos de objetos. Uma categoria sem interface específica deve continuar acessível pela lista complementar.

Abrir ou executar uma entrada usa a disponibilidade atual do jogo. Preferências que escondem tabs nativas não devem ser tratadas como permissão para apagar funções da HUD.

### 2. Sense e alvo persistentes

O ícone Sense abre uma lista compacta de assinaturas próximas. Selecionar alguém atualiza um quadro pequeno de alvo, com nome, poder relativo, vida, energia e build quando esses dados forem detectáveis. A build usa linhas ou duas colunas curtas; não exige abrir uma ficha grande nem manter o mouse sobre o alvo.

Lista e detalhes podem permanecer visíveis ao mesmo tempo. Abrir Inventário, Skills ou o Menu não fecha nem substitui o monitor. O jogador pode mover, recolher ou fechar explicitamente esses elementos; tamanho, posição e preferência de visibilidade são lembrados. Abrir Sense novamente traz o monitor à frente.

A atualização acompanha o alvo durante a luta e preserva a identidade selecionada quando a lista muda de ordem. Ao perder a capacidade de detectar o alvo, os valores deixam de ser apresentados como atuais e o painel indica a perda de sinal conforme as regras existentes.

Reaproveitar as regras de Sense e scanner, incluindo God Ki, informações vagas e restrição da build de Androids. Separar a consulta dos dados da renderização nativa; não duplicar as regras nem executar efeitos de gameplay em um ciclo de desenho da HUD.

### 3. Chat que aproveita o espaço disponível

- Arrastar pelas bordas ou pelo canto redimensiona continuamente. Arrastar o cabeçalho move o chat. As posições ficam dentro da janela ao mudar a resolução.
- Canais ocupam uma faixa compacta. Controles secundários ficam em um menu; os botões de aumentar/diminuir deixam de consumir espaço permanente.
- O texto se reorganiza conforme a largura, com fonte legível, entrelinha e espaçamento entre mensagens ajustados. Molduras e ícones podem continuar em pixel art sem impor uma fonte larga ao corpo do chat.
- O histórico rola por sua altura real. Mensagens longas continuam inteiramente acessíveis; palavras ou links muito longos não vazam da área. Quebrar linhas é esperado: perder legibilidade ou conteúdo não é.
- A roda do mouse percorre o histórico. Mensagens novas não interrompem a leitura de mensagens antigas; um indicador permite voltar às recentes.
- Salvar tamanho e posição, com opção de restaurar a disposição padrão. A entrada de texto não dispara skills enquanto o jogador escreve.

Como meta inicial de protótipo, tentar mostrar pelo menos 8 linhas curtas legíveis no espaço aproximado do segundo screenshot, sem contar os controles. Medir linhas renderizadas, e não prometer uma quantidade fixa de mensagens: mensagens de RP podem ocupar muitas linhas.

A primeira prova técnica deve confirmar redimensionamento, rolagem, seleção de texto e foco no cliente BYOND 516.1686. A escolha do componente de renderização depende desse resultado; um exemplo funcionando só no navegador externo não valida o chat do jogo.

### 4. Barra de skills durante o combate

Começar com uma fileira compacta de 10–12 slots configuráveis, perto da borda inferior. Uma segunda fileira pode ser habilitada para personagens que precisem dela. A quantidade final depende da validação na menor resolução de uso.

Cada slot mostra ícone identificável, tecla vinculada e estado da técnica. Em cooldown, mostra escurecimento progressivo e tempo restante. Técnicas ativas, indisponíveis ou sem recursos precisam de estados distintos, sem depender exclusivamente de cor. Nome e descrição completa aparecem ao consultar o slot.

O jogador organiza a barra a partir de Skills, com arraste e uma alternativa por clique. As teclas atuais são preservadas; mover um slot não troca uma tecla silenciosamente. Clicar ou usar o atalho passa pelo mesmo executor existente. A biblioteca continua acessível para todas as técnicas, inclusive as que não couberem na barra.

Criar uma consulta de estado que normalize os cooldowns reais das técnicas exibidas. A contagem começa quando a técnica efetivamente entra em recarga; um clique recusado não inventa nem reinicia um timer. Remover ou perder uma skill invalida o slot de forma explícita. Persistir a disposição por personagem e verificar troca de personagem e reconexão.

## Disposição inicial para validar

Usar a própria cena enviada pelo usuário como referência de densidade: atalhos existentes no alto; Sense e quadro de alvo próximos a uma borda; chat em um canto inferior; barra de skills na borda inferior, acomodada junto ao painel de status do jogador. Esses elementos precisam coexistir sem cobrir o personagem e a região central de combate.

Antes de definir medidas finais, comparar 1920×1080 com uma janela menor, inicialmente 1366×768, e testar a escala efetiva do cliente. Reduzir molduras e controles antes de reduzir fontes. Transparência ajuda a ver o cenário, mas não recupera uma área encoberta por texto e botões.

## Ordem de execução

1. **Cobertura funcional:** concluir o inventário das tabs e garantir uma entrada acessível para cada função no Classic.
2. **Uma cena de combate completa:** prototipar Sense, alvo com build, chat com mensagens reais e barra com estados de skill, todos abertos. Validar densidade e interação antes de produzir novos ícones.
3. **Monitor e chat no cliente:** implementar persistência, atualização do alvo, arraste, redimensionamento, rolagem e foco. Testar a cena real no BYOND.
4. **Barra conectada ao combate:** reaproveitar bindings e executar as skills pelo caminho atual; cobrir os diferentes tipos de cooldown antes de marcar a barra como pronta.
5. **Validação integrada:** comparar cobertura com Side + Tabs, testar resoluções, reconexão e combate. Só então finalizar a arte dos ícones e os ajustes visuais.

## Critérios de aceite

- Com o mesmo personagem e contexto, trocar Side + Tabs por Classic mantém uma forma acessível de usar todas as funções e consultar os dados disponíveis anteriormente.
- Other, Playtest, Sagas e Factions têm entradas testadas; uma categoria condicional não desaparece por falta de implementação.
- Durante uma luta, o jogador acompanha a build detectável, vida e energia do alvo sem abrir uma janela grande. Abrir e fechar Inventário não interrompe essa observação.
- Atualizar a lista, mudar de alvo e perder detecção não deixam informações antigas atribuídas ao inimigo errado.
- O chat do segundo screenshot melhora em linhas úteis legíveis; mensagens curtas, longas, de RP e com palavras extensas podem ser lidas e roladas em qualquer tamanho suportado.
- Redimensionar usa arraste; o chat mantém a posição de leitura ao receber mensagens e não interfere nos atalhos durante a digitação.
- Os slots mostram as skills configuradas e seus cooldowns reais; clique e teclado produzem o mesmo comportamento. Testar técnica instantânea, recarga longa, toggle, execução recusada e remoção da skill.
- Layout, escala e posições continuam utilizáveis após trocar a resolução, reconectar e trocar de personagem.
- Executar a baseline de compilação e inicialização e os testes relevantes de gameplay; registrar capturas no cliente, com todos os elementos de combate abertos. Um mockup isolado não encerra a validação.


## Latest customization direction — 2026-09-07

The fixed 12/24/36-slot design was superseded by the user’s explicit requirement for no maximum bar count or slot count per bar. Hotbars now use independent dynamic browser controls and persistent slot IDs, with per-bar columns, icon size, lock, visibility and placement. The editor creates/deletes bars, adds/removes slots, and paginates 12 at a time without limiting capacity. See ClassicHudTesting.md for the implemented behavior and verification limits.
