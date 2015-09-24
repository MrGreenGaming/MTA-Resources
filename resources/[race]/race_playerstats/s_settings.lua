--
-- SETTINGS
--

local function getString(var, default)
	local result = get(var)
	if not result then return default end
	return tostring(result)
end

local function getNumber(var, default)
	local result = get(var)
	if not result then return default end
	return tonumber(result)
end

local function getBool(var, default)
	local result = get(var)
	if not result then return default end
	if tostring(result) == 'false' then return false end
	return result or tostring(result) == 'true'
end



Settings = {
	["welcomeMessage"] = {
		dataType = getString,
		defaultValue = nil
	},
	["messageColor"] = {
		dataType = getString,
		defaultValue = "#FFF7A0"
	},
	["showStatsOnMapFinish"] = {
		dataType = getBool,
		defaultValue = false
	},
	["countMidraceJoinAsRacestart"] = {
		dataType = getBool,
		defaultValue = true
	},
	["countPostFinishDeath"] = {
		dataType = getBool,
		defaultValue = true
	},
	["vehicleWreckHealthLimit"] = {
		dataType = getNumber,
		defaultValue = 250
	}
}

function cacheResourceSettings()
	for name,setting in pairs(Settings) do
		local getter = setting.dataType or getString
		setting.value = getter(name, setting.defaultValue)
	end
end


addEventHandler("onResourceStart", resourceRoot, 
	function()
		cacheResourceSettings()
	end
)


addEvent("onSettingChange")
addEventHandler("onSettingChange", resourceRoot,
	function()
		cacheResourceSettings()
	end
)





--
-- DEBUG
-- 

function alert(message, channel, recipient)
	local prefix = getResourceInfo(resource, "name") or g_ResName
	local text = string.format("[%s] %s", prefix, message)

	if channel == "console" then
		outputConsole(text)
		return
	end
	
	if channel == "chat" then
		recipient = recipient or root
		local messageColor = tostring(Settings["messageColor"].value or "")
		text = string.format("#A0FFA0[%s] %s%s", prefix, messageColor, message)
		outputChatBox(text, recipient, 255, 255, 255, true)
		return
	end
	-- outputDebugString(text)
	
end
