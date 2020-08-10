local teamGUI
local mapList = {}
local teamList = {}
local teamsGUI
local teamsDataSet = false
local cachedTeamsData = {
	teams = false,
	player = false,
	t = false
}

function onShopInit ( tabPanel )

	teamTab = guiCreateTab("Teams", tabPanel)

	-- teamsGUI start --

	teamsGUI = {
		edit = {},
		gridlist = {},
		image = {},
		scrollpane = {},
		tab = {},
		tabpanel = {},
		label = {},
		window = {}
	}
	teamsGUI.tabpanel[1] = guiCreateTabPanel(5, 5, 715, 414, false, teamTab)

	teamsGUI.tab[1] = guiCreateTab("Your team", teamsGUI.tabpanel[1])

	teamsGUI.label[1] = guiCreateLabel(46, 22, 634, 55, "Create your own team! You will be able to set a team name, tag, colour, welcome message and invite players to your team. Teams expire after 20/40/60 days, but everyone in the team can refresh the team duration (Up to 60 days). Clan owners can transfer ownership with /makeowner PlayerName with color code.", false, teamsGUI.tab[1])
	guiLabelSetHorizontalAlign(teamsGUI.label[1], "left", true)
	teamsGUI.btnBuyTeam = guiCreateButton(46, 263, 165, 50, "Create team\n2750 GC / 20 days", false, teamsGUI.tab[1])
	guiSetProperty(teamsGUI.btnBuyTeam, "Disabled", "True")
	guiSetProperty(teamsGUI.btnBuyTeam, "NormalTextColour", "FFAAAAAA")
	teamsGUI.btnUpdateTeam = guiCreateButton(212, 263, 165, 50, "Save changes\n100 GC", false, teamsGUI.tab[1])
	guiSetVisible(teamsGUI.btnUpdateTeam, false)
	teamsGUI.label[2] = guiCreateLabel(46, 111, 73, 28, "Team name", false, teamsGUI.tab[1])
	guiLabelSetVerticalAlign(teamsGUI.label[2], "center")
	teamsGUI.teamname = guiCreateEdit(145, 111, 228, 28, "", false, teamsGUI.tab[1])
	guiSetProperty(teamsGUI.teamname, "Disabled", "True")
	teamsGUI.label[3] = guiCreateLabel(46, 149, 73, 28, "Team tag", false, teamsGUI.tab[1])
	guiLabelSetVerticalAlign(teamsGUI.label[3], "center")
	teamsGUI.teamtag = guiCreateEdit(145, 149, 74, 28, "", false, teamsGUI.tab[1])
	guiSetProperty(teamsGUI.teamtag, "Disabled", "True")
	teamsGUI.label[4] = guiCreateLabel(46, 187, 73, 28, "Team colour", false, teamsGUI.tab[1])
	guiLabelSetVerticalAlign(teamsGUI.label[4], "center")
	teamsGUI.teamcolour = guiCreateEdit(145, 187, 74, 28, "#FFFFFF", false, teamsGUI.tab[1])
	guiSetProperty(teamsGUI.teamcolour, "Disabled", "True")
	teamsGUI.teammsg = guiCreateEdit(145, 225, 228, 28, "", false, teamsGUI.tab[1])
	guiSetProperty(teamsGUI.teammsg, "Disabled", "True")
	teamsGUI.chkIgnore = guiCreateCheckBox(46, 335, 204, 29, " Don't show me team invites", false, false, teamsGUI.tab[1])
	guiSetProperty(teamsGUI.chkIgnore, "Disabled", "True")
	teamsGUI.gridMembers = guiCreateGridList(419, 107, 261, 202, false, teamsGUI.tab[1])
	guiGridListAddColumn(teamsGUI.gridMembers, "Members", 0.9)
	guiSetProperty(teamsGUI.gridMembers, "SortSettingEnabled", "False")
	teamsGUI.btnInvite = guiCreateButton(272, 332, 114, 32, "/Invite player", false, teamsGUI.tab[1])
	guiSetVisible(teamsGUI.btnInvite, false)
	guiSetProperty(teamsGUI.btnInvite, "NormalTextColour", "FFAAAAAA")
	teamsGUI.btnKick = guiCreateButton(419, 332, 114, 32, "Kick player", false, teamsGUI.tab[1])
	guiSetVisible(teamsGUI.btnKick, false)
	guiSetProperty(teamsGUI.btnKick, "NormalTextColour", "FFAAAAAA")
	teamsGUI.btnLeave = guiCreateButton(566, 332, 114, 32, "Leave team", false, teamsGUI.tab[1])
	guiSetVisible(teamsGUI.btnLeave, false)
	guiSetProperty(teamsGUI.btnLeave, "NormalTextColour", "FFAAAAAA")
	teamsGUI.label[5] = guiCreateLabel(46, 225, 83, 28, "Welcome msg", false, teamsGUI.tab[1])
	guiLabelSetVerticalAlign(teamsGUI.label[5], "center")

	teamsGUI.tab[2] = guiCreateTab("Teams", teamsGUI.tabpanel[1])

	teamsGUI.gridlist[1] = guiCreateGridList(48, 40, 608, 304, false, teamsGUI.tab[2])
	teamsGUI.teamCol = guiGridListAddColumn(teamsGUI.gridlist[1], "Team", 0.5)
	teamsGUI.meemberCol = guiGridListAddColumn(teamsGUI.gridlist[1], "Member", 0.5)

	teamsGUI.tab[3] = guiCreateTab("Team Wars", teamsGUI.tabpanel[1])

	teamsGUI.label[6] = guiCreateLabel(46, 22, 128, 16, "Select maps, update 7", false, teamsGUI.tab[3])
	guiSetFont(teamsGUI.label[6], "default-bold-small")
	teamsGUI.label[7] = guiCreateLabel(46, 38, 256, 16, "Select maps to be played in a Team War: ", false, teamsGUI.tab[3])
	teamsGUI.gridlist[2] = guiCreateGridList(48, 58, 256, 256, false, teamsGUI.tab[3])
	guiGridListAddColumn(teamsGUI.gridlist[2], "Map", 0.5)
	guiGridListAddColumn(teamsGUI.gridlist[2], "Author", 0.5)
	guiGridListAddColumn(teamsGUI.gridlist[2], "resname", 0.5)
	guiGridListSetSortingEnabled(teamsGUI.gridlist[2], false)
	teamsGUI.gridlist[3] = guiCreateGridList(406, 58, 256, 256, false, teamsGUI.tab[3])
	guiGridListAddColumn(teamsGUI.gridlist[3], "Map", 0.5)
	guiGridListAddColumn(teamsGUI.gridlist[3], "Author", 0.5)
	guiGridListAddColumn(teamsGUI.gridlist[3], "resname", 0.5)
	guiGridListSetSortingEnabled(teamsGUI.gridlist[3], false)
	teamsGUI.btnTWAdd = guiCreateButton(312, 154, 64, 24, "Add >", false, teamsGUI.tab[3])
	guiSetProperty(teamsGUI.btnTWAdd, "NormalTextColour", "FFAAAAAA")
	teamsGUI.btnTWRemove = guiCreateButton(334, 194, 64, 24, "< Remove", false, teamsGUI.tab[3])
	guiSetProperty(teamsGUI.btnTWRemove, "NormalTextColour", "FFAAAAAA")
	teamsGUI.label[8] = guiCreateLabel(56, 328, 40, 16, "Search:", false, teamsGUI.tab[3])
	teamsGUI.edit[1] = guiCreateEdit(104, 324, 192, 24, "", false, teamsGUI.tab[3])
	teamsGUI.btnTWSelect = guiCreateButton(128, 174, 96, 24, "Select maps", false, teamsGUI.tab[3])
	guiSetProperty(teamsGUI.btnTWSelect, "NormalTextColour", "FFAAAAAA")
	guiSetVisible(teamsGUI.gridlist[2], false)
	guiSetVisible(teamsGUI.btnTWAdd, false)
	guiSetVisible(teamsGUI.btnTWRemove, false)
	guiSetVisible(teamsGUI.label[8], false)
	guiSetVisible(teamsGUI.edit[1], false)

	-- teamsGUI end --

	guiSetVisible(teamsGUI.chkIgnore, false)
	teamGUI = teamsGUI
	addEventHandler('onClientGUIClick', teamsGUI.btnBuyTeam, buyTeam, false)
	addEventHandler('onClientGUIClick', teamsGUI.btnUpdateTeam, updateTeam, false)
	addEventHandler('onClientGUIClick', teamsGUI.btnKick, kickTeam, false)
	addEventHandler('onClientGUIClick', teamsGUI.btnLeave, leaveTeam, false)
	addEventHandler('onClientGUIClick', teamsGUI.btnInvite, inviteTeam, false)
	addEventHandler("onClientGUIClick", teamsGUI.btnTWAdd, addMaps, false)
	addEventHandler("onClientGUIClick", teamsGUI.btnTWRemove, removeMaps, false)
	addEventHandler("onClientGUIClick", teamsGUI.btnTWSelect, selectMaps, false)
	addEventHandler("onClientGUIChanged", teamsGUI.edit[1], handleSearches)
	translateTeamsGUI()
	addEventHandler("onClientPlayerLocaleChange", root, translateTeamsGUI)
end
addEvent('onShopInit', true)
addEventHandler('onShopInit', root, onShopInit )

function translateTeamsGUI()
	guiSetText(teamTab, _.context("GCshop Teams Tab", "Teams"))
	guiSetText(teamsGUI.tab[1], _("Your Team"))
	guiSetText(teamsGUI.label[1], _("Create your own team! You will be able to set a team name, tag, color, welcome message and invite players to your team. Teams expire after 20/40/60 days, but everyone in the team can refresh the team duration. Clan owners can transfer ownership with /makeowner PlayerName with color code."))
	guiSetText(teamsGUI.btnBuyTeam, _("Create team\n${price} GC / ${amount} days") % {price=2750, amount=20})
	guiSetText(teamsGUI.btnUpdateTeam, _("Save changes\n${price} GC") % {price=100})
	guiSetText(teamsGUI.label[2], _("Team Name"))
	guiSetText(teamsGUI.label[3], _("Team Tag"))
	guiSetText(teamsGUI.label[4], _("Team Color"))
	guiSetText(teamsGUI.chkIgnore, _("Don't show team invites"))
	guiSetText(teamsGUI.btnInvite, _("/Invite player"))
	guiSetText(teamsGUI.btnKick, _("Kick player"))
	guiSetText(teamsGUI.btnLeave, _("Leave team"))
	guiSetText(teamsGUI.label[5], _("Welcome message"))
	guiGridListSetColumnTitle(teamsGUI.gridlist[1], teamsGUI.teamCol, _("Team"))
	guiGridListSetColumnTitle(teamsGUI.gridlist[1], teamsGUI.meemberCol, _("Member"))
	guiSetText(teamsGUI.tab[3], _("Team Wars"))
	guiSetText(teamsGUI.label[6], _("Select maps"))
	guiSetText(teamsGUI.label[7], _("Select maps to be played in a Team War:"))
	guiSetText(teamsGUI.btnTWAdd, _("Add >"))
	guiSetText(teamsGUI.btnTWRemove, _("< Remove"))
	guiSetText(teamsGUI.btnTWSelect, _("Select maps"))
end


addEvent("teamLogin", true)
addEventHandler("teamLogin", root, function()
	guiSetProperty(teamGUI.btnBuyTeam, "Disabled", "False")
	guiSetProperty(teamGUI.teamname, "Disabled", "False")
	guiSetProperty(teamGUI.teamtag, "Disabled", "False")
	guiSetProperty(teamGUI.teammsg, "Disabled", "False")
	guiSetProperty(teamGUI.teamcolour, "Disabled", "False")
end)

addEvent("teamLogout", true)
addEventHandler("teamLogout", root, function()
	-- Reset GUI
	guiSetProperty(teamGUI.btnBuyTeam, "Disabled", "True")
	guiSetText(teamGUI.btnBuyTeam, "Create team\n2750 GC / 20 days")
	guiSetVisible(teamGUI.btnUpdateTeam, false)
	guiSetProperty(teamGUI.teamname, "Disabled", "True")
	guiSetText(teamGUI.teamname, "");
	guiSetProperty(teamGUI.teamtag, "Disabled", "True")
	guiSetText(teamGUI.teamtag, "");
	guiSetProperty(teamGUI.teammsg, "Disabled", "True")
	guiSetText(teamGUI.teammsg, "");
	guiSetProperty(teamGUI.teamcolour, "Disabled", "True")
	guiSetText(teamGUI.teamcolour, "#FFFFFF");
	guiSetVisible(teamGUI.btnLeave, false)
	guiSetVisible(teamGUI.btnInvite, false)
	guiSetVisible(teamGUI.btnKick, false)
	guiGridListClear(teamGUI.gridMembers)
	guiGridListClear(teamGUI.gridlist[1])
	if teamsDataSet then
		handleTeamData(cachedTeamsData.teams, cachedTeamsData.player, cachedTeamsData.t)
	end
end)


function handleTeamData(teams, player, t)
	teamsDataSet = true
	cachedTeamsData.teams = teams
	cachedTeamsData.player = player
	cachedTeamsData.t = t

	local g = teamGUI.gridlist[1]
	local g2 = teamGUI.gridMembers
	guiGridListClear(g)
	local teamid, i
	for r, z in ipairs(teams) do
		if teamid ~= z.teamid then
			teamid = z.teamid
			i = guiGridListAddRow(g)
			guiGridListSetItemText(g, i, 1, z.teamid .. '. ' .. z.tag .. ' ' .. z.name, true, false)
		end
		if z.status == 1 then
			i = guiGridListAddRow(g)
			guiGridListSetItemText(g, i, 2, string.gsub(z.mta_name or 'UNKNOWN',"#%x%x%x%x%x%x","") .. (z.forumid == z.owner and (_(' (Owner) (${age}/${remain} days left') % {age=z.age, remain=60}) or ''), false, false)
		end
	end
	if not t or player ~= localPlayer then return end
	guiGridListClear(teamGUI.gridMembers)
	for r, z in ipairs(teams) do
		if t and t.teamid == z.teamid and z.status == 1 then
			i = guiGridListAddRow(g2)
			guiGridListSetItemText(g2, i, 1, string.gsub(z.mta_name or 'UNKNOWN',"#%x%x%x%x%x%x","") .. (z.forumid == z.owner and (_(' (Owner) (${age}/${remain} days left') % {age=z.age, remain=60}) or ''), false, false)
			guiGridListSetItemData(g2, i, 1, z.forumid, false, false)
		end
	end
	if t.status == 1 then
		guiSetText(teamGUI.btnBuyTeam, _("Renew team\n${price} GC / ${amount} days") % {price=2750, amount=20})
		if tonumber(t.age) == 60 then
			guiSetProperty(teamGUI.btnBuyTeam, "Disabled", "True")
		else
			guiSetProperty(teamGUI.btnBuyTeam, "Disabled", "False")
		end

		guiSetVisible(teamGUI.btnUpdateTeam, t.forumid == t.owner)
		guiSetEnabled(teamGUI.teamname, t.forumid == t.owner)
		guiSetEnabled(teamGUI.teamtag, t.forumid == t.owner)
		guiSetEnabled(teamGUI.teammsg, t.forumid == t.owner)
		guiSetEnabled(teamGUI.teamcolour, t.forumid == t.owner)
		guiSetText(teamGUI.teamname, t.name)
		guiSetText(teamGUI.teamtag, t.tag)
		guiSetText(teamGUI.teammsg, t.message or '')
		guiSetText(teamGUI.teamcolour, t.colour)

		guiSetText(teamGUI.btnLeave, _("Leave team"))
		guiSetVisible(teamGUI.btnLeave, true)
		guiSetVisible(teamGUI.btnInvite, t.forumid == t.owner)
		guiSetVisible(teamGUI.btnKick, t.forumid == t.owner)
	else
		guiSetText(teamGUI.btnBuyTeam, _("Buy team\n${price} GC / ${amount} days") % {price=2750, amount=20})

		guiSetVisible(teamGUI.btnUpdateTeam, false)
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
			guiSetText(teamGUI.btnLeave, _("Rejoin team"))
		else
			guiSetVisible(teamGUI.btnLeave, false)
		end
		guiSetVisible(teamGUI.btnInvite, false)
		guiSetVisible(teamGUI.btnKick, false)
	end
end
addEvent("teamsData", true)
addEventHandler("teamsData", root, handleTeamData)

-- Buying/extending team --
function buyTeam (btn)
	triggerServerEvent('buyTeam', resourceRoot, guiGetText(teamGUI.teamname), guiGetText(teamGUI.teamtag), guiGetText(teamGUI.teamcolour), guiGetText(teamGUI.teammsg))
end
function updateTeam (btn)
	triggerServerEvent('updateTeam', resourceRoot, guiGetText(teamGUI.teamname), guiGetText(teamGUI.teamtag), guiGetText(teamGUI.teamcolour), guiGetText(teamGUI.teammsg))
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
	local playerWindow = guiCreateWindow ( 0.80, 0.10, 0.15, 0.60, _("Team invite"), true )
	local playerList = guiCreateGridList ( 0.05, 0.05, 0.9, 0.55, true, playerWindow )
	local inviteBtn = guiCreateButton(0.05, 0.60, .9, .15, _("Invite"), true, playerWindow)
	local closeBtn = guiCreateButton(0.05, 0.80, .9, .15, _("Close"), true, playerWindow)
	--Create a players column in the list
	local column = guiGridListAddColumn( playerList, _("Invite"), 0.85 )
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

--------------------
-- Team War update--
--------------------

function updateTWInfo()
	triggerServerEvent("gcshop_teams_fetchQueue_s", resourceRoot, localPlayer)
end
addEventHandler('onShopInit', root, updateTWInfo)

function selectMaps()
	triggerServerEvent("gcshop_teams_fetchMaps_s", resourceRoot, localPlayer)
end

function fetchMaps(t)
	guiSetVisible(teamGUI.btnTWSelect, false)
	guiSetVisible(teamGUI.gridlist[2], true)
	guiSetVisible(teamGUI.btnTWAdd, true)
	guiSetVisible(teamGUI.btnTWRemove, true)
	guiSetVisible(teamGUI.label[8], true)
	guiSetVisible(teamGUI.edit[1], true)

	mapList = t
	updateMaps(t)
end
addEvent("gcshop_teams_fetchMaps_c",true)
addEventHandler("gcshop_teams_fetchMaps_c",root,fetchMaps)

function updateMaps(t)
	guiGridListClear(teamGUI.gridlist[2])

	for a,b in ipairs(t) do
		local row = guiGridListAddRow(teamGUI.gridlist[2])
		guiGridListSetItemText(teamGUI.gridlist[2],row,1,tostring(b[1]),false,false)
		guiGridListSetItemText(teamGUI.gridlist[2],row,2,tostring(b[2]),false,false)
		guiGridListSetItemText(teamGUI.gridlist[2],row,3,tostring(b[3]),false,false)
	end
end

function updateTWQueue_c(t)
	guiGridListClear(teamGUI.gridlist[3])

	for a,b in ipairs(t) do
		local row = guiGridListAddRow(teamGUI.gridlist[3])
		guiGridListSetItemText(teamGUI.gridlist[3],row,1,tostring(b[1]),false,false)
		guiGridListSetItemText(teamGUI.gridlist[3],row,2,tostring(b[2]),false,false)
		guiGridListSetItemText(teamGUI.gridlist[3],row,3,tostring(b[3]),false,false)
	end
end
addEvent("gcshop_teams_updateTWQueue_c",true)
addEventHandler("gcshop_teams_updateTWQueue_c",root,updateTWQueue_c)

function addMaps()
	local resname = guiGridListGetItemText(teamGUI.gridlist[2], guiGridListGetSelectedItem(teamGUI.gridlist[2]), 3)
	if resname then
		triggerServerEvent("gcshop_teams_addMaps_s", resourceRoot, localPlayer, resname)
		triggerServerEvent("gcshop_teams_fetchQueue_s", resourceRoot, localPlayer)
	end
end

function removeMaps()
	local resname = guiGridListGetItemText(teamGUI.gridlist[3], guiGridListGetSelectedItem(teamGUI.gridlist[3]), 3)
	if resname then
		triggerServerEvent("gcshop_teams_removeMaps_s", resourceRoot, localPlayer, resname)
		triggerServerEvent("gcshop_teams_fetchQueue_s", resourceRoot, localPlayer)
	end
end

function handleSearches(element)
	local list
	local searchQuery
	if element == teamGUI.edit[1] then
		if not mapList then return end
		list = mapList
		searchQuery = guiGetText(teamGUI.edit[1])
	end
	if not list or not searchQuery then return end

	if #searchQuery == 0 then
		rebuildGridLists(element, list)
	else
		local t = searchTable(searchQuery,list)
		rebuildGridLists(element, t)
	end
end

function rebuildGridLists(element, list)
	if element == teamGUI.edit[1] then updateMaps(list) end
end

function searchTable(searchQuery,t)
    searchQuery = string.lower(tostring(searchQuery))
    if #searchQuery == 0 then return t end

    local results = {}
    for a,b in ipairs(t) do
        local match = false

		for i=1,#b do
			local f = string.find(string.lower( tostring(b[i]) ),searchQuery)
			if type(f) == "number" then match = true end
		end

        if match then table.insert(results,b) end
    end
    return results
end
