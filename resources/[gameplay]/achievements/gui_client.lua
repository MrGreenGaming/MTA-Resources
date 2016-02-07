bGuiOpen = false
addEvent("sb_showAchievements")
function toggleAchievementGUI(key, keyState)
	if keyState ~= "down" then if keyState then return end end
	if bGuiOpen == false then
		bGuiOpen = true
		triggerServerEvent("onAchievementsBoxLoad", resourceRoot)
	elseif isElement(window) then
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
	
	window = guiCreateWindow(0.2775, 0.3, 0.445, 0.3, "Achievements (F4 to close)", true)
	guiWindowSetSizable(window, false)
	
	--Tabs
	local tabPanel = guiCreateTabPanel(0, 0.1, 1, 1, true, window)
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
addEvent ( 'showAchievementsGUI', true )
addEventHandler ( 'showAchievementsGUI', resourceRoot, showAchievementsGUI )

