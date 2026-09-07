local source=app.open('artifacts/SuperSaiyan/GoldenAura.aseprite')
local preview=Sprite(96,128,ColorMode.RGB)
for f=1,24 do
 if f>1 then preview:newEmptyFrame() end
 preview.frames[f].duration=0.05
 local im=Image(96,128)
 for y=0,127 do for x=0,95 do im:drawPixel(x,y,app.pixelColor.rgba(22,25,35,255)) end end
 local fg=Image(96,128)
 fg:drawSprite(source,f)
 im:drawImage(fg,Point(0,0),255,BlendMode.NORMAL)
 preview:newCel(preview.layers[1],f,im,Point(0,0))
 if f==1 then im:saveAs('artifacts/SuperSaiyan/GoldenAuraPreview.png') end
end
preview:saveAs('artifacts/SuperSaiyan/GoldenAuraPreview.gif')
