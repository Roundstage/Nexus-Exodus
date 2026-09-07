'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),os=require('node:os');
const {parse,serialize,canonical,hash}=require('./Dmm.cjs');
const {loadPlanet,assemble,root,planetPaths}=require('./PlanetChunks.cjs');
const planet=process.argv[2] || 'Viltrum'; let tests=0;
function test(name,run){run();tests++;console.log(`PASS ${name}`);}
const tile=(n='')=>`/turf${n},/area`;
test('arbitrary key widths, coordinate blocks and north/south orientation',()=> {
 const map=parse('"abc" = (/turf,/area)\n"xyz" = (/turf/Other,/area)\n(1,1,1) = {"\nabc\nxyz\n"}\n(2,1,1) = {"\nxyz\nabc\n"}');
 assert.deepEqual(map.grid,[[tile(),tile('/Other')],[tile('/Other'),tile()]]);
 assert.deepEqual(parse(serialize(map.grid)).grid,map.grid);
});
test('quote-aware stack canonicalization preserves object order and strings',()=> {
 assert.equal(canonical('/obj{name="a,);b"; dir=2}, /turf, /area'),'/obj{dir = 2; name = "a,);b"},/turf,/area');
 assert.equal(canonical('/obj{dir=2;name="a,);b"},/turf,/area'),canonical('/obj{name="a,);b";dir=2},/turf,/area'));
 assert.throws(()=>canonical('/obj,,/turf,/area'),/Empty atom/);
});
test('reject malformed, missing, overlapping and multi-Z map data',()=> {
 const def='"a" = (/turf,/area)\n',block='(1,1,1) = {"\na\n"}';
 for(const input of [def+def+block,def+'garbage',def+block+block,def+block.replace('(1,1,1)','(2,1,1)'),def+block.replace('(1,1,1)','(1,1,2)'),def+block.replace('\na\n','\nb\n'),def+'(1,1,1) = {"\naa\na\n"}', '"a" = (/obj,/area)\n'+block]) assert.throws(()=>parse(input));
});
test('serialization grows beyond two-character dictionary keys',()=> {
 const grid=[Array.from({length:2800},(_,n)=>`/turf{name = "${n}"},/area`)];
 assert.deepEqual(parse(serialize(grid)).grid,grid);
});
const data=loadPlanet(planet);
test('25 chunks, correct areas and indexed DU.dme types',()=>assert.equal(Object.keys(data.chunkHashes).length,25));
test('protected baseline semantics outside explicitly authored chunks',()=> {
 const baseline=parse(fs.readFileSync(path.join(root,'docs/Maps/RebuildBaseline',`${planet}.dmm`),'utf8'));
 const changed=['Slice','Capital','Wilderness','ManualRecovery','Regions'].flatMap(stage=>{
  const file=path.join(root,'docs/Maps',`${planet}${stage}.json`);
  return fs.existsSync(file)?JSON.parse(fs.readFileSync(file)).changedChunks:[];
 });
 for(let row=0;row<5;row++)for(let col=0;col<5;col++)if(!changed.includes(`${planet}${'ABCDE'[row]}${col+1}.dmm`)) {
  for(let y=row*100;y<row*100+100;y++)assert.deepEqual(data.grid[y].slice(col*100,col*100+100),baseline.grid[y].slice(col*100,col*100+100));
 }
});
test('repeated assembly has identical bytes',()=> {
 const first=assemble(planet,{check:true}),second=assemble(planet,{check:true});
 assert.equal(first.output,second.output);assert.deepEqual(parse(first.output).grid,data.grid);
});
const temporary=fs.mkdtempSync(path.join(os.tmpdir(),'NexusPlanetChunks-'));
try {
 fs.mkdirSync(path.join(temporary,'src/Maps/PlanetChunks'),{recursive:true});
 fs.cpSync(data.paths.directory,planetPaths(planet,temporary).directory,{recursive:true});
 const declarations=[...new Set(data.palette.flatMap(s=>s.match(/\/[A-Za-z_]\w*(?:\/[A-Za-z_]\w*)*/g)))];
 fs.writeFileSync(path.join(temporary,'DU.dme'),declarations.join('\n'));
 const p=planetPaths(planet,temporary), original=fs.readFileSync(p.manifest,'utf8');
 test('reject duplicate, missing, misnamed and out-of-manifest chunks',()=> {
  for(const change of [m=>m.chunks.pop(),m=>m.chunks[1]=m.chunks[0],m=>m.chunks[0].file='../Other.dmm',m=>m.chunks[0].row='E']) {
   const m=JSON.parse(original);change(m);fs.writeFileSync(p.manifest,JSON.stringify(m));assert.throws(()=>loadPlanet(planet,temporary));
  }
  fs.writeFileSync(p.manifest,original);
  const extra=path.join(p.directory,'Extra.dmm');fs.writeFileSync(extra,'');assert.throws(()=>loadPlanet(planet,temporary));fs.unlinkSync(extra);
 });
 test('reject wrong sizes and unknown type paths',()=> {
  const file=path.join(p.directory,`${planet}A1.dmm`),saved=fs.readFileSync(file);
  fs.writeFileSync(file,serialize([[tile()]]));assert.throws(()=>loadPlanet(planet,temporary));
  fs.writeFileSync(file,saved.toString().replace(/\/turf(?:\/\w+)*/, '/turf/UndefinedPlanetType'));assert.throws(()=>loadPlanet(planet,temporary));fs.writeFileSync(file,saved);
 });
 test('protect manual outputs and preserve stable metadata on no-op assembly',()=> {
  assemble(planet,{base:temporary});const metadata=fs.readFileSync(p.metadata,'utf8');
  assemble(planet,{base:temporary});assert.equal(fs.readFileSync(p.metadata,'utf8'),metadata);
  fs.appendFileSync(p.output,'\n// manual edit\n');assert.throws(()=>assemble(planet,{base:temporary}),/Manual output edits/);
  const chunkHashes=loadPlanet(planet,temporary).chunkHashes;
  assemble(planet,{base:temporary,acknowledgeManualOutputEdits:true});assert.deepEqual(loadPlanet(planet,temporary).chunkHashes,chunkHashes);
  assert.equal(hash(fs.readFileSync(p.output)),JSON.parse(fs.readFileSync(p.metadata)).outputHash);
 });
} finally {
 // This unique test directory is the only recursive cleanup target.
 assert(path.resolve(temporary).startsWith(path.resolve(os.tmpdir())+path.sep));
 fs.rmSync(temporary,{recursive:true});
}
console.log(`${tests} focused map tests passed; gameplay and visual gates are separate.`);
