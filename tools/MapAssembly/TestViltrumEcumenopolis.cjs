'use strict';
const fs=require('node:fs'),path=require('node:path'),os=require('node:os'),assert=require('node:assert/strict');
const {root,loadPlanet}=require('./PlanetChunks.cjs'),{parse,splitOutside,hash}=require('./Dmm.cjs');
const index=(x,y)=>(y-1)*500+x-1;
function check(stage,baseline,registry){
 const report=JSON.parse(fs.readFileSync(path.join(stage,'ViltrumEcumenopolis.json')));
 const map=parse(fs.readFileSync(path.join(stage,'Viltrum.dmm'),'utf8'));
 assert.deepEqual([map.width,map.height],[500,500]);
 const at=(x,y)=>map.grid[500-y][x-1],occupied=new Set(),roads=new Set(report.roads.map(p=>index(...p)));
 const solid=new Uint8Array(250000),cache=new Map();let oldExteriors=0,entrances=0,water=0;
 for(let y=1;y<=500;y++)for(let x=1;x<=500;x++){
  const s=at(x,y),atoms=splitOutside(s,',').map(a=>a.split('{')[0]);
  if(!cache.has(s))cache.set(s,atoms.some(t=>/^\/turf\/(ViltrumCityStructure|CityBuildingFootprint|ViltrumRoof|ViltrumOcean|Wall21)/.test(t)||/^\/obj\/(ViltrumCityTree|ViltrumConsole|ViltrumCapitalFurnishing)/.test(t)||t.startsWith('/obj/ViltrumFurnishing')&&!t.startsWith('/obj/ViltrumFurnishing/LandingBeacon')));
  solid[index(x,y)]=+cache.get(s);
  if(atoms.some(a=>a.startsWith('/obj/CityHouse')))oldExteriors++;
  if(atoms.includes('/obj/CityBuildingDoor/ViltrumCity'))entrances++;
  if(atoms.some(a=>a.startsWith('/turf/ViltrumOcean'))){water++;assert.equal(s,baseline[500-y][x-1],'Changed original water');}
  if(x<=8||x>=493||y<=8||y>=493)assert.equal(s,baseline[500-y][x-1],'Changed world boundary');
  assert(!/\/turf\/(Stairs_Grass|EarthRiverSteps|Wall7)(?:,|\{)/.test(s));
 }
 assert.equal(oldExteriors,0,'Old rejected exterior remains on surface');
 for(const {x,y}of JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/ManualOutputDelta.json'))))assert.equal(at(x,y),baseline[500-y][x-1],`Manual tile changed: ${x},${y}`);
 for(const [a,b,c,d]of report.protectedBoxes)for(let y=b;y<=d;y++)for(let x=a;x<=c;x++)assert.equal(at(x,y),baseline[500-y][x-1]);
 for(const b of report.buildings){
  const [a,y,c,d]=b.bounds;
  for(let yy=y;yy<=d;yy++)for(let x=a;x<=c;x++){
   const k=index(x,yy);assert(!occupied.has(k)&&!roads.has(k),`Overlapping footprint ${x},${yy}`);occupied.add(k);
   const atoms=splitOutside(at(x,yy),','),structural=atoms.at(-2);
   assert(structural.startsWith('/turf/ViltrumCityStructure{'));
   assert(structural.includes(`icon_state = "${b.style}_${x-a}_${yy-y}"`),'Structural art differs from exterior');
  }
  assert(at(a,y).includes(b.type),'Missing exterior anchor');
  for(let x=a;x<=c;x++)for(const yy of [y-1,y-2])assert(!solid[index(x,yy)],`Obstructed frontage ${x},${yy}`);
 }
 function flood(start,allowed){
  const seen=new Uint8Array(250000),q=new Int32Array(250000);let tail=1;q[0]=index(...start);seen[q[0]]=1;
  assert(allowed(q[0]));
  for(let head=0;head<tail;head++){
   const k=q[head],x=k%500,y=Math.floor(k/500);
   for(const n of [x>0?k-1:-1,x<499?k+1:-1,y>0?k-500:-1,y<499?k+500:-1])if(n>=0&&!seen[n]&&allowed(n)){seen[n]=1;q[tail++]=n;}
  }
  return {seen,count:tail};
 }
 const publicWalk=flood([250,78],k=>!solid[k]);
 assert(publicWalk.seen[index(250,250)],'Arrival and racial spawn disconnected');
 for(const b of report.buildings)assert(publicWalk.seen[index(...b.door)],`Isolated building ${b.bounds}`);
 const roadWalk=flood(report.roads[0],k=>roads.has(k));
 assert.equal(roadWalk.count,roads.size,'Detached road network');
 for(const [x,y]of report.roads)assert(!solid[index(x,y)]&&publicWalk.seen[index(x,y)],`Blocked road ${x},${y}`);
 const mapped=registry.buildings.filter(b=>b.planet==='Viltrum');assert.equal(entrances,mapped.length);
 const inside=parse(fs.readFileSync(path.join(stage,'CityInteriors.dmm'),'utf8'));
 for(const b of mapped){
  const [x,y,z]=b.door,[rx,ry,rz]=b.return,[ex,ey]=b.exits[0];assert.equal(z,20);assert.equal(rz,20);assert.equal(ry,y-1);
  assert(at(x,y).includes(`building_id = "${b.id}"`));
  assert(at(x,y).includes(`target_x = ${b.entry[0]}`)&&at(x,y).includes(`target_y = ${b.entry[1]}`)&&at(x,y).includes('target_z = 22'));
  assert(publicWalk.seen[index(rx,ry)]);
  const exit=inside.grid[inside.height-ey][ex-1];
  assert(exit.includes(`target_x = ${rx}`)&&exit.includes(`target_y = ${ry}`)&&exit.includes('target_z = 20'));
 }
 assert(report.blocks.length>=45&&report.buildings.length>=600,'Insufficient urban coverage for planet-scale city');
 assert.equal(water,report.waterTiles);
 const result={blocks:report.blocks.length,buildings:report.buildings.length,accessible:mapped.length,structuralTiles:occupied.size,reachableTiles:publicWalk.count,
  connectedRoadTiles:roadWalk.count,preservedWaterTiles:water,manualTilesPreserved:true,clearFrontages:true,matchingStructuralArt:true,exactReturnTargets:true};
 fs.writeFileSync(path.join(stage,'Checks.json'),JSON.stringify(result,null,2)+'\n');
 return result;
}
module.exports={check};
if(require.main===module){
 const applied=path.join(root,'docs/Maps/ViltrumEcumenopolis.json');
 const temporary=fs.existsSync(applied)?fs.mkdtempSync(path.join(os.tmpdir(),'ViltrumCityCheck-')):null;
 const stage=temporary||path.join(root,'.codex-tmp/ViltrumEcumenopolis');
 if(temporary){
  fs.copyFileSync(applied,path.join(stage,'ViltrumEcumenopolis.json'));
  for(const file of ['Viltrum.dmm','CityInteriors.dmm'])fs.copyFileSync(path.join(root,'src/Maps',file),path.join(stage,file));
  fs.copyFileSync(path.join(root,'docs/Maps/CityBuildings.json'),path.join(stage,'CityBuildings.json'));
 }
 try{
 const report=JSON.parse(fs.readFileSync(path.join(stage,'ViltrumEcumenopolis.json')));
 if(report.appliedHashes){
  for(const [file,value]of Object.entries(report.appliedHashes))assert.equal(hash(fs.readFileSync(path.join(root,file))),value,`Edited applied file: ${file}`);
  assert.deepEqual(loadPlanet('Viltrum').grid,parse(fs.readFileSync(path.join(stage,'Viltrum.dmm'),'utf8')).grid);
 }
 const baselinePath=path.join(root,'docs/Maps/RebuildBaseline/BeforeViltrumEcumenopolis/src/Maps/Viltrum.dmm');
 const baseline=parse(fs.readFileSync(fs.existsSync(baselinePath)?baselinePath:path.join(root,'src/Maps/Viltrum.dmm'),'utf8')).grid;
 const data=JSON.parse(fs.readFileSync(path.join(stage,'CityBuildings.json')));
 const result=check(stage,baseline,data);console.log(result);
 if(temporary)fs.copyFileSync(path.join(stage,'Checks.json'),path.join(root,'docs/Maps/ViltrumEcumenopolisChecks.json'));
 }finally{
  if(temporary){assert(path.resolve(temporary).startsWith(path.resolve(os.tmpdir())+path.sep));fs.rmSync(temporary,{recursive:true});}
 }
}
