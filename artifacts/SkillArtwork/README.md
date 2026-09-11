# Nexus Exodus — artes das skills

Conjunto de 207 ilustrações de interface, seguindo a amostra aprovada pelo usuário em 11/09/2026. Cada habilidade tem uma composição própria baseada na descrição do jogo. As oito artes da amostra foram preservadas.

- `index.html`: galeria com busca, categorias, originais e prévias de 40/32 pixels.
- `SkillArtworkOverview.png` e `Review/`: visão geral e pranchas para revisão visual.
- `HotbarPreview.png`: prévia das artes no componente real da barra de atalhos, renderizada com dados de demonstração.
- `Originals/`: PNGs originais, preservados sem alteração.
- `Manifest.json`: tipos DM, descrições, motivos visuais, prompts completos e caminhos.
- `Records/`: dimensões e hashes dos originais e prompts de cada arte.
- `Catalog.json`: inventário extraído das definições compiladas e árvores de progressão.
- `Audit.json`: resultado da última auditoria de cobertura e integridade.

As imagens foram geradas individualmente com o ImageGen integrado. O processamento posterior apenas reduz cada original para o PNG de 128x128 em `src/Icons/UI/SkillArtwork/`. O jogo usa essas artes na interface; projéteis, animações, personagens e objetos do mundo preservam seus sprites.

A cobertura inclui técnicas de combate, buffs, habilidades raciais, magias, técnicas de Milestones, controles de combate e os comandos de transformação. Atalhos direcionais da mesma habilidade compartilham sua arte. Tipos abstratos, ferramentas de teste, itens e comandos de interface/social não são habilidades distintas; as exclusões e seus motivos estão no manifesto.

## Manutenção

Os scripts usam Node.js; exportação e validação das imagens também precisam de `sharp`, e a renderização da galeria precisa de `playwright` e Chrome. Configure `NODE_PATH` para as dependências disponíveis no ambiente.

1. `node tools/SkillArtwork/ExportCatalog.cjs`: atualiza o inventário em uma cópia temporária do ambiente BYOND 516.1686.
2. `node tools/SkillArtwork/BuildManifest.cjs`: associa descrições e `VisualBriefs.json` aos tipos compilados.
3. Gere uma imagem por prompt com ImageGen. Use `node tools/SkillArtwork/RecordGenerated.cjs ID CAMINHO_PNG` para preservar o original e preparar o asset. O script recusa substituir um original diferente.
4. `node tools/SkillArtwork/BuildRuntimeCatalog.cjs`: gera o catálogo compilado e sua revisão de cache; falha se faltar uma arte.
5. `node tools/SkillArtwork/AuditArtwork.cjs` e `node tools/SkillArtwork/BuildRuntimeCatalog.cjs --check`: validam cobertura, integridade e referências.
6. `node tools/SkillArtwork/BuildPreview.cjs --render`: reconstrói a galeria e as pranchas.
7. Execute a auditoria de assets e o smoke BYOND do repositório.

`node tools/SkillArtwork/BuildHotbarPreview.cjs` verifica o carregamento e a redução suave das artes usando o CSS e o JavaScript reais da barra, e atualiza a prévia.

`--partial` existe para inspeções durante a geração. A entrega final deve passar sem essa opção. Os artefatos de revisão ficam fora dos includes do jogo; apenas os PNGs reduzidos entram no recurso compilado.
