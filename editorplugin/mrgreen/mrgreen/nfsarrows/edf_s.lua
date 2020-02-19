local nfs_arrows = {}
local color = nil

addEventHandler("onResourceStart", root, 
	function(res)
		if getResourceName(res) ~= "editor_test" then return end
		local nfsarrowsRes = getResourceFromName("nfsarrows")
		if nfsarrowsRes and getResourceState( nfsarrowsRes ) == "running" then return end
		--------------------------------------------------------------------------------------------------------
		for _, v in pairs( getElementsByType("nfs_arrow", getResourceRootElement(res)) ) do
			local x, y, z = getElementData(v, "posX"), getElementData(v, "posY"), getElementData(v, "posZ")+0.05
			local rx, ry, rz = getElementData(v, "rotX"), getElementData(v, "rotY"), getElementData(v, "rotZ")
			local nfs_arrow = createObject(3851, x, y, z, rx, ry, rz)
			setElementDoubleSided(nfs_arrow, true)
			nfs_arrows[#nfs_arrows+1] = nfs_arrow
			local nfs_arrows_collision = createObject(18000, x, y, z, rx, ry, rz)
			setObjectScale(nfs_arrows_collision, 0)
			setElementParent(nfs_arrows_collision, nfs_arrow)
		end
		---------------------------------------------------------------------------------------------------------
		triggerClientEvent("setNFSArrowsUnbreakable", resourceRoot, nfs_arrows)
	end
)


addEventHandler("onResourceStop", root, 
	function(res)
		if getResourceName(res) ~= "editor_test" then return end
		---------------------------------------------------------
		for _, v in pairs(nfs_arrows) do
			destroyElement(v)
		end
		---------------------------------------------------------
		nfs_arrows = {}
	end
)


function onMapOpened(map)
	local resourceName = getResourceName(map)
	color = get(resourceName..".nfsarrows_color") or "blue"
	triggerClientEvent( root, "changeArrowsColor", resourceRoot, color )
	--outputChatBox("[Debug EDF] onMapOpened "..resourceName.." - "..tostring(color))
end
addEventHandler("onMapOpened", root, onMapOpened)