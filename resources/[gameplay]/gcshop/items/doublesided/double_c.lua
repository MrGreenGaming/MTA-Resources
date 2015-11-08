local doublesided = false

function loadDoubleSided( bool, settings )
	if bool then
		if not settings.disabled then
			doublesided = true
			setEverythingDoubleSided()
		end
	else
		doublesided = false
	end
end
addEvent( 'loadDoubleSided', true )
addEventHandler( 'loadDoubleSided', localPlayer, loadDoubleSided)

function settingGCTrials ( settings )
	if not settings.disabled then
		doublesided = true
		setEverythingDoubleSided()
	else
		doublesided = false
	end
end
addEvent('settingGCTrials', true)
addEventHandler('settingGCTrials', localPlayer, settingGCTrials)

function setEverythingDoubleSided()
	if not doublesided then return end
	for k,object in ipairs(getElementsByType'object') do
		setElementDoubleSided(object, true)
	end
end
addEventHandler('onClientMapStarting', root, setEverythingDoubleSided)