# Verificações que capturam falhas reais

## Geometria e circulação

- Compare a pegada sólida e os limites da arte com rua, água, margem, calçada e
  lotes vizinhos. Qualquer avanço visual deliberado deve ter regra explícita;
  portas e caminhos nunca podem ficar cobertos acidentalmente.
- Faça flood fill/BFS dos caminhos transitáveis, com densidade real de turfs e
  objetos. Toda porta acessível precisa de aproximação e retorno seguros.
- Classifique os finais de rua. Praça de retorno, acesso a serviço ou porto
  são destinos; um corte aleatório na grama é defeito. Não force conexões entre
  ilhas para satisfazer uma única BFS planetária.
- A ponte é um trecho completo: via de entrada → encontro na margem → tabuleiro
  → encontro oposto → saída. Água continua por baixo; colisões do guarda-corpo
  não invadem a faixa útil. Não use madeira de píer para continuar uma avenida.
- Confira todas as bordas de chunks, incluindo os cantos, em coordenadas globais.

## Portas e estrutura

Uma entrada tem building_id único, destino válido, área e planeta corretos.
O retorno conduz à aproximação externa, sem loop de reentrada. Teste ida/volta,
destino incorreto em outro planeta, KO/KB e bloqueios existentes. Coordenadas
numéricas sozinhas não bastam: ordem de includes pode mudar o significado do Z.

Use o runtime para verificar densidade/opacidade, bloqueio de voo e entrada no
interior. Não aceite como teste de integração uma regex de nomes como Roof.
Os interiores Nexus atuais ficam vazios, com somente um portal de retorno,
salvo uma nova instrução explícita para mobiliá-los.

## Arte aplicada e geração tardia

Renderize com os DMI que o jogo carrega, à escala de 32px por tile e com avatar
real. Compare linha da calçada, leitura da porta, continuidade dos materiais,
encobrimento pelo prédio e sobreposição com a rua. Uma imagem conceitual ou
atlas reduzido não substitui essa composição.

Capture tipos, ícones/estados, densidade, água e overlays de margens antes/depois
dos geradores de runtime. Acione os mesmos percursos chamados quando o jogador
entra nas regiões; simples startup sem visitar as zonas deixou passar Wall7,
edges e waves no passado. Preserve overlays legítimos ao bloquear geradores.

Na entrega, registre o escopo examinado e a distinção entre resultado de teste
e aprovação visual. Falhas reais exigem correção; não enfraqueça o check para
acomodar um mapa quebrado nem peça aprovação repetida para ajustes já autorizados.
