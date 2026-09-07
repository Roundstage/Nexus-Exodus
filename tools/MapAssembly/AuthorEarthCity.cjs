'use strict';
if(process.argv.length!==2)throw Error('No overwrite options.');
const {begin}=require('./EarthAuthoring.cjs');
const {spec,rect,route,prop,directory,point,hall,home,finish,floor,roof,facade,furn}=begin('Slice','EarthPhaseOneAssembly.json');
// City routes follow the existing western landmass. Bridges retain Water=true;
// waterfalls, their stairs, the landing lawn and all racial spawns are protected.
route([[96,210],[96,412]]);route([[151,220],[151,398]]);route([[45,255],[194,255]]);route([[45,314],[194,314]]);route([[45,398],[194,398]]);
route([[45,255],[45,398]]);route([[194,255],[194,398]]);route([[60,291],[194,291]]);
// Arrival is a natural open park; the terminal stands beside its 21x21 lawn.
hall('Arrival park terminal',72,345,85,371,{roofType:roof+'/Blue',material:floor+'/Sidewalk'});
hall('Regional transit office',115,355,124,374,{roofType:roof+'/Blue'});
prop(75,366,furn+'/Bench');prop(81,350,furn+'/Bench');directory(76,349,'Arrival park routes','Welcome to the western city. Hospital south; residential streets north; civic center southeast. The open lawn east is reserved for planetary arrivals.');
point('Human arrival park',95,362);
// Health, education and housing within short walks of the arrival park.
hall('West city hospital',69,321,91,341,{roofType:roof+'/Blue',material:floor+'/Clinic',doors:5});
for(const x of [73,87])for(const y of [325,337])prop(x,y,furn);
prop(74,330,furn+'/Files');directory(88,333,'Hospital directory','Public wards north and south. Reception is through the open central corridor. Arrival park north; pharmacy across the road.');
hall('Neighborhood pharmacy',108,322,121,339,{material:floor+'/Clinic'});for(const y of [326,335])prop(111,y,furn+'/Shelf');
hall('Community school and dojo',158,321,181,340,{doors:5});for(const x of [161,177])for(const y of [325,336])prop(x,y,furn+'/Desk');
home('Garden house',65,379,84,393);home('Corner apartment',107,379,122,393);
home('West terrace home',64,301,82,310);home('East terrace home',104,301,121,310);
hall('Neighborhood supermarket',158,371,178,392);for(const x of [161,175])for(const y of [375,382,388])prop(x,y,furn+'/Shelf');
hall('School library',164,346,183,364);for(const x of [167,180])for(const y of [350,359])prop(x,y,furn+'/Bookcase');
// Old-town storefronts are smaller and less symmetrical than imperial halls.
hall('Old town cafe',53,273,70,286,{facadeType:facade+'/Brick'});prop(56,282,furn+'/Stove');prop(66,277,furn+'/Table');prop(65,281,furn+'/Chair');
hall('Bookshop',106,272,125,286,{facadeType:facade+'/Brick'});for(const x of [109,122])for(const y of [276,282])prop(x,y,furn+'/Bookcase');
// Civic center and a 30x30 clear public square on the east bank of the river.
rect(159,259,191,289,floor+'/Sidewalk');spec.combatSpaces.push({name:'West city civic square',bounds:[160,259,189,288],minimum:28});point('West city civic square',175,275);
hall('City hall',160,300,188,317,{roofType:roof+'/Dark',material:floor+'/Sidewalk',doors:5});
for(const x of [164,184])prop(x,313,furn+'/Desk');directory(164,304,'Civic district routes','Town hall and civic square. Hospital northwest; shops south; garage southwest. River crossings connect both banks.');
hall('Hardware shop',158,240,168,251,{facadeType:facade+'/Brick'});hall('Corner grocery',109,259,126,269,{facadeType:facade+'/Brick'});
for(const [x,y]of[[161,247],[165,243],[112,266],[123,262]])prop(x,y,furn+'/Shelf');
hall('Motor repair garage',104,231,126,250,{roofType:roof+'/Dark',material:floor+'/Grate',doors:5});for(const x of [108,122])prop(x,246,furn+'/Toolbox');
hall('Riverside workshop',104,211,123,226,{roofType:roof+'/Dark',material:floor+'/Grate'});for(const x of [107,120])prop(x,222,furn+'/Toolbox');
// Urban park keeps a completely clear 30x30 training lawn.
rect(63,230,92,259,'/turf/Grass13');spec.combatSpaces.push({name:'West city training lawn',bounds:[63,230,92,259],minimum:28});point('West city training lawn',77,245);
for(const [x,y]of[[60,230],[60,258],[95,230],[95,258],[158,258],[192,289]])prop(x,y,furn+'/Bench');
finish();
