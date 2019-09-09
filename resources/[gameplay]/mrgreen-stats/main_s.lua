--------------------------------------------------
-- Add stats to the appropriate event functions --
--------------------------------------------------

-- saveStat(forumid, category, statName, statValue, isIncrement)
-- isPlayerAway()
local currentRaceState = false
function raceStateChanged(old, new)
    currentRaceState = new
end
addEvent('onRaceStateChanging')
addEventHandler('onRaceStateChanging', root, raceStateChanged)

-------------
-- General --
-------------
function playerReachedCheckpoint()
    local id = getPlayerID(source)
    if not id then return end
    saveStat(id, 'General', 'Total Checkpoints', 1, true)
end
addEvent('onPlayerReachCheckpoint')
addEventHandler('onPlayerReachCheckpoint', root, playerReachedCheckpoint)

function playerFinished(rank)
    local id = getPlayerID(source)
    if not id then return end
    local modename = exports.race:getRaceMode()
    if modename == "Sprint" then 
        saveStat(id, 'Race', 'Finishes', 1, true)
        if rank == 1 then
            saveStat(id, 'Race', 'Wins', 1, true)
            saveStat(id, 'General', 'Total Wins', 1, true)
        end
    elseif modename == "Never the same" then 
        saveStat(id, 'Never The Same', 'Finishes', 1, true)
        if rank == 1 then
            saveStat(id, 'Never The Same', 'Wins', 1, true)
            saveStat(id, 'General', 'Total Wins', 1, true)
        end
    elseif modename == "Reach the flag" then 
        saveStat(id, 'Reach The Flag', 'Wins', 1, true)
        saveStat(id, 'General', 'Total Wins', 1, true)
    end
end
addEvent('onPlayerFinish')
addEventHandler('onPlayerFinish', root, playerFinished)

function notifiedPlayerReady()
    local id = getPlayerID(source)
    if not id or isPlayerAway(source) then return end
    local modename = exports.race:getRaceMode()
    if modename == 'Sprint' then
        saveStat(id, 'Race', 'Starts', 1, true)
    elseif modename == 'Never the same' then
        saveStat(id, 'Never The Same', 'Starts', 1, true)
    elseif modename == 'Reach the flag' then
        saveStat(id, 'Reach The Flag', 'Starts', 1, true)
    end
end
addEvent('onNotifyPlayerReady')
addEventHandler('onNotifyPlayerReady', root, notifiedPlayerReady)

function playerWasted()
    local id = getPlayerID(source)
    if not id then return end
    if not isPlayerAway(source) then
        saveStat(id, 'General', 'Total Deaths', 1, true)
    end
end
addEvent('onPlayerWasted')
addEventHandler('onPlayerWasted', root, playerWasted)

local playTimeLastTick = {
    -- TABLE STRUCTURE
    -- [id] = getTickCount()
}
function savePlayTime()
    -- Playtime will be saved in seconds instead of ms
    for id, tick in pairs(playTimeLastTick) do
        local diff = math.ceil((getTickCount() - tick)/1000)
        saveStat(id, 'General', 'Playtime', diff, true)
        playTimeLastTick[id] = getTickCount()
    end
end
-- Save every x ms
setTimer(savePlayTime, 60000, 0)

function setPlayTimeTick(id)
    playTimeLastTick[id] = getTickCount()
end
addEvent('onPlayerStatsLoaded')
addEventHandler('onPlayerStatsLoaded', resourceRoot, setPlayTimeTick)

function removePlayTimeTick(id)
    playTimeLastTick[id] = nil
end
addEvent('onGCLogout')
addEventHandler( 'onGCLogout', root, removePlayTimeTick)

-----------------------
-- Capture The Flag  --
-----------------------
function playerFlagDeliveredCTF(old, new)
    local id = getPlayerID(source)
    if not id then return end
    saveStat(id, 'Capture The Flag', 'Flags Delivered', 1, true)
end
addEvent('onCTFFlagDelivered')
addEventHandler('onCTFFlagDelivered', root, playerFlagDeliveredCTF)

-----------------------
-- Destruction Derby --
-----------------------
function playerFinishedDD(old, new)
    local id = getPlayerID(source)
    if not id or isPlayerAway(source) then return end
    saveStat(id, 'Destruction Derby', 'Deaths', 1, true)
end
addEvent('onPlayerFinishDD')
addEventHandler('onPlayerFinishDD', root, playerFinishedDD)

function playerWinDD(old, new)
    local id = getPlayerID(source)
    if not id or isPlayerAway(source) then return end
    saveStat(id, 'Destruction Derby', 'Wins', 1, true)
    saveStat(id, 'General', 'Total Wins', 1, true)
end
addEvent('onPlayerWinDD')
addEventHandler('onPlayerWinDD', root, playerWinDD)

function playerKillDD(old, new)
    local id = getPlayerID(source)
    if not id or isPlayerAway(source) then return end
    saveStat(id, 'Destruction Derby', 'Kills', 1, true)
end
addEvent('onDDPlayerKill')
addEventHandler('onDDPlayerKill', root, playerKillDD)

-----------------------
--      Shooter      --
-----------------------
function playerFinishedShooter(old, new)
    local id = getPlayerID(source)
    if not id or isPlayerAway(source) then return end
    saveStat(id, 'Shooter', 'Deaths', 1, true)
end
addEvent('onPlayerFinishShooter')
addEventHandler('onPlayerFinishShooter', root, playerFinishedShooter)

function playerWinShooter(old, new)
    local id = getPlayerID(source)
    if not id or isPlayerAway(source) then return end
    saveStat(id, 'Shooter', 'Wins', 1, true)
    saveStat(id, 'General', 'Total Wins', 1, true)
end
addEvent('onPlayerWinShooter')
addEventHandler('onPlayerWinShooter', root, playerWinShooter)

function playerKillShooter(old, new)
    local id = getPlayerID(source)
    if not id or isPlayerAway(source) then return end
    saveStat(id, 'Shooter', 'Kills', 1, true)
end
addEvent('onShooterPlayerKill')
addEventHandler('onShooterPlayerKill', root, playerKillShooter)

-----------------------
--      DeadLine     --
-----------------------
function playerFinishedDeadline(old, new)
    local id = getPlayerID(source)
    if not id or isPlayerAway(source) then return end
    saveStat(id, 'DeadLine', 'Deaths', 1, true)
end
addEvent('onPlayerFinishDeadline')
addEventHandler('onPlayerFinishDeadline', root, playerFinishedDeadline)

function playerWinDeadline(old, new)
    local id = getPlayerID(source)
    if not id or isPlayerAway(source) then return end
    saveStat(id, 'DeadLine', 'Wins', 1, true)
    saveStat(id, 'General', 'Total Wins', 1, true)
end
addEvent('onPlayerWinDeadline')
addEventHandler('onPlayerWinDeadline', root, playerWinDeadline)

function playerKillDeadline(old, new)
    local id = getPlayerID(source)
    if not id or isPlayerAway(source) then return end
    saveStat(id, 'DeadLine', 'Kills', 1, true)
end
addEvent('onDeadlinePlayerKill')
addEventHandler('onDeadlinePlayerKill', root, playerKillDeadline)

