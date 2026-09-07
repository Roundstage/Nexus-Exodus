// Geography follows the supplied Earth reference, not procedural ellipses.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),out=path.join(root,'src/Maps/SuperEarth.dmm');
if(fs.existsSync(out)&&!process.argv.includes('--force'))throw Error('Map exists; --force replaces it.');
const geo=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/SuperEarthGeography.json'),'utf8'));
assert(geo.rows.length===500&&geo.rows.every(r=>r.length===500));
const sourceGrid=geo.rows.map(r=>[...r].map(Number));
const grid=sourceGrid.map(row=>row.slice());
const palette=[['/turf/Water2','#235785'],['/turf/GroundDirt','#d2b87a'],['/turf/Grass8','#6d9554'],['/turf/GroundSnow','#e0e7e8'],['/turf/GroundPebbles','#a7a391'],['/turf/Tile38','#c8d6dc'],['/turf/Tile40','#6b8290'],['/turf/Grass8','#406c3d','/obj/Trees/Tree_20191']];
const SIZE=500;
const isLand=(x,y)=>x>=0&&x<SIZE&&y>=0&&y<SIZE&&sourceGrid[y][x]!==0;
const noise=(x,y)=>Math.sin(x*.071+y*.043)*.5+Math.sin(x*.019-y*.057)*.32+Math.cos(x*.127+y*.013)*.18;
// First suppress small pixel artifacts from the geographic reference. The
// subsequent low-frequency transition bands make biomes blend naturally.
for(let y=2;y<SIZE-2;y++)for(let x=2;x<SIZE-2;x++)if(isLand(x,y)){
 const counts=[0,0,0,0,0];
 for(let dy=-2;dy<=2;dy++)for(let dx=-2;dx<=2;dx++){const terrain=sourceGrid[y+dy][x+dx];if(terrain)counts[terrain]++;}
 let winner=sourceGrid[y][x];for(let terrain=1;terrain<=4;terrain++)if(counts[terrain]>counts[winner])winner=terrain;
 if(counts[winner]>=11)grid[y][x]=winner;
}
function nearestTerrain(x,y,terrain,maxDistance=9){
 for(let distance=1;distance<=maxDistance;distance++){
  for(let dx=-distance;dx<=distance;dx++){const dy=distance-Math.abs(dx);for(const sign of dy?[dy,-dy]:[0]){const nx=x+dx,ny=y+sign;if(nx>=0&&nx<SIZE&&ny>=0&&ny<SIZE&&biomeGrid[ny][nx]===terrain)return distance;}}
 }return maxDistance+1;
}
// Introduce 6–9 tile irregular transition zones. A tile keeps its primary
// biome in the interior; boundary changes happen in broad clusters, not lines.
const biomeGrid=grid.map(row=>row.slice());
for(let y=0;y<SIZE;y++)for(let x=0;x<SIZE;x++)if(biomeGrid[y][x]!==0){
 const primary=biomeGrid[y][x], candidates=[];
 for(let terrain=1;terrain<=4;terrain++)if(terrain!==primary){const distance=nearestTerrain(x,y,terrain);if(distance<=9)candidates.push([terrain,distance]);}
 candidates.sort((a,b)=>a[1]-b[1]);
 if(candidates.length){const [terrain,distance]=candidates[0], threshold=(10-distance)*.09;
  if(noise(x,y)+.26<threshold)grid[y][x]=terrain;}
 // Coastal sand/dirt creates a gentle shoreline before the water tile.
 const coast=nearestTerrain(x,y,0,6);
 if(primary!==3&&coast<=5&&noise(x+31,y-17)<(6-coast)*.12)grid[y][x]=1;
}
function clearSquare(x,y,r){for(let dy=-r;dy<=r;dy++)for(let dx=-r;dx<=r;dx++)if(!isLand(x+dx,y+dy))return false;return true;}
let landing=null,score=Infinity;
for(let y=20;y<480;y++)for(let x=20;x<480;x++)if((x-100)**2+(y-135)**2<score&&clearSquare(x,y,11)){score=(x-100)**2+(y-135)**2;landing=[x,y];}
assert(landing,'No continental landing area');
const [lx,ly]=landing;
// Landing remains an ordinary natural clearing: no square arena/platform.
// Race settlements distributed across the Americas, Africa, Europe, Asia and Oceania.
const requests=[['Human',100,135],['Tsujin',265,100],['Demigod',290,140],['Saiyan',380,150],['Half Saiyan',385,160],['Legendary Saiyan',370,135],['Heran',365,190],['Android',405,155],['Bio-Android',150,310],['Spirit Doll',300,175],['Kai',345,130],['Majin',160,350],['Namekian',275,285],['Alien',425,370],['Kanassan',430,365],['Demon',285,215],['Makyo',140,330],['Frost Lord',350,65],['Ancient Namekian',285,300],['Ancient Progenitor',440,380]];
const spawns=[];
for(const[race,ax,ay]of requests){let best=null,distance=Infinity;for(let y=3;y<497;y++)for(let x=3;x<497;x++){
 const d=(x-ax)**2+(y-ay)**2;if(d>=distance||!clearSquare(x,y,3)||Math.abs(x-lx)<15&&Math.abs(y-ly)<15||spawns.some(([,sx,sy])=>(x-sx)**2+(y-sy)**2<100))continue;
 distance=d;best=[x,y];}assert(best,`No land for ${race}`);const[x,y]=best;
 // Spawn markers sit directly on the local biome instead of tiled plazas.
 const terrain=grid[y][x];
 palette.push([palette[terrain][0],'#ffd174',`/obj/Spawn{name = "${race}"; desc = "Super Terra - ${race}"}`]);grid[y][x]=palette.length-1;spawns.push([race,x,y]);}
// Sparse vegetation only on grass, avoiding landing and spawn clearings.
let seed=202609;for(let y=0;y<500;y++)for(let x=0;x<500;x++){seed=(Math.imul(seed,1664525)+1013904223)>>>0;if(grid[y][x]===2&&seed/4294967296<.018)grid[y][x]=7;}
let water=0;for(let y=0;y<500;y++)for(let x=0;x<500;x++){assert((grid[y][x]===0)===(sourceGrid[y][x]===0),'Coastline changed');if(grid[y][x]===0)water++;}
const alphabet='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',key=i=>'a'+alphabet[i];
assert(palette.length<52);
const defs=palette.map(([t,,o],i)=>`"${key(i)}" = (${o?o+',':''}${t},/area/SuperEarth)`).join('\n');
const text=defs+'\n\n(1,1,1) = {"\n'+grid.map(r=>r.map(key).join('')).join('\n')+'\n"}\n';
if(fs.existsSync(out)){const backup=path.join(root,'tmp/SuperEarthBeforeRealistic.dmm');fs.mkdirSync(path.dirname(backup),{recursive:true});if(!fs.existsSync(backup))fs.copyFileSync(out,backup);}
fs.writeFileSync(out,text);
const report={landing:[lx+1,500-ly],waterPercent:water/2500,spawns:spawns.map(([r,x,y])=>[r,x+1,500-y]),notes:'Landing uses natural terrain; biome transitions use irregular 6-9 tile bands.'};
fs.writeFileSync(path.join(root,'docs/Maps/SuperEarthSpawns.json'),JSON.stringify(report,null,2)+'\n');
const env=fs.readFileSync(path.join(root,'DU.dme'),'utf8').replace(/^#include\s+"[^"\r\n]+\.dmm"\s*$/gm,'');fs.writeFileSync(path.join(root,'SuperEarthEditor.dme'),env+'\n#include "src\\Maps\\SuperEarth.dmm"\n');
let svg='<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1060" viewBox="0 0 500 530"><rect width="500" height="530" fill="#142133"/>';
for(let y=0;y<500;y++){let s=0;for(let x=1;x<=500;x++)if(x===500||grid[y][x]!==grid[y][s]){svg+=`<rect x="${s}" y="${y}" width="${x-s}" height="1" fill="${palette[grid[y][s]][1]}"/>`;s=x;}}
for(const[,x,y]of spawns)svg+=`<circle cx="${x+.5}" cy="${y+.5}" r="2" fill="#ffd174"/>`;
svg+='<text x="12" y="520" font-family="sans-serif" font-size="11" fill="white">SUPER TERRA — geografia baseada na referencia</text></svg>';
fs.writeFileSync(path.join(root,'docs/Maps/SuperEarthOverview.svg'),svg);
console.log(JSON.stringify(report));
