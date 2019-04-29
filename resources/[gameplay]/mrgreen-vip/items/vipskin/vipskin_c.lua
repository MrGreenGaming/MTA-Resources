-- If you add new models, plase make the TXD file smaller with Magic.TXD
-- Tutorial: https://wiki.multitheftauto.com/wiki/Optimize_Custom_TXD

local vipSkins = {
	-- dff and txd files should have the same name
	-- [1] = {name = "Skin Name", file = "filename"}
	[1] = {name = "Ironman", file = "Ironman"},
	[2] = {name = "Fapman", file = "Fapman"},
	[3] = {name = "The Stig", file = "Stig"},
	[4] = {name = "Marie Rose (DoA)", file = "MarieRose"},
	[5] = {name = "Goku", file = "Goku"},
	[6] = {name = "Spiderman", file = "Spiderman"},
	[7] = {name = "Hitman", file = "hitman"},
	[8] = {name = "Skadi (Smite)", file = "skadi"},
	[9] = {name = "Anthony's Waifu", file = "waifu"}
}

-- Reserved skin ID's for VIP skin. If more are needed, please check unbought GC shop skins via database and remove them from there
-- Do not forget to change server side too.
local skinIds = {
	[1] = 220,
	[2] = 25,
	[3] = 66,
	[4] = 56,
	[5] = 226,
	[6] = 221,
	[7] = 254,
	[8] = 16,
	[9] = 235,
	[10] = 186
}


function populateVipSkinsGridList()
	guiGridListClear(gui["vip_skin_grid"])
	for id, row in ipairs(vipSkins) do
		guiGridListAddRow( gui["vip_skin_grid"], id, row.name )
	end
end

function getSkinName(id)
	if not tonumber(id) or not vipSkins[tonumber(id)] then return false end
	return vipSkins[tonumber(id)].name or false
end


function loadVipModels()
	local path = "items/vipskin/skins/"
	local dffEx = ".dff"
	local txdEx = ".txd"

	for num, row in pairs(vipSkins) do
		local replaceId = skinIds[num]
		if not tonumber(replaceId) then return end
		local txd = engineLoadTXD(path..row.file..txdEx )
		if not txd then return end
		local dff = engineLoadDFF(path..row.file..dffEx, replaceId ) 
		if not dff then return end
		engineImportTXD(txd, replaceId) 
		engineReplaceModel(dff, replaceId) 
		
	end
end
addEventHandler( 'onClientResourceStart', resourceRoot, loadVipModels)