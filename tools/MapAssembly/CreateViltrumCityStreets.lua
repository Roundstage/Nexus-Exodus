-- Extension of the native 32px street-kit workflow; no bitmap illustration.
local names={"road","lane_h","lane_v","cross_h","cross_v","pavement","garden","plaza","curb_n","curb_s","curb_e","curb_w","threshold","exit","quay_0"}
for i=1,15 do table.insert(names,"quay_"..i) end
local sprite=Sprite(#names*32,32,ColorMode.RGB)
local image=Image(#names*32,32,ColorMode.RGB)
local rgba=app.pixelColor.rgba
for i,name in ipairs(names) do
 local ox=(i-1)*32
 local function dot(x,y,r,g,b,a) image:drawPixel(ox+x,y,rgba(r,g,b,a or 255)) end
 local function rect(a,b,c,d,r,g,bl) for y=b,d do for x=a,c do dot(x,y,r,g,bl) end end end
 if name~="threshold" and name~="exit" then
  for y=0,31 do for x=0,31 do
   local n=((x*17+y*29+x*y*3)%5)-2
   if name=="garden" then dot(x,y,53+n,87+n,72+n)
   elseif i<=5 then dot(x,y,42+n,54+n,63+n)
   elseif name=="plaza" then
    local s=(x==0 or y==0) and -10 or 0;dot(x,y,161+n+s,174+n+s,175+n+s)
   else
    local s=(x%16==0 or y%16==0) and -8 or 0;dot(x,y,123+n+s,141+n+s,146+n+s)
   end
  end end
 end
 if name=="lane_h" then rect(3,15,24,16,128,174,177) end
 if name=="lane_v" then rect(15,3,16,24,128,174,177) end
 if name=="cross_h" then for y=2,26,8 do rect(4,y,27,y+3,174,192,190) end end
 if name=="cross_v" then for x=2,26,8 do rect(x,4,x+3,27,174,192,190) end end
 local n=name=="curb_n";local s=name=="curb_s";local e=name=="curb_e";local w=name=="curb_w"
 local mask=tonumber(string.match(name,"quay_(%d+)"))
 if mask then n=(mask & 1)~=0;e=(mask & 2)~=0;s=(mask & 4)~=0;w=(mask & 8)~=0 end
 if n then rect(0,0,31,2,192,204,200);rect(0,3,31,4,76,101,111) end
 if s then rect(0,27,31,28,76,101,111);rect(0,29,31,31,192,204,200) end
 if e then rect(27,0,28,31,76,101,111);rect(29,0,31,31,192,204,200) end
 if w then rect(0,0,2,31,192,204,200);rect(3,0,4,31,76,101,111) end
 if name=="threshold" or name=="exit" then
  rect(3,2,28,10,45,70,83);rect(5,3,26,4,102,179,180)
  if name=="exit" then rect(14,5,17,9,178,213,204);rect(11,7,20,8,178,213,204) end
 end
end
sprite:newCel(sprite.layers[1],1,image,Point(0,0))
sprite.gridBounds=Rectangle(0,0,32,32)
sprite:saveAs(app.params["native"])
local file=io.open(app.params["states"],"w")
file:write("[\""..table.concat(names,"\",\"").."\"]\n");file:close()
