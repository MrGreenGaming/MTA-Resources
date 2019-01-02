modsWarning = textCreateDisplay ()
local modWarnText1 = textCreateTextItem ( "You have modified game files", 0.5, 0.20, "high", 230, 0, 0, 255, 4.0, "center", "center" )
local modWarnText3 = textCreateTextItem ( "You have modified game files", 0.503, 0.203, "high", 230, 0, 0, 0, 4.0, "center", "center" )
local modWarnText2 = textCreateTextItem ( "Remove them to play on this server", 0.5, 0.27, "high", 217, 0, 0, 255, 2.5, "center", "center" )
local modWarnText4 = textCreateTextItem ( "Remove them to play on this server", 0.503, 0.273, "high", 217, 0, 0, 0, 2.5, "center", "center" )
textDisplayAddText ( modsWarning, modWarnText4 )
textDisplayAddText ( modsWarning, modWarnText3 )
textDisplayAddText ( modsWarning, modWarnText2 )
textDisplayAddText ( modsWarning, modWarnText1 )

local moddedPlayerTable = {}

function handleOnPlayerModInfo ( filename, modList )
    -- Print player name and file name
 
	if not isElement(source) then return end
 
	local mods = 0
		
    -- Print details on each modification
    local playerModTable = {}
    for idx,mod in ipairs(modList) do
		
        local line = tostring(idx) .. ")" .. getPlayerName(source) .. " " .. mod.name
        -- for k,v in pairs(mod) do
        --     line = line .. " " .. tostring(k) .. "=" .. tostring(v)
        -- end
		
		if not isModSafe ( mod ) then
			mods = mods + 1
			-- outputConsole(line)
			hasMods = true
			table.insert(playerModTable,line)
			-- warn( source )
		end
		
    end
	
	if mods > 0 then
		-- outputConsole( getPlayerName(source) .. " " .. filename )
		moddedPlayerTable[source] = true
		triggerClientEvent(source,"displayModdedPlayer",resourceRoot,playerModTable)
		playerModTable = nil

		for i = 1,10 do 
			outputChatBox("* Please remove your mods before you can play *",source,255,0,0)
		end

		if textDisplayIsObserver( afkwarn, source ) then textDisplayRemoveObserver( afkwarn, source ) end -- Remove AFK text
		if textDisplayIsObserver( afknotify, source ) then textDisplayRemoveObserver( afknotify, source ) end -- Remove AFK text

		textDisplayAddObserver(modsWarning, source)
		toggleAllControls( source, false,true, false)
		-- outputDebugString(getPlayerName(source).." is now put in MODDED files state.")
		-- kickPlayer ( source, "Remove your " .. mods .. " mods. Only .txd mods allowed" )
	else
		playerModTable = nil
	end
end
 

addEventHandler ( "onPlayerModInfo", root, handleOnPlayerModInfo )

-- Remove player from table when quits --
addEventHandler("onPlayerQuit", root, function() if moddedPlayerTable[source] then moddedPlayerTable[source] = nil end end)
--

whitelist = {
	["tree_hipoly19.dff"] = true,
}
function isModSafe ( mod )
	if string.find(mod.name, '.txd') or whitelist[mod.name] then
		return true
	elseif string.find(mod.name, '.dff') then
		return (mod.sizeX and mod.sizeY and mod.sizeZ and mod.sizeX == mod.originalSizeX and mod.sizeY == mod.originalSizeY and mod.sizeZ == mod.originalSizeZ) or false
	else
		return false
	end
end

function executeModState(gamemode)
	if gamemode == "Destruction derby" or gamemode == "Shooter" then
		for f,u in pairs(moddedPlayerTable) do
			if isElement(f) then		
				if isElement(getPedOccupiedVehicle(f)) and not isPedDead(f) then
					outputChatBox("You were killed, reason: Modded files.",f,255,0,0)
					killPed( f )
				end
			end
		end
	else -- Other gamemodes are handled the same
		for f,u in pairs(moddedPlayerTable) do
			if u then
				toggleAllControls( f, false,true, false)
				triggerClientEvent(f,"triggerPlayerSpectate",resourceRoot,true)
			end
		end
	end
end
addEvent('onRaceStateChanging', true)
addEventHandler('onRaceStateChanging', root, function(state) local gm = exports.race:getRaceMode() if state == "Running" then executeModState(gm) end end)

local virtualMachineWhitelist = {
	-- ["serial"] == true,
	["EB8EA4A9C0424281C602EB455E5CF753"] = true,	-- Rokkas linux vm https://mrgreengaming.com/forums/topic/19443-playing-on-a-virtual-machine/#comment-152720
}
function handleOnPlayerACInfo( detectedACList, d3d9Size, d3d9MD5, d3d9SHA256 )
    -- outputDebugString( "ACInfo for " .. getPlayerName(source)
                -- .. " detectedACList:" .. table.concat(detectedACList,",")
                -- .. " d3d9Size:" .. d3d9Size
                -- .. " d3d9SHA256:" .. d3d9SHA256
                -- )
	for _, AC in ipairs(detectedACList) do
		if AC == 14 then
			if (virtualMachineWhitelist[getPlayerSerial(source)]) then
				outputConsole("AC 14 Virtual Machine: Whitelisted serial")
			else
				kickPlayer(source, "AC14 Virtual Machine: Your serial is not on the whitelist")
				return
			end
		end
	end
end	
addEventHandler( "onPlayerACInfo", root, handleOnPlayerACInfo)

addEventHandler( "onResourceStart", resourceRoot,
    function()
        for _,player in ipairs( getElementsByType("player") ) do
            resendPlayerACInfo( player )
            resendPlayerModInfo( player )
        end
    end
)
addEventHandler('onPlayerJoin', root, function()
	resendPlayerACInfo(source)
	resendPlayerModInfo(source)
end)