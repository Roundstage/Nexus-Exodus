-- Aseprite batch script. Four independent lightning bursts, six frames each.
local out='artifacts/SuperSaiyan/'
local W,H,N=32,64,24
local sprite=Sprite(W,H,ColorMode.RGB)
sprite.layers[1].name='Lightning core'
local halo=sprite:newLayer();halo.name='Golden corona'
local rgba=app.pixelColor.rgba
local function line(im,x,y,u,v,c,radius)
 local steps=math.max(math.abs(u-x),math.abs(v-y),1)
 for i=0,steps do
  local px=math.floor(x+(u-x)*i/steps+0.5)
  local py=math.floor(y+(v-y)*i/steps+0.5)
  for dx=-radius,radius do for dy=-radius,radius do
   if px+dx>=0 and px+dx<W and py+dy>=0 and py+dy<H then im:drawPixel(px+dx,py+dy,c) end
  end end
 end
end
for f=1,N do
 if f>1 then sprite:newEmptyFrame() end
 sprite.frames[f].duration=0.05
 local variant=math.floor((f-1)/6)
 local phase=(f-1)%6
 local core=Image(W,H);local glow=Image(W,H)
 local alpha=({255,170,245,145,70,0})[phase+1]
 local points={}
 for k=0,7 do
  local x=16+math.floor(8*math.sin(k*13.7+variant*4.1+math.floor(phase/2)*0.8))
  points[#points+1]={x,4+k*8}
 end
 for k=1,#points-1 do
  local a,b=points[k],points[k+1]
  line(glow,a[1],a[2],b[1],b[2],rgba(255,191,54,math.floor(alpha*0.22)),2)
  line(core,a[1],a[2],b[1],b[2],rgba(255,246,194,alpha),0)
  if k==3 or k==5 then
   local bx=math.max(2,math.min(29,a[1]+(k==3 and 10 or -10)))
   line(glow,a[1],a[2],bx,a[2]+8,rgba(255,190,50,math.floor(alpha*0.18)),1)
   line(core,a[1],a[2],bx,a[2]+8,rgba(255,225,123,math.floor(alpha*0.75)),0)
  end
 end
 sprite:newCel(sprite.layers[1],f,core,Point(0,0))
 sprite:newCel(halo,f,glow,Point(0,0))
end
sprite:saveAs(out..'TransformationLightning.aseprite')
local sheet=Image(W*6,H*4)
for f=1,N do
 local im=Image(W,H);im:drawSprite(sprite,f)
 sheet:drawImage(im,Point(((f-1)%6)*W,math.floor((f-1)/6)*H))
end
sheet:saveAs(out..'TransformationLightningSheet.png')

sprite:saveCopyAs(out..'TransformationLightning.gif')
