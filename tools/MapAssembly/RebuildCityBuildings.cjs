'use strict';
// Guarded migration from open rectangles to objects with independent interiors.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root,loadPlanet,assemble}=require('./PlanetChunks.cjs'),{parse,serialize,hash,splitOutside}=require('./Dmm.cjs');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8').replace(/^\uFEFF/,''));
const backup=path.join(root,'docs/Maps/RebuildBaseline/BeforeBuildingObjects');
assert(!fs.existsSync(backup),'Migration already applied; edit sources directly.');
const manual=new Set(read('docs/Maps/RebuildBaseline/ManualOutputDelta.json').map(p=>`${p.x},${p.y}`));
const interior=Array.from({length:240},()=>Array(400).fill('/turf/CityBuildingFootprint,/area/CityInterior'));
const report={version:1,interiorZ:22,interiorDimensions:[400,240],buildings:[],preservedManualBuildings:[],planets:{},roadConflictsResolved:[]};
const pending=[];let slot=0;
for(const planet of ['Viltrum','SuperEarth']){
 const p=loadPlanet(planet),meta=read(`src/Maps/${planet}Metadata.json`),earth=planet==='SuperEarth';
 assert.equal(hash(fs.readFileSync(p.paths.output)),meta.outputHash,'Recover manual output edits first');
 assert.deepEqual(p.chunkHashes,meta.chunkHashes,'Recover changed chunks first');
 const specs=(earth?['SuperEarthSlice','SuperEarthRegions']:['ViltrumCapital','ViltrumWilderness']).map(n=>read(`docs/Maps/${n}.json`));
 const oldBuildings=specs.flatMap(s=>s.buildings),grid=p.grid,original=grid.map(r=>r.slice()),area=earth?'/area/SuperEarth':'/area/Viltrum';
 const floor=earth?'/turf/EarthFloor/Sidewalk':'/turf/ViltrumFloor',road=earth?'/turf/EarthFloor/Road':'/turf/ViltrumFloor/Road';
 const atoms=(x,y)=>splitOutside(grid[500-y][x-1],','),type=(x,y)=>atoms(x,y).at(-2),id=(x,y)=>(y-1)*500+x-1;
 const set=(x,y,t,objects=[])=>grid[500-y][x-1]=[...objects,t,area].join(',');
 const protectedTile=(x,y)=>x<9||y<9||x>492||y>492||(!earth&&manual.has(`${x},${y}`))||(earth&&Math.abs(x-101)<=10&&Math.abs(y-362)<=10)||(!earth&&Math.abs(x-250)<=10&&Math.abs(y-78)<=10)||atoms(x,y).some(a=>a.startsWith('/obj/Spawn'))||(earth&&[[139,350],[368,342],[184,96]].some(([a,b])=>Math.abs(x-a)<=24&&Math.abs(y-b)<=4));
 const combat=specs.flatMap(s=>s.combatSpaces||[]).map(s=>s.bounds);if(!earth)combat.push([232,219,269,248]);
 const inCombat=(x,y)=>combat.some(([a,b,c,d])=>x>=a&&x<=c&&y>=b&&y<=d);
 const roads=new Uint8Array(250000),occupied=new Uint8Array(250000);
 for(let y=1;y<=500;y++)for(let x=1;x<=500;x++)if(type(x,y)===road||earth&&type(x,y)==='/turf/EarthBridge')roads[id(x,y)]=1;
 if(earth)for(const {points,width}of specs.flatMap(s=>s.roads))for(let i=1;i<points.length;i++){
  const [a,b]=points[i-1],[c,d]=points[i],r=(width-1)/2;
  for(let y=Math.min(b,d)-r;y<=Math.max(b,d)+r;y++)for(let x=Math.min(a,c)-r;x<=Math.max(a,c)+r;x++)if(!protectedTile(x,y)&&!inCombat(x,y))roads[id(x,y)]=1;
 }
 const migrate=oldBuildings.filter(b=>{
  const [a,y,c,d]=b.bounds;for(let yy=y-1;yy<=d;yy++)for(let x=a;x<=c;x++)if(!earth&&manual.has(`${x},${yy}`)){report.preservedManualBuildings.push({planet,name:b.name});return false;}return true;
 });
 const savedProps=new Map();
 for(const b of migrate){const [a,y,c,d]=b.bounds,props=[];
  for(let yy=y-1;yy<=d;yy++)for(let x=a;x<=c;x++)if(!protectedTile(x,yy)){
   for(const atom of atoms(x,yy).filter(a=>a.startsWith('/obj/')&&!a.startsWith('/obj/Spawn')))props.push({atom,original:[x,yy]});
   if(roads[id(x,yy)])report.roadConflictsResolved.push({planet,building:b.name,x,y:yy});
   set(x,yy,floor);
  }savedProps.set(b.name,props);
 }
 // Restore roads after removing old shells, before placing any new lot.
 for(let y=9;y<=492;y++)for(let x=9;x<=492;x++)if(roads[id(x,y)]&&!protectedTile(x,y)&&!inCombat(x,y)){
  const prior=splitOutside(original[500-y][x-1],',').at(-2);
  set(x,y,earth&&(prior==='/turf/Water2'||prior==='/turf/EarthBridge')?'/turf/EarthBridge':road);
 }
 // Sidewalks are reserved first, with two clear tiles between road and sprite.
 for(let y=11;y<=490;y++)for(let x=11;x<=490;x++)if(roads[id(x,y)])for(let dy=-2;dy<=2;dy++)for(let dx=-2;dx<=2;dx++){
  const xx=x+dx,yy=y+dy,t=type(xx,yy);
  if(!roads[id(xx,yy)]&&!protectedTile(xx,yy)&&!inCombat(xx,yy)&&!t.includes('Water')&&!t.includes('Ocean')&&!t.includes('Roof')&&!t.includes('Wall'))set(xx,yy,floor,atoms(xx,yy).filter(a=>a.startsWith('/obj/')));
 }
 const width=8,height=earth?8:10;
 function fits(a,b){
  if(a<12||b<12||a+width>489||b+height>489)return false;
  for(let y=b-2;y<=b+height+1;y++)for(let x=a-2;x<=a+width+1;x++){
   const t=type(x,y);
   if(protectedTile(x,y)||inCombat(x,y)||roads[id(x,y)]||occupied[id(x,y)]||/Water|Ocean|Roof|Wall|CityBuildingFootprint/.test(t)||atoms(x,y).some(v=>v.startsWith('/obj/')&&!v.startsWith('/obj/EarthFurnishing')&&!v.startsWith('/obj/ViltrumFurnishing')))return false;
  }return true;
 }
 for(const b of migrate){
  const [oa,ob,oc,od]=b.bounds,cx=Math.floor((oa+oc)/2),cy=Math.floor((ob+od)/2);let pos;
  const candidates=[];for(let dy=-35;dy<=35;dy++)for(let dx=-35;dx<=35;dx++)candidates.push([cx-4+dx,cy-Math.floor(height/2)+dy,Math.abs(dx)+Math.abs(dy)]);
  candidates.sort((a,b)=>a[2]-b[2]||a[1]-b[1]||a[0]-b[0]);for(const [a,y]of candidates)if(fits(a,y)){pos=[a,y];break;}
  assert(pos,`No safe building lot: ${planet} ${b.name}`);const [a,y]=pos,door=[a+3,y-1],buildingId=`${earth?'earth':'viltrum'}_${String(slot+1).padStart(3,'0')}`;
  const n=b.name.toLowerCase();let style=earth?'residence':'terrace';
  if(/hospital|clinic|medical|pharmacy/.test(n))style='hospital';else if(/palace|audience|city hall|office|college|school|archive|civic/.test(n))style='civic';else if(/lab|research|science|observatory|energy|reactor|communications/.test(n))style=earth?'civic':'science';else if(/hangar|ship|fabrication|workshop|repair|warehouse|manufactur/.test(n))style=earth?'workshop':'hangar';else if(/market|shop|grocery|dining|cafe|trading/.test(n))style=earth?'shop':'terrace';else if(/residence|apartment/.test(n))style=earth?'apartment':'residence';
  const baseType='/obj/CityHouse'+(earth?'/Earth':''),suffix={residence:'',terrace:'/Terrace',hospital:'/Hospital',civic:'/Civic',science:'/Science',hangar:'/Hangar',shop:'/Shop',workshop:'/Workshop',apartment:'/Apartment'}[style];
  for(let yy=y-2;yy<=y+height+1;yy++)for(let x=a-2;x<=a+width+1;x++){occupied[id(x,yy)]=1;set(x,yy,floor);}
  for(let yy=y;yy<y+height;yy++)for(let x=a;x<a+width;x++)set(x,yy,'/turf/CityBuildingFootprint'+(earth?'/Earth':''));
  set(a,y,'/turf/CityBuildingFootprint'+(earth?'/Earth':''),[`${baseType}${suffix}{name = ${JSON.stringify(b.name)}; building_id = "${buildingId}"}`]);
  const ix=(slot%10)*40+5,iy=Math.floor(slot/10)*30+5,iz=22,interiorArea=earth?'/area/CityInterior/Earth':'/area/CityInterior',interiorFloor=earth?'/turf/EarthFloor':'/turf/ViltrumFloor',roof=earth?'/turf/EarthRoof':'/turf/ViltrumRoof';
  const putInside=(x,y,t,objects=[])=>interior[240-y][x-1]=[...objects,t,interiorArea].join(',');
  for(let yy=iy;yy<=iy+19;yy++)for(let x=ix;x<=ix+27;x++)putInside(x,yy,x===ix||x===ix+27||yy===iy||yy===iy+19?roof:interiorFloor);
  const entry=[ix+13,iy+2],exit=[ix+13,iy+1],interiorProps=[];
  // Group furniture against the sides; preserve central navigation and both exits.
  const positions=[];for(let yy=iy+4;yy<=iy+17;yy+=3)for(const xx of [ix+2,ix+5,ix+8,ix+19,ix+22,ix+25])positions.push([xx,yy]);
  const props=savedProps.get(b.name).filter(p=>!p.atom.startsWith('/obj/ViltrumDoor'));
  assert(props.length<=positions.length,'Interior furniture capacity exceeded');
  props.forEach((p,i)=>{const [x,y]=positions[i];putInside(x,y,interiorFloor,[p.atom]);interiorProps.push({...p,position:[x,y,iz]});});
  const exits=[exit,[ix+13,iy+18]];
  for(const [x,y]of exits)putInside(x,y,interiorFloor,[`/obj/CityBuildingDoor/Exit{building_id = "${buildingId}"; target_x = ${door[0]}; target_y = ${door[1]}; target_z = ${earth?21:20}}`]);
  set(...door,floor,[`/obj/CityBuildingDoor{name = ${JSON.stringify('Enter '+b.name)}; building_id = "${buildingId}"; target_x = ${entry[0]}; target_y = ${entry[1]}; target_z = 22}`]);
  // A three-tile front walk connects the threshold to surrounding public paving.
  for(let xx=door[0]-1;xx<=door[0]+1;xx++)set(xx,y-2,floor);
  report.buildings.push({planet,id:buildingId,name:b.name,style,type:baseType+suffix,originalBounds:b.bounds,bounds:[a,y,a+width-1,y+height-1],door:[...door,earth?21:20],interiorBounds:[ix,iy,ix+27,iy+19],entry:[...entry,iz],exits:exits.map(v=>[...v,iz]),props:interiorProps});slot++;
 }
 const chunks=[];for(let r=0;r<5;r++)for(let c=0;c<5;c++){const file=`${planet}${'ABCDE'[r]}${c+1}.dmm`,content=serialize(grid.slice(r*100,r*100+100).map(row=>row.slice(c*100,c*100+100)));if(hash(content)!==p.chunkHashes[file])chunks.push({file,content});}
 report.planets[planet]={beforeHash:meta.outputHash,changedChunks:chunks.map(v=>v.file),reservedRoadTiles:Array.from(roads).reduce((a,b)=>a+b,0)};pending.push({p,chunks});
}
// No source changes until both planets have valid reserved lots and interiors.
fs.mkdirSync(backup,{recursive:true});fs.copyFileSync(path.join(root,'DU.dme'),path.join(backup,'DU.dme'));
for(const {p,chunks}of pending){const dir=path.join(backup,path.basename(p.paths.directory));fs.mkdirSync(dir);fs.copyFileSync(p.paths.output,path.join(dir,'Output.dmm'));fs.copyFileSync(p.paths.metadata,path.join(dir,'Metadata.json'));for(const {file,content}of chunks){fs.copyFileSync(path.join(p.paths.directory,file),path.join(dir,file));fs.writeFileSync(path.join(p.paths.directory,file),content);}}
fs.writeFileSync(path.join(root,'src/Maps/CityInteriors.dmm'),serialize(interior));
fs.writeFileSync(path.join(root,'docs/Maps/CityBuildings.json'),JSON.stringify(report,null,2)+'\n');
for(const planet of ['Viltrum','SuperEarth'])assemble(planet);
console.log(`Migrated ${report.buildings.length} buildings; ${report.preservedManualBuildings.length} manually edited shells retained; separate Z22 interiors.`);
