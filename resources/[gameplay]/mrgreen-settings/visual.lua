-- Bloom = triggerEvent( "switchBloom", root, boolean ) 
-- CarPaint1 = triggerEvent( "switchCarPaint", root, boolean ) 
-- CarPaint2 = triggerEvent( "switchCarPaintReflect", root, boolean ) 
-- RoadShine = triggerEvent( "switchRoadshine3", root, boolean ) 
-- Dynamic sky(skybox1) = triggerEvent( "ToggleDynamicSky", root, boolean ) 
-- Skybox 2 = triggerEvent( "switchSkyAlt", root, boolean ) 
-- WaterShine = triggerEvent( "switchWaterShine", root, boolean ) 
-- Depth of Field = triggerEvent( "switchDoF", root, boolean ) 
-- Radial Blur = triggerEvent( "switchRadialBlur", root, boolean ) 
-- Chrome Wheels = replaceWheels(boolean)
-- bt Wheels = loadBTWheels(false)
-- Contrast = triggerEvent( "switchContrast", root, boolean )
-- Radar Shader = toggleRadar(boolean)
-- Nitro Shader = triggerEvent("e_ToggleNitroColor", root, boolean, hex)
-- Palette Shader = triggerEvent( "switchPalette", root, boolean )
-- Record Ghost = triggerEvent( "recordghost", root, boolean )
-- Local Ghost = triggerEvent( "localghost", root, boolean )
-- Best Ghost = triggerEvent( "bestghost", root, boolean )

-- GAMEPLAY FUNCTIONS, NEEDS TO BE ADDED TO OWN FILE SOON
-- NOS Mode = triggerEvent("setNitroType",root,type)

currentSkybox = false
currentCarPaint = false
timetosaveVisual = 5000
visual = { -- Standard Settings, 0 = off --
	["carpaint"] = 0, -- 1 = "fixed old carpaint", 2 = "reflect car paint"
	["water"] = 0, -- 1 = "water shader"
	["sky"] = 0, -- 1 = "dynamic sky", 2 = "sky box"
	["bloom"] = 0, -- 1 = "Fixed Bloom"
	["dof"] = 0, -- 1 = "Depth of field on"
	["enb"] = 0, -- 1 = "enb palette on"
	["chromewheels"] = 0, -- 1 = "Chrome Wheels on"
	["btwheels"] = 0, -- 1 = "bt Wheels on"
	["radar"] = 0, -- 1 = "Radar Shader on"
	["drawdistance"] = 0, -- 100 - 10000 = "valid draw distance"
	["fpslimit"] = 60, -- 25 - 100 = "valid fps limit"
	["fpslimitboats"] = 40, -- 25 - 100 = "valid fps limit"
	["contrast"] = 0, -- 1 = "contrast HDR on"
	["radial"] = 0, -- 1 = "Radial Blur on"
	["nitro"] = 0, -- 1 = "Nitro on"
	["recordghost"] = 1, -- 1 = "Record Ghost on"
	["localghost"] = 1, -- 1 = "local ghost on"
	["bestghost"] = 1, -- 1 = "best ghost on"
	["NOSMode"] = 1, -- 0 = "Old", 1 = "Hybrid", 2= "NFS"
	["nitrocolor"] = "0078FF",
}

	
-- Reapply settings when one of these resources (re)starts
local VSL_reApplyTimer = false
-- Add resource name here when used
local resetResource = {"-shaders-bloom_fix","-shaders-car_paint_fix","-shaders-car_paint_reflect","-shaders-contrast","-shaders-depth_of_field","-shaders-dynamic_sky","-shaders-nitro","-shaders-palette","-shaders-radial_blur","-shaders-SkyBox_ALT","-shaders-watershine","race","race_ghost", "race_fix"}
addEventHandler("onClientResourceStart",root,
	function(res)
		local resName = getResourceName(res)
		for _,rn in ipairs(resetResource) do
			if rn == resName then
				-- Timer system so no settings spam
				if isTimer(VSL_reApplyTimer) then killTimer(VSL_reApplyTimer) end
				VSL_reApplyTimer = setTimer(function() visual_LoadSettings() end,5000,1)
				break
			end
		end
	end
)


function visualCheckBoxHandler()
		--Bloom--
	if source == GUIEditor.checkbox["bloom"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["bloom"] ) then
			triggerEvent( "switchBloom", root, true )
			visual["bloom"] = 1
			v_setSaveTimer()
		else
			triggerEvent( "switchBloom", root, false )
			visual["bloom"] = 0
			v_setSaveTimer()
 		end

		--Contrast--
	elseif source == GUIEditor.checkbox["contrast"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["contrast"] ) then
			triggerEvent( "switchContrast", root, true )
			visual["contrast"] = 1
			v_setSaveTimer()
		else
			triggerEvent( "switchContrast", root, false )
			visual["contrast"] = 0
			v_setSaveTimer()
		end

		--Radar--
	elseif source == GUIEditor.checkbox["radar"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["radar"] ) then
			toggleRadar(true)
			visual["radar"] = 1
			v_setSaveTimer()
		else
			toggleRadar(false)
			visual["radar"] = 0
			v_setSaveTimer()
		end

		--water shader--
	elseif source == GUIEditor.checkbox["water"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["water"] ) then
			triggerEvent( "switchWaterShine", root, true ) 
			visual["water"] = 1
			v_setSaveTimer()
		else
			triggerEvent( "switchWaterShine", root, false ) 
			visual["water"] = 0
			v_setSaveTimer()
		end

		--Chrome Wheels--
	elseif source == GUIEditor.checkbox["chromewheels"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["chromewheels"] ) then
			guiCheckBoxSetSelected(GUIEditor.checkbox["btwheels"],false)

			loadBTWheels(false)
			replaceWheels(true)
			visual["chromewheels"] = 1
			visual["btwheels"] = 0
			v_setSaveTimer()
		else
			replaceWheels(false)
			visual["chromewheels"] = 0
			v_setSaveTimer()
		end

		--BT Wheels--
	elseif source == GUIEditor.checkbox["btwheels"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["btwheels"] ) then

			guiCheckBoxSetSelected(GUIEditor.checkbox["chromewheels"],false)
			replaceWheels(false)
			loadBTWheels(true)
			
			visual["btwheels"] = 1
			visual["chromewheels"] = 0
			v_setSaveTimer()
		else
			loadBTWheels(false)
			visual["btwheels"] = 0
			v_setSaveTimer()
		end

		--RoadShine--
	elseif source == GUIEditor.checkbox["palette"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["palette"] ) then
			triggerEvent( "switchPalette", root, true ) 
			visual["enb"] = 1
			v_setSaveTimer()
		else
			triggerEvent( "switchPalette", root, false ) 
			visual["enb"] = 0
			v_setSaveTimer()
		end

		--Depth of Field--
	elseif source == GUIEditor.checkbox["dof"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["dof"] ) then
			triggerEvent( "switchDoF", root, true ) 
			visual["dof"] = 1
			v_setSaveTimer()
		else
			triggerEvent( "switchDoF", root, false )
			visual["dof"] = 0 
			v_setSaveTimer()
		end

		--Radial Blur--
	elseif source == GUIEditor.checkbox["radialblur"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["radialblur"] ) then
			triggerEvent( "switchRadialBlur", root, true )
			visual["radial"] = 1
			v_setSaveTimer()
		else
			triggerEvent( "switchRadialBlur", root, false ) 
			visual["radial"] = 0
			v_setSaveTimer()
		end

		--SkyBox--
	elseif source == GUIEditor.checkbox["skybox"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["skybox"] ) then
			toggleSkyBox(true)
		else
			toggleSkyBox(false)
		end


		--CarPaint--
	elseif source == GUIEditor.checkbox["carpaint"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["carpaint"] ) then
			toggleCarPaint(true)
		else
			toggleCarPaint(false)
		end

			--Record Ghost--
	elseif source == GUIEditor.checkbox["recordghost"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["recordghost"] ) then
			triggerEvent("recordghost",root,true)
			v_setSaveTimer()
			visual["recordghost"] = 1
		else
			triggerEvent("recordghost",root,false)
			v_setSaveTimer()
			visual["recordghost"] = 0
		end

			--Local Ghost--
	elseif source == GUIEditor.checkbox["localghost"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["localghost"] ) then
			triggerEvent("localghost",root,true)
			v_setSaveTimer()
			visual["localghost"] = 1
		else
			triggerEvent("localghost",root,false)
			v_setSaveTimer()
			visual["localghost"] = 0
		end

			--Best Ghost--
	elseif source == GUIEditor.checkbox["bestghost"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["bestghost"] ) then
			triggerEvent("bestghost",root,true)
			v_setSaveTimer()
			visual["bestghost"] = 1
		else
			triggerEvent("bestghost",root,false)
			v_setSaveTimer()
			visual["bestghost"] = 0
		end

		--nitro--
	elseif source == GUIEditor.checkbox["nitro"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["nitro"] ) then
			triggerEvent("e_ToggleNitroColor", root, true, "#FF"..visual["nitrocolor"])
			v_setSaveTimer()
			visual["nitro"] = 1
		else
			triggerEvent("e_ToggleNitroColor", root, false)
			v_setSaveTimer()
			visual["nitro"] = 0
		end


	end
end
addEventHandler("onClientGUIClick", resourceRoot, visualCheckBoxHandler)

function visual_ButtonHandler()
	-- nitro --
	if source == GUIEditor.button["nitro"] then
		openPicker(100,"#"..visual["nitrocolor"],"Nitro Color")

		-- draw distance --
	elseif source == GUIEditor.button["drawdistance"] then
		local nr = tonumber(guiGetText( GUIEditor.edit["drawdistance"] ))

		if not nr then outputChatBox("Please insert a number before clicking ok.") return end
		if nr > 10000 or nr < 100 then outputChatBox("Draw Distance must be inbetween 100 and 10000.") return end

		setDrawDistance(nr)
		v_setSaveTimer()
		

	elseif source == GUIEditor.button["fpslimit"] then
		local nr = tonumber(guiGetText( GUIEditor.edit["fpslimit"] ))

		if not nr then outputChatBox("Please insert a number before clicking ok.") return end
		if nr > 100 or nr < 25 then outputChatBox("FPS limit must be inbetween 25 and 100.") return end

		setFPSLimit(nr)
		visual["fpslimit"] = nr
		v_setSaveTimer()
	
	elseif source == GUIEditor.button["fpslimitboats"] then
		local nr = tonumber(guiGetText( GUIEditor.edit["fpslimitboats"] ))
		
		if not nr then outputChatBox("Please insert a number before clicking ok.") return end
		if nr > 100 or nr < 25 then outputChatBox("FPS limit must be inbetween 25 and 100.") return end
		
		setElementData(localPlayer, "fpslimitboats", nr)
		visual["fpslimitboats"] = nr
		v_setSaveTimer()
	end
end
addEventHandler("onClientGUIClick", resourceRoot, visual_ButtonHandler)

function visual_comboBoxHandler()
	if source == GUIEditor.combobox["skybox"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["skybox"]) then
			toggleSkyBox(true)
		end
	elseif source == GUIEditor.combobox["carpaint"] then
		if guiCheckBoxGetSelected( GUIEditor.checkbox["carpaint"]) then
			toggleCarPaint(true)
		end

	elseif source == GUIEditor.combobox["NOSMode"] then
		local item = guiComboBoxGetSelected ( source )
        local text = guiComboBoxGetItemText ( source , item )

        if text == "old" or text == "nfs" or text == "hybrid" then
        	local t = getNOSModeName(item)
        	triggerEvent("setNitroType",root,t)
        	visual["NOSMode"] = tonumber(item)
        	v_setSaveTimer()
        end
	end
end
addEventHandler("onClientGUIComboBoxAccepted", resourceRoot, visual_comboBoxHandler)



function toggleSkyBox(bln)
	if bln then
		resetSkyBox()
		local theComboBoxNum = guiComboBoxGetSelected( GUIEditor.combobox["skybox"] )
		local theSelectedSkyBox = guiComboBoxGetItemText( GUIEditor.combobox["skybox"], theComboBoxNum )
		if theSelectedSkyBox == "Dynamic Sky" then
			triggerEvent( "ToggleDynamicSky", root, true ) 
			currentSkybox = theSelectedSkyBox
			visual["sky"] = 1
			v_setSaveTimer()
		elseif theSelectedSkyBox == "SkyBox 2" then
			triggerEvent( "switchSkyAlt", root, true ) 
			currentSkybox = theSelectedSkyBox
			visual["sky"] = 2
			v_setSaveTimer()
		end
	elseif not bln then
		resetSkyBox()
		visual["sky"] = 0
		v_setSaveTimer()
	end
end 		

function resetSkyBox()
	if currentSkybox == "Dynamic Sky" then
		triggerEvent( "ToggleDynamicSky", root, false )
	elseif currentSkybox == "SkyBox 2" then
		triggerEvent( "switchSkyAlt", root, false )

	else
		triggerEvent( "ToggleDynamicSky", root, false )
		triggerEvent( "switchSkyAlt", root, false )
	end
	currentSkybox = false
end



function toggleCarPaint(bln)
	if bln then
		resetCarPaint()
		local theComboBoxNum = guiComboBoxGetSelected( GUIEditor.combobox["carpaint"] )
		local theSelectedCarPaint = guiComboBoxGetItemText( GUIEditor.combobox["carpaint"], theComboBoxNum )
		if theSelectedCarPaint == "Car Paint 1" then
			triggerEvent( "switchCarPaint", root, true ) 
			currentCarPaint = theSelectedCarPaint
			visual["carpaint"] = 1
			v_setSaveTimer()
		elseif theSelectedCarPaint == "Car Paint 2" then
			triggerEvent( "switchCarPaintReflect", root, true ) 
			currentCarPaint = theSelectedCarPaint
			visual["carpaint"] = 2
			v_setSaveTimer()
		end
	elseif not bln then
		resetCarPaint()
		visual["carpaint"] = 0
		v_setSaveTimer()
	end
end 		

function resetCarPaint()
	if currentCarPaint == "Car Paint 1" then
		triggerEvent( "switchCarPaint", root, false )
	elseif currentCarPaint == "Car Paint 2" then
		triggerEvent( "switchCarPaintReflect", root, false )
	end
	currentCarPaint = false
end

function NitroColorHandler(id, color, alpha)
	if id == 100 then -- if it's the nitro colorpicker
		outputChatBox( "Nitro color is now: "..color.."COLOR", 255, 255, 255, true )
		guiSetProperty(NitroColorImage, "ImageColours", setIMGcolor(color))
		color = color:gsub("#","")
		visual["nitrocolor"] = color
		v_setSaveTimer()

		if guiCheckBoxGetSelected( GUIEditor.checkbox["nitro"] ) then
			triggerEvent("e_ToggleNitroColor", root, true, "#FF"..visual["nitrocolor"])
		end

		
	end
end
addEventHandler("onColorPickerOK", resourceRoot, NitroColorHandler)

function setDrawDistance(nr)
	if not nr then return end
	if nr >=100 and nr <= 100000 then
		setFarClipDistance( nr )
		visual["drawdistance"] = nr
	end
end

-- save and load --
function visual_LoadSettings()
	v_loadXML = xmlLoadFile( "settings/visualsettings2.xml" )
	if not v_loadXML then -- create when not exist
		v_loadXML = xmlCreateFile( "settings/visualsettings2.xml", "settings" )

		for f, u in pairs(visual) do -- set standard settings
			local theChild = xmlCreateChild( v_loadXML, tostring(f) )
			xmlNodeSetValue( theChild, u )
		end

		xmlSaveFile( v_loadXML )
	end

	for naam, value in pairs(visual) do -- Check if all settings are present in xml file
		if not xmlFindChild(v_loadXML,naam,0) then -- If settings is not in xml file
			local theChild = xmlCreateChild(v_loadXML,tostring(naam))
			xmlNodeSetValue(theChild,value)
			xmlSaveFile( v_loadXML )
		end
	end


	for w, c in pairs(visual) do -- Move settings to visual table --
		local theChild = xmlFindChild( v_loadXML, w, 0 )
		if not theChild then
			local theChild = xmlCreateChild( v_loadXML, w )
			xmlNodeSetValue( theChild, c )
		end
		if w ~= "nitrocolor" then -- nitrocolor is not a number value
			local val = xmlNodeGetValue( theChild )
			visual[w] = tonumber(val)
		else
			local val = xmlNodeGetValue( theChild )
			visual[w] = val
		end
	end

	xmlUnloadFile( v_loadXML )
	v_noSaveTimer = setTimer(function() end,8000, 1) -- dont save if this is active
	setVisualGUI()
	setTimer(setDrawDistance,30000,0,visual["drawdistance"])
end
addEventHandler("onClientResourceStart", resourceRoot, visual_LoadSettings)


function visual_SaveSettings()
	if not isTimer(v_noSaveTimer) then
		v_saveXML = xmlLoadFile("settings/visualsettings2.xml")

		for f, u in pairs(visual) do
			local theChild = xmlFindChild( v_saveXML, f, 0 )
			xmlNodeSetValue( theChild, u )
		end
		xmlSaveFile( v_saveXML )
		xmlUnloadFile( v_saveXML )
		outputChatBox("Settings Saved.")
	end
end

function v_setSaveTimer()
	if isTimer(visual_saveTimer) then
		killTimer(visual_saveTimer)
		visual_saveTimer = nil
	end
	visual_saveTimer = setTimer(visual_SaveSettings, timetosaveVisual, 1)
end


function setVisualGUI()
	for f, u in pairs(visual) do
		if f == "carpaint" then
			if u == 0 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["carpaint"], false )
			elseif u == 1 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["carpaint"], true )
				guiComboBoxSetSelected( GUIEditor.combobox["carpaint"], 2 )
				toggleCarPaint(true)
			elseif u == 2 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["carpaint"], true )
				guiComboBoxSetSelected( GUIEditor.combobox["carpaint"], 1 )
				toggleCarPaint(true)
			end


		elseif f == "water" then
			if u == 1 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["water"], true )
				triggerEvent( "switchWaterShine", root, true ) 

			end


		elseif f == "sky" then
			if u == 0 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["skybox"], false )
			elseif u == 1 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["skybox"], true )
				guiComboBoxSetSelected( GUIEditor.combobox["skybox"], 2 )
				toggleSkyBox(true)
			elseif u == 2 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["skybox"], true )
				guiComboBoxSetSelected( GUIEditor.combobox["skybox"], 1 )
				toggleSkyBox(true)
			end

		elseif f == "bloom" then
			if u == 1 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["bloom"], true )
				triggerEvent( "switchBloom", root, true )
			end


		elseif f == "dof" then
			if u == 1 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["dof"], true )
				triggerEvent( "switchDoF", root, true )
			end

		elseif f == "enb" then
			if u == 1 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["palette"], true )
				triggerEvent( "switchPalette", root, true )
			end

		elseif f == "chromewheels" then
			if u == 1 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["chromewheels"], true )
				loadBTWheels(false)
				replaceWheels(true)
			end

		elseif f == "btwheels" then
			if u == 1 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["btwheels"], true )
				replaceWheels(false)
				loadBTWheels(true)
			end

		elseif f == "radar" then
			if u == 1 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["radar"], true )
				toggleRadar(true)
			end

		elseif f == "recordghost" then
			if u == 1 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["recordghost"], true )
				triggerEvent("recordghost",root,true)
			else
				triggerEvent("recordghost",root,false)
			end

		elseif f == "localghost" then
			if u == 1 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["localghost"], true )
				triggerEvent("localghost",root,true)
			else
				triggerEvent("localghost",root,false)
			end

		elseif f == "bestghost" then
			if u == 1 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["bestghost"], true )
				triggerEvent("bestghost",root,true)
			else
				triggerEvent("bestghost",root,false)
			end

		elseif f == "drawdistance" then
			if u >= 100 and u <= 10000 then
				guiSetText( GUIEditor.edit["drawdistance"], u )
				setDrawDistance(u)
				setTimer(setDrawDistance,10000,1,u)
			else
				local distance = getFarClipDistance()
				if distance then
					guiSetText(GUIEditor.edit["drawdistance"], distance)
				end
			end

		elseif f == "fpslimit" then
			if u >= 25 and u <= 100 then
				guiSetText( GUIEditor.edit["fpslimit"], u )
				setFPSLimit(u)
				visual["fpslimit"] = u
			else
				local fpslimit = getFPSLimit()
				if fpslimit then
					guiSetText(GUIEditor.edit["fpslimit"], fpslimit)
				end
			end

		elseif f == "fpslimitboats" then
			if u >= 25 and u <= 100 then
				guiSetText( GUIEditor.edit["fpslimitboats"], u )
				setElementData(localPlayer, "fpslimitboats", u)
				visual["fpslimitboats"] = u
			else
				local fpslimit = getFPSLimit()
				if fpslimit then
					guiSetText(GUIEditor.edit["fpslimitboats"], fpslimit)
				end
			end
			
		elseif f == "contrast" then
			if u == 1 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["contrast"], true )
				triggerEvent( "switchContrast", root, true )
			end

		elseif f == "radial" then
			if u == 1 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["radialblur"], true )
				triggerEvent( "switchRadialBlur", root, true )
			end

		elseif f == "nitro" then
			if u == 1 then
				guiCheckBoxSetSelected( GUIEditor.checkbox["nitro"], true )
				guiSetProperty(NitroColorImage, "ImageColours", setIMGcolor(visual["nitrocolor"]))
				triggerEvent("e_ToggleNitroColor", root, true, "#FF"..visual["nitrocolor"])
			end

		elseif f == "NOSMode" then
			
			guiComboBoxSetSelected( GUIEditor.combobox["NOSMode"], u )
			local t = getNOSModeName(u)
			
			setTimer(function() triggerEvent("setNitroType", root, t) end,10000,1 )
			
			
		end
	end
end

function getNOSModeName(number)
	local number = tonumber(number)

	if number == 0 then
		return "old"
	elseif number == 1 then
		return "hybrid"
	elseif number == 2 then
		return "nfs"
	end
end


function resetVisualonStop()
	triggerEvent("e_ToggleNitroColor", root, false)
	triggerEvent( "switchRadialBlur", root, false )
	triggerEvent( "switchContrast", root, false )
	toggleRadar(false)
	toggleCarPaint(false)
	triggerEvent( "switchWaterShine", root, false )
	toggleSkyBox(false)
	triggerEvent( "switchBloom", root, false )
	triggerEvent( "switchDoF", root, false )
	triggerEvent( "switchPalette", root, false )
	replaceWheels(true)
	resetSkyBox()
end
addEventHandler("onClientResourceStop", resourceRoot, resetVisualonStop)
--util--

function setIMGcolor(hex)
	local hex = hex:gsub("#","")
	return "tl:FF"..hex.." tr:FF"..hex.." bl:FF"..hex.." br:FF"..hex
end
