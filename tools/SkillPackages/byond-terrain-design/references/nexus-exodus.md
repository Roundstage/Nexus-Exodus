# Perfil Nexus-Exodus

Localize a raiz com DU.dme e AGENTS.md. O caminho conhecido neste ambiente é
`C:/Users/allis/OneDrive/Documentos/GitHub/Nexus-Exodus`. Resolva os caminhos abaixo
a partir dessa raiz. Leia `docs/Maps/WorldbuildingContract.md` antes de escrever
e `docs/Maps/ViltrumEcumenopolisBrief.md` quando o planeta for Viltrum.

## Ferramentas a reutilizar

| Necessidade | Fonte no projeto |
| --- | --- |
| Parser/canonicalização/serialização DMM | tools/MapAssembly/Dmm.cjs |
| Manifests, eixos, hashes, montagem protegida | tools/MapAssembly/PlanetChunks.cjs |
| Checagem sem escrita da montagem | tools/MapAssembly/AssemblePlanetMaps.cjs PLANETA --check |
| Testes de chunks/parser/guarda de escrita | tools/MapAssembly/TestPlanetChunks.cjs |
| Água como união e terreno de base | tools/MapAssembly/EarthNaturalHydrology.cjs |
| Máscaras de vizinhos e pintura de margem | tools/MapAssembly/EarthRiverTerrain.cjs |
| Exemplo de maciço/dunas/caverna | tools/MapAssembly/AuthorEarthNaturalLandmarks.cjs |
| Materiais/fontes e exportação DMI | tools/MapAssembly/CreateEarthNaturalTiles.lua; ExportEarthNaturalTiles.py |
| Auditoria de pixels/estados/fontes | tools/MapAssembly/AuditEarthNaturalAssets.py |
| Rotas/colisão/portais em runtime | src/Code/Tests/EarthNaturalLandmarksSmoke.dm |
| Regressão de terreno e overlays após visitar zonas | src/Code/Tests/EarthTerrainGenerationSmoke.dm |
| Fontes de pesquisa de formas naturais | docs/Maps/EarthNaturalLandmarksReferences.md |

Assemble --check faz validação estática e respeita o bloqueio de edições manuais;
não prova que os arquivos atuais já correspondem à montagem proposta. Compare
também os hashes de saída e os dados reais. Arquivos de metadata são registros,
não evidência de que um editor não alterou a saída desde a última geração.

Author/Recover de etapas antigas não são comandos genéricos de reparo. Leia suas
pré-condições e snapshots fixos antes de adaptar. No último contexto consolidado,
há mapas salvos manualmente após as gerações; obtenha hashes novamente na execução.
Não replique layouts/hashes da Terra na ecumenópolis de Viltrum.
