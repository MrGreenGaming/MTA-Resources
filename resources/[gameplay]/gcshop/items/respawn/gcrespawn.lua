-----------------
-- Items stuff --
-----------------

local ID = 2
local respawntime = 1000
local saferespawn = 1000
function loadGCRespawn ( player, bool, settings )
	if bool then
		setElementData(player, 'gcshop.respawntime', respawntime)
		setElementData(player, 'gcshop.saferespawn', saferespawn)
	else
		setElementData(player, 'gcshop.respawntime', nil)
		setElementData(player, 'gcshop.saferespawn', nil)
	end
end


-------------------
-- Respawn stuff --
-------------------

addEventHandler('onResourceStop', resourceRoot, function()
	for _, player in ipairs(getElementsByType'player') do
		setElementData(player, 'gcshop.respawntime', nil)
		setElementData(player, 'gcshop.saferespawn', nil)
	end
end)

---.WhiteBlue
local ghostmodePlayers = {}

addEventHandler("onMapStarting", root,
    function()

        for _, player in ipairs(getElementsByType("player")) do
            local mapType = getElementData(root, "mapType")  
            
            if mapType == "Race" or mapType == "Never the Same" then
 
                if getElementData(player, "ghostmodePurchased") == true then
           
                    setElementData(player, "ghostmodeEnabled", true)
                    setElementData(player, "canEarnGreencoins", false) 
                    table.insert(ghostmodePlayers, player)  
                    outputChatBox(getPlayerName(player) .. " has activated permanent Ghostmode for this round.", root)
                else
              
                    setElementData(player, "ghostmodeEnabled", false)
                end
            end
        end
    end
)


addCommandHandler("buyghostmode", function(player)
    local mapType = getElementData(root, "mapType")
    
 
    if mapType == "Race" or mapType == "Never the Same" then
        setElementData(player, "ghostmodePurchased", true)
        outputChatBox("You have purchased Permanent Ghostmode for this round.", player)
    else
        outputChatBox("Ghostmode is only available on Race or Never the Same maps.", player, 255, 0, 0)
    end
end)


addEventHandler("onMapFinished", root,
    function()
        for _, player in ipairs(ghostmodePlayers) do
           
            setElementData(player, "ghostmodeEnabled", false)
            setElementData(player, "canEarnGreencoins", true)  
        end

        ghostmodePlayers = {}
    end
)
local healthTransferCooldown = {}  --


function useHealthTransfer(player, targetPlayer)
    local currentTime = getTickCount()
    

    if healthTransferCooldown[player] and currentTime - healthTransferCooldown[player] < 2000 then
        outputChatBox("You must wait before using Health Transfer again!", player, 255, 0, 0)
        return
    end

   
    local playerHealth = getElementHealth(player)
    local targetHealth = getElementHealth(targetPlayer)
    
    local transferAmount = math.min(playerHealth * 0.1, targetHealth * 0.1)  
    setElementHealth(player, playerHealth - transferAmount)
    setElementHealth(targetPlayer, targetHealth + transferAmount)

    healthTransferCooldown[player] = currentTime
    
    outputChatBox("You transferred health to " .. getPlayerName(targetPlayer) .. ".", player)
    outputChatBox(getPlayerName(player) .. " transferred health to you!", targetPlayer)
end

addCommandHandler("transferhealth", 
    function(player, _, targetPlayer)
        if not targetPlayer then
            outputChatBox("You must specify a target player.", player, 255, 0, 0)
            return
        end
        useHealthTransfer(player, targetPlayer)
    end
)
