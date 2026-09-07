'use strict';
// Incremental refinement: freeze the approved city, retire regional road grids,
// restore the natural terrain and repair the old overlapping river segments.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root,loadPlanet,assemble}=require('./PlanetChunks.cjs');
const {parse,serialize,splitOutside,hash}=require('./Dmm.cjs');
const {restoreHydrology,naturalLand}=require('./EarthNaturalHydrology.cjs');
const read=f=>JSON.parse(fs.readFileSync(path.join(root,f)));
assert(!fs.existsSync(path.join(root,'docs/Maps/EarthNaturalLandmarks.json')),'Historical wilderness stage retired: edit current natural-landmark chunks instead.');
const p=loadPlanet('SuperEarth'),meta=read('src/Maps/SuperEarthMetadata.json');
assert.equal(hash(fs.readFileSync(p.paths.output)),meta.outputHash,'Recover manual assembled-map changes first.');
assert.deepEqual(p.chunkHashes,meta.chunkHashes,'Assemble source chunk edits first.');
const backup=path.join(root,'docs/Maps/RebuildBaseline/BeforeEarthWilderness'),exists=fs.existsSync(backup);
const prior=read(exists?'docs/Maps/EarthWilderness.json':'docs/Maps/EarthNeighborhood.json');
assert.equal(meta.outputHash,prior.outputHash,'Earth changed since the recorded revision.');
assert.equal(hash(fs.readFileSync(path.join(root,'src/Maps/CityInteriors.dmm'))),prior.interiorHash,'Recover edited interiors first.');
assert.equal(hash(fs.readFileSync(path.join(root,'docs/Maps/CityBuildings.json'))),prior.buildingDataHash,'Recover edited building records first.');
const original=exists?parse(fs.readFileSync(path.join(backup,'SuperEarth.dmm'),'utf8')).grid:p.grid;
const registry=exists?JSON.parse(fs.readFileSync(path.join(backup,'CityBuildings.json'))):read('docs/Maps/CityBuildings.json');
const neighborhood=exists?JSON.parse(fs.readFileSync(path.join(backup,'EarthNeighborhood.json'))):read('docs/Maps/EarthNeighborhood.json');
const interior=parse(fs.readFileSync(exists?path.join(backup,'CityInteriors.dmm'):path.join(root,'src/Maps/CityInteriors.dmm'),'utf8'));
const natural=parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/SuperEarth.dmm'),'utf8')).grid;
const cityRiver=require('./AuthorEarthRiver.cjs').authorRiverChannel(natural);
// Retain the user's expanded western water and relocated spawn atoms. The
// original geographic seed is historical; the latest editor save takes priority.
const manual=read('docs/Maps/SuperEarthManualRecovery.json');
for(const c of manual.changes)if(splitOutside(c.after,',').at(-2).split('{')[0]==='/turf/EarthRiver')natural[500-c.y][c.x-1]='/turf/Water2,/area/SuperEarth';
const hydrology=restoreHydrology(natural,read('docs/Maps/SuperEarthSpawns.json'),cityRiver);
const grid=natural.map(r=>r.slice()),key=(x,y)=>`${x},${y}`,type=s=>splitOutside(s,',').at(-2).split('{')[0];
const cityBounds=[41,258,199,405],inside=([a,b,c,d],x,y)=>x>=a&&x<=c&&y>=b&&y<=d;
const huts=new Set(['Northern woodland cabin','Arctic research outpost','Alpine survey shelter','Jungle lookout lodge','Island nature lodge','Southern dune shelter']);
const services=new Set(['Hardware shop','Motor repair garage','Riverside workshop']);
const kept=neighborhood.buildings.filter(b=>b.row!=='Regional'||huts.has(b.name)||services.has(b.name));
const retired=neighborhood.buildings.filter(b=>!kept.includes(b)),retiredIds=new Set(retired.map(b=>b.id));
const report={version:1,design:'One western city; wilderness continents without ocean roads',cityBounds,outposts:kept.filter(b=>huts.has(b.name)),retiredBuildings:retired,hydrology,cityStreetTrims:[],trails:[],restoredRoadTiles:0,restoredOceanCrossingTiles:0};
const bridgeBounds=neighborhood.bridges.map(b=>b.bounds);
const pavement=t=>/^\/turf\/Earth(?:Street(?:\/|$)|Bridge|Floor\/(Road|Sidewalk|Crosswalk))/.test(t);
// Preserve the core city. Remove only obsolete outgoing stubs and the part of
// the north causeway beyond its east avenue; keep both local river bridges.
for(let y=cityBounds[1];y<=cityBounds[3];y++)for(let x=cityBounds[0];x<=cityBounds[2];x++){
 const old=original[500-y][x-1],t=type(old),overSea=!naturalLand(x,y)&&!bridgeBounds.some(b=>inside(b,x,y));
 const stub=pavement(t)&&!bridgeBounds.some(b=>inside(b,x,y))&&(y>=404||y<=261||(y>=392&&x>=169));
 if(overSea||stub){report.cityStreetTrims.push({x,y,reason:overSea?'ocean causeway':'outgoing street stub'});continue;}
 grid[500-y][x-1]=old;
}
// Pavement terminates around the last real junction instead of in open water.
for(let y=394;y<=403;y++)for(let x=167;x<=168;x++)if(naturalLand(x,y)){
 grid[500-y][x-1]='/turf/EarthStreet/Sidewalk,/area/SuperEarth';report.cityStreetTrims.push({x,y,reason:'pavement cap at last junction'});
}
// Keep approved structures and their exact doors/frontage, including three
// southern city services. Isolated shelters get a compact dirt forecourt.
for(const b of kept){
 const [a,y,c,d]=b.bounds;
 for(let yy=y-2;yy<=d;yy++)for(let x=a;x<=c;x++){
  const atoms=splitOutside(original[500-yy][x-1],',');
  if(huts.has(b.name)&&yy<y)atoms[atoms.length-2]='/turf/GroundDirt';
  grid[500-yy][x-1]=atoms.join(',');
 }
}
// Ground and structure under approved houses are user-authored: retain their
// exact stacks rather than reinstating the older generated roof footprints.
const fixedCity=new Set();
for(let y=cityBounds[1];y<=cityBounds[3];y++)for(let x=cityBounds[0];x<=cityBounds[2];x++)if(!report.cityStreetTrims.some(c=>c.x===x&&c.y===y))fixedCity.add(key(x,y));
// A short path from the southern city edge reaches its remaining workshops.
// These are local paths on the western landmass, never intercontinental roads.
const trails=[[[106,263],[106,213],[112,213]],[[106,233],[114,233]],[[163,259],[153,259],[153,238],[162,238]]];
function trail(points){
 for(let i=1;i<points.length;i++){
  const [a,b]=points[i-1],[c,d]=points[i];assert(a===c||b===d);
  for(let y=Math.min(b,d)-1;y<=Math.max(b,d)+1;y++)for(let x=Math.min(a,c)-1;x<=Math.max(a,c)+1;x++){
   if(type(natural[500-y][x-1])==='/turf/Water2')throw Error(`Local path would cross water at ${x},${y}`);
   if(kept.some(b=>inside([b.bounds[0],b.bounds[1]-2,b.bounds[2],b.bounds[3]],x,y)))continue;
   if(splitOutside(original[500-y][x-1],',').some(a=>a.startsWith('/obj/Spawn')))continue;
   if(pavement(type(grid[500-y][x-1])))continue;
   grid[500-y][x-1]='/turf/GroundDirt,/area/SuperEarth';
  }
 }
 report.trails.push(points);
}
trails.forEach(trail);
// Preserve open combat clearings as natural biome ground, including the eastern
// training clearing; no artificial grass rectangle or paved approaches.
const combat=[...read('docs/Maps/SuperEarthSlice.json').combatSpaces,...read('docs/Maps/SuperEarthRegions.json').combatSpaces];
for(const {bounds}of combat){const [a,b,c,d]=bounds;for(let y=b;y<=d;y++)for(let x=a;x<=c;x++){
 if(inside(cityBounds,x,y))continue;
 const atoms=splitOutside(grid[500-y][x-1],',');grid[500-y][x-1]=atoms.filter(a=>!a.startsWith('/obj/')||a.startsWith('/obj/Spawn')).join(',');
}}
// Use the quiet bank material around all river bends instead of the old large
// grass/dirt mosaic, whose partial cells looked like grass crossing the water.
for(let y=9;y<=492;y++)for(let x=9;x<=492;x++){
 if(type(grid[500-y][x-1])==='/turf/Grass8'){
  const atoms=splitOutside(grid[500-y][x-1],',');atoms[atoms.length-2]='/turf/Grass13';grid[500-y][x-1]=atoms.join(',');
 }
}
report.terrain=require('./EarthRiverTerrain.cjs').applyRiverTerrain(grid,natural);
for(const position of fixedCity){const [x,y]=position.split(',').map(Number);grid[500-y][x-1]=original[500-y][x-1];}
// The latest editor save moved three city spawns. Preserve all twenty atoms and
// coordinates from that save, rather than silently reverting to the old seed.
for(let y=1;y<=500;y++)for(let x=1;x<=500;x++){
 const oldSpawns=splitOutside(original[500-y][x-1],',').filter(a=>a.startsWith('/obj/Spawn'));
 const atoms=splitOutside(grid[500-y][x-1],',').filter(a=>!a.startsWith('/obj/Spawn'));
 grid[500-y][x-1]=[...oldSpawns,...atoms].join(',');
}
for(let y=1;y<=500;y++)for(let x=1;x<=500;x++){
 if(x<=8||x>=493||y<=8||y>=493)grid[500-y][x-1]='/turf/EarthOceanBoundary,/area/SuperEarth';
 const was=type(original[500-y][x-1]),now=type(grid[500-y][x-1]);
 if(pavement(was)&&!pavement(now))report.restoredRoadTiles++;
 if(was==='/turf/EarthBridge'&&now==='/turf/EarthRiver')report.restoredOceanCrossingTiles+=Number(!naturalLand(x,y));
}
// Retire removed regional rooms without moving any retained rooms or Viltrum.
const retiredRooms=registry.buildings.filter(b=>retiredIds.has(b.id));
for(const room of retiredRooms){const [a,b,c,d]=room.interiorBounds;for(let y=b;y<=d;y++)for(let x=a;x<=c;x++)interior.grid[interior.height-y][x-1]='/turf/CityBuildingFootprint,/area/CityInterior/Earth';}
registry.buildings=registry.buildings.filter(b=>!retiredIds.has(b.id));
report.retiredRooms=retiredRooms;
neighborhood.buildings=kept;neighborhood.totalBuildings=kept.length;neighborhood.accessibleBuildings=registry.buildings.filter(b=>b.planet==='SuperEarth').length;
neighborhood.wildernessRevision={report:'EarthWilderness.json',outpostIds:report.outposts.map(b=>b.id),retiredIds:[...retiredIds]};
const output=serialize(grid),interiorOutput=serialize(interior.grid),registryOutput=JSON.stringify(registry,null,2)+'\n';
const common={outputHash:hash(output),interiorHash:hash(interiorOutput),buildingDataHash:hash(registryOutput),chunkHashes:{},changedChunks:[]};
const updates=[];
for(let row=0;row<5;row++)for(let col=0;col<5;col++){
 const file=`SuperEarth${'ABCDE'[row]}${col+1}.dmm`,content=serialize(grid.slice(row*100,row*100+100).map(r=>r.slice(col*100,col*100+100)));
 common.chunkHashes[file]=hash(content);if(hash(content)!==p.chunkHashes[file]){updates.push({file,content});common.changedChunks.push(file);}
}
Object.assign(report,common,{beforeHash:hash(serialize(original)),cityBuildings:kept.length-report.outposts.length,accessibleBuildings:neighborhood.accessibleBuildings});
Object.assign(neighborhood,common);
const getSpawns=g=>g.flatMap((r,row)=>r.flatMap((s,col)=>splitOutside(s,',').filter(a=>a.startsWith('/obj/Spawn')).map(atom=>({x:col+1,y:500-row,atom}))));
assert.deepEqual(getSpawns(grid),getSpawns(original),'All spawns must survive unchanged.');
const out=path.join(root,'.codex-tmp/EarthWilderness');fs.mkdirSync(out,{recursive:true});
fs.writeFileSync(path.join(out,'SuperEarth.dmm'),output);fs.writeFileSync(path.join(out,'CityInteriors.dmm'),interiorOutput);fs.writeFileSync(path.join(out,'CityBuildings.json'),registryOutput);
for(const [name,value]of [['EarthWilderness',report],['EarthNeighborhood',neighborhood]])fs.writeFileSync(path.join(out,name+'.json'),JSON.stringify(value,null,2)+'\n');
const palette=[...new Set(grid.flat())].sort(),lookup=new Map(palette.map((s,i)=>[s,i]));
fs.writeFileSync(path.join(out,'Preview.json'),JSON.stringify({planet:'SuperEarth',palette,grid:grid.map(r=>r.map(s=>lookup.get(s)))}));
if(process.argv.includes('--apply')){
 if(!exists){
  fs.mkdirSync(backup);for(const name of ['SuperEarth.dmm','SuperEarthMetadata.json','CityInteriors.dmm'])fs.copyFileSync(path.join(root,'src/Maps',name),path.join(backup,name));
  for(const name of ['CityBuildings.json','EarthNeighborhood.json'])fs.copyFileSync(path.join(root,'docs/Maps',name),path.join(backup,name));
  for(const file of Object.keys(p.chunkHashes))fs.copyFileSync(path.join(p.paths.directory,file),path.join(backup,file));
 }
 for(const {file,content}of updates)fs.writeFileSync(path.join(p.paths.directory,file),content);
 fs.writeFileSync(path.join(root,'src/Maps/CityInteriors.dmm'),interiorOutput);fs.writeFileSync(path.join(root,'docs/Maps/CityBuildings.json'),registryOutput);
 for(const [name,value]of [['EarthWilderness',report],['EarthNeighborhood',neighborhood]])fs.writeFileSync(path.join(root,'docs/Maps',name+'.json'),JSON.stringify(value,null,2)+'\n');
 assemble('SuperEarth');
}
console.log({mode:process.argv.includes('--apply')?'applied':'preview',cityBuildings:report.cityBuildings,outposts:report.outposts.length,accessible:report.accessibleBuildings,retired:retired.length,restoredRoadTiles:report.restoredRoadTiles,hydrologyRepairs:hydrology.changes.length,outputHash:report.outputHash});
