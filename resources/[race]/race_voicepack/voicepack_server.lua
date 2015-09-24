local g_Root = getRootElement()

local mapMode = ""

function playAudio(player, filename)
	-- outputDebugString("play sound "..filename.." for "..getPlayerName(player))
	triggerClientEvent(player, "playClientAudio", getRootElement(), filename)
end

addEvent("onMapStarting")
addEventHandler('onMapStarting', g_Root,
	function(mapInfo)
		mapMode = mapInfo.modename
	end
)

addEventHandler('onPlayerQuit', g_Root,
    function()
        if mapMode == "Destruction derby" and getElementData(source,"state") == "alive" then
			local alivePlayers = getAlivePlayers()
            for i,player in ipairs(alivePlayers) do
                if player == source then
                    table.remove(alivePlayers, i)
                end
            end
            if #alivePlayers == 1 then
                playAudio(alivePlayers[1], "jobcomplete.mp3")
            end
		end
    end
)

addEventHandler('onPlayerWasted', g_Root,
	function()
		if mapMode == "Destruction derby" then
			local alivePlayers = getAlivePlayers()
			if #alivePlayers >= 1 then
				playAudio(source, "jobfail.mp3")
				if #alivePlayers == 1 then
					playAudio(alivePlayers[1], "jobcomplete.mp3")
				end
			end
		else
			if p_Killed then
				p_Killed = false
			else
				playAudio(source, "wasted.mp3")
			end
		end
	end
)

addEvent('onRequestKillPlayer', true)
addEventHandler('onRequestKillPlayer', g_Root,
    function()
		p_Killed = true
    end
)

addEvent("onPlayerToptimeImprovement")
addEventHandler("onPlayerToptimeImprovement", g_Root,
	function(newPos, newTime, oldPos, oldTime, displayTopCount, validEntryCount)
		if newPos <= displayTopCount and newPos <= validEntryCount then
			playAudio(source, "nicework.mp3")
		end
	end
)

local _getAlivePlayers = getAlivePlayers
function getAlivePlayers(player)
	local result = {}
	for _,player in ipairs(_getAlivePlayers()) do
		if getElementData(player, "state") == "alive" then
			table.insert(result, player)
		end
	end
	return result
end


-- CTF Sounds --
local noReturnTable = {
	["red"] = false,
	["blue"] = false
}

function getTeamColorName(t)
	local t = getTeamName(t)
	if t == "Red team" then
		return {[1] = "red", [2] = "blue"}
	elseif t == "Blue team" then
		return {[1] = "blue", [2] = "red"}
	else return false
	end
end


	
-- Flag Delivered Sound
addEvent("onCTFFlagDelivered",true)
addEventHandler("onCTFFlagDelivered",root,
	function()
		local player = source
		local team = getPlayerTeam(player)
		local team = getTeamColorName(team)
		if team then
			noReturnTable[team[2]] = true
			setTimer(function() noReturnTable[team[2]] = false end,1000,1)
			playAudio(root,team[1].."_team_scores.mp3")
		end
	end)

-- Flag Dropped Sound
addEvent("onCTFFlagDropped",true)
addEventHandler("onCTFFlagDropped",root,
	function(t)
		local player = source
		local team = getPlayerTeam(player)
		local t = getTeamColorName(team)
		if t then
			playAudio(root,t[2].."_flag_dropped.mp3")
		end
	end)


-- Flag Returned Sound
addEvent("onCTFFlagReturned",true)
addEventHandler("onCTFFlagReturned",root,
	function()
		local t = getTeamColorName(source)
		if t then
			local tn = t[1]
			setTimer(function() 
			if noReturnTable[tn] == false then
				playAudio(root,tn.."_flag_returned.mp3")
			end end,500,1)
			

		end
	end)

-- Flag Taken Sound
addEvent("onCTFFlagTaken",true)
addEventHandler("onCTFFlagTaken",root,
	function()
		local t = getPlayerTeam( source )
		local t = getTeamColorName(t)
		if t then
			playAudio(root,t[2].."_flag_taken.mp3")
		end
	end)
