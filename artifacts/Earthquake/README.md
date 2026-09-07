# Earthquake VFX

Primeira versão visual: fissuras no chão, frente de pressão convergente, pedras em suspensão e poeira em tons de terra. A contração acompanha a atração de inimigos da habilidade existente.

- `Earthquake.aseprite`: fonte editável, 160 × 128 px, 24 quadros de 50 ms (1,2 s), quatro camadas.
- `EarthquakeSheet.png`: spritesheet transparente, 6 colunas × 4 linhas, ordem da esquerda para a direita.
- `Earthquake.gif`: animação transparente em resolução original.
- `EarthquakePreview.gif`: prévia ampliada 4× sobre fundo escuro, com pausa entre repetições.
- `CreateEarthquake.lua`: gerador determinístico executado pelo próprio Aseprite, usando sua API Lua.
- `EarthquakeDust.pxc`: cópia de trabalho do exemplo embarcado **Smoke Explosion** do Pixel Composer. Não é o VFX final e não contribuiu para os pixels exportados: o programa 1.21.9.0 avisou sobre a versão do exemplo e falhou na simulação com `index out of bounds request 0 maximum size is 0` em `NodeValue_Dimension`.

O VFX final foi gerado e exportado no Aseprite 1.3.18.3. A spritesheet foi inspecionada visualmente. A integração usa `src/Icons/Effects/Earthquake.dmi` e `showNexusEarthquakeEffect()`, com raio de oito tiles. A frente externa de 72 px determina a escala; o centro visual do chão (80,75), medido a partir do canto superior esquerdo, é alinhado ao centro de colisão do usuário no momento do lançamento. O efeito fica parado no chão, abaixo dos personagens, preserva a paleta e termina após 1,2 segundo. A elipse é uma projeção visual estilizada; a consulta de dano continua circular.

`node artifacts/Earthquake/ExportEarthquakeDmi.cjs` converte a spritesheet em DMI sem modificar os pixels, acrescentando estado, dimensões e tempos de animação.

Para regenerar a partir da raiz do repositório:

```powershell
& 'C:/Program Files (x86)/Steam/steamapps/common/Aseprite/Aseprite.exe' -b --script artifacts/Earthquake/CreateEarthquake.lua
```

API utilizada: https://www.aseprite.org/api/ e https://www.aseprite.org/docs/cli/
