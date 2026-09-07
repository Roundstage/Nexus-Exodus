'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root,loadPlanet}=require('./PlanetChunks.cjs'),{serialize,hash,splitOutside}=require('./Dmm.cjs');
if(process.argv.length!==2)throw Error('No overwrite options.');
const p=loadPlanet('Viltrum'),prior=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/CapitalAssembly.json')));
assert.equal(hash(fs.readFileSync(p.paths.output)),prior.outputHash,'Generated output changed; recover edits first.');
for(const [file,digest]of Object.entries(prior.chunkHashes))assert.equal(p.chunkHashes[file],digest,`Changed source: ${file}`);
const grid=p.grid,land='/turf/ViltrumLandscape',ground='/turf/ViltrumGround',sea='/turf/ViltrumOcean',floor='/turf/ViltrumFloor',road=floor+'/Road',roof='/turf/ViltrumRoof',wall='/turf/ViltrumWall',furn='/obj/ViltrumFurnishing',extra='/obj/ViltrumCapitalFurnishing';
const manual=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/ManualOutputDelta.json'))),protectedTiles=new Set(manual.map(v=>`${v.x},${v.y}`));
const spec={phase:4,points:[],publicRooms:[],buildings:[],combatSpaces:[],changedChunks:[],boundaryWidth:8,manualPreservedTiles:manual.length,review:'Atlas and headless checks; interactive day/night, combat and movement review deferred by user.'};
function put(x,y,type,objects=[]){if(x<1||x>500||y<1||y>500)throw Error('Outside map');if(protectedTiles.has(`${x},${y}`))return;grid[500-y][x-1]=[...objects,type,'/area/Viltrum'].join(',');}
function rect(a,b,c,d,type){for(let y=b;y<=d;y++)for(let x=a;x<=c;x++)put(x,y,type);}
function disc(cx,cy,rx,ry,type){for(let y=Math.max(9,cy-ry);y<=Math.min(492,cy+ry);y++)for(let x=Math.max(9,cx-rx);x<=Math.min(492,cx+rx);x++)if(((x-cx)/rx)**2+((y-cy)/ry)**2<=1)put(x,y,type);}
function route(points,width=7){for(let n=1;n<points.length;n++){const [a,b]=points[n-1],[c,d]=points[n];assert(a===c||b===d,'Routes must be cardinal');const r=(width-1)/2;rect(Math.min(a,c)-r,Math.min(b,d)-r,Math.max(a,c)+r,Math.max(b,d)+r,road);}}
function prop(x,y,type){const atoms=splitOutside(grid[500-y][x-1],',');put(x,y,atoms.at(-2),[type]);}
function directory(x,y,name,text){prop(x,y,`/obj/ViltrumConsole{name = ${JSON.stringify(name)}; status_text = ${JSON.stringify(text)}}`);}
function point(name,x,y){spec.points.push({name,x,y});}
function hall(name,a,b,c,d){rect(a,b,c,d,roof);rect(a+1,b+1,c-1,d-1,floor);const cx=Math.floor((a+c)/2),cy=Math.floor((b+d)/2);for(const y of [b,d])rect(cx-2,y,cx+2,y,floor);for(const x of [a,c])rect(x,cy-2,x,cy+2,floor);for(let x=a;x<=c;x++)if(Math.abs(x-cx)>2)put(x,b-1,wall);spec.publicRooms.push([a+1,b+1,c-1,d-1]);spec.buildings.push({name,bounds:[a,b,c,d],entrances:[[cx,b],[cx,d],[a,cy],[c,cy]]});point(name,cx,cy);}
const untouchedCapital=new Set(['B2','B3','B4','C1','C2','C3','C4','C5','D2','D3','D4']);
function chunkAt(x,y){return `${'ABCDE'[Math.floor((500-y)/100)]}${Math.floor((x-1)/100)+1}`;}
// A continuous coastline function, evaluated in global coordinates, avoids seams.
function coastDistance(x,y){
 const center=250+9*Math.sin(y/49),half=221-0.006*Math.max(0,y-340)**2-0.006*Math.max(0,145-y)**2;
 return Math.min(x-(center-half),(center+half)-x,y-31,481-y);
}
for(let y=9;y<=492;y++)for(let x=9;x<=492;x++){
 if(untouchedCapital.has(chunkAt(x,y)))continue;
 // Keep the slice apron, terminal approaches and every recovered edit intact.
 if(chunkAt(x,y)==='E3' && x>=205&&x<=295&&y>=60)continue;
 const distance=coastDistance(x,y),polarLine=431+9*Math.sin(x/27);
 let type=distance< -6?sea:distance<0?sea+'/Shallow':distance<4?land+'/Shore':y>polarLine?land+'/Snow':y>405?land+'/Ice':y<190?land+'/Crater':land;
 if(distance>5&&y>190&&y<405)type=(Math.sin(x/19)+Math.cos(y/23)>.8)?land+'/Garden':ground;
 put(x,y,type);
}
// Remote northern islands and two separate seven-tile causeways to each.
for(const x of [72,428]){disc(x,451,25,22,land+'/Shore');disc(x,451,20,17,land+'/Ice');disc(x,451,12,10,floor);}
route([[72,445],[135,445]]);route([[72,457],[135,457]]);route([[365,445],[428,445]]);route([[365,457],[428,457]]);
prop(72,454,extra+'/CommunicationsMast');point('Northwest remote beacon',72,450);
directory(76,454,'Northwest beacon','Coastal beacon online. Two causeways lead east to the polar route and the defense citadel.');
hall('Offshore defense platform',417,443,439,460);prop(422,456,extra+'/CommunicationsMast');
// Polar circuit: broad double routes connecting the escarpment, citadel and preserve.
route([[110,401],[110,469],[390,469],[390,401]]);route([[190,401],[190,429],[310,429],[310,401]]);
route([[110,419],[390,419]]);route([[150,419],[150,469]]);route([[350,419],[350,469]]);
// A2: terraced escarpment with a reachable cave/event chamber, no required portal.
disc(153,450,26,20,land);disc(153,450,20,14,land+'/Rough');hall('Polar survey cavern',139,438,166,460);
for(const x of [143,162])prop(x,456,extra+'/FreightCrate');directory(143,442,'Polar survey record','Ancient strata exposed beneath the escarpment. Survey chamber open. Citadel east; beacon west.');
// A3: citadel's twin wings enclose a fifty-tile parade ground.
rect(219,421,281,479,floor);hall('Defense command',222,457,278,478);hall('West defense wing',217,425,230,449);hall('East defense wing',270,425,283,449);
rect(233,424,267,452,'/turf/ViltrumDistrictFloor/Arena');point('Citadel parade court',250,438);
for(const x of [225,275])prop(x,445,extra+'/CommunicationsMast');for(const x of [228,242,258,272])prop(x,474,furn+'/ArchiveTable');
route([[245,400],[245,419]]);route([[255,400],[255,419]]);route([[209,400],[209,419]]);route([[291,400],[291,419]]);
directory(226,462,'Defense command directory','Twin defense wings face the parade court. Palace south; polar survey west; preserve east.');
// A4: open ice lake surrounded by engineered gardens and an observation lodge.
disc(350,449,28,18,land+'/Garden');disc(350,449,21,13,land+'/Ice');hall('Polar preserve lodge',326,474,374,488);
for(const x of [333,367])prop(x,484,furn+'/Bench');point('Polar preserve training loop',350,449);
// B1: aqueduct and cliff route; two crossings preserve walking access.
rect(52,313,58,388,sea+'/Shallow');route([[90,301],[90,400]]);route([[24,310],[100,310]]);route([[24,390],[100,390]]);
route([[38,319],[38,381]]);route([[38,331],[90,331]]);route([[38,369],[90,369]]);
hall('Western aqueduct control',64,345,81,361);prop(68,357,'/obj/ViltrumConsole/Reactor');point('Western aqueduct terrace',55,331);
directory(68,349,'Aqueduct pressure station','Reservoir channel runs north-south. Use the southern and northern crossings. Residential terraces east; training grounds south.');
// B5: cliff terraces and service station with visible alternate approaches.
route([[410,301],[410,400]]);route([[410,310],[476,310],[476,390],[410,390]]);
hall('Eastern cliff service station',440,338,461,363);prop(445,359,extra+'/Workbench');point('Eastern scenic overlook',476,350);
directory(445,342,'Cliff service records','Eastern maintenance passage. Science enclave west; energy works south. Cliff terrace loop open.');
// D1: crater rings surround a deliberately clear sparring basin and a ruin lodge.
disc(52,150,34,34,land+'/Rough');disc(52,150,29,29,land+'/Crater');rect(37,135,66,164,land+'/Crater');
spec.combatSpaces.push({name:'Badlands impact basin',bounds:[37,135,66,164],minimum:28});point('Badlands impact basin',52,150);
route([[90,101],[90,200]]);route([[22,110],[100,110]]);route([[22,190],[100,190]]);hall('Badlands survey shelter',28,174,67,187);
prop(33,182,extra+'/Workbench');prop(62,182,extra+'/FreightCrate');
// D5: ruined research wings, accessible court and a preserved manual floor patch.
disc(449,151,38,33,land+'/Ruins');route([[410,101],[410,200]]);route([[410,110],[477,110],[477,190],[410,190]]);
hall('Abandoned west laboratory',424,152,443,177);hall('Abandoned east laboratory',458,139,477,167);
for(const [x,y]of [[428,173],[439,157],[462,162],[473,144]])prop(x,y,extra+'/Workbench');point('Ruined research court',450,150);
directory(429,157,'Recovered research log','Archive fragment: the eastern array was evacuated before the last polar storm. Two laboratory wings remain accessible around the open court.');
// Southern coastal route preserves the E3 landing and all user-authored paving.
route([[110,100],[110,53],[210,53],[210,59]]);route([[390,100],[390,53],[290,53],[290,59]]);
route([[190,100],[190,96]]);route([[310,100],[310,96]]);
hall('Southern watch post',132,43,163,62);prop(137,58,extra+'/CommunicationsMast');
hall('Southeast communications station',338,43,369,62);prop(344,58,extra+'/CommunicationsMast');prop(363,58,extra+'/CommunicationsMast');
directory(343,47,'Southern relay','Polar relay synchronized. Follow the coast west to the landing apron, or north toward fabrication.');
// Keep the old landing's secondary terraces joined to the new coastal routes.
route([[190,96],[209,96]]);route([[291,96],[310,96]]);
// Regional floor material accents preserve atom stacks and user edits exactly.
const accents=[{bounds:[230,352,270,382],type:'Palace'},{bounds:[320,360,342,380],type:'Laboratory'},{bounds:[360,356,380,380],type:'Laboratory'},{bounds:[326,221,373,268],type:'Arena'},{bounds:[121,146,139,178],type:'Grate'},{bounds:[360,150,380,180],type:'Grate'}];
for(const {bounds:[a,b,c,d],type}of accents)for(let y=b;y<=d;y++)for(let x=a;x<=c;x++){
 if(protectedTiles.has(`${x},${y}`))continue;
 const atoms=splitOutside(grid[500-y][x-1],',');if(atoms.at(-2).startsWith(floor)){atoms[atoms.length-2]=`/turf/ViltrumDistrictFloor/${type}`;grid[500-y][x-1]=atoms.join(',');}
}
// Inaccessible eight-tile storm belt catches direct teleport arrivals as well.
rect(1,1,500,8,sea+'/Boundary');rect(1,493,500,500,sea+'/Boundary');rect(1,9,8,492,sea+'/Boundary');rect(493,9,500,492,sea+'/Boundary');
for(const {x,y,output}of manual)assert.equal(grid[500-y][x-1],output,`Manual edit lost ${x},${y}`);
const backup=path.join(root,'docs/Maps/RebuildBaseline/BeforeWilderness');assert(!fs.existsSync(backup),'Already authored');
const updates=[];for(let row=0;row<5;row++)for(let col=0;col<5;col++){const file=`Viltrum${'ABCDE'[row]}${col+1}.dmm`,content=serialize(grid.slice(row*100,row*100+100).map(r=>r.slice(col*100,col*100+100)));if(hash(content)!==p.chunkHashes[file])updates.push({file,content});}
fs.mkdirSync(backup);for(const {file,content}of updates){fs.copyFileSync(path.join(p.paths.directory,file),path.join(backup,file));fs.writeFileSync(path.join(p.paths.directory,file),content);}
spec.changedChunks=updates.map(v=>v.file);fs.writeFileSync(path.join(root,'docs/Maps/ViltrumWilderness.json'),JSON.stringify(spec,null,2)+'\n');console.log(`Authored wilderness, coastline, outposts and boundary in ${updates.length} chunks; all ${manual.length} manual edits preserved.`);
