---
name: byond-terrain-design
description: Cria e corrige terreno explorável em BYOND/DMM, com rios contínuos, margens, costas, montanhas, dunas, cachoeiras, cavernas, biomas e interfaces com pontes/cidades. Use para geração de tiles, relevo e hidrologia; não para edifícios isolados ou engenharia real.
---

# Terrenos BYOND

Crie formas naturais que o jogador possa percorrer e reconhecer. Hidrologia,
relevo, colisão e transições visuais devem descrever o mesmo lugar.

Em Nexus-Exodus, leia [o perfil do projeto](references/nexus-exodus.md) antes de
alterar mapas. Para compor formas, água e travessias, leia
[terreno e hidrologia](references/landforms.md). Para montagem e evidências, leia
[pipeline e verificações](references/validation.md).

## Fluxo de trabalho

1. **Recupere o estado real.** Compare saídas DMM, metadados e chunks; capture
   alterações manuais, spawns, chegadas, regiões aprovadas e landmarks existentes.
   Não interprete diferença de hash como autorização para descartar a saída.
2. **Desenhe relações físicas e de jogo.** Organize costa, bacias, nascentes,
   canais, encostas, passes, cavernas e destinos. Use referências primárias
   quando estiver pesquisando uma forma específica. Registre o que a referência
   ensina e como foi simplificado para o jogo; não prometa simulação física.
3. **Construa máscaras semânticas.** Separe água, margem, solo, estrutura sólida,
   terraço, rampa, entrada de caverna e área protegida. Una toda água antes de
   calcular margens. Incorpore os limites urbanos antes de reservar travessias.
4. **Resolva caminhabilidade.** Defina rotas de subida, contorno, chegada à água
   e saída de cavernas. Uma textura com sombra não cria altura nem colisão;
   um desnível documentado em metadata não implementa movimento vertical.
5. **Escolha a arte pela vizinhança.** Pinte materiais e transições a partir das
   máscaras finais, inclusive entre chunks. Use tiles completos na escala do
   projeto e fontes editáveis. Para novos bitmaps com IA, leia a skill imagegen
   disponível; o resultado gerado precisa ser inspecionado e convertido em kit.
6. **Prove o trecho e o runtime.** Renderize as peças DMI finais a 1x, encontre
   rotas nos dados e exercite os geradores automáticos que poderiam alterar o
   terreno depois. Amplie respeitando o escopo e autorização atuais.

## Interface com cidades

Forneça à cidade: solo construível, água superficial, água sob pontes, faixa de
margem reservada, zonas sólidas, rampas, células preservadas, travessias candidatas
e hashes dos insumos. Use coordenadas globais consistentes. Receba da cidade as
vias, lotes, aproximações e pegadas de estruturas. Um conflito deve ser resolvido
nessas máscaras, não coberto com grama ou asfalto numa última passada de pintura.

Use `byond-city-design`, se disponível, para a composição urbana. Mesmo sem ela,
trate edifícios/ruas como reservas espaciais; não coloque material natural por
cima da área urbana aprovada. A classificação de água sob a ponte deve preservar
a conectividade hidrológica sem acionar natação no tabuleiro transitável.

## Entrega

Entregue tiles editáveis/exportados, mapas/chunks afetados, diagramas técnicos ou
máscaras quando úteis, previews DMI a 1x e resultados de conectividade/colisão.
Em Nexus, montanhas, dunas e cachoeiras são inteiramente de turfs exploráveis;
não substitua relevo por um grande objeto ilustrado. Não use as antigas stairs.
Deixe a revisão visual/interativa BYOND com o usuário quando assim instruído.
