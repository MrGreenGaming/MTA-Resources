
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

--- Rules window ---

GUIEditor = {
    button = {},
    window = {},
    label = {}
}
addCommandHandler('rules',
    function()
		local screenW, screenH = guiGetScreenSize()
        GUIEditor.window[1] = guiCreateWindow((screenW - 350) / 2, (screenH - 230) / 2, 350, 230, "Server Rules", false) 
        guiWindowSetMovable(GUIEditor.window[1], false)
        guiWindowSetSizable(GUIEditor.window[1], false)

        GUIEditor.label[1] = guiCreateLabel(10, 23, 330, 166, "1. Don't spam, swear, exploit, be a retard.\n2. Our main language here is English.\nIf an admin asks you to use English, use English.\n3. The admins ( /admins ) are always right.\n4. Do not deliberately block to ruin maps.\n5. Do not camp in DD and/or SH maps.\n6. Do not teamkill in CTF maps\n7. Don't escape map boundaries if any.\n\nFailure to comply with the rules can get you kicked or banned!", false, GUIEditor.window[1])
        guiSetFont(GUIEditor.label[1], "clear-normal")
        guiLabelSetColor(GUIEditor.label[1], 0, 255, 0)
        guiLabelSetHorizontalAlign(GUIEditor.label[1], "left", true)
        GUIEditor.button[1] = guiCreateButton(10, 199, 330, 18, "I have read and agreed to the rules", false, GUIEditor.window[1])    
		showCursor(true)
        addEventHandler("onClientGUIClick", GUIEditor.button[1], closeRules, false)
		
		-- Centered, size mantains, the only problem with this is that the 1080p players would see it very tiny, this can be changed with comparing resolutions, if its too high, the size is doubled. I also removed all relatives values on the label and button
    end
)

function hasPlayerSeenTheRules()
    local file = xmlLoadFile('rules_.xml')
    if not file then
        file = xmlCreateFile('rules_.xml', 'rules')
    end
    if not xmlNodeGetValue(file) or xmlNodeGetValue(file) == '' then
        return false
    elseif xmlNodeGetValue(file) == 'viewed' then
        return true
    end
    xmlUnloadFile(file)
end

addEventHandler('onClientResourceStart', resourceRoot,
function()
    if not hasPlayerSeenTheRules() then
        executeCommandHandler('rules')
    end
end)

function closeRules(button)
    if button == "left" then
        if isElement(GUIEditor.window[1]) then
            destroyElement(GUIEditor.window[1])
            showCursor(false)
            local file = xmlLoadFile('rules_.xml')
            if not file then
               file = xmlCreateFile('rules_.xml', 'rules')
            end
            xmlNodeSetValue(file, 'viewed')
            xmlSaveFile(file)
            xmlUnloadFile(file)
        end
    end
end


-- -- /ignore <playername> -- Uncommented by KaliBwoy, added to settings menu.

-- local ignores = nil
-- function findPlayerByName(playerPart)
-- 	local pl = playerPart and getPlayerFromName(playerPart)
-- 	if pl and isElement(pl) then
-- 		return pl
-- 	elseif playerPart then
-- 		for i,v in ipairs (getElementsByType ("player")) do
-- 			if (string.find(string.gsub ( string.lower(getPlayerName(v)), '#%x%x%x%x%x%x', '' ),string.lower(playerPart))) then
-- 				return v
-- 			end
-- 		end
--     end
--  end
 
-- function ignorePlayer(cmd, playername)
-- 	local player = findPlayerByName(playername)
-- 	if player == localPlayer then
-- 		outputChatBox ( 'Press F2 2x times for full server ignore', 255, 0, 0 )
-- 	elseif not player then
-- 		outputChatBox ( '/ignore: Could not find \'' .. (playername or '') .. '\'', 255, 0, 0 )
-- 	else
-- 		if not ignores then
-- 			ignores = {}
-- 		end
-- 		outputChatBox ( '/ignore: ignoring player ' .. getPlayerName(player), 255, 0, 0 )
-- 		setElementData(player, 'ignored', true, false)
-- 		setTimer(function()
-- 		table.insert(ignores, player)
-- 		end, 100,1)
-- 	end
-- end
-- addCommandHandler ( 'ignore', ignorePlayer)

-- function onClientChatMessageHandler( text )
-- 	if not ignores or not text then return end
	
-- 	for k, player in ipairs(ignores) do
-- 		if isElement(player) and text:find(getPlayerName(player), 1, true) then
-- 			return cancelEvent()
-- 		end
-- 	end
-- end
-- addEventHandler("onClientChatMessage", root, onClientChatMessageHandler)

-- /fpslimit <limit>

local limit
function clientFPSLimit(cmd, limit_)
	--if (tonumber(limit_) and tonumber(limit_) > 19 and tonumber(limit_) < 61) then
	--	outputChatBox('Your FPS limit will be changed on next map change')
	--	limit = tonumber(limit_)
	--else
	--	outputChatBox('Bad limit.')
	--end
	triggerEvent("gus_c_fpslimit", root, limit_)
end
addCommandHandler ( 'fpslimit', clientFPSLimit)

--addEventHandler('onClientMapStarting', root, function ()
--	if limit then setFPSLimit(limit) end
--end)

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

-- tray notification on map started

addEventHandler("onClientResourceStart", getRootElement(),
    function(res)
        createTrayNotification("[MrGreenGaming] Map (" .. getResourceName(res) .. ") just started.", "default" )
    end
)
