# Viltrum — capital e regiões em chunks editáveis

O usuário aprovou o estilo revisado em 2026-09-06. Os 25 chunks estão expandidos;
StrongDMM e revisão interativa seguem adiados. A superfície permanece 500x500
em Z20, spawn (250,250) e chegada (250,78), sem alterar a ordem dos mapas em DU.dme.

## Atlas e conteúdo

| Faixa | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- |
| A | Ilha/farol polar | Observatório polar | Cidadela | Cavernas e posto | Plataforma insular |
| B | Escarpa e abrigo | Residências e serviços | Palácio e administração | Ciência e academia | Reserva e aqueduto |
| C | Treinamento | Mercado e ágora | Fórum, arquivo e energia | Escola de guerra e arena | Geração e reatores |
| D | Badlands e estação | Estaleiros e hangares | Terminais espaciais | Fabricação e ruínas | Ruínas de pesquisa |
| E | Mar e limite | Vigia costeiro | Chegada preservada | Comunicações | Mar e limite |

São 42 interiores públicos e 60 destinos somando o slice original à expansão.
ViltrumCapital.json e ViltrumWilderness.json registram 38 edifícios/54 destinos;
ViltrumSlice.json registra os quatro interiores/seis pontos originais.
Espaços livres: treino 50x50, arena 48x48 com quatro saídas, ágora 29x29,
badlands 30x30 e fórum 38x30. As avenidas são largas e os interiores esparsos.
Móveis, clínica, comércio e indústria são fixtures para RP, sem adicionar
sistemas de cura, economia, crafting ou geração de energia.

As 40 divisas têm pelo menos duas faixas transitáveis de cinco tiles.
Cada entrada principal da expansão pode ser bloqueada individualmente sem
isolar o edifício. A chegada mantém os 441 tiles livres. Todos os 2.152 tiles
editados manualmente no DMM anterior foram recuperados exatamente nos chunks;
30 conflitos de piso em D4 foram resolvidos em favor do usuário.
ViltrumManualRecovery.json e RebuildBaseline/ManualOutputRecovery documentam isso.

## Arquitetura, arte e portas

As decisões persistentes estão em AGENTS.md: roofs são as paredes estruturais
sólidas e opacas no perímetro; walls são fachadas decorativas; pisos ocupam o
bloco inteiro; móveis são objetos com alpha real sobre qualquer piso.
Não cobrir os cômodos jogáveis com roofs.

A arte original usa pedra clara, teal e navy. ArtSource/Viltrum preserva os
documentos Aseprite, PNGs de origem, paleta, prompts e manifests de exportação.
O kit expandido acrescenta oito móveis de capital, 16 terrenos/pisos e cinco
estilos de portas (civic, palace, laboratory, hangar, force_field).
Há 25 painéis de porta em cinco grupos públicos, com estados closed, opening,
open e closing. A passagem aguarda a abertura; o fechamento adia enquanto houver
um mob no vão. As portas não esmagam ocupantes nem exigem senha.

ViltrumDoors.dm define as transições; ViltrumTechnology.dm fornece diretórios e
diagnóstico público do regulador. Não foram adicionadas luzes ativas ou loops
ociosos de decoração. A faixa externa de tempestade tem oito tiles, Enter sempre
bloqueado; roofs também bloqueiam o bypass global de voo.
resolvePlanetSurfaceArrival é chamado por SafeTeleport para mobs antes da
atualização de contexto e retorna a chegada normal quando o destino é um limite
de Viltrum ou Terra. Atribuições arbitrárias a loc não acionam esse mecanismo.

## Fontes e comandos

Edite src/Maps/PlanetChunks/Viltrum/ViltrumA1.dmm até ViltrumE5.dmm.
O manifesto define A-E de norte a sul e 1-5 de oeste a leste. Cada chunk usa Z1.
Para índices de linha r e coluna c começando em zero:
X=c*100+localX; Y=(4-r)*100+localY. O (1,1) local é sudoeste.
A1 (1,1) vira (1,401); E1 (1,1) vira (1,1).

```powershell
node tools/MapAssembly/AssemblePlanetMaps.cjs Viltrum
node tools/MapAssembly/AssemblePlanetMaps.cjs Viltrum --check
node tools/MapAssembly/TestPlanetChunks.cjs Viltrum
node tools/MapAssembly/TestViltrumSlice.cjs
node tools/MapAssembly/TestViltrumCapital.cjs --wilderness
.\tools\MapAssembly\TestPlanetParser.ps1 -Planet Viltrum -Chunks A1,C3,D3
.\tools\MapAssembly\RenderPlanetAtlas.ps1 -Planet Viltrum -PythonPath <python-with-Pillow>
.\tools\Open-PlanetChunk.ps1 -Planet Viltrum -Chunk C3 -PrepareOnly
```

GenerateViltrumMap.cjs delega ao montador; --force é rejeitado. Alteração manual
do output provoca recusa. Recupere-a nos chunks antes de montar; a opção explícita
--acknowledge-manual-output-edits-lost existe para descarte consciente.
Os scripts Author*, Revise*, Recover* e Place* são migrações históricas guardadas,
não geradores que devem ser repetidos sobre o estado atual.
ViltrumMetadata.json contém hashes das fontes/output e contagens.
A DME temporária contém apenas o chunk escolhido e não modifica DU.dme.

## Verificação e limites

Os testes cobrem parser, orientação, montagem determinística, preservação manual,
rotas, entradas alternativas, combate, divisas, roofs, alpha, portas e oito
posições de borda/canto com voo, knockback e SafeTeleport. A compilação completa
BYOND 516.1686 passou sem erros/avisos, com smoke Versioned e Clean.
Os oito erros Planet_X/Y/Z/Nav_Level reportados pelo usuário foram reproduzidos
e corrigidos; o parser headless de chunks resolve código e assets sem StrongDMM.

ViltrumMaterialProof.png e ViltrumCapitalMaterialProof.png mostram móveis sobre
três pisos. ViltrumOverview.png, ViltrumChunkAtlas.png e ViltrumChunks/*.png
mostram a montagem atual com sprites de primeiro frame.
Gameplay rápido, portas em todas as direções, transições de noite/dia e scanner
visual não foram certificados. A decoração é esparsa; variantes especializadas
de cantos, transições e props do roteiro ainda não estão todas implementadas.
O ícone espacial existente foi mantido. RebuildStatus.md contém evidências,
contagens, proveniência e a falha preexistente de referência do logo na UI.
