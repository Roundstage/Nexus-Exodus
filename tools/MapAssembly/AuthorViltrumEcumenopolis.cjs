'use strict';
// Preview first; --apply accepts only these exact, unedited inputs. No force mode.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root,loadPlanet,assemble}=require('./PlanetChunks.cjs');
const {parse,serialize,hash,splitOutside}=require('./Dmm.cjs');
const read=f=>JSON.parse(fs.readFileSync(path.join(root,f),'utf8'));
const stage=path.join(root,'.codex-tmp/ViltrumEcumenopolis');
const backup=path.join(root,'docs/Maps/RebuildBaseline/BeforeViltrumEcumenopolis');
const paths=['src/Maps/Viltrum.dmm','src/Maps/ViltrumMetadata.json','src/Maps/CityInteriors.dmm','docs/Maps/CityBuildings.json','src/Maps/SuperEarth.dmm','src/Maps/SuperEarthMetadata.json'];
const live=loadPlanet('Viltrum');
const liveHashes=Object.fromEntries(paths.map(f=>[f,hash(fs.readFileSync(path.join(root,f)))]));
const last=fs.existsSync(path.join(root,'docs/Maps/ViltrumEcumenopolis.json'))?read('docs/Maps/ViltrumEcumenopolis.json'):null;
if(fs.existsSync(backup)){
 assert(last,'Baseline exists without applied report; inspect it before another write.');
 for(const [file,value] of Object.entries(last.appliedHashes))assert.equal(liveHashes[file],value,`Concurrent/manual changes: ${file}`);
 assert.deepEqual(live.chunkHashes,last.chunkHashes,'Chunks changed after the ecumenopolis pass.');
}
const baselineFile=f=>fs.existsSync(backup)?path.join(backup,f):path.join(root,f);
const original=parse(fs.readFileSync(baselineFile('src/Maps/Viltrum.dmm'),'utf8')).grid;
if(!fs.existsSync(backup))assert.deepEqual(live.grid,original,'Recover semantic output edits into chunks first.');
const grid=original.map(r=>r.slice());
const data=JSON.parse(fs.readFileSync(baselineFile('docs/Maps/CityBuildings.json')));
const interiors=parse(fs.readFileSync(baselineFile('src/Maps/CityInteriors.dmm'),'utf8'));
const baseInteriors=interiors.grid.map(r=>r.slice());
const area='/area/Viltrum',street='/turf/ViltrumCityStreet';
const key=(x,y)=>(y-1)*500+x-1,xy=k=>[k%500+1,Math.floor(k/500)+1];
const at=(g,x,y)=>g[500-y][x-1];
const turf=s=>splitOutside(s,',').at(-2).split('{')[0];
const wet=new Uint8Array(250000),fixed=new Uint8Array(250000),distance=new Uint16Array(250000);
const buildings=[],roads=new Set(),occupied=new Set(),quays=[],blocks=[];
const recovered=read('docs/Maps/RebuildBaseline/ManualOutputDelta.json');
const protectedBoxes=[
 [215,259,285,301], // Authored archive, public facades and manually corrected reactor.
 [187,58,227,98],[273,58,313,98],[238,58,262,90], // Landing complex.
 [363,155,371,164],[415,135,423,143] // Small manual landmarks.
];
const combatBoxes=[[232,219,269,250],[25,225,74,274],[136,236,164,264],[326,221,373,268],
 [348,212,352,216],[348,274,352,278],[314,243,318,247],[382,243,386,247]];
const inCombat=(x,y)=>combatBoxes.some(([a,b,c,d])=>x>=a&&x<=c&&y>=b&&y<=d);
for(let y=1;y<=500;y++)for(let x=1;x<=500;x++){
 const k=key(x,y),s=at(original,x,y);
 wet[k]=+turf(s).startsWith('/turf/ViltrumOcean');
 fixed[k]=+(x<=8||x>=493||y<=8||y>=493||protectedBoxes.some(([a,b,c,d])=>x>=a&&x<=c&&y>=b&&y<=d)||s.includes('/obj/Spawn'));
}
for(const {x,y}of recovered)fixed[key(x,y)]=1;
// Compute water union once, then its distance field; banks never overwrite water.
const queue=new Int32Array(250000);let tail=0;
distance.fill(65535);
for(let k=0;k<wet.length;k++)if(wet[k]){distance[k]=0;queue[tail++]=k;}
for(let head=0;head<tail;head++){
 const k=queue[head],x=k%500,y=Math.floor(k/500);
 for(const n of [x>0?k-1:-1,x<499?k+1:-1,y>0?k-500:-1,y<499?k+500:-1])if(n>=0&&distance[n]>distance[k]+1){distance[n]=distance[k]+1;queue[tail++]=n;}
}
function put(x,y,type,objects=[]){
 assert(x>=1&&y>=1&&x<=500&&y<=500);
 const k=key(x,y);assert(!fixed[k]&&!wet[k],`Protected/wet write at ${x},${y}`);
 grid[500-y][x-1]=[...objects,type,area].join(',');
}
function rect(a,b,c,d,type){for(let y=b;y<=d;y++)for(let x=a;x<=c;x++)put(x,y,type);}
function freeBox(a,b,c,d,padding=0){
 if(a-padding<9||b-padding<9||c+padding>492||d+padding>492)return false;
 for(let y=b-padding;y<=d+padding;y++)for(let x=a-padding;x<=c+padding;x++)if(fixed[key(x,y)]||distance[key(x,y)]<4)return false;
 return true;
}
// Replace obsolete isolated exteriors and empty roads outside preserved work.
// A restrained planted surface joins the urban blocks to the original coastline.
for(let y=9;y<=492;y++)for(let x=9;x<=492;x++){
 const k=key(x,y);if(fixed[k]||wet[k])continue;
 if(distance[k]<=4){
  let mask=0;for(const [dx,dy,bit]of [[0,1,1],[1,0,2],[0,-1,4],[-1,0,8]])if(wet[key(x+dx,y+dy)])mask|=bit;
  put(x,y,street+`/Quay{icon_state = "quay_${mask}"}`);quays.push([x,y]);
 }else put(x,y,street+'/Garden');
}
// Each accepted block contributes a complete street loop on dry, unprotected
// land. There are no clipped road fragments or causeways through the ocean.
const step=44,candidates=new Map();
for(let j=0;j<11;j++)for(let i=0;i<11;i++){
 const x=20+i*step,y=20+j*step;
 if(freeBox(x-4,y-4,x+step+4,y+step+4))candidates.set(`${i},${j}`,{i,j,x,y});
}
// Keep the largest contiguous neighborhood component; detached fringe cells
// remain waterfront parks rather than isolated road islands.
const unseen=new Set(candidates.keys()),components=[];
while(unseen.size){
 const q=[unseen.values().next().value];unseen.delete(q[0]);
 for(let n=0;n<q.length;n++){
  const {i,j}=candidates.get(q[n]);
  for(const k of [`${i-1},${j}`,`${i+1},${j}`,`${i},${j-1}`,`${i},${j+1}`])if(unseen.delete(k))q.push(k);
 }
 components.push(q);
}
assert(components.length);
const accepted=components.sort((a,b)=>b.length-a.length)[0].map(k=>candidates.get(k));
function district(x,y){
 if(y<160)return 'Porto Meridional';
 if(y>370)return 'Terraços Boreais';
 if(x>315)return 'Distrito de Ciências';
 if(x<180)return 'Bairros do Poente';
 return 'Coroa Imperial';
}
function road(a,b,c,d,r=2){
 assert(a===c||b===d);
 for(let y=Math.min(b,d)-r-2;y<=Math.max(b,d)+r+2;y++)for(let x=Math.min(a,c)-r-2;x<=Math.max(a,c)+r+2;x++)if(!roads.has(key(x,y)))put(x,y,street+'/Pavement');
 for(let y=Math.min(b,d)-r;y<=Math.max(b,d)+r;y++)for(let x=Math.min(a,c)-r;x<=Math.max(a,c)+r;x++){put(x,y,street);roads.add(key(x,y));}
}
for(const cell of accepted){
 const {x,y}=cell;rect(x+3,y+3,x+41,y+41,street+'/Pavement');
 blocks.push({...cell,span:44,bounds:[x,y,x+44,y+44],district:district(x+22,y+22),rows:[]});
}
for(const {x,y}of blocks){road(x,y,x+44,y);road(x,y+44,x+44,y+44);road(x,y,x,y+44);road(x+44,y,x+44,y+44);}
function house(x,y,style,block){
 const width=style==='civic'?8:['residence','residenceb'].includes(style)?5:7,height=style==='civic'?10:6;
 for(let yy=y;yy<y+height;yy++)for(let xx=x;xx<x+width;xx++){
  assert(!roads.has(key(xx,yy))&&!occupied.has(key(xx,yy)),`Building/road overlap ${xx},${yy}`);
  put(xx,yy,`/turf/ViltrumCityStructure{icon_state = "${style}_${xx-x}_${yy-y}"}`);occupied.add(key(xx,yy));
 }
 const suffix={residence:'',residenceb:'/ResidenceB',hospital:'/Hospital',science:'/Science',transit:'/Transit',civic:'/Civic'}[style];
 const type='/obj/ViltrumCityHouse'+suffix;
 grid[500-y][x-1]=type+','+at(grid,x,y);
 const item={style,type,bounds:[x,y,x+width-1,y+height-1],door:[x+Math.floor((width-1)/2),y-1,20],district:block.district,block:[block.i,block.j]};
 buildings.push(item);return item;
}
function ornament(x,y,type){
 if(inCombat(x,y))return;
 assert(!roads.has(key(x,y))&&!occupied.has(key(x,y)));
 const s=at(grid,x,y);put(x,y,turf(s),[type]);
}
for(const block of blocks){
 const {x,y,i,j}=block;
 // Civic courts replace the upper rows with a broad, usable gathering space.
 const intersectsCombat=combatBoxes.some(([a,b,c,d])=>x<=c&&x+44>=a&&y<=d&&y+44>=b);
 const civic=(i+2*j)%5===0&&!intersectsCombat;
 const green=(i+j)%4===0&&!civic;
 block.kind=civic?'civic court':green?'garden neighborhood':'continuous frontage';
 const rowY=civic?[y+7]:green?[y+7,y+31]:[y+7,y+19,y+31];
 if(!civic){road(x,y+15,x+44,y+15,1);road(x,y+27,x+44,y+27,1);}
 else road(x,y+15,x+44,y+15,1);
 for(let row=0;row<rowY.length;row++){
  const yy=rowY[row],placed=[];
  const service=row===0&&(i+j)%3===0;
  let xx=x+5;
  if(service&&!Array.from({length:7},(_,dx)=>xx+dx).some(px=>Array.from({length:8},(_,dy)=>yy+dy).some(py=>inCombat(px,py)))){
   const kind=j<=3?'transit':i>5?'science':(i+j)%2?'hospital':'science';
   placed.push(house(xx,yy,kind,block));xx+=7;
  }
  while(xx+4<=x+39){
   if(!Array.from({length:5},(_,dx)=>xx+dx).some(px=>Array.from({length:8},(_,dy)=>yy+dy).some(py=>inCombat(px,py))))placed.push(house(xx,yy,(i*3+j+row+placed.length)%3===0?'residenceb':'residence',block));
   xx+=5;
  }
  block.rows.push({y:yy,frontage:[x+5,xx-1],count:placed.length});
  // A planted rear strip does not interrupt the two clear frontage tiles.
  rect(x+5,yy+6,x+39,yy+6,street+'/Garden');
 }
 if(civic){
  rect(x+5,y+18,x+39,y+39,street+'/Plaza');
  house(x+18,y+25,'civic',block);
  for(const dx of [7,12,32,37])for(const dy of [21,34])ornament(x+dx,y+dy,'/obj/ViltrumCityTree');
  for(const dx of [13,30])ornament(x+dx,y+19,'/obj/ViltrumFurnishing/Bench');
 }else if(green){
  rect(x+5,y+18,x+39,y+24,street+'/Garden');
  rect(x+5,y+20,x+39,y+21,street+'/Pavement');
  for(const dx of [8,16,28,36])ornament(x+dx,y+22,'/obj/ViltrumCityTree');
 }else{
  // Small corner service courts supply neighborhood variation.
  for(const dx of [7,37])ornament(x+dx,y+38,'/obj/ViltrumFurnishing');
 }
}
// Restrained lane paint follows the union of streets, after every intersection
// is known. Crosswalks span the five-tile avenues before intersection corners.
for(const {x,y}of blocks){
 for(const [a,b,c,d]of [[x,y,x+44,y],[x,y+44,x+44,y+44],[x,y,x,y+44],[x+44,y,x+44,y+44]]){
  const horizontal=b===d;
  for(let v=(horizontal?a:b)+5;v<=(horizontal?c:d)-5;v++){
   const xx=horizontal?v:a,yy=horizontal?b:v;
   if(roads.has(key(xx,yy)))put(xx,yy,street+(horizontal?'/LaneHorizontal':'/LaneVertical'));
  }
  for(const offset of [5,39])for(let n=-2;n<=2;n++){
   const xx=horizontal?a+offset:a+n,yy=horizontal?b+n:b+offset;
   if(roads.has(key(xx,yy)))put(xx,yy,street+(horizontal?'/CrossingHorizontal':'/CrossingVertical'));
  }
 }
}
// Smaller connected terraces fit the shoreline and protected-landmark gaps.
// Every new loop has a dry, clear connector to the existing network before
// its houses are placed. This creates local variation without road stubs.
const infillConnectors=[];
function clearGardenBox(x,y){
 if(!freeBox(x-4,y-4,x+36,y+36))return false;
 for(let yy=y-4;yy<=y+36;yy++)for(let xx=x-4;xx<=x+36;xx++)if(inCombat(xx,yy)||turf(at(grid,xx,yy))!==street+'/Garden'||splitOutside(at(grid,xx,yy),',').length!==2)return false;
 return true;
}
function corridorClear(a,b,c,d){
 if(!freeBox(Math.min(a,c)-4,Math.min(b,d)-4,Math.max(a,c)+4,Math.max(b,d)+4))return false;
 for(let yy=Math.min(b,d)-4;yy<=Math.max(b,d)+4;yy++)for(let xx=Math.min(a,c)-4;xx<=Math.max(a,c)+4;xx++){
  const atoms=splitOutside(at(grid,xx,yy),','),t=atoms.at(-2).split('{')[0];
  if(occupied.has(key(xx,yy))||atoms.length!==2||!t.startsWith(street))return false;
 }
 return true;
}
for(let pass=0;pass<3;pass++)for(let y=16;y<=448;y+=8)for(let x=16;x<=448;x+=8){
 if(!clearGardenBox(x,y))continue;
 const choices=[];
 for(const [sx,sy,dx,dy]of [[x,y+16,-1,0],[x+32,y+16,1,0],[x+16,y,0,-1],[x+16,y+32,0,1]]){
  for(let d=5;d<=56;d++){
   const ex=sx+dx*d,ey=sy+dy*d;if(ex<9||ex>492||ey<9||ey>492)break;
   if(roads.has(key(ex,ey))){if(corridorClear(sx,sy,ex,ey))choices.push({line:[sx,sy,ex,ey],length:d});break;}
  }
 }
 if(!choices.length)continue;
 const connector=choices.sort((a,b)=>a.length-b.length)[0].line;
 road(...connector);infillConnectors.push(connector);
 rect(x+3,y+3,x+29,y+29,street+'/Pavement');
 road(x,y,x+32,y);road(x,y+32,x+32,y+32);road(x,y,x,y+32);road(x+32,y,x+32,y+32);road(x,y+15,x+32,y+15,1);
 const block={i:100+blocks.length,j:pass,x,y,span:32,bounds:[x,y,x+32,y+32],district:district(x+16,y+16),kind:'waterfront terrace',rows:[]};
 for(const yy of [y+7,y+19]){
  for(let n=0;n<4;n++)house(x+5+n*5,yy,(n+blocks.length)%3?'residence':'residenceb',block);
  rect(x+5,yy+6,x+24,yy+6,street+'/Garden');block.rows.push({y:yy,frontage:[x+5,x+24],count:4});
 }
 for(const dy of [8,20])ornament(x+27,y+dy,'/obj/ViltrumFurnishing/Bench');
 blocks.push(block);
}
// Designed central public park surrounds the preserved archive and connects
// its paths to the forum; planted edges follow those paths instead of rectangles
// of unrelated legacy textures.
for(let y=212;y<=322;y++)for(let x=184;x<=321;x++){
 const k=key(x,y);if(fixed[k]||wet[k]||occupied.has(k)||roads.has(k)||turf(at(grid,x,y))!==street+'/Garden')continue;
 if(Math.abs(x-250)<=2||Math.abs(y-305)<=2||Math.abs(y-254)<=2)put(x,y,street+'/Plaza');
 else if(!inCombat(x,y)&&x%10===4&&y%12===6&&distance[k]>5)ornament(x,y,'/obj/ViltrumCityTree');
}
// Short pedestrian approaches, authored before previews, link existing public
// spaces to the city; these are pavements, not purposeless arterial stubs.
const walkLinks=[];
for(const [sx,sy]of [[250,78],[250,250],[215,280],[285,280],[149,250],[350,245],[50,250]]){
 let nearest=null,best=Infinity;
 for(const k of roads){const [x,y]=xy(k),d=Math.abs(x-sx)+Math.abs(y-sy);if(d<best){best=d;nearest=[x,y];}}
 const pathTiles=[],seen=new Uint8Array(250000),prev=new Int32Array(250000);prev.fill(-1);
 const start=key(sx,sy),goal=key(...nearest),q=[start];seen[start]=1;
 for(let head=0;head<q.length&&!seen[goal];head++){
  const k=q[head],[x,y]=xy(k);
  for(const [xx,yy]of [[x-1,y],[x+1,y],[x,y-1],[x,y+1]]){
   if(xx<9||xx>492||yy<9||yy>492)continue;
   const n=key(xx,yy),t=turf(at(grid,xx,yy));
   if(seen[n]||wet[n]||occupied.has(n)||/Roof|Wall21/.test(t))continue;
   if(splitOutside(at(grid,xx,yy),',').slice(0,-2).some(a=>a.startsWith('/obj/ViltrumFurnishing')&&!a.startsWith('/obj/ViltrumFurnishing/LandingBeacon')||a.startsWith('/obj/ViltrumConsole')))continue;
   prev[n]=k;seen[n]=1;q.push(n);
  }
 }
 assert(seen[goal],`No public approach from ${sx},${sy}`);
 for(let k=goal;k!==start;k=prev[k]){const [x,y]=xy(k);pathTiles.push([x,y]);
  for(let dy=-1;dy<=1;dy++)for(let dx=-1;dx<=1;dx++){
   const xx=x+dx,yy=y+dy,n=key(xx,yy);
   if(xx<9||xx>492||yy<9||yy>492||fixed[n]||wet[n]||occupied.has(n)||roads.has(n))continue;
   if(turf(at(grid,xx,yy))===street+'/Garden')put(xx,yy,street+'/Pavement');
  }
 }
 walkLinks.push({from:[sx,sy],to:nearest,tiles:pathTiles});
}
// Match existing private rooms to compatible new street buildings. Empty room
// geometry, area, entry and the single return tile remain exactly where they are.
const mapped=data.buildings.filter(b=>b.planet==='Viltrum');
for(const b of mapped){
 const style={residence:'residence',terrace:'residenceb',hospital:'hospital',science:'science',hangar:'transit',civic:'civic'}[b.style];
 const options=buildings.filter(h=>!h.id&&h.style===style).sort((a,c)=>(Math.abs(a.door[0]-b.door[0])+Math.abs(a.door[1]-b.door[1]))-(Math.abs(c.door[0]-b.door[0])+Math.abs(c.door[1]-b.door[1])));
 assert(options.length,`Insufficient ${style} buildings for ${b.id}`);
 const h=options[0];h.id=b.id;h.name=b.name;
 b.bounds=h.bounds;b.door=h.door;b.return=[h.door[0],h.door[1]-1,20];b.type=h.type;b.exteriorStyle=style;b.district=h.district;
 const [x,y]=h.bounds;
 grid[500-y][x-1]=at(grid,x,y).replace(h.type+',',h.type+`{building_id = "${b.id}";name = "${b.name}"},`);
 const [dx,dy]=b.door,[ix,iy,iz]=b.entry;
 put(dx,dy,street+'/Pavement',[`/obj/CityBuildingDoor/ViltrumCity{building_id = "${b.id}";target_x = ${ix};target_y = ${iy};target_z = ${iz}}`]);
 const [ex,ey]=b.exits[0],atoms=splitOutside(interiors.grid[interiors.height-ey][ex-1],',');
 assert.equal(atoms.length,3,'Expected exactly one return portal');
 atoms[0]=`/obj/CityBuildingDoor/Exit/ViltrumCity{building_id = "${b.id}";target_x = ${b.return[0]};target_y = ${b.return[1]};target_z = 20}`;
 interiors.grid[interiors.height-ey][ex-1]=atoms.join(',');
}
// Non-accessible facades are deliberately not advertised as entrances.
const report={version:1,design:'Continuous modern neighborhoods on preserved Viltrum land; connected perimeter avenues and local frontages.',
 inputHashes:liveHashes,semanticOutputDelta:0,protectedBoxes,combatBoxes,protectedTileCount:fixed.reduce((a,b)=>a+b,0),waterTiles:wet.reduce((a,b)=>a+b,0),
 blocks,buildings,roads:[...roads].map(xy),infillConnectors,walkLinks,quayTiles:quays.length,
 accessibleBuildings:mapped.length,emptyInteriors:true,singleReturnDoor:true,
 counts:{blocks:blocks.length,buildings:buildings.length,structuralTiles:occupied.size,roadTiles:roads.size,
 byStyle:Object.fromEntries(['residence','residenceb','hospital','science','transit','civic'].map(s=>[s,buildings.filter(h=>h.style===s).length]))}};
for(let y=1;y<=500;y++)for(let x=1;x<=500;x++)if(fixed[key(x,y)]||wet[key(x,y)])assert.equal(at(grid,x,y),at(original,x,y));
// Confirm every interior change is exactly a Viltrum return portal tile.
const exits=new Set(mapped.map(b=>b.exits[0].slice(0,2).join(',')));
for(let y=1;y<=interiors.height;y++)for(let x=1;x<=interiors.width;x++)if(!exits.has(`${x},${y}`))assert.equal(interiors.grid[interiors.height-y][x-1],baseInteriors[interiors.height-y][x-1]);
fs.mkdirSync(stage,{recursive:true});
const dump=(name,value)=>fs.writeFileSync(path.join(stage,name),JSON.stringify(value,null,2)+'\n');
const palette=[...new Set(grid.flat())],indices=new Map(palette.map((s,i)=>[s,i]));
dump('Preview.json',{planet:'Viltrum',palette,grid:grid.map(r=>r.map(s=>indices.get(s)))});
dump('ViltrumEcumenopolis.json',report);dump('CityBuildings.json',data);
fs.writeFileSync(path.join(stage,'Viltrum.dmm'),serialize(grid));
fs.writeFileSync(path.join(stage,'CityInteriors.dmm'),serialize(interiors.grid));
// Geometry tests operate on the staged candidate before any runtime file changes.
require('./TestViltrumEcumenopolis.cjs').check(stage,original,data);
if(process.argv.includes('--apply')){
 for(const [file,value]of Object.entries(liveHashes))assert.equal(hash(fs.readFileSync(path.join(root,file))),value,`Concurrent edit: ${file}`);
 assert.deepEqual(loadPlanet('Viltrum').chunkHashes,live.chunkHashes);
 if(!fs.existsSync(backup)){
  for(const file of paths){const dst=path.join(backup,file);fs.mkdirSync(path.dirname(dst),{recursive:true});fs.copyFileSync(path.join(root,file),dst);}
  fs.cpSync(live.paths.directory,path.join(backup,'chunks'),{recursive:true});
  fs.writeFileSync(path.join(backup,'Hashes.json'),JSON.stringify({files:liveHashes,chunks:live.chunkHashes,semanticOutputDelta:0},null,2)+'\n');
 }
 // Output differs from metadata only by editor serialization, already proved
 // semantically equal above. Normalize it without a discard/force assembly flag.
 const metadata=read('src/Maps/ViltrumMetadata.json');
 metadata.outputHash=liveHashes['src/Maps/Viltrum.dmm'];
 fs.writeFileSync(live.paths.metadata,JSON.stringify(metadata,null,2)+'\n');
 for(const entry of live.manifest.chunks){
  const r='ABCDE'.indexOf(entry.row),c=entry.column-1;
  fs.writeFileSync(path.join(live.paths.directory,entry.file),serialize(grid.slice(r*100,r*100+100).map(row=>row.slice(c*100,c*100+100))));
 }
 const assembled=assemble('Viltrum');report.chunkHashes=assembled.chunkHashes;
 fs.copyFileSync(path.join(stage,'CityInteriors.dmm'),path.join(root,'src/Maps/CityInteriors.dmm'));
 fs.copyFileSync(path.join(stage,'CityBuildings.json'),path.join(root,'docs/Maps/CityBuildings.json'));
 report.appliedHashes=Object.fromEntries(paths.map(f=>[f,hash(fs.readFileSync(path.join(root,f)))]));
 for(const f of ['src/Maps/SuperEarth.dmm','src/Maps/SuperEarthMetadata.json'])assert.equal(report.appliedHashes[f],liveHashes[f]);
 dump('ViltrumEcumenopolis.json',report);
 fs.copyFileSync(path.join(stage,'ViltrumEcumenopolis.json'),path.join(root,'docs/Maps/ViltrumEcumenopolis.json'));
 console.log('Applied guarded Viltrum city and exact return targets; Earth unchanged.');
}
console.log(JSON.stringify(report.counts));
