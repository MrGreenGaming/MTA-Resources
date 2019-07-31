Resource: Custom Coronas v1.2.0
contact: knoblauch700@o2.pl

This resource lets You create some coronas. Not just your typical gtasa coronas 
that often times fail to appear. Since in this case corona Elements are created using
dxDrawMaterialLine3d MTA function. I have changed the behaviour of the material 
to act as cylindrical billboards do.

exported functions are explained in the mta wiki:
https://wiki.multitheftauto.com/wiki/Resource:Custom_coronas

createCorona(posX,posY,posZ,size,colorR,colorG,colorB,colorA, [isSoft = false])
	Creates a Corona.
createMaterialCorona(material,posX,posY,posZ,size,colorR,colorG,colorB,colorA, [isSoft = false])
	Creates a Corona wit a custom texture.
destroyCorona(corona Element)
	Destroys the corona element.
setCoronaPosition(corona Element,posX,posY,posZ)
	Position of the corona in world space.
setCoronaSize(corona Element,size)
	Size of the corona.
setCoronaSizeXY(corona Element,sizeX,sizeY)
	Size of the corona.
setCoronaDepthBias(corona Element,depthBiasValue)
	On createCorona the depthBias is set properly (0-1). You can however set other value
	depending on your needs. To see the results you'll need to set enableDepthBiasScale
	to true. 
setCoronaColor(corona Element,colorR,colorG,colorB,colorA)
	RGBA diffuse color emitted by the corona. 
setCoronasDistFade(MaxEffectFade,MinEffectFade)
	Set the distance in which the corona starts to fade.
enableDepthBiasScale(isEnabled)
	Standard depthBias for GTASA coronas is ab. 1 unit, despise the corona scale. This function
	elables depthBias scaling.