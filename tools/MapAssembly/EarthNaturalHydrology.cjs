'use strict';
const {splitOutside}=require('./Dmm.cjs');
// Same continental outlines and river controls as the retained scenic baseline.
// All water disks are unioned before any bank is painted; later segments cannot
// overwrite upstream water, and riverbank disks cannot create land in the sea.
const landforms=[[116,326,88,140],[370,298,98,164],[174,96,110,61],[279,438,31,30],[278,207,25,28]];
function naturalLand(x,y){
 return landforms.some(([cx,cy,rx,ry])=>{const dx=(x-cx)/rx,dy=(y-cy)/ry,a=Math.atan2(dy,dx);return 1+.07*Math.sin(a*5+cx)+.04*Math.sin(a*9+cy)-Math.sqrt(dx*dx+dy*dy)>0;});
}
const key=(x,y)=>`${x},${y}`;
function riverWater(rivers,falls){
 const mask=new Set(),courses=[];
 function disk(x,y,r){for(let yy=y-r;yy<=y+r;yy++)for(let xx=x-r;xx<=x+r;xx++)if((xx-x)**2+(yy-y)**2<=r*r)mask.add(key(xx,yy));}
 for(const points of rivers){
  disk(...points[0],11);const centerline=[];
  for(let i=1;i<points.length;i++){
   const [ax,ay]=points[i-1],[bx,by]=points[i],steps=Math.max(Math.abs(ax-bx),Math.abs(ay-by));
   for(let n=0;n<=steps;n++){const x=Math.round(ax+(bx-ax)*n/steps),y=Math.round(ay+(by-ay)*n/steps);disk(x,y,3);centerline.push([x,y]);}
  }
  courses.push({source:points[0],mouth:points.at(-1),points,centerline});
 }
 for(const [x,y]of falls)disk(x,y-7,6);
 return {mask,courses};
}
function restoreHydrology(terrain,geography,cityRiver){
 const {mask,courses}=riverWater(geography.rivers,geography.waterfalls),changes=[];
 for(let y=9;y<=492;y++)for(let x=9;x<=492;x++){
  // Retain the already approved city channel, including its new river bends.
  if(x>=112&&x<=174&&y>=260&&y<=410)continue;
  const atoms=splitOutside(terrain[500-y][x-1],','),old=atoms.at(-2).split('{')[0];
  if(['/turf/WaterFall','/turf/Stairs_Grass'].includes(old))continue;
  if((!naturalLand(x,y)||mask.has(key(x,y)))&&old!=='/turf/Water2'){
   if(atoms.some(a=>a.startsWith('/obj/Spawn')))throw Error(`Hydrology would cover a spawn at ${x},${y}`);
   terrain[500-y][x-1]='/turf/Water2,/area/SuperEarth';
   changes.push({x,y,from:old,to:'/turf/Water2',reason:naturalLand(x,y)?'river segment overwritten by bank':'bank painted beyond the coastline'});
  }
 }
 return {courses,changes,cityRiverBounds:cityRiver.bounds};
}
module.exports={naturalLand,riverWater,restoreHydrology};
