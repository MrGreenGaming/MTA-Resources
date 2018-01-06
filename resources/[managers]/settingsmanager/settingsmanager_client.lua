function saveSetting(settingName, settingValue, resName)
	local settingsXML = xmlLoadFile("@settings.xml") or xmlCreateFile("@settings.xml", "settings")
	if not settingsXML then return false end
	
	local resourceName = resName or getResourceName(sourceResource)
	local resourceNode = xmlFindChild(settingsXML, resourceName, 0) or xmlCreateChild(settingsXML, resourceName)
	local settingsNode = xmlFindChild(resourceNode, settingName, 0) or xmlCreateChild(resourceNode, settingName)

	if xmlNodeSetValue( settingsNode, tostring(settingValue) ) and xmlSaveFile(settingsXML) then 
		xmlUnloadFile(settingsXML) 
		return true	
	else
		xmlUnloadFile(settingsXML) 
		return false
	end
end

function loadSetting(settingName, resName)
	local settingsXML = xmlLoadFile("@settings.xml") or xmlCreateFile("@settings.xml", "settings")
	if not settingsXML then return nil end
	
	local resourceName = resName or getResourceName(sourceResource)
	local resourceNode = xmlFindChild(settingsXML, resourceName, 0)
	local settingsNode = resourceNode and xmlFindChild(resourceNode, settingName, 0)
	local settingValue = settingsNode and xmlNodeGetValue(settingsNode)
	
	xmlUnloadFile(settingsXML)
	return convertValue(settingValue) --converts string to a bool or returns string untouched if it isn't a bool
end

function convertValue(value)
	if value == "true" then
		return true
	elseif value == "false" then
		return false
	elseif value then
		return value
	elseif not value then
		return nil 
	end
end