-- Aseprite-authored energy shell, inspired by the supplied expanding-sphere reference.
local out='artifacts/ExplosiveWave/'
local W,N=160,20
local sprite=Sprite(W,W,ColorMode.RGB)
sprite.layers[1].name='Expanding energy sphere'
local rgba=app.pixelColor.rgba
for f=1,N do
  if f>1 then sprite:newEmptyFrame() end
  sprite.frames[f].duration=0.04
  local im=Image(W,W)
  local t=(f-1)/(N-1)
  local radius=6+66*math.min(1,t/0.63)^0.65
  local fade=math.min(1,(1-t)/0.32)
  for y=0,W-1 do for x=0,W-1 do
    local dx,dy=x-79.5,y-79.5
    local r=math.sqrt(dx*dx+dy*dy)
    local a=math.atan(dy,dx)
    local ripple=math.sin(a*13+f*0.6)*0.9+math.sin(a*23-f*0.4)*0.5
    local edge=radius+ ripple-r
    local red,green,blue,alpha=255,40,115,0
    if edge>=0 then
      local rim=math.max(0,1-edge/6)
      local core=math.max(0,1-r/radius)
      alpha=(38+155*rim+70*core)*fade
      green=60+170*rim+65*core
      blue=140+105*rim+70*core
      -- Curved bands give the shell volume while its center remains translucent.
      local band=math.abs(dy+radius*0.25-math.sin(dx/radius*1.5)*radius*0.22)
      if band<1.4 and r<radius*0.92 then alpha=140*fade; green=170; blue=225 end
    elseif edge>-5 then alpha=(1+edge/5)*65*fade end
    -- Short radial energy needles around the advancing front.
    local ray=math.abs(math.sin(a*11+0.25))
    if ray<0.025 and r>radius*0.82 and r<math.min(78,radius+7) then
      alpha=220*fade;green=210;blue=235
    end
    if f==N then alpha=0 end
    if alpha>0 then im:drawPixel(x,y,rgba(red,math.min(255,green),math.min(255,blue),math.floor(alpha))) end
  end end
  sprite:newCel(sprite.layers[1],f,im,Point(0,0))
end
sprite:saveAs(out..'ExplosiveWave.aseprite')
sprite:saveCopyAs(out..'ExplosiveWave.gif')
local sheet=Image(W*5,W*4)
for f=1,N do
 local im=Image(W,W);im:drawSprite(sprite,f)
 sheet:drawImage(im,Point(((f-1)%5)*W,math.floor((f-1)/5)*W))
end
sheet:saveAs(out..'ExplosiveWaveSheet.png')
print('Energy sphere: 160x160, 20 frames, 0.8 seconds')
