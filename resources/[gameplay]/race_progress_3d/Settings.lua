---
-- Class to manage settings, which can be used in other scripts.
--
-- @author	driver2
-- @copyright	2009 driver2
--
-- Changes:
-- 2010-01-30: Commented functions and cleaned up a bit



Settings = {}

---
-- Creates a new object with the default settings and
-- the filename.
--
-- @param   table   defaultSettings: A table with the default settings
-- @param   string  filename: The xml file to save the settings to
function Settings:new(defaultSettings,filename)
	local object = {}
	setmetatable(object,self)
	self.__index = self
	object.settingsXml = Xml:new(filename,"settings")
	object.settings = {}
	object.settings.default = defaultSettings
	return object
end

---
-- Change a setting to a new value.
--
-- @param   string   settings: The name of the setting
-- @param   mixed    value: The value of the setting (should be something that can be saved
-- 				as a string
-- @param   string   settingType (optional, defaults to "main"): The type of the setting
function Settings:set(setting,value,settingType)
	-- Set default type if parameter was omitted
	if settingType == nil then
		settingType = "main"
	end

	-- Retrieve the datatype of the setting by the default setting
	local defaultType = type(self.settings.default[setting])
	-- Convert according to datatype
	if defaultType == "string" then
		value = tostring(value)
	elseif defaultType == "number" then
		value = tonumber(value)
	elseif defaultType == "boolean" then
		value = toboolean(value)
	end
	-- If table for this settingtype doesnt exist, create it
	if self.settings[settingType] == nil then
		self.settings[settingType] = {}
	end
	-- Set new value to setting
	self.settings[settingType][setting] = value
end
---
-- Load settings of this setting type from the XML file
--
-- @param   string   settingType (optional, defaults to "main"): The setting type
function Settings:loadFromXml(settingType)
	-- Set default type if parameter was omitted
	if settingType == nil then
		settingType = "main"
	end
	self.settingsXml:open()

	-- Loop through default settings and read the values
	for k,v in pairs(self.settings.default) do
		local value = self.settingsXml:getAttribute("root",k)
		if value ~= false and value ~= "" then
			self:set(k,value,settingType)
		else
			self:set(k,v,settingType)
		end
	end
	self.settingsXml:unload()
end

---
-- Save the settings of this setting type to the XML file
--
-- @param   string   setting (optional, defaults to nil): The name of the setting
-- 			to save (if omitted, it will save all settings)
-- @param   string   settingType (optional, defaults to "main"): The setting type
function Settings:saveToXml(setting,settingType)
	if settingType == nil then
		settingType = "main"
	end
	self.settingsXml:open()

	-- Loop through all settings of this type and save them if
	-- they are equal to the setting or if setting is nil.
	for k,v in pairs(self.settings[settingType]) do
		if setting == nil or setting == k then
			self.settingsXml:setAttribute("root",k,v)
		end
	end
	self.settingsXml:save()
	self.settingsXml:unload()
end

---
-- Gets a single setting.
--
-- @param   string   setting: The name of the setting
-- @param   string   settingType (optional): The type of the setting (default: "main")
function Settings:get(setting,settingType)
	-- Retrieve datatype from default settings
	datatype = type(self.settings.default[setting])
	-- Set default settingtype if parameter was omitted
	if settingType == nil then
		settingType = "main"
	end
	local value = nil
	-- Get the setting from this setting type if it exists
	if (self.settings[settingType] ~= nil) then
		value = self.settings[settingType][setting]
	end
	
	-- If the datatype of the retrieved value matches the default datatype, everything is ok
	if type(value) == datatype then
		return value
	end
	-- If not, return the default value
	return self.settings.default[setting]
end
