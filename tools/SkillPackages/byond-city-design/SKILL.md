---
name: byond-city-design
description: Cria e revisa cidades jogáveis em BYOND/DMM, incluindo bairros, ecumenópoles, ruas, edifícios, assets DMI e interiores acessíveis. Use para composição urbana e correções de clipping entre lotes, ruas e rios; não para cidades reais ou somente terrenos naturais.
---

# Cidades BYOND

Produza tecido urbano reconhecível na escala do jogador: edifícios vizinhos,
entradas legíveis, ruas com destinos e bairros com funções distintas. Uma vista
aérea bonita não basta para provar que a cidade funciona no jogo.

## Contexto que decide o trabalho

Leia as instruções atuais do projeto e confirme mapa, escala, perspectiva,
entradas, spawns e alterações manuais antes de gerar. Em Nexus-Exodus, leia
[o perfil do projeto](references/nexus-exodus.md), inclusive as decisões mais
recentes sobre Viltrum e interiores. As regras de um planeta não são regras de
todos os planetas. Uma nova direção do usuário supera um roteiro antigo.

Para desenhar bairros e preparar assets, use
[composição e kit urbano](references/urban-form.md). Para aceitação e regressões,
use [verificações de cidade](references/validation.md).

## Fluxo de trabalho

1. **Leia o lugar.** Registre água, relevo, áreas preservadas, chegadas e acessos.
   Se o terreno ainda estiver inconsistente, resolva a faixa afetada primeiro.
   Use a skill `byond-terrain-design` se disponível para essa parte; o contrato
   de entrada necessário está descrito abaixo mesmo sem a outra skill.
2. **Planeje relações.** Defina funções de bairros, destinos, vias principais,
   ruas locais, percursos a pé e espaços de combate. Esboce quadras/lotes dentro
   desses limites. Um grafo conectado não autoriza asfalto atravessando oceanos.
3. **Reserve espaços antes de pintar.** Separe água, margem, ponte, pavimento,
   rua, lote, estrutura sólida, arte projetada e acesso. Gere casas somente em
   lotes que comportem a arte inteira, a colisão e a frente de entrada.
4. **Defina o kit a partir das quadras.** Escolha uma família consistente de
   casas, versões de esquina/orientação e serviços. Faça assets na escala real;
   leia a skill `imagegen` disponível se for gerar ou editar bitmaps com IA.
   Conserve fontes editáveis, estados DMI e a proveniência da arte.
5. **Prove uma composição pequena.** Monte um trecho com casas adjacentes,
   esquina, entrada residencial e serviço importante. Inclua margem/ponte se
   afetadas. Renderize usando os pixels DMI finais e um jogador real a 1x;
   mostre também colisão e áreas reservadas em uma vista técnica separada.
6. **Verifique e amplie.** Corrija sobreposições, escala e caminhos antes de
   replicar o kit. Quando o usuário já autorizou execução completa, continue
   após as verificações pertinentes, sem inventar uma aprovação por etapa.
   Se uma escolha visual estiver de fato pendente, entregue o trecho concreto
   para avaliação e continue apenas o trabalho independente dessa escolha.

## Contrato entre cidade e terreno

Receba do terreno máscaras estáveis de água superficial, água sob pontes,
margens reservadas, solo construível, relevo sólido, rampas transitáveis,
travessias candidatas e células protegidas. Mantenha coordenadas globais e hashes
dos insumos. Se não houver essas máscaras, derive-as dos dados atuais antes de
posicionar lotes, em vez de tratar todo terreno vazio como construível.

A cidade devolve ruas, calçadas, lotes, pegadas de edifícios, portas, praças,
aproximações de pontes e o grafo de acesso. Qualquer conflito exige rever o lote
ou travessia; não repinte água ou relevo para ocultar uma colisão. Máscara da arte
e máscara de bloqueio são distintas: um sprite grande não bloqueia automaticamente
todos os tiles visíveis no BYOND.

## Entrega

Entregue os arquivos editáveis e de execução necessários ao pedido, composição
a 1x, resumo de conflitos/caminhos, vínculo entre portas e interiores e evidência
dos checks executados. Informe separadamente o que foi renderizado offline,
exercitado no runtime e aprovado visualmente pelo usuário. Não lance interfaces
BYOND quando a revisão interativa foi reservada ao usuário.
