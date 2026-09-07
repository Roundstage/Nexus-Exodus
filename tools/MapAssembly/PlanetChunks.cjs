'use strict';
const fs=require('node:fs'), path=require('node:path');
const {parse,serialize,hash,splitOutside}=require('./Dmm.cjs');
const root=path.resolve(__dirname,'../..');
const version='1.0.0';
function planetPaths(planet, base=root) {
 if(!['Viltrum','SuperEarth'].includes(planet)) throw Error('Planet must be Viltrum or SuperEarth');
 const directory=path.join(base,'src/Maps/PlanetChunks',planet);
 return {directory,manifest:path.join(directory,`${planet}Manifest.json`),output:path.join(base,'src/Maps',`${planet}.dmm`),metadata:path.join(base,'src/Maps',`${planet}Metadata.json`)};
}
// A conservative declaration index, not a DM compiler. Full smoke remains the
// authority for macros, conditional compilation, variable values and inheritance.
function environmentTypes(base=root) {
 const types=new Set(['/area','/turf','/obj','/mob']), visited=new Set();
 function read(file) {
  if(visited.has(file)) return; visited.add(file);
  const source=fs.readFileSync(file,'utf8');
  for(const m of source.matchAll(/^\s*#include\s+"([^"\r\n]+\.(?:dm|dme))"/gm)) read(path.resolve(path.dirname(file),m[1].replace(/\\/g,'/')));
  const levels=[]; let comment=false;
  for(const original of source.split(/\r?\n/)) {
   let line=original;
   if(comment) { const end=line.indexOf('*/'); if(end<0) continue; line=line.slice(end+2);comment=false; }
   const start=line.indexOf('/*'); if(start>=0) { const end=line.indexOf('*/',start+2); if(end<0){line=line.slice(0,start);comment=true;}else line=line.slice(0,start)+line.slice(end+2); }
   if(!line.trim() || /^\s*(?:\/\/|#)/.test(line)) continue;
   const indent=line.match(/^\s*/)[0].replace(/\t/g,'    ').length;
   while(levels.length && levels.at(-1).indent>=indent) levels.pop();
   const token=line.trim().replace(/\s*\/\/.*$/,'').trim();
   const declaration=/^\/?[A-Za-z_]\w*(?:\/[A-Za-z_]\w*)*$/.test(token);
   const parent=levels.at(-1);
   let full=null;
   if(declaration && (!parent || parent.full)) {
    full=token.startsWith('/') ? token : (parent ? parent.full+'/' : '/')+token;
    if(full.split('/').some(s=>['proc','verb','var','tmp','const','global'].includes(s))) full=null;
    if(full && /^\/(area|turf|obj|mob)(\/|$)/.test(full)) { const parts=full.split('/'); for(let n=2;n<=parts.length;n++) types.add(parts.slice(0,n).join('/')); }
   }
   levels.push({indent,full});
  }
 }
 read(path.join(base,'DU.dme')); return types;
}
function loadPlanet(planet,base=root) {
 const paths=planetPaths(planet,base), raw=fs.readFileSync(paths.manifest), manifest=JSON.parse(raw);
 if(manifest.version!==1 || manifest.planet!==planet || manifest.chunkSize!==100 || manifest.rows!=='ABCDE' || manifest.columns!==5 || manifest.chunks.length!==25) throw Error('Invalid manifest structure');
 const expected=Array.from({length:25},(_,i)=>`${planet}${'ABCDE'[Math.floor(i/5)]}${i%5+1}.dmm`);
 const listed=manifest.chunks.map(c=>c.file);
 if(new Set(listed).size!==25 || expected.some(f=>!listed.includes(f))) throw Error('Missing, duplicate or out-of-manifest chunk');
 const actual=fs.readdirSync(paths.directory,{recursive:true}).filter(f=>/\.dmm$/i.test(f));
 if(actual.length!==25 || actual.some(f=>!expected.includes(f))) throw Error('Unexpected chunk files');
 const grid=Array.from({length:500},()=>Array(500)), chunkHashes={};
 for(const entry of manifest.chunks) {
  const match=entry.file.match(/([A-E])([1-5])\.dmm$/), row='ABCDE'.indexOf(match[1]), col=+match[2]-1;
  if(entry.row!==match[1] || entry.column!==col+1) throw Error('Manifest coordinates do not match chunk name');
  const data=fs.readFileSync(path.join(paths.directory,entry.file)), map=parse(data.toString());
  if(map.width!==100 || map.height!==100) throw Error(`Wrong chunk dimensions: ${entry.file}`);
  chunkHashes[entry.file]=hash(data);
  for(let y=0;y<100;y++) for(let x=0;x<100;x++) grid[row*100+y][col*100+x]=map.grid[y][x];
 }
 const types=environmentTypes(base), palette=[...new Set(grid.flat())];
 for(const stack of palette) for(const atom of splitOutside(stack,',')) {
  const type=atom.split('{')[0]; if(!types.has(type)) throw Error(`Undefined or unindexed environment type ${type}; verify its declaration in DU.dme`);
  if(type.startsWith('/area') && type!==`/area/${planet}`) throw Error(`Wrong planet area ${type}`);
 }
 return {paths,manifest,grid,chunkHashes,manifestHash:hash(raw),palette};
}
function assemble(planet,{base=root,acknowledgeManualOutputEdits=false,check=false}={}) {
 const data=loadPlanet(planet,base), output=serialize(data.grid), outputHash=hash(output), p=data.paths;
 if(fs.existsSync(p.output)) {
  const currentHash=hash(fs.readFileSync(p.output));
  const recorded=fs.existsSync(p.metadata) ? JSON.parse(fs.readFileSync(p.metadata)).outputHash : data.manifest.seedHash;
  if(currentHash!==recorded && !acknowledgeManualOutputEdits) throw Error('Manual output edits detected. Recover them into chunks, or explicitly pass --acknowledge-manual-output-edits-lost.');
 }
 const counts={turfs:250000,areas:250000,objects:0,mobs:0};
 for(const row of data.grid) for(const tile of row) for(const atom of splitOutside(tile,',')) { if(atom.startsWith('/obj/')) counts.objects++; if(atom.startsWith('/mob/')) counts.mobs++; }
 const metadata={generatorVersion:version,manifestHash:data.manifestHash,chunkHashes:data.chunkHashes,outputHash,dimensions:[500,500,1],paletteKeyCount:data.palette.length,atomCounts:counts};
 if(!check) {
  const prior=fs.existsSync(p.metadata) ? JSON.parse(fs.readFileSync(p.metadata)) : null;
  metadata.generatedAt=prior && prior.outputHash===outputHash && prior.manifestHash===metadata.manifestHash && JSON.stringify(prior.chunkHashes)===JSON.stringify(metadata.chunkHashes) ? prior.generatedAt : new Date().toISOString();
  fs.writeFileSync(p.output+'.pending',output);fs.renameSync(p.output+'.pending',p.output);
  fs.writeFileSync(p.metadata,JSON.stringify(metadata,null,2)+'\n');
 }
 return {...metadata,output};
}
module.exports={root,version,planetPaths,environmentTypes,loadPlanet,assemble};
