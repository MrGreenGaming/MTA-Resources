addEvent("sb_showAchievements")
function toggleAchievementGUI(key, keyState)
	if keyState ~= "down" then if keyState then return end end
	if not window then
		triggerServerEvent("onAchievementsBoxLoad", resourceRoot)
	elseif isElement(window) then
		destroyElement(window)
		window = nil
		showCursor(false)
	end	
end
bindKey("f4", "down", toggleAchievementGUI)
addEventHandler("sb_showAchievements", root, toggleAchievementGUI)

function showAchievementsGUI ( achievementList, playerAchievements )
	guiSetInputMode("no_binds_when_editing")
	showCursor(true)
	
	window = guiCreateWindow(0.2, 0.2, 0.45, 0.3, "Player Achievements", true)
	local tabPanel = guiCreateTabPanel(0, 0.1, 1, 1, true, window)
	local ownStats = guiCreateTab("My Achievements", tabPanel)
	local achGrid = guiCreateGridList(0,0, 1, 1, true, ownStats)
	local achCol = guiGridListAddColumn(achGrid, "Achievements", 0.6)
	local achRewardCol = guiGridListAddColumn(achGrid, "Reward", 0.06)
	local achLockCol = guiGridListAddColumn(achGrid, "Status", 0.08)
	local achLockProgress = guiGridListAddColumn(achGrid, "Progress", 0.06)
	local achLockWhen = guiGridListAddColumn(achGrid, "When", 0.15)
	local unlocked = 0
	for _, ach in ipairs(achievementList) do
		local achID = ach.id
		row = guiGridListAddRow(achGrid)
		guiGridListSetItemText(achGrid, row, achCol, ach.s, false, false)
		guiGridListSetItemText(achGrid, row, achRewardCol, ach.reward .. ' GC', false, false)
		guiGridListSetItemText(achGrid, row, achLockCol, "Locked", false, false)
		if ach.max then
			guiGridListSetItemText(achGrid, row, achLockProgress, (playerAchievements[achID] and playerAchievements[achID].progress or 0) .. ' / ' .. ach.max, false, false)
		end
		if playerAchievements[achID] then
			if playerAchievements[achID].unlockedDate then
				guiGridListSetItemText(achGrid, row, achLockWhen, playerAchievements[achID].unlockedDate, false, false)
			end
			if playerAchievements[achID].unlocked == 1 then
				unlocked = unlocked + 1
				guiGridListSetItemText(achGrid, row, achLockCol, "Unlocked", false, false)
				guiGridListSetItemColor(achGrid, row, achLockCol, 154, 205, 50, 255)
				guiGridListSetItemColor(achGrid, row, achRewardCol, 154, 205, 50, 255)
				guiGridListSetItemColor(achGrid, row, achLockProgress, 154, 205, 50, 255)
				guiGridListSetItemColor(achGrid, row, achCol, 154, 205, 50, 255)
			end
		end
	end
	guiSetText(ownStats, "My Achievements: "..unlocked.."/"..tostring(#achievementList))
end
addEvent ( 'showAchievementsGUI', true )
addEventHandler ( 'showAchievementsGUI', resourceRoot, showAchievementsGUI )

