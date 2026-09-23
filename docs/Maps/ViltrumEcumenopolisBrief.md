# Viltrum: ecumenópolis moderna

**Implementação de 2026-09-14:** [cidade aplicada, previews e validação](ViltrumEcumenopolis.md).
O brief abaixo registra a direção inicial; a especificação aplicada e seus
hashes estão em `ViltrumEcumenopolis.json`.

Direção do usuário em 2026-09-14. Este brief prepara a próxima execução conjunta
de `byond-terrain-design` e `byond-city-design`; a criação das skills não aplica
um novo mapa. Leia o [contrato comum](WorldbuildingContract.md) antes de gerar.

## O que já foi decidido

Viltrum deve se tornar uma ecumenópolis moderna. A conversa anterior estabeleceu
prédios reconhecíveis, casas vizinhas, desenho de quadras e portas para interiores
separados. A escala monumental das referências convive com ruas legíveis para
um jogador; as torres geradas anteriormente foram rejeitadas como resultado.
Não reutilize automaticamente esse sheet nem a cidade antiga só porque existem
arquivos chamados Capital, Buildings ou WorldChecks.

As imagens enviadas mostram arquitetura clara, vidro/água azul-teal, estruturas
escuras, planos recortados, terraços verdes, espaços cívicos e torres de destaque.
Use essas relações para criar uma família de assets moderna e consistente.
A imagem de cidade medieval ensina proximidade e composição; não define telhas
medievais para Viltrum. A referência futurista de rua ensina relação entre
fachada, entrada, passeio e via; não é uma licença para copiar o tileset.

Preserve a Terra aprovada e suas áreas naturais. A regra terrestre de uma única
cidade não limita Viltrum a um único núcleo cercado por wilderness. Ao mesmo
tempo, ecumenópolis não implica preencher oceanos com estradas ou desenhar um
tapete idêntico de quarteirões em todos os chunks.

## Proposta de composição para a primeira execução

Os itens desta seção são um ponto de partida de design, não novas exigências do
usuário nem um layout já aprovado.

- Malha contínua de bairros sobre o solo utilizável, com corredores de água,
  jardins planejados, infraestrutura e áreas de circulação/combate.
- Habitação moderna contígua forma a maioria das frentes. Esquinas, apartamentos
  compactos e serviços locais criam variação com proporções compatíveis.
- Eixo cívico/imperial com praça e alguns volumes monumentais, sem transformar
  cada casa em torre. Hospitais, ciência, transporte e indústria limpa ajudam a
  diferenciar bairros e dão destinos às vias principais.
- Uma família de materiais claros e vidro teal, sombra suficiente para volume,
  luminância contida nas bordas e vegetação em faixas coerentes. Ajustar paleta
  a partir da leitura a 1x, não apenas do panorama distante.
- Reservar espaço para rotas alternativas e combate em praças/avenidas; ruas
  residenciais podem ser compactas. Não abrir um terreno vazio enorme por casa.

## Ordem prática

1. Comparar a saída manual atual de Viltrum com os chunks e preservar as edições.
   Confirmar spawns/chegadas/portas existentes e a cobertura dos geradores.
2. Preparar água, margens, relevo preservado e solo construível em coordenadas
   globais. Entregar essas máscaras à composição urbana.
3. Esboçar bairros e hierarquia viária para o planeta. Detalhar primeiro um
   trecho de aproximadamente uma quadra com casas adjacentes, esquina, hospital
   ou clínica e uma entrada residencial. Incluir uma travessia somente se o
   terreno escolhido justificar uma ponte.
4. Produzir apenas o kit necessário a esse trecho: moradias compatíveis,
   serviço, estrutura, portas, pisos/ruas, cantos e poucos props transparentes.
   Renderizar DMI a 1x com personagem e verificar colisão/fluxos/overlays.
5. Usar o resultado do trecho para ajustar o kit e ampliar bairros distintos,
   conforme o escopo autorizado. A avaliação interativa fica com o usuário.

## Critério de conclusão da futura cidade

Casas formam frentes contínuas sem clipping; entradas e retornos funcionam;
interiores seguem a política vigente; rios não são interrompidos por grama;
pontes têm aproximações e tabuleiro completos; todos os finais de via têm
função; costuras de chunks não ficam visíveis por erro de vizinhança. O runtime
não cria cliffs, edges ou waves sobre o terreno autorado. Previews usam os DMI
finais, fontes são editáveis e verificações correspondem aos arquivos entregues.

Evidência técnica e aprovação visual são registradas separadamente. Não declarar
a ecumenópolis concluída com base apenas num atlas, gerador ou folha de sprites.
