function elementChanged(oldModel, newModel)
    if getElementType(source) == 'player' and newModel ~= 1 and bPlayerUse[source] then
		setTimer(setElementModel,2000, 1, source, 1)
	end
end
addEventHandler("onElementModelChange", root, elementChanged)

addEventHandler('onPlayerSpawn', getRootElement(),
function()
	if bPlayerUse[source] then
		setTimer(function(player) if isElement(player) and getElementModel(player) ~= 1 then setElementModel(player, 1) end end,2000, 1, source)
	end
end
)

bPlayerUse = {}
-- addCommandHandler('snow',
-- function(player)
-- 	bPlayerUse[player] = not bPlayerUse[player]
-- end
-- )
addEvent("onPSnowUse", true)
addEventHandler("onPSnowUse",root,function()
	bPlayerUse[client] = not bPlayerUse[client]
	end)


addEventHandler('onPlayerQuit', getRootElement(),
function()
	if bPlayerUse[source] then bPlayerUse[source] = nil end
end
)
