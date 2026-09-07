# Pixel Composer: validação da atualização

Validado em 2026-09-06 no Pixel Composer 1.21.9.2 instalado pelo Steam.

- O exemplo original **Smoke Explosion**, aberto novamente por Welcome Files, carregou e simulou seus 24 quadros sem o erro de dimensão da versão 1.21.9.0.
- `SmokeExplosionValidated.pxc` foi salvo pelo aplicativo. O campo Dimension do nó Particle contém `[1,1]`, em vez do array vazio encontrado na cópia antiga.
- `SmokeExplosionValidated.png` foi exportado pelo aplicativo usando Save Current Frame na saída Render Spritesheet. É a superfície de 320 × 256 pixels do exemplo, não o VFX final da Explosive Wave.
- `../Earthquake/EarthquakeDust.pxc` continua sendo a cópia antiga com dados inválidos. A atualização não reparou automaticamente esse arquivo já salvo.
- `SmokeExplosionRepaired.pxc` é uma tentativa de reparo manual preparada durante o diagnóstico, não validada no aplicativo. Prefira a base `SmokeExplosionValidated.pxc`.

A atualização resolveu o fluxo testado de importação do exemplo original, simulação, salvamento e exportação. Isso não equivale a validar todos os nós ou projetos do programa.

As [notas oficiais da versão 1.21.9.2](https://makham.itch.io/pixel-composer/devlog/1647248/12192-patch) mencionam correções no carregamento de dimensões de projetos antigos e de valores padrão de arrays.
