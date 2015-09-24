Freeroam = setmetatable({}, RaceMode)
Freeroam.__index = Freeroam

Freeroam:register('Freeroam')

function Freeroam:isApplicable()
	return not self.checkpointsExist() and self.getMapOption('respawn') == 'timelimit'
end

function Freeroam:isRanked()
	return false
end

function Freeroam:pickFreeSpawnpoint(ignore)
	local i = table.find(self.getSpawnpoints(), 'used', '[nil]')
	if i then
		repeat
			i = math.random(self.getNumberOfSpawnpoints())
		until not self.getSpawnpoint(i).used
	else
		i = math.random(self.getNumberOfSpawnpoints())
	end
	local spawnpoint = self.getSpawnpoint(i)
	spawnpoint.used = true
	if self.startTick then
		TimerManager.createTimerFor("map"):setTimer(freeSpawnpoint, 2000, 1, self, i)
	end
	return spawnpoint
end