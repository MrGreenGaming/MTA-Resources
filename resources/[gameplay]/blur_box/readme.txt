Resource: Blur Box v1.0.1
contact: knoblauch700@o2.pl

This resource lets You create simple gaussian blur boxes onClientHUDRender.
Using that - You can make your game GUI a bit more fancy.

exported functions are explained in the mta wiki:
https://wiki.multitheftauto.com/wiki/Resource:Blur_box

example resource:
http://www.solidfiles.com/d/f45a107b42/blurBox_test.zip

createBlurBox(posX,posY,sizeX,sizeY,colorR,colorG,colorB,colorA,postGUI)
	Creates a BlurBox.
destroyBlurBox(BlurBox Element)
	Destroys the BlurBox element.
setBlurBoxEnabled(BlurBox Element,isEnabled)
	Enable/Disable the BlurBox element.
setBlurBoxPosition(BlurBox Element,int posX,posY,posZ)
	Position of the BlurBox in world space.
setBlurBoxSize(BlurBox Element,int sizeX,sizeY)
	Size of the BlurBox.
setBlurBoxColor(BlurBox Element,int colorR,colorG,colorB,colorA)
	RGBA diffuse color of the BlurBox.
setBlurIntensity(float blurFactor)
	Set blur amount for all the blur boxes. (default 0.6)
setScreenResolutionMultiplier(float x,y)
	Set sampled screen relative resolution multiplier (0-1)
