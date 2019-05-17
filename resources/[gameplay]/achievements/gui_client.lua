bGuiOpen = false;

function showAchievementsGUI ( achievementListMix, playerAchievementsMix, achievementListRace, playerAchievementsRace )
	if(not isElement(tabPanel)) then		
		guiSetInputMode("no_binds_when_editing")
		tabPanel = guiCreateTabPanel(537, 331, 840, 307, false)
		raceStats = guiCreateTab("Race Achievements", tabPanel)
		mixStats = guiCreateTab("Mix Achievements", tabPanel)
	end

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

function showAchievementsDX()
	showCursor(true)
	dxDrawRectangle(531, 323, 856, 325, tocolor(1, 0, 0, 228), false)
	dxDrawRectangle(531, 313, 856, 10, tocolor(12, 180, 24, 255), false)
	dxDrawRectangle(531, 303, 856, 10, tocolor(78, 200, 87, 255), false)
	dxDrawText("Achievements", 899 + 1, 303 + 1, 1020 + 1, 322 + 1, tocolor(0, 0, 0, 255), 1.40, "default-bold", "left", "top", false, false, false, false, false)
	dxDrawText("Achievements", 899, 303, 1020, 322, tocolor(255, 255, 255, 255), 1.40, "default-bold", "left", "top", false, false, false, false, false)
end

function toggleGui()
	local bVisibility = not guiGetVisible(tabPanel)
	
	guiSetVisible(tabPanel, bVisibility)
	showCursor(bVisibility)

	if(bVisibility) then		
    	addEventHandler("onClientRender", root, showAchievementsDX)
		triggerServerEvent("onAchievementsBoxLoad", resourceRoot)
	else
    	removeEventHandler("onClientRender", getRootElement(), showAchievementsDX)
    end
end

bindKey("F4", "down", toggleGui)
addEventHandler("sb_showAchievements", root, toggleGui)
