'use strict';
// One-time lossless migration of the CURRENT map; never reruns a blockout generator.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {parse,serialize,hash}=require('./Dmm.cjs');
const {planetPaths}=require('./PlanetChunks.cjs');
const planet=process.argv[2];
if(process.argv.length!==3) throw Error('Usage: node tools/MapAssembly/SeedPlanetChunks.cjs Viltrum|SuperEarth (no overwrite options)');
const p=planetPaths(planet);
if(fs.existsSync(p.directory)) throw Error('Chunk directory already exists; sources are never overwritten');
const source=fs.readFileSync(p.output),map=parse(source.toString());
assert.equal(map.width,500);assert.equal(map.height,500);
const chunks=[], files=[];
for(let row=0;row<5;row++) for(let col=0;col<5;col++) {
 const grid=map.grid.slice(row*100,row*100+100).map(r=>r.slice(col*100,col*100+100));
 const file=`${planet}${'ABCDE'[row]}${col+1}.dmm`, output=serialize(grid);
 assert.deepEqual(parse(output).grid,grid); files.push({file,output});chunks.push({file,row:'ABCDE'[row],column:col+1});
}
fs.mkdirSync(p.directory,{recursive:true});
for(const f of files) fs.writeFileSync(path.join(p.directory,f.file),f.output,{flag:'wx'});
fs.writeFileSync(p.manifest,JSON.stringify({version:1,planet,chunkSize:100,rows:'ABCDE',columns:5,seedHash:hash(source),orientation:'A is north; local (1,1) is southwest; global y = (4-rowIndex)*100 + localY',chunks},null,2)+'\n',{flag:'wx'});
console.log(`Seeded 25 lossless ${planet} chunks; original output unchanged`);
