'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root}=require('./PlanetChunks.cjs'),{splitOutside,parse}=require('./Dmm.cjs');
function migration(){const file=path.join(root,'docs/Maps/CityBuildings.json');return fs.existsSync(file)?JSON.parse(fs.readFileSync(file)):null;}
function adaptSpec(spec,planet){
 const change=migration();if(!change)return;
 const moved=change.buildings.filter(b=>b.planet===planet),names=new Map(moved.map(b=>[b.name,b]));
 // Old open-room coordinates were intentionally migrated to separate rooms.
 // Test each replacement door and every interior below, not a solid exterior.
 spec.publicRooms=spec.publicRooms.filter(([a,b,c,d])=>!moved.some(m=>m.originalBounds.join(',')===[a-1,b-1,c+1,d+1].join(',')));
 spec.buildings=spec.buildings.filter(b=>!names.has(b.name));
 spec.points=spec.points.map(p=>names.has(p.name)?{...p,x:names.get(p.name).door[0],y:names.get(p.name).door[1]}:p);
}
function checkInteriors(){
 const data=migration();assert(data);const map=parse(fs.readFileSync(path.join(root,'src/Maps/CityInteriors.dmm'),'utf8'));let floorTiles=0,interiorObjects=0;
 for(const b of data.buildings){
  const [a,y,c,d]=b.interiorBounds,walkable=new Set(),expectedArea=b.planet==='Viltrum'?'/area/CityInterior':'/area/CityInterior/Earth';
  for(let yy=y;yy<=d;yy++)for(let x=a;x<=c;x++){
   const atoms=splitOutside(map.grid[map.height-yy][x-1],','),turf=atoms.at(-2);assert.equal(atoms.at(-1),expectedArea);
   const objects=atoms.slice(0,-2);interiorObjects+=objects.length;
   const allowedExit=/^\/obj\/CityBuildingDoor(?:\/Earth)?\/Exit(?:\{|$)/;
   assert(objects.every(atom=>allowedExit.test(atom)),`Unexpected object inside ${b.name}`);
   const solid=/Roof/.test(turf);
   if(!solid)walkable.add(`${x},${yy}`);
   if(x===a||x===c||yy===y||yy===d)assert(/Roof/.test(turf),'Interior perimeter must be sealed');
  }
  const start=b.entry.slice(0,2).join(','),seen=new Set([start]),queue=[start];assert(walkable.has(start));
  for(let i=0;i<queue.length;i++){const [x,y]=queue[i].split(',').map(Number);for(const [xx,yy]of[[x-1,y],[x+1,y],[x,y-1],[x,y+1]]){const key=`${xx},${yy}`;if(walkable.has(key)&&!seen.has(key)){seen.add(key);queue.push(key);}}}
  assert.equal(seen.size,walkable.size,`Isolated interior floor: ${b.name}`);floorTiles+=seen.size;
  const destination=b.return||b.door;
  assert.equal(b.exits.length,1,`Interior must have one return portal: ${b.name}`);
  assert.equal(b.props.length,0,`Interior registry still contains objects: ${b.name}`);
  for(const [x,y]of b.exits){assert(seen.has(`${x},${y}`));const stack=map.grid[map.height-y][x-1];assert(stack.includes(`building_id = "${b.id}"`)&&stack.includes(`target_x = ${destination[0]}`)&&stack.includes(`target_y = ${destination[1]}`)&&stack.includes(`target_z = ${destination[2]}`),'Exit must return to its exact street');}
 }
 assert.equal(interiorObjects,data.buildings.length,'Each building must contain only its single return portal');
 return {buildings:data.buildings.length,interiorFloorTiles:floorTiles,allRoomsConnected:true,exactReturnDoors:true,emptyInteriors:true,singleReturnDoor:true,interiorObjects};
}
module.exports={adaptSpec,checkInteriors,migration};
if(require.main===module){const result=checkInteriors();fs.writeFileSync(path.join(root,'docs/Maps/CityInteriorChecks.json'),JSON.stringify(result,null,2)+'\n');console.log(result);}
