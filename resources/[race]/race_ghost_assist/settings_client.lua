g_Root = getRootElement()
local child

-- !!!
-- default settings
Settings = {
	sensitivity = 1, -- defines when the line turns green/red
	linelength = 12 -- length of the racing line
}
IsEnabled = false
-- !!!



-- // ======================[ saveSettings ] =============================//
function saveSettings()
    outputDebug("@saveSettings")

    local file = xmlLoadFile( "/settings/assist_settings.xml")
	if not file then
		file = xmlCreateFile("/settings/assist_settings.xml", "settings")
	end

	-- save the values
    for key, val in pairs(Settings) do
        child = xmlFindChild(file, key, 0)
        if child then
            xmlNodeSetValue(child, val)
		-- key wasnt found
        else
            child = xmlCreateChild(file, key)
            xmlNodeSetValue(child, val)
        end
    end

    if xmlSaveFile(file) then
		-- debug
		outputDebug("Settings saved!")
	end
    xmlUnloadFile(file)

end


-- // ======================[ loadSettings ] =============================//
function loadSettings()
    outputDebug("@loadSettings")

	file = xmlLoadFile("/settings/assist_settings.xml")

	-- create a default settings xml
	if not file then
		file = xmlCreateFile("/settings/assist_settings.xml", "settings")
		-- set xml child nodes
		for key, val in pairs(Settings) do
			child = xmlCreateChild(file, key)
			xmlNodeSetValue(child, tostring(val))
		end
		xmlSaveFile(file)
	end

	-- Load settings into table --
    Settings.sensitivity = xmlNodeGetValue(xmlFindChild(file, "sensitivity", 0))
    Settings.linelength = xmlNodeGetValue(xmlFindChild(file, "linelength", 0))

	xmlUnloadFile(file)

	-- debug
    -- outputDebug("Settings loaded!")
	-- outputChatBox("loadSettings: \n"..inspect(cfg))

end -- loadSettings
