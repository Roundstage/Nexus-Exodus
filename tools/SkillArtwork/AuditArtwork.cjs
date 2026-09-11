const fs=require('fs'),path=require('path'),crypto=require('crypto'),sharp=require('sharp');
const root=path.resolve(__dirname,'../..'),folder=path.join(root,'artifacts/SkillArtwork');
const manifest=JSON.parse(fs.readFileSync(path.join(folder,'Manifest.json')));
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
(async()=>{
 const errors=[],missing=[],hashes=new Map(),types=new Set(),assets=new Set();
 let checked=0,totalBytes=0;
 for(const s of manifest.skills){
  if(types.has(s.type)||assets.has(s.asset)) errors.push(s.id+': duplicate type or asset path');
  types.add(s.type);assets.add(s.asset);
  const recordPath=path.join(folder,'Records',s.id+'.json');
  if(!fs.existsSync(recordPath)){missing.push(s.id);continue;}
  try{
   const r=JSON.parse(fs.readFileSync(recordPath));
   const original=fs.readFileSync(path.join(root,s.original)),asset=fs.readFileSync(path.join(root,s.asset));
   const originalMeta=await sharp(original).metadata(),assetMeta=await sharp(asset).metadata();
   if(r.id!==s.id||r.original!==s.original||r.asset!==s.asset)errors.push(s.id+': record identity mismatch');
   if(hash(original)!==r.sha256)errors.push(s.id+': changed original');
   if(hash(s.prompt)!==r.promptSha256)errors.push(s.id+': changed prompt');
   if(originalMeta.width!==originalMeta.height||originalMeta.width!==r.originalWidth||originalMeta.height!==r.originalHeight)errors.push(s.id+': invalid original dimensions');
   if(assetMeta.width!==128||assetMeta.height!==128||assetMeta.format!=='png')errors.push(s.id+': invalid runtime PNG');
   const expected=await sharp(original).resize(128,128,{kernel:'lanczos3'}).png({compressionLevel:9}).toBuffer();
   if(!asset.equals(expected))errors.push(s.id+': runtime image differs from original resampling');
   const digest=hash(asset);
   if(hashes.has(digest))errors.push(s.id+': duplicates '+hashes.get(digest));else hashes.set(digest,s.id);
   if(!s.subject||!s.artDescription)errors.push(s.id+': missing visual brief or description');
   totalBytes+=asset.length;checked++;
  }catch(e){errors.push(s.id+': '+e.message);}
 }
 for(const e of manifest.excluded)if(types.has(e.type))errors.push(e.type+': both included and excluded');
 const report={expected:manifest.skills.length,checked,missing,errors,uniqueArtworks:hashes.size,runtimeBytes:totalBytes,approvedSamples:manifest.skills.filter(s=>s.approvedSample).length};
 fs.writeFileSync(path.join(folder,'Audit.json'),JSON.stringify(report,null,2)+'\n');
 console.log(JSON.stringify(report,null,2));
 if(errors.length||(missing.length&&!process.argv.includes('--partial')))process.exitCode=1;
})().catch(e=>{console.error(e);process.exitCode=1;});
