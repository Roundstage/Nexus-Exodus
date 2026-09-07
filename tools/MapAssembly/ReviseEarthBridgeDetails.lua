-- Edit only the four bridge edge states in the existing native street source.
local sprite=Sprite{fromFile=app.params['native']}
local original=sprite.cels[1].image
local image=Image(original)
local pc=app.pixelColor
for index=18,21 do
 local horizontal=index<20
 local far=index==19 or index==20
 for y=0,31 do for x=0,31 do
  -- Walking pavement continues up to the concrete parapet, without a black band.
  local value=original:getPixel(5*32+x,y)
  local depth=horizontal and (far and 31-y or y) or (far and 31-x or x)
  local along=horizontal and x or y
  if depth<11 then
   local shade=depth<2 and 192 or depth<5 and 161 or depth<9 and 115 or 74
   if along%16<3 then shade=math.min(220,shade+19) end
   value=pc.rgba(shade,shade+3,math.max(0,shade-4),255)
  end
  image:drawPixel(index*32+x,y,value)
 end end
end
sprite.cels[1].image=image
sprite:saveAs(app.params['native'])
