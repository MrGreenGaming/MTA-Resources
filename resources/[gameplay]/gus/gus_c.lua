
-- MrGreen banner --

function banner()
	dxDrawImage(3, y-48-5, 320, 40, 'text.png', 0, 0, 0, tocolor(255, 255, 255), true)
end
addEventHandler("onClientRender", root, banner )

local fCam = false
function freecam()
    if getResourceFromName('freecam') and exports.freecam then
        fCam = not fCam
        if fCam then
            outputChatBox("[FREECAM] Free camera movement is now enabled", 0, 255, 0)
            exports.freecam:setFreecamEnabled()
			local veh = getPedOccupiedVehicle(localPlayer)
			if veh then
				setElementFrozen(veh, true)
			end
        else
            outputChatBox("[FREECAM] Free camera movement is now disabled", 0, 255, 0)
			setElementHealth(localPlayer,0)
            exports.freecam:setFreecamDisabled()
            if getElementData(localPlayer, 'state') == 'alive' then
                setCameraTarget(localPlayer)
            else
                local players = getElementsByType('player')
                local rnd = nil
                for _, player in ipairs(players) do
                    if getElementData(player, 'state') == 'alive' then
                        rnd = player
                        break
                    end
                end
                if rnd then
                    setCameraTarget(rnd)
                end
            end
        end
    end
end
addEvent('freecam', true)
addEventHandler('freecam', resourceRoot, freecam)

-- /fpslimit <limit>
function clientFPSLimit(cmd, limit_)
	triggerEvent("gus_c_fpslimit", root, limit_)
end
addCommandHandler ( 'fpslimit', clientFPSLimit)

addCommandHandler('votekut', function() playSound(":gcshop/horns/files/38.mp3", false) end)

addEventHandler("onClientResourceStart",resourceRoot,
	function()
		if not fileExists("@settings.xml") then
			return
		end
		local settings = xmlLoadFile ("@settings.xml")
		local UsernameNode = xmlFindChild(settings,"Username",0)
		local PasswordNode = xmlFindChild(settings,"Password",0)
		local pass = xmlNodeGetValue(PasswordNode)
		local user = xmlNodeGetValue(UsernameNode)
		triggerServerEvent("autologin",localPlayer,user,pass)
	end
)

addCommandHandler("autologin",
	function(command,username,password)
		if not username or not password then
			if fileExists("@settings.xml") then
				fileDelete("@settings.xml")
			end
			outputChatBox('/autologin: removed', 255,0,0)
			return
		end
		local settings, UsernameNode, PasswordNode
		if not fileExists("@settings.xml") then
			settings = xmlCreateFile("@settings.xml","AutoLogin")
			UsernameNode = xmlCreateChild(settings,"Username")
			PasswordNode = xmlCreateChild(settings,"Password")
		else
			settings = xmlLoadFile ("@settings.xml")
			UsernameNode = xmlFindChild(settings,"Username",0)
			PasswordNode = xmlFindChild(settings,"Password",0)
		end
		xmlNodeSetValue(UsernameNode,username)
		xmlNodeSetValue(PasswordNode,password)
		xmlSaveFile(settings)
		xmlUnloadFile(settings)
		outputChatBox('/autologin: added for ' .. username .. ' ' .. password, 255,0,0)
	end
)

addCommandHandler("mapflash", function()
	dontMapFlash = not exports.settingsmanager:loadSetting("dontMapFlash")
	if dontMapFlash then
		outputChatBox("#ffffff* Taskbar flashing on map change was #ff0000DISABLED", 255, 0, 0, true)
	else
		outputChatBox("#ffffff* Taskbar flashing on map change was #00FF00ENABLED", 0, 255, 0, true)
	end
	exports.settingsmanager:saveSetting("dontMapFlash", dontMapFlash)
end)

MapSound = {}
function detectMap(theRes)
	dontMapFlash = exports.settingsmanager:loadSetting("dontMapFlash")
	if dontMapFlash == nil then --if not set
		dontMapFlash = false --set defaults
		exports.settingsmanager:saveSetting("dontMapFlash", false) --and save
	end
    if #getElementsByType('spawnpoint', source) > 0 then
		if not dontMapFlash then
			setWindowFlashing(true, 0)
		end
        MapSound = getElementsByType( "sound", source )
        for f, u in pairs(MapSound) do
            setSoundPaused( u, true )
        end
	end
end
addEventHandler("onClientResourceStart", root, detectMap)

addEvent("onClientMapLaunched", true)
addEventHandler("onClientMapLaunched", root, function()
	for f, u in pairs(MapSound) do
		setSoundPaused( u, false )
	end
end)

-- notification tray on map started

addEventHandler("onMapGather", getRootElement(),
    function(mapName,likes,dislikes,timesPlayed, author, description, lastTimePlayed, playerTime, nextmap)
        local nextmap = nextmap or '-not set-'
        if isTrayNotificationEnabled() then
            createTrayNotification("[MrGreenGaming] ".. mapName .." just started. (".. nextmap  or '-not set-' ..").", "default" )
        end
    end
)

function checkGear()
    local theVehicle = getPedOccupiedVehicle(localPlayer)
    if ( getElementModel(theVehicle) == 520 and getVehicleLandingGearDown( theVehicle ) == true) then
      setVehicleLandingGearDown(theVehicle,false)
      outputChatBox( "[Hydra] Landing gear is ready!", 0, 255, 0)
        if ( getAnalogControlState( "special_control_up" ) == 0 ) then
            setAnalogControlState( "special_control_up", 1 )
        else
            setAnalogControlState( "special_control_up", 0 )
        end
    end
end
addEventHandler("onClientMapStarting", root, checkGear)

-- disable randomfoliage

addEventHandler("onClientMapStarting", root, function()
    setWorldSpecialPropertyEnabled("randomfoliage", false)
end)

-- Vehicle ID change
local lastVehID
function checkVehicleID()
    local currentVehID = false
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then
        currentVehID = false
    else
        currentVehID = getElementModel(veh)
    end

    if lastVehID ~= currentVehID then
        setElementData(localPlayer, 'playerVehicleID', currentVehID)
    end
    lastVehID = currentVehID
end
setTimer(checkVehicleID, 50, 0)

-- Toggle UI
local ToggleUI = {}
ToggleUI.screenSize = { guiGetScreenSize() }
ToggleUI.visible = true
ToggleUI.screenSource = false

function ToggleUI.toggleUIVisibility()
    ToggleUI.visible = not ToggleUI.visible
    removeEventHandler("onClientPreRender", root, ToggleUI.render)
    if ToggleUI.visible and isElement(ToggleUI.screenSource) then
        destroyElement(ToggleUI.screenSource)
        ToggleUI.screenSource = false
    else
        ToggleUI.screenSource = dxCreateScreenSource(ToggleUI.screenSize[1], ToggleUI.screenSize[2])
        if ToggleUI.screenSource then
            addEventHandler("onClientPreRender", root, ToggleUI.render)
        end
    end
end
addCommandHandler("toggleui", ToggleUI.toggleUIVisibility)

function ToggleUI.render()
    if not ToggleUI.screenSource then
        ToggleUI.toggleUIVisibility()
        return
    elseif isChatBoxInputActive() or isConsoleActive() then
        return
    end
    dxUpdateScreenSource(ToggleUI.screenSource)
    dxDrawImage(0, 0, ToggleUI.screenSize[1], ToggleUI.screenSize[2], ToggleUI.screenSource, 0, 0, 0, "0xFFFFFFFF", true)
end

-- Daylight
local light = {}
light.allowedModes = {
    ["never the same"] = true,
    sprint = true,
    ["reach the flag"] = true
}
light.timer = false
light.timeCache = {getTime()}
light.durationCache = getMinuteDuration()
light.currentMode = false
light.mode = ""

function light.toggleDaylight()
    if getResourceFromName("snow") and getResourceState(getResourceFromName("snow")) == "running" then
        outputChatBox("Daylight cannot be used while Santa Claus is here.", 200, 0, 0)
        return
    end
    if light.mode ~= "day" then
        local allowed = light.isAllowed()
        if light.mode == "night" then outputChatBox("Nightlight disabled.", 200, 0, 0) end
        outputChatBox("Daylight enabled." .. (allowed and "" or " It will only be applied in allowed modes."), 0, 200, 0)
        if allowed then
            light.apply()
        end
        light.mode = "day"
    else
        light.apply(true)
        light.mode = ""
        outputChatBox("Daylight disabled.", 200, 0, 0)
    end
end
addCommandHandler("daylight", light.toggleDaylight)

function light.toggleNightlight()
    if getResourceFromName("snow") and getResourceState(getResourceFromName("snow")) == "running" then
        outputChatBox("Nightlight cannot be used while Santa Claus is here.", 200, 0, 0)
        return
    end

    if light.mode ~= "night" then
        local allowed = light.isAllowed()
        if light.mode == "day" then outputChatBox("Daylight disabled.", 200, 0, 0) end
        outputChatBox("Nightlight enabled." .. (allowed and "" or " It will only be applied in allowed modes."), 0, 200, 0)
        if allowed then
            light.apply()
        end
        light.mode = "night"
    else
        light.apply(true)
        light.mode = ""
        outputChatBox("Nightlight disabled.", 200, 0, 0)
    end
end
addCommandHandler("nightlight", light.toggleNightlight)

function light.apply(fromCache)
    if not fromCache then
        if (light.mode == "day") then
            setTime(12,0)
        elseif (light.mode == "night") then
            setTime(0,0)
        end
        setMinuteDuration(2147483647)
        if not isTimer(light.timer) then
            light.timer = setTimer(
                function()
                    setMinuteDuration(2147483647)
                    if getTime() ~= 12 and light.mode == "day" then
                        setTime(12,0)
                    elseif getTime() ~= 0 and light.mode == "night" then
                        setTime(0,0)
                    end
                end,
            200, 0)
        end
    else
        if isTimer(light.timer) then
            killTimer(light.timer)
        end
        setTime(light.timeCache[1], light.timeCache[2])
        setMinuteDuration(light.durationCache)
    end
end

function light.onMapStart(info)
    light.currentMode = info.modename:lower()
    light.setCache()
    if (light.mode == "day" or light.mode == "night") and light.isAllowed() then
        light.apply(false)
    end
end
addEvent("onClientMapStarting")
addEventHandler("onClientMapStarting", root, light.onMapStart)

function light.onMapStop()
    if isTimer(light.timer) then
        killTimer(light.timer)
    end
    light.setCache(true)
end
addEvent("onClientMapStopping")
addEventHandler("onClientMapStopping", root, light.onMapStop)

function light.setCache(reset)
    if reset then
        if (light.mode == "day") then
            light.timeCache = {12, 0}
        elseif (light.mode == "night") then
            light.timeCache = {0, 0}
        end
        light.durationCache = 1000
        return
    end
    light.timeCache = {getTime()}
    light.durationCache = getMinuteDuration()
end

function light.isAllowed()
    return light.allowedModes[light.currentMode] and true or false
end

function isBoolean(str)
	if str == nil then return false end
	if str == "false" then return true end
	if str == "true" then return true end
	if str == false then return true end
	if str == true then return true end
end
