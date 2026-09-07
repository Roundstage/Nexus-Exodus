-- Native, editable 32px terrain pieces from original generated materials.
-- No stairs: slopes use continuous scree/sand; cliff faces are solid turfs.
local materials=Image{fromFile=app.params['materials']}
local pc=app.pixelColor
local names={}
local tiles={}
local function sample(cell,x,y) return materials:getPixel(cell%4*32+math.floor(x/2),math.floor(cell/4)*32+math.floor(y/2)) end
local function tint(c,n) return pc.rgba(math.max(0,math.min(255,pc.rgbaR(c)+n)),math.max(0,math.min(255,pc.rgbaG(c)+n)),math.max(0,math.min(255,pc.rgbaB(c)+n)),255) end
local function mix(a,b,w) return pc.rgba(math.floor(pc.rgbaR(a)*(1-w)+pc.rgbaR(b)*w),math.floor(pc.rgbaG(a)*(1-w)+pc.rgbaG(b)*w),math.floor(pc.rgbaB(a)*(1-w)+pc.rgbaB(b)*w),255) end
local function add(name,paint)
 local tile=Image(32,32,ColorMode.RGB)
 for y=0,31 do for x=0,31 do tile:drawPixel(x,y,paint(x,y)) end end
 names[#names+1]=name;tiles[#tiles+1]=tile
end
local biomes={{'sand',0,1,3},{'snow',4,5,7},{'forest',9,8,9}}
for _,b in ipairs(biomes) do
 for mask=0,15 do
  add(b[1]..'_top_'..mask,function(x,y)
   local c=mix(sample(b[2],x,y),sample(b[2],15,15),.6)
   local rim=(math.floor(mask/1)%2==1 and y<2) or (math.floor(mask/2)%2==1 and x>29) or (math.floor(mask/4)%2==1 and y>29) or (math.floor(mask/8)%2==1 and x<2)
   return rim and tint(c,15) or c
  end)
 end
 for row=0,1 do
  add(b[1]..'_face_'..row,function(x,y)
   local c=sample(b[3],x,y)
   if row==0 and y<3 then c=sample(b[2],x,y) end
   return tint(c,row==1 and 6+math.floor(y/8) or 20-math.floor(y/8))
  end)
 end
 for _,dir in ipairs({'n','e','s','w'}) do
  add(b[1]..'_ramp_'..dir,function(x,y)
   local slope=dir=='n' and 31-y or dir=='s' and y or dir=='e' and x or 31-x
   return tint(sample(b[4],x,y),math.floor(slope/4)-4)
  end)
 end
end
for name,cell in pairs({sand_ground=2,cave_floor=12,cave_roof=13,ice=6,waterfall=10,foam=11}) do add(name,function(x,y) return sample(cell,x,y) end) end
-- A range of slope illumination values lets adjacent dune cells carry one
-- continuous wind direction. The crest is sand, never a blocking rock wall.
for shade=-4,4 do add('dune_'..(shade+4),function(x,y) return tint(sample(15,x,y),shade*7) end) end
-- Six connected tiles form a natural arch. Only the opening is walkable.
for row=0,1 do for col=0,2 do
 add('cave_mouth_'..col..'_'..row,function(x,y)
  local xx=col*32+x-47.5;local yy=row*32+y
  local opening=yy>22 and math.abs(xx)<25 or (xx/25)^2+((yy-28)/25)^2<1
  if opening then return pc.rgba(24+math.floor(yy/12),20+math.floor(yy/14),18,255) end
  return sample(1,x,y)
 end)
end end
-- Fully tiled continuous dunes. Every edge fades into the existing desert
-- ground, and the steep leeward face shares the same wind direction.
local base=Image{fromFile=app.params['base']}
local duneSizes={{13,6},{14,6},{16,7}}
local function elevation(x,y)
 if math.abs(y)>=1 then return 0 end
 local u=x+.65*y*y-.15
 local width=u<0 and .85 or .28
 return math.max(0,1-math.abs(u)/width)*(1-y*y)
end
for index,size in ipairs(duneSizes) do
 local rx,ry=size[1],size[2]
 for yy=-ry-1,ry+1 do for xx=-rx-1,rx+1 do
  add('dune_patch_'..index..'_'..(xx+rx+1)..'_'..(yy+ry+1),function(x,y)
   local dx=(xx+(x+.5)/32-.5)/rx;local dy=(yy+(.5-(y+.5)/32))/ry
   local h=elevation(dx,dy);local c=base:getPixel(x,y)
   local slope=(elevation(dx+.012,dy)-elevation(dx-.012,dy))/.024
   local shade=math.max(-48,math.min(28,-slope*13))*math.min(1,h*12)
   return tint(mix(c,sample(2,x,y),math.min(.7,h*.7)),math.floor(shade))
  end)
 end end
end
local sprite=Sprite(512,math.ceil(#names/16)*32,ColorMode.RGB)
local sheet=Image(sprite.width,sprite.height,ColorMode.RGB)
for i,tile in ipairs(tiles) do sheet:drawImage(tile,Point((i-1)%16*32,math.floor((i-1)/16)*32)) end
sprite.cels[1].image=sheet
sprite:saveAs(app.params['native'])
local f=io.open(app.params['names'],'w');f:write(table.concat(names,'\n'));f:close()
