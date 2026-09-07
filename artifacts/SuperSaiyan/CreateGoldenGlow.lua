-- Visible SSJ halo: true alpha falloff, unlike the opaque lighting-plane mask.
local s=Sprite(256,256,ColorMode.RGB)
s.layers[1].name='Soft golden halo'
local im=Image(256,256,ColorMode.RGB)
for y=0,255 do for x=0,255 do
 local r=math.sqrt((x-127.5)^2+(y-127.5)^2)/120
 local a=math.floor(230*math.max(0,1-r*r)^3)
 im:drawPixel(x,y,app.pixelColor.rgba(255,210,80,a))
end end
s:newCel(s.layers[1],1,im,Point(0,0))
s:saveAs('artifacts/SuperSaiyan/GoldenGlow.aseprite')
im:saveAs('src/Icons/Ki/GoldenGlow.png')
