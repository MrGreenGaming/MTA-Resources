local guiEnabled = false
local snowToggle = true

addEvent("onClientReady",true)
addEventHandler("onClientReady",root,function()
	triggerClientEvent(client,"triggerGuiEnabled",client,guiEnabled,snowToggle)
end)

local maxHowTo = 2
local howToTable = {}


addEventHandler("onPlayerLeave",root,function() howToTable[source] = nil end)
addEventHandler("onPlayerChat",root,
	function(m)
		local lowerC = string.lower(m) 
		local find = string.find(lowerC,"snow")
		if find then
			playerHowToCheck(source)
		end
	end )


function playerHowToCheck(p)
	if p then
		if not howToTable[p] then
			howToTable[p] = 1
			tellPlayerHowTo(p)
		else
			if howToTable[p] > maxHowTo then return end
			howToTable[p] = howToTable[p] + 1
			tellPlayerHowTo(p)
		end		
	end
end

function tellPlayerHowTo(p)
	outputChatBox("You can enable/disable snow by pressing J",p,0,255,0)
end
