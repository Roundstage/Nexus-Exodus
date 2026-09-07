// Hand-directed geography with deterministic scenery. --force replaces the map.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),out=path.join(root,'src/Maps/SuperEarth.dmm');
if(fs.existsSync(out)&&!process.argv.includes('--force'))throw Error('Map exists; --force replaces it.');
const n=500,g=Array.from({length:n},()=>Array(n).fill(0));
const p=[['/turf/Water2','#285d83'],['/turf/Ground14','#d8c08b'],['/turf/Grass13','#699654'],['/turf/Grass8','#91a16a'],['/turf/GroundDirt','#a68b66'],['/turf/Wall12','#676c58'],['/turf/WaterFall','#95d4df'],['/turf/Stairs_Grass','#99ab7c']];
p.push(['/turf/Ground10','#cdb077'],['/turf/Grass12','#3e784e'],['/turf/GroundSnow','#e2e9e8'],['/turf/GroundIce2','#b8d9df']);
const set=(x,y,t)=>{if(x>=1&&x<=n&&y>=1&&y<=n)g[n-y][x-1]=t;};
const get=(x,y)=>x>=1&&x<=n&&y>=1&&y<=n?g[n-y][x-1]:0;
function disk(cx,cy,r,t){for(let y=cy-r;y<=cy+r;y++)for(let x=cx-r;x<=cx+r;x++)if((x-cx)**2+(y-cy)**2<=r*r)set(x,y,t);}
function line(ax,ay,bx,by,r,t){const steps=Math.max(Math.abs(ax-bx),Math.abs(ay-by));for(let i=0;i<=steps;i++)disk(Math.round(ax+(bx-ax)*i/(steps||1)),Math.round(ay+(by-ay)*i/(steps||1)),r,t);}
const landforms=[[116,326,88,140],[370,298,98,164],[174,96,110,61],[279,438,31,30],[278,207,25,28]];
const landOwner=Array.from({length:n},()=>Array(n).fill(-1));
for(let y=1;y<=n;y++)for(let x=1;x<=n;x++){
 let depth=-9,owner=-1;for(let i=0;i<landforms.length;i++){const[cx,cy,rx,ry]=landforms[i],dx=(x-cx)/rx,dy=(y-cy)/ry,a=Math.atan2(dy,dx),candidate=1+.07*Math.sin(a*5+cx)+.04*Math.sin(a*9+cy)-Math.sqrt(dx*dx+dy*dy);if(candidate>depth){depth=candidate;owner=i;}}
 if(depth>0)landOwner[n-y][x-1]=owner;
 if(depth>0)set(x,y,depth<.045?1:depth<.10?3:2);
}
// Three source lakes feed continuous rivers ending in the ocean.
const rivers=[[[132,409],[128,383],[139,350],[128,315],[149,279],[137,243],[132,175]],[[367,413],[356,380],[368,342],[388,302],[372,267],[391,221],[381,174],[387,117]],[[190,119],[184,96],[203,71],[218,37]]];
for(const points of rivers){const [sx,sy]=points[0];disk(sx,sy,14,3);disk(sx,sy,11,0);
 for(let i=1;i<points.length;i++){const[a,b]=points[i-1],[c,d]=points[i];line(a,b,c,d,5,3);line(a,b,c,d,3,0);}}
// Rock faces cross the rivers; grass stairways give a walking route around them.
const falls=[[139,350],[368,342],[184,96]];
for(const[x,y]of falls){for(let dx=-22;dx<=22;dx++){if(Math.abs(dx)>3){set(x+dx,y,5);set(x+dx,y+1,4);}else {set(x+dx,y,6);set(x+dx,y+1,0);}}
 for(let dy=-2;dy<=3;dy++)for(let dx=17;dx<=20;dx++)set(x+dx,y+dy,7);
 disk(x,y-7,6,0);
}
// Sparse broken escarpments and dirt trails make terrain readable at player scale.
for(const[cx,cy]of [[86,407],[415,374],[340,235],[147,121]])for(let dx=-14;dx<=14;dx++)if(Math.abs(dx)>3&&get(cx+dx,cy)!==0)set(cx+dx,cy,5);
const anchors=[[95,362],[78,289],[163,329],[340,395],[413,297],[329,205],[135,92],[225,100]];
// Explicit geographic biomes. Water, cliffs, waterfalls and stairways are never replaced.
const biomeCounts={desert:0,jungle:0,arctic:0};
for(let y=1;y<=n;y++)for(let x=1;x<=n;x++){
 const t=get(x,y);if(![1,2,3,4].includes(t))continue;
 if(landOwner[n-y][x-1]===3){set(x,y,y>449+3*Math.sin(x*.13)?11:10);biomeCounts.arctic++;}
 else if(y<160&&x<290&&t===2){set(x,y,8);biomeCounts.desert++;}
 else if(x>300&&y<345+7*Math.sin(x*.05)&&y>145&&t===2){set(x,y,9);biomeCounts.jungle++;}
}
assert(biomeCounts.desert>2000&&biomeCounts.jungle>2000&&biomeCounts.arctic>1000,'Missing requested biome');
const races=['Human','Tsujin','Demigod','Saiyan','Half Saiyan','Legendary Saiyan','Heran','Android','Bio-Android','Spirit Doll','Kai','Majin','Namekian','Alien','Kanassan','Demon','Makyo','Frost Lord','Ancient Namekian','Ancient Progenitor'];
const spawns=[];
const safe=(x,y,r)=>{for(let dy=-r;dy<=r;dy++)for(let dx=-r;dx<=r;dx++)if(![1,2,3,4,8,9,10,11].includes(get(x+dx,y+dy)))return false;return true;};
for(let i=0;i<races.length;i++){const[ax,ay]=anchors[i%anchors.length];let best=null,score=Infinity;
 for(let y=ay-25;y<=ay+25;y++)for(let x=ax-25;x<=ax+25;x++){const d=(ax-x)**2+(ay-y)**2;if(d<score&&safe(x,y,4)&&spawns.every(([,sx,sy])=>(sx-x)**2+(sy-y)**2>=100)){score=d;best=[x,y];}}
 assert(best);const[x,y]=best;spawns.push([races[i],x,y]);}
// Preserve the established arrival area as an unobstructed natural meadow.
for(let y=352;y<=372;y++)for(let x=91;x<=111;x++)set(x,y,2);
let seed=9132026;const random=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/4294967296;};
const variants=new Map();function decor(base,obj,color){const key=base+obj;if(!variants.has(key)){variants.set(key,p.length);p.push([p[base][0],color,obj]);}return variants.get(key);}
let decorations=0;
for(let y=2;y<n;y++)for(let x=2;x<n;x++){
 const t=get(x,y);if(![2,3,4,8,9,10].includes(t)||Math.abs(x-101)<=14&&Math.abs(y-362)<=14||spawns.some(([,sx,sy])=>(sx-x)**2+(sy-y)**2<64))continue;
 const patch=Math.sin(x*.061+y*.027)+Math.cos(y*.073-x*.019),r=random();
 if(t===9&&patch>-.7&&r<.55&&x%5===0&&y%5===0){set(x,y,decor(t,'/obj/Trees/Tree_20194','#244d35'));decorations++;}
 else if(t===10&&patch>.3&&r<.08&&x%4===0&&y%4===0){set(x,y,decor(t,'/obj/Trees/Tree_20193','#83a79e'));decorations++;}
 else if(t===2&&patch>.5&&r<.055&&x%3===0&&y%3===0){set(x,y,decor(t,'/obj/Trees/Tree_20191','#365c37'));decorations++;}
 else if(r<.004&&patch<-.6){set(x,y,decor(t,'/obj/Turfs/Rock1','#747763'));decorations++;}
}
for(const[r,x,y]of spawns){const t=get(x,y);p.push([p[t][0],'#ffdc83',`/obj/Spawn{name = "${r}"; desc = "Super Terra - ${r}"}`]);set(x,y,p.length-1);}
for(let y=1;y<=n;y++)for(let x=1;x<=n;x++)if(['/turf/GroundSnow','/turf/GroundIce2'].includes(p[get(x,y)][0]))assert(landOwner[n-y][x-1]===3,'Arctic terrain leaked outside its island');
for(let y=352;y<=372;y++)for(let x=91;x<=111;x++)assert(get(x,y)===2||p[get(x,y)][2]?.startsWith('/obj/Spawn'));
for(const[x,y]of falls)assert(get(x,y)===6&&get(x,y+1)===0&&get(x,y-1)===0);
const alphabet='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',key=i=>alphabet[Math.floor(i/52)]+alphabet[i%52];
const text=p.map(([t,,o],i)=>`"${key(i)}" = (${o?o+',':''}${t},/area/SuperEarth)`).join('\n')+'\n\n(1,1,1) = {"\n'+g.map(r=>r.map(key).join('')).join('\n')+'\n"}\n';
const backup=path.join(root,'tmp/SuperEarthBeforeScenic.dmm');fs.mkdirSync(path.dirname(backup),{recursive:true});if(fs.existsSync(out)&&!fs.existsSync(backup))fs.copyFileSync(out,backup);fs.writeFileSync(out,text);
fs.writeFileSync(path.join(root,'docs/Maps/SuperEarthSpawns.json'),JSON.stringify({landing:[101,362],spawns,waterfalls:falls,rivers,decorations,biomeCounts},null,2)+'\n');
// Preview recipe contains actual DMM tile indices and sprite asset information.
fs.writeFileSync(path.join(root,'docs/Maps/SuperEarthRender.json'),JSON.stringify({palette:p,grid:g}));
let svg='<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1000" viewBox="0 0 500 500">';
for(let y=0;y<n;y++){let s=0;for(let x=1;x<=n;x++)if(x===n||g[y][x]!==g[y][s]){svg+=`<rect x="${s}" y="${y}" width="${x-s}" height="1" fill="${p[g[y][s]][1]}"/>`;s=x;}}
fs.writeFileSync(path.join(root,'docs/Maps/SuperEarthOverview.svg'),svg+'</svg>');
console.log(JSON.stringify({spawns:spawns.length,waterfalls:falls.length,decorations,tiles:250000}));
