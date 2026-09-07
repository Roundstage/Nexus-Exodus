# Super Terra — continentes preservados e atlas adaptado

A decisão do usuário em 2026-09-06 foi preservar os continentes e adaptar o atlas.
A metrópole ocupa o oeste (B1/B2/C1/C2), próxima do spawn Human (95,362) e da
chegada natural (101,362), em Z21. C3 continua majoritariamente mar; não foi criada
uma ilha urbana para seguir a posição sugerida no roteiro.

## Conteúdo e geografia

Os 25 chunks têm 100x100 tiles e Z local 1; o resultado é 500x500 em Z21.
O conjunto contém 42 interiores públicos, 52 destinos, três áreas livres de
combate de 30x30, moradias com divisão interna, hospital, comércio, espaços cívicos,
transporte, oficinas, porto, fazendas e postos regionais. São instalações para
exploração/RP; não introduzem uma economia, cura ou crafting próprios.

| Faixa | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- |
| A | Costa oeste/farol | Fazendas e cabeceira oeste | Ilha ártica e posto | Cabeceira leste/cabana | Mar e costa nordeste |
| B | Chegada, transporte e cidade | Cidade, clínica, moradias e rio | Mar e ligação norte | Subúrbios e escola | Porto e armazéns |
| C | Bairro oeste e treino | Centro cívico, praça e oficinas | Mar, ponte e reserva insular | Parque, indústria e rio | Costa, resgate e vila |
| D | Costa sudoeste | Ligações ao continente sul | Reserva e costa sul | Selva e posto | Costa sudeste |
| E | Mar e costa sul | Vila do oásis e fazendas | Rio, oficinas e vila sul | Mar | Mar |

Os 20 spawns raciais mantêm coordenadas e propriedades originais. A chegada 21x21
permanece idêntica ao mapa protegido, sem tablado ou obstáculos. As cachoeiras
(139,350), (368,342) e (184,96), seus 21 tiles e todas as escadas de grama foram
preservados. Neve/gelo ficam na ilha norte; margens verdes do deserto permanecem.
As árvores existentes usam Celianna; não introduzir árvores Terraria.

Todos os 138.811 tiles de água do baseline continuam água, ponte com Water=TRUE
ou limite oceânico. Existem 3.710 tiles de ponte elevada, sem aterrar os mares.
Os 20 spawns e todos os destinos têm conexão cardinal com a cidade. Edifícios
têm entradas alternativas. O teste distingue divisas de terra natural de
travessias exclusivamente sobre o mar; não afirma duas pontes em cada divisa
oceânica. Uma faixa externa de oito tiles impede saída do mapa. SafeTeleport de
mobs redireciona destinos nessa faixa para a chegada normal.

## Fontes e comandos

Edite src/Maps/PlanetChunks/SuperEarth/SuperEarthA1.dmm até SuperEarthE5.dmm.
SuperEarthManifest.json define a grade, A ao norte e 1 a oeste.
Nunca edite o DMM montado sem recuperar essas alterações nos chunks.

```powershell
node tools/MapAssembly/AssemblePlanetMaps.cjs SuperEarth
node tools/MapAssembly/AssemblePlanetMaps.cjs SuperEarth --check
node tools/MapAssembly/TestPlanetChunks.cjs SuperEarth
node tools/MapAssembly/TestEarthLayout.cjs --regions
.\tools\MapAssembly\RenderPlanetAtlas.ps1 -Planet SuperEarth -PythonPath <python-with-Pillow>
.\tools\MapAssembly\TestPlanetParser.ps1 -Planet SuperEarth -Chunks A3,B2,E2
.\tools\Open-PlanetChunk.ps1 -Planet SuperEarth -Chunk B2 -PrepareOnly
```

GenerateSuperEarthMap.cjs delega ao montador seguro; --force é rejeitado.
Os geradores geográficos anteriores são históricos e recusam execução enquanto
existir o manifesto de chunks. Backups, paridade inicial e hashes ficam em
RebuildBaseline; os metadados atuais ficam em src/Maps/SuperEarthMetadata.json.

## Arte, runtime e verificação

EarthCity.dm define roofs sólidos/opacos, fachadas decorativas, pisos,
pontes, diretórios e móveis transparentes sobre pisos independentes.
ArtSource/Earth contém dois documentos Aseprite e seus manifests:
28 estados selecionados de arte existente e quatro materiais de rua originais.
Provenance.md registra fontes, normalização e comandos. Os arquivos legados
originais não foram alterados; não houve importação de ClassicBlunder.

SuperEarthWorldChecks.json registra conservação, conectividade, combate,
divisas e cobertura de colisão por terreno terrestre. EarthCitySmoke.dm cobre
pisos, roofs com voo, móveis, chegada, cachoeiras, pontes e oito pontos de limite.
Os testes de planeta continuam verificando descoberta, scanner, decolagem,
desativação/restauração e spawns. Compilação completa 0 erros/avisos; smoke
Versioned e Clean passaram.

SuperEarthOverview.png, SuperEarthChunkAtlas.png e SuperEarthChunks/*.png usam
sprites reais de primeiro frame. Vegetação legada, bordas automáticas, iluminação
e scanner final precisam de revisão em jogo. StrongDMM e gameplay interativo
continuam adiados por decisão do usuário. Consulte RebuildStatus.md para
limitações e a falha preexistente na auditoria estrita de referências.
