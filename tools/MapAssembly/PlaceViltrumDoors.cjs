'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root,loadPlanet}=require('./PlanetChunks.cjs'),{splitOutside,serialize,hash}=require('./Dmm.cjs');
if(process.argv.length!==2)throw Error('No overwrite options.');
const p=loadPlanet('Viltrum'),prior=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/WildernessAssembly.json')));
assert.equal(hash(fs.readFileSync(p.paths.output)),prior.outputHash,'Manual output changed; recover first.');
for(const [file,digest]of Object.entries(prior.chunkHashes))assert.equal(p.chunkHashes[file],digest,`Source changed: ${file}`);
const groups=[{name:'civic_dining',x:169,y:321,type:'/obj/ViltrumDoor'},{name:'palace_audience',x:250,y:351,type:'/obj/ViltrumDoor/Palace'},{name:'research_hall',x:331,y:359,type:'/obj/ViltrumDoor/Laboratory'},{name:'transit_hangar',x:130,y:145,type:'/obj/ViltrumDoor/Hangar'},{name:'grid_service',x:450,y:222,type:'/obj/ViltrumDoor/ForceField'}];
for(const group of groups)for(let x=group.x-2;x<=group.x+2;x++){
 const atoms=splitOutside(p.grid[500-group.y][x-1],',');assert(atoms.length===2&&atoms[0].startsWith('/turf/ViltrumFloor'),'Door footprint must be an unoccupied public floor');
 p.grid[500-group.y][x-1]=[`${group.type}{door_group = "${group.name}"}`,...atoms].join(',');
}
const backup=path.join(root,'docs/Maps/RebuildBaseline/BeforeDoors');assert(!fs.existsSync(backup));fs.mkdirSync(backup);
const changed=[];for(let row=0;row<5;row++)for(let col=0;col<5;col++){
 const file=`Viltrum${'ABCDE'[row]}${col+1}.dmm`,content=serialize(p.grid.slice(row*100,row*100+100).map(r=>r.slice(col*100,col*100+100)));
 if(hash(content)!==p.chunkHashes[file]){fs.copyFileSync(path.join(p.paths.directory,file),path.join(backup,file));fs.writeFileSync(path.join(p.paths.directory,file),content);changed.push(file);}
}
fs.writeFileSync(path.join(root,'docs/Maps/ViltrumDoors.json'),JSON.stringify({groups,panels:25,animationTicks:3,changedChunks:changed,collision:'Dense through opening; passable when fully open. Closing rechecks occupancy before enabling collision.',publicAccess:'No passwords; grouped five-tile entrances; all buildings retain other open arches.'},null,2)+'\n');console.log('Placed five public door groups / 25 panels without changing floor footprints.');
