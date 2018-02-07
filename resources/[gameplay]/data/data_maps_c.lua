function clientResourceStart()
end
addEventHandler('onClientResourceStart', getResourceRootElement(),clientResourceStart)

function buttonTrigger(button, state)
	if state == "up" and button == "left" then
		if source == GUI.button[1] or source == GUI_maps.button[1] or source == resourceRoot then
			local bool = not guiGetVisible(GUI_maps.window[1])
			guiSetVisible(GUI_maps.window[1],bool)
			showCursor(bool)
			if bool then
				guiSetInputMode("no_binds_when_editing")
				triggerServerEvent("data_maps_fetchData_s", resourceRoot, localPlayer)
			else
				guiSetInputMode("allow_binds")
			end
		end
	end
end
addEvent("data_maps_buttonTrigger",true)
addEventHandler("data_maps_buttonTrigger",root,buttonTrigger)

function fetchData_c(t)
	guiGridListClear(GUI_maps.gridlist[1])
	for a,b in ipairs(t) do
		local row = guiGridListAddRow(GUI_maps.gridlist[1])
		guiGridListSetItemText(GUI_maps.gridlist[1],row,1,tostring(t[a][1]),false,false)
		guiGridListSetItemText(GUI_maps.gridlist[1],row,2,tostring(t[a][2]),false,false)
		guiGridListSetItemText(GUI_maps.gridlist[1],row,3,tostring(t[a][3]),false,false)
		guiGridListSetItemText(GUI_maps.gridlist[1],row,4,tostring(t[a][4]),false,true)
		guiGridListSetItemText(GUI_maps.gridlist[1],row,5,tostring(t[a][5]),false,true)
		guiGridListSetItemText(GUI_maps.gridlist[1],row,6,tostring(t[a][6]),false,true)
		guiGridListSetItemText(GUI_maps.gridlist[1],row,7,tostring(t[a][7]),false,true)
	end
	
	hypothesisTesting(t)
end
addEvent("data_maps_fetchData_c",true)
addEventHandler("data_maps_fetchData_c",root,fetchData_c)

function hypothesisTesting(t)
	local maps = #t
	guiSetText(GUI_maps.label[12], tostring(maps)) -- set # maps
	
	local targetObs = maps * 5
	guiSetText(GUI_maps.label[13], tostring(targetObs)) -- set target obs
	
	local obs = 0
	local i = 0
	while i < #t do
		i = i + 1
		obs = obs + t[i][4]
	end
	guiSetText(GUI_maps.label[14], tostring(obs)) -- set obs
	if obs < targetObs then guiLabelSetColor(GUI_maps.label[14], 255, 0, 0) end
	
	local EPrXi = 1 / maps
	local EPrXiFloor = math.floor(EPrXi * 1000) / 1000
	guiSetText(GUI_maps.label[15], tostring(EPrXiFloor)) -- set expected probability
	
	guiSetText(GUI_maps.label[16], tostring(EPrXiFloor)) -- set H0
	
	local chi = 0
	local Eob = obs / maps
	i = 0
	while i < #t do
		i = i + 1
		local ob = t[i][4] / maps
		chi = chi + (math.pow(ob - Eob, 2) / Eob)
	end
	chiFloor = math.floor(chi * 1000) / 1000
	guiSetText(GUI_maps.label[17], tostring(chiFloor)) -- set chi squared
	
	local alpha = 0.05
	guiSetText(GUI_maps.label[18], tostring(alpha)) -- set alpha level
	
	local chiCritical = AChiSq(alpha,maps - 1)
	guiSetText(GUI_maps.label[19], tostring(chiCritical)) -- set critical chi squared
	
	if chi > chiCritical then -- Reject H0
		guiSetText(GUI_maps.label[20], "Reject H0")
		if obs >= targetObs then
			guiSetText(GUI_maps.label[2], "No")
			guiLabelSetColor(GUI_maps.label[2], 255, 0, 0)
		end
	else
		guiSetText(GUI_maps.label[20], "Do not reject H0")
		if obs >= targetObs then
			guiSetText(GUI_maps.label[2], "Yes")
			guiLabelSetColor(GUI_maps.label[2], 0, 255, 0)
		end
	end
end