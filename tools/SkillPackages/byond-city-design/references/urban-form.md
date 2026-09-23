# Composição urbana e kit de edifícios

## Quadras que parecem habitadas

Desenhe ruas segundo destinos e terreno. Diferencie avenidas, ruas de bairro,
frentes comerciais, becos, praças e percursos ribeirinhos. Defina primeiro a
linha de fachadas; casas adjacentes devem compartilhar o ritmo da calçada.
Variação de telhado, janela, jardim e largura preserva essa linha. Uma casa por
retângulo enorme de pavimento produz um estacionamento de sprites.

Use um módulo residencial recorrente, versões de esquina, pequenos serviços
nas interseções e alguns edifícios públicos reconhecíveis. Marque quais portas
são acessíveis e quais fachadas são cenográficas. Distribua acessibilidade entre
serviços e residências; não transforme a cidade inteira em cenário inacessível.
Nomes como hospital ou fábrica não implementam cura ou produção automaticamente.

Dimensões iniciais usadas na Terra: casas de aproximadamente 5–7 tiles de frente,
calçadas de 2 tiles, vielas transitáveis de cerca de 3 tiles, ruas residenciais
com cerca de 7 tiles. São hipóteses de escala, não limites universais. Compare
porta/jogador, largura de combate, alcance da câmera e aspecto visual antes de
fixar os valores. O objetivo é densidade legível, não maximizar a ocupação.

Registre por lote: id, bairro/função, limites, frente, orientação, tipo do edifício,
âncora do sprite, deslocamento em pixels, extensão visual, máscara de colisão,
tile da porta, aproximação externa e referência do interior. Calcule os limites
visuais incluindo pixel_x/pixel_y e sobreposições; não teste apenas a âncora.
Vãos estreitos meramente visuais não devem parecer passagens utilizáveis.

## Modernidade e ecumenópoles

Construa continuidade entre bairros, transições de densidade, serviços e uma
hierarquia de marcos. Um planeta urbano não precisa repetir a mesma quadra nem
cobrir toda água com vias. Corredores de água, parques, encostas urbanizadas e
áreas de infraestrutura organizam a cidade e criam orientação.

Para Viltrum, use habitação moderna reconhecível em conjuntos adjacentes como
base, reinterpretada com pedra/metal claro, vidro teal e linhas escuras. Reserve
torres e volumes imperiais para marcos e funções específicas. As referências
altas não anulam a rejeição de torres finas isoladas em todos os lotes. Fachadas
brancas sem sombra perdem volume; luz ciano em toda borda vira ruído. Use planos
claros, juntas escuras e sinais luminosos localizados.

## Inventário orientado ao uso

Monte uma matriz pequena de função × orientação × variação realmente utilizada:

- Moradia contígua, esquina, pequeno apartamento e acesso residencial.
- Hospital/clínica, serviço cívico, comércio e os serviços pedidos para o bairro.
- Fachadas/portas, estrutura/roofs, pisos, calçadas, asfalto e marcações.
- Esquinas/cantos de pavimento, travessia completa, guarda-corpo e aproximações.
- Árvores, bancos, postes, vegetação e sinalização com fundo transparente.

Não gere uma folha imensa com dezenas de peças antes de testar se duas casas
vizinhas funcionam juntas. Planeje espaço transparente de cada peça e estados
necessários antes da geração. Inspecione a imagem resultante; recortar uma
ilustração de cidade não cria automaticamente módulos alinhados de 32×32.

## Contrato de arte e BYOND

Mantenha perspectiva, resolução, direção de luz, proporção da porta e espessura
dos contornos iguais na família. Exporte pixel art com nearest-neighbor, sem
reescalas fracionárias. Tiles de piso/estrutura cobrem o bloco inteiro; objetos
recortados têm alfa real, sem piso embutido e sem quadriculado pintado.

Registre a fonte editável Aseprite, dimensões de quadro, nomes dos estados,
direções, frames e duração da animação. Compare os pixels exportados e os nomes
usados no DM/DMM. Um arquivo DMI é PNG com metadados; salvar um PNG simples com
outra extensão não produz necessariamente os estados corretos.

No Nexus, roofs são os turfs sólidos e opacos da estrutura; walls são faces
decorativas. A arte de uma casa grande precisa de uma pegada sólida correspondente,
respeitando a porta. Interiores são separados. Se o cliente deixar de desenhar a
âncora de um objeto grande, a estrutura ainda deve aparecer corretamente; use o
mecanismo de turfs estruturais/recortes já existente, quando apropriado.

Prefira assets estáticos compartilhados, cache de ícones e instâncias somente
onde há função. Não adicione um loop, luz dinâmica ou interação por fachada.
Meça a contagem de turfs/objetos/estados antes de expandir a escala planetária.
