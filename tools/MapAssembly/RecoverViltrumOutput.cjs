'use strict';
// Recover the observed manual DMM changes before replacing the generated output.
// All deltas win over new floor work; both conflicting versions are recorded.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {loadPlanet,root}=require('./PlanetChunks.cjs'),{hash,serialize}=require('./Dmm.cjs');
if(process.argv.length!==2)throw Error('No overwrite options.');
const p=loadPlanet('Viltrum'),bytes=fs.readFileSync(p.paths.output),digest=hash(bytes);
assert.equal(digest,'f91752413c14eb0d1f23793e954a5ae5d7215e375195a06b63c766ba92b22c80','Output changed again; inspect it first.');
const deltas=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline/ManualOutputDelta.json')));
const conflicts=[];
for(const change of deltas){const current=p.grid[500-change.y][change.x-1];if(current!==change.before&&current!==change.output)conflicts.push({...change,capital:current});p.grid[500-change.y][change.x-1]=change.output;}
const backup=path.join(root,'docs/Maps/RebuildBaseline/ManualOutputRecovery');assert(!fs.existsSync(backup),'Already recovered');fs.mkdirSync(backup);
fs.writeFileSync(path.join(backup,'ViltrumManual.dmm'),bytes);fs.copyFileSync(p.paths.metadata,path.join(backup,'PreviousMetadata.json'));
const updates=[];
for(let row=0;row<5;row++)for(let col=0;col<5;col++){
 const file=`Viltrum${'ABCDE'[row]}${col+1}.dmm`,content=serialize(p.grid.slice(row*100,row*100+100).map(r=>r.slice(col*100,col*100+100)));
 if(hash(content)!==p.chunkHashes[file])updates.push({file,content});
}
for(const {file,content}of updates){fs.copyFileSync(path.join(p.paths.directory,file),path.join(backup,file));fs.writeFileSync(path.join(p.paths.directory,file),content);}
const check=loadPlanet('Viltrum');for(const {x,y,output}of deltas)assert.equal(check.grid[500-y][x-1],output,`Manual tile lost: ${x},${y}`);
fs.writeFileSync(path.join(root,'docs/Maps/ViltrumManualRecovery.json'),JSON.stringify({outputHash:digest,recoveredTiles:deltas.length,changedChunks:updates.map(v=>v.file),conflicts,resolution:'Manual output tiles preserved exactly; capital floor conflicts retain user edits.',backup:'docs/Maps/RebuildBaseline/ManualOutputRecovery'},null,2)+'\n');
// Adopt only after proving every changed output tile exists in source chunks.
const metadata=JSON.parse(fs.readFileSync(p.paths.metadata));metadata.outputHash=digest;fs.writeFileSync(p.paths.metadata,JSON.stringify(metadata,null,2)+'\n');
console.log(`Recovered ${deltas.length} tiles in ${updates.length} chunks; ${conflicts.length} conflicts resolved in favor of manual tiles.`);
