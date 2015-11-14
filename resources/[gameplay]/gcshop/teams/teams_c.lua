local teamGUI

function onShopInit ( tabPanel )
	local GUIEditor
	teamTab = guiCreateTab("Teams", tabPanel)
	
	-- GUIEditor start --

	GUIEditor = {
		gridlist = {},
		tab = {},
		tabpanel = {},
		label = {}
	}
	GUIEditor.tabpanel[1] = guiCreateTabPanel(5, 5, 715, 414, false, teamTab)

	GUIEditor.tab[1] = guiCreateTab("Your team", GUIEditor.tabpanel[1])

	GUIEditor.label[1] = guiCreateLabel(46, 22, 634, 55, "Create your own team! You will be able to set a team name, tag, colour, welcome message and invite players to your team. Teams expire after 30 days, but everyone in the team can renew the team duration. You can only own one team or be in one team. If you create/join a team, you can't create/join any other team for 30 days.", false, GUIEditor.tab[1])
	guiLabelSetHorizontalAlign(GUIEditor.label[1], "left", true)
	GUIEditor.btnBuyTeam = guiCreateButton(46, 263, 165, 50, "Create team\n2500 GC / 30 days", false, GUIEditor.tab[1])
	guiSetProperty(GUIEditor.btnBuyTeam, "Disabled", "True")
	guiSetProperty(GUIEditor.btnBuyTeam, "NormalTextColour", "FFAAAAAA")
	GUIEditor.label[2] = guiCreateLabel(46, 111, 73, 28, "Team name", false, GUIEditor.tab[1])
	guiLabelSetVerticalAlign(GUIEditor.label[2], "center")
	GUIEditor.teamname = guiCreateEdit(145, 111, 228, 28, "", false, GUIEditor.tab[1])
	guiSetProperty(GUIEditor.teamname, "Disabled", "True")
	GUIEditor.label[3] = guiCreateLabel(46, 149, 73, 28, "Team tag", false, GUIEditor.tab[1])
	guiLabelSetVerticalAlign(GUIEditor.label[3], "center")
	GUIEditor.teamtag = guiCreateEdit(145, 149, 74, 28, "", false, GUIEditor.tab[1])
	guiSetProperty(GUIEditor.teamtag, "Disabled", "True")
	GUIEditor.label[4] = guiCreateLabel(46, 187, 73, 28, "Team colour", false, GUIEditor.tab[1])
	guiLabelSetVerticalAlign(GUIEditor.label[4], "center")
	GUIEditor.teamcolour = guiCreateEdit(145, 187, 74, 28, "#FFFFFF", false, GUIEditor.tab[1])
	guiSetProperty(GUIEditor.teamcolour, "Disabled", "True")
	GUIEditor.teammsg = guiCreateEdit(145, 225, 228, 28, "", false, GUIEditor.tab[1])
	guiSetProperty(GUIEditor.teammsg, "Disabled", "True")
	GUIEditor.chkIgnore = guiCreateCheckBox(46, 335, 204, 29, " Don't show me team invites", false, false, GUIEditor.tab[1])
	guiSetProperty(GUIEditor.chkIgnore, "Disabled", "True")
	GUIEditor.gridMembers = guiCreateGridList(419, 107, 261, 202, false, GUIEditor.tab[1])
	guiGridListAddColumn(GUIEditor.gridMembers, "Members", 0.9)
	guiSetProperty(GUIEditor.gridMembers, "SortSettingEnabled", "False")
	GUIEditor.btnInvite = guiCreateButton(272, 332, 114, 32, "/Invite player", false, GUIEditor.tab[1])
	guiSetVisible(GUIEditor.btnInvite, false)
	guiSetProperty(GUIEditor.btnInvite, "NormalTextColour", "FFAAAAAA")
	GUIEditor.btnKick = guiCreateButton(419, 332, 114, 32, "Kick player", false, GUIEditor.tab[1])
	guiSetVisible(GUIEditor.btnKick, false)
	guiSetProperty(GUIEditor.btnKick, "NormalTextColour", "FFAAAAAA")
	GUIEditor.btnLeave = guiCreateButton(566, 332, 114, 32, "Leave team", false, GUIEditor.tab[1])
	guiSetVisible(GUIEditor.btnLeave, false)
	guiSetProperty(GUIEditor.btnLeave, "NormalTextColour", "FFAAAAAA")
	GUIEditor.label[5] = guiCreateLabel(46, 225, 83, 28, "Welcome msg", false, GUIEditor.tab[1])
	guiLabelSetVerticalAlign(GUIEditor.label[5], "center")

	GUIEditor.tab[2] = guiCreateTab("Teams", GUIEditor.tabpanel[1])

	GUIEditor.gridlist[1] = guiCreateGridList(48, 40, 608, 304, false, GUIEditor.tab[2])
	guiGridListAddColumn(GUIEditor.gridlist[1], "Team", 0.5)
	guiGridListAddColumn(GUIEditor.gridlist[1], "Member", 0.5)

	-- GUIEditor end --
	
	guiSetVisible(GUIEditor.chkIgnore, false)
	teamGUI = GUIEditor
	addEventHandler('onClientGUIClick', GUIEditor.btnBuyTeam, buyTeam, false)
	addEventHandler('onClientGUIClick', GUIEditor.btnKick, kickTeam, false)
	addEventHandler('onClientGUIClick', GUIEditor.btnLeave, leaveTeam, false)
	addEventHandler('onClientGUIClick', GUIEditor.btnInvite, inviteTeam, false)
end
addEvent('onShopInit', true)
addEventHandler('onShopInit', root, onShopInit )

addEvent("teamLogin", true)
addEventHandler("teamLogin", root, function()
	guiSetProperty(teamGUI.btnBuyTeam, "Disabled", "False")
	guiSetProperty(teamGUI.teamname, "Disabled", "False")
	guiSetProperty(teamGUI.teamtag, "Disabled", "False")
	guiSetProperty(teamGUI.teammsg, "Disabled", "False")
	guiSetProperty(teamGUI.teamcolour, "Disabled", "False")
end)

addEvent("teamsData", true)
addEventHandler("teamsData", root, function(teams, player, t)
	-- Update teamlists
	local g = teamGUI.gridlist[1]
	local g2 = teamGUI.gridMembers
	guiGridListClear(g)
	guiGridListClear(teamGUI.gridMembers)
	local teamid, i
	for r, z in ipairs(teams) do
		if teamid ~= z.teamid then
			teamid = z.teamid
			i = guiGridListAddRow(g)
			guiGridListSetItemText(g, i, 1, z.teamid .. '. ' .. z.tag .. ' ' .. z.name, true, false)
		end
		if z.status == 1 then
			i = guiGridListAddRow(g)
			guiGridListSetItemText(g, i, 2, string.gsub(z.mta_name,"#%x%x%x%x%x%x","") .. (z.forumid == z.owner and ' (Owner)' or ''), false, false)
		end
	end
	for r, z in ipairs(teams) do
		if t and t.teamid == z.teamid and z.status == 1 then
			i = guiGridListAddRow(g2)
			guiGridListSetItemText(g2, i, 1, string.gsub(z.mta_name,"#%x%x%x%x%x%x","") .. (z.forumid == z.owner and ' (Owner)' or ''), false, false)
			guiGridListSetItemData(g2, i, 1, z.forumid, false, false)
		end
	end
	if not t or player ~= localPlayer then return end
	if t.status == 1 then
		guiSetText(teamGUI.btnBuyTeam, "Renew team\n2500 GC / 30 days")
		
		guiSetEnabled(teamGUI.teamname, false)
		guiSetEnabled(teamGUI.teamtag, false)
		guiSetEnabled(teamGUI.teammsg, false)
		guiSetEnabled(teamGUI.teamcolour, false)
		guiSetText(teamGUI.teamname, t.name)
		guiSetText(teamGUI.teamtag, t.tag)
		guiSetText(teamGUI.teammsg, t.message or '')
		guiSetText(teamGUI.teamcolour, t.colour)
		
		guiSetText(teamGUI.btnLeave, "Leave team")
		guiSetVisible(teamGUI.btnLeave, true)
		guiSetVisible(teamGUI.btnInvite, t.forumid == t.owner)
		guiSetVisible(teamGUI.btnKick, t.forumid == t.owner)
	else
		guiSetText(teamGUI.btnBuyTeam, "Buy team\n2500 GC / 30 days")
		
		guiSetEnabled(teamGUI.teamname, true)
		guiSetEnabled(teamGUI.teamtag, true)
		guiSetEnabled(teamGUI.teammsg, true)
		guiSetEnabled(teamGUI.teamcolour, true)
		guiSetText(teamGUI.teamname, '')
		guiSetText(teamGUI.teamtag, '')
		guiSetText(teamGUI.teammsg, '')
		guiSetText(teamGUI.teamcolour, '#FFFFFF')
		
		if t.status == 0 then
			guiSetVisible(teamGUI.btnLeave, true)
			guiSetText(teamGUI.btnLeave, "Rejoin team")
		else
			guiSetVisible(teamGUI.btnLeave, false)
		end
		guiSetVisible(teamGUI.btnInvite, false)
		guiSetVisible(teamGUI.btnKick, false)
	end
end)

-- Buying/extending team --
function buyTeam (btn)
	triggerServerEvent('buyTeam', resourceRoot, guiGetText(teamGUI.teamname), guiGetText(teamGUI.teamtag), guiGetText(teamGUI.teamcolour), guiGetText(teamGUI.teammsg))
end

function kickTeam(btn)
	local r, c = guiGridListGetSelectedItem(teamGUI.gridMembers)
	if r == -1 or c == -1 then return end
	local forumid = tonumber(guiGridListGetItemData(teamGUI.gridMembers, r, c))
	if not forumid then return end
	triggerServerEvent('cmd', resourceRoot, 'teamkick', tostring(forumid))
end

function leaveTeam (btn)
	triggerServerEvent('cmd', resourceRoot, guiGetText(teamGUI.btnLeave) == "Leave team" and 'leave' or 'rejoin')
end

function inviteTeam (btn)
	--Create the grid list element
	local playerWindow = guiCreateWindow ( 0.80, 0.10, 0.15, 0.60, "Team invite", true )
	local playerList = guiCreateGridList ( 0.05, 0.05, 0.9, 0.55, true, playerWindow )
	local inviteBtn = guiCreateButton(0.05, 0.60, .9, .15, "Invite", true, playerWindow)
	local closeBtn = guiCreateButton(0.05, 0.80, .9, .15, "Close", true, playerWindow)
	--Create a players column in the list
	local column = guiGridListAddColumn( playerList, "Invite", 0.85 )
	if ( column ) then --If the column has been created, fill it with players
		for id, player in ipairs(getElementsByType("player")) do
			local row = guiGridListAddRow ( playerList )
			guiGridListSetItemText ( playerList, row, column, string.gsub(getPlayerName ( player ),"#%x%x%x%x%x%x",""), false, false )
		end
	end
	addEventHandler('onClientGUIClick', inviteBtn, function() 
		local r, c = guiGridListGetSelectedItem(playerList)
		if r == -1 or c == -1 then return end
		local name = guiGridListGetItemText(playerList, r, c)
		triggerServerEvent('cmd', resourceRoot, 'invite', name)
		destroyElement(playerWindow)
	end, false)
	addEventHandler('onClientGUIClick', closeBtn, function() destroyElement(playerWindow) end, false)

end

