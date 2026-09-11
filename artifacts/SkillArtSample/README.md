# Amostra de artes de skills

Oito ilustrações originais usadas para aprovar a identidade visual das habilidades de Nexus Exodus. A amostra foi preservada aqui; suas artes agora integram o [conjunto completo de 207 habilidades](../SkillArtwork/README.md), já vinculado à interface do jogo.

- `index.html`: galeria com os originais, slots de 40 px com o estilo da hotbar atual e uma faixa de ícones de 32 px. Abrir com zoom do navegador em 100% para avaliar esses tamanhos.
- `SkillArtSample.png`: captura da galeria.
- Os oito arquivos PNG individuais são os originais gerados, sem recorte ou alteração.
- `Prompts.json`: descrições de origem, tipos DM, arquivos de referência e prompts completos.

Produção: ferramenta integrada `image_gen`, uma geração por habilidade. Direção visual: ícones pintados de RPG, fundo escuro, formas grandes e cores de acento, sem letras ou molduras desenhadas na arte.

As cores são propostas desta amostra, não uma classificação de gameplay já implementada. As duas técnicas de energia foram incluídas para avaliar a distinção entre habilidades da mesma família: espiral larga em Double Sunday e lança fina perfurante em Tyrant Lancer.

A prévia usa o desenho de bordas e sobreposição de tecla de `src/Code/UI/Browser/ClassicHud.css`; não representa uma captura do cliente BYOND. A avaliação no cliente deve ocorrer na etapa de integração.

`RenderPreview.cjs` captura a galeria com Playwright e Chrome em modo headless, conferindo imagens, dimensões dos slots e ausência de overflow. Requer Playwright disponível no caminho de módulos do Node. É possível selecionar outro canal Chromium com `SKILL_ART_BROWSER_CHANNEL`.
