'use strict';
// Recovery of the inspected 2026-09-06 editor save before wilderness authoring.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root,loadPlanet,assemble}=require('./PlanetChunks.cjs'),{parse,serialize,hash}=require('./Dmm.cjs');
const p=loadPlanet('SuperEarth'),bytes=fs.readFileSync(p.paths.output);
assert.equal(hash(bytes),'e92c79dfcbcf8c5dc74776e1c3da9b00c788422e3e599f7c8c8f28854ea8092d','Editor save changed again; inspect before recovery.');
const folder=path.join(root,'.codex-tmp/EarthWilderness'),delta=JSON.parse(fs.readFileSync(path.join(folder,'ManualChanges.json')));
const map=parse(fs.readFileSync(path.join(folder,'ManualNormalized.dmm'),'utf8'));
assert.equal(delta.changes.length,4397);
for(const c of delta.changes){assert.equal(p.grid[500-c.y][c.x-1],c.before);assert.equal(map.grid[500-c.y][c.x-1],c.after);}
const backup=path.join(root,'docs/Maps/RebuildBaseline/EarthManualRecovery');assert(!fs.existsSync(backup),'Already recovered.');fs.mkdirSync(backup);
fs.writeFileSync(path.join(backup,'SuperEarthEditorSave.dmm'),bytes);fs.writeFileSync(path.join(backup,'SuperEarthBeforeRecovery.dmm'),serialize(p.grid));
fs.copyFileSync(p.paths.metadata,path.join(backup,'PreviousMetadata.json'));
fs.copyFileSync(path.join(root,'docs/Maps/EarthNeighborhood.json'),path.join(backup,'EarthNeighborhood.json'));
const changedChunks=[];
for(let row=0;row<5;row++)for(let col=0;col<5;col++){
 const file=`SuperEarth${'ABCDE'[row]}${col+1}.dmm`,content=serialize(map.grid.slice(row*100,row*100+100).map(r=>r.slice(col*100,col*100+100)));
 if(hash(content)===p.chunkHashes[file])continue;
 fs.copyFileSync(path.join(p.paths.directory,file),path.join(backup,file));fs.writeFileSync(path.join(p.paths.directory,file),content);changedChunks.push(file);
}
const recovered=loadPlanet('SuperEarth');assert.deepEqual(recovered.grid,map.grid,'Recovery differs from inspected editor map.');
const meta=JSON.parse(fs.readFileSync(p.paths.metadata));meta.outputHash=hash(bytes);fs.writeFileSync(p.paths.metadata,JSON.stringify(meta,null,2)+'\n');
const assembled=assemble('SuperEarth');
const report={editorHash:hash(bytes),outputHash:assembled.outputHash,recoveredTiles:delta.changes.length,changedChunks,normalization:'Two invalid multi-turf dictionary entries retain their last declared turf; raw editor file retained.',...delta};
fs.writeFileSync(path.join(root,'docs/Maps/SuperEarthManualRecovery.json'),JSON.stringify(report,null,2)+'\n');
const neighborhood=JSON.parse(fs.readFileSync(path.join(root,'docs/Maps/EarthNeighborhood.json')));
Object.assign(neighborhood,{outputHash:assembled.outputHash,chunkHashes:assembled.chunkHashes,manualRecovery:'SuperEarthManualRecovery.json'});
fs.writeFileSync(path.join(root,'docs/Maps/EarthNeighborhood.json'),JSON.stringify(neighborhood,null,2)+'\n');
console.log({recoveredTiles:report.recoveredTiles,normalizedEntries:delta.fixes.length,changedChunks,outputHash:assembled.outputHash});
