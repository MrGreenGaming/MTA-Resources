GUIEditor = {
    window = {},
    staticimage = {},
    label = {}
}

bGuiOpen = false

addEvent("sb_showAchievements")
function toggleAchievementGUI(key, keyState)
	local screenW, screenH = guiGetScreenSize()
	if keyState ~= "down" then if keyState then return end end
	if bGuiOpen == false then
		bGuiOpen = true
		triggerServerEvent("onAchievementsBoxLoad", resourceRoot)
		achievements = exports.blur_box:createBlurBox( 0, 0, screenW, screenH, 255, 255, 255, 255, true )
        achievementsIntensity = exports.blur_box:setBlurIntensity(2.5)
	elseif isElement(window) then
		exports.blur_box:destroyBlurBox(achievements)
		destroyElement(window)
		bGuiOpen = false
		showCursor(false)
	end	
end
bindKey("f4", "down", toggleAchievementGUI)
addEventHandler("sb_showAchievements", root, toggleAchievementGUI)

function showAchievementsGUI ( achievementListMix, playerAchievementsMix, achievementListRace, playerAchievementsRace )
	guiSetInputMode("no_binds_when_editing")
	showCursor(true)

	local screenWidth, screenHeight = guiGetScreenSize()
	window = guiCreateStaticImage((screenWidth - 854) / 2, (screenHeight  - 324) / 2, 854, 324, ":stats/images/dot.png", false)
	guiSetProperty(window, "ImageColours", "tl:FF0A0A0A tr:FF0A0A0A bl:FF0A0A0A br:FF0A0A0A") 
	GUIEditor.staticimage[2] = guiCreateStaticImage(0, 0, 854, 10, ":stats/images/dot.png", false, window)
	guiSetProperty(GUIEditor.staticimage[2], "ImageColours", "tl:FF4EC857 tr:FF4EC857 bl:FF4EC857 br:FF4EC857")
	GUIEditor.staticimage[3] = guiCreateStaticImage(0, 10, 854, 10, ":stats/images/dot.png", false, window)
	guiSetProperty(GUIEditor.staticimage[3], "ImageColours", "tl:FF0CB418 tr:FF0CB418 bl:FF0CB418 br:FF0CB418")
	GUIEditor.label[1] = guiCreateLabel(364, 1, 128, 16, "Achievements", false, window)
	guiSetFont(GUIEditor.label[1], "default-bold-small")
	guiSetProperty(GUIEditor.label[1], "AlwaysOnTop", "true")
	guiLabelSetColor(GUIEditor.label[1], 255, 255, 255)
	guiLabelSetHorizontalAlign(GUIEditor.label[1], "center", false)
	guiLabelSetVerticalAlign(GUIEditor.label[1], "center") 

	--Tabs
	local tabPanel = guiCreateTabPanel(0, 0.1, 1, 0.88, true, window)
	local raceStats = guiCreateTab("Race Achievements", tabPanel)
	local mixStats = guiCreateTab("Mix Achievements", tabPanel)

	--Gridlist MIX
	local achGrid = guiCreateGridList(0,0, 1, 1, true, mixStats)
	guiGridListSetSortingEnabled(achGrid, false)
	local achCol = guiGridListAddColumn(achGrid, "Achievements", 0.56)
	local achRewardCol = guiGridListAddColumn(achGrid, "Reward", 0.08)
	local achLockCol = guiGridListAddColumn(achGrid, "Status", 0.09)
	local achLockProgress = guiGridListAddColumn(achGrid, "Progress", 0.074)
	local achLockWhen = guiGridListAddColumn(achGrid, "When", 0.15)
	local unlocked = 0
	for _, ach in ipairs(achievementListMix) do
		local achID = ach.id
		row = guiGridListAddRow(achGrid)
		guiGridListSetItemText(achGrid, row, achCol, ach.s, false, false)
		guiGridListSetItemText(achGrid, row, achRewardCol, ach.reward .. ' GC', false, false)
		guiGridListSetItemText(achGrid, row, achLockCol, "Locked", false, false)
		if ach.max then
			guiGridListSetItemText(achGrid, row, achLockProgress, (playerAchievementsMix[achID] and playerAchievementsMix[achID].progress or 0) .. ' / ' .. ach.max, false, false)
		end
		if playerAchievementsMix[achID] then
			if playerAchievementsMix[achID].unlockedDate then
				guiGridListSetItemText(achGrid, row, achLockWhen, playerAchievementsMix[achID].unlockedDate, false, false)
			end
			if playerAchievementsMix[achID].unlocked == 1 then
				unlocked = unlocked + 1
				guiGridListSetItemText(achGrid, row, achLockCol, "Unlocked", false, false)
				guiGridListSetItemColor(achGrid, row, achLockCol, 154, 205, 50, 255)
				guiGridListSetItemColor(achGrid, row, achRewardCol, 154, 205, 50, 255)
				guiGridListSetItemColor(achGrid, row, achLockProgress, 154, 205, 50, 255)
				guiGridListSetItemColor(achGrid, row, achCol, 154, 205, 50, 255)
			end
		end
	end
	guiSetText(mixStats, "Mix Achievements: "..unlocked.."/"..tostring(#achievementListMix))

	--Gridlist RACE
	local achGridRace = guiCreateGridList(0,0, 1, 1, true, raceStats)
	guiGridListSetSortingEnabled(achGridRace, false)
	local achColRace = guiGridListAddColumn(achGridRace, "Achievements", 0.56)
	local achRewardColRace = guiGridListAddColumn(achGridRace, "Reward", 0.08)
	local achLockColRace = guiGridListAddColumn(achGridRace, "Status", 0.09)
	local achLockProgressRace = guiGridListAddColumn(achGridRace, "Progress", 0.074)
	local achLockWhenRace = guiGridListAddColumn(achGridRace, "When", 0.15)
	local unlocked = 0
	for _, ach in ipairs(achievementListRace) do
		local achID = ach.id
		row = guiGridListAddRow(achGridRace)
		guiGridListSetItemText(achGridRace, row, achColRace, ach.s, false, false)
		guiGridListSetItemText(achGridRace, row, achRewardColRace, ach.reward .. ' GC', false, false)
		guiGridListSetItemText(achGridRace, row, achLockColRace, "Locked", false, false)
		if ach.max then
			guiGridListSetItemText(achGridRace, row, achLockProgressRace, (playerAchievementsRace[achID] and playerAchievementsRace[achID].progress or 0) .. ' / ' .. ach.max, false, false)
		end
		if playerAchievementsRace[achID] then
			if playerAchievementsRace[achID].unlockedDate then
				guiGridListSetItemText(achGridRace, row, achLockWhenRace, playerAchievementsRace[achID].unlockedDate, false, false)
			end
			if playerAchievementsRace[achID].unlocked == 1 then
				unlocked = unlocked + 1
				guiGridListSetItemText(achGridRace, row, achLockColRace, "Unlocked", false, false)
				guiGridListSetItemColor(achGridRace, row, achLockColRace, 154, 205, 50, 255)
				guiGridListSetItemColor(achGridRace, row, achRewardColRace, 154, 205, 50, 255)
				guiGridListSetItemColor(achGridRace, row, achLockProgressRace, 154, 205, 50, 255)
				guiGridListSetItemColor(achGridRace, row, achColRace, 154, 205, 50, 255)
			end
		end
	end
	guiSetText(raceStats, "Race Achievements: "..unlocked.."/"..tostring(#achievementListRace))
end

-- stop player from clicking  GUIEditor.staticimage[2] or GUIEditor.staticimage[3]

--	addEventHandler("onClientGUIClick", resourceRoot, function()
--		if (source == GUIEditor.staticimage[2]) and (source == GUIEditor.staticimage[3]) then
--			cancelEvent()
--		end
--	end)

addEvent ( 'showAchievementsGUI', true )
addEventHandler ( 'showAchievementsGUI', resourceRoot, showAchievementsGUI )
