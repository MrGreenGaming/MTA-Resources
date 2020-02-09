local nfs_arrows = {}
local color = nil


addEventHandler("onResourceStart", root, 
	function(res)
		if getResourceName(res) == "editor_test" then return end
		----------------------------------------------------
		if not isMap(res) then return end
		----------------------------------------------------
		local nfsarrows = getElementsByType("nfs_arrow", getResourceRootElement(res))
		if #nfsarrows > 0 then
			for _, v in pairs(nfsarrows) do
				local x, y, z = getElementData(v, "posX"), getElementData(v, "posY"), getElementData(v, "posZ")+0.05
				local rx, ry, rz = getElementData(v, "rotX"), getElementData(v, "rotY"), getElementData(v, "rotZ")
				local nfs_arrow = createObject(3851, x, y, z, rx, ry, rz)
				nfs_arrows[#nfs_arrows+1] = nfs_arrow
				setElementDoubleSided(nfs_arrow, true)
				local nfs_arrows_collision = createObject(18000, x, y, z, rx, ry, rz)
				setObjectScale(nfs_arrows_collision, 0)
				setElementParent(nfs_arrows_collision, nfs_arrow)
			end
			--outputChatBox("[Debug] NFS Arrows created.")
		else
			--outputChatBox("[Debug] Non-arrows map started.")
		end
		-----------------------------------------------------------------------------------------------------------
		local resourceName = getResourceName( exports.mapmanager:getRunningGamemodeMap() )
		color = get(resourceName..".nfsarrows_color")
		triggerClientEvent( "updateArrowsState", resourceRoot, nfs_arrows, color )
	end
)


addEventHandler("onResourceStop", root, 
	function(res)
		if getResourceName(res) == "editor_test" then return end
		-------------------------------------------
		if not isMap(res) then return end
		-------------------------------------------
		for _, v in pairs(nfs_arrows) do
			destroyElement(v)
		end
		--outputChatBox("[Debug] NFS Arrows destroyed.")
		-------------------------------------------
		nfs_arrows = {}
		color = nil
		triggerClientEvent( "updateArrowsState", resourceRoot, nil, nil )	
	end
)


function isMap(res)
	if getResourceInfo(res, "type") == "map" then return true end
end

addEvent("getArrowsData", true)
addEventHandler("getArrowsData", root, 
	function()
		if color then
			triggerClientEvent( client, "updateArrowsState", resourceRoot, nfs_arrows, color )
		end
	end
)