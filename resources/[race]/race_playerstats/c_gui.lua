
local ui = { }
local Settings = {
	["showOnRaceFinish"] = true,
	["windowPosX"] = 15,
	["windowPosY"] = 345,
	["windowWidth"] = 320,
	["windowHeight"] = 380
}


function table.length(t)
	local l = 0
	for _,_ in pairs(t) do
		l = l + 1
	end
	return l
end

function CreateStatCategory(categoryName, uiContainer)
	if not ui.Categories[categoryName] then
		local catName = guiCreateTab(categoryName, uiContainer)
		ui.Categories[categoryName] = catName
		guiSetFont(catName, "clear")
	end
	return ui.Categories[categoryName]
end

function CreateStatLabel(label, uiContainer)
	if not ui.Labels[label.category] then
		ui.Labels[label.category] = {}
	end

	local index = table.length(ui.Labels[label.category])

	local name = guiCreateLabel(15, 5 + index * 16, 200, 16, label.text, false, uiContainer)
	guiSetFont(name, "default-bold-small")
	
	local val = guiCreateLabel(200, 5 + index * 16, 90, 16, "", false, uiContainer)
	guiSetFont(val, "default")
	guiLabelSetHorizontalAlign(val, "right")
	
	ui.Labels[label.category][label.key] = { Name=name, Value=val }
end


function Initialize()
	LoadClientSettings()
	
	ui.Window = guiCreateWindow(Settings["windowPosX"], Settings["windowPosY"], Settings["windowWidth"], Settings["windowHeight"], "Stats", false)
	ui.Panel = guiCreateTabPanel(0, 0.075, 1, 0.8, true, ui.Window)
	
	ui.CloseButton = guiCreateButton (0, 0.91, 0.25, 0.05, "Close (F10)", true, ui.Window)
	ui.DisplayPref = guiCreateCheckBox(0.33, 0.91, 0.5, 0.05, "Show on every race finish", (Settings["showOnRaceFinish"] == true), true, ui.Window) 
	
	ui.Categories = {}
	ui.Labels = {}
	
	for _,category in ipairs(StatCategory) do
		local catLabels = getLabelsForCategory(category)
		if #catLabels > 0 then
			local catName = CreateStatCategory(category, ui.Panel)

			for i,label in ipairs(catLabels) do
				CreateStatLabel(label, catName)
			end
			
		end
	end



	addEventHandler("onClientGUIClick", ui.CloseButton, consoleHideStats)
	addEventHandler("onClientGUIClick", ui.DisplayPref,
		function()
			Settings["showOnRaceFinish"] = guiCheckBoxGetSelected(ui.DisplayPref)
			SaveClientSettings()
		end
	)
	
	addEventHandler("onClientGUISize", ui.Window,
		function()
			local w, h = guiGetSize(ui.Window)
			Settings["windowWidth"] = w
			Settings["windowHeight"] = h
			guiSetSize(ui.Panel, 1, 0.8, true)
			SaveClientSettings()
		end,
		false
	)

	addEventHandler("onClientGUIMove", ui.Window, 
		function()
			local x, y = guiGetPosition(ui.Window, false)
			Settings["windowPosX"] = x
			Settings["windowPosY"] = y
			SaveClientSettings()
		end,
		false
	)
	
	consoleHideStats()
end
addEventHandler("onClientResourceStart", getResourceRootElement(), Initialize)


function consoleHideStats()
	guiSetVisible(ui.Window, false)
	showCursor(false)
end


function consoleShowStats(commandName, playerName)
	triggerServerEvent("onRequestPlayerStats", localPlayer, playerName)
	guiSetVisible(ui.Window, true)
	showCursor(true)
end
-- moved to server script
--addCommandHandler("stats", consoleShowStats, false, false)

addEvent("sb_showMyStats")
function toggleStatsWindow()
	if not guiGetVisible(ui.Window) then
		consoleShowStats()
	else
		consoleHideStats()
	end
end
bindKey("F10", "down", toggleStatsWindow)
addEventHandler("sb_showMyStats",root,toggleStatsWindow)

function guiUpdateStats(playerName, stats)
	if not stats then stats = {} end

	guiSetText(ui.Window, "Stats for "..playerName)
	
	for _,label in ipairs(StatLabel) do
		local value = stats[label.key] or 0

		if label.format then
			value = label.format(value)
		end
		
		guiSetText(ui.Labels[label.category][label.key].Value, tostring(value))
	end
end


--
-- EVENTS
--

-- this event is used by the server to change the stats panel visibility
addEvent("onClientStatsDisplay", true)
addEventHandler("onClientStatsDisplay", root, 
	function(display)
		if display then
			if source == localPlayer or Settings["showOnRaceFinish"] then
				guiSetVisible(ui.Window, true)
				showCursor(true)
			end
		else
			consoleHideStats()
		end
	end
)


-- this event is used by the server to update the client's stats table
addEvent("onClientUpdateStats", true)
addEventHandler("onClientUpdateStats", root, 
	function(playerName, stats)
		if stats then
			guiUpdateStats(playerName, stats)
		end
	end
)


--[[
addEvent("onClientDisplayStats", true)
addEventHandler("onClientDisplayStats", root, 
	function(playerName, stats)
		if stats then
			if source == localPlayer or Settings["showOnRaceFinish"] then
				guiUpdateStats(playerName, stats)
				guiSetVisible(ui.Window, true)
				showCursor(true)
			end
		else
			consoleHideStats()
		end
	end
)
]]



function getLabelsForCategory(category)
	local ret = {}
	for i,label in ipairs(StatLabel) do
		if label.category == category then
			table.insert(ret, label)
		end
	end
	return ret
end

StatCategory = { "Racing", "Player", "Achievements", "Crimes" }

StatLabel = {
	-- Vehicles
	{ key=4,    text="Distance travelled by car", category="Achievements", format=Convert.MetersToKilometers },
	{ key=5,    text="Distance travelled by motorbike", category="Achievements", format=Convert.MetersToKilometers },
	{ key=6,    text="Distance travelled by boat", category="Achievements", format=Convert.MetersToKilometers },
	{ key=8,    text="Distance travelled by aircraft", category="Achievements", format=Convert.MetersToKilometers },
	{ key=27,   text="Distance travelled by bycicle", category="Achievements", format=Convert.MetersToKilometers },
	{ key=122,  text="Cars destroyed", category="Crimes" },
	{ key=1125, text="Bikes destroyed", category="Crimes" },
	{ key=123,  text="Boats destroyed", category="Crimes" },
	{ key=124,  text="Planes & Helicopters destroyed", category="Crimes" },

	--Player
	{ key=1090, text="Damage taken", category="Player", format=Convert.Health },
	{ key=135,  text="Deaths", category="Player" },
	{ key=1001, text="Playing time", category="Player", format=Convert.SecondsToTimeString },
	{ key=21,	text="Fatness", category="Player", format=Convert.PermilleToPercentage },
	
	-- Cash
	--{ key=1011, text="Total earnings", format=Convert.Currency },
	--{ key=62,   text="Money spent", format=Convert.Currency },
	--{ key=1012, text="Current balance", category="Money", format=Convert.Currency },
	
	-- Races
	{ key=148,  text="Race starts", category="Racing" },
	{ key=1025, text="Race finishes", category="Racing" },
	{ key=1026, text="Race wins", category="Racing" },
	{ key=1027, text="Toptimes set", category="Racing" },
	{ key=1024, text="Checkpoints collected", category="Racing" }
}



--
-- EXPORTS
--
function AddStatColumn(statKey, description, category, formatFunction)
	if not statKey then
		outputDebugString("Missing first parameter: statKey [integer]")
		return
	end

	if not description then
		outputDebugString("Missing second parameter: description [string]")
		return
	end
	
	if formatFunction and type(formatFunction) ~= "string" then
		outputDebugString("The 'formatFunction' parameter must be a function name")
		return
	end
	
	formatFunction = Convert[formatFunction] or Convert.ToString
	
	if not category then
		category = "Misc"
	end

	local foundCat = false
	for _,cat in ipairs(StatCategory) do
		outputDebugString(cat)
		if cat == category then
			foundCat = true
			break
		end
	end
	if not foundCat then
		table.insert(StatCategory, category)
		CreateStatCategory(category, ui.Panel)
	end

	AddStatColumnInternal(statKey, description, category, formatFunction)
end

function AddStatColumnInternal(statKey, description, category, formatFunction)
	local newLabel = { key=statKey, text=description, category=category, format=formatFunction }
	local foundLabel = false

	for i,label in ipairs(StatLabel) do 
		if label.key == statKey then
			foundLabel = true
			break
		end
	end

	if not foundLabel then
		StatLabel[#StatLabel+1] = newLabel
		CreateStatLabel(newLabel, ui.Categories[category])
	end

end


--
-- SETTINGS
--

function SaveClientSettings()
	local xml = xmlCreateFile("client-settings.xml", "settings")
	if not xml then return false end

	local guiNode = xmlCreateChild(xml, "gui")
	if Settings["showOnRaceFinish"] ~= nil then
		xmlNodeSetAttribute(guiNode, "showOnRaceFinish", tostring(Settings["showOnRaceFinish"]))
	end
	
	xmlNodeSetAttribute(guiNode, "posX", tostring(Settings["windowPosX"]))
	xmlNodeSetAttribute(guiNode, "posY", tostring(Settings["windowPosY"]))
	xmlNodeSetAttribute(guiNode, "width", tostring(Settings["windowWidth"]))
	xmlNodeSetAttribute(guiNode, "height", tostring(Settings["windowHeight"]))
	
	local ret = xmlSaveFile(xml)
	xmlUnloadFile(xml)
	return ret
end


function LoadClientSettings()
	local xml = xmlLoadFile("client-settings.xml")
	if not xml then return false end

	local guiNode = xmlFindChild(xml, "gui", 0)
	
	local attrShow = xmlNodeGetAttribute(guiNode, "showOnRaceFinish")
	if attrShow ~= nil and attrShow ~= "" then
		Settings["showOnRaceFinish"] = (attrShow == "true")
	end
	
	local attrPosX = xmlNodeGetAttribute(guiNode, "posX")
	if tonumber(attrPosX) then
		Settings["windowPosX"] = tonumber(attrPosX)
	end

	local attrPosY = xmlNodeGetAttribute(guiNode, "posY")
	if tonumber(attrPosY) then
		Settings["windowPosY"] = tonumber(attrPosY)
	end
	
	local attrWidth = xmlNodeGetAttribute(guiNode, "width")
	if tonumber(attrWidth) then
		Settings["windowWidth"] = tonumber(attrWidth)
	end
	
	local attrHeight = xmlNodeGetAttribute(guiNode, "height")
	if tonumber(attrHeight) then
		Settings["windowHeight"] = tonumber(attrHeight)
	end

	xmlUnloadFile(xml)
	return true
end