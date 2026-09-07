-- Native, editable additions to the established 32-pixel Earth street kit.
-- API: https://www.aseprite.org/api/sprite and /api/image
local names = {"asphalt","lane_h","lane_v","cross_h","cross_v","sidewalk","curb_n","curb_s","curb_e","curb_w","lawn","garden_path","doorstep","exit_mat","hedge","fence","bin","flowers","bridge_n","bridge_s","bridge_e","bridge_w"}
local sprite = Sprite(#names*32,32,ColorMode.RGB)
local image = Image(#names*32,32,ColorMode.RGB)
local color = app.pixelColor.rgba
for index,name in ipairs(names) do
  local offset=(index-1)*32
  local function dot(x,y,r,g,b) image:drawPixel(offset+x,y,color(r,g,b,255)) end
  local function rect(a,b,c,d,r,g,bl) for y=b,d do for x=a,c do dot(x,y,r,g,bl) end end end
  if index<=12 or index>=19 then
    for y=0,31 do for x=0,31 do
      local n=((x*17+y*29+x*y*3)%7)-3
      if name=="lawn" then dot(x,y,74+n,103+n,60+n)
      elseif index>=6 and index<=10 or name=="garden_path" then
        local seam=(x%16==0 or y%16==0) and -14 or 0
        dot(x,y,159+n+seam,154+n+seam,139+n+seam)
      else dot(x,y,51+n,55+n,57+n) end
    end end
  end
  if name=="lane_h" then rect(1,14,22,15,211,191,113);rect(1,18,22,19,211,191,113) end
  if name=="lane_v" then rect(14,1,15,22,211,191,113);rect(18,1,19,22,211,191,113) end
  if name=="cross_h" then for y=2,26,8 do rect(2,y,29,y+3,213,208,186) end end
  if name=="cross_v" then for x=2,26,8 do rect(x,2,x+3,29,213,208,186) end end
  if name=="curb_n" then rect(0,0,31,2,195,190,173);rect(0,3,31,4,111,111,103) end
  if name=="curb_s" then rect(0,27,31,28,111,111,103);rect(0,29,31,31,195,190,173) end
  if name=="curb_e" then rect(27,0,28,31,111,111,103);rect(29,0,31,31,195,190,173) end
  if name=="curb_w" then rect(0,0,2,31,195,190,173);rect(3,0,4,31,111,111,103) end
  if name=="doorstep" or name=="exit_mat" then
    rect(2,2,29,13,91,84,69);rect(3,3,28,11,166,153,124)
    if name=="exit_mat" then rect(14,4,17,10,71,104,90);rect(11,7,20,8,71,104,90) end
  end
  if name=="hedge" then
    rect(0,13,31,28,38,62,37)
    for y=9,25 do for x=0,31 do local n=(x*19+y*11)%17;dot(x,y,52+n,86+n,44+n) end end
    rect(0,9,31,10,91,126,61)
  end
  if name=="fence" then
    rect(0,12,31,14,107,89,65);rect(0,23,31,25,95,77,57)
    for x=2,28,8 do rect(x,6,x+3,29,168,148,111);rect(x,6,x,29,206,186,145) end
  end
  if name=="bin" then
    rect(9,11,23,28,37,48,49);rect(10,10,21,26,66,82,79);rect(7,8,24,11,88,100,89)
    rect(12,13,13,25,94,108,91);rect(17,13,18,25,42,59,56)
  end
  if name=="flowers" then
    for j=1,15 do local x=3+(j*11)%25;local y=7+(j*7)%20;rect(x,y,x+1,math.min(30,y+4),68,111,48);dot(x,y,209,159+(j%3)*20,105+(j%2)*60);dot(x+1,y+1,240,219,144) end
  end
  if index>=19 then
    local horizontal=name=="bridge_n" or name=="bridge_s"
    local side=(name=="bridge_s" or name=="bridge_e") and 27 or 2
    if horizontal then rect(0,side,31,side+3,171,177,169);rect(0,side+4,31,side+4,74,83,84);for x=2,26,8 do rect(x,side-1,x+1,side+4,209,212,194) end
    else rect(side,0,side+3,31,171,177,169);for y=2,26,8 do rect(side-1,y,side+4,y+1,209,212,194) end end
  end
end
sprite:newCel(sprite.layers[1],1,image,Point(0,0))
sprite.gridBounds=Rectangle(0,0,32,32)
sprite:saveAs(app.params["native"])
