function setLocalData(key, value)
	local key = tostring(key)
	local value = tostring(value)
	local file = xmlLoadFile("settings.xml") or xmlCreateFile("settings.xml", "settings")
	
	if not file or not key or not value then 
		return false 
	end
	
	local resourceName = getResourceName(sourceResource)
	local resource = xmlFindChild(file, resourceName, 0) or xmlCreateChild(file, resourceName)
	local setting = xmlFindChild(resource, key, 0) or xmlCreateChild(resource, key)
	local value = xmlNodeSetValue(setting, value)
	
	if value and xmlSaveFile(file) then
		xmlUnloadFile(file)
		return true
	else
		xmlUnloadFile(file)
		return false
	end
end

function getLocalData(key)
	local key = tostring(key)
	local file = xmlLoadFile("settings.xml") or xmlCreateFile("settings.xml", "settings")
	
	if not file or not key then 
		return false 
	end
	
	local resourceName = getResourceName(sourceResource)
	local resource = xmlFindChild(file, resourceName, 0) or xmlCreateChild(file, resourceName)
	local setting = xmlFindChild(resource, key, 0) or xmlCreateChild(resource, key)
	local value = setting and xmlNodeGetValue(setting) or settings[resourceName][key]
	
	if value == "true" then
		xmlUnloadFile(file)
		return true
	elseif value == "false" then
		xmlUnloadFile(file)
		return false
	elseif value then 
		xmlUnloadFile(file)
		return value
	else 
		xmlUnloadFile(file)
		return nil 
	end
end