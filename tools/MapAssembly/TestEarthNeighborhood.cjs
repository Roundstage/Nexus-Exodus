'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root,loadPlanet}=require('./PlanetChunks.cjs'),{parse,splitOutside,hash}=require('./Dmm.cjs');
if(fs.existsSync(path.join(root,'docs/Maps/EarthNaturalLandmarks.json'))){
 const result=require('./TestEarthNaturalLandmarks.cjs').run();
 fs.writeFileSync(path.join(root,process.argv.includes('--preview')?'.codex-tmp/EarthNaturalLandmarks':'docs/Maps','EarthNeighborhoodChecks.json'),JSON.stringify(result,null,2)+'\n');process.exit(0);
}
if(fs.existsSync(path.join(root,'docs/Maps/EarthWilderness.json'))){
 const result=require('./TestEarthWilderness.cjs').run();
 const target=path.join(root,process.argv.includes('--preview')?'.codex-tmp/EarthWilderness':'docs/Maps','EarthNeighborhoodChecks.json');
 fs.writeFileSync(target,JSON.stringify(result,null,2)+'\n');process.exit(0);
}
const preview=process.argv.includes('--preview'),folder=path.join(root,preview?'.codex-tmp/EarthNeighborhood':'docs/Maps');
const report=JSON.parse(fs.readFileSync(path.join(folder,'EarthNeighborhood.json'))),buildings=JSON.parse(fs.readFileSync(path.join(folder,'CityBuildings.json')));
const surface=preview?parse(fs.readFileSync(path.join(folder,'SuperEarth.dmm'),'utf8')):loadPlanet('SuperEarth');
const interior=parse(fs.readFileSync(path.join(root,preview?'.codex-tmp/EarthNeighborhood/CityInteriors.dmm':'src/Maps/CityInteriors.dmm'),'utf8'));
const baseline=parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/SuperEarth.dmm'),'utf8'));
assert.equal(hash(fs.readFileSync(path.join(root,preview?'.codex-tmp/EarthNeighborhood/SuperEarth.dmm':'src/Maps/SuperEarth.dmm'))),report.outputHash,'Surface and neighborhood report differ');
assert.equal(hash(fs.readFileSync(path.join(root,preview?'.codex-tmp/EarthNeighborhood/CityInteriors.dmm':'src/Maps/CityInteriors.dmm'))),report.interiorHash,'Interior report is stale');
assert.equal(hash(fs.readFileSync(path.join(folder,'CityBuildings.json'))),report.buildingDataHash,'Building registry report is stale');
if(!preview)assert.deepEqual(surface.chunkHashes,report.chunkHashes,'Source chunks and neighborhood report differ');
const atoms=(x,y)=>splitOutside(surface.grid[500-y][x-1],','),type=(x,y)=>atoms(x,y).at(-2).split('{')[0],id=(x,y)=>(y-1)*500+x-1;
const wet=t=>['/turf/EarthRiver','/turf/Water2','/turf/EarthRiverFall','/turf/WaterFall','/turf/EarthOceanBoundary','/turf/EarthBridge'].includes(t)||t.startsWith('/turf/EarthStreet/Bridge');
const dense=atom=>/^\/turf\/(EarthBuildingStructure|CityBuildingFootprint|EarthRoof|ViltrumRoof|EarthRiverRock|EarthRiverFall|EarthRiver$|EarthOceanBoundary|Wall12|Water2|WaterFall)/.test(atom)||/^\/turf\/EarthStreet\/Bridge\/(North|South)$/.test(atom)||/^\/obj\/(EarthFurnishing|EarthDirectory|Trees\/|Turfs\/Rock1)/.test(atom)||atom.startsWith('/obj/EarthStreetFixture')&&!atom.endsWith('/Flowers');
const solid=new Uint8Array(250000),spawns=[],oldSpawns=[];let waterRetained=0;
const reshaped=new Set(report.riverRevision.changes.map(p=>`${p.x},${p.y}`));
for(let y=1;y<=500;y++)for(let x=1;x<=500;x++){
 const here=atoms(x,y),old=splitOutside(baseline.grid[500-y][x-1],','),t=type(x,y);
 solid[id(x,y)]=Number(here.some(a=>dense(a.split('{')[0])));
 for(const atom of here)if(atom.startsWith('/obj/Spawn'))spawns.push({x,y,atom});
 for(const atom of old)if(atom.startsWith('/obj/Spawn'))oldSpawns.push({x,y,atom});
 if(old.at(-2)==='/turf/Water2'&&!reshaped.has(`${x},${y}`)){assert(wet(t),`Water erased outside authored river corridor ${x},${y}`);waterRetained++;}
 if(old.at(-2)==='/turf/WaterFall')assert.equal(t,'/turf/EarthRiverFall',`Waterfall removed ${x},${y}`);
 if(old.at(-2)==='/turf/Stairs_Grass')assert.equal(t,'/turf/EarthRiverSteps',`Terrain steps removed ${x},${y}`);
}
assert.deepEqual(spawns,oldSpawns);assert.equal(spawns.length,20);
const seen=new Uint8Array(250000),queue=[id(101,362)];seen[queue[0]]=1;
for(let i=0;i<queue.length;i++){const n=queue[i],x=n%500,y=Math.floor(n/500);for(const q of [x?n-1:-1,x<499?n+1:-1,y?n-500:-1,y<499?n+500:-1])if(q>=0&&!seen[q]&&!solid[q]){seen[q]=1;queue.push(q);}}
for(const spawn of spawns)assert(seen[id(spawn.x,spawn.y)]&&!solid[id(spawn.x,spawn.y)],`Spawn disconnected ${spawn.x},${spawn.y}`);
for(let y=352;y<=372;y++)for(let x=91;x<=111;x++)assert(!solid[id(x,y)]&&!wet(type(x,y)),`Arrival park obstructed ${x},${y}`);
const footprints=new Set();
for(const building of report.buildings){
 const [a,b,c,d]=building.bounds;
 for(let y=b;y<=d;y++)for(let x=a;x<=c;x++){const position=id(x,y);assert(!footprints.has(position),'Overlapping buildings');footprints.add(position);assert.equal(type(x,y),'/turf/EarthBuildingStructure',`Building cuts into road/water ${building.name}`);assert(atoms(x,y).at(-2).includes(`"${building.style}_${x-a}_${y-b}"`),'Structural art crop/anchor mismatch');}
 for(let x=a;x<=c;x++)for(const y of [b-1,b-2])assert(!solid[id(x,y)]&&seen[id(x,y)],`Front sidewalk blocked ${building.name} ${x},${y}`);
 assert(seen[id(...building.door)],`Unreachable doorway ${building.name}`);
}
// Every river cross-section retains its minimum width; rows overlap and connect.
let last;
for(const section of report.riverRevision.channel){
 assert(section.right-section.left+1>=7);
 if(last)assert(Math.max(last.left,section.left)<=Math.min(last.right,section.right),'Disconnected river rows');
 for(let x=section.left;x<=section.right;x++)assert(wet(type(x,section.y)),`River interrupted at ${x},${section.y}`);
 last=section;
}
for(const [section,y]of [[report.riverRevision.channel[0],259],[report.riverRevision.channel.at(-1),411]]){
 assert(Array.from({length:section.right-section.left+1},(_,i)=>section.left+i).some(x=>wet(type(x,y))),'Authored river does not join the preserved upstream/downstream terrain');
}
for(const bridge of report.bridges){
 const [a,b,c,d]=bridge.bounds,cy=(b+d)/2;
 for(const [x,y]of bridge.abutments){const t=splitOutside(baseline.grid[500-y][x-1],',').at(-2);assert(t!=='/turf/Water2','Abutment must rest on land');}
 for(let y=b;y<=d;y++)for(let x=a;x<=c;x++)assert(type(x,y).startsWith('/turf/EarthStreet/Bridge'),`Broken bridge deck ${x},${y}`);
 assert(seen[id(a,cy)]&&seen[id(c,cy)],'Bridge approach disconnected');
}
let interiorTiles=0;
for(const b of buildings.buildings.filter(b=>b.planet==='SuperEarth')){
 const [a,y,c,d]=b.interiorBounds,walkable=new Set();
 const inside=(x,yy)=>splitOutside(interior.grid[interior.height-yy][x-1],',');
 for(let yy=y;yy<=d;yy++)for(let x=a;x<=c;x++){
  const stack=inside(x,yy);assert.equal(stack.at(-1),'/area/CityInterior/Earth');
  if(x===a||x===c||yy===y||yy===d)assert(stack.at(-2).startsWith('/turf/EarthRoof'),'Interior is not sealed');
  else if(!stack.some(v=>dense(v.split('{')[0])))walkable.add(`${x},${yy}`);
 }
 const start=b.entry.slice(0,2).join(','),visited=new Set([start]),q=[start];assert(walkable.has(start));
 for(let i=0;i<q.length;i++){const [x,yy]=q[i].split(',').map(Number);for(const [xx,y2]of [[x-1,yy],[x+1,yy],[x,yy-1],[x,yy+1]]){const k=`${xx},${y2}`;if(walkable.has(k)&&!visited.has(k)){visited.add(k);q.push(k);}}}
 assert.equal(visited.size,walkable.size,`Isolated room floor ${b.name}`);interiorTiles+=visited.size;
 for(const [x,yy]of b.exits){const stack=inside(x,yy).join(',');assert(stack.includes(`building_id = "${b.id}"`)&&stack.includes(`target_x = ${b.return[0]}`)&&stack.includes(`target_y = ${b.return[1]}`)&&stack.includes('target_z = 21'));assert(visited.has(`${x},${yy}`));}
 assert(!solid[id(...b.return)]&&seen[id(...b.return)],`Blocked return destination ${b.name}`);
 for(const prop of b.props)assert(inside(...prop.position).includes(prop.atom),`Furniture missing ${b.name}`);
}
const result={mode:preview?'preview':'applied',buildings:report.buildings.length,accessibleEarthBuildings:buildings.buildings.filter(b=>b.planet==='SuperEarth').length,spawnsPreserved:20,clearArrivalTiles:441,waterRetainedOutsideRiverCorrection:waterRetained,riverCorrections:reshaped.size,riverMinimumWidth:7,continuousRiver:true,bankToBankBridges:report.bridges.length,reachableTiles:queue.length,connectedInteriorTiles:interiorTiles,overlappingBuildings:0,blockedFrontSidewalkTiles:0};
fs.writeFileSync(path.join(folder,'EarthNeighborhoodChecks.json'),JSON.stringify(result,null,2)+'\n');console.log(result);
