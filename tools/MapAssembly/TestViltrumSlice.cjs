'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {loadPlanet,root}=require('./PlanetChunks.cjs');
const {splitOutside}=require('./Dmm.cjs');
const {grid}=loadPlanet('Viltrum'),spec=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/ViltrumSlice.json')));
// Conservative walking collision model for the exact types in this slice.
// Runtime smoke independently checks the actual BYOND density of the arrival area.
function blocked(x,y){
 if(x<1||x>500||y<1||y>500)return true;
 const atoms=splitOutside(grid[500-y][x-1],',').map(a=>a.split('{')[0]);
 return atoms.some(a=>a.startsWith('/turf/CityBuildingFootprint')||a.startsWith('/turf/ViltrumRoof')||a.startsWith('/turf/ViltrumOcean')||a.startsWith('/obj/ViltrumCapitalFurnishing')||(a.startsWith('/obj/ViltrumFurnishing')&&a!=='/obj/ViltrumFurnishing/LandingBeacon')||a.startsWith('/obj/ViltrumConsole')||['/turf/Wall21','/turf/Water2','/obj/Turfs/Rock1','/obj/Turfs/Plant37','/obj/Trees/Dead_Tree_2'].includes(a));
}
const id=(x,y)=>(y-1)*500+x-1;
function walk(start,obstruction=()=>false){
 const seen=new Uint8Array(250000),queue=[start];seen[id(...start)]=1;
 for(let n=0;n<queue.length;n++){
  const [x,y]=queue[n];
  for(const [nx,ny]of[[x+1,y],[x-1,y],[x,y+1],[x,y-1]])if(!blocked(nx,ny)&&!obstruction(nx,ny)&&!seen[id(nx,ny)]){seen[id(nx,ny)]=1;queue.push([nx,ny]);}
 }
 return {seen,count:queue.length};
}
for(let x=240;x<=260;x++)for(let y=68;y<=88;y++)assert(!blocked(x,y),`Landing obstructed ${x},${y}`);
let spawns=[];for(let row=0;row<500;row++)for(let col=0;col<500;col++)if(grid[row][col].includes('/obj/Spawn'))spawns.push([col+1,500-row]);
assert.deepEqual(spawns,[[250,250]],'Exactly one racial spawn at the preserved coordinate');
for(const start of [[250,78],[250,250]]){
 const {seen}=walk(start);
 for(const p of spec.points)assert(seen[id(p.x,p.y)],`Unreachable POI: ${p.name}`);
 for(const [x1,y1,x2,y2]of spec.publicRooms)for(let x=x1;x<=x2;x++)for(let y=y1;y<=y2;y++)if(!blocked(x,y))assert(seen[id(x,y)],`Unreachable public room tile ${x},${y}`);
}
const alternate=walk([250,78],(x,y)=>x>=245&&x<=255&&y>=175&&y<=185);
for(const p of spec.points)assert(alternate.seen[id(p.x,p.y)],`Axis blockage isolates ${p.name}`);
const c=spec.combatClear;assert(c.x2-c.x1+1>=28&&c.y2-c.y1+1>=28);
for(let x=c.x1;x<=c.x2;x++)for(let y=c.y1;y<=c.y2;y++)assert(!blocked(x,y),`Combat floor obstruction ${x},${y}`);
const seams=[];
for(const y of [100,200,300]){
 let runs=0,open=false;
 for(let x=201;x<=300;x++) {const crossing=!blocked(x,y)&&!blocked(x,y+1);if(crossing&&!open)runs++;open=crossing;}
 // Separate main and lateral approaches even when terrain forms one continuous run.
 const approaches=[[209,215],[245,255],[285,291]].filter(([a,b])=>Array.from({length:b-a+1},(_,i)=>a+i).every(x=>!blocked(x,y)&&!blocked(x,y+1)));
 assert(approaches.length>=2,`Fewer than two wide approaches at Y=${y}`);seams.push({y,walkableRuns:runs,wideApproaches:approaches.length});
}
const coverage=[];
for(const row of [2,3]){let dense=0;for(let y=(4-row)*100+1;y<=(5-row)*100;y++)for(let x=201;x<=300;x++)if(blocked(x,y))dense++;assert(dense/10000<.30);coverage.push({chunk:`${'ABCDE'[row]}3`,densePercent:dense/100});}
const result={landingClearTiles:441,spawn:spawns[0],requiredPois:spec.points.length,cardinalReachable:walk([250,78]).count,alternateRouteAfterAxisBlockage:true,publicRooms:spec.publicRooms.length,combatDimensions:[c.x2-c.x1+1,c.y2-c.y1+1],seams,coverage,manualReview:'Deferred by user; flight, combat, lighting and boundaries not certified.'};
fs.writeFileSync(path.join(root,'docs/Maps/ViltrumSliceChecks.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result,null,2));
