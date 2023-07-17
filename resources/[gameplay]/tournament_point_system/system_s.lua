Tournament = {
	currentGamemode = "",
	playerPoints = {},
	ddKill = tonumber(get("ddKill")),
	shooterKill = tonumber(get("shooterKill")),
	chatPrefix = '#1FB907[Tournament]#FFFFFF ',
}

exports.scoreboard:addScoreboardColumn('TourPoints', 'userdata', 80, 'TourPoints', MAX_PRIRORITY_SLOT)

for _, pl in ipairs(getElementsByType('player')) do
	setElementData(pl, 'TourPoints', 0)
end

function onMapChange()
	Tournament.currentGamemode = exports.race:getRaceMode();
    logCurrentGamemodeInfo();
end
addEventHandler("onMapStarting", root, onMapChange)

function onPlayerJoin()
	for i, line in ipairs(Tournament.playerPoints) do
		if line["serial"] == getPlayerSerial(source) then
			local points = line["points"]
			setElementData(source, "TourPoints", points, true)
			outputChatBox(Tournament.chatPrefix .. "You currently have " .. points .. " points!", source, 255, 255, 255, true)
			return
		end
	end
	setElementData(source, "TourPoints", 0)
end
addEventHandler("onPlayerJoin", root, onPlayerJoin)

function OnPlayerChangeNick(oldNick, newNick)
	for i, line in ipairs(Tournament.playerPoints) do
		if line["serial"] == getPlayerSerial(source) then
			line["nickname"] = newNick
		end
	end
end
addEventHandler("onPlayerChangeNick", root, OnPlayerChangeNick)

