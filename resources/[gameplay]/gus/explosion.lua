-- Automatically bans players who trigger too many explosions and kills in a short time.
-- 10 explosions and 5 kills in 5 seconds will result in a 15 minute ban.
-- This is likely caused by a malicious player.

local iExplosionCheckInterval = 2000 -- how often to check for illegality in milliseconds
local iCombinedCheckWindow = 5000    -- how far into the past to check for explosions and kills in milliseconds
local iExplosionThreshold = 10
local iKillThreshold = 5

local tblRecentExplosions = {}
local tblRecentKills = {}

function remcol(str)
	return string.gsub(str, '#%x%x%x%x%x%x', '')
end

-- Collect explosions
addEventHandler("onExplosion", root, function()
	if isElement(source) and getElementType(source) == "player" then
		tblRecentExplosions[source] = tblRecentExplosions[source] or {}
		table.insert(tblRecentExplosions[source], getTickCount())
	end
end)

-- Collect kills
addEventHandler("onPlayerWasted", root, function(_, killer)
	table.insert(tblRecentKills, getTickCount())
end)

-- The actual check for illegality
setTimer(function()
	local now = getTickCount()

	for player, explosions in pairs(tblRecentExplosions) do
		if not isElement(player) then
			tblRecentExplosions[player] = nil
		else
			-- Clean old explosion timestamps
			local validExplosions = {}
			for _, t in ipairs(explosions) do
				if now - t <= iCombinedCheckWindow then
					table.insert(validExplosions, t)
				end
			end
			tblRecentExplosions[player] = validExplosions

			-- Clean old kill timestamps
			local kills = tblRecentKills or {}
			local validKills = {}
			for _, t in ipairs(kills) do
				if now - t <= iCombinedCheckWindow then
					table.insert(validKills, t)
				end
			end
			tblRecentKills = validKills

			if #validExplosions >= iExplosionThreshold then
				exports.discord:send("admin.log", {
					log = remcol(getPlayerName(player)) ..
							" has triggered " .. #validExplosions .. " explosions." ..
							#validKills .. " players died during the same time." ..
							"\nSerial: " .. getPlayerSerial(player)
				})
			end

			-- Check thresholds and ban
			if #validExplosions >= iExplosionThreshold and #validKills >= iKillThreshold then
				local playerName = remcol(getPlayerName(player))
				local serial = getPlayerSerial(player)

				if getResourceFromName('discord') and getResourceState(getResourceFromName('discord')) == 'running' then
					exports.discord:send("admin.log", {
						log = playerName ..
								" has been banned (15 minutes) by VulpyScript for triggering " ..
								#validExplosions ..
								" explosions." ..
								#validKills .. " players died during the same time.\nSerial: " .. serial
					})
				end

				banPlayer(player, true, false, true, "VulpyScript",
					"Suspicious activity. Contact VulpyWags or appeal if false positive.", 900)

				tblRecentExplosions[player] = nil
				tblRecentKills[player] = nil
			end
		end
	end
end, iExplosionCheckInterval, 0)


addEventHandler("onPlayerQuit", root,
	function(quitType)
		tblRecentExplosions[source] = nil
		tblRecentKills[source] = nil
	end
)
