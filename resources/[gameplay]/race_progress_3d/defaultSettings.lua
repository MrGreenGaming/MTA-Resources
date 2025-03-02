---
-- Defines the default settings for the progress bar
-- which can be changed by each player indivudally via
-- the GUI.
--
-- @author	driver2
-- @copyright	2009-2010 driver2
--
-- Recent changes:
-- 2010-02-09: Added toggleSettingsGuiKey, commented out unused settings

defaultSettings = {
	["enabled"] = true,
	["size"] = 0.33,
	-- ["fontSize"] = 1,
	-- ["fontType"] = "clear",
	["top"] = 0.33,
	["left"] = 0.03,
	["debug"] = false,
	["updateinterval"] = 0.2,

	["lineColorRed"] = 255,
	["lineColorGreen"] = 255,
	["lineColorBlue"] = 255,
	["lineColorAlpha"] = 200,

	["shadowColorRed"] = 40,
	["shadowColorGreen"] = 40,
	["shadowColorBlue"] = 40,
	["shadowColorAlpha"] = 180,

	-- ["fontColorRed"] = 255,
	-- ["fontColorGreen"] = 255,
	-- ["fontColorBlue"] = 255,
	-- ["fontColorAlpha"] = 255,

	-- ["backgroundColorRed"] = 40,
	-- ["backgroundColorGreen"] = 40,
	-- ["backgroundColorBlue"] = 40,
	-- ["backgroundColorAlpha"] = 180,

	["showInfo"] = true,
	["preferNear"] = false,
	["sortMode"] = "length",
}


-- Other settings

toggleSettingsGuiKey = "F6"
