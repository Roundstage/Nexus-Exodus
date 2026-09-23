# Perfil Nexus-Exodus

Localize a raiz com DU.dme e AGENTS.md no workspace. Neste ambiente o projeto é
`C:/Users/allis/OneDrive/Documentos/GitHub/Nexus-Exodus`. Os caminhos abaixo são
relativos a essa raiz, não ao diretório de instalação da skill.

Leia `docs/Maps/WorldbuildingContract.md` para a memória consolidada e os cuidados
de escrita. Para Viltrum, leia também `docs/Maps/ViltrumEcumenopolisBrief.md`.
Esses documentos diferenciam decisões do usuário, evidência atual e propostas.

## Entradas e ferramentas existentes

| Necessidade | Fonte no projeto |
| --- | --- |
| Referências urbanas e proporções iniciais | docs/Maps/CityDesignReferences.md |
| Rio/rua/ponte e fontes de pesquisa | docs/Maps/RiverCityReferences.md |
| Referências visuais enviadas pelo usuário | docs/Maps/References/Conversation20260906/Index.md |
| Política atual de interiores vazios | docs/Maps/CityInteriorSimplification.md |
| Registro de prédios e destinos | docs/Maps/CityBuildings.json |
| Objetos/portas/áreas e validação de viagem | src/Code/MapCode/CityBuildings.dm |
| Turfs estruturais por tile e kit urbano terrestre | src/Code/MapCode/EarthNeighborhood.dm |
| Parser, coordenadas, chunks e proteção de saída manual | tools/MapAssembly/Dmm.cjs; PlanetChunks.cjs |
| Exemplo de composição, não gerador atual de Viltrum | tools/MapAssembly/AuthorEarthNeighborhood.cjs |
| Importação/exportação de prédios | tools/MapAssembly/ExportCityBuildings.py |
| Auditoria de arte aplicada | tools/MapAssembly/AuditEarthNeighborhoodAssets.py |
| Renderizador terrestre, a adaptar para uma nova cidade | tools/MapAssembly/RenderEarthNeighborhood.py |
| Controles de interiores/viagem | tools/MapAssembly/CityBuildingChecks.cjs; src/Code/Tests/CityBuildingSmoke.dm |

Inspecione o CLI e a revisão esperada de um script antes de executá-lo. Alguns
checks escrevem JSON em docs/Maps; renderizadores podem usar previews antigos.
Scripts Author/Recover/Rebuild de etapas anteriores podem restaurar prédios
rejeitados ou mobiliário já removido. Não execute uma cadeia histórica só porque
os nomes dos scripts parecem adequados.

Para checks sem escrita de interiores, use a função exportada:
`node -e "console.log(require('./tools/MapAssembly/CityBuildingChecks.cjs').checkInteriors())"`.
Para mapas atuais, escolha testes de geometria compatíveis com a revisão e
execute o smoke completo quando código/assets/mapas forem alterados. O contrato
comum lista os comandos e suas limitações.
