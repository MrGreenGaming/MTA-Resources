local glitchesData = {
	["vehicle_rapid_stop"] = true,
}

local function toggleGlitches()
	for glitchName, glitchState in pairs(glitchesData) do
		if setGlitchEnabled(glitchName, glitchState) then
			if glitchState then
				outputDebugString("Glitch '" .. glitchName .. "' has been enabled.")
			else
				outputDebugString("Glitch '" .. glitchName .. "' has been disabled.")
			end
		else
			outputDebugString("Failed to set glitch '" .. glitchName .. "' to " .. tostring(glitchState) .. ".")
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, toggleGlitches)
