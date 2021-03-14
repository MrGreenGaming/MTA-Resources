function isEnabledXML()
	local settingsXML = xmlLoadFile("/settings/settings.xml")
	if not settingsXML then
		settingsXML = xmlCreateFile("/settings/settings.xml", "settings")
		xmlSaveFile(settingsXML)
	else
		local theChild = xmlFindChild(settingsXML, 'enabled', 0)
		if theChild then
			local xmlEnabled = xmlNodeGetValue(theChild)

			return toboolean(xmlEnabled)
		end
	end
	return true
end

function saveXML(enabled)
	local settingsXML = xmlLoadFile("/settings/settings.xml")
	local theChild = xmlFindChild(settingsXML, "enabled", 0)

	if theChild then
		xmlNodeSetValue(theChild, tostring(enabled))
	else
		local theNewChild = xmlCreateChild(settingsXML, "enabled")
		xmlNodeSetValue(theNewChild, tostring(enabled))
	end

	xmlSaveFile(settingsXML)
	xmlUnloadFile(settingsXML)
end

function toboolean( bool )
    bool = tostring( bool )
    if bool == "true" then
        return true
    elseif bool == "false" then
        return false
	end
end
