// Authoring metadata only. Does not regenerate maps or modify runtime types.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
const relativeSource='src/Code/CoreFunctions/Map.dm';
const source=fs.readFileSync(path.join(root,relativeSource),'utf8');
const turfStart=source.indexOf('\nturf\r\n')>=0?source.indexOf('\nturf\r\n'):source.indexOf('\nturf\n');
assert(turfStart>=0);
const turfSection=source.slice(turfStart).split(/\nturf\/proc\/Water_Ripple/)[0];
const blocks=new Map([...turfSection.matchAll(/^\t(\w+)\r?\n((?:\t\t[^\n]*\n|\s*\r?\n)*)/gm)].map(m=>[m[1],m[2]]));
const entries=[];
function add(names,biomes,role,status,notes){for(const name of names.split(' ')){
 const body=blocks.get(name);assert(body,`Missing turf ${name}`);
 const active=body.split(/\r?\n/).filter(l=>!l.trim().startsWith('//')).join('\n');
 const icon=active.match(/^\t\ticon\s*=\s*'([^']+)'/m)?.[1];
 const iconState=active.match(/^\t\ticon_state\s*=\s*"([^"]*)"/m)?.[1]??null;
 assert(icon&&fs.existsSync(path.join(root,icon)),`Missing asset: ${name}`);
 const explicitDensity=active.match(/^\t\tdensity\s*=\s*(\d)/m)?.[1];
 const mosaic=active.match(/DecideTurfStateForSpecialIcons\((\d+),(\d+)\)/);
 entries.push({type:`/turf/${name}`,biomes,role,status,notes,source:relativeSource,icon,iconState,
  density:explicitDensity===undefined?'inherited':Number(explicitDensity),
  visualReview:'pending',requiresColdRegion:biomes.includes('polar')||biomes.includes('alpine_snow'),
  mosaic:mosaic?[Number(mosaic[1]),Number(mosaic[2])]:null,
  edgeIcon:active.match(/^\t\tedge_icon\s*=\s*'([^']+)'/m)?.[1]??null,
  cliffType:active.match(/^\t\tcliff_type\s*=\s*(\/\S+)/m)?.[1]??null});}}
add('Ground14 Ground4 Ground10',['desert','beach'],'ground','code_supported','Areia/deserto confirmado pelo asset ou icon_state; tonalidades ainda precisam de revisao visual.');
add('GroundPebbles',['beach','desert'],'ground','code_supported','Apesar do nome, icon_state = Sand; nao classificar como montanha/pedregulho.');
add('GroundDirtSand',['dry_transition'],'transition','candidate','Candidato terra/areia; verificar textura Turfs96:dirt antes de usar como borda.');
add('GroundSandDark',['desert'],'ground','code_supported','Deserto escuro; densidade 0 explicita e auto_edge desativado.');
add('GroundDirt Ground12 Ground18',['soil','dry_transition'],'ground','code_supported','Terra exposta; nao equivale automaticamente a areia de praia.');
add('Grass5 Grass13',['temperate_grassland'],'ground','code_supported','Assets BigGrass/BigGrassTurf2; usam mosaicos e overlays em New().');
add('Grass8',['temperate_grassland','dry_transition'],'transition','code_supported','Asset BigGrassAndDirtTurf: mistura grama/terra, nao grama uniforme.');
add('Grass12',['tropical_forest'],'ground','code_supported','JungleGrassTile: solo de selva.');
add('Grass1 Grass2 Grass3 Grass4 Grass7 Grass9 Grass10 Grass11 Grass14',['grass_variant_review'],'ground','candidate','Gramas legadas; cor, saturacao e compatibilidade de borda precisam de revisao visual.');
add('GroundSnow',['polar','alpine_snow'],'ground','code_supported','Neve; exige mascara fria/altitude explicita. Brilho da imagem nunca autoriza neve.');
add('GroundIce GroundIce2 GroundIce3',['polar','alpine_snow'],'ground','code_supported','Gelo; exige regiao fria explicita, nao usar como pedra clara.');
add('SnowAndRocks',['alpine_snow'],'transition','code_supported','Mistura neve/rocha; so em borda fria autorizada, nao em montanha tropical generica.');
add('Ground13 Ground11',['rock_barrier'],'obstacle','code_supported','Densidade 1: obstaculo, nunca piso de spawn/chegada.');
add('Ground_Wasteland',['wasteland'],'ground','candidate','Ambiente degradado/seco; nao substitui automaticamente savana ou Saara.');
add('Ground3 Ground17 GroundHell GrassSluggo',['fictional'],'ground','excluded','Assets Vegeta/Hell/Namek: fora da paleta terrestre por padrao.');
add('Ground16 Ground19',['urban'],'constructed','excluded','Flagstone/darktile; pavimentacao, nao bioma natural.');
add('Water2 Water6',['water'],'water','code_supported','Agua confirmada pelo tipo/asset; profundo, raso e agua doce exigem revisao visual e de movimento.');
const catalog={version:1,evidence:'Classificacao semantica baseada no codigo e nomes/estados dos assets; nao representa aprovacao visual.',
 rules:{geography:'Definir primeiro regiao/umidade/temperatura/altitude; selecionar tiles depois. Nunca usar luminosidade para decidir neve.',
  spawn:'Excluir obstacles/constructed/fictional e density=1. density=inherited exige verificacao no runtime.',
  transitions:'Compartilhar edge_icon/cliff_type quando possivel; a igualdade nao garante compatibilidade visual.',
  mosaics:'Tiles com mosaico usam icon_state calculado por coordenada; misturar tipos por pixel pode cortar a textura.',
  unsupported:'Savana, pantano e rocha transitavel nao tem paleta aprovada neste catalogo. Nao adivinhar uma substituicao.'},
 recipes:{desert:['Ground14','Ground4','Ground10'],beach:['Ground14','GroundPebbles'],
  temperate_grassland:['Grass5','Grass13'],tropical_forest:['Grass12'],soil:['GroundDirt','Ground12','Ground18'],
  dry_transition:['Grass8','GroundDirtSand'],polar:['GroundSnow','GroundIce','GroundIce2','GroundIce3'],
  alpine_snow:['SnowAndRocks','GroundSnow'],water:['Water2','Water6']},tiles:entries};
for(const e of entries)assert(!(e.type==='/turf/GroundPebbles'&&e.biomes.includes('rock_barrier')));
for(const [biome,names]of Object.entries(catalog.recipes))for(const name of names){const e=entries.find(t=>t.type===`/turf/${name}`);assert(e&&e.biomes.includes(biome)&&e.density!==1);}
const dir=path.join(root,'docs/Maps');fs.mkdirSync(dir,{recursive:true});
fs.writeFileSync(path.join(dir,'BiomeTiles.json'),JSON.stringify(catalog,null,2)+'\n');
let md='# Catalogo de tiles por bioma\n\nFonte: `src/Code/CoreFunctions/Map.dm`. Classificacao por codigo/asset, **revisao visual pendente** em todos os itens. Nenhum mapa foi regenerado.\n\n';
md+='`BiomeTiles.json` e o catalogo consumivel por geradores. `recipes` sao candidatos de paleta, nao uma classificacao geografica do mundo. `candidate` exige revisao adicional; `excluded` nao entra na Terra por padrao.\n\n';
md+='## Regras de geracao\n\n'+Object.values(catalog.rules).map(v=>'- '+v).join('\n')+'\n\n';
md+='## Inventario\n\n| Tile | Biomas | Funcao | Evidencia | Densidade declarada | Observacao |\n| --- | --- | --- | --- | --- | --- |\n';
for(const e of entries)md+=`| \`${e.type}\` | ${e.biomes.join(', ')} | ${e.role} | ${e.status} | ${e.density} | ${e.notes} |\n`;
md+='\n## Proxima etapa visual\n\nMontar amostras de 6x6 ou maiores por tipo, incluindo mosaicos, e comparar no jogo. Validar bordas grama/terra/areia e neve/gelo separadamente. Arvores, pedras e demais objetos de decoracao requerem um catalogo complementar: nao foram aprovados por esta classificacao de turfs.\n\nRegenerar o inventario: `node tools/BuildBiomeTileCatalog.cjs`. Isso nao altera o DME nem os mapas.\n';
fs.writeFileSync(path.join(dir,'BiomeTiles.md'),md);
console.log(`Catalogo validado: ${entries.length} tiles, ${Object.keys(catalog.recipes).length} paletas; assets existentes. Nenhum DMM alterado.`);
