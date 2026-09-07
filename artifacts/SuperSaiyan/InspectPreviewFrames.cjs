const fs=require('fs');for(const n of ['Body','BaseHair','GoldHair']){let b=fs.readFileSync('artifacts/SuperSaiyan/SsjPreview'+n+'.png');console.log(n,b.readUInt32BE(16),b.readUInt32BE(20));}
