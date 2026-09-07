const fs=require('fs'),z=require('zlib');
for(const p of ['src/Icons/PlayerIcons/BaseIcons/NewHumanIconsFromGuppinas/BaseHumanPale.dmi','src/Icons/PlayerIcons/Hair/HairGoku.dmi','src/Icons/PlayerIcons/Hair/HairGokuSSj.dmi']){
 const b=fs.readFileSync(p);console.log(p,b.readUInt32BE(16),b.readUInt32BE(20));for(let o=8;o<b.length;){const n=b.readUInt32BE(o),t=b.toString('ascii',o+4,o+8),d=b.subarray(o+8,o+8+n);if(t==='zTXt')console.log(z.inflateSync(d.subarray(d.indexOf(0)+2)).toString().slice(0,700));o+=n+12;}
}
