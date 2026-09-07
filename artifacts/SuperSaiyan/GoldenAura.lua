-- Pixel Composer Lua Surface. 24 loop frames, 96x128, 8 columns.
local W,H,N,C=96,128,24,8
for f=0,N-1 do
 local t=f/N*6.28318530718
 local ox=(f%C)*W
 local oy=math.floor(f/C)*H
 for y=0,H-1 do
  for x=0,W-1 do
   local h=(110-y)/94
   local dx=x-48
   local a=0
   local r,g,b=255,181,35
   if h>0 and h<1 then
    local width=29*math.sin(math.pi*h)^0.65
    local bend=2.4*math.sin(h*9-t)+1.2*math.sin(h*19+t*2)
    local ripple=2.3*math.sin(h*28-t*2)+1.4*math.sin(h*43-t*3)
    local edge=width+ripple*(h+0.2)
    local d=math.abs(dx-bend)
    local shell=math.abs(d-edge)
    if d<edge then a=0.075+0.065*h end
    if shell<5 then a=math.max(a,0.20*(1-shell/5)) end
    if shell<2 then a=0.8;r=255;g=207;b=63 end
    if shell<0.8 then a=0.96;r=255;g=246;b=162 end
    local inner=math.abs(d-edge*0.78-1.8*math.sin(h*24-t*2))
    if inner<0.8 and h>0.12 then a=0.67;r=255;g=230;b=113 end
    a=a*math.min(1,h*14,(1-h)*20)
   end
   for k=0,11 do
    local phase=(f/N+k/12)%1
    local py=108-phase*98
    local px=48+math.sin(k*8.31)*34+math.sin(phase*5+k)*3
    if math.abs(x-px)<0.8 and math.abs(y-py)<1.5 then
     a=math.max(a,0.9*math.sin(phase*math.pi));r=255;g=235;b=139
    end
   end
   setColorAlpha(colorCreateRGB(r,g,b),a)
   drawPixel(ox+x,oy+y)
  end
 end
end
