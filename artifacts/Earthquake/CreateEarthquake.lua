-- Run with Aseprite -b --script artifacts/Earthquake/CreateEarthquake.lua
-- Deterministic, layered earthquake animation; all pixels authored in Aseprite.
local out = 'artifacts/Earthquake/'
local W,H,N = 160,128,24
local sprite = Sprite(W,H,ColorMode.RGB)
sprite.layers[1].name = 'Ground fissures'
local layers = {sprite.layers[1]}
for _,name in ipairs({'Inward pressure','Stone fragments','Dust clouds'}) do
  local layer = sprite:newLayer(); layer.name=name; layers[#layers+1]=layer
end
local rgba = app.pixelColor.rgba
local colors = {
  rgba(40,30,35,255), rgba(77,51,45,255), rgba(117,76,53,255),
  rgba(161,108,68,255), rgba(202,151,94,255), rgba(235,195,132,255),
  rgba(255,229,172,255)
}
local function dot(im,x,y,c)
  x,y=math.floor(x+0.5),math.floor(y+0.5)
  if x>=0 and y>=0 and x<W and y<H then im:drawPixel(x,y,c) end
end
local function line(im,x,y,u,v,c,width)
  local steps=math.max(math.abs(u-x),math.abs(v-y),1)
  for i=0,math.ceil(steps) do
    local t=i/math.ceil(steps)
    for j=0,(width or 1)-1 do dot(im,x+(u-x)*t,y+(v-y)*t+j,c) end
  end
end
local function ellipse(im,x,y,rx,ry,c)
  for v=-math.ceil(ry),math.ceil(ry) do
    for u=-math.ceil(rx),math.ceil(rx) do
      if u*u/(rx*rx)+v*v/(ry*ry)<=1 then dot(im,x+u,y+v,c) end
    end
  end
end
local function clamp(x) return math.max(0,math.min(1,x)) end
local function hash(i) return (math.sin(i*127.1+311.7)*43758.5453)%1 end
local cx,cy=80,75
for f=1,N do
  if f>1 then sprite:newEmptyFrame() end
  sprite.frames[f].duration=0.05
  local ims={Image(W,H),Image(W,H),Image(W,H),Image(W,H)}
  local t=(f-1)/(N-1)
  -- Fissures appear rapidly, then break into short remnants.
  if f>1 and f<22 then
    local reveal=clamp((f-1)/5)
    for k=1,13 do
      local angle=k*math.pi*2/13+hash(k)*0.25
      local prevx,prevy=cx+math.cos(angle)*9,cy+math.sin(angle)*5
      for seg=1,6 do
        local r=(9+seg*9)*reveal
        local a=angle+(hash(k*31+seg)-0.5)*0.19
        local x,y=cx+math.cos(a)*r,cy+math.sin(a)*r*0.48
        if f<16 or hash(k*23+seg)>(f-16)/6 then
          line(ims[1],prevx,prevy,x,y,colors[1],2)
          line(ims[1],prevx,prevy-1,x,y-1,colors[f<7 and 6 or 4],1)
          if seg==4 then
            line(ims[1],x,y,x+math.cos(a+0.6)*10,y+math.sin(a+0.6)*5,colors[2],1)
          end
        end
        prevx,prevy=x,y
      end
    end
  end
  -- Broken elliptical shock front contracts toward the caster.
  if f>=3 and f<=16 then
    local p=(f-3)/13
    local r=69*(1-p)^0.7+3
    for j=0,239 do
      local a=j*math.pi*2/240
      if math.sin(a*11+p*8)>-0.3 then
        local rr=r+math.sin(a*17)*1.1
        dot(ims[2],cx+math.cos(a)*rr,cy+math.sin(a)*rr*0.48,colors[5])
        dot(ims[2],cx+math.cos(a)*rr,cy+math.sin(a)*rr*0.48-1,colors[7])
      end
    end
  end
  -- Faceted airborne debris tracks the inward pull.
  if f>=4 and f<=21 then
    local p=(f-4)/17
    for k=1,23 do
      local a=k*2.39996
      local r=(29+hash(k)*38)*(1-p*0.7)
      local lift=math.sin(p*math.pi)*(9+hash(k+20)*15)
      local x,y=cx+math.cos(a)*r,cy+math.sin(a)*r*0.48-lift
      local size=(2+hash(k+80)*3)*(1-clamp((p-0.65)/0.4))
      if size>0.8 then
        ellipse(ims[3],x,cy+math.sin(a)*r*0.48,size+1,1,colors[1])
        for v=-math.ceil(size),math.ceil(size) do
          for u=-math.ceil(size),math.ceil(size) do
            if math.abs(u)*0.8+math.abs(v)<=size then
              local c=colors[2]
              if v<-0.3*size then c=colors[6]
              elseif u<0 then c=colors[4]
              else c=colors[3] end
              dot(ims[3],x+u,y+v,c)
            end
          end
        end
      end
    end
  end
  -- Discrete dust lobes: dark underside, ochre body, pale sunlit cap.
  if f>=4 and f<=23 then
    local p=(f-4)/19
    for k=1,25 do
      local a=k*math.pi*2/25+hash(k)*0.15
      local r=(57+hash(k+10)*9)*(1-clamp(p/0.75)*0.78)
      local x=cx+math.cos(a)*r
      local y=cy+math.sin(a)*r*0.48-6*math.sin(p*math.pi)
      local scale=math.sin(math.pi*clamp(p*1.12))
      local size=(3+hash(k+51)*4)*scale
      if size>0.5 then
        for l=1,3 do
          local xx=x+(l-2)*size*0.7
          local yy=y-(l%2)*size*0.4
          local rr=size*(0.65+hash(k*10+l)*0.4)
          ellipse(ims[4],xx,yy+1,rr+1,rr*0.66,colors[2])
          ellipse(ims[4],xx,yy,rr,rr*0.72,colors[4])
          ellipse(ims[4],xx-0.6,yy-rr*0.28,rr*0.82,rr*0.42,colors[5])
          if k%3~=0 then ellipse(ims[4],xx-1,yy-rr*0.45,rr*0.43,rr*0.19,colors[6]) end
        end
      end
    end
  end
  for i,im in ipairs(ims) do sprite:newCel(layers[i],f,im,Point(0,0)) end
end
sprite:saveAs(out..'Earthquake.aseprite')
sprite:saveCopyAs(out..'Earthquake.gif')
local sheet=Image(W*6,H*4)
for f=1,N do
  local im=Image(W,H); im:drawSprite(sprite,f)
  sheet:drawImage(im,Point(((f-1)%6)*W,math.floor((f-1)/6)*H))
end
sheet:saveAs(out..'EarthquakeSheet.png')
-- Comfortable large preview with an intentional dark ground, nearest-neighbor.
local preview=Sprite(W,H,ColorMode.RGB)
for f=1,N+10 do
  if f>1 then preview:newEmptyFrame() end
  preview.frames[f].duration=0.05
  local im=Image(W,H)
  im:clear(rgba(29,35,35,255))
  for y=0,H-1 do for x=0,W-1 do
    if hash(x+y*W)>0.975 then dot(im,x,y,rgba(38,44,41,255)) end
  end end
  if f<=N then im:drawSprite(sprite,f) end
  preview:newCel(preview.layers[1],f,im,Point(0,0))
end
app.activeSprite=preview
app.command.SpriteSize{ui=false,width=W*4,height=H*4,method='nearest-neighbor'}
preview:saveCopyAs(out..'EarthquakePreview.gif')
print('Earthquake: 24 frames, 160x128, 50ms/frame, four editable layers.')
