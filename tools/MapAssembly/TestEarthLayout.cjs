'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root,loadPlanet}=require('./PlanetChunks.cjs'),{parse,splitOutside}=require('./Dmm.cjs');
if(fs.existsSync(path.join(root,'docs/Maps/EarthNaturalLandmarks.json'))){
 const result=require('./TestEarthNaturalLandmarks.cjs').run();
 fs.writeFileSync(path.join(root,`docs/Maps/SuperEarth${process.argv.includes('--regions')?'World':'Slice'}Checks.json`),JSON.stringify(result,null,2)+'\n');process.exit(0);
}
// The current topology deliberately separates continents. The wilderness suite
// replaces the old requirement for a walking road from every spawn to the city.
if(fs.existsSync(path.join(root,'docs/Maps/EarthWilderness.json'))){
 const result=require('./TestEarthWilderness.cjs').run();
 fs.writeFileSync(path.join(root,`docs/Maps/SuperEarth${process.argv.includes('--regions')?'World':'Slice'}Checks.json`),JSON.stringify(result,null,2)+'\n');process.exit(0);
}
const p=loadPlanet('SuperEarth'),baseline=parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/SuperEarth.dmm'),'utf8'));
const whole=process.argv.includes('--regions'),spec=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/SuperEarthSlice.json')));
if(whole){const regions=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/SuperEarthRegions.json')));for(const key of ['points','publicRooms','buildings','combatSpaces'])spec[key].push(...regions[key]);}
require('./CityBuildingChecks.cjs').adaptSpec(spec,'SuperEarth');
const neighborhood=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/EarthNeighborhood.json')));
const riverChanges=new Set(neighborhood.riverRevision.changes.map(p=>`${p.x},${p.y}`));
const turfType=atoms=>atoms.at(-2).split('{')[0];
const wet=t=>['/turf/Water2','/turf/EarthRiver','/turf/EarthRiverFall','/turf/WaterFall','/turf/EarthOceanBoundary','/turf/EarthBridge'].includes(t)||t.startsWith('/turf/EarthStreet/Bridge');
const id=(x,y)=>(y-1)*500+x-1,solid=new Uint8Array(250000),cache=new Map(),spawns=[],originalSpawns=[];let waterTiles=0,bridges=0,falls=0;
for(let row=0;row<500;row++)for(let col=0;col<500;col++){
 const stack=p.grid[row][col],old=splitOutside(baseline.grid[row][col],','),atoms=splitOutside(stack,','),turf=turfType(atoms),x=col+1,y=500-row;
 if(!cache.has(stack))cache.set(stack,atoms.map(a=>a.split('{')[0]).some(a=>a.startsWith('/turf/CityBuildingFootprint')||a.startsWith('/turf/EarthBuildingStructure')||a.startsWith('/turf/EarthRoof')||a.startsWith('/obj/EarthFurnishing')||a.startsWith('/obj/EarthStreetFixture')&&!a.endsWith('/Flowers')||a==='/obj/EarthDirectory'||a.startsWith('/obj/Trees/')||['/obj/Turfs/Rock1','/turf/Wall12','/turf/Water2','/turf/WaterFall','/turf/EarthRiver','/turf/EarthRiverFall','/turf/EarthRiverRock','/turf/EarthOceanBoundary','/turf/EarthStreet/Bridge/North','/turf/EarthStreet/Bridge/South'].includes(a)));
 solid[id(x,y)]=Number(cache.get(stack));
 for(const atom of atoms)if(atom.startsWith('/obj/Spawn'))spawns.push({x,y,atom});
 for(const atom of old)if(atom.startsWith('/obj/Spawn'))originalSpawns.push({x,y,atom});
 if(turfType(old)==='/turf/Water2'&&!riverChanges.has(`${x},${y}`)){waterTiles++;assert(wet(turf),`Water erased outside the river correction at ${x},${y}: ${turf}`);}
 if(turf==='/turf/EarthBridge'||turf.startsWith('/turf/EarthStreet/Bridge'))bridges++;
 if(turfType(old)==='/turf/WaterFall'){assert.equal(turf,'/turf/EarthRiverFall',`Waterfall removed at ${x},${y}`);falls++;}
 if(turfType(old)==='/turf/Stairs_Grass')assert.equal(turf,'/turf/EarthRiverSteps',`Terrain steps removed at ${x},${y}`);
 if(['/turf/GroundSnow','/turf/GroundIce2'].includes(turf))assert(y>=400,'Arctic terrain leaked south');
 if(turf==='/turf/Ground10')assert.equal(old.at(-2),turf,'Desert expanded into river margins or other biomes');
}
assert.deepEqual(spawns,originalSpawns,'All original spawn coordinates and atom fields must survive');assert.equal(spawns.length,20);
for(const {x,y}of spawns)assert(!solid[id(x,y)],`Blocked racial spawn ${x},${y}`);
for(let y=352;y<=372;y++)for(let x=91;x<=111;x++)assert(!solid[id(x,y)]&&!wet(turfType(splitOutside(p.grid[500-y][x-1],','))),`Arrival park obstructed ${x},${y}`);
function walk(x,y,closed=[]){
 const blocked=solid.slice();for(const [cx,cy]of closed)blocked[id(cx,cy)]=1;assert(!blocked[id(x,y)]);
 const seen=new Uint8Array(250000),queue=new Int32Array(250000);let size=1;queue[0]=id(x,y);seen[queue[0]]=1;
 for(let head=0;head<size;head++){const v=queue[head],cx=v%500,cy=Math.floor(v/500);for(const n of [cx>0?v-1:-1,cx<499?v+1:-1,cy>0?v-500:-1,cy<499?v+500:-1])if(n>=0&&!blocked[n]&&!seen[n]){seen[n]=1;queue[size++]=n;}}
 return {seen,count:size};
}
for(const start of [[101,362],[95,362]]){
 const {seen}=walk(...start);for(const {name,x,y}of spec.points)assert(seen[id(x,y)],`Unreachable Earth destination: ${name} ${x},${y}`);
 for(const [a,b,c,d]of spec.publicRooms)for(let y=b;y<=d;y++)for(let x=a;x<=c;x++)if(!solid[id(x,y)])assert(seen[id(x,y)],`Isolated room tile ${x},${y}`);
 if(whole)for(const {x,y}of spawns)assert(seen[id(x,y)],`Regional spawn cannot walk to the city: ${x},${y}`);
}
for(const building of spec.buildings){const [a,b,c,d]=building.bounds;for(const [x,y]of building.entrances){
 const radius=(building.doors-1)/2,closed=Array.from({length:building.doors},(_,i)=>(x===a||x===c)?[x,y+i-radius]:[x+i-radius,y]);
 for(const tile of closed)assert(!solid[id(...tile)],`Public doorway blocked: ${building.name}`);
 assert(walk(101,362,closed).seen[id(Math.floor((a+c)/2),Math.floor((b+d)/2))],`One doorway closure isolates ${building.name}`);
}}
for(const {name,bounds:[a,b,c,d],minimum}of spec.combatSpaces){assert(c-a+1>=minimum&&d-b+1>=minimum);for(let y=b;y<=d;y++)for(let x=a;x<=c;x++)assert(!solid[id(x,y)],`Combat obstruction: ${name} ${x},${y}`);}
const coverage=[],seams=[],reachable=walk(101,362);
if(whole){
 for(let y=1;y<=500;y++)for(let x=1;x<=500;x++)if(x<=8||x>=493||y<=8||y>=493)assert.equal(p.grid[500-y][x-1],'/turf/EarthOceanBoundary,/area/SuperEarth',`Missing Earth boundary ${x},${y}`);
 // Measure obstacles on land: ocean is deliberately impassable, not urban clutter.
 for(let row=0;row<5;row++)for(let col=0;col<5;col++){
  let land=0,dense=0;
  for(let y=401-row*100;y<=500-row*100;y++)for(let x=col*100+1;x<=col*100+100;x++){
   const turf=turfType(splitOutside(p.grid[500-y][x-1],','));
   if(['/turf/Water2','/turf/WaterFall','/turf/EarthRiver','/turf/EarthRiverFall','/turf/EarthOceanBoundary'].includes(turf))continue;
   land++;dense+=solid[id(x,y)];
  }
  assert(!land||dense/land<.30,`Earth ${'ABCDE'[row]}${col+1} exceeds 30% land collision budget`);
  coverage.push({chunk:`${'ABCDE'[row]}${col+1}`,landTiles:land,denseTiles:dense,denseLandPercent:land?+(dense/land*100).toFixed(2):0});
 }
 for(const vertical of [true,false])for(let boundary=100;boundary<=400;boundary+=100)for(let segment=0;segment<5;segment++){
  const starts=[];
  for(let offset=1;offset<=98;offset++){
   const open=Array.from({length:3},(_,i)=>segment*100+offset+i).every(t=>[boundary,boundary+1].every(f=>reachable.seen[id(vertical?f:t,vertical?t:f)]));
   if(open&&(!starts.length||offset-starts.at(-1)>=6))starts.push(offset);
  }
  // Land-to-land seams need redundant crossings. Bridge-only ocean seams are
  // reported separately; they do not turn the preserved ocean into a land seam.
  let naturalLandPairs=0;
  for(let t=segment*100+1;t<=segment*100+100;t++)if([boundary,boundary+1].every(f=>splitOutside(baseline.grid[500-(vertical?t:f)][(vertical?f:t)-1],',').at(-2)!=='/turf/Water2'))naturalLandPairs++;
  if(naturalLandPairs>=10)assert(starts.length>=2,`Earth land seam ${vertical?'X':'Y'}=${boundary}/${segment+1} lacks redundant crossings`);
  seams.push({axis:vertical?'X':'Y',boundary,segment:segment+1,naturalLandPairs,threeTileCrossings:starts.length,active:starts.length>0});
 }
}
const result={phase:whole?6:5,revision:'Earth neighborhood with continuous river',exteriorBuildings:neighborhood.totalBuildings,accessibleBuildings:neighborhood.accessibleBuildings,destinations:spec.points.length,spawnsPreserved:20,clearArrivalTiles:441,waterRetainedOutsideRiverCorrection:waterTiles,riverCorrections:riverChanges.size,raisedBridgeTiles:bridges,waterfallTilesPreserved:falls,reachableTiles:reachable.count,allDestinationsConnected:true,interiorEvidence:'CityInteriorChecks.json',allRegionalSpawnsConnected:whole,oceanBoundaryTiles:whole?15744:0,coverage,seams,combatSpaces:spec.combatSpaces,review:spec.review};
fs.writeFileSync(path.join(root,`docs/Maps/SuperEarth${whole?'World':'Slice'}Checks.json`),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result,null,2));
