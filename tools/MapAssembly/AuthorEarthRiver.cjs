'use strict';
const assert=require('node:assert/strict');
const {splitOutside}=require('./Dmm.cjs');
// Preserve continental geography; repair the western river's pinched, sometimes
// diagonally disconnected course. Authored stations follow the existing valley.
function authorRiverChannel(terrain){
 const stations=[[260,142,7],[267,145,7],[280,149,7],[291,142,7],[305,134,7],[314,129,7],[325,131,7],[334,134,7],[341,139,9],[350,139,7],[360,136,7],[374,131,7],[390,129,7],[398,130,7],[410,132,8]];
 const changes=[],channel=[];
 for(let y=260;y<=410;y++){
  const next=stations.findIndex(s=>s[0]>=y),one=stations[Math.max(0,next-1)],two=stations[next];
  const t=one===two?0:(y-one[0])/(two[0]-one[0]),smooth=t*t*(3-2*t);
  const center=one[1]+(two[1]-one[1])*smooth,width=Math.round(one[2]+(two[2]-one[2])*smooth);
  const left=Math.round(center-(width-1)/2),right=left+width-1;channel.push({y,left,right});
  for(let x=112;x<=174;x++){
   const atoms=splitOutside(terrain[500-y][x-1],','),old=atoms.at(-2);
   if(old==='/turf/WaterFall'||old==='/turf/Stairs_Grass')continue;
   const target=x>=left&&x<=right?'/turf/Water2':old==='/turf/Water2'?'/turf/Grass13':old;
   if(target===old)continue;
   assert(!atoms.some(a=>a.startsWith('/obj/Spawn')),`River would move a spawn at ${x},${y}`);
   atoms[atoms.length-2]=target;terrain[500-y][x-1]=atoms.join(',');changes.push({x,y,from:old,to:target});
  }
 }
 return {bounds:[112,260,174,410],stations,channel,changes,minChannelWidth:Math.min(...channel.map(r=>r.right-r.left+1))};
}
module.exports={authorRiverChannel};
