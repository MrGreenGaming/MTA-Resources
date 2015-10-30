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
	["enabled"] = false,
	["drawDistance"] = true,
	["drawDelay"] = true,
	["mode"] = "km",
	["size"] = 0.45,
	["fontSize"] = 1,
	["fontType"] = "clear",
	["top"] = 0.15,
	["left"] = 0.98,
	["roundCorners"] = true,

	["barColorRed"] = 0,
	["barColorGreen"] = 0,
	["barColorBlue"] = 0,
	["barColorAlpha"] = 80,

	["progressColorRed"] = 255,
	["progressColorGreen"] = 200,
	["progressColorBlue"] = 120,
	["progressColorAlpha"] = 80,

	["fontColorRed"] = 255,
	["fontColorGreen"] = 255,
	["fontColorBlue"] = 255,
	["fontColorAlpha"] = 255,

	["font2ColorRed"] = 255,
	["font2ColorGreen"] = 200,
	["font2ColorBlue"] = 120,
	["font2ColorAlpha"] = 255,

	["backgroundColorRed"] = 40,
	["backgroundColorGreen"] = 40,
	["backgroundColorBlue"] = 40,
	["backgroundColorAlpha"] = 180,

	["background2ColorRed"] = 40,
	["background2ColorGreen"] = 40,
	["background2ColorBlue"] = 40,
	["background2ColorAlpha"] = 180,

	["fontDelayColorRed"] = 255,
	["fontDelayColorGreen"] = 255,
	["fontDelayColorBlue"] = 255,
	["fontDelayColorAlpha"] = 255,

	["backgroundDelayColorRed"] = 69,
	["backgroundDelayColorGreen"] = 89,
	["backgroundDelayColorBlue"] = 252,
	["backgroundDelayColorAlpha"] = 180,

	["showInfo"] = true,
	--["shufflePlayers"] = false,
	--["sortByLength"] = true,
	["preferNear"] = false,
	["sortMode"] = "length"
}


-- Other settings

toggleSettingsGuiKey = "F7"
