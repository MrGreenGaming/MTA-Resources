local screenX, screenY = guiGetScreenSize()

local this_server = nil
local other_server = nil
local players_race = 0
local players_mix = 0


local b_isMenuOpened = false
local var_guiDrawSpeed = 200 --ms
local var_timesToExecute = var_guiDrawSpeed/50



addEventHandler("onClientResourceStart", resourceRoot, 
function()
	--Images
	img_Background = guiCreateStaticImage(0, 0, 1920*screenX/1920, 1080*screenY/1080, "images/background.png", false)
	guiSetVisible(img_Background, false)

	img_ButtonRace = guiCreateStaticImage(0.25*screenX, 0.4*screenY, 0.2083333333333333*screenX, 0.1171875*screenX, "images/race.png", false, img_Background)
	img_ButtonMix = guiCreateStaticImage(0.543*screenX, 0.4*screenY, 0.2083333333333333*screenX, 0.1171875*screenX, "images/mix.png", false, img_Background)
	img_ButtonRaceInfo = guiCreateStaticImage(0.2, 0.051, 0.06, 0.1066666666666667, "images/info.png", true, img_ButtonRace)
	img_ButtonMixInfo = guiCreateStaticImage(0.14, 0.051, 0.06, 0.1066666666666667, "images/info.png", true, img_ButtonMix)
	setTooltip(img_ButtonRaceInfo, "Racing as it should be. Old classic maps, brand new maps and fun maps mixed all together won't make you feel bored!")
	setTooltip(img_ButtonMixInfo, "Car madness with various gamemodes as Capture The Flag, Shooter, Reach The Flag, Never The Same and Never The Same DD.")

	--Labels
	label_RaceMix_font = exports.fonts:createCEGUIFont("Arial", math.floor(17*screenX/1920))

	label_Race = guiCreateLabel(0.025, 0.045, 0.155, 0.2, "RACE", true, img_ButtonRace)
	guiLabelSetHorizontalAlign(label_Race, "left")
	guiSetFont(label_Race, label_RaceMix_font)

	label_Mix = guiCreateLabel(0.025, 0.045, 0.145, 0.2, "MIX", true, img_ButtonMix)
	guiLabelSetHorizontalAlign(label_Mix, "left")
	guiSetFont(label_Mix, label_RaceMix_font)

	label_RaceOnline = guiCreateLabel(0.725, 0.045, 0.25, 0.2, "-/-", true, img_ButtonRace)
	guiLabelSetHorizontalAlign(label_RaceOnline, "right")
	guiSetFont(label_RaceOnline, label_RaceMix_font)

	label_MixOnline = guiCreateLabel(0.725, 0.045, 0.25, 0.2, "-/-", true, img_ButtonMix)
	guiLabelSetHorizontalAlign(label_MixOnline, "right")
	guiSetFont(label_MixOnline, label_RaceMix_font)

	label_ChooseServer_font = exports.fonts:createCEGUIFont("Arial", math.floor(30*screenX/1920))
	label_ChooseServer_posY = 0.80
	label_ChooseServer = guiCreateLabel(0, label_ChooseServer_posY*screenY, screenX, label_ChooseServer_posY*screenY, "Select the server where you want to play", false, img_Background)
	guiLabelSetHorizontalAlign(label_ChooseServer, "center")
	guiSetFont(label_ChooseServer, label_ChooseServer_font)


	label_TotalOnline_font = exports.fonts:createCEGUIFont("Arial", math.floor(20*screenX/1920))
	label_TotalOnline_posY = 0.96
	label_TotalOnline = guiCreateLabel(0, label_TotalOnline_posY*screenY, screenX, label_TotalOnline_posY*screenY, "Total players online: ", false, img_Background)
	guiLabelSetHorizontalAlign(label_TotalOnline, "center")
	guiSetFont(label_TotalOnline, label_TotalOnline_font)

	label_YouAreHere_font = exports.fonts:createCEGUIFont("Arial", math.floor(15*screenX/1920))
	label_YouAreHere = guiCreateLabel(0, 0, 0.2083333333333333*screenX, 25*screenX/1920, "You are here", false, img_Background)
	guiLabelSetHorizontalAlign(label_YouAreHere, "center")
	guiSetFont(label_YouAreHere, label_YouAreHere_font)
	guiSetVisible(label_YouAreHere, false)
	
	label_RaceMapInfo = guiCreateLabel(0.025, 0.76, 0.95, 0.2, "Map:\nAuthor:", true, img_ButtonRace)
	guiLabelSetHorizontalAlign(label_RaceMapInfo, "left")
	guiSetFont(label_RaceMapInfo, label_YouAreHere_font)

	label_MixMapInfo = guiCreateLabel(0.025, 0.76, 0.95, 0.2, "Map:\nAuthor:", true, img_ButtonMix)
	guiLabelSetHorizontalAlign(label_MixMapInfo, "left")
	guiSetFont(label_MixMapInfo, label_YouAreHere_font)

	
	setTimer(triggerServerEvent, 500, 1, "getServersInfo", localPlayer)
	setTimer(triggerServerEvent, 500, 1, "getServersMapInfo", localPlayer, "client")
	
	setTimer(function()		
				guiSetText(label_RaceOnline, getElementData(resourceRoot, "Race Players"))		
				guiSetText(label_MixOnline, getElementData(resourceRoot, "Mix Players"))		
				guiSetText(label_TotalOnline, "Total players online: "..getElementData(resourceRoot, "Total players online"))		
				end,		
	1100, 1)	
	
	local var_buttonZoom = 8
	local var_buttonZoom_a = 8/screenX
	local var_buttonZoom_s = var_buttonZoom/2
	local var_buttonZoom_sX = var_buttonZoom_s/screenX
	local var_buttonZoom_sY = var_buttonZoom_s/screenY

	
	--"Animation" for buttons
	addEventHandler("onClientMouseMove", root,
    function()
        if source == img_ButtonRace or source == img_ButtonRaceInfo or source == label_Race or source == label_RaceOnline or source == label_RaceMapInfo then
			guiSetSize(img_ButtonRace, (0.2083333333333333+var_buttonZoom_a)*screenX, (0.1171875+var_buttonZoom_a)*screenX, false)
			guiSetPosition(img_ButtonRace, (0.25-var_buttonZoom_sX)*screenX, (0.4-var_buttonZoom_sY)*screenY, false)
		elseif source == img_ButtonMix or source == img_ButtonMixInfo or source == label_Mix or source == label_MixOnline or source == label_MixMapInfo then
			guiSetSize(img_ButtonMix, (0.2083333333333333+var_buttonZoom_a)*screenX, (0.1171875+var_buttonZoom_a)*screenX, false)
			guiSetPosition(img_ButtonMix, (0.543-var_buttonZoom_sX)*screenX, (0.4-var_buttonZoom_sY)*screenY, false)
		else
			guiSetSize(img_ButtonRace, 0.2083333333333333*screenX, 0.1171875*screenX, false)
			guiSetSize(img_ButtonMix, 0.2083333333333333*screenX, 0.1171875*screenX, false)
			guiSetPosition(img_ButtonRace, 0.25*screenX, 0.4*screenY, false)
			guiSetPosition(img_ButtonMix, 0.543*screenX, 0.4*screenY, false)
        end
    end
	)

	
	--Button handlers
	addEventHandler("onClientGUIClick", img_ButtonRace, 
	function()
		if source ~= img_ButtonRace then return end
	
		if this_server ~= "Race" then
			playSoundFrontEnd(1)
			triggerServerEvent('onRequestRedirect', localPlayer)
		else
			playSoundFrontEnd(4)
			drawGUI()
		end
	end
	)

	addEventHandler("onClientGUIClick", img_ButtonMix, 
	function()
		if source ~= img_ButtonMix then return end
	
		if this_server ~= "Mix" then
			playSoundFrontEnd(1)
			triggerServerEvent('onRequestRedirect', localPlayer)
		else
			playSoundFrontEnd(4)
			drawGUI()
		end
	end
	)
end
)




function setTooltip(element, text)
    setElementData(element, "tooltip-text", text, false)
end




function drawGUI()
	if isTimer(timer_guiDrawAnimation) then killTimer(timer_guiDrawAnimation) end
	if isTimer(timer_guiDrawAnimation2) then killTimer(timer_guiDrawAnimation2) guiSetVisible(img_Background, false) end

	if not b_isMenuOpened then
		b_isMenuOpened = true

		showCursor(true)
		guiSetVisible(img_Background, true)
		guiBringToFront(img_Background)
		guiSetAlpha(img_Background, 0)
		timer_guiDrawAnimation = setTimer(function() local a = guiGetAlpha(img_Background) guiSetAlpha(img_Background, a+(1/var_timesToExecute)) end, 50, var_timesToExecute)
	elseif b_isMenuOpened then
		b_isMenuOpened = false

		showCursor(false)
		guiSetAlpha(img_Background, 1)
		timer_guiDrawAnimation = setTimer(function() local a = guiGetAlpha(img_Background) guiSetAlpha(img_Background, a-(1/var_timesToExecute)) end, 50, var_timesToExecute)
		timer_guiDrawAnimation2 = setTimer(guiSetVisible, var_guiDrawSpeed, 1, img_Background, false)
	end
end
bindKey('F2', 'down', drawGUI)



function receiveServersInfo(server1, server2)
	this_server = server1
	other_server = server2
	
	guiSetVisible(label_YouAreHere, true)
	
	if this_server == "Race" then
		guiSetPosition(label_YouAreHere, 0.25*screenX, (0.4*screenY)+(235*screenX/1920), false)
	elseif this_server == "Mix" then
		guiSetPosition(label_YouAreHere, 0.543*screenX, (0.4*screenY)+(235*screenX/1920), false)
	else
		guiSetVisible(label_YouAreHere, false)
	end
end
addEvent("receiveServersInfo", true)
addEventHandler("receiveServersInfo", root, receiveServersInfo)


addEventHandler ( "onClientElementDataChange", root,
function (dataName)
	if source == resourceRoot and dataName == "Race Players" then
		local players_race = getElementData(resourceRoot, dataName)
		guiSetText(label_RaceOnline, players_race)
	elseif source == resourceRoot and dataName == "Mix Players" then
		local players_mix = getElementData(resourceRoot, dataName)
		guiSetText(label_MixOnline, players_mix)
	elseif source == resourceRoot and dataName == "Total players online" then
		local players_total = getElementData(resourceRoot, dataName)
		guiSetText(label_TotalOnline, "Total players online: "..players_total)
	end
end
)

function updateF2GUI( dataName, data )
	--outputChatBox("dataName: "..dataName.."\n"..data)
	if dataName == "Race Map" then
		guiSetText(label_RaceMapInfo, data)
	elseif dataName == "Mix Map" then
		guiSetText(label_MixMapInfo, data)
	end
end
addEvent("updateF2GUI", true)
addEventHandler("updateF2GUI", root, updateF2GUI)