local iInvalidEventThreshold = 5
local iCheckWindow = 5000 -- how far into the past to check for invalid events in milliseconds

local tblRecentInvalidEvents = {}

function remcol(str)
	return string.gsub(str, '#%x%x%x%x%x%x', '')
end

addEventHandler("onPlayerTriggerInvalidEvent", root, function(eventName, isAdded, isRemote)
	if isElement(source) and getElementType(source) == "player" then
		tblRecentInvalidEvents[source] = tblRecentInvalidEvents[source] or {}
		table.insert(tblRecentInvalidEvents[source],
			{ tick = getTickCount(), eventName = eventName, isAdded = isAdded, isRemote = isRemote })
		checkIllegality()
	end
end)

function checkIllegality()
	local now = getTickCount()

	for player, events in pairs(tblRecentInvalidEvents) do
		if not isElement(player) then -- player left
			tblRecentInvalidEvents[player] = nil
		else
			-- Clean old event timestamps
			local invalidEvents = {}
			for _, event in ipairs(events) do
				if now - event.tick <= iCheckWindow then
					table.insert(invalidEvents, event)
				end
			end
			tblRecentInvalidEvents[player] = invalidEvents

			if #invalidEvents >= iInvalidEventThreshold then
				local eventNames = {}
				for _, e in ipairs(invalidEvents) do
					table.insert(eventNames, e.eventName)
				end
				local eventList = table.concat(eventNames, "\n")

				if getResourceFromName("discord") and getResourceState(getResourceFromName("discord")) == "running" then
					exports.discord:send("admin.log", {
						log = remcol(getPlayerName(player)) ..
								"has been **banned (15 minutes) by VulpyScript** for triggering " .. #invalidEvents .. " invalid events.\n"
								.. "Events:\n" .. eventList
					})
				end
				banPlayer(player, true, false, true, "VulpyScript",
					"Suspicious activity. Contact VulpyWags or appeal if false positive", 900)
			end
		end
	end
end
