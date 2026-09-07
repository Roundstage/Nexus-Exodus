'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {loadPlanet,root}=require('./PlanetChunks.cjs'),{splitOutside}=require('./Dmm.cjs');
const {grid}=loadPlanet('Viltrum'),spec=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/ViltrumCapital.json')));
const wholeWorld=process.argv.includes('--wilderness');
if(wholeWorld){
 const wilderness=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/ViltrumWilderness.json')));
 for(const key of ['points','publicRooms','buildings','combatSpaces'])spec[key].push(...wilderness[key]);
 spec.phase=4;
}
require('./CityBuildingChecks.cjs').adaptSpec(spec,'Viltrum');
const id=(x,y)=>(y-1)*500+x-1,solid=new Uint8Array(250000);
const legacy=['/turf/Wall21','/turf/Water2','/obj/Turfs/Rock1','/obj/Turfs/Plant37','/obj/Trees/Dead_Tree_2'];
const collision=new Map();
for(let y=1;y<=500;y++)for(let x=1;x<=500;x++){
 const stack=grid[500-y][x-1];
 if(!collision.has(stack))collision.set(stack,splitOutside(stack,',').map(a=>a.split('{')[0]).some(a=>a.startsWith('/turf/CityBuildingFootprint')||a.startsWith('/turf/ViltrumRoof')||a.startsWith('/turf/ViltrumOcean')||a.startsWith('/obj/ViltrumCapitalFurnishing')||a.startsWith('/obj/ViltrumConsole')||(a.startsWith('/obj/ViltrumFurnishing')&&a!=='/obj/ViltrumFurnishing/LandingBeacon')||legacy.includes(a)));
 solid[id(x,y)]=Number(collision.get(stack));
}
function walk(x,y,closed=[]){
 const blocked=solid.slice();for(const [cx,cy]of closed)blocked[id(cx,cy)]=1;
 assert(!blocked[id(x,y)],'Start cannot be dense');
 const seen=new Uint8Array(250000),queue=new Int32Array(250000);let size=1;queue[0]=id(x,y);seen[queue[0]]=1;
 for(let head=0;head<size;head++){
  const p=queue[head],px=p%500,py=Math.floor(p/500);
  for(const n of [px>0?p-1:-1,px<499?p+1:-1,py>0?p-500:-1,py<499?p+500:-1])if(n>=0&&!blocked[n]&&!seen[n]){seen[n]=1;queue[size++]=n;}
 }
 return {seen,count:size};
}
const base=walk(250,78);
for(const start of [[250,78],[250,250]]){
 const {seen}=walk(...start);
 for(const p of spec.points)assert(seen[id(p.x,p.y)],`Unreachable ${p.name}`);
 for(const room of spec.publicRooms){const [a,b,c,d]=room;for(let y=b;y<=d;y++)for(let x=a;x<=c;x++)if(!solid[id(x,y)])assert(seen[id(x,y)],`Isolated public tile ${x},${y}`);}
}
for(const building of spec.buildings){
 const [a,b,c,d]=building.bounds;
 for(const [x,y]of building.entrances){
  const doorway=Array.from({length:5},(_,i)=>(x===a||x===c)?[x,y+i-2]:[x+i-2,y]);
  for(const p of doorway)assert(!solid[id(...p)],`Doorway blocked: ${building.name} ${p}`);
  const {seen}=walk(250,78,doorway);
  assert(seen[id(Math.floor((a+c)/2),Math.floor((b+d)/2))],`One entrance blockage isolates ${building.name}`);
 }
}
for(const space of spec.combatSpaces){
 const [a,b,c,d]=space.bounds;assert(c-a+1>=space.minimum&&d-b+1>=space.minimum);
 for(let y=b;y<=d;y++)for(let x=a;x<=c;x++)assert(!solid[id(x,y)],`Combat obstruction: ${space.name} ${x},${y}`);
 for(const [x,y]of space.exits||[])assert(base.seen[id(x,y)],`Arena exit inaccessible: ${x},${y}`);
}
const coverage=spec.districts.map(({chunk,bounds,densityLimit})=>{const [a,b,c,d]=bounds;let dense=0;for(let y=b;y<=d;y++)for(let x=a;x<=c;x++)dense+=solid[id(x,y)];assert(dense/10000<densityLimit,`${chunk} exceeds density budget`);return {chunk,densePercent:dense/100};});
// Every newly authored district has two separated wide crossings on every edge.
const seams=[];
for(const {chunk,bounds}of spec.districts){const [a,b,c,d]=bounds;
 for(const edge of ['west','east','south','north']){
  const vertical=edge==='west'||edge==='east',fixed=edge==='west'?a:edge==='east'?c:edge==='south'?b:d;
  const neighbor=fixed+(['west','south'].includes(edge)?-1:1);if(neighbor<1||neighbor>500)continue;
  const start=vertical?b:a,windows=[];
  for(let offset=0;offset<=93;offset++){
   const valid=Array.from({length:7},(_,i)=>{const t=start+offset+i;return vertical?[[fixed,t],[neighbor,t]]:[[t,fixed],[t,neighbor]];}).flat().every(([x,y])=>base.seen[id(x,y)]&&!solid[id(x,y)]);
   if(valid&&(!windows.length||start+offset-windows.at(-1)>=14))windows.push(start+offset);
  }
  // Unauthored coastal neighbors can remain ocean; document those deferred edges.
  const adjacentChunk=vertical?`${chunk[0]}${Number(chunk[1])+(edge==='west'?-1:1)}`:`${'ABCDE'['ABCDE'.indexOf(chunk[0])+(edge==='north'?-1:1)]}${chunk[1]}`;
  const active=spec.districts.some(v=>v.chunk===adjacentChunk)||['C3','D3','E3'].includes(adjacentChunk);
  if(active)assert(windows.length>=2,`${chunk} ${edge}: fewer than two seven-tile crossings`);
  seams.push({chunk,edge,active,sevenTileCrossings:windows.length});
 }
}
const recovered=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/ManualOutputDelta.json')));
for(const {x,y,output}of recovered)assert.equal(grid[500-y][x-1],output,`Recovered manual tile changed ${x},${y}`);
const worldSeams=[];
if(wholeWorld){
 for(let y=1;y<=500;y++)for(let x=1;x<=500;x++)if(x<=8||x>=493||y<=8||y>=493)assert.equal(grid[500-y][x-1],'/turf/ViltrumOcean/Boundary,/area/Viltrum',`Missing boundary ${x},${y}`);
 for(const vertical of [true,false])for(let boundary=100;boundary<=400;boundary+=100)for(let segment=0;segment<5;segment++){
  const starts=[];
  for(let offset=1;offset<=96;offset++){
   const open=Array.from({length:5},(_,i)=>segment*100+offset+i).every(t=>[boundary,boundary+1].every(f=>{const x=vertical?f:t,y=vertical?t:f;return !solid[id(x,y)]&&base.seen[id(x,y)];}));
   if(open&&(!starts.length||offset-starts.at(-1)>=10))starts.push(offset);
  }
  assert(starts.length>=2,`World seam ${vertical?'X':'Y'}=${boundary} segment ${segment}: needs two separate five-tile crossings`);
  worldSeams.push({axis:vertical?'X':'Y',boundary,segment:segment+1,fiveTileCrossings:starts.length});
 }
}
const result={phase:spec.phase,publicBuildings:spec.buildings.length,requiredDestinations:spec.points.length,reachableTiles:base.count,allPublicFloorTilesReachable:true,eachPublicDoorwayCanBeBlockedWithoutIsolatingBuilding:true,recoveredManualTilesPreserved:recovered.length,stormBoundaryTiles:wholeWorld?250000-484*484:0,combatSpaces:spec.combatSpaces,coverage,seams,worldSeams,manualReview:spec.review};
fs.writeFileSync(path.join(root,`docs/Maps/Viltrum${wholeWorld?'World':'Capital'}Checks.json`),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result,null,2));
