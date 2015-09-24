bountyDelayTime = 10000
isBountyGamemodeAllowed = false
OutputColorR,OutputColorG,OutputColorB =  171, 255, 174

btestmode = true
addCommandHandler( "bountytestmode", 
	function(Psource,cmd,bln) 
		if hasObjectPermissionTo( Psource, "function.banPlayer", false) then 
			if bln == true or bln == "true" then btestmode = true outputDebugString("Bounty testmode : true")
			elseif bln == false or bln == "false" then btestmode = false outputDebugString("Bounty testmode : false")
			end
		end
	end)

local BountyTable = {
	-- [playerWithBounty] = { EXAMPLE TREE
	-- 	["source"] = bountySource,
	-- 	["amount"] = bountyAmount, }
}

local hasPlayerSetBounty = {
	-- [player] = true, -- EXAMPLE TREE --
}

local gc = exports["gc"]
-- local kill = exports["race_kill"]

function setBountyHandler(Psource,cmd,NamePart, amount)
	-- fail checks --

	if btestmode and not hasObjectPermissionTo( Psource, "function.banPlayer", false ) then return end


	if exports.race:getRaceMode() == "Sprint" then return end

	if not isBountyGamemodeAllowed then outputChatBox("Bounty's are only allowed in DD or Shooter!",Psource,255,0,0) return end

	if not NamePart then return end

	local toPlayer = getPlayerFromPartialName(NamePart)


	if hasPlayerSetBounty[Psource] then outputChatBox("You can only set 1 bounty per match.",Psource,255,0,0) return end

	if not toPlayer then outputChatBox("Player Not Found.",Psource,255,0,0) return end

	if isPedDead(toPlayer) then outputChatBox("You can't set bounties on dead players.",Psource,255,0,0) return end

	local theName = __getPlayerName(toPlayer,true)

	if BountyTable[toPlayer] then outputChatBox(theName.." already got a bounty his head.",Psource,255,0,0) return end

	if not tonumber(amount) then outputChatBox("Wrong command syntax used, use: /addbounty name amount",Psource,255,0,0) return end
	
	local amount = tonumber(amount)
	if amount < 50 or amount > 1000 then outputChatBox("GC Amount must be between 50gc and 10000gc",Psource,255,0,0) return end

	local playerGC = gc:getPlayerGreencoins(Psource)
	if playerGC-amount < 0 then outputChatBox("You do not have enough GC!",Psource,255,0,0) return end

	local alivePlayers = getAlivePlayers()
	local minPlayers = calculateMinimumPlayers()
	-- if #alivePlayers < minPlayers then bountyOutput("You can't place a bounty with less than "..tostring(minPlayers).." players alive.",Psource,255,0,0) return end
	-- if Psource == toPlayer then bountyOutput("You can not put a bounty on yourself!",Psource,255,0,0) return end

	-- End fail checks --
	setTimer( setBounty, bountyDelayTime, 1, toPlayer,Psource,amount)
	local time = bountyDelayTime
	local time = time/1000
	outputChatBox("Bounty will be active in "..tostring(time).." seconds.",Psource,0,255,0)


end
addCommandHandler( "setbounty", setBountyHandler )


function setBounty(victim,Psource,amount)
	if mapState ~= "Running" then outputChatBox("Bounty Failed, Map has stopped.",Psource,255,0,0) return end
	if not isElement(victim) then outputChatBox("Bounty Failed, Can't find player.",Psource,255,0,0) return end
	if isPedDead( victim ) then outputChatBox("Bounty Failed, Victim is dead.",Psource,255,0,0) return end
	if BountyTable[victim] then outputChatBox("Bounty Failed, There is already a bounty on that player.",Psource,255,0,0) return end
	local sourceName = __getPlayerName(Psource,true)
	local victimName = __getPlayerName(victim,true)
	hasPlayerSetBounty[Psource] = true
	BountyTable[victim] = {
	["source"] = Psource,
	["amount"] = amount }


	giveBountyRewards(Psource, -amount)
	bountyOutput(sourceName.." has put a bounty on "..victimName.."'s head! ("..tostring(amount).." GC)",getRootElement(),OutputColorR,OutputColorG,OutputColorB)


	triggerClientEvent( root, "clientReceiveBounty", root, victim, amount )

end

function checkGamemode(state)
	mapState = state
	if state == "Running" and exports.race:getRaceMode() == "Destruction derby" or exports.race:getRaceMode() == "Shooter" then
		isBountyGamemodeAllowed = true
	elseif state == "LoadingMap" then
		BountyTable = {}
		hasPlayerSetBounty = {}
	else
		isBountyGamemodeAllowed = false
	end
end
addEvent('onRaceStateChanging', true)
addEventHandler("onRaceStateChanging", root, checkGamemode)



-- Bounty Kill --
function handleBountyKill()
	local player = source

	-- if tonumber(#getAlivePlayers()) == 1 then handleWinner() end
	if not BountyTable[player] then return end

	local amount = tonumber(BountyTable[player]["amount"])
	local bountySource = BountyTable[player]["source"]

	local killer = exports.race_kill:getKiller(player)
	local killerName = __getPlayerName(killer, true)
	local playerName = __getPlayerName(player, true)
	local sourceName = __getPlayerName(bountySource, true)

	if killer == bountySource then 
		bountyOutput(sourceName.." completed his own bounty by killing "..playerName..", "..tostring(amount).." GC refunded.",root,OutputColorR,OutputColorG,OutputColorB ) 
		giveBountyRewards(bountySource,amount)

		BountyTable[player] = nil
		return 
	end

	if not killer then
		-- Refund source
		bountyOutput(playerName.." died without getting killed, "..tostring(amount).." GC refunded to "..sourceName.."!",root,OutputColorR,OutputColorG,OutputColorB)
		giveBountyRewards(bountySource,amount)

		BountyTable[player] = nil

	elseif killer then
		-- Give Killer Credit
		bountyOutput(killerName.." has earned "..tostring(amount).."GC for completing "..sourceName.."'s bounty by killing "..playerName.."!",root,OutputColorR,OutputColorG,OutputColorB)
		giveBountyRewards(killer,amount)

		BountyTable[player] = nil
	end

	
end
addEvent('onPlayerFinishDD')
addEventHandler('onPlayerFinishDD', root, handleBountyKill)
addEvent('onPlayerFinishShooter')
addEventHandler('onPlayerFinishShooter', root, handleBountyKill)


function handleWinner(name)
	local winner = source
	if name == "race rank" and tonumber(getElementData(winner,"race rank")) == 1 then
		local winnerName = __getPlayerName(winner,true)

		if not BountyTable[winner] then return end

		local amount = BountyTable[winner]["amount"]

		bountyOutput(winnerName.." earned "..tostring(amount).."GC for winning the match with a bounty on his head!",root,OutputColorR,OutputColorG,OutputColorB)
		giveBountyRewards(winner,amount)

		BountyTable = {}
		hasPlayerSetBounty = {}
	end

end
addEventHandler("onElementDataChange",root,handleWinner)




function giveBountyRewards(to,amt)
	if not btestmode then
		gc:addPlayerGreencoins(to,amt)
	end
end

-- Min Player Calculator --
function calculateMinimumPlayers()
	local playerCount = getPlayerCount()
	if playerCount < 10 then playerCount = 10 end
	local percent = playerCount/100*40 -- calculate 40 percent
	return math.floor(percent)
end

 -- util --
function bountyOutput(str,element,r,g,b)
	local delayTime = 800 -- ms
	setTimer(function()
	local prefix = "[Bounty]"
	outputChatBox(prefix.." "..str,element,r,g,b)
	exports.messages:outputGameMessage(prefix.." "..str,element,2.4,r,g,b)
	end,delayTime,1)
end



function getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end

function __getPlayerName(plyr, bln)
	if bln and isElement(plyr) then
		local theName = getPlayerName(plyr)
		local theName = string.gsub(theName, '#%x%x%x%x%x%x', '')
		return theName
	elseif not bln then
		return getPlayerName(plyr)
	end
end
