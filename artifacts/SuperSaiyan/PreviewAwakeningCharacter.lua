-- Layout/timing preview with real BYOND-exported body and hair. Not a game capture.
local function loadFrame(path)
 local s=app.open(path)
 app.activeSprite=s
 app.command.ChangePixelFormat{format='rgb'}
 local im=Image(32,32,ColorMode.RGB)
 im:drawSprite(s,1)
 s:close()
 return im
end
local body=loadFrame('artifacts/SuperSaiyan/SsjPreviewBody.png')
local base=loadFrame('artifacts/SuperSaiyan/SsjPreviewBaseHair.png')
local gold=loadFrame('artifacts/SuperSaiyan/SsjPreviewGoldHair.png')
local aura=app.open('artifacts/SuperSaiyan/GoldenAura.aseprite')
local strikes=app.open('artifacts/SuperSaiyan/FallingLightning.aseprite')
local W,H=256,256
local preview=Sprite(W,H,ColorMode.RGB)
local left,right,bottom=body.width,0,0
for y=0,body.height-1 do for x=0,body.width-1 do if app.pixelColor.rgbaA(body:getPixel(x,y))>0 then left=math.min(left,x);right=math.max(right,x);bottom=math.max(bottom,y) end end end
local cx=(left+right)/2
local shocks={35,65,90,112,130,146,160,172,182,190,196,203}
for f=0,219 do
 if f>0 then preview:newEmptyFrame() end
 preview.frames[f+1].duration=0.1
 local power=math.min(1,f/190)
 local mix=f<25 and 0 or (1+math.sin(math.rad((f-25)*(6+power*11))))/2
 if f>=185 then mix=1 end
 local lift=power*7+math.sin(math.rad(f*6))*power
 if f>=205 then lift=lift*(220-f)/15 end
 local feet=208-math.floor(lift)
 local im=Image(W,H)
 local ambient=1-power*0.72
 for y=0,H-1 do for x=0,W-1 do
  local grid=(x%32==0 or y%32==0) and 7 or 0
  local glow=math.max(0,1-math.sqrt((x-128)^2+(y-195)^2)/110)*power
  im:drawPixel(x,y,app.pixelColor.rgba(math.floor((30+grid)*ambient+glow*45),math.floor((36+grid)*ambient+glow*28),math.floor((44+grid)*ambient),255))
 end end
 local au=Image(96,128);au:drawSprite(aura,(f*2)%24+1)
 local scale=0.3+power*0.7
 au:resize(math.floor(96*scale),math.floor(128*scale))
 local a=f<25 and f or 55+power*160+mix*30
 if f>=205 then a=230*(220-f)/15 end
 im:drawImage(au,Point(128-math.floor(48*scale),feet-math.floor(116*scale)),math.floor(a),BlendMode.NORMAL)
 for _,time in ipairs(shocks) do
  local age=f-time
  if age>=0 and age<9 then
   local rx=10+age*(8+power*6);local ry=rx*0.4
   for x=0,W-1 do for y=0,H-1 do
    local d=((x-128)/rx)^2+((y-208)/ry)^2
    if math.abs(d-1)<0.08 then im:drawPixel(x,y,app.pixelColor.rgba(170,145,85,255)) end
   end end
  end
 end
 local bx=math.floor(128-cx);local by=feet-bottom
 im:drawImage(body,Point(bx,by),255,BlendMode.NORMAL)
 im:drawImage(base,Point(bx,by),math.floor(255*(1-mix)),BlendMode.NORMAL)
 im:drawImage(gold,Point(bx,by),math.floor(255*mix),BlendMode.NORMAL)
 im:drawImage(gold,Point(bx,by),math.floor(180*mix*mix),BlendMode.ADDITION)
 if f>=35 and f<207 and f%14<3 then
  local bolt=Image(32,192);bolt:drawSprite(strikes,math.floor(f/14)%4*6+(f%14)*2+1)
  im:drawImage(bolt,Point(128+(math.floor(f/14)%2==0 and -38 or 38)-16,20),255,BlendMode.NORMAL)
 end
 preview:newCel(preview.layers[1],f+1,im,Point(0,0))
 if f==170 then im:saveAs('artifacts/SuperSaiyan/AwakeningCharacterPreview.png') end
end
preview:saveAs('artifacts/SuperSaiyan/AwakeningCharacterPreview.gif')
