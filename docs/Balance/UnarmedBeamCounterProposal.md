# Proposta de balanceamento: Comet Reversal

> Status: protótipo implementado em 31 de agosto de 2026 e pronto para playtest. A implementação não altera os atributos globais de Beam.

## Problema

Existe uma assimetria clara entre as opções de resposta a longa distância:

| Opção atual | Alcance | Recarga | Papel |
|---|---:|---:|---|
| Beams comuns e nomeados | 30–60 tiles | 3 s por técnica | Pressão e controle de longa distância |
| Echoing Slash | 40 tiles | 9 s | Projétil físico de sword, fator 14 |
| Sky Break | 40 tiles | 13 s | Projétil físico de sword, orçamento máximo 26 |
| Burning Shot | 6 tiles | 14 s | Aproximação unarmed intermediária |
| March of Fury | 7 tiles | 17 s | Capstone unarmed de perseguição |
| Blue Comet Special | 8 tiles | 17,5 s | Maior alcance unarmed atual |

Os fatores de melee e projétil usam fórmulas diferentes e não devem ser comparados isoladamente. A diferença relevante é espacial: sword continua ameaçando a 40 tiles, enquanto unarmed precisa atravessar quase toda essa distância antes de começar a exercer pressão.

O Short Dash universal não pode evadir `Beam`, `Explosive` ou projéteis com `Size`. Block reduz dano, mas não recupera distância. A deflexão genérica de beam também não cria pressão sobre o emissor. Unarmed precisa de uma resposta própria que preserve a força atual de Beam e recompense leitura e timing.

## Proposta

A implementação adiciona uma técnica unarmed defensiva chamada **Comet Reversal**.

O lutador assume uma postura curta, intercepta um beam que realmente acertaria sua hitbox e avança pelo rastro de energia em direção ao emissor. Sword responde à distância com ondas físicas; unarmed responde convertendo um acerto bem lido em aproximação.

### Fluxo

1. O jogador ativa Comet Reversal sem selecionar alvo.
2. O custo é pago e a recarga começa imediatamente.
3. Uma postura visível permanece ativa por **1,2 segundo**.
4. O counter só dispara se um segmento hostil de `Beam` realmente tocaria a hitbox do usuário e seu `Owner` estiver no arco frontal de 90 graus.
5. No primeiro contato válido, a postura entra em guarda de investida antes de qualquer efeito assíncrono:
   - o dano daquele contato é cancelado;
   - somente o beam responsável é encerrado através de `BeamStop(..., immediate = 1)`;
   - o beam mantém sua recarga normal, sem silêncio, debuff ou penalidade adicional;
   - o usuário avança em direção ao primeiro `Owner` por no máximo **32 tiles**, respeitando paredes e colisão;
   - durante esse único avanço, outros beams hostis cujo `Owner` esteja no arco frontal e que tocarem o usuário também são encerrados, sem trocar o alvo, iniciar outro rush ou conceder outro golpe;
   - a guarda termina junto do avanço e possui um teto de segurança de **3,5 segundos**;
   - ao alcançar adjacência, tenta um único golpe físico de precisão normal;
   - se não alcançar, conserva apenas o terreno conquistado e não recebe ataque gratuito.
6. Se nenhum beam válido tocar durante a janela, custo e recarga continuam gastos.

## Números iniciais

| Propriedade | Valor de protótipo |
|---|---:|
| Requisito | Sem arma equipada |
| Janela do counter | 12 ticks / 1,2 s |
| Recarga | 100 ticks / 10 s |
| Custo | 24 Energy, pelo cálculo normal de técnica física |
| Avanço máximo | 32 tiles |
| Guarda após o primeiro contato | Duração do avanço, máximo 3,5 s |
| Dano do golpe final | `damage_multiplier = 2.0` |
| Precisão | Melee normal + bônus unarmed existente |
| Knockback, stun e bleed | Nenhum |
| Alvo | Somente o emissor do beam interceptado |

O dano deve permanecer baixo. O prêmio é interromper um disparo corretamente lido e transformar distância em pressão melee.

## O que não muda em Beam

Comet Reversal não altera globalmente:

- `damage_factor`;
- `Drain`;
- `Range`;
- `MoveDelay`;
- `deflect_difficulty`;
- hitbox ou velocidade dos segmentos;
- `beam_skill_cooldown_ticks`;
- dano, alcance ou recarga de qualquer beam individual.

Fora da janela específica de um usuário unarmed que comprou a técnica, Beam continua funcionando exatamente como hoje.

## Counterplay do usuário de Beam

- **Bait:** iniciar a carga, esperar a postura terminar e disparar depois. O unarmed perde custo e fica 10 s sem o counter.
- **Flanco:** beams cujo emissor esteja atrás ou fora do arco frontal não acionam a técnica.
- **Distância extrema:** acima de 32 tiles, o unarmed ganha terreno, mas não recebe o golpe final.
- **Terreno e body block:** o avanço não atravessa paredes, objetos densos ou personagens que bloqueiem a rota.
- **Interrupção:** knockback ou outra interrupção do movimento encerra a resposta sem conceder o golpe final, mesmo que o usuário termine adjacente.
- **Cancelar e defender:** o emissor pode encerrar sua ofensiva e preparar Block, movimento ou outro counter antes da chegada.
- **Defesa normal:** o golpe final não é garantido e usa a resolução melee normal.
- **Pressão de equipe:** o avanço não concede invulnerabilidade global; melee, blasts, explosões e beams emitidos por adversários fora do arco frontal ainda podem acertar o usuário.
- **Mistura de ataques:** blasts, explosões, Genki Dama e projéteis físicos não acionam Comet Reversal.

## Proteções contra abuso

- Revalidar `requires_unarmed` na ativação e no momento do trigger.
- Armar a guarda de investida sincronamente antes de iniciar o avanço, impedindo múltiplos segmentos de criarem vários rushes.
- Beams adicionais cujo emissor permaneça no arco frontal encerram apenas os próprios streams; eles não renovam o teto de 3,5 segundos, não trocam o alvo e não criam golpes extras.
- Aceitar somente `Beam` hostil com `Owner` do tipo `mob`, no mesmo `z`, respeitando Safezone e RP Mode.
- Não refletir dano contra o emissor e não resetar outras recargas unarmed.
- Limpar a janela e a guarda de investida em KO, grab, RP Mode, Safezone, ao equipar uma arma ou quando o avanço terminar.
- Comet Reversal é incompatível com Block, Guard Break e outros counters ativos.
- Manter `repeat_macro = 0`.
- Não permitir teleporte direto: toda aproximação deve usar movimento com colisão.

## Posição na progressão

Sugestão: **Unarmed Tier 4**, custo de progressão **20**, após Guard Break.

Isso a coloca no mesmo estágio e custo de Echoing Slash, mas com função oposta: Echoing Slash mantém ameaça à distância; Comet Reversal cria uma oportunidade condicional de aproximação.

```dm
configureProgressionRewardPath(
	/obj/Attacks/NexusMeleeTechnique/CometReversal,
	4,
	20,
	list(/obj/Attacks/NexusMeleeTechnique/GuardBreak)
)
```

## Integração implementada

- `CometReversal` vive em `src/Code/Combat/NexusMeleeTechniques.dm`, com `behavior = "beam_counter"` e `hotbar_type = "Melee"`.
- A janela usa a postura exclusiva `comet_reversal`; ativá-la remove Riposte, Block, Guard Break ou outra postura concorrente.
- `obj/Blast/proc/Beam()` testa o counter depois da confirmação e deduplicação geométrica do contato, antes de deflexão, absorção ou dano.
- `Owner`, `from_attack`, `streaming`, `current_beam` e a posse do objeto são revalidados antes de `BeamStop(..., immediate = 1)` encerrar somente o disparo responsável.
- O primeiro contato arma uma única guarda de investida com teto de 3,5 segundos. Contatos adicionais de beams com emissor no arco frontal encerram seus próprios streams, mas preservam o primeiro alvo e não criam outro avanço ou golpe.
- `runNexusSkillApproach()` limita o avanço a 32 tiles e respeita paredes, objetos densos e personagens no caminho; ao retornar, encerra imediatamente a guarda.
- O tipo faz parte de `getNexusUnarmedAttackTypes()`, da árvore Combat -> Unarmed e do exame detalhado do Action HUD.
- Os smoke tests cobrem o contrato numérico, progressão, arco frontal, dois beams consecutivos do mesmo emissor, teardown independente dos streams, um único avanço/golpe e o fim da guarda junto da investida.

## Critérios de playtest

Medir separadamente:

- dano de beam evitado por ativação;
- quantidade de beams interrompidos por uma única investida;
- taxa de posturas desperdiçadas;
- distância média recuperada;
- frequência com que o golpe final realmente conecta;
- tempo médio que unarmed leva para alcançar o emissor após o trigger;
- taxa de vitória contra beam antes e depois da técnica.

Se a técnica ficar forte demais, os primeiros ajustes devem ser reduzir o avanço de 32 para 24 tiles ou remover o golpe final. Se ficar fraca, aumentar a janela para 1,5 s ou reduzir a recarga para 8 s. Nenhum desses ajustes exige reduzir dano, alcance ou cadência de Beam.

## Referências no código

- `src/Code/CoreFunctions/Vars/GlobalCombatSettings.dm`: valor-base da recarga de Beam, aplicado separadamente a cada objeto de técnica.
- `src/Code/ProjectileSystem/Beams.dm` e `src/Code/ProjectileSystem/NexusBeams.dm`: alcance, fatores e recargas dos beams.
- `src/Code/ProjectileSystem/BeamCore.dm` e `src/Code/ProjectileSystem/Projectiles.dm`: criação, contato, `Owner`, `from_attack` e encerramento.
- `src/Code/Combat/NexusSpecialStyles.dm`: Echoing Slash e Sky Break.
- `src/Code/Combat/NexusMeleeTechniques.dm`: alcances, recargas e resolução das técnicas unarmed.
- `src/Code/Application/Movement/DefensiveDash.dm`: exclusão explícita de Beam no Short Dash.
- `src/Code/PlayerMechanics/ProgressionTrees.dm`: organização atual das árvores Weapon e Unarmed.
