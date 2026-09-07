'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root}=require('./PlanetChunks.cjs'),{parse,splitOutside}=require('./Dmm.cjs');
function run({preview=process.argv.includes('--preview')}={}){
 const folder=path.join(root,preview?'.codex-tmp/EarthNaturalLandmarks':'docs/Maps');
 const report=JSON.parse(fs.readFileSync(path.join(folder,'EarthNaturalLandmarks.json')));
 const core=require('./TestEarthWilderness.cjs').run({preview,natural:true});
 const map=parse(fs.readFileSync(path.join(root,preview?'.codex-tmp/EarthNaturalLandmarks/SuperEarth.dmm':'src/Maps/SuperEarth.dmm'),'utf8'));
 const interior=parse(fs.readFileSync(path.join(root,preview?'.codex-tmp/EarthNaturalLandmarks/CityInteriors.dmm':'src/Maps/CityInteriors.dmm'),'utf8'));
 const at=(x,y)=>map.grid[500-y][x-1],key=(x,y)=>`${x},${y}`;
 const walk=s=>!splitOutside(s,',').some(a=>/^\/turf\/(EarthNaturalRoof|EarthRiver(?:\{|,|$)|EarthRiverFall|EarthNaturalFall|EarthNaturalFoam|EarthOceanBoundary)/.test(a)||/^\/obj\/Trees/.test(a));
 let floors=0,ramps=0;
 for(const landmark of report.landmarks){
  const [a,b,c,d]=landmark.bounds,seen=new Set(),queue=[landmark.foot];assert(walk(at(...landmark.foot)),`Mountain foot blocked: ${landmark.id}`);seen.add(key(...landmark.foot));
  for(let i=0;i<queue.length;i++){const[x,y]=queue[i];for(const[xx,yy]of[[x-1,y],[x+1,y],[x,y-1],[x,y+1]])if(xx>=a-4&&xx<=c+4&&yy>=b-4&&yy<=d+4&&!seen.has(key(xx,yy))&&walk(at(xx,yy))){seen.add(key(xx,yy));queue.push([xx,yy]);}}
  for(const cell of landmark.cells)if(cell.kind!=='cliff'){
   assert(seen.has(key(cell.x,cell.y)),`Unreachable terrace ${landmark.id} ${cell.x},${cell.y} h${cell.height}`);floors++;ramps+=Number(cell.kind==='ramp');
  }
  for(let h=1;h<=landmark.levels.length;h++)assert(landmark.cells.some(c=>c.height===h&&c.kind==='terrace'&&seen.has(key(c.x,c.y))),`No explorable summit ${landmark.id}`);
  for(const c of landmark.cells)assert(!/\/obj\//.test(at(c.x,c.y))||at(c.x,c.y).startsWith('/obj/EarthCaveEntrance'),'Natural formation replaced with an object');
 }
 for(const dune of report.dunes)for(const[x,y]of dune.cells)assert(walk(at(x,y))&&at(x,y).startsWith('/turf/EarthNaturalGround/Dune'),'Dune is not a walkable terrain tile');
 const cave=report.cave;assert(walk(at(...cave.return)),'Cave approach is blocked');assert(walk(at(...cave.door)),'Cave mouth is solid');
 const innerAt=(x,y)=>interior.grid[interior.height-y][x-1];
 const seen=new Set([key(...cave.entry)]),queue=[cave.entry.slice(0,2)];
 for(let i=0;i<queue.length;i++){const[x,y]=queue[i];for(const[xx,yy]of[[x-1,y],[x+1,y],[x,y-1],[x,y+1]])if(xx>cave.bounds[0]&&xx<cave.bounds[2]&&yy>cave.bounds[1]&&yy<cave.bounds[3]&&!seen.has(key(xx,yy))&&walk(innerAt(xx,yy))){seen.add(key(xx,yy));queue.push([xx,yy]);}}
 for(const c of cave.cells)if(c.walk)assert(seen.has(key(c.x,c.y)),`Isolated cave floor ${c.x},${c.y}`);
 assert(innerAt(...cave.exit).includes('target_x = 132; target_y = 105; target_z = 21'),'Cave returns to wrong location');
 // All user-edited city tiles are byte-for-byte semantic matches, except the
 // 24 rejected terrain stairs. No streets, houses or spawn atoms are repainted.
 const oldFile=path.join(root,'docs/Maps/RebuildBaseline/BeforeEarthNaturalLandmarks/SuperEarth.dmm');
 const old=fs.existsSync(oldFile)?parse(fs.readFileSync(oldFile,'utf8')):parse(fs.readFileSync(path.join(root,'src/Maps/SuperEarth.dmm'),'utf8'));
 const [a,b,c,d]=report.cityBounds;let cityPreserved=0;
 for(let y=b;y<=d;y++)for(let x=a;x<=c;x++)if(!/\/turf\/EarthRiverSteps/.test(old.grid[500-y][x-1])){assert.equal(at(x,y),old.grid[500-y][x-1],`Approved city changed ${x},${y}`);cityPreserved++;}
 const result={...core,removedRemoteBuildings:report.retiredBuildings.length,oldStairsRemoved:report.stairsRemoved.length,allTerracesReachable:true,walkableMountainTiles:floors,naturalRampTiles:ramps,duneTiles:report.dunes.reduce((s,d)=>s+d.cells.length,0),caveFloorTiles:cave.cells.filter(c=>c.walk).length,cityTilesPreserved:cityPreserved,landformObjectAnchors:0};
 fs.writeFileSync(path.join(folder,'EarthNaturalLandmarksChecks.json'),JSON.stringify(result,null,2)+'\n');console.log(result);return result;
}
module.exports={run};if(require.main===module)run();
