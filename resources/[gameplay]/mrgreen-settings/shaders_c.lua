tableasd = {2,{{{{anothertable,1}}}}}
--1. Bloom
--2. Car paint
--3. Radar shader
--4. Water shader
--6. Chrome wheels

-- index numbers ^



function loadShader(id, load, resRestartCall)
	--here add a bunch of IFs and functions to start/stop respective shaders
	if id == 2 then
		createCarPaintShader(load)
	elseif id == 1 then
		createBloomShader(load)
	elseif id == 4 then
		if isTimer(watershade) then killTimer(watershade) end
		watershade = setTimer(createWaterShader, 2000, 1, load)
	elseif id == 3 and load == false and resRestartCall == true then
		return
	elseif id == 3 then
		toggleRadar(load)
	elseif id == 6 then -- chrome wheels
		replaceWheels(load)
	elseif id == 5 then
		if tonumber(load) and tonumber(load) ~= getFarClipDistance() then
			setFarClipDistance(tonumber(load))
		end	
	end	
end

addEventHandler('onClientVehicleEnter', getRootElement(),
function(player)
	if player == getLocalPlayer() then
		local clip = getFarClipDistance()
		local node = xmlLoadFile('settings1.xml')
		if node then
			local child = xmlFindChild(node, "shader", 4)
			local myclip = xmlNodeGetAttribute(child, "use")
			if myclip == "false" then return end
			if tonumber(myclip) ~= clip then
				setFarClipDistance(tonumber(myclip))
			end	
		end	
	end
end
)

showGui = false

addCommandHandler('settings',
function()
	showGui = not showGui
	showCursor(showGui)
	guiSetVisible(GUIEditor_Window[1], showGui)
end
)

function updateGUIonStart()
	createCarPaintShader(false)
	createBloomShader(false)
	createWaterShader(false)
	local node = xmlLoadFile('settings1.xml')
	if node then
		for i, child in ipairs(xmlNodeGetChildren(node)) do
			local enable = xmlNodeGetAttribute(child, "use")
			local id = xmlNodeGetAttribute(child, "id")
			local bool
			if enable == "true" then bool = true
				elseif enable == "false" then bool = false 
			end
			
			if tonumber(enable) then
				guiSetText(GUIEditor_Edit[1], enable)
			elseif tonumber(id) ~= 5 then
			guiCheckBoxSetSelected(GUIEditor_Checkbox[tonumber(id)], bool)
			end
			if (id == 5) and (enable == "false") then
			else
			loadShader(tonumber(id), bool, true)
			end
		end
	else
		local childs = {}
		local node = xmlCreateFile("settings1.xml", "settings")
		childs[1] = xmlCreateChild(node, "shader")
			xmlNodeSetAttribute(childs[1], "id", "1")
			xmlNodeSetAttribute(childs[1], "use", "false")
		childs[2] = xmlCreateChild(node, "shader")
			xmlNodeSetAttribute(childs[2], "id", "2")
			xmlNodeSetAttribute(childs[2], "use", "false")
		childs[3] = xmlCreateChild(node, "shader")
			xmlNodeSetAttribute(childs[3], "id", "3")
			xmlNodeSetAttribute(childs[3], "use", "false")
		childs[4] = xmlCreateChild(node, "shader")
			xmlNodeSetAttribute(childs[4], "id", "4")
			xmlNodeSetAttribute(childs[4], "use", "false")
		childs[5] = xmlCreateChild(node, "shader")
			xmlNodeSetAttribute(childs[5], "id", "5")
			xmlNodeSetAttribute(childs[5], "use", "false")
		childs[6] = xmlCreateChild(node, "shader")
			xmlNodeSetAttribute(childs[6], "id", "6")
			xmlNodeSetAttribute(childs[6], "use", "false")
		xmlSaveFile(node)
		xmlUnloadFile(node)	
	end
end

function xmlChange(index, data)
	if type(index) == "number" and type(data) == "string" then
	index = index - 1
	local node = xmlLoadFile('settings1.xml')
	if node then
		local child = xmlFindChild(node, "shader", index)
		if child then
			xmlNodeSetAttribute(child, "use", data)
		else 
			local makeChromeWheelChild = xmlCreateChild(node, "shader")
			xmlNodeSetAttribute(makeChromeWheelChild, "id", "6")
			xmlNodeSetAttribute(makeChromeWheelChild, "use", "false")
		end

		xmlSaveFile(node)
		xmlUnloadFile(node)
		local bool 
		if data == "true" then bool = true
		elseif data == "false" then bool = false
		end
		if tonumber(data) then
			loadShader(index+1, data)
		else
			loadShader(index+1, bool)
		end
	end	
	end
end

addEvent('guiShaderCreated', true)
addEventHandler('guiShaderCreated', getRootElement(),
function()
	updateGUIonStart()
	addEventHandler('onClientGUIClick', GUIEditor_Button[1],
	function(button, state)
		if button == "left" and state == "up" then
				showGui = false
			showCursor(showGui)
			guiSetVisible(GUIEditor_Window[1], showGui)
		end	
	end, false)
	addEventHandler('onClientGUIClick', GUIEditor_Checkbox[1],
	function(button, state)
		if button == "left" and state == "up" then
				if guiCheckBoxGetSelected(source) then
					xmlChange(1, "true")
					--createTheShader
				else
					xmlChange(1, "false")
					--removeTheShader
				end	
		end	
	end, false)
	addEventHandler('onClientGUIClick', GUIEditor_Checkbox[2],
	function(button, state)
		if button == "left" and state == "up" then
				if guiCheckBoxGetSelected(source) then
					xmlChange(2, "true")
					--createTheShader
				else
					xmlChange(2, "false")
					--removeTheShader
				end	
		end	
	end, false)
	addEventHandler('onClientGUIClick', GUIEditor_Checkbox[3],
	function(button, state)
		if button == "left" and state == "up" then
				if guiCheckBoxGetSelected(source) then
					xmlChange(3, "true")
					--createTheShader
				else
					xmlChange(3, "false")
					--removeTheShader
				end	
		end	
	end, false)
	addEventHandler('onClientGUIClick', GUIEditor_Checkbox[4],
	function(button, state)
		if button == "left" and state == "up" then
				if guiCheckBoxGetSelected(source) then
					xmlChange(4, "true")
					--createTheShader
				else
					xmlChange(4, "false")
					--removeTheShader
				end	
		end	
	end, false)
	addEventHandler('onClientGUIClick', GUIEditor_Checkbox[6], -- Chrome Wheels Shader
	function(button, state)
		if button == "left" and state == "up" then
				if guiCheckBoxGetSelected(source) then
					xmlChange(6, "true")
					--createTheShader
				else
					xmlChange(6, "false")
					--removeTheShader
				end	
		end	
	end, false)
	addEventHandler('onClientGUIClick', GUIEditor_Button[2],
	function(button, state)
		if button == "left" and state == "up" then
			local number = tonumber(guiGetText(GUIEditor_Edit[1]))
			if (number) and (number > 99) and (number < 10001) then
				xmlChange(5, tostring(number))
			end
		end	
	end, false)
end
)

