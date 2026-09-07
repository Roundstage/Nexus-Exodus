'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'../..');
const expected=['Map2018','Space2018','Viltrum','SuperEarth','CityInteriors'].map(n=>`src/Maps/${n}.dmm`);
function check(source){
 const begin=source.indexOf('// BEGIN_INCLUDE');assert(begin>=0);
 assert.equal(source.indexOf('BEGIN_INCLUDE'),begin+3,'Reserved editor marker appears in an earlier comment');
 const first=new Map();
 for(const m of source.matchAll(/^\s*#include\s+"([^"\r\n]+\.dmm)"/gm)){
  const file=m[1].replace(/\\/g,'/');if(!first.has(file))first.set(file,m.index);
 }
 assert.deepEqual([...first.keys()],expected,'Effective runtime map load order is wrong');
 assert([...first.values()].every(index=>index<begin),'Runtime map order must be protected above the editor-generated block');
 return [...first.keys()];
}
function run(){
 const source=fs.readFileSync(path.join(root,'DU.dme'),'utf8');check(source);
 // Model the editor registering every map alphabetically after a save, even
 // when it already appears outside the generated include block.
 const registrations=expected.slice().sort().map(f=>`#include "${f}"`).join('\n');
 const editorSave=source.replace('// END_INCLUDE',registrations+'\n// END_INCLUDE');
 check(editorSave);
 // Dream Maker recognizes the reserved marker even inside explanatory text.
 // Such a comment made the editor erase the supposedly protected preamble.
 assert.throws(()=>check(source.replace('// Load runtime maps','// Keep above BEGIN_INCLUDE.\n// Load runtime maps')),/Reserved editor marker/);
 const withoutPreamble=source.replace(/^#include "src\\Maps\\[^"\r\n]+\.dmm"\r?\n/gm,'');
 assert.throws(()=>check(withoutPreamble.replace('// END_INCLUDE',registrations+'\n// END_INCLUDE')),/load order/);
 // Verify the accumulated dimensions supporting the game's hard-coded Zs.
 const levels=[];let last=0;
 for(const file of expected){
  const text=fs.readFileSync(path.join(root,file),'utf8');let max=0;
  for(const m of text.matchAll(/^\(\s*\d+\s*,\s*\d+\s*,\s*(\d+)\s*\)\s*=/gm))max=Math.max(max,+m[1]);
  assert(max>0,`No map Z blocks in ${file}`);levels.push([last+1,last+max]);last+=max;
 }
 assert.deepEqual(levels,[[1,15],[16,19],[20,20],[21,21],[22,22]]);
 console.log('PASS runtime map order, editor-save regression, missing-preamble rejection and global Z1-22 spans');
}
module.exports={check};if(require.main===module)run();
