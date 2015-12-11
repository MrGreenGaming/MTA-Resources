blockerTable = {}
addEventHandler("onClientElementDataChange",root,
	function(name) 
		if getElementType(source) == "player" and name == "markedblocker" then
			if source == localPlayer then
				checkDisplayBlockerTimer()
			end

			if getElementData(source,"markedblocker") then
				removeBlockerFromTable(p)
				table.insert(blockerTable,source)
			else
				removeBlockerFromTable(p)
			end
		end 
	end)

addEventHandler("onClientResourceStart",resourceRoot,
	function()
		for _,p in ipairs(getElementsByType("player")) do
			if getElementData(p,"markedblocker") then
				table.insert(blockerTable,p)
			end
		end
	end)
addEventHandler("onClientPlayerQuit",root,
	function()
		removeBlockerFromTable(source)
	end)

function theTool()

	local mode = getResourceFromName'race' and getResourceState(getResourceFromName'race')=='running' and exports.race:getRaceMode()
	if not (mode == "Sprint" or mode == "Never the same") or getElementData(localPlayer, 'markedblocker') then return end
	for _, p in ipairs(blockerTable) do
		local vehMe = getPedOccupiedVehicle(localPlayer)
		local vehBlocker = getPedOccupiedVehicle(p)
		if vehMe and vehBlocker then
			setElementCollidableWith(vehMe, vehBlocker, false)
			setElementAlpha(vehBlocker, 140)
		end
	end
end
setTimer( theTool, 50, 0)

function onClientExplosion()
	if not (mode == "Sprint" or mode == "Never the same") or getElementData(localPlayer, 'markedblocker') then return end
	if getElementType(source) == "player" and getElementData(p, 'markedblocker') then
		cancelEvent()
	end
end
addEventHandler('onClientExplosion', root, onClientExplosion)

local playerIsBlocker = false
local localBlockerTimer = false
function checkDisplayBlockerTimer()
	if getElementData(localPlayer,"markedblocker") and getElementData(resourceRoot,"serverTimestamp") then
		playerIsBlocker = true
		local durationSec = getElementData(localPlayer,"markedblocker").expireTimestamp - getElementData(resourceRoot,"serverTimestamp")
		localBlockerTimer = setTimer( function() localBlockerTimer = false end, durationSec*1000, 1 )
		
	else
		playerIsBlocker = false
		if isTimer(checkDisplayBlockerTimer) then killTimer(checkDisplayBlockerTimer) checkDisplayBlockerTimer = false end
	end
end
setTimer(checkDisplayBlockerTimer,10000,1)




local screenW, screenH = guiGetScreenSize()

function displayBlockerTimer()
	if not playerIsBlocker or not isTimer(localBlockerTimer) then
		return 
	end



	local timeLeft = getTimerDetails( localBlockerTimer )
	local readableTime = secondsToTimeDesc( math.floor(timeLeft/1000) )
	-- local minutes = math.floor((timeLeft/1000) / 60)
	-- local seconds = math.floor((timeLeft/1000) % 60)


    dxDrawText("You are marked as a blocker for: "..readableTime, screenW * 0.727 + 1, screenH * 0.971 + 1, screenW * 0.981 + 1, screenH * 0.996 + 1, tocolor(0, 0, 0, 255), 1.00, "default-bold", "left", "center", false, false, false, false, false)
    dxDrawText("You are marked as a blocker for: "..readableTime, screenW * 0.727, screenH * 0.971, screenW * 0.981, screenH * 0.996, tocolor(255, 0, 5, 255), 1.00, "default-bold", "left", "center", false, false, false, false, false)

end
addEventHandler("onClientRender",root,displayBlockerTimer)

function removeBlockerFromTable(p)
	for i,player in ipairs(blockerTable) do
		if p == player then
			table.remove(blockerTable,i)
		end
	end

end

function secondsToTimeDesc( seconds )
	if seconds then
		local results = {}
		local sec = ( seconds %60 )
		local min = math.floor ( ( seconds % 3600 ) /60 )
		local hou = math.floor ( ( seconds % 86400 ) /3600 )
		local day = math.floor ( seconds /86400 )
 
		if day > 0 then table.insert( results, day .. ( day == 1 and " d" or " d" ) ) end
		if hou > 0 then table.insert( results, hou .. ( hou == 1 and " h" or " h" ) ) end
		if min > 0 then table.insert( results, min .. ( min == 1 and " m" or " m" ) ) end
		if sec > 0 then table.insert( results, sec .. ( sec == 1 and " s" or " s" ) ) end
 
		return string.reverse ( table.concat ( results, ", " ):reverse():gsub(" ,", " dna ", 1 ) )
	end
	return ""
<<<<<<< HEAD
end
=======
end
>>>>>>> refs/remotes/JarnoVgr/master
