'use strict';
// Incremental terrain revision. The current city/editor changes are immutable;
// this stage removes remote buildings and authors explorable tile landforms.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root,loadPlanet,assemble,environmentTypes}=require('./PlanetChunks.cjs');
const {parse,serialize,splitOutside,hash}=require('./Dmm.cjs');
const {naturalLand,riverWater}=require('./EarthNaturalHydrology.cjs');
const read=f=>JSON.parse(fs.readFileSync(path.join(root,f)));
const p=loadPlanet('SuperEarth'),meta=read('src/Maps/SuperEarthMetadata.json');
assert.equal(hash(fs.readFileSync(p.paths.output)),meta.outputHash,'Recover manual output changes first.');
assert.deepEqual(p.chunkHashes,meta.chunkHashes,'Assemble edited chunks first.');
const backup=path.join(root,'docs/Maps/RebuildBaseline/BeforeEarthNaturalLandmarks'),exists=fs.existsSync(backup);
const prior=read(exists?'docs/Maps/EarthNaturalLandmarks.json':'docs/Maps/EarthWilderness.json');
assert.equal(meta.outputHash,prior.outputHash,'Earth changed since recorded revision.');
for(const [file,field]of [['src/Maps/CityInteriors.dmm','interiorHash'],['docs/Maps/CityBuildings.json','buildingDataHash']])assert.equal(hash(fs.readFileSync(path.join(root,file))),prior[field],`Recover edited ${file} first.`);
const source=name=>fs.readFileSync(exists?path.join(backup,name):path.join(root,name.endsWith('.dmm')?'src/Maps':'docs/Maps',name),'utf8');
const original=parse(source('SuperEarth.dmm')).grid,grid=original.map(r=>r.slice());
const registry=JSON.parse(source('CityBuildings.json')),neighborhood=JSON.parse(source('EarthNeighborhood.json')),interior=parse(source('CityInteriors.dmm'));
const seed=parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/SuperEarth.dmm'),'utf8')).grid;
const geography=read('docs/Maps/SuperEarthSpawns.json'),rivers=riverWater(geography.rivers,geography.waterfalls);
const key=(x,y)=>`${x},${y}`,type=s=>splitOutside(s,',').at(-2).split('{')[0],at=(x,y)=>grid[500-y][x-1];
const cityBounds=[41,258,199,405],inside=([a,b,c,d],x,y)=>x>=a&&x<=c&&y>=b&&y<=d;
const wet=t=>['/turf/EarthRiver','/turf/EarthRiverFall','/turf/EarthNaturalFall','/turf/EarthNaturalFoam','/turf/EarthOceanBoundary'].includes(t)||t.startsWith('/turf/EarthStreet/Bridge');
const changes=new Map(),put=(x,y,stack)=>{assert(x>=9&&x<=492&&y>=9&&y<=492);grid[500-y][x-1]=stack;changes.set(key(x,y),{x,y,before:original[500-y][x-1],after:stack});};
const report={version:1,design:'Explorable 32px tile landforms, natural ramps, no remote buildings or stairs',cityBounds,outposts:[],retiredBuildings:[],stairsRemoved:[],oldCliffsRemoved:[],landmarks:[],dunes:[]};
function naturalStack(x,y){
 if(wet(type(at(x,y))))return at(x,y);
 let t=type(seed[500-y][x-1]);
 if(/Wall12|Stairs|WaterFall/.test(t))t=y<160&&x<290?'/turf/Ground10':x>=250&&x<=310&&y>=407?'/turf/GroundSnow':x>300&&y<345?'/turf/Grass12':'/turf/Grass13';
 if(t==='/turf/Water2')t='/turf/EarthRiver';
 if(['/turf/Grass8','/turf/Grass13'].includes(t))t='/turf/EarthRiverBank{icon_state = "bank_0"}';
 return `${t},/area/SuperEarth`;
}
const retired=neighborhood.buildings.filter(b=>b.row==='Regional'),retiredIds=new Set(retired.map(b=>b.id));
report.retiredBuildings=retired;
for(const b of retired){const[a,y,c,d]=b.bounds;for(let yy=y-2;yy<=d;yy++)for(let x=a;x<=c;x++)put(x,yy,naturalStack(x,yy));}
const oldWilderness=read('docs/Maps/EarthWilderness.json');
for(const points of oldWilderness.trails)for(let i=1;i<points.length;i++){
 const[a,b]=points[i-1],[c,d]=points[i];
 for(let y=Math.min(b,d)-1;y<=Math.max(b,d)+1;y++)for(let x=Math.min(a,c)-1;x<=Math.max(a,c)+1;x++)if(!inside(cityBounds,x,y)&&type(at(x,y))==='/turf/GroundDirt')put(x,y,naturalStack(x,y));
}
for(let y=9;y<=492;y++)for(let x=9;x<=492;x++){
 const t=type(at(x,y));
 if(/Stairs|Steps/.test(t)){report.stairsRemoved.push({x,y});put(x,y,naturalStack(x,y));}
 else if(t==='/turf/Wall12'&&!inside(cityBounds,x,y)){report.oldCliffsRemoved.push({x,y});put(x,y,naturalStack(x,y));}
}
// Retired interiors remain reserved solid space; retained rooms never move.
for(const b of registry.buildings.filter(b=>retiredIds.has(b.id))){const[a,y,c,d]=b.interiorBounds;for(let yy=y;yy<=d;yy++)for(let x=a;x<=c;x++)interior.grid[interior.height-yy][x-1]='/turf/CityBuildingFootprint,/area/CityInterior/Earth';}
registry.buildings=registry.buildings.filter(b=>!retiredIds.has(b.id));
neighborhood.buildings=neighborhood.buildings.filter(b=>!retiredIds.has(b.id));
neighborhood.totalBuildings=neighborhood.buildings.length;neighborhood.accessibleBuildings=registry.buildings.filter(b=>b.planet==='SuperEarth').length;
const spawns=[];for(let y=1;y<=500;y++)for(let x=1;x<=500;x++)for(const atom of splitOutside(original[500-y][x-1],','))if(atom.startsWith('/obj/Spawn'))spawns.push({x,y,atom});
function safe(x,y){assert(!inside(cityBounds,x,y),'Natural landmark inside approved city');assert(naturalLand(x,y)&&!wet(type(at(x,y))),`Landmark covers water ${x},${y}`);assert(!spawns.some(s=>(s.x-x)**2+(s.y-y)**2<64),`Landmark crowds spawn ${x},${y}`);}
const cardinal=[[0,1],[1,0],[0,-1],[-1,0]];
function mountain({id,name,biome,levels,gaps,foot}){
 const height=new Map(),bounds=[500,500,0,0];
 levels.forEach(([cx,cy,rx,ry],i)=>{
  for(let y=Math.floor(cy-ry-2);y<=Math.ceil(cy+ry+2);y++)for(let x=Math.floor(cx-rx-2);x<=Math.ceil(cx+rx+2);x++){
   const dx=(x-cx)/rx,dy=(y-cy)/ry,a=Math.atan2(dy,dx),r=1+.055*Math.sin(3*a+1)+.04*Math.cos(7*a);
   if(Math.hypot(dx,dy)<=r){safe(x,y);height.set(key(x,y),i+1);bounds[0]=Math.min(bounds[0],x);bounds[1]=Math.min(bounds[1],y);bounds[2]=Math.max(bounds[2],x);bounds[3]=Math.max(bounds[3],y);}
  }
 });
 const walls=new Map(),cells=[];
 for(const [k,h]of height){const[x,y]=k.split(',').map(Number);let distance=3;
  for(let dy=-2;dy<=2;dy++)for(let dx=-2;dx<=2;dx++)if(Math.abs(dx)+Math.abs(dy)<=2&&(height.get(key(x+dx,y+dy))||0)<h)distance=Math.min(distance,Math.abs(dx)+Math.abs(dy));
  if(distance<=2)walls.set(k,distance-1);
 }
 const ramps=new Set();
 gaps.forEach(([x,y,dir],i)=>{
  // A continuous three-tile-wide scree ramp breaks one ring per terrace.
  for(let d=-5;d<=5;d++)for(let w=-1;w<=1;w++){
   const xx=x+(dir==='n'||dir==='s'?w:d),yy=y+(dir==='n'||dir==='s'?d:w),k=key(xx,yy);
   if(height.get(k)===i+1){walls.delete(k);ramps.add(k);}
  }
 });
 for(const [k,h]of height){const[x,y]=k.split(',').map(Number),wall=walls.has(k),ramp=ramps.has(k),mask=cardinal.reduce((m,[dx,dy],i)=>m+((height.get(key(x+dx,y+dy))||0)<h?2**i:0),0);
  const suffix=biome==='snow'?'/Snow':biome==='forest'?'/Forest':'';
  const t=wall?'/turf/EarthNaturalRoof'+suffix:ramp?'/turf/EarthNaturalGround/Ramp':'/turf/EarthNaturalGround'+suffix;
  const state=wall?`${biome}_face_${walls.get(k)}`:ramp?`${biome}_ramp_${gaps[h-1][2]}`:`${biome}_top_${mask}`;
  put(x,y,`${t}{icon_state = "${state}"; landmark_id = "${id}"; terrain_height = ${h}},/area/SuperEarth`);cells.push({x,y,height:h,kind:wall?'cliff':ramp?'ramp':'terrace'});
 }
 const landmark={id,name,biome,bounds,levels,gaps,foot,cells};report.landmarks.push(landmark);return landmark;
}
const desert=mountain({id:'sandstone_massif',name:'Hollow Sandstone Mountain',biome:'sand',levels:[[132,124,23,19],[133,127,15,12],[131,130,7,5]],gaps:[[110,124,'e'],[147,127,'w'],[131,125,'n']],foot:[107,124]});
mountain({id:'arctic_peak',name:'Northern Glacial Ridge',biome:'snow',levels:[[281,444,19,16],[282,446,12,10],[282,447,5,4]],gaps:[[281,429,'n'],[293,446,'w'],[277,447,'e']],foot:[281,425]});
// Dune field: separate crescent ridges, a common wind direction and open
// interdune corridors. All slopes are walkable; no decorative object anchors.
let duneIndex=0;
for(const [cx,cy,rx,ry]of [[108,94,13,6],[111,76,14,6],[158,68,16,7]]){
 duneIndex++;
 const cells=[];
 for(let y=cy-ry-1;y<=cy+ry+1;y++)for(let x=cx-rx-1;x<=cx+rx+1;x++){
  safe(x,y);
  put(x,y,`/turf/EarthNaturalGround/Dune{icon_state = "dune_patch_${duneIndex}_${x-cx+rx+1}_${y-cy+ry+1}"; landmark_id = "dune_field"; terrain_height = 1},/area/SuperEarth`);cells.push([x,y]);
 }
 report.dunes.push({center:[cx,cy],radius:[rx,ry],cells});
}
// A mossy shelf flanks the original forest stream. Keep every original water
// tile, and replace only the falling curtain / downstream foam within it.
const forest=mountain({id:'forest_falls',name:'Forest Waterfall Ledges',biome:'forest',levels:[[354,342,8,7]],gaps:[[347,342,'e']],foot:[344,342]});
// The east-bank shelf stays outside the water union as well.
mountain({id:'forest_east_ledge',name:'Forest Waterfall East Ledge',biome:'forest',levels:[[382,344,7,6]],gaps:[[388,344,'w']],foot:[391,344]});
for(let y=341;y<=343;y++)for(let x=361;x<=377;x++)if(!wet(type(at(x,y))))put(x,y,`${y===343?'/turf/EarthNaturalGround/Forest':'/turf/EarthNaturalRoof/Forest'},/area/SuperEarth`);
const fallCells=[],foamCells=[];
for(let y=338;y<=344;y++)for(let x=359;x<=379;x++)if(wet(type(at(x,y)))){
 if(y>=340&&y<=342){put(x,y,'/turf/EarthNaturalFall,/area/SuperEarth');fallCells.push([x,y]);}
 else if(y===338||y===339){put(x,y,'/turf/EarthNaturalFoam,/area/SuperEarth');foamCells.push([x,y]);}
}
report.waterfall={fallCells,foamCells,source:[367,413],pool:[368,335],outflow:[388,302]};
// Natural arch at the south foot, opening into a separate irregular cavern.
const cave={id:'sandstone_cave',name:'Whispering Sandstone Cave',door:[132,106,21],return:[132,105,21],entry:[341,219,22],exit:[341,218,22],bounds:[325,215,358,238],chambers:[[341,221,5,4],[343,229,7,6],[332,230,4,4]],cells:[]};
for(let row=0;row<2;row++)for(let col=0;col<3;col++){
 const x=cave.door[0]-1+col,y=cave.door[1]+1-row,opening=col===1;
 put(x,y,`${opening?'/turf/EarthNaturalGround/CaveMouth':'/turf/EarthNaturalRoof'}{icon_state = "cave_mouth_${col}_${row}"; landmark_id = "sandstone_massif"; terrain_height = 1},/area/SuperEarth`);
}
const doorAtom=`/obj/EarthCaveEntrance{building_id = "${cave.id}"; target_x = 341; target_y = 219; target_z = 22}`;
put(132,106,doorAtom+','+at(132,106));
for(let y=103;y<=105;y++)put(132,y,'/turf/EarthNaturalGround/Ramp{icon_state = "sand_ramp_n"; landmark_id = "sandstone_massif"},/area/SuperEarth');
for(const cell of desert.cells)if(cell.x>=131&&cell.x<=133&&cell.y>=106&&cell.y<=107)cell.kind=cell.x===132?'terrace':'cliff';
const [ca,cb,cc,cd]=cave.bounds;
for(let y=cb;y<=cd;y++)for(let x=ca;x<=cc;x++){
 const walk=x>ca&&x<cc&&y>cb&&y<cd&&cave.chambers.some(([cx,cy,rx,ry])=>((x-cx)/rx)**2+((y-cy)/ry)**2<=1+.09*Math.sin(x*.9+y*.8));
 const t=walk?'/turf/EarthNaturalGround/Cave':'/turf/EarthNaturalRoof/Cave';
 let stack=`${t},/area/CityInterior/Earth`;
 if(x===341&&y===218)stack=`/obj/EarthCaveEntrance/Exit{building_id = "${cave.id}"; target_x = 132; target_y = 105; target_z = 21},`+stack;
 interior.grid[interior.height-y][x-1]=stack;cave.cells.push({x,y,walk});
}
report.cave=cave;
// Refresh river edge art only where cleanup touched banks, keeping the user's
// entire approved city reach unchanged apart from explicitly rejected stairs.
const skin=require('./EarthRiverTerrain.cjs');
const topology=grid.map(r=>r.map(s=>wet(type(s))?'/turf/Water2,/area/SuperEarth':s));
const skinned=grid.map(r=>r.slice());skin.applyRiverTerrain(skinned,topology);
for(const {x,y}of [...changes.values()])for(let yy=y-1;yy<=y+1;yy++)for(let xx=x-1;xx<=x+1;xx++)if(!inside(cityBounds,xx,yy)&&['/turf/EarthRiver','/turf/EarthRiverBank'].includes(type(at(xx,yy))))put(xx,yy,skinned[500-yy][xx-1]);
// Never restore historical spawn coordinates over the latest user's choices.
for(const {x,y,atom}of spawns)assert(splitOutside(at(x,y),',').includes(atom),'Spawn changed during natural authoring');
report.changes=[...changes.values()].filter(c=>c.before!==c.after);
const output=serialize(grid),interiorOutput=serialize(interior.grid),registryOutput=JSON.stringify(registry,null,2)+'\n';
const common={outputHash:hash(output),interiorHash:hash(interiorOutput),buildingDataHash:hash(registryOutput),chunkHashes:{},changedChunks:[]},updates=[];
for(let row=0;row<5;row++)for(let col=0;col<5;col++){
 const file=`SuperEarth${'ABCDE'[row]}${col+1}.dmm`,content=serialize(grid.slice(row*100,row*100+100).map(r=>r.slice(col*100,col*100+100)));common.chunkHashes[file]=hash(content);
 if(common.chunkHashes[file]!==p.chunkHashes[file]){updates.push({file,content});common.changedChunks.push(file);}
}
Object.assign(report,common,{beforeHash:hash(serialize(original)),cityBuildings:neighborhood.totalBuildings,accessibleBuildings:neighborhood.accessibleBuildings});Object.assign(neighborhood,common,{naturalRevision:{report:'EarthNaturalLandmarks.json',retiredIds:[...retiredIds]}});
const out=path.join(root,'.codex-tmp/EarthNaturalLandmarks');fs.mkdirSync(out,{recursive:true});
for(const [name,value]of [['SuperEarth.dmm',output],['CityInteriors.dmm',interiorOutput],['CityBuildings.json',registryOutput]])fs.writeFileSync(path.join(out,name),value);
for(const [name,value]of [['EarthNaturalLandmarks',report],['EarthNeighborhood',neighborhood]])fs.writeFileSync(path.join(out,name+'.json'),JSON.stringify(value,null,2)+'\n');
const palette=[...new Set(grid.flat())].sort(),lookup=new Map(palette.map((s,i)=>[s,i]));fs.writeFileSync(path.join(out,'Preview.json'),JSON.stringify({planet:'SuperEarth',palette,grid:grid.map(r=>r.map(s=>lookup.get(s)))}));
const innerPalette=[...new Set(interior.grid.flat())].sort(),innerLookup=new Map(innerPalette.map((s,i)=>[s,i]));fs.writeFileSync(path.join(out,'InteriorPreview.json'),JSON.stringify({palette:innerPalette,grid:interior.grid.map(r=>r.map(s=>innerLookup.get(s)))}));
if(process.argv.includes('--apply')){
 // Check generated types and the current editor state before any production
 // write, so an omitted include cannot leave partially applied chunk changes.
 const known=environmentTypes();
 for(const stack of new Set([...grid.flat(),...interior.grid.flat()]))for(const atom of splitOutside(stack,','))assert(known.has(atom.split('{')[0]),`Undefined generated map type: ${atom.split('{')[0]}`);
 assert.equal(hash(fs.readFileSync(p.paths.output)),meta.outputHash,'Editor saved Earth while authoring; recover those changes first.');
 for(const [file,field]of [['src/Maps/CityInteriors.dmm','interiorHash'],['docs/Maps/CityBuildings.json','buildingDataHash']])assert.equal(hash(fs.readFileSync(path.join(root,file))),prior[field],`Concurrent edit to ${file}`);
 if(!exists){fs.mkdirSync(backup);for(const name of ['SuperEarth.dmm','SuperEarthMetadata.json','CityInteriors.dmm'])fs.copyFileSync(path.join(root,'src/Maps',name),path.join(backup,name));for(const name of ['CityBuildings.json','EarthNeighborhood.json'])fs.copyFileSync(path.join(root,'docs/Maps',name),path.join(backup,name));for(const file of Object.keys(p.chunkHashes))fs.copyFileSync(path.join(p.paths.directory,file),path.join(backup,file));}
 for(const {file,content}of updates)fs.writeFileSync(path.join(p.paths.directory,file),content);
 fs.writeFileSync(path.join(root,'src/Maps/CityInteriors.dmm'),interiorOutput);fs.writeFileSync(path.join(root,'docs/Maps/CityBuildings.json'),registryOutput);
 for(const [name,value]of [['EarthNaturalLandmarks',report],['EarthNeighborhood',neighborhood]])fs.writeFileSync(path.join(root,'docs/Maps',name+'.json'),JSON.stringify(value,null,2)+'\n');assemble('SuperEarth');
}
console.log({mode:process.argv.includes('--apply')?'applied':'preview',cityBuildings:report.cityBuildings,accessible:report.accessibleBuildings,removedBuildings:retired.length,stairsRemoved:report.stairsRemoved.length,landmarks:report.landmarks.length,cave:cave.door,outputHash:report.outputHash});
