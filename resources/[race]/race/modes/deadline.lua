Deadline = setmetatable({}, RaceMode)
Deadline.__index = Deadline

Deadline:register('Deadline')

deadlineBindsActive = false
deadlineDrawLines = false -- Bool for late joiners, draw lines or not
deadlineActivationTimer = {}
------------------------
-- Gameplay Variables Standards --
DeadlineOptions = {}
DeadlineOptions.size = 40 -- Size of line
DeadlineOptions.minimumSpeed = 60 -- Minimum speed (in km/h)
DeadlineOptions.boostSpeed = 100 -- Boost Speed (added to current speed)
DeadlineOptions.boost_cooldown = 35000 -- boost cooldown in ms
DeadlineOptions.jumpHeight = 0.25 -- Jump Height
DeadlineOptions.jump_cooldown = 15000 -- jump cooldown in ms
DeadlineOptions.notMovingKillTime = 10000 -- Kill time for not moving, also counts if reversing (ms)
DeadlineOptions.godmode = true -- set bool if vehicles should be immume to collisions or not
DeadlineOptions.lineAliveTime = 2500 -- Set how long a line should be alive (in ms) -- 1350


DeadlineOptionsDefaults = DeadlineOptions

-- /deadline setlinesize x
-- /deadline setminspeed x
-- /deadline setboostspeed x
-- /deadline setboostcooldown x
-- /deadline jumpheight x
-- /deadline jumpcooldown x
-- /deadline godmode true/false
-- /deadline linealivetime x
-- /deadline help
-- /deadline reset

-- Gameplay Variables Standards --
------------------------





function Deadline:isApplicable()
	return not self.checkpointsExist() and string.lower(tostring(RaceMode.registeredModes[string.lower(g_MapInfo.metamode)])) == 'deadline'
end


function Deadline:getPlayerRank(player)
	return #getActivePlayers()
end

-- Copy of old updateRank
function Deadline:updateRanks()
	for i,player in ipairs(g_Players) do
		if not isPlayerFinished(player) then
			local rank = self:getPlayerRank(player)
			if not rank or rank > 0 then
				setElementData(player, 'race rank', rank)
			end
		end
	end
	-- Make text look good at the start
	if not self.running then
		for i,player in ipairs(g_Players) do
			setElementData(player, 'race rank', '' )
			setElementData(player, 'checkpoint', '' )
		end
	end
end


function Deadline:timeout()
	local activePlayers = getActivePlayers()

	if #activePlayers == 2 then
		if type(getElementData(activePlayers[1], "kills")) == "number" and type(getElementData(activePlayers[2], "kills")) == "number" then
			--outputChatBox(getPlayerName(activePlayers[1])..": "..getElementData(activePlayers[1], "kills").." - "..getPlayerName(activePlayers[2])..": "..getElementData(activePlayers[2], "kills"))
			if getElementData(activePlayers[1], "kills") < getElementData(activePlayers[2], "kills") then
				self:handleFinishActivePlayer(activePlayers[1])
			elseif getElementData(activePlayers[2], "kills") < getElementData(activePlayers[1], "kills") then
				self:handleFinishActivePlayer(activePlayers[2])
			end
		elseif type(getElementHealth(getPedOccupiedVehicle(activePlayers[1]))) == "number" and type(getElementHealth(getPedOccupiedVehicle(activePlayers[2]))) == "number" then
			--outputChatBox(getPlayerName(activePlayers[1])..": "..getElementHealth(getPedOccupiedVehicle(activePlayers[1])).." - "..getPlayerName(activePlayers[2])..": "..getElementHealth(getPedOccupiedVehicle(activePlayers[2])))
			if getElementHealth(getPedOccupiedVehicle(activePlayers[1])) < getElementHealth(getPedOccupiedVehicle(activePlayers[2])) then
				self:handleFinishActivePlayer(activePlayers[1])
			elseif getElementHealth(getPedOccupiedVehicle(activePlayers[2])) < getElementHealth(getPedOccupiedVehicle(activePlayers[1])) then
				self:handleFinishActivePlayer(activePlayers[2])
			end
		else
			self:handleFinishActivePlayer(activePlayers[math.random(1, 2)])
		end
	elseif #activePlayers >= 2 then
		for i=1, #activePlayers do
			self:handleFinishActivePlayer(activePlayers[i])
		end
	end
end


function Deadline:onPlayerWasted(player)
	if isActivePlayer(player) then
		self:handleFinishActivePlayer(player)
		if getActivePlayerCount() <= 1 then
			self:endMap()
		else
			local veh = g_CurrentRaceMode.getPlayerVehicle(player)
			local x, y, z = getElementPosition(veh)
			TimerManager.createTimerFor("map",player):setTimer(setElementPosition, 1950, 1, veh, x + 5000, y + 5000, z + 5000)
			TimerManager.createTimerFor("map",player):setTimer(clientCall, 2000, 1, player, 'Spectate.start', 'auto')
		end
	end
	self.setPlayerIsFinished(player)
	showBlipsAttachedTo(player, false)
	clientCall(player, 'showOnlyHealthBar', false)

end



function Deadline:onPlayerQuit(player)
	if isActivePlayer(player) then
		self:handleFinishActivePlayer(player)
		if getActivePlayerCount() <= 1 then
			self:endMap()
		end
	end
end



function Deadline:handleFinishActivePlayer(player)
	local timePassed = self:getTimePassed()
	-- self.rankingBoard:add(player, timePassed)
	-- Do remove
	local rank = self:getPlayerRank(player)
	finishActivePlayer(player)
	-- outputChatBox('Deadline:handleFinishActivePlayer Rank:'..tostring(rank))
	if rank and rank > 1 then
		triggerEvent( "onPlayerFinishDeadline",player,tonumber( rank ),timePassed )
	end
	-- Update ranking board if one player left
	local activePlayers = getActivePlayers()
	if #activePlayers == 1 then
		-- self.rankingBoard:add(activePlayers[1], timePassed)
		showMessage(getPlayerName(activePlayers[1]) .. ' is the final survivor!', 0, 255, 0)
		triggerEvent( "onPlayerWinDeadline",activePlayers[1],1,timePassed )
	end
end
addEvent('onPlayerFinishDeadline')
addEvent('onPlayerWinDeadline')


function Deadline:launch()
	RaceMode.launch(self)

	--if math.random(2) == 1 then clientCall(g_Root, 'showOnlyHealthBar', true) end -- Use this to hide names 50% of the time
	clientCall(g_Root, 'showOnlyHealthBar', true) -- Use this to hide names 100% of the time
	-- Add binds for rockets/jumps and cooldown at start
	deadlineBindsActive = false
	self.cooldowns = {}
	local tick = getTickCount() + 150
	for k, player in ipairs(getActivePlayers()) do

		-- bindKey(player, "vehicle_fire", "down", function(p,k,s) self:boost(p,k,s) end)
		bindKey(player, "vehicle_fire", "down", self.boost)
		bindKey(player, "vehicle_secondary_fire", "down", self.jump)
		bindKey(player, "mouse2", "down", self.jump)
		self.cooldowns[player] = {boost = tick, jump = tick}

		removeElementData( player, 'deadline.jumpOnCooldown' )
		removeElementData( player, 'deadline.boostOnCooldown' )
		
	end



	deadlineActivationTimer[1] = setTimer(showMessage, 50, 1, "Dead Lines will be enabled in 5 seconds!", 255, 0, 0, root)
	deadlineActivationTimer[2] = setTimer(showMessage, 1000, 1, "Dead Lines will be enabled in 4 seconds!", 255, 127, 0, root)
	deadlineActivationTimer[3] = setTimer(showMessage, 2000, 1, "Dead Lines will be enabled in 3 seconds!", 254, 255, 0, root)
	deadlineActivationTimer[4] = setTimer(showMessage, 3000, 1, "Dead Lines will be enabled in 2 seconds!", 127, 255, 0, root)
	deadlineActivationTimer[5] = setTimer(showMessage, 4000, 1, "Dead Lines will be enabled in 1 seconds!", 0, 255, 0, root)
	deadlineActivationTimer[6] = setTimer(showMessage, 5000, 1, "Kill players with your line while avoiding other lines", 0, 255, 0, root)
	deadlineActivationTimer[7] = setTimer(showMessage, 8000, 1, "Press fire to speed boost and alt-fire/rmb to jump!", 0, 255, 0, root)
	deadlineActivationTimer[8] = setTimer(function() deadlineDrawLines = true clientCall(g_Root, 'Deadline.load',DeadlineOptions) deadlineBindsActive = true end,5000,1)
	
end



function Deadline:start()
	self:cleanup()
	local options = {
		duration = 5 * 60 * 1000,
		respawn = 'none',
		autopimp = false,
		autopimp_map_can_override = false,
		vehicleweapons = false,
		vehicleweapons_map_can_override = false,
		hunterminigun = false,
		hunterminigun_map_can_override = false,
		ghostmode = false,
		ghostmode_map_can_override = false,
	}
	for key,value in pairs(options) do
		Deadline.setMapOption(key,value)
	end
	

end

function Deadline.boost(player, key, keyState) 
	if not deadlineBindsActive then return end
	if not isActivePlayer( player ) then return end
	local veh = g_CurrentRaceMode.getPlayerVehicle(player)

	if not g_CurrentRaceMode:checkAndSetJumpCooldown(player,'boost') then return end
	-- outputDebugString('Shooter ' .. 'jump ' .. getPlayerName(player)) 
	clientCall(player, 'deadlineBoost')
	-- clientCall(player, 'dl_cd_handler', 'boost')

	
end

function Deadline.jump(player, key, keyState)  
	if not deadlineBindsActive then return end
	if not isActivePlayer( player ) then return end
	local veh = g_CurrentRaceMode.getPlayerVehicle(player)

	if not g_CurrentRaceMode:checkAndSetJumpCooldown(player,'jump') then return end
	-- outputDebugString('Shooter ' .. 'jump ' .. getPlayerName(player)) 
	clientCall(player, 'deadlineJump')
	-- clientCall(player, 'dl_cd_handler', 'jump')

	
end

function Deadline:checkAndSetJumpCooldown ( player,boostOrJump )
	-- if (getTickCount() > self.cooldowns[player].jump) then
	-- 	self.cooldowns[player].jump = getTickCount() + 50
	-- 	return true
	-- else
	-- 	return false
	-- end
	
	local action = false
	if boostOrJump == "jump" then
		action = 'deadline.jumpOnCooldown'
	elseif boostOrJump == "boost" then
		action = 'deadline.boostOnCooldown'
	else 
		return false
	end

	local canDo = getElementData( player, action)

	if canDo then
		return false
	else
		return true
	end

end


function Deadline:handleFinishActivePlayer(player)
		

	local timePassed = self:getTimePassed()
	-- self.rankingBoard:add(player, timePassed)
	-- Do remove
	local rank = self:getPlayerRank(player)
	finishActivePlayer(player)
	if rank and rank > 1 then
		triggerEvent( "onPlayerFinishDeadline",player,tonumber( rank ),timePassed )
	end
	-- Update ranking board if one player left
	local activePlayers = getActivePlayers()

	if #activePlayers == 1 then
		-- self.rankingBoard:add(activePlayers[1], timePassed)
		showMessage(getPlayerName(activePlayers[1]) .. ' is the final survivor!', 0, 255, 0)
		triggerEvent( "onPlayerWinDeadline",activePlayers[1],1,timePassed )
	end

end
addEvent('onPlayerFinishDeadline')
addEvent('onPlayerWinDeadline')


function Deadline:cleanup()
	clientCall(g_Root, 'Deadline.unload')
	deadlineBindsActive = false
	deadlineDrawLines = false

	for i, t in ipairs(deadlineActivationTimer) do

		if isTimer( t ) then
			killTimer( t )
		end
	end
	deadlineActivationTimer = {}

	-- Remove binds
	for k, v in ipairs(getElementsByType'player') do
		removeElementData( player, 'deadline.jumpOnCooldown' )
		removeElementData( player, 'deadline.boostOnCooldown' )
		
		if isKeyBound(v, 'vehicle_fire', 'down', self.boost) then
			unbindKey(v, 'vehicle_fire', 'both', self.boost)
		end
		if isKeyBound(v, 'vehicle_secondary_fire', 'down', self.jump) then
			unbindKey(v, 'vehicle_secondary_fire', 'both', self.jump)
		end
		if isKeyBound(v, 'mouse2', 'down', self.jump) then
			unbindKey(v, 'mouse2', 'both', self.jump)
		end
	end
end

function Deadline:endMap()
	Deadline:cleanup()
	RaceMode.endMap(self)
end

function Deadline:destroy()

	if self.rankingBoard then
		self.rankingBoard:destroy()
		self.rankingBoard = nil
	end
	self:cleanup()
	RaceMode.destroy(self)
end


Deadline.modeOptions = {
	duration = 5 * 60 * 1000,
	respawn = 'none',
	autopimp = false,
	autopimp_map_can_override = false,
	vehicleweapons = false,
	vehicleweapons_map_can_override = false,
	hunterminigun = false,
	hunterminigun_map_can_override = false,
	ghostmode = false,
	ghostmode_map_can_override = false,
}





addEvent( 'deadlineShouldDrawLines' ,true)
function deadlineHandleLateJoiners()
	triggerClientEvent(client,'clientShouldDrawLines',client,deadlineDrawLines,DeadlineOptions)
end
addEventHandler( 'deadlineShouldDrawLines',getRootElement(),deadlineHandleLateJoiners )


addEvent( 'onPlayerDeadlineWasted' ,true)
function deadlineClientPlayerKillDetection(killer)
	local victim = source
	-- outputChatBox("Notify Dead: Victim: "..type(victim)..' killer: '..type(killer))
	-- outputChatBox('Victim: '..getPlayerName( victim ))
	-- outputChatBox('Killer: '..getPlayerName(killer))
	-- outputChatBox(victimName..' is killed by '..killerName)
	-- triggerEvent( 'onDeadlinePlayerKill', killer)
	triggerEvent('deadlineKill',victim,killer)
	

end
addEventHandler( 'onPlayerDeadlineWasted',getRootElement(),deadlineClientPlayerKillDetection )

function Deadline.admincommands (playerSource, commandName, option, value)
	-- Deadline.receiveNewSettings
	local accountName = getAccountName(getPlayerAccount( playerSource ) )
	if isObjectInACLGroup( "user."..accountName, aclGetGroup('Developer') ) then
	-- if ( hasObjectPermissionTo ( playerSource, "function.kickPlayer", false ) ) then
		-- outputChatBox( 'commandName: '..tostring(commandName)..' - option: '..tostring(option)..' - value: '..tostring(value) )

		if option == 'help' then
			outputChatBox('Read console (f8) for full list of deadline admin commands',playerSource)
			outputConsole( '-----DEADLINE ADMIN OPTION COMMANDS----',playerSource )
			outputConsole( '/deadline setlinesize x - default 40',playerSource )
			outputConsole( '/deadline setminspeed x - default 60',playerSource )
			outputConsole('/deadline setboostspeed x - default 100',playerSource)
			outputConsole('/deadline setboostcooldown x - default 35000',playerSource)
			outputConsole('/deadline jumpheight x - default 0.25',playerSource)
			outputConsole('/deadline jumpcooldown x - default 15000',playerSource)
			outputConsole('/deadline godmode true/false - default true',playerSource)
			outputConsole('/deadline linealivetime x - default 2500',playerSource)
			outputConsole('/deadline help - list all commands',playerSource)
			outputConsole('/deadline reset - reset all options to default',playerSource)
			outputConsole( '-----DEADLINE ADMIN OPTION COMMANDS----',playerSource )
		elseif option == 'reset' then
			outputChatBox(getPlayerName( playerSource )..' has reset all DeadLine options to default')
			DeadlineOptions = DeadlineOptionsDefaults
			clientCall(getRootElement(), 'Deadline.receiveNewSettings', DeadlineOptions)

		elseif option == 'setlinesize' then
			if not tonumber(value) then return end
			outputChatBox( getPlayerName(playerSource)..' set DeadLine Size from '..DeadlineOptions.size..' to '..value)
			DeadlineOptions.size = tonumber(value)
			clientCall(getRootElement(), 'Deadline.receiveNewSettings', DeadlineOptions)

		elseif option == 'setminspeed' then
			if not tonumber(value) then return end
			outputChatBox( getPlayerName(playerSource)..' set DeadLine Minimum Speed from '..DeadlineOptions.minimumSpeed..' to '..value..'km/h')
			DeadlineOptions.minimumSpeed = tonumber(value)
			clientCall(getRootElement(), 'Deadline.receiveNewSettings', DeadlineOptions)
		elseif option == 'setboostspeed' then
			if not tonumber(value) then return end
			outputChatBox( getPlayerName(playerSource)..' set DeadLine Boost Speed from'..DeadlineOptions.boostSpeed..' to '..value..'km/h')
			DeadlineOptions.boostSpeed = tonumber(value)
			clientCall(getRootElement(), 'Deadline.receiveNewSettings', DeadlineOptions)
		elseif option == 'setboostcooldown' then
			if not tonumber(value) then return end
			outputChatBox( getPlayerName(playerSource)..' set DeadLine Boost Cooldown from '..DeadlineOptions.boost_cooldown..' to '..value..'km/h')
			DeadlineOptions.boost_cooldown = tonumber(value)
			clientCall(getRootElement(), 'Deadline.receiveNewSettings', DeadlineOptions)
		elseif option == 'jumpheight' then
			if not tonumber(value) then return end
			outputChatBox( getPlayerName(playerSource)..' set DeadLine Jump Height from'..DeadlineOptions.jumpHeight..' to '..value..'')
			DeadlineOptions.jumpHeight = tonumber(value)
			clientCall(getRootElement(), 'Deadline.receiveNewSettings', DeadlineOptions)
		elseif option == 'jumpcooldown' then
			if not tonumber(value) then return end
			outputChatBox( getPlayerName(playerSource)..' set DeadLine Jump Cooldown from'..DeadlineOptions.jump_cooldown..' to '..value..'')
			DeadlineOptions.jump_cooldown = tonumber(value)
			clientCall(getRootElement(), 'Deadline.receiveNewSettings', DeadlineOptions)
		elseif option == 'godmode' then
			if value == 'true' then
				outputChatBox( getPlayerName(playerSource)..' set DeadLine Godmode to true')
				DeadlineOptions.jump_cooldown = true
				clientCall(getRootElement(), 'Deadline.receiveNewSettings', DeadlineOptions)				
			elseif value == 'false' then
				outputChatBox( getPlayerName(playerSource)..' set DeadLine Godmode to fase')
				DeadlineOptions.jump_cooldown = false
				clientCall(getRootElement(), 'Deadline.receiveNewSettings', DeadlineOptions)	
			end
		
		elseif option == 'linealivetime' then
			if not tonumber(value) then return end
			outputChatBox( getPlayerName(playerSource)..' set DeadLine Line Alive Time from'..DeadlineOptions.lineAliveTime..' to '..value..'ms')
			DeadlineOptions.lineAliveTime = tonumber(value)
			clientCall(getRootElement(), 'Deadline.receiveNewSettings', DeadlineOptions)
		end
	end

end
addCommandHandler( 'deadline', Deadline.admincommands )