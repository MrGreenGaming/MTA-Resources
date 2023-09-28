ui_timetosave = 5000 -- Time to save after a setting gets changed, get's reset if another setting gets saved in the same time, see saveTime() --

Exp_Funct = { -- Exported functions
	["rankboard"] = {
		res = "race_rank",
		["true"] = 'exports["race_rank"].showBoard()',
		["false"] = 'exports["race_rank"].hideBoard()'},

	["trafficsensor"] = {
		res = "race_traffic_sensor",
		["true"] = 'exports["race_traffic_sensor"].showTrafficSensor()',
		["false"] = 'exports["race_traffic_sensor"].hideTrafficSensor()'},

	["gccounter"] = {
		res = "gc",
		["true"] = 'exports["gc"].e_showGC()',
		["false"] = 'exports["gc"].e_hideGC()'},

	["nextmapwindow"] = {
		res = "mapratings",
		["true"] = 'exports["map_window"].showNextMapWindow()',
		["false"] = 'exports["map_window"].hideNextMapWindow()'},

	["checkpointdelay"] = {
		res = "race_delay_indicator",
		["true"] = 'exports["race_delay_indicator"].showCPDelays()',
		["false"] = 'exports["race_delay_indicator"].hideCPDelays()'},

	["chatbubbles"] = {
		res = "gus",
		["true"] =	'exports["gus"].showChaticon()',
		["false"] = 'exports["gus"].hideChaticon()'},

	["floatingmessages"] = {
		res = "messages",
		["true"] = 'exports["messages"].showFloatMessages()',
		["false"] ='exports["messages"].hideFloatMessages()'},

	["radar"] = {
		res = "race_sphud",
		["true"] = 'exports["race_sphud"].e_showRadar()',
		["false"] = 'exports["race_sphud"].e_hideRadar()'},

	["timeleft"] = {
		["true"] = 'timeleft_on()',
		["false"] = 'timeleft_off()'},

	["fpscounter"] = {
		res = "fps",
		["true"] = 'exports["fps"].e_showFPS()',
		["false"] = 'exports["fps"].e_hideFPS()'},

	["customnametags"] = {
		["true"] = 'CustomNameTags_on',
		["false"] = 'CustomNameTags_off'},

	["speed-o-metermode"] = {
		res = "speed-o-meter",
		[1] = 'exports["speed-o-meter"].setKMH()',
		[2] = 'exports["speed-o-meter"].setMPH()',
		[3] = 'exports["speed-o-meter"].setNone()'},

	["hudmode"] = {
		res = "race_sphud",
		[1] = 'exports["race_sphud"].e_showNewhud()',
		[2] = 'exports["race_sphud"].e_showSPhud()',
		[3] = 'exports["race_sphud"].e_showOldhud()'},
}

-- Reapply settings when one of these resources (re)starts
local UI_reApplyTimer = false
-- Add resource name here when used
local resetResource = {"race_sphud","speed-o-meter","fps","race_sphud","messages","gus","race_delay_indicator","mapratings","race_traffic_sensor","race_rank","race"}
addEventHandler("onClientResourceStart",root,
	function(res)
		local resName = getResourceName(res)
		for _,rn in ipairs(resetResource) do
			if rn == resName then
				-- Timer system so no settings spam
				if isTimer(UI_reApplyTimer) then killTimer(UI_reApplyTimer) end
				UI_reApplyTimer = setTimer(function() updateUIgui() executeHUDSettings() end,5000,1)
				break
			end
		end
	end
)


UI = { -- Default settings--
	["rankboard"] = false ,
	["trafficsensor"] = true ,
	["gccounter"] = true ,
	["nextmapwindow"] = false ,
	["checkpointdelay"] = false ,
	["chatbubbles"] = true ,
	["floatingmessages"] = true ,
	["fpscounter"] = false ,
	["customnametags"] = true ,
	["speed-o-metermode"] = 3 ,
	["hudmode"] = 1 ,
	["radar"] = true,
	["timeleft"] = true

}

-- speed-o-metermode: 1 = "km/h", 2="mph", 3="none"
-- hudmode: 1 = new HUD, 2 = sphud, 3 = old hud


function ui_ClickHandler()
	-- Open Progress Bar Settings Button
	if source == GUIEditor.button[2] then
		exports["race_progress"].toggleGui()

	-- Toggle RankBoard
	elseif source == GUIEditor.checkbox[5] then
		saveTime()
		if guiCheckBoxGetSelected( source ) then
			exports["race_rank"].showBoard()


			UI["rankboard"] = true
		else
			exports["race_rank"].hideBoard()


			UI["rankboard"] = false
		end
	-- Open RankBoard settings
	elseif source == GUIEditor.button[5] then
		exports["race_rank"].toggleSettings()
	-- Toggle Traffic Sensor
	elseif source == GUIEditor.checkbox[7] then
		saveTime()
		if guiCheckBoxGetSelected( source ) then
			exports["race_traffic_sensor"].showTrafficSensor()

			UI["trafficsensor"] = true
		else
			exports["race_traffic_sensor"].hideTrafficSensor()

			UI["trafficsensor"] = false
		end


	-- Toggle GC counter
	elseif source == GUIEditor.checkbox[8] then
		saveTime()
		if guiCheckBoxGetSelected( source ) then
			exports["gc"].e_showGC() -- false = show, true = hide
			UI["gccounter"] = true

		else
			exports["gc"].e_hideGC()
			UI["gccounter"] = false

		end
	-- toggle nextmapwindow
	elseif source == GUIEditor.checkbox[9] then
		saveTime()
		if guiCheckBoxGetSelected( source ) then
			exports["map_window"].showNextMapWindow()

			UI["nextmapwindow"] = true
		else
			exports["map_window"].hideNextMapWindow()

			UI["nextmapwindow"] = false
		end

	-- Toggle CP Delays
	elseif source == GUIEditor.checkbox[10] then
		saveTime()
		if guiCheckBoxGetSelected( source ) then
			exports["race_delay_indicator"].showCPDelays()

			UI["checkpointdelay"] = true
		else
			exports["race_delay_indicator"].hideCPDelays()

			UI["checkpointdelay"] = false
		end

	-- Toggle Chat Bubbles (chat icons)
	elseif source == GUIEditor.checkbox[11] then
		saveTime()
		if guiCheckBoxGetSelected( source ) then
			exports["gus"].showChaticon()

			UI["chatbubbles"] = true
		else
			exports["gus"].hideChaticon()

			UI["chatbubbles"] = false
		end

	-- Toggle Float messages
	elseif source == GUIEditor.checkbox[12] then
		saveTime()
		if guiCheckBoxGetSelected( source ) then
			exports["messages"].showFloatMessages()

			UI["floatingmessages"] = true
		else
			exports["messages"].hideFloatMessages()

			UI["floatingmessages"] = false
		end

	-- Toggle Radar
	elseif source == GUIEditor.checkbox[14] then
		saveTime()
		if guiCheckBoxGetSelected( source ) then
			exports["race_sphud"].e_showRadar()

			UI["radar"] = true
		else
			exports["race_sphud"].e_hideRadar()

			UI["radar"] = false
		end

	-- Toggle Custon NameTags
	elseif source == customNameTagsCheckBox then
		saveTime()
		if guiCheckBoxGetSelected( source ) then
			triggerEvent("toggleNameTags",root,true)

			UI["customnametags"] = true
		else
			triggerEvent("toggleNameTags",root,false)

			UI["customnametags"] = false
		end

	-- Toggle FPS Counter
	elseif source == GUIEditor.checkbox[15] then
		saveTime()
		if guiCheckBoxGetSelected( source ) then
			exports["fps"].e_showFPS()

			UI["fpscounter"] = true
		else
			exports["fps"].e_hideFPS()

			UI["fpscounter"] = false
		end
	-- Toggle TimeLeft --
	elseif source == GUIEditor.checkbox[16] then
		saveTime()
		if guiCheckBoxGetSelected( source ) then
			timeleft_on()

			UI["timeleft"] = true
		else
			timeleft_off()

			UI["timeleft"] = false
		end

	end
end
addEventHandler("onClientGUIClick", resourceRoot, ui_ClickHandler)


function ui_ComboBoxHandler(comboBox)
	if comboBox == GUIEditor.combobox[1] then
		saveTime()
		local theID = guiComboBoxGetSelected( comboBox )
		local theText = guiComboBoxGetItemText( comboBox, theID )

		if theText == "New Hud" then
			if isTimer(HudOverrideTimer) then
				killTimer(HudOverrideTimer)
			end
			setTimer( sphudOverride, 2000, 1)

			exports["race_sphud"].e_showNewhud()
			UI["hudmode"] = 1


		elseif theText == "SP Hud" then
			if isTimer(HudOverrideTimer) then
				killTimer(HudOverrideTimer)
			end
			setTimer( sphudOverride, 2000, 1)

			exports["race_sphud"].e_showSPhud()
			UI["hudmode"] = 2


		elseif theText == "Old Hud" then
			if isTimer(HudOverrideTimer) then
				killTimer(HudOverrideTimer)
			end
			setTimer( sphudOverride, 2000, 1)

			exports["race_sphud"].e_showOldhud()
			UI["hudmode"] = 3

		end
		-- Speed - o - meter mode combobox
	elseif comboBox == GUIEditor.combobox[2] then
		saveTime()
		local theID = guiComboBoxGetSelected( comboBox )
		local theText = guiComboBoxGetItemText( comboBox, theID )

		if theText == "km/h" then
			exports["speed-o-meter"].setKMH()
			UI["speed-o-metermode"] = 1


		elseif theText == "mph" then
			exports["speed-o-meter"].setMPH()
			UI["speed-o-metermode"] = 2

		elseif theText == "None" then
			exports["speed-o-meter"].setNone()
			UI["speed-o-metermode"] = 3

		end
	end
end
addEventHandler("onClientGUIComboBoxAccepted", resourceRoot, ui_ComboBoxHandler)





function sphudOverride() -- sphud overrides toggleGCInfo and enableFPS
	for f, u in pairs(Exp_Funct) do
		if UI[f] then
			if Exp_Funct[f]["true"] then

				local executeFunction = loadstring(Exp_Funct[f]["true"])
				executeFunction()

			-- elseif tostring(f) == "speed-o-metermode" then --set speed-o-meter mode
			-- 	local theNumber = UI[f]
			-- 	local executeFunction = loadstring(Exp_Funct[f][theNumber])
			-- 	executeFunction()
			-- 	outputChatBox("Set Speedometer to "..tostring(theNumber))

			end
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
	UIxml = xmlLoadFile( "/settings/uisettings.xml" )

	for f, u in pairs(UI) do
		local theChild = xmlFindChild( UIxml, f, 0 )
		if not theChild then
			local theNewChild = xmlCreateChild( UIxml, tostring(f) )
			xmlNodeSetValue( theNewChild, tostring(u) )
		else
			local theValue = xmlNodeSetValue( theChild, tostring(u) )
		end
	end
	outputChatBox("UI Settings Saved")

	xmlSaveFile( UIxml )
	xmlUnloadFile( UIxml )

end



function loadUISettings()
	UIxml = xmlLoadFile( "/settings/uisettings.xml" )
	if not UIxml then
		UIxml = xmlCreateFile( "/settings/uisettings.xml", "settings" )

		for f, u in pairs(UI) do
			local theChild = xmlCreateChild( UIxml, f )
			xmlNodeSetValue( theChild, tostring(u) )
		end
	end

	for f, u in pairs(UI) do -- load settings to UI table
		local theChild = xmlFindChild( UIxml, f, 0 )
		local theValue = xmlNodeGetValue( theChild )

		if isBoolean(theValue) then
			UI[f] = toBoolean(theValue)
		else
			UI[f] = tonumber(theValue)
		end
	end



	xmlSaveFile( UIxml )
	xmlUnloadFile( UIxml )
	updateUIgui()
	executeHUDSettings()
end
addEventHandler("onClientResourceStart", resourceRoot, loadUISettings)

function executeHUDSettings()
	local precheck = "if not (getResourceFromName(Exp_Funct['hudmode'].res) and getResourceState(getResourceFromName(Exp_Funct['hudmode'].res))=='running') then return outputDebugString('settings: hudmode not running', 2) end; "
	local executeHud = loadstring(precheck .. Exp_Funct["hudmode"][tonumber(UI["hudmode"])])
	setTimer(executeHud,2000,1)
	setTimer(executeUISettings, 3000, 1)
end

function executeUISettings()
	for f, u in pairs(UI) do
		local precheck = string.format("if Exp_Funct['%s'].res and getResourceFromName(Exp_Funct['%s'].res) and getResourceState(getResourceFromName(Exp_Funct['%s'].res))~='running' then return end; ", f, f, f)
		if f == "speed-o-metermode" then -- exception for number based setting
			if Exp_Funct[f].res and getResourceFromName(Exp_Funct[f].res) and getResourceState(getResourceFromName(Exp_Funct[f].res))~='running' then
				-- outputDebugString('settings: ' .. f .. ' res not running', 2)
			else
				local executeFunction = loadstring(precheck .. Exp_Funct["speed-o-metermode"][tonumber(UI["speed-o-metermode"])])
				executeFunction()
			end
		elseif f ~= "hudmode" and f ~= "customnametags" then
			if Exp_Funct[f].res and not (getResourceFromName(Exp_Funct[f].res) and getResourceState(getResourceFromName(Exp_Funct[f].res))=='running') then
				-- outputDebugString('settings: ' .. f .. ' res not running', 2)
			else
				local executeSetting = loadstring(Exp_Funct[f][tostring(UI[f])])
				executeSetting()
			end

		elseif f == "customnametags" then
			triggerEvent("toggleNameTags",root,toBoolean(u))
		end
	end
end


function updateUIgui() -- Updates the GUI to the settings that loaded --
	for f, u in pairs(UI) do

		if f == "rankboard" then
			if u then
				guiCheckBoxSetSelected( GUIEditor.checkbox[5], true )
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox[5], false )
			end
		elseif f == "trafficsensor" then
			if u then
				guiCheckBoxSetSelected( GUIEditor.checkbox[7], true )
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox[7], false )
			end

		elseif f == "gccounter" then
			if u then
				guiCheckBoxSetSelected( GUIEditor.checkbox[8], true )
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox[8], false )
			end

		elseif f == "nextmapwindow" then
			if u then
				guiCheckBoxSetSelected( GUIEditor.checkbox[9], true )
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox[9], false )
			end

		elseif f == "checkpointdelay" then
			if u then
				guiCheckBoxSetSelected( GUIEditor.checkbox[10], true )
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox[10], false )
			end

		elseif f == "chatbubbles" then
			if u then
				guiCheckBoxSetSelected( GUIEditor.checkbox[11], true )
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox[11], false )
			end

		elseif f == "floatingmessages" then
			if u then
				guiCheckBoxSetSelected( GUIEditor.checkbox[12], true )
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox[12], false )
			end

		elseif f == "fpscounter" then
			if u then
				guiCheckBoxSetSelected( GUIEditor.checkbox[15], true )
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox[15], false )
			end

		elseif f == "timeleft" then
			if u then
				guiCheckBoxSetSelected( GUIEditor.checkbox[16], true )
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox[16], false )
			end

		elseif f == "radar" then
			if toBoolean(u) then
				guiCheckBoxSetSelected( GUIEditor.checkbox[14], true )
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox[14], false )
			end
		elseif f == "customnametags" then
			if toBoolean(u) then
				guiCheckBoxSetSelected(customNameTagsCheckBox,true)
			else
				guiCheckBoxSetSelected(customNameTagsCheckBox,false)
			end

		elseif f == "speed-o-metermode" then
			guiComboBoxSetSelected( GUIEditor.combobox[2], tonumber(u)-1 )

		elseif f == "hudmode" then
			guiComboBoxSetSelected( GUIEditor.combobox[1], tonumber(u)-1 )
        end
	end
end

addEvent('onClientMapStarting')
function setTimeLeftonMapStart()
	if UI["timeleft"] then
		setTimer(function()
			timeleft_on()
		end,2000,1)
	end
end
addEventHandler("onClientMapStarting", root, setTimeLeftonMapStart)


function timeleft_on()
	triggerEvent('onClientCall_race', getResourceRootElement( getResourceFromName('race')), 'showGUIComponents', 'timeleft', 'timeleftbg')
end

function timeleft_off()
	triggerEvent('onClientCall_race', getResourceRootElement( getResourceFromName('race')), 'hideGUIComponents', 'timeleft', 'timeleftbg')
end




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
