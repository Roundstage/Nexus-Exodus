'use strict';
// One-time authored layout application. The protected phase-one hashes guard all
// existing chunks; this tool has no --force path and refuses subsequent use.
const fs=require('node:fs'),path=require('node:path');
const {root,loadPlanet}=require('./PlanetChunks.cjs');
const {serialize,hash}=require('./Dmm.cjs');
if(process.argv.length!==2)throw Error('This one-time slice authoring tool takes no overwrite options.');
const planet=loadPlanet('Viltrum');
const seed=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/PhaseOneAssembly.json')));
for(const [file,digest] of Object.entries(seed.chunkHashes))if(planet.chunkHashes[file]!==digest)throw Error(`Chunk has changed since seeding: ${file}; author directly in the sources.`);
const grid=planet.grid,area='/area/Viltrum',ground='/turf/ViltrumGround',floor='/turf/ViltrumFloor',road=floor+'/Road',platform=floor+'/Structural',wall='/turf/ViltrumWall',props='/turf/ViltrumFurnishing';
const put=(x,y,type,objects=[])=>{grid[500-y][x-1]=[...objects,type,area].join(',');};
const rect=(x1,y1,x2,y2,type)=>{for(let y=y1;y<=y2;y++)for(let x=x1;x<=x2;x++)put(x,y,type);};
const outline=(x1,y1,x2,y2,type)=>{rect(x1,y1,x2,y1,type);rect(x1,y2,x2,y2,type);rect(x1,y1,x1,y2,type);rect(x2,y1,x2,y2,type);};
const building=(x1,y1,x2,y2)=>{
 rect(x1,y1,x2,y2,wall);rect(x1+1,y1+1,x2-1,y2-1,floor);
 const cx=Math.floor((x1+x2)/2),cy=Math.floor((y1+y2)/2);
 rect(cx-2,y1,cx+2,y1,floor);rect(cx-2,y2,cx+2,y2,floor);
 rect(x1,cy-2,x1,cy+2,floor);rect(x2,cy-2,x2,cy+2,floor);
 for(let x=x1+4;x<=x2-4;x+=6) if(Math.abs(x-cx)>3){put(x,y1,wall+'/Glass');put(x,y2,wall+'/Glass');}
};
// C3 + D3 terrain: two spacious civic islands separated by broad garden margins.
rect(201,101,300,300,ground);
rect(205,205,296,296,floor);rect(218,218,282,257,floor);
rect(205,118,296,168,floor);rect(230,66,270,117,platform);
// Three parallel north/south paths; the axis is eleven tiles wide.
rect(245,68,255,304,road);rect(209,102,215,300,road);rect(285,102,291,300,road);
for(const y of [110,175,201,258,295])rect(205,y-3,296,y+3,road);
// Unbroken east/west seam into the original capital's boulevard.
rect(201,247,300,253,floor);
// Arrival remains at (250,78), E3: 21x21 floor with markers OUTSIDE the scatter box.
rect(238,66,262,92,floor);rect(240,68,260,88,platform);
for(const [x,y]of [[238,66],[262,66],[238,92],[262,92]])put(x,y,floor+'/Beacon');
rect(209,92,215,110,road);rect(285,92,291,110,road);rect(209,92,291,98,road);
// Public archive: 29x29 interior, four five-tile open arches, reading galleries.
building(219,263,242,291);
for(const x of [223,237])for(const y of [267,271,283,287]){put(x,y,props+'/ArchiveTable');put(x+(x===223?2:-2),y,props+'/Bench');}
put(229,288,floor,['/obj/ViltrumConsole{name = "Public archive directory"; status_text = "Welcome to the capital archive. Forum south; palace precinct north; transit terminal south along the imperial axis."}']);
// East memorial court and working energy regulator in an accessible service pavilion.
building(260,269,281,290);
put(270,284,platform,['/obj/ViltrumConsole/Reactor']);
rect(263,271,278,282,platform);
for(const x of [263,278])put(x,286,wall+'/Column');
for(const [x,y]of [[269,262],[277,262],[264,258],[282,258]])put(x,y,props+'/Memorial');
// Main combat forum: a completely empty 36x30 rectangle, with four approaches.
rect(229,216,272,251,floor);rect(232,219,269,248,platform);
put(250,250,floor,['/obj/Spawn{name = "Viltrumite"; desc = "Viltrum"}']);
// Paired terminal wings leave the eleven-tile axis and both terrace roads open.
building(219,128,240,158);building(260,128,281,158);
for(const x of [223,237,264,278])for(const y of [132,138,150,154])put(x,y,props+'/Bench');
put(229,155,floor,['/obj/ViltrumConsole{name = "Arrival concourse directory"}']);
put(269,155,floor,['/obj/ViltrumConsole{name = "Departure concourse directory"; status_text = "Landing apron: south at 250,78. Use normal planetary liftoff from the surface. Forum and archive: north. Both outer terraces remain open."}']);
// Sparse furnishings define terraces without filling the combat and travel lanes.
for(const y of [120,164,184,208,256,299])for(const x of [218,282])put(x,y,props);
for(const y of [119,161,209,254,298])for(const x of [239,261])put(x,y,props+'/Banner');
for(const x of [219,281])for(const y of [218,230,242])put(x,y,props+'/Bench');
// Blend authored edges using existing road approaches; no invisible collision seam.
rect(245,301,255,308,road);rect(201,247,228,253,floor);rect(273,247,300,253,floor);
const points=[{name:'Planet landing',x:250,y:78},{name:'Capital forum spawn',x:250,y:250},{name:'Archive',x:230,y:277},{name:'Energy pavilion',x:270,y:280},{name:'Arrival concourse',x:230,y:143},{name:'Departure concourse',x:270,y:143}];
const updated=[];
for(let row=0;row<5;row++)for(let col=0;col<5;col++){
 const file=`Viltrum${'ABCDE'[row]}${col+1}.dmm`,content=serialize(grid.slice(row*100,row*100+100).map(r=>r.slice(col*100,col*100+100)));
 if(hash(content)!==planet.chunkHashes[file])updated.push({file,content});
}
// All serialization succeeds before the first source write.
for(const {file,content}of updated)fs.writeFileSync(path.join(planet.paths.directory,file),content);
fs.writeFileSync(path.join(root,'docs/Maps/ViltrumSlice.json'),JSON.stringify({version:1,phase:2,landing:{x:250,y:78,radius:10},spawn:{x:250,y:250},combatClear:{x1:232,y1:219,x2:269,y2:248},points,publicRooms:[[220,129,239,157],[261,129,280,157],[220,264,241,290],[261,270,280,289]],changedChunks:updated.map(v=>v.file),status:'Awaiting visual approval and deferred in-game review'},null,2)+'\n');
console.log(`Authored vertical slice in ${updated.map(v=>v.file).join(', ')}`);
