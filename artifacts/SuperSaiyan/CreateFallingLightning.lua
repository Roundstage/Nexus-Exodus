-- Four falling strikes, 32x192, six frames. Ground anchor y=188.
local W,H=32,192
local s=Sprite(W,H,ColorMode.RGB)
local sheet=Image(W*6,H*4)
local function line(im,x,y,u,v,color,r)
 local n=math.max(math.abs(u-x),math.abs(v-y),1)
 for k=0,n do
  local a=math.floor(x+(u-x)*k/n);local b=math.floor(y+(v-y)*k/n)
  for dx=-r,r do for dy=-r,r do if a+dx>=0 and a+dx<W and b+dy>=0 and b+dy<H then im:drawPixel(a+dx,b+dy,color) end end end
 end
end
for f=0,23 do
 if f>0 then s:newEmptyFrame() end
 s.frames[f+1].duration=0.05
 local phase=f%6;local variant=math.floor(f/6)
 local im=Image(W,H)
 local reach=({62,126,188,188,188,188})[phase+1]
 local alpha=({190,235,255,225,110,0})[phase+1]
 for y=2,reach-12,12 do
  local x=16+math.floor(8*math.sin(y*0.78+variant*3))
  local u=16+math.floor(8*math.sin((y+12)*0.78+variant*3))
  line(im,x,y,u,y+12,app.pixelColor.rgba(255,185,42,math.floor(alpha*0.25)),2)
  line(im,x,y,u,y+12,app.pixelColor.rgba(255,247,198,alpha),0)
 end
 s:newCel(s.layers[1],f+1,im,Point(0,0))
 sheet:drawImage(im,Point(phase*W,variant*H))
end
s:saveAs('artifacts/SuperSaiyan/FallingLightning.aseprite')
sheet:saveAs('artifacts/SuperSaiyan/FallingLightningSheet.png')
