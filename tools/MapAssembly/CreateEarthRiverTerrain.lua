-- Native terrain transitions from generated material swatches. Each corner
-- interpolates the same neighboring samples, so adjacent tile edges agree.
local materials=Image{fromFile=app.params["materials"]}
local count=515
local sprite=Sprite(512,math.ceil(count/16)*32,ColorMode.RGB)
local sheet=Image(sprite.width,sprite.height,ColorMode.RGB)
local pc=app.pixelColor
local function smooth(t) return t*t*(3-2*t) end
local function has(mask,bit) return math.floor(mask/2^bit)%2 end
local function sample(center,mask,x,y)
 if x==0 and y==0 then return center end
 local bits={['0,-1']=0,['1,0']=1,['0,1']=2,['-1,0']=3,['1,-1']=4,['1,1']=5,['-1,1']=6,['-1,-1']=7}
 return has(mask,bits[x..','..y])
end
local function put(index,x,y,value) sheet:drawPixel(index%16*32+x,math.floor(index/16)*32+y,value) end
for center=0,1 do for mask=0,255 do
 local index=center*256+mask
 for y=0,31 do for x=0,31 do
  local xx=(x-15.5)/32;local yy=(y-15.5)/32;local a=math.floor(xx);local b=math.floor(yy)
  local fx=smooth(xx-a);local fy=smooth(yy-b)
  local v=(sample(center,mask,a,b)*(1-fx)+sample(center,mask,a+1,b)*fx)*(1-fy)+(sample(center,mask,a,b+1)*(1-fx)+sample(center,mask,a+1,b+1)*fx)*fy
  local material=v>.55 and 0 or v>.39 and 2 or 1
  local value=materials:getPixel(material*32+x,y)
  if v>.55 and v<.72 then value=pc.rgba(math.min(255,pc.rgbaR(value)+13),math.min(255,pc.rgbaG(value)+20),math.min(255,pc.rgbaB(value)+11),255) end
  put(index,x,y,value)
 end end
end end
for y=0,31 do for x=0,31 do
 local rock=materials:getPixel(96+x,y)
 local fall=materials:getPixel(x,y)
 local streak=(x*11)%7<2 and 28 or 5
 if y<4 then streak=36 end
 if y>26 then streak=45 end
 put(512,x,y,pc.rgba(math.min(255,pc.rgbaR(fall)+streak),math.min(255,pc.rgbaG(fall)+streak),math.min(255,pc.rgbaB(fall)+streak),255))
 local shade=math.floor(y/8)%2==0 and 10 or -16
 put(513,x,y,pc.rgba(math.max(0,pc.rgbaR(rock)+shade),math.max(0,pc.rgbaG(rock)+shade),math.max(0,pc.rgbaB(rock)+shade),255))
 if y<6 then put(514,x,y,materials:getPixel(32+x,y))
 else local d=math.floor(y/8)*7;put(514,x,y,pc.rgba(math.max(0,pc.rgbaR(rock)-d),math.max(0,pc.rgbaG(rock)-d),math.max(0,pc.rgbaB(rock)-d),255)) end
end end
sprite:newCel(sprite.layers[1],1,sheet,Point(0,0))
sprite.gridBounds=Rectangle(0,0,32,32)
sprite:saveAs(app.params["native"])
