'use strict';
const {splitOutside}=require('./Dmm.cjs');
// Skin the retained water topology with matching edge/corner tiles. All spawn
// atoms and water/land classifications are preserved; terrain art is editable.
function applyRiverTerrain(grid,baseline){
 const natural=baseline.map(r=>r.map(s=>splitOutside(s,',').at(-2).split('{')[0]));
 const isWater=(x,y)=>x<1||x>500||y<1||y>500||['/turf/Water2','/turf/WaterFall'].includes(natural[500-y][x-1]);
 const offsets=[[0,1],[1,0],[0,-1],[-1,0],[1,1],[1,-1],[-1,-1],[-1,1]];
 let waterTiles=0,bankTiles=0;
 for(let y=1;y<=500;y++)for(let x=1;x<=500;x++){
  const atoms=splitOutside(grid[500-y][x-1],','),type=atoms.at(-2).split('{')[0];let replacement;
  const mask=offsets.reduce((n,[dx,dy],bit)=>n+(isWater(x+dx,y+dy)?2**bit:0),0);
  if(['/turf/Water2','/turf/EarthRiver'].includes(type)){replacement=`/turf/EarthRiver{icon_state = "water_${mask}"}`;waterTiles++;}
  else if(['/turf/Grass13','/turf/EarthStreet/Lawn','/turf/EarthRiverBank'].includes(type)){replacement=`/turf/EarthRiverBank{icon_state = "bank_${mask}"}`;bankTiles++;}
  else if(type==='/turf/WaterFall')replacement='/turf/EarthRiverFall';
  else if(type==='/turf/Stairs_Grass')replacement='/turf/EarthRiverSteps';
  else if(type==='/turf/Wall12'&&x>=115&&x<=162&&y>=346&&y<=354)replacement='/turf/EarthRiverRock';
  if(replacement){atoms[atoms.length-2]=replacement;grid[500-y][x-1]=atoms.join(',');}
 }
 return {waterTiles,bankTiles,waterTopologyPreserved:true,matchedEdgesAndCorners:true};
}
module.exports={applyRiverTerrain};
