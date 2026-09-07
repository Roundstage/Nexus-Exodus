// Deterministic authoring utility. Run with node tools/GenerateViltrumMap.cjs.
// Refuses to overwrite an edited map unless --force is supplied.
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const output = path.join(root, 'src/Maps/Viltrum.dmm');
if (fs.existsSync(output) && !process.argv.includes('--force')) throw Error('Map exists; use --force only to discard manual map edits.');
const size = 500;
const palette = [
 ['aa','/turf/Ground_Wasteland','#937762'],
 ['ab','/turf/GroundDirt','#b19a7e'],
 ['ac','/turf/GroundSnow','#d9dfe1'],
 ['ad','/turf/Water2','#3c6576'],
 ['ae','/turf/TileStone','#bcb7ab'],
 ['af','/turf/Tile38','#d6d6cd'],
 ['ag','/turf/Tile40','#65717a'],
 ['ah','/turf/Wall21','#424955'],
 ['ai','/turf/Tile22','#aaa59f'],
 ['aj','/turf/Ground_Wasteland','#746452','/obj/Turfs/Rock1'],
 ['ak','/turf/Ground_Wasteland','#655445','/obj/Trees/Dead_Tree_2'],
 ['al','/turf/Ground_Wasteland','#858258','/obj/Turfs/Plant37'],
 ['am','/turf/Tile38','#ffffff','/obj/Spawn{name = "Viltrumite"; desc = "Viltrum"}'],
];
const grid = Array.from({length:size},()=>Array(size).fill(0));
const set = (x,y,t) => { if(x>=1&&x<=size&&y>=1&&y<=size) grid[y-1][x-1]=t; };
function rect(x1,y1,x2,y2,t){for(let y=y1;y<=y2;y++)for(let x=x1;x<=x2;x++)set(x,y,t);}
function disk(cx,cy,r,t){for(let y=cy-r;y<=cy+r;y++)for(let x=cx-r;x<=cx+r;x++)if((x-cx)**2+(y-cy)**2<=r*r)set(x,y,t);}
function road(x1,y1,x2,y2,width=4){const n=Math.max(Math.abs(x2-x1),Math.abs(y2-y1));for(let i=0;i<=n;i++)disk(Math.round(x1+(x2-x1)*i/n),Math.round(y1+(y2-y1)*i/n),width,4);}
function building(x1,y1,x2,y2){rect(x1,y1,x2,y2,7);rect(x1+2,y1+2,x2-2,y2-2,5);const mid=Math.floor((x1+x2)/2);rect(mid-2,y1,mid+2,y1+2,5);rect(mid-2,y2-2,mid+2,y2,5);}
let seed=7312026;
function random(){seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/4294967296;}
for(let y=1;y<=size;y++)for(let x=1;x<=size;x++){
 const coast=38+12*Math.sin(y/39)+6*Math.sin(y/13);
 let t=0;
 if(x<coast||x>size-coast*.65)t=3;
 else if(x<coast+10||x>size-coast*.65-10)t=1;
 else if(y>424+12*Math.sin(x/32))t=2;
 else if(Math.sin(x/28)+Math.cos(y/36)+Math.sin((x+y)/51)>1.2)t=1;
 else {const r=random();if(r<.012)t=9;else if(r<.015)t=10;else if(r<.026)t=11;}
 set(x,y,t);
}
// Eroded uplands and impact basins; broad, traversable terrain.
for(const [x,y,r] of [[114,365,32],[388,345,37],[112,140,29],[382,89,24]]){disk(x,y,r,1);disk(x,y,r-5,0);disk(x,y,Math.floor(r*.32),1);}
road(250,75,250,410,5);road(100,250,411,250,5);
road(250,145,391,145,4);road(391,145,391,250,4);
road(112,250,112,330,4);road(250,370,365,370,4);
// Imperial capital: open boulevards, axial palace, residential courtyards.
rect(174,191,326,313,4);
rect(180,197,320,307,5);
rect(244,191,256,313,6);rect(174,244,326,256,6);
for(const x of [186,214,265,293])for(const y of [204,266])building(x,y,x+20,y+30);
disk(250,250,18,4);disk(250,250,11,5);
// Imperial insignia in the central plaza, all walkable floor.
for(let i=0;i<=12;i++){set(238+i,256-i,6);set(262-i,256-i,6);}
rect(205,323,295,385,4);building(213,332,287,378);
rect(243,323,257,370,6);rect(235,361,265,368,8);
for(const x of [219,276])for(const y of [340,354,368])rect(x,y,x+4,y+4,7);
// Training arena, cardinal entrances and an unobstructed fighting floor.
disk(112,250,48,4);disk(112,250,43,7);disk(112,250,39,8);disk(112,250,33,1);
rect(107,202,117,216,4);rect(107,284,117,298,4);rect(64,245,80,255,4);rect(144,245,160,255,4);
// Military academy with barracks and three sparring courts.
rect(344,207,436,293,4);
for(const x of [350,399])for(const y of [212,263])building(x,y,x+28,y+23);
rect(383,207,397,293,6);rect(344,244,436,256,6);
for(const y of [211,264]){rect(384,y,396,y+24,8);}
// Spaceport: three marked landing pads, terminal and broad access road.
rect(184,51,316,132,4);building(202,105,298,129);
rect(243,100,257,145,6);
for(const x of [207,250,293]){disk(x,78,18,6);disk(x,78,15,5);rect(x-6,77,x+6,79,6);rect(x-1,72,x+1,84,6);}
// Remote outposts and ruined research compound.
building(94,315,130,341);building(347,355,383,383);
rect(356,123,426,171,4);
for(const x of [361,398])building(x,132,x+22,161);
rect(365,157,369,162,0);rect(417,137,421,141,0);
const landmarks=[['Capital imperial',250,250],['Palacio',250,350],['Arena',112,250],['Academia militar',391,250],['Espacoporto',250,78],['Ruinas',391,145],['Posto norte',365,370]];
set(250,250,12);
// Validate cardinal walkability between points of interest (walls and props excluded).
const blocked = new Set([3,7,9,10,11]);
const seen=new Set();const queue=[[250,250]];seen.add(249*size+249);
for(let i=0;i<queue.length;i++){const [x,y]=queue[i];for(const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1]]){const nx=x+dx,ny=y+dy,k=(ny-1)*size+nx-1;if(nx<1||nx>size||ny<1||ny>size||seen.has(k)||blocked.has(grid[ny-1][nx-1]))continue;seen.add(k);queue.push([nx,ny]);}}
for(const [label,x,y] of landmarks)assert(seen.has((y-1)*size+x-1),`Unreachable: ${label}`);
const defs=palette.map(([key,turf,,obj])=>`"${key}" = (${obj?obj+',':''}${turf},/area/Viltrum)`).join('\n');
const rows=grid.slice().reverse().map(row=>row.map(t=>palette[t][0]).join(''));
assert.equal(rows.length,500);assert(rows.every(row=>row.length===1000));
const dmm=defs+'\n\n(1,1,1) = {"\n'+rows.join('\n')+'\n"}\n';
fs.writeFileSync(output,dmm);
// Derive a lightweight editor environment from the source-of-truth DU.dme.
const environment=fs.readFileSync(path.join(root,'DU.dme'),'utf8');
const mapIncludes=environment.match(/^#include\s+"[^"\r\n]+\.dmm"\s*$/gm);
assert(mapIncludes && mapIncludes.length===4,'Review changed DU.dme map includes before generating editor environment.');
fs.writeFileSync(path.join(root,'ViltrumEditor.dme'),environment.replace(/^#include\s+"[^"\r\n]+\.dmm"\s*$/gm,'')+'\n#include "src\\Maps\\Viltrum.dmm"\n');
// Structural verification from the serialized DMM, independent of grid dimensions.
const reread=fs.readFileSync(output,'utf8');
const cells=reread.split('(1,1,1) = {"\n')[1].split('\n"}')[0].split('\n');
assert.equal(cells.length,500);
const keys=new Set(palette.map(p=>p[0]));
for(const row of cells){assert.equal(row.length,1000);for(let i=0;i<row.length;i+=2)assert(keys.has(row.slice(i,i+2)));}
let svg='<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1100" viewBox="0 0 500 550"><rect width="500" height="550" fill="#141c24"/>';
for(let y=0;y<size;y++){let start=0;for(let x=1;x<=size;x++)if(x===size||grid[y][x]!==grid[y][start]){svg+=`<rect x="${start}" y="${size-1-y}" width="${x-start}" height="1" fill="${palette[grid[y][start]][2]}"/>`;start=x;}}
for(const [label,x,y] of landmarks)svg+=`<text x="${x}" y="${500-y-9}" text-anchor="middle" font-family="sans-serif" font-size="7" fill="white" stroke="#141c24" stroke-width="2" paint-order="stroke">${label}</text>`;
svg+='<text x="16" y="521" fill="#ffffff" font-family="sans-serif" font-size="13">VILTRUM / 500 x 500</text><text x="16" y="539" fill="#adb9c4" font-family="sans-serif" font-size="8">Planta esquematica dos tiles — nao e uma renderizacao dos sprites do jogo.</text></svg>';
fs.mkdirSync(path.join(root,'docs/Maps'),{recursive:true});
fs.writeFileSync(path.join(root,'docs/Maps/ViltrumOverview.svg'),svg);
console.log(JSON.stringify({map:output,dimensions:[500,500,1],tiles:250000,palette:palette.length,reachableTiles:seen.size,landmarks:landmarks.length,bytes:Buffer.byteLength(dmm)}));
