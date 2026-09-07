const fs=require('fs'),z=require('zlib');
const b=fs.readFileSync('artifacts/SuperSaiyan/GoldenAuraSheet.png');let chunks=[];for(let p=8;p<b.length;){let n=b.readUInt32BE(p);if(b.toString('ascii',p+4,p+8)==='IDAT')chunks.push(b.subarray(p+8,p+8+n));p+=n+12;}
const w=b.readUInt32BE(16),h=b.readUInt32BE(20),d=z.inflateSync(Buffer.concat(chunks)),stride=w*4,raw=Buffer.alloc(h*stride);let k=0;
function paeth(a,b,c){let p=a+b-c,x=Math.abs(p-a),y=Math.abs(p-b),v=Math.abs(p-c);return x<=y&&x<=v?a:y<=v?b:c;}
for(let y=0;y<h;y++){let f=d[k++];for(let x=0;x<stride;x++){let i=y*stride+x,a=x>=4?raw[i-4]:0,c=y&&x>=4?raw[i-stride-4]:0,up=y?raw[i-stride]:0;raw[i]=(d[k++]+(f===1?a:f===2?up:f===3?Math.floor((a+up)/2):f===4?paeth(a,up,c):0))&255;}}
let alpha={};for(let i=3;i<raw.length;i+=4)alpha[raw[i]]=(alpha[raw[i]]||0)+1;console.log({w,h,colorType:b[25],transparent:alpha[0],opaque:alpha[255],alphaLevels:Object.keys(alpha).length});
