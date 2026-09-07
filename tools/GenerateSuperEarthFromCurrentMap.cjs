// Extract current Earth; --force replaces SuperEarth and keeps a first backup.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),out=path.join(root,'src/Maps/SuperEarth.dmm');
if(fs.existsSync(path.join(root,'src/Maps/PlanetChunks/SuperEarth/SuperEarthManifest.json')))throw Error('Historical generator retired: edit Earth chunks and run tools/MapAssembly/AssemblePlanetMaps.cjs SuperEarth.');
if(fs.existsSync(out)&&!process.argv.includes('--force'))throw Error('Map exists; --force replaces it.');
const source=fs.readFileSync(path.join(root,'src/Maps/Map2018.dmm'),'utf8');
const defs=new Map([...source.matchAll(/^"([a-zA-Z]+)" = (.+)\r?$/gm)].map(m=>[m[1],m[2].trim()]));
const block=source.match(/\(1,1,1\) = \{"\r?\n([\s\S]*?)\r?\n"\}/);assert(block);
const rows=block[1].split(/\r?\n/),width=[...defs.keys()][0].length;
assert(rows.length===500&&rows.every(r=>r.length===500*width));
const original=rows.map(r=>Array.from({length:500},(_,x)=>defs.get(r.slice(x*width,(x+1)*width))));
assert(original.every(r=>r.every(Boolean)));
function atoms(v){const a=[];let start=1,depth=0,quote=null;for(let i=1;i<v.length-1;i++){const c=v[i];if(quote){if(c==='\\'){i++;continue;}if(c===quote)quote=null;continue;}if(c==='"'||c==="'"){quote=c;continue;}if(c==='{')depth++;if(c==='}')depth--;if(c===','&&!depth){a.push(v.slice(start,i));start=i+1;}}a.push(v.slice(start,-1));return a;}
const anchors=[];let portals=0;
const cells=original.map((r,row)=>r.map((v,col)=>{
 const parts=atoms(v);for(const p of parts)if(p.startsWith('/obj/Spawn{'))anchors.push({x:col+1,y:500-row,race:p.match(/name\s*=\s*"([^"]+)"/)?.[1]});
 const terrain=parts.filter(p=>p.startsWith('/turf/')&&!p.startsWith('/turf/Teleporter'));
 const kept=parts.filter(p=>{if(p.startsWith('/area')||p.startsWith('/obj/Spawn'))return false;if(p.startsWith('/turf/Teleporter')){assert(terrain.length,'Portal without underlying terrain');portals++;return false;}return true;});
 return '('+kept.join(',')+',/area/SuperEarth)';}));
const races=['Human','Tsujin','Demigod','Saiyan','Half Saiyan','Legendary Saiyan','Heran','Android','Bio-Android','Spirit Doll','Kai','Majin','Namekian','Alien','Kanassan','Demon','Makyo','Frost Lord','Ancient Namekian','Ancient Progenitor'];
const placements=[],used=new Set();
for(let i=0;i<races.length;i++){
 const race=races[i],anchor=anchors.find(s=>s.race===race)||anchors[i%anchors.length];assert(anchor);let best=null,d=Infinity;
 for(let y=Math.max(1,anchor.y-35);y<=Math.min(500,anchor.y+35);y++)for(let x=Math.max(1,anchor.x-35);x<=Math.min(500,anchor.x+35);x++){
 const parts=atoms(cells[500-y][x-1]);if(used.has(x+','+y)||parts.some(p=>p.startsWith('/obj/')||p.startsWith('/mob/')))continue;
 if(parts.filter(p=>p.startsWith('/turf/')).length!==1||!parts.some(p=>/^\/turf\/(Grass\w*|Ground\w*|Tile\w*)(\{|$)/.test(p)))continue;
 const distance=(x-anchor.x)**2+(y-anchor.y)**2;if(distance<d){best=[x,y];d=distance;}}
 assert(best,`No spawn for ${race}`);const[x,y]=best;used.add(x+','+y);
 cells[500-y][x-1]=cells[500-y][x-1].replace('(',`(/obj/Spawn{name = "${race}"; desc = "Super Terra - ${race}"},`);placements.push([race,x,y]);
}
for(let y=70;y<=90;y++)for(let x=240;x<=260;x++){assert(!used.has(x+','+y));cells[500-y][x-1]=`(/turf/${x===240||x===260||y===70||y===90?'Tile40':'Tile38'},/area/SuperEarth)`;}
const signature=v=>atoms(v).filter(p=>p.startsWith('/turf/')&&!p.startsWith('/turf/Teleporter')).join(',');
let changedTerrain=0;
for(let y=0;y<500;y++)for(let x=0;x<500;x++)if(signature(original[y][x])!==signature(cells[y][x])){changedTerrain++;assert(x>=239&&x<=259&&y>=410&&y<=430,'Terrain modified outside landing pad');}
const alphabet='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',dictionary=new Map();
function key(v){if(!dictionary.has(v)){const i=dictionary.size;assert(i<2704);dictionary.set(v,alphabet[Math.floor(i/52)]+alphabet[i%52]);}return dictionary.get(v);}
const rendered=cells.map(r=>r.map(key).join(''));
const text=[...dictionary].map(([v,k])=>`"${k}" = ${v}`).join('\n')+'\n\n(1,1,1) = {"\n'+rendered.join('\n')+'\n"}\n';
if(fs.existsSync(out)){const backup=path.join(root,'tmp/SuperEarthBeforeEarthBase.dmm');fs.mkdirSync(path.dirname(backup),{recursive:true});if(!fs.existsSync(backup))fs.copyFileSync(out,backup);}
fs.writeFileSync(out,text);
const env=fs.readFileSync(path.join(root,'DU.dme'),'utf8').replace(/^#include\s+"[^"\r\n]+\.dmm"\s*$/gm,'');
fs.writeFileSync(path.join(root,'SuperEarthEditor.dme'),env+'\n#include "src\\Maps\\SuperEarth.dmm"\n');
function color(v){const t=signature(v);if(/Water/.test(t))return '#346c94';if(/Snow|Ice/.test(t))return '#dce6eb';if(/Grass/.test(t))return '#78a55b';if(/Wall|Roof/.test(t))return '#465362';if(/Tile|Bridge/.test(t))return '#b7ac9e';return '#ac956a';}
let svg='<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1100" viewBox="0 0 500 550"><rect width="500" height="550" fill="#152333"/>';
for(let y=0;y<500;y++){const colors=cells[y].map(color);let s=0;for(let x=1;x<=500;x++)if(x===500||colors[x]!==colors[s]){svg+=`<rect x="${s}" y="${y}" width="${x-s}" height="1" fill="${colors[s]}"/>`;s=x;}}
for(const[,x,y]of placements)svg+=`<circle cx="${x-.5}" cy="${500-y+.5}" r="2" fill="#ffcf64"/>`;
svg+='<text x="15" y="520" fill="white" font-family="sans-serif" font-size="13">SUPER TERRA — BASE: TERRA ATUAL</text><text x="15" y="540" fill="#bdcbd8" font-family="sans-serif" font-size="8">Planta dos terrenos. Amarelo: spawns. Espacoporto: 250,80.</text></svg>';
fs.writeFileSync(path.join(root,'docs/Maps/SuperEarthOverview.svg'),svg);
fs.writeFileSync(path.join(root,'docs/Maps/SuperEarthSpawns.json'),JSON.stringify({source:'src/Maps/Map2018.dmm',sourceZ:1,changedTerrain,removedPortalTiles:portals,spawns:placements},null,2)+'\n');
console.log(JSON.stringify({placements,changedTerrain,portals,keys:dictionary.size}));
