'use strict';
// Apply the user's full-block roof / decorative wall / alpha object convention.
// Refuses any chunks edited since the first slice; never has a --force path.
const fs=require('node:fs'),path=require('node:path');
const {root,planetPaths}=require('./PlanetChunks.cjs');
const {parse,serialize,hash,splitOutside}=require('./Dmm.cjs');
if(process.argv.length!==2)throw Error('No overwrite options are supported.');
const prior=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/VerticalSliceAssembly.json')));
const planet={paths:planetPaths('Viltrum'),grid:Array.from({length:500},()=>Array(500)),chunkHashes:{}};
// The old furniture turf types are being retired. Read only the exactly hashed
// prior chunks; the normal assembler validates every NEW type after migration.
for(const [file,digest]of Object.entries(prior.chunkHashes)) {
 const bytes=fs.readFileSync(path.join(planet.paths.directory,file));
 if(hash(bytes)!==digest)throw Error(`Source changed: ${file}; revise manually rather than overwriting.`);
 planet.chunkHashes[file]=digest;
 const m=file.match(/([A-E])([1-5])\.dmm$/),row='ABCDE'.indexOf(m[1]),col=+m[2]-1,chunk=parse(bytes.toString());
 for(let y=0;y<100;y++)for(let x=0;x<100;x++)planet.grid[row*100+y][col*100+x]=chunk.grid[y][x];
}
const grid=planet.grid;
for(let y=0;y<500;y++)for(let x=0;x<500;x++){
 const atoms=splitOutside(grid[y][x],','),turf=atoms.at(-2);
 if(turf.startsWith('/turf/ViltrumFurnishing'))atoms.splice(atoms.length-2,1,turf.replace('/turf/','/obj/'),'/turf/ViltrumFloor');
 else if(turf==='/turf/ViltrumWall'||turf==='/turf/ViltrumWall/Glass')atoms[atoms.length-2]='/turf/ViltrumRoof';
 else if(turf==='/turf/ViltrumWall/Column')atoms[atoms.length-2]='/turf/ViltrumRoof/Dark';
 else if(turf==='/turf/ViltrumFloor/Beacon')atoms.splice(atoms.length-2,1,'/obj/ViltrumFurnishing/LandingBeacon','/turf/ViltrumFloor');
 grid[y][x]=atoms.join(',');
}
// Full-tile front elevation sits immediately south of the solid roof perimeter.
// Five-tile public entrances stay open; no roof turfs replace interior floors.
for(const [x1,y,x2]of[[219,262,242],[260,268,281],[219,127,240],[260,127,281]]){
 const center=Math.floor((x1+x2)/2);
 for(let x=x1;x<=x2;x++)if(Math.abs(x-center)>2)grid[500-y][x-1]=`${(x-x1)%6===3?'/turf/ViltrumWall/Glass':'/turf/ViltrumWall'},/area/Viltrum`;
}
const updates=[];
for(let row=0;row<5;row++)for(let col=0;col<5;col++){
 const file=`Viltrum${'ABCDE'[row]}${col+1}.dmm`,content=serialize(grid.slice(row*100,row*100+100).map(r=>r.slice(col*100,col*100+100)));
 if(hash(content)!==planet.chunkHashes[file])updates.push({file,content});
}
for(const update of updates)fs.writeFileSync(path.join(planet.paths.directory,update.file),update.content);
const specPath=path.join(root,'docs/Maps/ViltrumSlice.json'),spec=JSON.parse(fs.readFileSync(specPath));
spec.revision=2;spec.architecture='Solid opaque roof perimeter, decorative wall facade, walkable interior floors; furnishings are transparent objects.';spec.status='Revised to user feedback; awaiting style approval; interactive review deferred.';
fs.writeFileSync(specPath,JSON.stringify(spec,null,2)+'\n');
console.log(`Revised ${updates.length} chunks; original generated kit and Aseprite documents retained.`);
