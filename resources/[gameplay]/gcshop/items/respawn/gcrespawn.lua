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

addEventHandler("onMapStarting", root,
    function()
        for _, player in ipairs(getElementsByType("player")) do
            local mapType = getElementData(root, "mapType")  
            if mapType == "Race" or mapType == "Never the Same" then
                if getElementData(player, "ghostmodePurchased") == true then
                    setElementData(player, "ghostmodeEnabled", true)
                    setElementData(player, "canEarnGreencoins", false) 
                else
                    setElementData(player, "ghostmodeEnabled", false)
                end
            end
        end
    end
)

addCommandHandler("buyghostmode",
    function(player)
        setElementData(player, "ghostmodePurchased", true)
        outputChatBox("You have purchased Permanent Ghostmode for this round.", player)
    end
)


addEventHandler("onMapFinished", root,
    function()
        for _, player in ipairs(getElementsByType("player")) do
            setElementData(player, "ghostmodeEnabled", false)
            setElementData(player, "canEarnGreencoins", true)
        end
    end
)
