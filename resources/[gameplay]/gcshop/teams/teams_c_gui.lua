
GUIEditor = {
    gridlist = {},
    tab = {},
    tabpanel = {},
    label = {}
}
GUIEditor.tabpanel[1] = guiCreateTabPanel(5, 5, 715, 414, false)

GUIEditor.tab[1] = guiCreateTab("Your team", GUIEditor.tabpanel[1])

GUIEditor.label[1] = guiCreateLabel(46, 22, 634, 55, "Create your own team! You will be able to set a team name, tag, colour, welcome message and invite players to your team. Teams expire after 30/60 days, but everyone in the team can refresh the team duration (Up to 60 days). You can only own one team or be in one team.", false, GUIEditor.tab[1])
guiLabelSetHorizontalAlign(GUIEditor.label[1], "left", true)
GUIEditor.btnBuyTeam = guiCreateButton(46, 263, 165, 50, "Create team\n2750 GC / 20 days", false, GUIEditor.tab[1])
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
GUIEditor.btnInvite = guiCreateButton(419, 332, 114, 32, "Invite player", false, GUIEditor.tab[1])
guiSetProperty(GUIEditor.btnInvite, "Disabled", "True")
guiSetProperty(GUIEditor.btnInvite, "NormalTextColour", "FFAAAAAA")
GUIEditor.btnLeave = guiCreateButton(566, 332, 114, 32, "Leave team", false, GUIEditor.tab[1])
guiSetProperty(GUIEditor.btnLeave, "Disabled", "True")
guiSetProperty(GUIEditor.btnLeave, "NormalTextColour", "FFAAAAAA")
GUIEditor.label[5] = guiCreateLabel(46, 225, 83, 28, "Welcome msg", false, GUIEditor.tab[1])
guiLabelSetVerticalAlign(GUIEditor.label[5], "center")

GUIEditor.tab[2] = guiCreateTab("Teams", GUIEditor.tabpanel[1])

GUIEditor.gridlist[1] = guiCreateGridList(48, 40, 608, 304, false, GUIEditor.tab[2])
guiGridListAddColumn(GUIEditor.gridlist[1], "Team", 0.5)
guiGridListAddColumn(GUIEditor.gridlist[1], "Member", 0.5)
