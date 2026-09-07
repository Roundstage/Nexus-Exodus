'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root,loadPlanet}=require('./PlanetChunks.cjs'),{splitOutside,serialize,hash}=require('./Dmm.cjs');
function begin(stage,baseline){
 const p=loadPlanet('SuperEarth'),prior=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline',baseline)));
 assert.equal(hash(fs.readFileSync(p.paths.output)),prior.outputHash,'Earth output changed; recover manual edits first.');
 for(const [file,digest]of Object.entries(prior.chunkHashes))assert.equal(p.chunkHashes[file],digest,`Earth source changed: ${file}`);
 const spec={phase:stage==='Slice'?5:6,layout:'Existing continents retained; western city near original Human spawn, replacing the brief ocean-based C3 placement.',landing:{x:101,y:362,radius:10},spawn:{x:95,y:362},points:[],publicRooms:[],buildings:[],combatSpaces:[],roads:[],changedChunks:[],review:'Interactive review deferred by user; script and headless verification only.'};
 const grid=p.grid,original=grid.map(r=>r.slice()),floor='/turf/EarthFloor',roof='/turf/EarthRoof',facade='/turf/EarthFacade',furn='/obj/EarthFurnishing';
 const protectedTile=(x,y)=>(Math.abs(x-101)<=10&&Math.abs(y-362)<=10)||[[139,350],[368,342],[184,96]].some(([a,b])=>Math.abs(x-a)<=24&&Math.abs(y-b)<=4);
 const atomsAt=(x,y)=>splitOutside(grid[500-y][x-1],',');
 function put(x,y,type,objects=[],{bridge=false}={}){
  assert(x>=1&&x<=500&&y>=1&&y<=500,'Outside Earth map');
  if(protectedTile(x,y))return;
  const old=atomsAt(x,y),spawn=old.filter(a=>a.startsWith('/obj/Spawn'));
  if(spawn.length){if(type.startsWith(roof)||objects.length)return;objects=spawn;}
  if(old.at(-2)==='/turf/WaterFall'||old.at(-2)==='/turf/Stairs_Grass')return;
  if((old.at(-2)==='/turf/Water2'||old.at(-2)==='/turf/EarthBridge')&&type!=='/turf/EarthOceanBoundary'){
   if(!bridge)throw Error(`Building would erase water at ${x},${y}`);
   type='/turf/EarthBridge';
  }
  grid[500-y][x-1]=[...objects,type,'/area/SuperEarth'].join(',');
 }
 function rect(a,b,c,d,type,options){for(let y=b;y<=d;y++)for(let x=a;x<=c;x++)put(x,y,type,[],options);}
 function route(points,width=7){for(let n=1;n<points.length;n++){const [a,b]=points[n-1],[c,d]=points[n];assert(a===c||b===d);const r=(width-1)/2;rect(Math.min(a,c)-r,Math.min(b,d)-r,Math.max(a,c)+r,Math.max(b,d)+r,floor+'/Road',{bridge:true});}spec.roads.push({points,width});}
 function prop(x,y,type,name){if(protectedTile(x,y)||atomsAt(x,y).some(a=>a.startsWith('/obj/Spawn')))return;const turf=atomsAt(x,y).at(-2);assert(!turf.startsWith(roof)&&turf!=='/turf/Water2',`Fixture needs an accessible floor: ${x},${y}`);put(x,y,turf,[type+(name?`{name = ${JSON.stringify(name)}}`:'')]);}
 function directory(x,y,name,text){prop(x,y,`/obj/EarthDirectory{name = ${JSON.stringify(name)}; directions_text = ${JSON.stringify(text)}}`);}
 function point(name,x,y){spec.points.push({name,x,y});}
 function hall(name,a,b,c,d,{material=floor,roofType=roof,facadeType=facade,doors=3}={}){
  for(const other of spec.buildings){const [oa,ob,oc,od]=other.bounds;assert(!(a<=oc&&c>=oa&&b-1<=od&&d>=ob-1),`${name} overlaps ${other.name}`);}
  // Refuse water loss before writing any part of this structure.
  for(let y=b-1;y<=d;y++)for(let x=a;x<=c;x++)assert(!atomsAt(x,y).includes('/turf/Water2'),`${name} overlaps water at ${x},${y}`);
  rect(a,b,c,d,roofType);rect(a+1,b+1,c-1,d-1,material);const cx=Math.floor((a+c)/2),cy=Math.floor((b+d)/2),r=(doors-1)/2;
  for(const y of [b,d])rect(cx-r,y,cx+r,y,material);for(const x of [a,c])rect(x,cy-r,x,cy+r,material);
  for(let x=a;x<=c;x++)if(Math.abs(x-cx)>r)put(x,b-1,facadeType);
  spec.publicRooms.push([a+1,b+1,c-1,d-1]);spec.buildings.push({name,bounds:[a,b,c,d],doors,entrances:[[cx,b],[cx,d],[a,cy],[c,cy]]});point(name,cx,cy);return {cx,cy};
 }
 function home(name,a,b,c,d){hall(name,a,b,c,d,{facadeType:facade+'/Wood'});const cx=Math.floor((a+c)/2),cy=Math.floor((b+d)/2);for(let x=a+1;x<c;x++)if(Math.abs(x-cx)>1)put(x,cy,roof);for(const [x,y,type]of[[a+2,d-2,furn],[c-2,d-2,furn+'/Dresser'],[a+2,b+2,furn+'/Stove'],[c-2,b+2,furn+'/Table']])prop(x,y,type);}
 function finish(){
  const backup=path.join(root,'docs/Maps/RebuildBaseline',`BeforeEarth${stage}`);assert(!fs.existsSync(backup),'Stage already applied.');
  const updates=[];for(let row=0;row<5;row++)for(let col=0;col<5;col++){const file=`SuperEarth${'ABCDE'[row]}${col+1}.dmm`,content=serialize(grid.slice(row*100,row*100+100).map(r=>r.slice(col*100,col*100+100)));if(hash(content)!==p.chunkHashes[file])updates.push({file,content});}
  // Spawn atom strings survive all layout operations, including unchanged template spawns.
  const spawns=g=>g.flat().flatMap(s=>splitOutside(s,',').filter(a=>a.startsWith('/obj/Spawn'))).sort();assert.deepEqual(spawns(grid),spawns(original));
  fs.mkdirSync(backup);for(const {file,content}of updates){fs.copyFileSync(path.join(p.paths.directory,file),path.join(backup,file));fs.writeFileSync(path.join(p.paths.directory,file),content);}
  spec.changedChunks=updates.map(v=>v.file);fs.writeFileSync(path.join(root,`docs/Maps/SuperEarth${stage}.json`),JSON.stringify(spec,null,2)+'\n');console.log(`Earth ${stage}: ${updates.length} chunks, ${spec.buildings.length} public interiors, ${spec.points.length} destinations; original spawn atoms preserved.`);
 }
 return {p,grid,spec,put,rect,route,prop,directory,point,hall,home,finish,floor,roof,facade,furn};
}
module.exports={begin};
