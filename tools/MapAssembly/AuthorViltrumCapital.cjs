'use strict';
// One-time application of the approved capital design. Subsequent edits belong
// in the source chunks; a changed source can never be regenerated with --force.
const fs=require('node:fs'),path=require('node:path');
const {root,loadPlanet}=require('./PlanetChunks.cjs');
const {serialize,hash}=require('./Dmm.cjs');
if(process.argv.length!==2)throw Error('No overwrite options are supported.');
const planet=loadPlanet('Viltrum');
const prior=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/RevisionTwoAssembly.json')));
for(const [file,digest]of Object.entries(prior.chunkHashes))if(planet.chunkHashes[file]!==digest)throw Error(`Source changed: ${file}; author directly in chunks.`);
const grid=planet.grid,area='/area/Viltrum',ground='/turf/ViltrumGround',floor='/turf/ViltrumFloor',road=floor+'/Road',dark=floor+'/Structural',roof='/turf/ViltrumRoof',wall='/turf/ViltrumWall',furn='/obj/ViltrumFurnishing',extra='/obj/ViltrumCapitalFurnishing';
const spec={phase:3,styleApproved:'2026-09-06: Está bom, pode continuar.',points:[],publicRooms:[],buildings:[],combatSpaces:[],districts:[],changedChunks:[],review:'Script and headless checks; interactive review deferred by user.'};
function put(x,y,type,objects=[]){if(x<1||y<1||x>500||y>500)throw Error('Outside map');grid[500-y][x-1]=[...objects,type,area].join(',');}
function rect(x1,y1,x2,y2,type){for(let y=y1;y<=y2;y++)for(let x=x1;x<=x2;x++)put(x,y,type);}
function outline(x1,y1,x2,y2,type){rect(x1,y1,x2,y1,type);rect(x1,y2,x2,y2,type);rect(x1,y1,x1,y2,type);rect(x2,y1,x2,y2,type);}
function prop(x,y,type,name){const atoms=grid[500-y][x-1].split(',');put(x,y,atoms.at(-2),[type+(name?`{name = ${JSON.stringify(name)}}`:'')]);}
function consoleAt(x,y,name,text){prop(x,y,`/obj/ViltrumConsole{name = ${JSON.stringify(name)}; status_text = ${JSON.stringify(text)}}`);}
function point(name,x,y){spec.points.push({name,x,y});}
function hall(name,x1,y1,x2,y2,material=floor){
 rect(x1,y1,x2,y2,roof);rect(x1+1,y1+1,x2-1,y2-1,material);
 const cx=Math.floor((x1+x2)/2),cy=Math.floor((y1+y2)/2);
 const entrances=[[cx,y1],[cx,y2],[x1,cy],[x2,cy]];
 for(const [x,y]of entrances)if(x===cx)rect(x-2,y,x+2,y,material);else rect(x,y-2,x,y+2,material);
 for(let x=x1;x<=x2;x++)if(Math.abs(x-cx)>2)put(x,y1-1,(x-x1)%7===3?wall+'/Glass':wall);
 spec.publicRooms.push([x1+1,y1+1,x2-1,y2-1]);spec.buildings.push({name,bounds:[x1,y1,x2,y2],entrances});point(name,cx,cy);
 return {cx,cy};
}
function district(chunk,name){
 const col=Number(chunk[1])-1,row='ABCDE'.indexOf(chunk[0]),x=col*100,y=(4-row)*100;
 rect(x+1,y+1,x+100,y+100,ground);
 // Broad perimeter circulation: two north/south and two east/west approaches.
 for(const dx of [10,90])rect(x+dx-3,y+1,x+dx+3,y+100,road);
 for(const dy of [10,90])rect(x+1,y+dy-3,x+100,y+dy+3,road);
 spec.districts.push({chunk,name,bounds:[x+1,y+1,x+100,y+100],densityLimit:chunk==='C1'||chunk==='C4'?.20:.30});
}
for(const [chunk,name]of [['B2','Residential terraces'],['B3','Imperial palace precinct'],['B4','Science enclave'],['C1','Grand training grounds'],['C2','Civic market'],['C4','War college and arena'],['C5','Planetary energy works'],['D2','Shipyard approach'],['D4','Fabrication district']])district(chunk,name);

// B3: a central audience hall, paired offices and a monumental memorial court.
rect(218,319,282,395,floor);rect(245,301,255,400,road);
hall('Imperial audience hall',229,351,271,383);
rect(244,355,256,379,dark);prop(250,379,extra+'/Throne');
for(const x of [234,266])for(const y of [357,365,377])prop(x,y,furn+'/Banner');
hall('Western imperial office',219,322,240,342);hall('Eastern imperial office',260,322,281,342);
for(const x of [224,235,265,276])prop(x,337,furn+'/ArchiveTable');
for(const x of [224,276])prop(x,347,furn+'/Memorial');
consoleAt(233,355,'Imperial directory','Audience hall and offices. South: forum and spaceport. West: residences. East: research enclave. Both outer terraces bypass the hall.');
point('Memorial court',250,330);
// Preserve all three approved slice approaches across the B3/C3 seam.
for(const [a,b]of [[209,215],[245,255],[285,291]])rect(a,301,b,318,road);

// B2: staggered communal residences, open central garden, clinic and dining hall.
rect(119,319,181,381,floor);rect(146,311,152,389,road);rect(111,347,189,353,road);
hall('West residence',119,360,140,380);hall('East residence',159,355,181,380);
for(const [x,y]of [[123,375],[136,375],[163,375],[177,375]])prop(x,y,extra+'/Bed');
for(const [x,y]of [[123,364],[177,359]])prop(x,y,extra+'/Locker');
hall('Terrace clinic',120,321,140,340);hall('Communal dining hall',158,321,181,340);
prop(124,336,extra+'/MedicalBed');prop(136,336,extra+'/MedicalBed');
prop(163,336,extra+'/ServingCounter');for(const x of [164,176])prop(x,325,furn+'/ArchiveTable');
for(const [x,y]of [[143,357],[155,357],[143,343],[155,343]])prop(x,y,furn);
consoleAt(137,325,'Terrace services','Communal residences north; clinic and dining south. Palace east; civic market south. Public rooms use open arches.');point('Terrace garden',149,350);

// B4: three research pavilions around a central open quadrangle.
rect(319,319,381,381,floor);rect(347,311,353,389,road);rect(311,347,389,353,road);
hall('Research hall',319,359,343,381,dark);hall('Medical laboratory',359,355,381,381);
hall('Scientific archive',323,319,377,339);
for(const [x,y]of [[324,375],[338,375],[329,334],[341,334],[359,334],[371,334]])prop(x,y,furn+'/ArchiveTable');
for(const x of [364,376])prop(x,376,extra+'/MedicalBed');
prop(365,360,'/obj/ViltrumConsole/Reactor');consoleAt(325,364,'Research records','Civil research, medical observation and the scientific archive. Medical laboratory east, archive south. Energy works southeast.');
for(const [x,y]of [[340,344],[360,344],[340,354],[360,354]])prop(x,y,furn);point('Research quadrangle',350,350);

// C1: 50x50 uninterrupted sparring square and a separate endurance loop.
rect(22,222,79,279,floor);rect(25,225,74,274,dark);
spec.combatSpaces.push({name:'Grand training floor',bounds:[25,225,74,274],minimum:48});point('Grand training floor',50,250);
hall('Training equipment pavilion',25,282,74,297);for(const x of [31,42,58,68])prop(x,293,extra+'/Locker');
consoleAt(29,286,'Training course','Central field: fifty tiles square. The outer loop remains clear for endurance running. Forum east; badlands south.');
for(const [x,y]of [[20,220],[80,220],[20,280],[80,280]])prop(x,y,furn+'/Banner');

// C2: an open agora, three smaller service halls and a northern exchange gallery.
rect(119,219,181,281,floor);rect(134,234,166,266,dark);
hall('Civic exchange gallery',119,273,181,293);hall('Equipment market',120,223,132,261);hall('Food market',168,223,181,261);
for(const x of [124,137,163,176])prop(x,288,furn+'/ArchiveTable');
for(const y of [228,236,250,256]){prop(124,y,extra+'/Locker');prop(177,y,extra+'/ServingCounter');}
consoleAt(123,278,'Civic exchange','Civic exchange and public meeting halls. Equipment gallery west, communal food hall east. Forum east; residential terraces north.');
point('Civic agora',150,250);spec.combatSpaces.push({name:'Civic agora',bounds:[136,236,164,264],minimum:28});

// C4: octagonal arena, continuous spectator loop, four seven-tile open exits.
rect(314,212,386,278,floor);
for(let y=214;y<=276;y++)for(let x=316;x<=384;x++){
 const dx=Math.abs(x-350),dy=Math.abs(y-245),inside=dx<=34&&dy<=31&&dx+dy<=55;
 if(!inside)continue;
 const edge=dx>=33||dy>=30||dx+dy>=54;
 put(x,y,edge?roof+'/Dark':dark);
}
rect(347,211,353,279,dark);rect(313,242,387,248,dark);
rect(326,221,373,268,dark); // 48x48, wholly inside the octagonal envelope.
spec.combatSpaces.push({name:'War college arena',bounds:[326,221,373,268],minimum:48,exits:[[350,214],[350,276],[316,245],[384,245]]});point('War college arena',350,245);
hall('War college lecture hall',318,282,342,296);hall('War college barracks',359,282,382,296);
for(const x of [323,337])prop(x,292,furn+'/ArchiveTable');for(const x of [364,377])prop(x,292,extra+'/Bed');
consoleAt(320,286,'War college directory','Arena south: four open exits and a 48 by 48 clear combat floor. Spectator circulation runs around the perimeter. Barracks east.');

// C5: utility campus with staggered generator halls and an exposed service court.
rect(418,218,482,282,floor);rect(447,211,453,289,road);
hall('Western energy generator',420,258,441,281,dark);hall('Eastern energy generator',459,258,480,281,dark);
hall('Planetary grid control',425,222,475,241);
for(const [x,y]of [[426,275],[435,263],[464,263],[474,275]])prop(x,y,'/obj/ViltrumConsole/Reactor');
for(const x of [432,443,457,468])prop(x,237,furn+'/ArchiveTable');
consoleAt(430,226,'Planetary grid diagnostics','Generator service court north. Research northwest; fabrication southwest. Grid diagnostics nominal. Keep generator approaches clear.');
point('Energy service court',450,250);

// D2: freight apron, two asymmetric hangars and a maintenance bay.
rect(119,119,181,181,dark);rect(145,101,155,200,road);
hall('Western transit hangar',120,145,140,179,dark);hall('Eastern transit hangar',160,138,181,179,dark);
hall('Shipyard maintenance',120,118,139,135);for(const x of [124,135])prop(x,131,extra+'/Workbench');
for(const [x,y]of [[124,151],[136,173],[165,143],[177,173]])prop(x,y,extra+'/FreightCrate');
consoleAt(123,149,'Freight dispatch','Clear freight apron east. Imperial terminal is east along either perimeter route. Maintenance south. Hangars are public staging interiors.');point('Freight apron',150,150);

// D4: two long fabrication halls and a lower warehouse; large open repair court.
rect(319,119,381,181,floor);rect(347,111,353,189,road);
hall('Precision fabrication',320,153,341,181,dark);hall('Repair facility',359,149,381,181,dark);hall('Freight warehouse',325,119,375,138,dark);
for(const [x,y]of [[325,176],[336,157],[364,176],[377,154]])prop(x,y,extra+'/Workbench');
for(const x of [330,340,360,370])prop(x,133,extra+'/FreightCrate');
consoleAt(326,157,'Fabrication orders','Precision hall west; repairs east; freight warehouse south. Open service court connects the spaceport and energy works.');point('Repair court',350,145);

// Sparse wayfinding markers stand beside, never inside, the seven-tile roads.
for(const district of spec.districts){const [x,y]=district.bounds;consoleAt(x+14,y+13,district.name,`${district.name}. Both perimeter boulevards lead back toward the capital forum at 250,250 and planet arrival at 250,78.`);}
const updates=[];
for(let row=0;row<5;row++)for(let col=0;col<5;col++){
 const file=`Viltrum${'ABCDE'[row]}${col+1}.dmm`,content=serialize(grid.slice(row*100,row*100+100).map(r=>r.slice(col*100,col*100+100)));
 if(hash(content)!==planet.chunkHashes[file])updates.push({file,content});
}
spec.changedChunks=updates.map(v=>v.file);
const target=path.join(root,'docs/Maps/ViltrumCapital.json');if(fs.existsSync(target))throw Error('Capital specification already exists; refusing replacement.');
// Recoverable snapshot before source writes; all content is serialized first.
const backup=path.join(root,'docs/Maps/RebuildBaseline/BeforeCapital');if(fs.existsSync(backup))throw Error('Capital backup exists; inspect prior application first.');
fs.mkdirSync(backup);for(const {file}of updates)fs.copyFileSync(path.join(planet.paths.directory,file),path.join(backup,file));
for(const {file,content}of updates)fs.writeFileSync(path.join(planet.paths.directory,file),content);
fs.writeFileSync(target,JSON.stringify(spec,null,2)+'\n');
console.log(`Authored ${updates.length} capital chunks, ${spec.buildings.length} public buildings and ${spec.points.length} destinations.`);
