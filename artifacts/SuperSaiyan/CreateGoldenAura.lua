-- Golden flame aura, authored through Aseprite. Feet anchor: (48,116).
local W,H,N=96,128,24
local sprite=Sprite(W,H,ColorMode.RGB)
sprite.layers[1].name='Rising golden flames'
local sheet=Image(W*8,H*3)
for f=0,N-1 do
 if f>0 then sprite:newEmptyFrame() end
 sprite.frames[f+1].duration=0.05
 local im=Image(W,H)
 local t=2*math.pi*f/N
 for y=0,H-1 do for x=0,W-1 do
  local height=116-y
  local dx=x-48
  local alpha,r,g,b=0,255,174,22
  if height>=0 and height<110 then
   local v=height/110
   local width=(24+9*math.sin(v*math.pi))*(1-v)^0.48
   local edge=width+3*math.sin(v*31-t*2)+2*math.sin(v*57-t*3)
   local d=math.abs(dx-1.8*math.sin(v*12-t))
   if d<edge then
    local rim=(d/edge)^3
    alpha=math.floor(22+rim*100)
    g=math.floor(150+rim*60)
    if d>edge-3 then alpha=200;g=220;b=78 end
   end
   -- Separate tapered tongues travel upwards along both sides, leaving an open center.
   for k=0,9 do
    local p=(f/N+k/10)%1
    local cy=8+p*100
    local side=k%2==0 and -1 or 1
    local cx=side*(22*(1-p)^0.4+4*math.sin(k*3+p*8))
    local tail=(height-cy)/18
    local thickness=3.5*(1-math.abs(tail))
    if thickness>0 and math.abs(dx-cx-side*tail*4)<thickness then
     alpha=math.max(alpha,math.floor(230*math.sin(p*math.pi)))
     r=255;g=242;b=141
    end
   end
   alpha=math.floor(alpha*math.min(1,(height+1)/7,(110-height)/10))
  end
  im:drawPixel(x,y,app.pixelColor.rgba(r,g,b,alpha))
 end end
 sprite:newCel(sprite.layers[1],f+1,im,Point(0,0))
 sheet:drawImage(im,Point((f%8)*W,math.floor(f/8)*H))
end
sprite:saveAs('artifacts/SuperSaiyan/GoldenAura.aseprite')
sheet:saveAs('artifacts/SuperSaiyan/GoldenAuraSheet.png')
