'use strict';
// Recover water metadata where two authored roads crossed the same bridge cell.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root,loadPlanet}=require('./PlanetChunks.cjs'),{parse,splitOutside,serialize,hash}=require('./Dmm.cjs');
const p=loadPlanet('SuperEarth'),baseline=parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/SuperEarth.dmm'),'utf8'));
const prior=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/EarthCityAssembly.json')));
assert.equal(hash(fs.readFileSync(p.paths.output)),prior.outputHash);
for(const [file,digest]of Object.entries(prior.chunkHashes))assert.equal(p.chunkHashes[file],digest);
let corrected=0;for(let y=0;y<500;y++)for(let x=0;x<500;x++)if(splitOutside(baseline.grid[y][x],',').at(-2)==='/turf/Water2'){
 const atoms=splitOutside(p.grid[y][x],',');if(atoms.at(-2)==='/turf/EarthFloor/Road'){atoms[atoms.length-2]='/turf/EarthBridge';p.grid[y][x]=atoms.join(',');corrected++;}
}
for(let row=0;row<5;row++)for(let col=0;col<5;col++){const file=`SuperEarth${'ABCDE'[row]}${col+1}.dmm`,content=serialize(p.grid.slice(row*100,row*100+100).map(r=>r.slice(col*100,col*100+100)));if(hash(content)!==p.chunkHashes[file])fs.writeFileSync(path.join(p.paths.directory,file),content);}
console.log(`Restored underlying-water semantics on ${corrected} bridge-intersection tiles.`);
