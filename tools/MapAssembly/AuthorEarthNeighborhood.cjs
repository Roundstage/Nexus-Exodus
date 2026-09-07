'use strict';
// Reserve streets and frontage before placing ordinary neighboring houses.
// Default is a reviewable preview. --apply checks hashes and retains a baseline.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root,loadPlanet,assemble}=require('./PlanetChunks.cjs');
if(fs.existsSync(path.join(root,'docs/Maps/EarthWilderness.json')))throw Error('Historical neighborhood generator retired after wilderness refinement. Edit current chunks or use AuthorEarthWilderness.cjs with its preservation guards.');
const {parse,serialize,hash,splitOutside}=require('./Dmm.cjs');
const read=file=>JSON.parse(fs.readFileSync(path.join(root,file),'utf8'));
const p=loadPlanet('SuperEarth'),meta=read('src/Maps/SuperEarthMetadata.json');
assert.equal(hash(fs.readFileSync(p.paths.output)),meta.outputHash,'Recover manual output edits first.');
assert.deepEqual(p.chunkHashes,meta.chunkHashes,'Assemble/review source edits first.');
const backup=path.join(root,'docs/Maps/RebuildBaseline/BeforeEarthNeighborhood');
const exists=fs.existsSync(backup),previous=exists?read('docs/Maps/EarthNeighborhood.json'):null;
if(exists){
 assert.equal(meta.outputHash,previous.outputHash,'City changed since last authoring pass.');
 assert.deepEqual(meta.chunkHashes,previous.chunkHashes,'City chunks changed since last authoring pass.');
 assert.equal(hash(fs.readFileSync(path.join(root,'src/Maps/CityInteriors.dmm'))),previous.interiorHash,'Interiors changed since last authoring pass; recover these edits first.');
 assert.equal(hash(fs.readFileSync(path.join(root,'docs/Maps/CityBuildings.json'))),previous.buildingDataHash,'Building registry changed since last authoring pass; recover these edits first.');
}
const baseline=parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/SuperEarth.dmm'),'utf8')).grid;
const riverRevision=require('./AuthorEarthRiver.cjs').authorRiverChannel(baseline);
const original=exists?parse(fs.readFileSync(path.join(backup,'SuperEarth.dmm'),'utf8')).grid:p.grid;
const grid=original.map(r=>r.slice());
const data=exists?JSON.parse(fs.readFileSync(path.join(backup,'CityBuildings.json'))):read('docs/Maps/CityBuildings.json');
const interiorSource=parse(fs.readFileSync(exists?path.join(backup,'CityInteriors.dmm'):path.join(root,'src/Maps/CityInteriors.dmm'),'utf8'));
const interiorHeight=300;
const interiors=Array.from({length:interiorHeight-interiorSource.height},()=>Array(400).fill('/turf/CityBuildingFootprint,/area/CityInterior')).concat(interiorSource.grid.map(r=>r.slice()));
const AREA='/area/SuperEarth',STREET='/turf/EarthStreet',LAWN=STREET+'/Lawn';
const buildings=data.buildings.filter(b=>b.planet==='SuperEarth'),byName=new Map(buildings.map(b=>[b.name,b]));
const mainNames=new Set(read('docs/Maps/SuperEarthSlice.json').buildings.map(b=>b.name));
const combat=[...read('docs/Maps/SuperEarthSlice.json').combatSpaces,...read('docs/Maps/SuperEarthRegions.json').combatSpaces].map(b=>b.bounds);
const index=(x,y)=>(y-1)*500+x-1,key=(x,y)=>`${x},${y}`;
const atoms=(x,y)=>splitOutside(grid[500-y][x-1],','),type=(x,y)=>atoms(x,y).at(-2);
const inBounds=(x,y)=>x>=9&&y>=9&&x<=492&&y<=492;
const protectedTile=(x,y)=>!inBounds(x,y)||Math.abs(x-101)<=10&&Math.abs(y-362)<=10||[[368,342],[184,96]].some(([a,b])=>Math.abs(x-a)<=24&&Math.abs(y-b)<=4)||['/turf/WaterFall','/turf/Stairs_Grass'].includes(splitOutside(baseline[500-y][x-1],',').at(-2))||splitOutside(original[500-y][x-1],',').some(a=>a.startsWith('/obj/Spawn'));
const inCombat=(x,y)=>combat.some(([a,b,c,d])=>x>=a&&x<=c&&y>=b&&y<=d);
const water=(x,y)=>/\/turf\/(Water|EarthOceanBoundary)/.test(baseline[500-y][x-1]);
const roadTile=t=>t==='/turf/EarthFloor/Road'||t==='/turf/EarthBridge'||t===STREET||/^\/turf\/EarthStreet\/(Lane|Crossing|Bridge)/.test(t);
const roads=new Set(),occupied=new Set(),sidewalk=new Set(),promenade=new Set();
const report={version:2,design:'Ordinary adjacent houses on aligned frontages; separate interiors',cityBounds:[50,263,189,394],rows:[],streets:[],decorations:[],buildings:[],accessibleHomes:[],preservedArrivalTiles:441};
report.riverRevision=riverRevision;
function put(x,y,t,objects=[]){
 assert(inBounds(x,y));if(protectedTile(x,y))return false;
 assert(!water(x,y)||t==='/turf/EarthBridge'||t.startsWith(STREET+'/Bridge')||t==='/turf/Water2',`Water lost ${x},${y}: ${t}`);
 grid[500-y][x-1]=[...objects,t,AREA].join(',');return true;
}
function rect(a,b,c,d,t){for(let y=b;y<=d;y++)for(let x=a;x<=c;x++)if(!protectedTile(x,y)&&!water(x,y))put(x,y,t);}
function restore(x,y){
 if(protectedTile(x,y)||inCombat(x,y))return;
 const natural=splitOutside(baseline[500-y][x-1],',').at(-2);
 put(x,y,natural);
}
// Remove the superseded exterior objects and their original oversized paved lots.
for(const b of buildings){
 for(const [a,y,c,d] of [b.originalBounds,[b.bounds[0]-2,b.bounds[1]-2,b.bounds[2]+2,b.bounds[3]+2]])
  for(let yy=y-1;yy<=d;yy++)for(let x=a;x<=c;x++)if(!roadTile(type(x,yy)))restore(x,yy);
 const [x,y]=b.door;if(!protectedTile(x,y)&&!roadTile(type(x,y)))restore(x,y);
}
for(let y=260;y<=410;y++)for(let x=41;x<=210;x++)if(!protectedTile(x,y)&&!inCombat(x,y)){
 const natural=splitOutside(baseline[500-y][x-1],',').at(-2);
 if(natural==='/turf/WaterFall'||natural==='/turf/Stairs_Grass')continue;
 if(water(x,y)){
  put(x,y,'/turf/Water2');
 }else put(x,y,LAWN);
}
function street(a,b,c,d,width=7,bridge=false){
 assert(a===c||b===d);const r=(width-1)/2;const horizontal=b===d;
 report.streets.push({points:[[a,b],[c,d]],width});
 for(let y=Math.min(b,d)-r;y<=Math.max(b,d)+r;y++)for(let x=Math.min(a,c)-r;x<=Math.max(a,c)+r;x++){
  if(protectedTile(x,y)||inCombat(x,y))continue;
  assert(!water(x,y)||bridge,`Road requires an authored crossing at ${x},${y}`);
  const t=water(x,y)?'/turf/EarthBridge':STREET;
  put(x,y,t);roads.add(key(x,y));
 }
 // Sidewalks are exactly two clear tiles; fixture planting goes behind them.
 for(let y=Math.min(b,d)-r-2;y<=Math.max(b,d)+r+2;y++)for(let x=Math.min(a,c)-r-2;x<=Math.max(a,c)+r+2;x++){
  if(protectedTile(x,y)||inCombat(x,y)||water(x,y)||roads.has(key(x,y))||roadTile(type(x,y)))continue;
  put(x,y,STREET+'/Sidewalk');sidewalk.add(key(x,y));
 }
 for(let v=Math.min(horizontal?a:b,horizontal?c:d);v<=Math.max(horizontal?a:b,horizontal?c:d);v++){
  const x=horizontal?v:a,y=horizontal?b:v;
  if(roads.has(key(x,y))&&!water(x,y))put(x,y,STREET+(horizontal?'/LaneHorizontal':'/LaneVertical'));
 }
}
// Main street bends around the arrival park instead of being cut by its lawn.
street(48,255,48,414);street(96,255,96,334);street(85,334,96,334);
street(85,334,85,374);street(85,374,96,374);street(96,374,96,414);
// The eastern avenue is set back from every bend in the river.
street(163,259,163,398);street(194,259,194,354);
street(48,398,214,398,7,true);street(48,314,194,314,7,true);
street(48,291,124,291);street(163,291,194,291);
street(48,374,117,374);street(48,354,85,354);street(48,334,120,334);
street(48,267,128,267);street(163,267,194,267);
street(163,374,187,374);street(163,354,194,354);street(163,334,194,334);
// An unbroken three-tile river walk follows the actual banks. Streets that do
// not cross the river stop inland of it; houses must also respect this reserve.
const riverEdges=[];
for(let y=260;y<=410;y++){
 const wet=[];for(let x=112;x<=174;x++)if(water(x,y))wet.push(x);
 if(!wet.length)continue;riverEdges.push({y,left:Math.min(...wet),right:Math.max(...wet)});
}
for(const side of ['left','right']){let last;
 for(const edge of riverEdges){const y=edge.y,x=y>=348&&y<=352?(side==='left'?129:157):edge[side]+(side==='left'?-5:5);
  for(let xx=Math.min(x,last??x)-1;xx<=Math.max(x,last??x)+1;xx++)if(!water(xx,y)&&!protectedTile(xx,y)&&!inCombat(xx,y)&&!roads.has(key(xx,y))){put(xx,y,STREET+'/GardenPath');promenade.add(key(xx,y));}
  last=x;
 }
}
report.riverEdges=riverEdges;report.bridges=[];
// Each bridge is a single bank-to-bank deck: seven road tiles, two walking
// tiles on each side and a parapet. End supports are wholly on land.
for(const cy of [314,398]){
 const section=riverEdges.filter(e=>Math.abs(e.y-cy)<=6),a=Math.min(...section.map(e=>e.left))-4,c=Math.max(...section.map(e=>e.right))+4;
 for(let y=cy-6;y<=cy+6;y++)for(let x=a;x<=c;x++){
  const distance=Math.abs(y-cy),t=distance===6?STREET+'/Bridge/'+(y>cy?'North':'South'):distance>=4?STREET+'/Bridge/Sidewalk':y===cy?STREET+'/Bridge/Lane':STREET+'/Bridge';
  assert(!protectedTile(x,y)&&!inCombat(x,y));put(x,y,t);roads.add(key(x,y));
 }
 report.bridges.push({name:cy===314?'Market bridge':'North bridge',bounds:[a,cy-6,c,cy+6],roadBounds:[a,cy-3,c,cy+3],abutments:[[a,cy],[c,cy]],riverBanks:[Math.min(...section.map(e=>e.left)),Math.max(...section.map(e=>e.right))]});
}
// A short rocky lip supports the existing falls. Its surrounds join the park
// instead of retaining a 45-tile straight scar across the city.
for(let x=131;x<=149;x++)if(!water(x,350)&&!protectedTile(x,350)&&!promenade.has(key(x,350)))put(x,350,'/turf/Wall12');
for(let y=263;y<=400;y++)for(let x=41;x<=198;x++)if(roadTile(type(x,y)))roads.add(key(x,y));

const houseTypes=['/obj/EarthHouse','/obj/EarthHouse/Sage','/obj/EarthHouse/Brick','/obj/EarthHouse/Blue'];
function styleFor(name){
 if(/townhouse/i.test(name))return '';
 if(/hospital|clinic|pharmacy/i.test(name))return 'Hospital';
 if(/repair|workshop|manufactur|warehouse/i.test(name))return 'Garage';
 if(/shop|market|grocery|cafe|trading/i.test(name))return 'Shop';
 if(/office|terminal|school|library|city hall|college|laborator|research|station|outpost|lighthouse|shelter/i.test(name))return 'Civic';
 return '';
}
let nextSlot=data.buildings.length,homeIndex=0;
function place(name,a,b,{existing=null,accessible=false,row='Regional',variant=0}={}){
 const style=styleFor(name),w=style?7:5,h=6,t=style?'/obj/EarthHouse/'+style:houseTypes[variant%4];
 for(let y=b;y<b+h;y++)for(let x=a;x<a+w;x++){
  assert(!protectedTile(x,y)&&!water(x,y)&&!inCombat(x,y)&&!roads.has(key(x,y))&&!promenade.has(key(x,y))&&!occupied.has(key(x,y)),`Bad building lot ${name}: ${x},${y}`);
 }
 const door=[a+Math.floor(w/2),b-1,21];
 for(let x=a;x<a+w;x++)for(const y of [b-1,b-2])assert(!occupied.has(key(x,y))&&!roads.has(key(x,y))&&!water(x,y)&&!protectedTile(x,y),`Frontage blocked ${name}: ${x},${y}`);
 let record=existing;
 if(accessible&&!record){
  const s=nextSlot++,ix=s%10*40+5,iy=Math.floor(s/10)*30+5;
  record={planet:'SuperEarth',id:'earth_home_'+String(++homeIndex).padStart(3,'0'),name,originalBounds:[a,b,a+w-1,b+h-1],interiorBounds:[ix,iy,ix+13,iy+11],props:[]};
  data.buildings.push(record);report.accessibleHomes.push(record.id);
 }
 const buildingId=record?.id||`earth_facade_${row}_${a}_${b}`;
 const artState=style?style.toLowerCase():['cream','sage','brick','blue'][variant%4];
 for(let y=b;y<b+h;y++)for(let x=a;x<a+w;x++){put(x,y,`/turf/EarthBuildingStructure{icon_state = "${artState}_${x-a}_${y-b}"}`);occupied.add(key(x,y));}
 put(a,b,`/turf/EarthBuildingStructure{icon_state = "${artState}_0_0"}`,[`${t}{name = ${JSON.stringify(name)}; building_id = "${buildingId}"}`]);
 rect(a,b-2,a+w-1,b-1,STREET+'/Sidewalk');
 if(record){
  Object.assign(record,{name,style:style.toLowerCase()||['cream','sage','brick','blue'][variant%4],type:t,bounds:[a,b,a+w-1,b+h-1],door,return:[door[0],door[1]-1,21]});
  // Interiors are populated once all frontage coordinates have been finalized.
  record.neighborhood=true;
 } else put(...door.slice(0,2),STREET+'/Sidewalk');
 report.buildings.push({id:buildingId,name,type:t,style:style.toLowerCase()||['cream','sage','brick','blue'][variant%4],bounds:[a,b,a+w-1,b+h-1],door,accessible:!!record,row});
 return w;
}
function row(id,x,b,entries){
 const first=x,rowBuildings=[];
 for(let i=0;i<entries.length;i++){
  const name=entries[i]||`${id} townhouse ${i+1}`,existing=byName.get(name);
  const w=place(name,x,b,{existing,accessible:!existing&&i===1,row:id,variant:i+report.rows.length});
  rowBuildings.push([x,b,x+w-1,b+5]);x+=w;
 }
 // Backyards fit between this row and the next street, with a 3-tile route
 // around either end. Fence only the rear edge; never fence a walking exit.
 for(let xx=first;xx<x;xx++)for(let y=b+6;y<=b+10;y++){
  if(protectedTile(xx,y)||inCombat(xx,y)||water(xx,y)||roads.has(key(xx,y))||sidewalk.has(key(xx,y))||promenade.has(key(xx,y)))continue;
  put(xx,y,LAWN);
 }
 report.rows.push({id,bounds:[first,b,x-1,b+5],buildings:rowBuildings});
}
row('GardenRow',54,380,['Garden house',null,null,null,null,null]);
row('StationRow',54,360,['Arrival park terminal',null,null,null,null]);
row('HospitalRow',54,340,['West city hospital',null,null,null,null]);
row('WestTerrace',54,320,['West terrace home',null,null,null,null,null]);
row('CafeRow',54,297,['Old town cafe',null,null,null,null,null]);
row('SouthTerrace',54,273,[null,null,null,null,null,null]);
row('RiverNorth',103,380,['Corner apartment',null,null]);
row('RiverClinic',103,340,['Neighborhood pharmacy',null,null]);
row('RiverTerrace',103,320,['East terrace home',null,null]);
row('BookRow',103,297,['Bookshop',null,null]);
row('GroceryRow',103,273,['Corner grocery',null,null]);
row('MarketRow',170,380,['Neighborhood supermarket',null,null]);
row('LibraryRow',170,360,['School library','Community school and dojo',null]);
row('TransitRow',170,320,['Regional transit office',null,null]);
row('CivicRow',170,297,['City hall',null,null]);

// Keep the regional POIs and southern workshops, with compact footprints/art.
for(const record of buildings)if(!report.buildings.some(b=>b.id===record.id)){
 const style=styleFor(record.name),w=style?7:5;
 const [dx,dy]=record.door;place(record.name,dx-Math.floor(w/2),dy+1,{existing:record,variant:report.buildings.length});
}

// Paint curb edges only where they touch a road, preserving the full sidewalk.
for(const position of sidewalk){const [x,y]=position.split(',').map(Number);
 if(type(x,y)!==STREET+'/Sidewalk')continue;
 const side=roads.has(key(x,y+1))?'North':roads.has(key(x,y-1))?'South':roads.has(key(x-1,y))?'West':roads.has(key(x+1,y))?'East':null;
 if(side)put(x,y,STREET+'/Curb'+side);
}
// Crossings on the busy north/south streets; no lane markings through junctions.
for(const cx of [96,163])for(const cy of [291,314,334,374,398]){
 for(let y=cy-3;y<=cy+3;y++)for(let x=cx-3;x<=cx+3;x++)if(roads.has(key(x,y))&&!protectedTile(x,y)&&!water(x,y))put(x,y,STREET);
 for(const y of [cy-6,cy+6])for(let x=cx-3;x<=cx+3;x++)if(roads.has(key(x,y))&&!protectedTile(x,y)&&!water(x,y))put(x,y,STREET+'/CrossingHorizontal');
}
function fixture(x,y,t){
 if(!inBounds(x,y)||protectedTile(x,y)||inCombat(x,y)||water(x,y)||roads.has(key(x,y))||sidewalk.has(key(x,y))||promenade.has(key(x,y))||occupied.has(key(x,y))||atoms(x,y).some(v=>v.startsWith('/obj/')))return false;
 put(x,y,type(x,y),[t]);report.decorations.push({x,y,type:t});return true;
}
for(const r of report.rows){const [a,b,c,d]=r.bounds;
 // Leaves overhang their own garden strip, never the continuous front sidewalk.
 for(let x=a+2;x<=c-2;x+=10){fixture(x,d+4,'/obj/EarthStreetFixture/Tree');fixture(x+2,d+2,'/obj/EarthStreetFixture/Flowers');}
 for(let x=a;x<=c;x++)fixture(x,d+6,'/obj/EarthStreetFixture/Fence');
 fixture(a-2,b+1,'/obj/EarthStreetFixture/Lamp');fixture(c+2,b+1,'/obj/EarthStreetFixture/Bin');
}
// Small park furnishings outside the protected arrival lawn and combat squares.
for(const [x,y]of [[85,384],[86,363],[85,343],[88,323],[88,300],[126,383],[125,323],[187,384],[187,364],[187,343]]){
 fixture(x,y,'/obj/EarthStreetFixture/Bench');fixture(x,y+4,'/obj/EarthStreetFixture/Tree');
}
for(const edge of riverEdges){
 if(edge.y%11===3)fixture(edge.left-2,edge.y,'/obj/EarthStreetFixture/Tree');
 if(edge.y%13===6)fixture(edge.right+2,edge.y,'/obj/EarthStreetFixture/Tree');
 if(edge.y%7===2){fixture(edge.left-2,edge.y,'/obj/EarthStreetFixture/Flowers');fixture(edge.right+2,edge.y+1,'/obj/EarthStreetFixture/Flowers');}
}

for(const record of data.buildings.filter(b=>b.planet==='SuperEarth')){
 const [ix,iy]=record.interiorBounds,old=record.interiorBounds;
 // Clear only the old room's reserved slot, without moving Viltrum's rooms.
 for(let y=iy;y<=old[3];y++)for(let x=ix;x<=old[2];x++)interiors[interiorHeight-y][x-1]='/turf/CityBuildingFootprint,/area/CityInterior/Earth';
 const domestic=!styleFor(record.name),w=domestic?14:22,h=domestic?12:18,cx=ix+Math.floor(w/2),area='/area/CityInterior/Earth';
 const floor=/hospital|pharmacy/i.test(record.name)?'/turf/EarthFloor/Clinic':/garage|workshop|manufactur/i.test(record.name)?'/turf/EarthFloor/Concrete':'/turf/EarthFloor';
 const set=(x,y,t,objects=[])=>interiors[interiorHeight-y][x-1]=[...objects,t,area].join(',');
 for(let y=iy;y<iy+h;y++)for(let x=ix;x<ix+w;x++)set(x,y,x===ix||x===ix+w-1||y===iy||y===iy+h-1?'/turf/EarthRoof/Dark':floor);
 const sourceProps=record.props.map(p=>({atom:p.atom,original:p.original}));
 if(domestic&&!sourceProps.length)for(const [i,atom]of ['/obj/EarthFurnishing','/obj/EarthFurnishing/Dresser','/obj/EarthFurnishing/Stove','/obj/EarthFurnishing/Sink','/obj/EarthFurnishing/Table','/obj/EarthFurnishing/Chair','/obj/EarthFurnishing/Bookcase'].entries())sourceProps.push({atom,original:null});
 const positions=[];
 // Side walls hold storage/beds, the central circulation strip stays three wide.
 for(let y=iy+h-3;y>=iy+3;y-=3)for(let x=ix+2;x<ix+w-2;x+=3)if(Math.abs(x-cx)>1)positions.push([x,y]);
 assert(sourceProps.length<=positions.length,`Furniture exceeds room capacity: ${record.name}`);
 record.props=sourceProps.map((p,i)=>{const [x,y]=positions[i];set(x,y,floor,[p.atom]);return {...p,position:[x,y,22]};});
 record.interiorBounds=[ix,iy,ix+w-1,iy+h-1];record.entry=[cx,iy+3,22];record.exits=[[cx,iy+1,22],[cx,iy+h-2,22]];
 for(const [x,y]of record.exits)set(x,y,floor,[`/obj/CityBuildingDoor/Earth/Exit{building_id = "${record.id}"; target_x = ${record.return[0]}; target_y = ${record.return[1]}; target_z = 21}`]);
 put(...record.door.slice(0,2),STREET+'/Sidewalk',[`/obj/CityBuildingDoor/Earth{name = ${JSON.stringify('Enter '+record.name)}; building_id = "${record.id}"; target_x = ${record.entry[0]}; target_y = ${record.entry[1]}; target_z = 22}`]);
}
data.interiorDimensions=[400,interiorHeight];
report.terrain=require('./EarthRiverTerrain.cjs').applyRiverTerrain(grid,baseline);
const spawns=g=>g.flatMap((r,row)=>r.flatMap((s,col)=>splitOutside(s,',').filter(a=>a.startsWith('/obj/Spawn')).map(atom=>({x:col+1,y:500-row,atom}))));
assert.deepEqual(spawns(grid),spawns(original),'All spawn coordinates/fields must survive.');
const out=path.join(root,'.codex-tmp/EarthNeighborhood');fs.mkdirSync(out,{recursive:true});
const output=serialize(grid),outputHash=hash(output),interiorOutput=serialize(interiors);
report.outputHash=outputHash;report.interiorHash=hash(interiorOutput);report.buildingDataHash=hash(JSON.stringify(data,null,2)+'\n');report.beforeHash=hash(serialize(original));report.totalBuildings=report.buildings.length;report.accessibleBuildings=data.buildings.filter(b=>b.planet==='SuperEarth').length;
const updates=[];report.chunkHashes={};for(let row=0;row<5;row++)for(let col=0;col<5;col++){
 const file=`SuperEarth${'ABCDE'[row]}${col+1}.dmm`,content=serialize(grid.slice(row*100,row*100+100).map(r=>r.slice(col*100,col*100+100)));report.chunkHashes[file]=hash(content);if(hash(content)!==p.chunkHashes[file])updates.push({file,content});
}
report.changedChunks=updates.map(c=>c.file);
fs.writeFileSync(path.join(out,'SuperEarth.dmm'),output);fs.writeFileSync(path.join(out,'CityInteriors.dmm'),interiorOutput);
fs.writeFileSync(path.join(out,'CityBuildings.json'),JSON.stringify(data,null,2)+'\n');fs.writeFileSync(path.join(out,'EarthNeighborhood.json'),JSON.stringify(report,null,2)+'\n');
const palette=[...new Set(grid.flat())].sort(),lookup=new Map(palette.map((v,i)=>[v,i]));fs.writeFileSync(path.join(out,'Preview.json'),JSON.stringify({planet:'SuperEarth',baseline:false,palette,grid:grid.map(r=>r.map(v=>lookup.get(v)))}));
if(process.argv.includes('--apply')){
 if(!exists){fs.mkdirSync(backup);for(const file of ['SuperEarth.dmm','SuperEarthMetadata.json','CityInteriors.dmm'])fs.copyFileSync(path.join(root,'src/Maps',file),path.join(backup,file));fs.copyFileSync(path.join(root,'docs/Maps/CityBuildings.json'),path.join(backup,'CityBuildings.json'));for(const file of Object.keys(p.chunkHashes))fs.copyFileSync(path.join(p.paths.directory,file),path.join(backup,file));}
 for(const {file,content}of updates)fs.writeFileSync(path.join(p.paths.directory,file),content);
 fs.writeFileSync(path.join(root,'src/Maps/CityInteriors.dmm'),interiorOutput);fs.writeFileSync(path.join(root,'docs/Maps/CityBuildings.json'),JSON.stringify(data,null,2)+'\n');fs.writeFileSync(path.join(root,'docs/Maps/EarthNeighborhood.json'),JSON.stringify(report,null,2)+'\n');assemble('SuperEarth');
}
console.log(JSON.stringify({mode:process.argv.includes('--apply')?'applied':'preview',buildings:report.totalBuildings,accessible:report.accessibleBuildings,rows:report.rows.length,changedChunks:report.changedChunks,outputHash},null,2));
