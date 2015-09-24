socialSettings = { -- default settings
	["pm"] = false,
	["chatbox"] = false,
}
receiveChatMessages = true

function socialCheckBoxHandler()
	-- Disable Private Messages --
	if source == GUIEditor.checkbox[17] then
		if guiCheckBoxGetSelected( source ) then
			triggerServerEvent( "client_TogglePM", getResourceRootElement( getResourceFromName( "privateMessaging" )), false, false )
			socialSettings["pm"] = true

			if isTimer( saveSocialTimer ) then
				killTimer( saveSocialTimer )
			end
			saveSocialTimer = setTimer(saveSocial,2000,1)

			
		elseif not guiCheckBoxGetSelected( source ) then
			triggerServerEvent( "client_TogglePM", getResourceRootElement( getResourceFromName( "privateMessaging" )), true, false )
			socialSettings["pm"] = false

			if isTimer( saveSocialTimer ) then
				killTimer( saveSocialTimer )
			end
			saveSocialTimer = setTimer(saveSocial,2000,1)
		end
	elseif source == GUIEditor.checkbox[18] then
		if guiCheckBoxGetSelected(source) then
			outputChatBox("Chatbox messages turned off!",255,0,0)
			receiveChatMessages = false
			socialSettings["chatbox"] = true

			if isTimer( saveSocialTimer ) then
				killTimer( saveSocialTimer )
			end
			saveSocialTimer = setTimer(saveSocial,2000,1)
		else
			socialSettings["chatbox"] = false
			receiveChatMessages = true
			outputChatBox("Chatbox Messages turned on!",0,255,0)

			if isTimer( saveSocialTimer ) then
				killTimer( saveSocialTimer )
			end
			saveSocialTimer = setTimer(saveSocial,2000,1)
		end
	end
end
addEventHandler( "onClientGUIClick", resourceRoot, socialCheckBoxHandler )

-- Reapply settings when one of these resources (re)starts
local SOC_reApplyTimer = false
-- Add resource name here when used
local resetResource = {"privateMessaging","race"}
addEventHandler("onClientResourceStart",root,
    function(res)
        local resName = getResourceName(res)
        for _,rn in ipairs(resetResource) do
            if rn == resName then
                -- Timer system so no settings spam
                if isTimer(SOC_reApplyTimer) then killTimer(SOC_reApplyTimer) end
                SOC_reApplyTimer = setTimer(function() setSocialSettings() end,5000,1)
                break
            end
        end
    end
)

function socialButtonHandler()
	-- Manage Ignored Players button --
	if source == GUIEditor.button[4] then
		showIgnorePlayerlist()
	-- Ignore Close Button
	elseif source == ignorePlayerCloseButton then
		guiSetVisible( ignorePlayerWindow, false )
	-- Ignore Remove Player Button
	elseif source == removePlayerButton then
		local theSelected = guiGridListGetSelectedItem( ignorePlayerGridlist )
		if guiGridListGetSelectedItem( ignorePlayerGridlist ) ~= -1 then
			local theName = guiGridListGetItemText( ignorePlayerGridlist, theSelected, ignoredplayerColumn )
			local theSerial = guiGridListGetItemData( ignorePlayerGridlist, theSelected, ignoredplayerColumn )
			removePlayerfromIgnoreList(theSerial)

			outputChatBox("Removed "..tostring(theName).." from the ignore list.")
		else
			outputChatBox("Please select a player before removing it from the list.",255,0,0)
		end

	end
end
addEventHandler( "onClientGUIClick", resourceRoot, socialButtonHandler )



function saveSocial()
	saveSocialXML = xmlLoadFile( "/settings/socialsettings.xml" )
	if not saveSocialXML then
		saveSocialXML = xmlCreateFile( "/settings/socialsettings.xml", "settings" )
		for f, u in pairs(socialSettings) do
			local theChild = xmlCreateChild( saveSocialXML, tostring(f) )
			xmlNodeSetValue( theChild, tostring(u) )
		end
	elseif saveSocialXML then
		for f, u in pairs(socialSettings) do
			local theChild = xmlFindChild( saveSocialXML, tostring(f), 0 )
			if not theChild then
				local thenewChild = xmlCreateChild( saveSocialXML, tostring(f) )
				xmlNodeSetValue( thenewChild, tostring(u) )
			end
			xmlNodeSetValue( theChild, tostring(u) )
		end
	end
	xmlSaveFile( saveSocialXML )
	xmlUnloadFile( saveSocialXML )
end

function loadSocial()
	loadSocialXML = xmlLoadFile("/settings/socialsettings.xml")
	if not loadSocialXML then
		loadSocialXML = xmlCreateFile("/settings/socialsettings.xml", "settings")
		for f, u in pairs(socialSettings) do
			local theChild = xmlCreateChild( loadSocialXML, tostring(f) )
			xmlNodeSetValue( theChild, tostring(u) )
		end
		xmlSaveFile(loadSocialXML)
	elseif loadSocialXML then
		for f, u in pairs(xmlNodeGetChildren( loadSocialXML )) do
			local name = xmlNodeGetName( u )
			socialSettings[tostring(name)] = toBoolean(xmlNodeGetValue( u ))
		end
	end
	xmlUnloadFile( loadSocialXML )
	setSocialGUI()
	setSocialSettings()
end
addEventHandler("onClientResourceStart", resourceRoot, loadSocial)

function setSocialGUI()
	for f, u in pairs(socialSettings) do
		if f == "pm" then
			if u then
				guiCheckBoxSetSelected( GUIEditor.checkbox[17], true )
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox[17], false )
			end
		elseif f == "chatbox" then
			if u then
				guiCheckBoxSetSelected( GUIEditor.checkbox[18], true )
			else
				guiCheckBoxSetSelected( GUIEditor.checkbox[18], false )
			end
		end
	end
end


function setSocialSettings()
	for f, u in pairs(socialSettings) do
		if f == "pm" then
			if u then
				triggerServerEvent( "client_TogglePM", getResourceRootElement( getResourceFromName( "privateMessaging" )), false, false )
			else
				-- triggerServerEvent( "client_TogglePM", getResourceRootElement( getResourceFromName( "privateMessaging" )), true, false )
			end
		elseif f == "chatbox" then
			if u then
				
				setTimer(setDisableChatMessages,2000,1)
			else
				-- setTimer(function() receiveChatMessages = true end,2000,1)
			end
		end
	end
end

function setDisableChatMessages()
	outputChatBox("Chatbox Messages Disabled (you can still see admin messages), go to the /settings menu to enable it again.",255,0,0)
	receiveChatMessages = false
end


-- Disable Chat ---
-------------------
-------------------
adminTable = {}
function disableChatbox(msg)
	if receiveChatMessages == false and #adminTable > 0 then
		for f, u in pairs(adminTable) do
			if isElement(u) then


				local playerName = string.gsub(getPlayerName(u), '#%x%x%x%x%x%x', '')
				local nameLength = #playerName
				local _msg = string.gsub(msg, '#%x%x%x%x%x%x', '') -- strip colors
				local msg_comp = string.sub(_msg,1,nameLength)
				local name_comp = string.sub(playerName,1,nameLength)
				-- outputDebugString(msg_comp.." "..name_comp)
				if name_comp == msg_comp then -- Admins will not get ignored --
					return
				else
					cancelEvent()
				end
			else
				cancelEvent()
			end
		end
	end
end
addEventHandler("onClientChatMessage", root, disableChatbox)

addEvent("receiveAdminTable", true)
function getAllAdmins(t)
	adminTable = t
end
addEventHandler("receiveAdminTable", resourceRoot, getAllAdmins)

function askAdminTable()
	triggerServerEvent( "requestAdminTable", resourceRoot )
end
addEventHandler("onClientResourceStart",resourceRoot,askAdminTable)
-- IGNORE SCRIPT --
-------------------
-------------------


ignoredPlayers = {} 


function findPlayerByName(playerPart)
	local pl = playerPart and getPlayerFromName(playerPart)
	if pl and isElement(pl) then
		return pl
	elseif playerPart then
		for i,v in ipairs (getElementsByType ("player")) do
			if (string.find(string.gsub ( string.lower(getPlayerName(v)), '#%x%x%x%x%x%x', '' ),string.lower(playerPart))) then
				return v
			end
		end
    end
 end
 
function ignorePlayer(cmd, playername)
	local player = findPlayerByName(playername)
	if player == localPlayer then
		outputChatBox ( "You can't ignore yourself!", 255, 0, 0 )
	elseif not player then
		outputChatBox ( '/ignore: Could not find \'' .. (playername or '') .. '\'', 255, 0, 0 )
	else
		if getElementData(player, "pser") ~= "admin" then -- if player is not admin
			outputChatBox ( '/ignore: ignoring player ' .. getPlayerName(player), 255, 0, 0 )

			local theName = getPlayerName(player)
			local theSer = getElementData( player, "pser")
			local theName = string.gsub(theName, '#%x%x%x%x%x%x', '')
			local theName = string.gsub(theName, '%W','')
			ignoredPlayers[theSer] = theName -- add to table
			saveIgnoredPlayers()
			reloadIgnoreGridList()
		else
			outputChatBox("You can't ignore an admin.")
		end

	end
end
addCommandHandler ( 'ignore', ignorePlayer)



function onClientChatMessageHandler( text )
	local text_firstThreeChar = string.sub(text,1,3)
	if tablelength(ignoredPlayers) == 0 or not text then return end

	for key, plyr in pairs(getElementsByType("player")) do

		local playername = getPlayerName( plyr )
		local playername_firstThreeChar = string.sub(playername,1,3)

		if text_firstThreeChar == playername_firstThreeChar then -- if first three letters match

			local playerserial = getElementData( plyr, "pser")
			local findplayername = text:find(playername,1,true)

			if findplayername and ignoredPlayers[playerserial] and playerserial ~= "admin" then
				return cancelEvent()
			end
		end
	end
end
addEventHandler("onClientChatMessage", getRootElement(), onClientChatMessageHandler)

function removePlayerfromIgnoreList(theSer)
	if not theSer then return false end
	if ignoredPlayers[theSer] then
		ignoredPlayers[theSer] = nil
	end
	local theXML = xmlLoadFile( "/settings/ignoredplayers.xml" )
	local theXMLTable = xmlNodeGetChildren( theXML )
	for f, u in pairs(theXMLTable) do
		if theSer == xmlNodeGetAttribute( u, "serial" ) then
			xmlDestroyNode( u )
			xmlSaveFile(theXML)
		end
	end
	xmlUnloadFile(theXML)

	reloadIgnoreGridList()
end

function reloadIgnoreGridList()
	guiGridListClear( ignorePlayerGridlist )
	for f, u in pairs(ignoredPlayers) do
		local theRow = guiGridListAddRow( ignorePlayerGridlist )
		guiGridListSetItemText( ignorePlayerGridlist, theRow, ignoredplayerColumn, tostring(u), false, false )
		guiGridListSetItemData( ignorePlayerGridlist, theRow, ignoredplayerColumn, tostring(f) )
	end
end




function saveIgnoredPlayers()
	ignoredXML = xmlLoadFile( "/settings/ignoredplayers.xml" )
	if not ignoredXML then
		ignoredXML = xmlCreateFile( "/settings/ignoredplayers.xml", "players" )
	end
	for f, u in pairs(ignoredPlayers) do
		ignoredPlayerNode = xmlFindChild( ignoredXML, tostring(u), 0 )
		if not ignoredPlayerNode then
			ignoredPlayerNode = xmlCreateChild( ignoredXML, tostring(u) )
			xmlNodeSetAttribute( ignoredPlayerNode, "name", tostring(u) )
			xmlNodeSetAttribute( ignoredPlayerNode, "serial", tostring(f) )
		end
	end


	xmlSaveFile( ignoredXML )
	xmlUnloadFile( ignoredXML )
end

function loadIgnoredPlayers()
	load_ignoredXML = xmlLoadFile("/settings/ignoredplayers.xml")
	if load_ignoredXML then
		local theNodesTable = xmlNodeGetChildren( load_ignoredXML )
			for f, u in pairs(theNodesTable) do
				local name = xmlNodeGetAttribute( u, "name" )
				local ser = xmlNodeGetAttribute(u, "serial")
				ignoredPlayers[ser] = name
			end
		xmlUnloadFile( load_ignoredXML )
	end
	reloadIgnoreGridList()
end
addEventHandler( "onClientResourceStart", resourceRoot, loadIgnoredPlayers)


function isPlayerIgnoredPM(plyr)
	local srl = getElementData(plyr,"pser")
	if not srl then return false end
	if srl == "admin" then return false end
	if ignoredPlayers[srl] then return true end
	return false
end


------ Utils ------
-------------------
-------------------
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end