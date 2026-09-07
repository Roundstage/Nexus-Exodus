'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root,loadPlanet}=require('./PlanetChunks.cjs'),{parse,splitOutside,hash}=require('./Dmm.cjs');
const {naturalLand,riverWater}=require('./EarthNaturalHydrology.cjs');
function run({preview=process.argv.includes('--preview'),natural=fs.existsSync(path.join(root,'docs/Maps/EarthNaturalLandmarks.json'))}={}){
 const stage=natural?'EarthNaturalLandmarks':'EarthWilderness';
 const folder=path.join(root,preview?'.codex-tmp/'+stage:'docs/Maps');
 const report=JSON.parse(fs.readFileSync(path.join(folder,stage+'.json'))),neighborhood=JSON.parse(fs.readFileSync(path.join(folder,'EarthNeighborhood.json'))),registry=JSON.parse(fs.readFileSync(path.join(folder,'CityBuildings.json')));
 const mapFile=path.join(root,preview?'.codex-tmp/'+stage+'/SuperEarth.dmm':'src/Maps/SuperEarth.dmm');
 const map=parse(fs.readFileSync(mapFile,'utf8'));
 const backup=path.join(root,'docs/Maps/RebuildBaseline/BeforeEarthWilderness/SuperEarth.dmm');
 const approved=parse(fs.readFileSync(fs.existsSync(backup)?backup:path.join(root,'src/Maps/SuperEarth.dmm'),'utf8'));
 const baseline=parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/SuperEarth.dmm'),'utf8'));
 assert.equal(hash(fs.readFileSync(mapFile)),report.outputHash);
 assert.equal(hash(fs.readFileSync(path.join(root,preview?'.codex-tmp/'+stage+'/CityInteriors.dmm':'src/Maps/CityInteriors.dmm'))),report.interiorHash);
 assert.equal(hash(fs.readFileSync(path.join(folder,'CityBuildings.json'))),report.buildingDataHash);
 if(!preview)assert.deepEqual(loadPlanet('SuperEarth').chunkHashes,report.chunkHashes);
 const type=s=>splitOutside(s,',').at(-2).split('{')[0],at=(x,y)=>map.grid[500-y][x-1],key=(x,y)=>`${x},${y}`,id=(x,y)=>(y-1)*500+x-1;
 const inside=([a,b,c,d],x,y)=>x>=a&&x<=c&&y>=b&&y<=d;
 const wet=t=>['/turf/EarthRiver','/turf/EarthRiverFall','/turf/EarthNaturalFall','/turf/EarthNaturalFoam','/turf/EarthOceanBoundary'].includes(t)||t.startsWith('/turf/EarthStreet/Bridge');
 const asphalt=t=>t==='/turf/EarthStreet'||t==='/turf/EarthBridge'||t==='/turf/EarthFloor/Road'||/^\/turf\/EarthStreet\/(Lane|Crossing|Bridge)/.test(t);
 const solid=new Uint8Array(250000),oldSpawns=[],newSpawns=[];let asphaltTiles=0,forestObjects=0;
 for(let y=1;y<=500;y++)for(let x=1;x<=500;x++){
  const stack=at(x,y),atoms=splitOutside(stack,','),t=type(stack),was=type(baseline.grid[500-y][x-1]);
  const dense=a=>/^\/turf\/(EarthBuildingStructure|CityBuildingFootprint|EarthRoof|EarthRiverRock|EarthRiverFall|EarthRiver$|EarthOceanBoundary|Wall12|Water2|WaterFall)/.test(a)||/^\/turf\/EarthStreet\/Bridge\/(North|South)$/.test(a)||/^\/obj\/(EarthFurnishing|EarthDirectory|Trees\/|Turfs\/Rock1)/.test(a)||a.startsWith('/obj/EarthStreetFixture')&&!a.endsWith('/Flowers');
  solid[id(x,y)]=Number(wet(t)&&!t.startsWith('/turf/EarthStreet/Bridge')||t.startsWith('/turf/EarthNaturalRoof')||atoms.some(a=>dense(a.split('{')[0])));
  for(const atom of atoms)if(atom.startsWith('/obj/Spawn'))newSpawns.push({x,y,atom});
  for(const atom of splitOutside(approved.grid[500-y][x-1],','))if(atom.startsWith('/obj/Spawn'))oldSpawns.push({x,y,atom});
  forestObjects+=atoms.filter(a=>a.startsWith('/obj/Trees')).length;
  if(asphalt(t)){asphaltTiles++;assert(inside(report.cityBounds,x,y),`Road left in the wilderness ${x},${y}`);assert(naturalLand(x,y)||neighborhood.bridges.some(b=>inside(b.bounds,x,y)),`Ocean road remains ${x},${y}`);}
  assert(t!=='/turf/EarthBridge','Legacy regional causeway remains');
  if(was==='/turf/WaterFall')assert(['/turf/EarthRiverFall','/turf/EarthNaturalFall'].includes(t),`Waterfall removed ${x},${y}`);
  if(natural)assert(!/Steps|Stairs/.test(t),`Rejected terrain stairs remain ${x},${y}`);
  else if(was==='/turf/Stairs_Grass')assert.equal(t,'/turf/EarthRiverSteps',`Terrain stairway removed ${x},${y}`);
  if(x<=8||x>=493||y<=8||y>=493)assert.equal(t,'/turf/EarthOceanBoundary');
  if(['/turf/GroundSnow','/turf/GroundIce2'].includes(t))assert(y>=400);
 }
 assert.deepEqual(newSpawns,oldSpawns,'Latest edited spawn positions must survive');assert.equal(newSpawns.length,20);
 for(let y=352;y<=372;y++)for(let x=91;x<=111;x++)assert(!solid[id(x,y)]&&!wet(type(at(x,y))),'Arrival park obstructed');
 // Land components are independent: restoring oceans must not force another
 // road between continents merely to satisfy a global walkability test.
 const components=new Int32Array(250000).fill(-1),sizes=[];
 for(let start=0;start<250000;start++)if(!solid[start]&&components[start]<0){
  const number=sizes.length,queue=[start];components[start]=number;
  for(let i=0;i<queue.length;i++){const n=queue[i],x=n%500,y=Math.floor(n/500);for(const v of [x?n-1:-1,x<499?n+1:-1,y?n-500:-1,y<499?n+500:-1])if(v>=0&&!solid[v]&&components[v]<0){components[v]=number;queue.push(v);}}
  sizes.push(queue.length);
 }
 const city=components[id(101,362)];
 for(const spawn of newSpawns)assert(!solid[id(spawn.x,spawn.y)]&&sizes[components[id(spawn.x,spawn.y)]]>=100,`Spawn trapped ${spawn.x},${spawn.y}`);
 for(const [x,y]of [[340,395],[135,92],[280,445]])assert(components[id(x,y)]!==city,'Continents are still connected by a walkable causeway');
 const occupied=new Set(),outposts=new Set(report.outposts.map(b=>b.id));
 for(const b of neighborhood.buildings){
  const [a,y,c,d]=b.bounds;
  for(let yy=y;yy<=d;yy++)for(let x=a;x<=c;x++){
   assert(!occupied.has(key(x,yy)),'Overlapping buildings');occupied.add(key(x,yy));
   assert.equal(at(x,yy),approved.grid[500-yy][x-1],`Approved house footprint changed ${b.name} ${x},${yy}`);
  }
  for(let x=a;x<=c;x++)for(const yy of [y-1,y-2])assert(!solid[id(x,yy)]&&components[id(x,yy)]===components[id(...b.door)],`Obstructed frontage ${b.name}`);
  if(!outposts.has(b.id))assert.equal(components[id(...b.door)],city,`City destination disconnected ${b.name}`);
  else assert(sizes[components[id(...b.door)]]>=100,`Shelter is trapped ${b.name}`);
 }
 assert.equal(neighborhood.buildings.length,natural?61:70);assert.equal(outposts.size,natural?0:6);
 assert.equal(registry.buildings.filter(b=>b.planet==='SuperEarth').length,natural?29:38);
 // Independently reconstruct the complete original river union. The approved
 // city reach has its own course; every other source/segment/plunge pool is wet.
 const geography=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/SuperEarthSpawns.json'))),rivers=riverWater(geography.rivers,geography.waterfalls);
 let riverTiles=0;
 for(const position of rivers.mask){const [x,y]=position.split(',').map(Number);if(x>=112&&x<=174&&y>=260&&y<=410)continue;assert(wet(type(at(x,y))),`Grass/road interrupts a river at ${position}`);riverTiles++;}
 for(const section of neighborhood.riverRevision.channel)for(let x=section.left;x<=section.right;x++)assert(wet(type(at(x,section.y))),`City river interrupted ${x},${section.y}`);
 for(const bridge of neighborhood.bridges){const [a,b,c,d]=bridge.bounds;for(let y=b;y<=d;y++)for(let x=a;x<=c;x++)assert(type(at(x,y)).startsWith('/turf/EarthStreet/Bridge'),`Incomplete city bridge ${x},${y}`);}
 // A pure-water flood fill from each lake must reach the open ocean; roads
 // outside the two city bridge spans are never interpreted as water.
 const waterSeen=new Set(),queue=[[10,10]];waterSeen.add(key(10,10));
 for(let i=0;i<queue.length;i++){const [x,y]=queue[i];for(const [xx,yy]of [[x-1,y],[x+1,y],[x,y-1],[x,y+1]]){const k=key(xx,yy);if(xx>=1&&xx<=500&&yy>=1&&yy<=500&&!waterSeen.has(k)&&wet(type(at(xx,yy)))){waterSeen.add(k);queue.push([xx,yy]);}}}
 for(const river of geography.rivers)assert(waterSeen.has(key(...river[0])),`Source lake cut off from ocean ${river[0]}`);
 const result={mode:preview?'preview':'applied',cityBuildings:report.cityBuildings,outposts:outposts.size,accessibleBuildings:report.accessibleBuildings,spawnsPreservedFromLatestEditorSave:20,clearArrivalTiles:441,asphaltTiles,asphaltOutsideCity:0,intercontinentalRoads:0,riverUnionTilesChecked:riverTiles,allThreeSourcesReachOcean:true,cityBridges:2,approvedHouseFootprintsPreserved:true,forestObjects,landComponents:sizes.filter(n=>n>=100).length,cityWalkableTiles:sizes[city],outputHash:report.outputHash};
 fs.writeFileSync(path.join(folder,'EarthWildernessChecks.json'),JSON.stringify(result,null,2)+'\n');console.log(result);return result;
}
module.exports={run};if(require.main===module)run();
