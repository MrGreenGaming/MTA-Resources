local screenX, screenY = guiGetScreenSize()

local this_server = nil
local other_server = nil
local players_race = 0
local players_mix = 0

local img_Background = guiCreateStaticImage(0, 0, 1920, 1080, "images/background.png", false)
guiSetVisible(img_Background, false)


local img_ButtonRace = guiCreateStaticImage(0.25*screenX, 0.4*screenY, 400*screenX/1920, 225*screenX/1920, "images/race.png", false, img_Background)
local img_ButtonMix = guiCreateStaticImage(0.543*screenX, 0.4*screenY, 400*screenX/1920, 225*screenX/1920, "images/mix.png", false, img_Background)
local img_ButtonRaceSelected = guiCreateStaticImage(0.25*screenX, 0.4*screenY, 400*screenX/1920, 225*screenX/1920, "images/selected.png", false, img_Background)
local img_ButtonMixSelected = guiCreateStaticImage(0.543*screenX, 0.4*screenY, 400*screenX/1920, 225*screenX/1920, "images/selected.png", false, img_Background)
guiSetVisible(img_ButtonRaceSelected, false)
guiSetVisible(img_ButtonMixSelected, false)


local label_ChooseServer_font = guiCreateFont("fonts/arial.ttf", math.floor(30*screenY/1080))
local label_ChooseServer_posY = 0.80
local label_ChooseServer = guiCreateLabel(0, label_ChooseServer_posY*screenY, screenX, label_ChooseServer_posY*screenY, "Select the server where you want to play", false, img_Background)
guiLabelSetHorizontalAlign(label_ChooseServer, "center")
guiSetFont(label_ChooseServer, label_ChooseServer_font)


local label_TotalOnline_font = guiCreateFont("fonts/arial.ttf", math.floor(20*screenY/1080))
local label_TotalOnline_posY = 0.96
local label_TotalOnline = guiCreateLabel(0, label_TotalOnline_posY*screenY, screenX, label_TotalOnline_posY*screenY, "Total players online: ", false, img_Background)
guiLabelSetHorizontalAlign(label_TotalOnline, "center")
guiSetFont(label_TotalOnline, label_TotalOnline_font)

local label_YouAreHere_font = guiCreateFont("fonts/arial.ttf", math.floor(15*screenY/1080))
local label_YouAreHere = guiCreateLabel(0, 0, 400*screenX/1920, 25*screenX/1920, "You are here", false, img_Background)
guiLabelSetHorizontalAlign(label_YouAreHere, "center")
guiSetFont(label_YouAreHere, label_YouAreHere_font)
guiSetVisible(label_YouAreHere, false)

local label_RaceOnline_font = guiCreateFont("fonts/arial.ttf", math.floor(17*screenY/1080))
local label_RaceOnline = guiCreateLabel(0.245*screenX, 0.408*screenY, 400*screenX/1920, 35*screenX/1920, "-/-", false, img_Background)
guiLabelSetHorizontalAlign(label_RaceOnline, "right")
guiSetFont(label_RaceOnline, label_RaceOnline_font)

local label_MixOnline_font = guiCreateFont("fonts/arial.ttf", math.floor(17*screenY/1080))
local label_MixOnline = guiCreateLabel(0.538*screenX, 0.408*screenY, 400*screenX/1920, 35*screenX/1920, "-/-", false, img_Background)
guiLabelSetHorizontalAlign(label_MixOnline, "right")
guiSetFont(label_MixOnline, label_MixOnline_font)



local b_isMenuOpened = false
local var_guiDrawSpeed = 200 --ms
local var_timesToExecute = var_guiDrawSpeed/50


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

addEventHandler("onClientMouseMove", root,
    function()
        if source == img_ButtonRace or source == img_ButtonRaceSelected then
			guiSetVisible(img_ButtonRaceSelected, true)
		elseif source == img_ButtonMix or source == img_ButtonMixSelected then
			guiSetVisible(img_ButtonMixSelected, true)
		else
			guiSetVisible(img_ButtonRaceSelected, false)
			guiSetVisible(img_ButtonMixSelected, false)
        end
    end
)

addEventHandler("onClientGUIClick", img_ButtonRaceSelected, 
function()
	if source ~= img_ButtonRaceSelected then return end
	
	if this_server ~= "Race" then
		playSoundFrontEnd(1)
		triggerServerEvent('onRequestRedirect', localPlayer)
	else
		playSoundFrontEnd(4)
	end
end
)

addEventHandler("onClientGUIClick", img_ButtonMixSelected, 
function()
	if source ~= img_ButtonMixSelected then return end
	
	if this_server ~= "Mix" then
		playSoundFrontEnd(1)
		triggerServerEvent('onRequestRedirect', localPlayer)
	else
		playSoundFrontEnd(4)
	end
end
)

addEventHandler("onClientResourceStart", resourceRoot, 
function()
	triggerServerEvent("getServersInfo", localPlayer)
	
	setTimer(function()
				guiSetText(label_RaceOnline, getElementData(resourceRoot, "Race Players"))
				guiSetText(label_MixOnline, getElementData(resourceRoot, "Mix Players"))
				guiSetText(label_TotalOnline, "Total players online: "..getElementData(resourceRoot, "Total players online"))
			end,
	1100, 1)
end
)


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