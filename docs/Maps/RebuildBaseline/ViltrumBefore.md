# Viltrum — mapa inicial

`src/Maps/Viltrum.dmm`: 500 x 500 tiles, um Z local (1), 250.000 turfs.
Mapa autoral inicial, com assets existentes do Nexus. A planta em
`ViltrumOverview.svg` representa a distribuicao dos tiles; nao os sprites reais.

Abra o ambiente `DU.dme` no editor e depois abra `src/Maps/Viltrum.dmm`.
Alternativamente, `ViltrumEditor.dme` e um ambiente derivado de `DU.dme`
que inclui somente este mapa, para edicao mais leve. Regenere-o se os includes
do projeto mudarem. Ele serve para edicao/compilacao, nao para iniciar o servidor:
o codigo de jogo ainda espera os Z-levels do mundo antigo.
O arquivo agora esta incluido em `DU.dme` depois dos dois mapas antigos:
seu Z local 1 corresponde ao Z global 20 (`Z_LEVEL_VILTRUM`). Terra e Espaco
continuam nos Z 1 e 16. O ambiente de edicao isolado continua no Z local 1.

| Local | Coordenadas X,Y |
| --- | --- |
| Praca imperial | 250,250 |
| Palacio | 250,350 |
| Arena | 112,250 |
| Academia militar | 391,250 |
| Espacoporto | 250,78 |
| Ruinas | 391,145 |
| Posto norte | 365,370 |

Ha costa nas laterais, planicies aridas, crateras, terreno nevado ao norte,
avenidas largas e edificios com entradas abertas. Os interiores ocupam o
mesmo Z. As plataformas do espacoporto sao cenario, sem teleporte ou naves.

Usa `/area/Viltrum`, com recursos e ciclo dia/noite. O spawn `Viltrumite`
em (250,250,20) atende Viltrumite e Half-Viltrumite, independentemente de Saiyan.
Vinculos de respawn ja escolhidos pelo jogador e o modo Earth Only continuam
prioritarios. Quando Viltrum esta desativado, o spawn racial usa os spawns
Human da Terra disponiveis; nunca usa Saiyan como alternativa.

O planeta e criado uma unica vez no espaco, perto de (350,350,16), em um
tile livre. Usa temporariamente o sprite Vegeta tingido e se move como Braal.
Colidir com ele leva ao espacoporto (250,78,20), com a dispersao padrao de
10 tiles. A decolagem retorna ao planeta no espaco. O scanner inclui Viltrum.
Admin -> Disable planet -> Disable/Enable controla sua presenca e usa a
lista persistente `disabled_planets` ja salva pelo jogo. Desativar nao apaga
o mapa nem evacua instantaneamente jogadores: aplica as regras existentes
para planetas desativados. Gravidade permanece padrao e destruicao planetaria
nao esta habilitada para Viltrum.

Geracao reproduzivel: `node tools/GenerateViltrumMap.cjs`.
O gerador recusa sobrescrever um mapa existente. `--force` descarta edicoes
manuais e recria o mapa original. O gerador verifica dimensoes, chaves e
conexao a pe entre os sete pontos principais; nao simula regras de movimento
do jogo. Revise visualmente no editor antes de usar em producao.
