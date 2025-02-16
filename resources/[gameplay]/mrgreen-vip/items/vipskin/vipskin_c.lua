-- If you add new models, plase make the TXD file smaller with Magic.TXD
-- Tutorial: https://wiki.multitheftauto.com/wiki/Optimize_Custom_TXD
local vipSkinPath = "items/vipskin/skins/"
local vipSkinVoicePath = "items/vipskin/skins/voice/"
local vipSkins = {
	-- !IMPORTANT! 
	-- dff and txd files should have the same name
	[1] = {name = "Ironman", file = "Ironman", customVoice = false},
	[2] = {name = "Fapman", file = "Fapman", customVoice = false},
	[3] = {name = "The Stig", file = "Stig", customVoice = false},
	[4] = {name = "Marie Rose (DoA)", file = "MarieRose", customVoice = {'woman1.mp3', 'woman2.mp3'}},
	[5] = {name = "Goku", file = "Goku", customVoice = false},
	[6] = {name = "Spiderman", file = "Spiderman", customVoice = false},
	[7] = {name = "Hitman", file = "hitman", customVoice = false},
	[8] = {name = "Skadi (Smite)", file = "skadi", customVoice = {'woman1.mp3', 'woman2.mp3'}},
	[9] = {name = "Anthony's Waifu", file = "waifu", customVoice = {'waifu1.mp3', 'waifu2.mp3'}},
	[10] = {name = "Mini CJ", file = "minicj", customVoice = false},
	[11] = {name = "Random Guy", file = "randomguy", customVoice = false},
	[12] = {name = "Anna Home", file = "Annahome", customVoice = {'woman1.mp3', 'woman2.mp3'}},
	[13] = {name = "Neo (matrix)", file = "NEO", customVoice = false},
	[14] = {name = "Daffy Duck", file = "daffyduck", customVoice = false},
	[15] = {name = "Ai Kizuna", file = "AiKizuna", customVoice = {'woman1.mp3', 'woman2.mp3'}},
	[16] = {name = "Luigi", file = "luigi", customVoice = false},
	[17] = {name = "Mario", file = "mario", customVoice = false},
	[18] = {name = "Marshmello Spec Ops", file = "specopsmarshmello", customVoice = false},
	[19] = {name = "Bugs Bunny", file = "bugsbunny", customVoice = false},
	[20] = {name = "Lifeguard Female", file = "femalelifeguard", customVoice = {'woman1.mp3', 'woman2.mp3'}},
	[21] = {name = "Crysis", file = "crysis", customVoice = false},
	[21] = {name = "Random Guy 2", file = "randomguy2", customVoice = false},
	[22] = {name = "Furry Wolf", file = "furry", customVoice = false},
	[23] = {name = "Squid Game - Frontman", file = "Frontman", customVoice = false},
	[24] = {name = "Squid Game - Circle Soldier", file = "SoldierCircle", customVoice = false},
	[25] = {name = "Deadpool", file = "deadpool", customVoice = false}
}

-- Reserved skin ID's for VIP skin. If more are needed, please check unbought GC shop skins via database and remove them from there
-- Skins are fetched from server
local skinIds = {
	-- [1] = 220,
	-- [2] = 25,
	-- [3] = 66,
	-- [4] = 56,
	-- [5] = 226,
	-- [6] = 221,
	-- [7] = 254,
	-- [8] = 16,
	-- [9] = 235,
	-- [10] = 186
}

-- Request skins table from server
addEventHandler('onClientResourceStart', resourceRoot, function()
	triggerServerEvent('onClientRequestsVipSkinsTable',resourceRoot)
end)
addEvent('onServerSendVipSkinsTable', true)
addEventHandler('onServerSendVipSkinsTable', localPlayer, function(table)

	skinIds = table
	handleVipSkins()
end)


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


local loadedSkins = {
	-- ['skin_id'] = {dff= dffFile, txd = txdFile, isLoaded = false}
}

function handleVipSkins()
	-- Get used vip skins from player element data
	local usedSkins = {}
	for i, p in ipairs(getElementsByType('player')) do 
		local theId = getElementData(p, 'vip.skin')
		if theId and tonumber(theId) then
			-- Check if id is already added to usedSkins
			local doInsert = true
			for i, v in ipairs(usedSkins) do
				if v == theId then
					doInsert = false
				end
			end
			-- If skin id is not added, add it 
			if doInsert then
				table.insert(usedSkins, theId)
			end
			-- Set female voice for female peds
			if vipSkins[tonumber(theId)] and vipSkins[tonumber(theId)].customVoice then
				-- There doesnt seem to be any female 'death' noises, so disable the voice for female peds
				setPedVoice( p, "PED_TYPE_DISABLED", nil )				
			end
		end
	end
	-- Check for skins that should be unloaded, then load the new skins
	for i, _ in pairs(loadedSkins) do
		local id = string.gsub(i, 'skin_', '')
		if id then id = tonumber(id) end
		if id and not tableIncludes(usedSkins, id) then
			-- Not used anymore, restore model
			engineRestoreModel(skinIds[id])
			loadedSkins[i] = nil
		end
	end
	local path = "items/vipskin/skins/"
	local dffEx = ".dff"
	local txdEx = ".txd"

	-- Start downloading the skins
	for i, id in ipairs(usedSkins) do
		if not vipSkins[id] then
			outputDebugString('VIP Skins: ID '..id..' is not added to the vipSkins table, failed loading.',3,255,0,0)
		else
			-- Download files, completedVipSkinDownload() will handle it further
			local fileName = vipSkins[id].file
			downloadFile(path..fileName..'.txd')
			downloadFile(path..fileName..'.dff')
		end
	end
end
addEvent('onClientMapStarting', true)
addEventHandler('onClientMapStarting', root, handleVipSkins)
-- 'onVipSelectedSkin' triggers for the player that selected a skin only, the rest of the players will get it at 'onClientMapStarting'
addEvent('onVipSelectedSkin', true)
addEventHandler('onVipSelectedSkin', root, handleVipSkins)

function complededVipSkinDownload(file, success)
	if success then
		local theExtension = string.match(file,"^.+(%..+)$")
		if not theExtension or type(theExtension) ~= 'string' then 
			outputDebugString('VIP Skin: Could not find file extension for  '..file,3,255,0,0)
			return
		end

		local withoutExtension = string.gsub(file, theExtension, '')
		local withoutPath = string.gsub(withoutExtension, vipSkinPath, '')
		local skinId = getVipSkinIdFromFileName(withoutPath)

		if theExtension == '.txd' and not isVipSkinLoaded(skinId, 'txd') then
			-- load TXD
			local txd = engineLoadTXD(withoutExtension..'.txd')
			if not txd then
				outputDebugString('VIP Skin: Could not load txd for  '..file,3,255,0,0)
				return
			else
				if not loadedSkins['skin_'..skinId] then
					loadedSkins['skin_'..skinId] = {txd = false, dff = false}
				end
				loadedSkins['skin_'..skinId]['txd'] = txd
				-- Add a fast timer to check if the skin is fully loaded, run 3 times since the checks are not very heavy
				setTimer(replaceVipSkin, 50, 3, skinId)
			end
		elseif theExtension == '.dff' and not isVipSkinLoaded(skinId, 'dff') then
			-- load DFF
			local dff = engineLoadDFF(withoutExtension..'.dff')
			if not dff then
				outputDebugString('VIP Skin: Could not load dff for  '..file,3,255,0,0)
				return
			else
				if not loadedSkins['skin_'..skinId] then
					loadedSkins['skin_'..skinId] = {txd = false, dff = false}
				end
				loadedSkins['skin_'..skinId]['dff'] = dff
				-- Add a fast timer to check if the skin is fully loaded, run 3 times since the checks are not very heavy
				setTimer(replaceVipSkin, 50, 3, skinId)
			end
		end
	else
		outputDebugString('VIP Skin: '..file..' failed to download', 3,255,0,0)
	end
end
addEventHandler('onClientFileDownloadComplete', resourceRoot, complededVipSkinDownload)


function replaceVipSkin(skinId)
	-- Both skins are already loaded, check if theyre applied and apply them
	if not loadedSkins['skin_'..skinId] or loadedSkins['skin_'..skinId]['isLoaded'] then
		-- Skin already loaded, return
		return 
	end
	-- Check if both skins are available
	if not loadedSkins['skin_'..skinId]['txd'] or not loadedSkins['skin_'..skinId]['dff'] then
		return
	end

	local modelId = skinIds[skinId] or false
	if not modelId or not tonumber(modelId) then
		outputDebugString('VIP Skin: Could not find model id for skin: '..file,3,255,0,0)
		return
	end

	local txd = loadedSkins['skin_'..skinId]['txd']
	local dff = loadedSkins['skin_'..skinId]['dff']
	-- outputDebugString('-------------TXD AND DFF--------------')
	-- outputDebugString(txd)
	-- outputDebugString(dff)
	-- outputDebugString('---------------------------')
	local imported = engineImportTXD(txd, tonumber(modelId))
	local loaded = engineReplaceModel(dff, tonumber(modelId))
	if not imported or not loaded then
		-- Reset skin if not loaded
		engineRestoreModel( modelId )
		loadedSkins['skin_'..skinId] = nil
	else
		loadedSkins['skin_'..skinId]['isLoaded'] = true
	end
end

function isVipSkinLoaded(id, type)
	return loadedSkins['skin_'..id] and loadedSkins['skin_'..id][type] or false
end

-- Custom voices on death --
function playCustomSkinVoice ()
	if isElement(source) and getElementType(source) == 'player' and getElementDimension(source) == getElementDimension( localPlayer ) and getElementData(source, 'vip.skin') and vipSkins[getElementData(source, 'vip.skin')] then
		local theCustomVoice = vipSkins[getElementData(source, 'vip.skin')].customVoice
		if theCustomVoice then
			local chosenVoice = theCustomVoice[math.random(1,#theCustomVoice)]
			if source == localPlayer then
				playSound( vipSkinVoicePath..chosenVoice )
			else
				local x, y, z = getElementPosition( source )
				local x1, y1, z1 = getElementPosition(localPlayer)
				if getDistanceBetweenPoints3D( x, y, z, x1, y1, z1 ) < 20 then
					playSound3D( vipSkinVoicePath..chosenVoice, x, y, z)
				end
			end
		end
	end
end
addEventHandler ( "onClientPlayerWasted", root, playCustomSkinVoice )
-- Utils --
function tableIncludes(table, value)
	for i, v in pairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

function getModelIdFromFileName(name)
	-- Get index
	local theIndex = false
	for i, row in ipairs(vipSkins) do
		
		if row.file == name then
			theIndex = i
			break
		end
	end
	if not theIndex then return false end
	return skinIds[theIndex] or false
end

function getVipSkinIdFromFileName(name)
	-- Get index
	local theIndex = false
	for i, row in ipairs(vipSkins) do
		if row.file == name then
			theIndex = i
			break
		end
	end
	return theIndex or false
end
