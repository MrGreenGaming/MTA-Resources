--This file is responsible for updating the Mix Stats. They are all defaulted to 0 from default_stats.lua

function onPlayerFinish( rank, time )
	local modename = exports.race:getRaceMode()
	if modename == "Never the same" then 
		if rank == 1 then
			-- outputDebugString("stats +1 nts_wins " .. getPlayerName(source))
			dbExec(database, "UPDATE stats_mix SET nts_wins = IFNULL ( nts_wins, 0 ) + 1 WHERE playerName = ?", getPlayerName(source))
		end
	elseif modename == "Reach the flag" then
		-- outputDebugString("stats +1 rtf_flags " .. getPlayerName(source))
		dbExec(database, "UPDATE stats_mix SET rtf_flags = IFNULL ( rtf_flags, 0 ) + 1 WHERE playerName = ?", getPlayerName(source))
	elseif modename == "Sprint" then
		if rank == 1 then
			-- outputDebugString("stats +1 sprint_wins " .. getPlayerName(source))
			dbExec(database, "UPDATE stats_mix SET sprint_wins = IFNULL ( sprint_wins, 0 ) + 1 WHERE playerName = ?", getPlayerName(source))
		end
	end		
end
addEventHandler("onPlayerFinish", root, onPlayerFinish)


function ddFinish(rank)
	-- outputDebugString("stats +1 dd_deaths " .. getPlayerName(source))
    dbExec(database, "UPDATE stats_mix SET dd_deaths = IFNULL ( dd_deaths, 0 ) + 1 WHERE playerName = ?", getPlayerName(source))
end
addEvent('onPlayerFinishDD')
addEventHandler('onPlayerFinishDD', root, ddFinish)

function ddWin()
	-- outputDebugString("stats +1 dd_wins " .. getPlayerName(source))
    dbExec(database, "UPDATE stats_mix SET dd_wins = IFNULL ( dd_wins, 0 ) + 1 WHERE playerName = ?", getPlayerName(source))
end
addEvent('onPlayerWinDD')
addEventHandler('onPlayerWinDD', root, ddWin)

function onDDPlayerKill()
	-- outputDebugString("stats +1 dd_kills " .. getPlayerName(source))
    dbExec(database, "UPDATE stats_mix SET dd_kills = IFNULL ( dd_kills, 0 ) + 1 WHERE playerName = ?", getPlayerName(source))
end
addEvent('onDDPlayerKill')
addEventHandler('onDDPlayerKill', root, onDDPlayerKill)


function CTFFlagDelivered()
	-- outputDebugString("stats +1 ctf_delivered " .. getPlayerName(source))
    dbExec(database, "UPDATE stats_mix SET ctf_delivered = IFNULL ( ctf_delivered, 0 ) + 1 WHERE playerName = ?", getPlayerName(source))
end
addEventHandler('onCTFFlagDelivered', root, CTFFlagDelivered)


function ShooterFinish(rank)
	-- outputDebugString("stats +1 shooter_deaths " .. getPlayerName(source))
    dbExec(database, "UPDATE stats_mix SET shooter_deaths = IFNULL ( shooter_deaths, 0 ) + 1 WHERE playerName = ?", getPlayerName(source))
end
addEvent('onPlayerFinishShooter')
addEventHandler('onPlayerFinishShooter', root, ShooterFinish)

function ShooterWin()
	-- outputDebugString("stats +1 shooter_wins " .. getPlayerName(source))
    dbExec(database, "UPDATE stats_mix SET shooter_wins = IFNULL ( shooter_wins, 0 ) + 1 WHERE playerName = ?", getPlayerName(source))
end
addEvent('onPlayerWinShooter')
addEventHandler('onPlayerWinShooter', root, ShooterWin)

function onShooterPlayerKill()
	-- outputDebugString("stats +1 shooter_kills " .. getPlayerName(source))
    dbExec(database, "UPDATE stats_mix SET shooter_kills = IFNULL ( shooter_kills, 0 ) + 1 WHERE playerName = ?", getPlayerName(source))
end
addEvent('onShooterPlayerKill')
addEventHandler('onShooterPlayerKill', root, onShooterPlayerKill)


addEvent('onPlayerVictimDeath', true)
addEventHandler('onPlayerVictimDeath', root,
function()
    dbExec(database, "UPDATE stats_mix SET mh_victim_deaths = IFNULL ( mh_victim_deaths, 0 ) + 1 WHERE playerName = ?", getPlayerName(source))
end
)

addEvent('onPlayerVictimBecome', true)
addEventHandler('onPlayerVictimBecome', root,
function()
    dbExec(database, "UPDATE stats_mix SET mh_victim_become = IFNULL ( mh_victim_become, 0 ) + 1 WHERE playerName = ?", getPlayerName(source))
end
)
