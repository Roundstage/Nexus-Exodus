# Formas, materiais e hidrologia

## Água primeiro

Represente a água como um conjunto único antes de pintar qualquer banco ou
transição: fontes + lagos + tributários + canal principal + quedas + saída.
Calcule margens sobre a união final. Pintar um rio completo e depois pintar as
margens de outro cortou a água anterior com grama no projeto.

Use um grafo fonte → trecho alto → queda/lago quando houver → canal → mar ou
bacia terminal explicitamente intencional. Nem todo mapa precisa de nascente
visível, mas cada fragmento deve ter explicação. Varie largura e curvatura com
continuidade; evite linhas diagonais serrilhadas de largura constante atravessando
quadras. Um rio urbano permanece um rio: reserve leito, margens e passeio antes
de traçar ruas ou lotes. Vegetação deve agrupar-se sem bloquear os percursos.

Derive as transições de um padrão definido de 4 ou 8 vizinhos, documentando bits
e diagonais. Inclua cantos internos/externos e peças estreitas. Cálculos na borda
de um chunk precisam ler os vizinhos globais; nunca tratem a célula fora do chunk
como vazio por conveniência.

## Montanhas e escarpas

Comece pela massa e sua silhueta, não por faixas de cliff soltas. Use contornos
irregulares, estratos/material coerente, terraços ligados e rotas de acesso
legíveis. Uma subida natural atravessa uma abertura contínua na barreira sólida
e chega ao próximo terraço; teste o caminho real, inclusive com a vegetação.

No Nexus, turfs de rock/roof são a estrutura sólida opaca. Os pisos dos terraços
e rampas permanecem transitáveis. O usuário rejeitou Stairs_Grass e EarthRiverSteps:
use transições naturais contínuas, sem recolocar as velhas escadas sob outro nome.
Não presuma que Flying permite atravessar uma estrutura que deve barrar passagem.

Uma caverna de arenito pode ter camadas expostas, entrada erodida em alcova e
aproximação escura sob o maciço. Conecte câmaras/galerias exploráveis e um retorno
seguro ao exterior. A entrada pode ser um trigger invisível; a formação e o
espaço caminhável são turfs. Não implemente sistemas de escalada/Z novos apenas
para dar aparência de altura sem um pedido que exija essa mecânica.

## Deserto e dunas

Defina direção de vento artística e uma família de cristas, lados suaves/íngremes
e depressões interdunares. Repita o princípio da forma, variando curvatura e
amplitude. Evite cones soltos ou retângulos com textura contrastante.

Reparta dunas grandes em tiles alinhados com continuidade de cor, iluminação e
crista. Mantenha rotas entre e sobre as dunas conforme a colisão escolhida. Não
faça cada tile uma pequena duna individual nem cada pixel um tipo DM único.
Reserve terreno aberto para que o maciço e a caverna orientem o jogador.

## Ártico e floresta

O pico ártico combina rocha exposta, neve, cristas e depósitos na base; materiais
e sombras continuam entre terraços. Não replique o maciço do deserto trocando
somente a paleta se a forma deveria ser glacial.

Uma cachoeira liga água a montante, borda rochosa, queda, espuma/poço e canal a
jusante. Separe a estrutura sólida de suas passagens e da água classificada pelo
runtime. A espuma não deve fechar o rio como um tile de chão. Crie rotas nas
margens ou terraços próximos para exploração, sem uma escada no meio da queda.

## Pontes como travessias

Escolha uma travessia por função, largura do canal e lugar de apoio nas margens.
Modele aproximação, encontro, tabuleiro contínuo, bordas/guarda-corpos e saída.
O material da faixa útil continua a via (asfalto ou material moderno do kit).
Madeira é apropriada para uma passarela explicitamente desenhada assim, não
como remendo de avenida nem como píer aleatório numa nascente.

Mantenha a água subjacente numa máscara distinta da superfície caminhável. Não
inferir toda hidrologia apenas de Water quando esse flag também decide natação.
Um terraço viário, aterro ou drenagem coberta exige representação deliberada;
não transforme um oceano em corredor de asfalto para conectar componentes.
