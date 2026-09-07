# Catalogo de tiles por bioma

Fonte: `src/Code/CoreFunctions/Map.dm`. Classificacao por codigo/asset, **revisao visual pendente** em todos os itens. Nenhum mapa foi regenerado.

`BiomeTiles.json` e o catalogo consumivel por geradores. `recipes` sao candidatos de paleta, nao uma classificacao geografica do mundo. `candidate` exige revisao adicional; `excluded` nao entra na Terra por padrao.

## Regras de geracao

- Definir primeiro regiao/umidade/temperatura/altitude; selecionar tiles depois. Nunca usar luminosidade para decidir neve.
- Excluir obstacles/constructed/fictional e density=1. density=inherited exige verificacao no runtime.
- Compartilhar edge_icon/cliff_type quando possivel; a igualdade nao garante compatibilidade visual.
- Tiles com mosaico usam icon_state calculado por coordenada; misturar tipos por pixel pode cortar a textura.
- Savana, pantano e rocha transitavel nao tem paleta aprovada neste catalogo. Nao adivinhar uma substituicao.

## Inventario

| Tile | Biomas | Funcao | Evidencia | Densidade declarada | Observacao |
| --- | --- | --- | --- | --- | --- |
| `/turf/Ground14` | desert, beach | ground | code_supported | inherited | Areia/deserto confirmado pelo asset ou icon_state; tonalidades ainda precisam de revisao visual. |
| `/turf/Ground4` | desert, beach | ground | code_supported | inherited | Areia/deserto confirmado pelo asset ou icon_state; tonalidades ainda precisam de revisao visual. |
| `/turf/Ground10` | desert, beach | ground | code_supported | inherited | Areia/deserto confirmado pelo asset ou icon_state; tonalidades ainda precisam de revisao visual. |
| `/turf/GroundPebbles` | beach, desert | ground | code_supported | inherited | Apesar do nome, icon_state = Sand; nao classificar como montanha/pedregulho. |
| `/turf/GroundDirtSand` | dry_transition | transition | candidate | inherited | Candidato terra/areia; verificar textura Turfs96:dirt antes de usar como borda. |
| `/turf/GroundSandDark` | desert | ground | code_supported | 0 | Deserto escuro; densidade 0 explicita e auto_edge desativado. |
| `/turf/GroundDirt` | soil, dry_transition | ground | code_supported | inherited | Terra exposta; nao equivale automaticamente a areia de praia. |
| `/turf/Ground12` | soil, dry_transition | ground | code_supported | inherited | Terra exposta; nao equivale automaticamente a areia de praia. |
| `/turf/Ground18` | soil, dry_transition | ground | code_supported | inherited | Terra exposta; nao equivale automaticamente a areia de praia. |
| `/turf/Grass5` | temperate_grassland | ground | code_supported | inherited | Assets BigGrass/BigGrassTurf2; usam mosaicos e overlays em New(). |
| `/turf/Grass13` | temperate_grassland | ground | code_supported | inherited | Assets BigGrass/BigGrassTurf2; usam mosaicos e overlays em New(). |
| `/turf/Grass8` | temperate_grassland, dry_transition | transition | code_supported | inherited | Asset BigGrassAndDirtTurf: mistura grama/terra, nao grama uniforme. |
| `/turf/Grass12` | tropical_forest | ground | code_supported | inherited | JungleGrassTile: solo de selva. |
| `/turf/Grass1` | grass_variant_review | ground | candidate | inherited | Gramas legadas; cor, saturacao e compatibilidade de borda precisam de revisao visual. |
| `/turf/Grass2` | grass_variant_review | ground | candidate | inherited | Gramas legadas; cor, saturacao e compatibilidade de borda precisam de revisao visual. |
| `/turf/Grass3` | grass_variant_review | ground | candidate | inherited | Gramas legadas; cor, saturacao e compatibilidade de borda precisam de revisao visual. |
| `/turf/Grass4` | grass_variant_review | ground | candidate | inherited | Gramas legadas; cor, saturacao e compatibilidade de borda precisam de revisao visual. |
| `/turf/Grass7` | grass_variant_review | ground | candidate | inherited | Gramas legadas; cor, saturacao e compatibilidade de borda precisam de revisao visual. |
| `/turf/Grass9` | grass_variant_review | ground | candidate | inherited | Gramas legadas; cor, saturacao e compatibilidade de borda precisam de revisao visual. |
| `/turf/Grass10` | grass_variant_review | ground | candidate | inherited | Gramas legadas; cor, saturacao e compatibilidade de borda precisam de revisao visual. |
| `/turf/Grass11` | grass_variant_review | ground | candidate | inherited | Gramas legadas; cor, saturacao e compatibilidade de borda precisam de revisao visual. |
| `/turf/Grass14` | grass_variant_review | ground | candidate | inherited | Gramas legadas; cor, saturacao e compatibilidade de borda precisam de revisao visual. |
| `/turf/GroundSnow` | polar, alpine_snow | ground | code_supported | inherited | Neve; exige mascara fria/altitude explicita. Brilho da imagem nunca autoriza neve. |
| `/turf/GroundIce` | polar, alpine_snow | ground | code_supported | inherited | Gelo; exige regiao fria explicita, nao usar como pedra clara. |
| `/turf/GroundIce2` | polar, alpine_snow | ground | code_supported | inherited | Gelo; exige regiao fria explicita, nao usar como pedra clara. |
| `/turf/GroundIce3` | polar, alpine_snow | ground | code_supported | inherited | Gelo; exige regiao fria explicita, nao usar como pedra clara. |
| `/turf/SnowAndRocks` | alpine_snow | transition | code_supported | inherited | Mistura neve/rocha; so em borda fria autorizada, nao em montanha tropical generica. |
| `/turf/Ground13` | rock_barrier | obstacle | code_supported | 1 | Densidade 1: obstaculo, nunca piso de spawn/chegada. |
| `/turf/Ground11` | rock_barrier | obstacle | code_supported | 1 | Densidade 1: obstaculo, nunca piso de spawn/chegada. |
| `/turf/Ground_Wasteland` | wasteland | ground | candidate | inherited | Ambiente degradado/seco; nao substitui automaticamente savana ou Saara. |
| `/turf/Ground3` | fictional | ground | excluded | 0 | Assets Vegeta/Hell/Namek: fora da paleta terrestre por padrao. |
| `/turf/Ground17` | fictional | ground | excluded | inherited | Assets Vegeta/Hell/Namek: fora da paleta terrestre por padrao. |
| `/turf/GroundHell` | fictional | ground | excluded | inherited | Assets Vegeta/Hell/Namek: fora da paleta terrestre por padrao. |
| `/turf/GrassSluggo` | fictional | ground | excluded | inherited | Assets Vegeta/Hell/Namek: fora da paleta terrestre por padrao. |
| `/turf/Ground16` | urban | constructed | excluded | inherited | Flagstone/darktile; pavimentacao, nao bioma natural. |
| `/turf/Ground19` | urban | constructed | excluded | inherited | Flagstone/darktile; pavimentacao, nao bioma natural. |
| `/turf/Water2` | water | water | code_supported | inherited | Agua confirmada pelo tipo/asset; profundo, raso e agua doce exigem revisao visual e de movimento. |
| `/turf/Water6` | water | water | code_supported | inherited | Agua confirmada pelo tipo/asset; profundo, raso e agua doce exigem revisao visual e de movimento. |

## Proxima etapa visual

Montar amostras de 6x6 ou maiores por tipo, incluindo mosaicos, e comparar no jogo. Validar bordas grama/terra/areia e neve/gelo separadamente. Arvores, pedras e demais objetos de decoracao requerem um catalogo complementar: nao foram aprovados por esta classificacao de turfs.

Regenerar o inventario: `node tools/BuildBiomeTileCatalog.cjs`. Isso nao altera o DME nem os mapas.
