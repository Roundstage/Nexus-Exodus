'use strict';
if(process.argv.length!==2)throw Error('No overwrite options.');
const fs=require('node:fs'),path=require('node:path'),{root}=require('./PlanetChunks.cjs'),{begin}=require('./EarthAuthoring.cjs');
const {spec,rect,route,prop,directory,point,hall,home,finish,floor,roof,facade,furn,put}=begin('Regions','EarthCityAssembly.json');
// Two long-distance crossings link the continents while retaining water beneath
// bridge decks. The three original rivers, falls and green margins stay intact.
route([[194,398],[312,398],[312,374]]);route([[194,414],[312,414]]);
route([[267,398],[267,430]]);route([[290,414],[290,452]]);
route([[96,414],[180,414],[180,446]]);route([[96,412],[96,449]]);route([[45,398],[60,398],[60,439]]);
route([[110,210],[110,142],[140,142]]);route([[160,220],[160,150],[140,150]]);
route([[110,142],[110,65],[245,65],[245,135],[110,135]]);route([[110,115],[245,115]]);route([[110,80],[245,80]]);
route([[315,170],[315,433]]);route([[410,160],[410,440]]);route([[450,190],[450,390]]);
for(const y of [190,230,300,350,390])route([[315,y],[450,y]]);
route([[278,197],[330,197]]);route([[278,217],[330,217]]);route([[278,197],[278,217]]);
route([[450,350],[476,350]]);route([[450,330],[476,330]]);
// Northwest coast, farmland and northern cabins.
hall('Northwest lighthouse',54,419,67,435,{roofType:roof+'/Blue',material:floor+'/Sidewalk'});prop(57,431,furn+'/Files');directory(57,423,'Coastal route board','South: arrival park and western city. East: farms and the northern crossings. Keep the coastal walk clear.');
home('Northern woodland cabin',91,431,107,444);home('Northern farmhouse',160,418,176,431);
for(let y=435;y<=444;y++)for(let x=155;x<=177;x++)if((y-435)%3<2)put(x,y,'/turf/GroundDirt');point('Northern farm fields',165,440);
// Arctic remains exclusively on the original northern island.
hall('Arctic research outpost',268,433,282,446,{roofType:roof+'/Blue',material:floor+'/Clinic'});for(const x of [271,279])prop(x,442,furn+'/Desk');
directory(271,437,'Arctic field log','Northern island station. Return south by either crossing. Snow and sea-ice surveys operate around the island perimeter.');
hall('Northern geological station',384,416,399,431,{roofType:roof+'/Dark'});prop(388,427,furn+'/Toolbox');
hall('Alpine survey shelter',344,436,358,448,{facadeType:facade+'/Wood'});prop(347,444,furn+'/Bookcase');point('Eastern lake shore',381,405);
// East-bank suburbs and harbor: domestic interiors, school, warehouse and docks.
home('East suburb family home',324,370,338,384);home('East suburb courtyard home',340,356,353,369);
hall('East suburb community school',389,357,404,375);for(const x of [392,401])for(const y of [361,371])prop(x,y,furn+'/Desk');
hall('Eastern neighborhood grocery',398,316,420,334,{facadeType:facade+'/Brick'});for(const x of [401,417])for(const y of [320,330])prop(x,y,furn+'/Shelf');
hall('Harbor freight warehouse',428,319,443,339,{roofType:roof+'/Dark',material:floor+'/Grate',doors:5});for(const x of [431,440])for(const y of [323,335])prop(x,y,furn+'/Cabinet');
directory(432,324,'Harbor dispatch','North and south piers lead to the waterfront. Warehouse west; neighborhood stores farther inland. Western city via the northern crossings.');point('North harbor pier',470,350);point('South harbor pier',470,330);
// Commercial belt and jungle-frontier settlements.
rect(320,269,349,298,'/turf/Grass13');spec.combatSpaces.push({name:'Eastern community training park',bounds:[320,269,349,298],minimum:28});point('Eastern community training park',335,284);
hall('Eastern manufacturing hall',324,234,346,251,{roofType:roof+'/Dark',material:floor+'/Grate',doors:5});for(const x of [328,342])for(const y of [238,247])prop(x,y,furn+'/Toolbox');
hall('Regional technical college',420,270,441,289,{roofType:roof+'/Blue',material:floor+'/Sidewalk'});for(const x of [423,438])for(const y of [274,285])prop(x,y,furn+'/Desk');
home('Eastern fishing house',427,233,442,246);hall('Jungle field laboratory',336,210,354,225,{roofType:roof+'/Blue',material:floor+'/Clinic'});prop(340,221,furn+'/Desk');prop(351,214,furn+'/Files');
hall('Jungle lookout lodge',346,164,362,181,{facadeType:facade+'/Wood'});prop(350,177,furn+'/Bench');
hall('Southern delta field station',400,173,416,188,{roofType:roof+'/Blue'});prop(404,184,furn+'/Desk');point('Eastern delta viewpoint',397,190);
// The small central island stays green, with modest public lodging and two piers.
hall('Island nature lodge',269,199,282,212,{facadeType:facade+'/Wood'});prop(272,208,furn+'/Bench');prop(279,203,furn+'/Bookcase');
// Southern desert and oasis town. No desert tile expands over an existing green margin.
home('Oasis courtyard house',111,88,128,101);hall('Oasis trading hall',135,102,154,117,{facadeType:facade+'/Brick'});
for(const x of [139,150])prop(x,113,furn+'/Shelf');home('Southern travelers inn',141,66,157,79);
home('Southern farmstead',143,136,158,150);for(let y=123;y<=131;y++)for(let x=119;x<=138;x++)if((x-119)%3<2)put(x,y,'/turf/GroundDirt');point('Oasis farm plots',128,127);
hall('Canyon repair workshop',225,90,243,108,{roofType:roof+'/Dark',material:floor+'/Grate'});prop(229,104,furn+'/Toolbox');prop(239,94,furn+'/Cabinet');
hall('Southern dune shelter',227,54,240,63,{facadeType:facade+'/Wood'});prop(230,59,furn+'/Bench');
directory(139,106,'Oasis town routes','Trading hall and farms. The waterfall and its green banks lie east. West and east bridges return to the western city; the coastal road circles the desert.');
// Divide the first city's homes into bedroom and kitchen, with a central 3-tile arch.
for(const [a,b,c,d]of[[65,379,84,393],[107,379,122,393],[64,301,82,310],[104,301,121,310]]){
 const cx=Math.floor((a+c)/2),cy=Math.floor((b+d)/2);for(let x=a+1;x<c;x++)if(Math.abs(x-cx)>1)put(x,cy,roof);
}
// Eight-tile ocean boundary uses the same local entry/teleport contract as Viltrum.
rect(1,1,500,8,'/turf/EarthOceanBoundary');rect(1,493,500,500,'/turf/EarthOceanBoundary');rect(1,9,8,492,'/turf/EarthOceanBoundary');rect(493,9,500,492,'/turf/EarthOceanBoundary');
finish();
