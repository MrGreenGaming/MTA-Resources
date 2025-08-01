local glitchesData = {
	["vehicle_rapid_stop"] = true,
}

local function toggleGlitches()
	for glitchName, glitchState in pairs(glitchesData) do
		setGlitchEnabled(glitchName, glitchState)
	end
end
addEventHandler("onResourceStart", resourceRoot, toggleGlitches)