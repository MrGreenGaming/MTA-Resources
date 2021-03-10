
GUIEditor = {
    checkbox = {},
    combobox = {},
    edit = {},
    button = {},
    window = {},
    label = {}
}

customFlags = {
	{ name = "-", value = "" }, 
	{ name = "Pride", value = "pride" },
	{ name = "Trans. pride", value = "trans" }
}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
	local screenW, screenH = guiGetScreenSize()
        GUIEditor.window[1] = guiCreateWindow((screenW - 500) / 2, (screenH - 250) / 2, 500, 250, "Ranking board settings", false)
        guiWindowSetSizable(GUIEditor.window[1], false)

        GUIEditor.label[1] = guiCreateLabel(46, 28, 200, 18, "Enable animations", false, GUIEditor.window[1])
        GUIEditor.checkbox["animations"] = guiCreateCheckBox(14, 28, 17, 18, "", true, false, GUIEditor.window[1])
        GUIEditor.label[2] = guiCreateLabel(46, 56, 200, 18, "Show intervals", false, GUIEditor.window[1])
        GUIEditor.checkbox["intervals"] = guiCreateCheckBox(14, 56, 15, 15, "", false, false, GUIEditor.window[1])
        GUIEditor.label[3] = guiCreateLabel(46, 84, 200, 18, "Live timing (experimental)", false, GUIEditor.window[1])
        GUIEditor.checkbox["live"] = guiCreateCheckBox(14, 84, 15, 15, "", false, false, GUIEditor.window[1])
        guiSetEnabled(GUIEditor.checkbox["live"], false)
	guiSetAlpha(GUIEditor.label[3], 0.5)
	
	GUIEditor.label[4] = guiCreateLabel(46, 112, 200, 18, "Make dark names lighter", false, GUIEditor.window[1])
        GUIEditor.checkbox["fixdark"] = guiCreateCheckBox(14, 112, 15, 15, "", false, false, GUIEditor.window[1])
        
        GUIEditor.label[5] = guiCreateLabel(46, 140, 200, 18, "Show country flags", false, GUIEditor.window[1])
        GUIEditor.checkbox["flags"] = guiCreateCheckBox(14, 140, 17, 18, "", true, false, GUIEditor.window[1])
        
        GUIEditor.label[6] = guiCreateLabel(14, 174, 200, 18, "Set custom flag", false, GUIEditor.window[1])
        GUIEditor.combobox["customFlag"] = guiCreateComboBox(114, 172, 95, 100, "", false, GUIEditor.window[1])
        for index, customF in ipairs(customFlags) do
        	guiComboBoxAddItem(GUIEditor.combobox["customFlag"], customF["name"])
        end
        
        guiComboBoxAdjustHeight(GUIEditor.combobox["customFlag"], #customFlags);
        
        GUIEditor.label[7] = guiCreateLabel(250, 28, 240, 18, "Number of positions to show (5 - 20)", false, GUIEditor.window[1])
        GUIEditor.edit["lines"] = guiCreateEdit(250, 50, 80, 22, "8", false, GUIEditor.window[1])
        GUIEditor.button["lines"] = guiCreateButton(250+80, 50, 33, 25, "OK", false, GUIEditor.window[1])
        
        GUIEditor.label[8] = guiCreateLabel(250, 84, 240, 18, "Board scale (0.5 - 3.0 or 0 for automatic)", false, GUIEditor.window[1])
        GUIEditor.edit["scale"] = guiCreateEdit(250, 106, 80, 22, "0", false, GUIEditor.window[1])
        GUIEditor.button["scale"] = guiCreateButton(250+80, 106, 33, 25, "OK", false, GUIEditor.window[1])
        local scale = math.floor((screenH/800)*10 + 0.5) / 10 
        local scaleInfoLabel = guiCreateLabel(250, 132, 240, 18, "Your automatic scale value is: " .. tostring(scale), false, GUIEditor.window[1])
        guiSetAlpha(scaleInfoLabel, 0.5)
        
        GUIEditor.label[9] = guiCreateLabel(250, 150, 240, 18, "Background opacity (0.0 - 1.0)", false, GUIEditor.window[1])
        GUIEditor.edit["opacity"] = guiCreateEdit(250, 172, 80, 22, "0.65", false, GUIEditor.window[1])
        GUIEditor.button["opacity"] = guiCreateButton(250+80, 172, 33, 25, "OK", false, GUIEditor.window[1])
        
        GUIEditor.button[1] = guiCreateButton(415, 202, 65, 28, "Close", false, GUIEditor.window[1])
        guiSetProperty(GUIEditor.button[1], "NormalTextColour", "FFAAAAAA")
        
        guiSetVisible(GUIEditor.window[1], false)
    end
)

showGui = false

addCommandHandler('boardsettings', function()
	showGui = not showGui
	showCursor(showGui)
	guiSetVisible(GUIEditor.window[1], showGui)
	guiBringToFront( GUIEditor.window[1] )
end)

addEventHandler("onClientGUIClick", resourceRoot, function()
    if source == GUIEditor.button[1] then
        executeCommandHandler("boardsettings") 
    end 
end)

function toggleSettings()
	executeCommandHandler("boardsettings")
end


UI = { -- Default settings--
	["animations"] = true,
	["intervals"] = false,
	["live"] = false,
	["fixdark"] = false,
	["flags"] = true,
	["customFlag"] = 1,
	["lines"] = 8,
	["opacity"] = 0.65,
	["scale"] = 0
}

ui_timetosave = 5000

function ui_ClickHandler()
	-- Toggle Animations
	if source == GUIEditor.checkbox["animations"] then
		saveTime()
		if guiCheckBoxGetSelected( source ) then
			setAnimationsEnabled(true)
			UI["animations"] = true
		else
			setAnimationsEnabled(false)
			UI["animations"] = false
		end

	-- Toggle Intervals
	elseif source == GUIEditor.checkbox["intervals"] then
		saveTime()
		local liveEnabled = guiCheckBoxGetSelected(GUIEditor.checkbox["live"])
		if guiCheckBoxGetSelected( source ) then
			setShowIntervals(true, liveEnabled)
			UI["intervals"] = true
			guiSetEnabled(GUIEditor.checkbox["live"], true)
			guiSetAlpha(GUIEditor.label[3], 1)
		else
			setShowIntervals(false, liveEnabled)
			UI["intervals"] = false
			guiSetEnabled(GUIEditor.checkbox["live"], false)
			guiSetAlpha(GUIEditor.label[3], 0.5)
		end
	-- Toggle Live timing
	elseif source == GUIEditor.checkbox["live"] then
		saveTime()
		
		if guiCheckBoxGetSelected( source ) then
			setShowIntervals(true, true)
			UI["live"] = true
		else
			setShowIntervals(true, false)
			UI["live"] = false
		end
	-- Toggle fixing dark names
	elseif source == GUIEditor.checkbox["fixdark"] then
		saveTime()
		
		if guiCheckBoxGetSelected( source ) then
			setLightenDarkColors(true)
			UI["fixdark"] = true
		else
			setLightenDarkColors(false)
			UI["fixdark"] = false
		end
	-- Toggle showing flags
	elseif source == GUIEditor.checkbox["flags"] then
		saveTime()
		if guiCheckBoxGetSelected( source ) then
			setShowFlags(true)
			UI["flags"] = true
		else
			setShowFlags(false)
			UI["flags"] = false
		end
	elseif source == GUIEditor.button["lines"] then
		saveTime()
		local nr = tonumber(guiGetText( GUIEditor.edit["lines"] ))

		if not nr then outputChatBox("Please insert a number before clicking ok.",255) return end
		if nr > 20 or nr < 5 then outputChatBox("Number of positions must be between 5 and 20",255) return end
		UI["lines"] = nr
		setNumberOfPositions(nr)
	elseif source == GUIEditor.button["opacity"] then
		saveTime()
		local nr = tonumber(guiGetText( GUIEditor.edit["opacity"] ))

		if not nr then outputChatBox("Please insert a number before clicking ok.",255) return end
		if nr > 1 or nr < 0 then outputChatBox("The opacity must be between 0.0 and 1.0",255) return end
		UI["opacity"] = nr
		setBackgroudOpacity(nr)
	elseif source == GUIEditor.button["scale"] then
		saveTime()
		local nr = tonumber(guiGetText( GUIEditor.edit["scale"] ))

		if not nr then outputChatBox("Please insert a number before clicking ok.",255) return end
		if nr ~= 0 and (nr > 3 or nr < 0.5) then outputChatBox("The scale must be between 0.5 and 3.0 or can be 0 for automatic scaling",255) return end
		UI["scale"] = nr
		setBoardScale(nr)
	end
end
addEventHandler("onClientGUIClick", resourceRoot, ui_ClickHandler)

function ui_ComboBoxHandler(comboBox)
	if comboBox == GUIEditor.combobox["customFlag"] then
		saveTime()
		local theID = guiComboBoxGetSelected( comboBox ) + 1
		UI['customFlag'] = theID;
		if customFlags[theID] ~= nil then
			setCustomFlag(customFlags[theID]["value"])
		end
		
	end
end
addEventHandler("onClientGUIComboBoxAccepted", resourceRoot, ui_ComboBoxHandler)


function updateUIgui() -- Updates the GUI to the settings that loaded --
	for f, u in pairs(UI) do
		if f == "animations" then
			if u then
				guiCheckBoxSetSelected( GUIEditor.checkbox["animations"], true )
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox["animations"], false )
			end
		elseif f == "intervals" then
			if u then
				guiCheckBoxSetSelected( GUIEditor.checkbox["intervals"], true )
				guiSetEnabled(GUIEditor.checkbox["live"], true)
				guiSetAlpha(GUIEditor.label[3], 1)
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox["intervals"], false )
				guiSetEnabled(GUIEditor.checkbox["live"], false)
				guiSetAlpha(GUIEditor.label[3], 0.5)
			end
		elseif f == "live" then
			if u then
				guiCheckBoxSetSelected( GUIEditor.checkbox["live"], true )
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox["live"], false )
			end
		elseif f == "fixdark" then
			if u then
				guiCheckBoxSetSelected( GUIEditor.checkbox["fixdark"], true )
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox["fixdark"], false )
			end
		elseif f == "flags" then
			if u then
				guiCheckBoxSetSelected( GUIEditor.checkbox["flags"], true )
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox["flags"], false )
			end
		elseif f == "customFlag" then
			if u == 0 then u = 1 end
			guiComboBoxSetSelected( GUIEditor.combobox["customFlag"], tonumber(u)-1 )
		elseif f == "lines" then
			if u then
				guiSetText( GUIEditor.edit["lines"], u )
			end
		elseif f == "opacity" then
			if u then
				guiSetText( GUIEditor.edit["opacity"], u )
			end
		elseif f == "scale" then
			if u then
				guiSetText( GUIEditor.edit["scale"], u )
			end
		end
	end
end

function executeUISettings()
	for f, u in pairs(UI) do
		if f == "animations" then
			setAnimationsEnabled(u)
		elseif f == "intervals" then
			setShowIntervals(u, UI['live'])
		elseif f == "flags" then
			setShowFlags(u)
		elseif f == "customFlag" then
			if u == 0 then u = 1 end
			setCustomFlag(customFlags[u] and customFlags[u]["value"] or "")
		elseif f == "lines" then
			setNumberOfPositions(u)
		elseif f == "opacity" then
			setBackgroudOpacity(u)
		elseif f == "scale" then
			setBoardScale(u)
		end
	end
end


function saveTime()
	if isTimer( theSaveTimer ) then
		killTimer( theSaveTimer )
	end
	theSaveTimer = setTimer(saveUISettings, ui_timetosave, 1)
end

function saveUISettings()
	UIxml = xmlLoadFile( "board_settings.xml" )

	for f, u in pairs(UI) do
		local theChild = xmlFindChild( UIxml, f, 0 )
		if not theChild then
			local theNewChild = xmlCreateChild( UIxml, tostring(f) )
			xmlNodeSetValue( theNewChild, tostring(u) )
		else
			local theValue = xmlNodeSetValue( theChild, tostring(u) )
		end
	end
	outputChatBox("RankBoard settings saved")

	xmlSaveFile( UIxml )
	xmlUnloadFile( UIxml )
end



function loadUISettings()
	UIxml = xmlLoadFile("board_settings.xml")
	if not UIxml then
		UIxml = xmlCreateFile("board_settings.xml", "main")

		for f, u in pairs(UI) do
			local theChild = xmlCreateChild( UIxml, f )
			xmlNodeSetValue( theChild, tostring(u) )
		end
	end

	for f, u in pairs(UI) do -- load settings to UI table
		local theChild = xmlFindChild( UIxml, f, 0 )
		if theChild then
			local theValue = xmlNodeGetValue( theChild )
	
			if isBoolean(theValue) then
				UI[f] = toBoolean(theValue)
			else
				UI[f] = tonumber(theValue)
			end
		end
	end

	xmlSaveFile( UIxml )
	xmlUnloadFile( UIxml )
	updateUIgui()
	executeUISettings()
end
addEventHandler("onClientResourceStart", resourceRoot, loadUISettings)

-- util --
function toBoolean(str)
	if str == "true" then return true end
	if str == "false" then return false end
	if str == true then return true end
	if str == false then return false end
end

function isBoolean(str)
	if str == nil then return false end
	if str == "false" then return true end
	if str == "true" then return true end
	if str == false then return true end
	if str == true then return true end
end

function guiComboBoxAdjustHeight ( combobox, itemcount )
    if getElementType ( combobox ) ~= "gui-combobox" or type ( itemcount ) ~= "number" then error ( "Invalid arguments @ 'guiComboBoxAdjustHeight'", 2 ) end
    local width = guiGetSize ( combobox, false )
    return guiSetSize ( combobox, width, ( itemcount * 20 ) + 20, false )
end
