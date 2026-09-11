'use strict';
// Keep authored building rooms empty and retain one return portal beside entry.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root}=require('./PlanetChunks.cjs');
const {parse,serialize,splitOutside,hash}=require('./Dmm.cjs');
const mapPath=path.join(root,'src/Maps/CityInteriors.dmm');
const registryPath=path.join(root,'docs/Maps/CityBuildings.json');
const map=parse(fs.readFileSync(mapPath,'utf8'));
const registry=JSON.parse(fs.readFileSync(registryPath,'utf8'));
let removedObjects=0,removedExits=0;
for(const building of registry.buildings){
 const [a,b,c,d]=building.interiorBounds;
 const keepExit=building.exits.slice().sort((left,right)=>
  Math.abs(left[0]-building.entry[0])+Math.abs(left[1]-building.entry[1])-
  Math.abs(right[0]-building.entry[0])-Math.abs(right[1]-building.entry[1]))[0];
 assert(keepExit,`Missing interior exit: ${building.id}`);
 for(let y=b;y<=d;y++)for(let x=a;x<=c;x++){
  const atoms=splitOutside(map.grid[map.height-y][x-1],',');
  const objects=atoms.slice(0,-2);
  const retained=(x===keepExit[0]&&y===keepExit[1])
   ? objects.filter(atom=>/^\/obj\/CityBuildingDoor(?:\/Earth)?\/Exit(?:\{|$)/.test(atom)) : [];
  assert(x!==keepExit[0]||y!==keepExit[1]||retained.length===1,`Expected one return portal: ${building.id}`);
  removedObjects+=objects.length-retained.length;
  removedExits+=objects.filter(atom=>/^\/obj\/CityBuildingDoor(?:\/Earth)?\/Exit(?:\{|$)/.test(atom)).length-retained.length;
  map.grid[map.height-y][x-1]=[...retained,...atoms.slice(-2)].join(',');
 }
 building.exits=[keepExit];
 building.props=[];
}
const mapOutput=serialize(map.grid),registryOutput=JSON.stringify(registry,null,2)+'\n';
const interiorHash=hash(mapOutput),buildingDataHash=hash(registryOutput);
fs.writeFileSync(mapPath,mapOutput);
fs.writeFileSync(registryPath,registryOutput);
for(const name of ['EarthNeighborhood.json','EarthNaturalLandmarks.json']){
 const reportPath=path.join(root,'docs/Maps',name),report=JSON.parse(fs.readFileSync(reportPath,'utf8'));
 report.interiorHash=interiorHash;report.buildingDataHash=buildingDataHash;
 fs.writeFileSync(reportPath,JSON.stringify(report,null,2)+'\n');
}
const result={version:1,buildings:registry.buildings.length,removedObjects,removedExtraExits:removedExits,objectsRemaining:registry.buildings.length,interiorHash,buildingDataHash};
fs.writeFileSync(path.join(root,'docs/Maps/CityInteriorSimplification.json'),JSON.stringify(result,null,2)+'\n');
console.log(result);
