Sprint = setmetatable({}, RaceMode)
Sprint.__index = Sprint

Sprint:register('Sprint')

function Sprint:isApplicable()
	return self.checkpointsExist() -- and self.getMapOption('respawn') == 'timelimit'
end

Sprint.modeOptions = {
	respawn = 'timelimit',
	respawntime = 5,
}