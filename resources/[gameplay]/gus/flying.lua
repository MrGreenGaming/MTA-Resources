-- This script automatically bans players if they are assumed using fly hacks.
-- Percentages are used of all finished players. The two highest airborne percentages are compared.
-- If the difference is 60% or more, the player with the highest percentage is banned for 15 minutes. (This likely using fly hacks.)

-- VulpyWags: 15/20 checkpoints airborne = 75%
-- OtherPlay: 2/20 checkpoints airborne = 10%
-- Difference is 65% (75% - 10%) -> VulpyWags gets temp banned for 15 minutes.

-- Does not track:
-- Coremarkers maps
-- Helicopters and planes
-- Maps with less than 5 checkpoints
-- Needs at least 2 finished players to compare percentages

local cpInfo = {}

addEventHandler("onPlayerReachCheckpoint", root, function(cp)
	local vehicle = getPedOccupiedVehicle(source)
	if not vehicle then return end

	if getVehicleType(vehicle) == "Helicopter" or getVehicleType(vehicle) == "Plane" or getVehicleType(vehicle) == "Boat" then
		return
	end

	local isInAir = not isVehicleOnGround(vehicle)

	cpInfo[source] = cpInfo[source] or {}
	cpInfo[source][cp] = isInAir
end)

addEventHandler("onPostFinish", root, function()
	if getResourceFromName("coremarkers") and getResourceState(getResourceFromName("coremarkers")) == "running" then
		cpInfo = {}
		return
	end

	local finishedPlayers = {}
	for _, player in ipairs(getElementsByType("player")) do
		if getElementData(player, "race.finished") then
			table.insert(finishedPlayers, player)
		end
	end

	local flyingPercentages = {}

	for _, player in pairs(finishedPlayers) do
		local totalCheckpoints = 0
		local flyingCount = 0

		if (cpInfo[player] == nil) then
			cpInfo[player] = {}
		end
		for _, wasFlying in pairs(cpInfo[player]) do
			totalCheckpoints = totalCheckpoints + 1
			if wasFlying then
				flyingCount = flyingCount + 1
			end
		end

		if (totalCheckpoints >= 5) then
			local flyingPercentage = flyingCount / totalCheckpoints
			flyingPercentages[player] = flyingPercentage
		end

	end

	if (#finishedPlayers <= 1) then
		if #finishedPlayers == 1 then
			for player, percent in pairs(flyingPercentages) do
				if percent >= 0.6 and isElement(player) and getResourceFromName("discord") and getResourceState(getResourceFromName("discord")) == "running" then
					exports.discord:send("admin.log", {
						log = getPlayerName(player) .. " has finished the map with " ..
								math.floor(percent * 100) ..
								"% airborne.\nNo other players finished the map to compare. Can't determine if cheating.\nSerial: " ..
								getPlayerSerial(player)
					})
				end
			end
		end
	else
		local topPlayer = nil
		local topPercent = -1
		local secondTopPercent = -1

		for player, percent in pairs(flyingPercentages) do
			if percent > topPercent then
				secondTopPercent = topPercent
				topPercent = percent
				topPlayer = player
			elseif percent > secondTopPercent then
				secondTopPercent = percent
			end
		end

		local diff = topPercent - secondTopPercent

		if diff >= 0.60 and isElement(topPlayer) then
			if getResourceFromName("discord") and getResourceState(getResourceFromName("discord")) == "running" then
				exports.discord:send("admin.log", {
					log = getPlayerName(topPlayer) .. " has been banned (15 minutes) by VulpyScript for flying " ..
							math.floor(topPercent * 100) .. "% of the time.\nSerial: " .. getPlayerSerial(topPlayer)
				})
			end

			banPlayer(topPlayer, true, false, true, "VulpyScript",
				"Suspicious activity. Contact VulpyWags or appeal if false positive.", 900)
		end
	end

	cpInfo = {}
end)
