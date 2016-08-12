------------------------------------
---   Drawing custom paintjobs   ---
------------------------------------

local client_path = 'items/paintjob/';

function onClientElementDataChange(name)
	if name ~= 'gcshop.custompaintjob' then return end

	local val = getElementData(source, 'gcshop.custompaintjob')
	
	
	if val ~= nil then
		addShaders(source, val)
		--outputDebugString("c add custom paintjob")
	else
		removeWorldTexture(source)
		--outputDebugString("c rem custom paintjob")
	end
end
addEventHandler('onClientElementDataChange', root, onClientElementDataChange)
local textureVehicle = {
[500] = { "vehiclegrunge256","*map*" }, 
[520] = "hydrabody256", 
[552] = { "vehiclegrunge256","*map*" }, 
[584] = {"petrotr92interior128","petroltr92decal256"}, 
[521] = "fcr90092body128", 
[405] = { "vehiclegrunge256","*map*" }, 
[585] = { "vehiclegrunge256","*map*" }, 
[437] = {"vehiclegrunge256","*map*","bus92decals128","coach92interior128","vehiclegeneric256"}, 
[453] = "vehiclegrunge256","*map*", 
[469] = "sparrow92body128", 
[485] = "vehiclegrunge256","*map*", 
[501] = "rcgoblin92texpage128", 
[522] = {"nrg50092body128","vehiclegeneric256" },
[554] = "vehiclegrunge256","*map*", 
[586] = {"wayfarerbody8bit128"}, 
[523] = "copbike92body128", 
[406] = "vehiclegrunge256","*map*" , 
[587] = "vehiclegrunge256","*map*" , 
[438] = { "vehiclegrunge256","*map*" }, 
[454] = { "vehiclegrunge256","*map*" }, 
[470] = { "vehiclegrunge256","*map*" }, 
[486] = { "vehiclegrunge256","*map*" }, 
[502] = { "vehiclegrunge256","*map*" }, 
[524] = { "vehiclegrunge256","*map*" }, 
[556] = "monstera92body256a", 
[588] = "hotdog92body256", 
[525] = { "vehiclegrunge256","*map*" }, 
[407] = { "vehiclegrunge256","*map*" }, 
[589] = { "vehiclegrunge256","*map*" }, 
[439] = { "vehiclegrunge256","*map*" }, 
[455] = { "vehiclegrunge256","*map*" }, 
[471] = { "vehiclegrunge256","*map*" }, 
[487] = "maverick92body128", 
[503] = { "vehiclegrunge256","*map*" }, 
[526] = { "vehiclegrunge256","*map*" }, 
[558] = { "vehiclegrunge256","*map*","@hite" }, 
[590] = "freibox92texpage256", 
[527] = { "vehiclegrunge256","*map*" }, 
[408] = { "vehiclegrunge256","*map*" }, 
[424] = { "vehiclegrunge256","*map*" }, 
[440] = {"rumpo92adverts256","vehiclegrunge256"}, 
[456] = { "yankee92logos", "vehiclegrunge256","*map*" }, 
[472] = { "vehiclegrunge256","*map*" }, 
[488] = { "vehiclegrunge256","*map*","polmavbody128a"}, 
[504] = { "vehiclegrunge256","*map*" }, 
[528] = { "vehiclegrunge256","*map*" }, 
[560] = { "vehiclegrunge256","*map*","#emapsultanbody256" }, 
[592] = {"andromeda92wing", "andromeda92body"}, 
[529] = { "vehiclegrunge256","*map*" }, 
[409] = { "vehiclegrunge256","*map*" }, 
[593] = "dodo92body8bit256", 
[441] = "vehiclegeneric256", 
[457] = { "vehiclegrunge256","*map*" }, 
[473] = { "vehiclegrunge256","*map*" }, 
[489] = { "vehiclegrunge256","*map*" }, 
[505] = { "vehiclegrunge256","*map*" }, 
[530] = { "vehiclegrunge256","*map*" }, 
[562] = { "vehiclegrunge256","*map*" }, 
[594] = "rccam92pot64", 
[531] = { "vehiclegrunge256","*map*" }, 
[410] = { "vehiclegrunge256","*map*" }, 
[426] = { "vehiclegrunge256","*map*" }, 
[442] = { "vehiclegrunge256","*map*" }, 
[458] = { "vehiclegrunge256","*map*" }, 
[474] = { "vehiclegrunge256","*map*" }, 
[490] = { "vehiclegrunge256","*map*" }, 
[506] = { "vehiclegrunge256","*map*" }, 
[532] = "combinetexpage128", 
[564] = "rctiger92body128", 
[596] = { "vehiclegrunge256","*map*" }, 
[533] = { "vehiclegrunge256","*map*" }, 
[411] = { "vehiclegrunge256","*map*" }, 
[597] = { "vehiclegrunge256","*map*" }, 
[443] = { "vehiclegrunge256","*map*" }, 
[459] = { "vehiclegrunge256","*map*" }, 
[475] = { "vehiclegrunge256","*map*" }, 
[491] = { "vehiclegrunge256","*map*" }, 
[507] = { "vehiclegrunge256","*map*" }, 
[534] = { "vehiclegrunge256","*map*","*map*" }, 
[566] = { "vehiclegrunge256","*map*" }, 
[598] = { "vehiclegrunge256","*map*" }, 
[535] = { "vehiclegrunge256","*map*","#emapslamvan92body128" }, 
[567] = { "vehiclegrunge256","*map*","*map*" }, 
[599] = { "vehiclegrunge256","*map*" }, 
[444] = { "vehiclegrunge256","*map*" }, 
[460] = {"skimmer92body128","vehiclegrunge256","*map*"}, 
[476] = "rustler92body256", 
[492] = { "vehiclegrunge256","*map*" }, 
[508] = { "vehiclegrunge256","*map*" }, 
[536] = { "vehiclegrunge256","*map*" }, 
[568] = "bandito92interior128", 
[600] = { "vehiclegrunge256","*map*" }, 
[591] = { "vehiclegrunge256","*map*" }, 
[537] = { "vehiclegrunge256","*map*" }, 
[413] = { "vehiclegrunge256","*map*" }, 
[601] = { "vehiclegrunge256","*map*" }, 
[445] = { "vehiclegrunge256","*map*" }, 
[461] = { "vehiclegrunge256","*map*" }, 
[477] = { "vehiclegrunge256","*map*" }, 
[493] = { "vehiclegeneric256" }, 
[509] = { "vehiclegrunge256","*map*" }, 
[538] = { "vehiclegrunge256","*map*" }, 
[570] = { "vehiclegrunge256","*map*" }, 
[602] = { "vehiclegrunge256","*map*" }, 
[605] = { "vehiclegrunge256","*map*" }, 
[425] = "hunterbody8bit256a", 
[415] = { "vehiclegrunge256","*map*" }, 
[611] = { "vehiclegrunge256","*map*" }, 
[569] = { "vehiclegrunge256","*map*" }, 
[539] = { "vehiclegrunge256","*map*" }, 
[414] = { "vehiclegrunge256","*map*" }, 
[430] = {"predator92body128","vehiclegrunge256","*map*"}, 
[446] = { "vehiclegrunge256","*map*" }, 
[462] = { "vehiclegrunge256","*map*" }, 
[478] = { "vehiclegrunge256","*map*" }, 
[494] = { "vehiclegrunge256","*map*" }, 
[510] = { "vehiclegrunge256","*map*" }, 
[540] = { "vehiclegrunge256","*map*" }, 
[572] = { "vehiclegrunge256","*map*" }, 
[604] = { "vehiclegrunge256","*map*" }, 
[557] = "monsterb92body256a", 
[607] = { "vehiclegrunge256","*map*" }, 
[579] = { "vehiclegrunge256","*map*" }, 
[400] = { "vehiclegrunge256","*map*" }, 
[404] = { "vehiclegrunge256","*map*" }, 
[541] = { "vehiclegrunge256","*map*" }, 
[573] = { "vehiclegrunge256","*map*" }, 
[431] = {"vehiclegrunge256","*map*","bus92decals128","dash92interior128"}, 
[447] = "sparrow92body128", 
[463] = { "vehiclegrunge256","*map*" }, 
[479] = { "vehiclegrunge256","*map*" }, 
[495] = { "vehiclegrunge256","*map*" }, 
[511] =  {"vehiclegrunge256","*map*","beagle256"},
[542] = { "vehiclegrunge256","*map*" }, 
[574] = { "vehiclegrunge256","*map*" }, 
[606] = { "vehiclegrunge256","*map*" }, 
[555] = { "vehiclegrunge256","*map*" }, 
[563] = "raindance92body128", 
[428] = { "vehiclegrunge256","*map*" }, 
[565] = { "vehiclegrunge256","*map*","@hite" }, 
[561] = { "vehiclegrunge256","*map*" }, 
[543] = { "vehiclegrunge256","*map*" }, 
[416] = { "vehiclegrunge256","*map*" }, 
[432] = "rhino92texpage256", 
[448] = { "vehiclegrunge256","*map*" }, 
[464] = "rcbaron92texpage64", 
[480] = { "vehiclegrunge256","*map*" }, 
[496] = { "vehiclegrunge256","*map*" }, 
[512] = "cropdustbody256", 
[544] = { "vehiclegrunge256","*map*" }, 
[576] = { "vehiclegrunge256","*map*" }, 
[608] = { "vehiclegrunge256","*map*" }, 
[559] = { "vehiclegrunge256","*map*" }, 
[429] = { "vehiclegrunge256","*map*" }, 
[571] = { "vehiclegrunge256","*map*" }, 
[427] = { "vehiclegrunge256","*map*" }, 
[513] = "stunt256", 
[545] = { "vehiclegrunge256","*map*" }, 
[577] = "at400_92_256", 
[433] = { "vehiclegrunge256","*map*" }, 
[449] = { "vehiclegrunge256","*map*" }, 
[465] = "rcraider92texpage128", 
[481] = "vehiclegeneric256", 
[497] = {"polmavbody128a", "vehiclegrunge256","*map*"}, 
[514] = { "vehiclegrunge256","*map*" }, 
[546] = { "vehiclegrunge256","*map*" }, 
[578] = { "vehiclegrunge256","*map*" }, 
[610] = { "vehiclegrunge256","*map*" }, 
[603] = { "vehiclegrunge256","*map*" }, 
[402] = { "vehiclegrunge256","*map*" }, 
[412] = { "vehiclegrunge256","*map*" }, 
[575] = { "vehiclegrunge256","*map*","remapbroadway92body128" }, 
[515] = { "vehiclegrunge256","*map*" }, 
[547] = { "vehiclegrunge256","*map*" }, 
[418] = { "vehiclegrunge256","*map*" }, 
[434] = { "hotknifebody128a", "hotknifebody128b"},
[450] = { "vehiclegrunge256","*map*" }, 
[466] = { "vehiclegrunge256","*map*" }, 
[482] = { "vehiclegrunge256","*map*" }, 
[498] = { "vehiclegrunge256","*map*" }, 
[516] = { "vehiclegrunge256","*map*" }, 
[548] = {"cargobob92body256" ,"vehiclegrunge256","*map*"}, 
[580] = { "vehiclegrunge256","*map*" }, 
[583] = { "vehiclegrunge256","*map*" }, 
[422] = { "vehiclegrunge256","*map*" }, 
[423] = { "vehiclegrunge256","*map*" }, 
[403] = { "vehiclegrunge256","*map*" }, 
[609] = { "vehiclegrunge256","*map*" }, 
[517] = { "vehiclegrunge256","*map*" }, 
[549] = { "vehiclegrunge256","*map*" }, 
[419] = { "vehiclegrunge256","*map*" }, 
[435] = "artict1logos", 
[451] = { "vehiclegrunge256","*map*" }, 
[467] = { "vehiclegrunge256","*map*" }, 
[483] = { "vehiclegrunge256","*map*" }, 
[499] = { "vehiclegrunge256","*map*" }, 
[518] = { "vehiclegrunge256","*map*" }, 
[550] = { "vehiclegrunge256","*map*" }, 
[582] = { "vehiclegrunge256","*map*" }, 
[421] = { "vehiclegrunge256","*map*" }, 
[595] = { "vehiclegrunge256","*map*" }, 
[553] = { "vehiclegrunge256","*map*","nevada92body256"}, 
[581] = "bf40092body128", 
[417] = "leviathnbody8bit256", 
[519] = "shamalbody256", 
[551] = { "vehiclegrunge256","*map*" }, 
[420] = { "vehiclegrunge256","*map*" }, 
[436] = { "vehiclegrunge256","*map*" }, 
[452] = { "vehiclegrunge256","*map*" }, 
[468] = { "vehiclegrunge256","*map*" }, 
[484] = { "vehiclegrunge256","*map*", "vehiclegeneric256","marquis92interior128" }, 
[401] = { "vehiclegrunge256","*map*" },}



local removeTable = {}
function buildRemoveTable() -- Gets all used textures and puts them in a table for a remove list.
	local function isTextureInTable(texture)
		for _,texture2 in ipairs(removeTable) do
			if texture == texture2 then
				return true
			end
		end
		return false
	end

	for _,texture in pairs(textureVehicle) do
		if type(texture) == "table" then
			for _,texture2 in ipairs(texture) do
				if not isTextureInTable(texture2) then
					table.insert(removeTable,texture2)
					
				end
			end
		else
			if not isTextureInTable(texture) then
				table.insert(removeTable,texture)
			end
		end
	end
end
addEventHandler("onClientResourceStart",resourceRoot,buildRemoveTable)




local shaders = {}
function addShaders(player, val, newUpload)
	local veh = getPedOccupiedVehicle(player) or nil
	if not veh or not val or not fileExists(client_path .. val .. '.bmp') then return end

	if shaders[player] then
		if shaders[player][3] ~= val or newUpload then -- Different PJ then before
			-- outputDebugString("Using Different PJ")
			remShaders ( player )

			local texture, shader = createPJShader(val)
			
			-- outputConsole('adding shader for ' .. getPlayerName(player))
			shaders[player] = {texture, shader,val}

			applyPJtoVehicle(shader,veh)

			return 
		elseif shaders[player][3] == val then -- Same PJ as before
			-- outputDebugString("Using Same PJ")
			local texture = shaders[player][1]
			local shader = shaders[player][2]

			applyPJtoVehicle(shader,veh)
			return
		end
	else -- New PJ
		-- outputDebugString("Using New PJ")
		remShaders ( player )

		local texture, shader = createPJShader(val)
		
		-- outputConsole('adding shader for ' .. getPlayerName(player))
		shaders[player] = {texture, shader,val}


		applyPJtoVehicle(shader,veh)
		return
	end
end


function removeWorldTexture(player)

	if not shaders[player] then return end
	if not shaders[player][2] then return end
	local shader = shaders[player][2]
	if not shader then return end

	local veh = getPedOccupiedVehicle(player)

	engineRemoveShaderFromWorldTexture(shader,"vehiclegeneric256",veh)
	for _,texture in pairs(removeTable) do
		engineRemoveShaderFromWorldTexture(shader,texture,veh)
	end

	
end


function applyPJtoVehicle(shader,veh)
	if not veh then return false end
	if not shader then return false end
	local player = getVehicleOccupant(veh)
	if not player then return end

	removeWorldTexture(player,shader)

	local vehID = getElementModel(veh)
	local apply = false


	if type(textureVehicle[vehID]) == "table" then -- texturegrun -- textureVehicle[vehID]
		for _, texture in ipairs(textureVehicle[vehID]) do
			apply = engineApplyShaderToWorldTexture(shader,texture,veh)

			
		end
	else
		apply = engineApplyShaderToWorldTexture(shader,textureVehicle[vehID],veh)
		
	end

	return apply
end

function createPJShader(val)
	if not val then return false end

	local texture = dxCreateTexture ( client_path .. val .. '.bmp' )
	local shader, tec = dxCreateShader( client_path .. "paintjob.fx" )
   
	--bit of sanity checking
	if not shader then
		outputConsole( "Could not create shader. Please use debugscript 3" )
		destroyElement( texture )
		return false
	elseif not texture then
		outputConsole( "loading texture failed" )
		destroyElement ( shader )
		tec = nil
		return false
	end
	dxSetShaderValue ( shader, "gTexture", texture )
	return texture,shader,tec
end

function remShaders ( player )
	if shaders[player] and isElement(shaders[player][2]) then
		destroyElement(shaders[player][1])
		destroyElement(shaders[player][2])
		shaders[player]=nil
		-- outputConsole('removed shader for ' .. getPlayerName(player))

	end
end

function refreshShaders()
	
	for _,player in pairs(shaders) do
		
		if isElement(player[1]) then destroyElement(player[1]) end
		if isElement(player[2]) then destroyElement(player[2]) end
		
	end
	shaders = {}
	

end
addEvent("clientRefreshShaderTable",true)
addEventHandler("clientRefreshShaderTable",root,refreshShaders)


function onGCShopLogout (forumID)
	remShaders ( source )
end
addEventHandler("onGCShopLogout", root, onGCShopLogout)

function onClientStart()
	triggerServerEvent('clientSendPaintjobs', root, root, localPlayer)
end
addEventHandler('onClientResourceStart', resourceRoot, onClientStart)

-- local prev
-- setTimer( function()
-- 	local veh = getPedOccupiedVehicle(localPlayer)
-- 	if prev then
-- 		if not (veh and isElement(veh)) then
-- 			prev = nil
-- 			remShaders(localPlayer)
-- 		elseif prev ~= getElementModel(veh) then
-- 			prev = getElementModel(veh)
-- 			remShaders(localPlayer)
-- 		end
-- 	elseif veh and getElementModel(veh) then
-- 		prev = getElementModel(veh)
-- 	end
	
-- end, 50, 0)

--------------------------------------
---   Uploading custom paintjobs   ---
--------------------------------------
local allowedExtensions = {".png",".bmp",".jpg"}
function gcshopRequestPaintjob(imageMD5, forumID, filename, id)
	if not player_perks[4] then return outputChatBox('Buy the perk!', 255, 0, 0); end
	--outputDebugString('c: Requesting paintjob ' ..tostring( filename) .. ' ' .. tostring(forumID) .. ' ' .. getPlayerName(localPlayer))
	if string.find(filename,".tinypic.com/") or string.find(filename,"i.imgur.com/") or string.find(filename,".postimg.org/") then -- If filename is hosting URL
		local forbiddenFile = 0
		for _,ext in ipairs(allowedExtensions) do
			if string.find(filename,ext) then
				forbiddenFile = forbiddenFile + 1
			end
		end

		if forbiddenFile ~= 1 then -- If file has forbidden extension
			outputChatBox('Please use a different file extension (only .png, .jpg and .bmp allowed!)', 255, 0, 0)
		elseif forbiddenFile == 1 then
			triggerServerEvent("serverReceiveHostingURL",localPlayer,filename,id)
		end
	else -- Normal upload from disk
		if not fileExists(filename) then
			-- File not found, abort
			--outputDebugString('c: File not found ' .. tostring(filename) .. ' ' .. tostring(forumID) .. ' ' .. getPlayerName(localPlayer))
			outputChatBox('Custom paintjob image "' .. tostring(filename) .. '" not found!', 255, 0, 0)
		else
			local localMD5 = getMD5(filename)
			if localMD5 == imageMD5 then
				-- image didn't chance, tell the server to use the old custom texture
				--outputDebugString('c: Same image, not uploading ' .. tostring(localMD5) .. ' ' .. tostring(imageMD5) .. ' ' .. getPlayerName(localPlayer))
				triggerServerEvent( 'receiveImage', localPlayer, false, id)
			elseif not isValidImage(filename) then
				outputChatBox('Custom paintjob image "' .. tostring(filename) .. '" is not a valid image!!', 255, 0, 0)
			else
				-- a new image needs to be uploaded
				--outputDebugString('c: New image ' .. tostring(localMD5) .. ' ' .. tostring(imageMD5) .. ' ' .. getPlayerName(localPlayer))
				local file = fileOpen(filename, true)
				local image = fileRead(file, fileGetSize(file))
				fileClose(file)
				triggerLatentServerEvent('receiveImage', 1000000, localPlayer, image, id)
			end
		end
	end
end
addEvent('gcshopRequestPaintjob', true)
addEventHandler('gcshopRequestPaintjob', resourceRoot, gcshopRequestPaintjob)

function isValidImage(image)
	local isImage = guiCreateStaticImage( 1.1, 1.1, 0.01, 0.01, image, true);
	if not isImage then	return false end
	destroyElement(isImage);
	local file = fileOpen(image, true);
	local size = fileGetSize(file);
	fileClose(file);
	if size <= 1000000/2 then
		return true;
	end
end


----------------------------------------
---   Downloading custom paintjobs   ---
---          from server             ---
----------------------------------------

function serverPaintjobsMD5 ( md5list )
	local requests = {}
	for forumID, playermd5list in pairs(md5list) do
		for pid, imageMD5 in pairs(playermd5list) do
			local filename = tostring(forumID) .. '-' .. pid .. '.bmp'
			if not fileExists(client_path .. filename) or imageMD5 ~= getMD5(client_path .. filename) then
				table.insert(requests, filename)
				--outputDebugString('c: Requesting paintjob ' .. tostring(filename) .. ' ' .. tostring(fileExists(filename) and getMD5(filename)) .. ' ' .. tostring(imageMD5) .. ' ' .. getPlayerName(localPlayer))
			end
		end
	end
	
	if #requests > 0 then
		triggerServerEvent( 'clientRequestsPaintjobs', localPlayer, requests)
	end
	
	for k, player in ipairs(getElementsByType'player') do
		local val = getElementData(player, 'gcshop.custompaintjob')
		if val ~= nil then
			addShaders(player, val)
		else
			remShaders(player)
		end
	end
end
addEvent('serverPaintjobsMD5', true)
addEventHandler('serverPaintjobsMD5', resourceRoot, serverPaintjobsMD5)

function serverSendsPaintjobs ( files )
	for filename, image in pairs(files) do
		local file = fileCreate(client_path .. filename)
		fileWrite(file, image)
		fileClose(file)
		--outputDebugString('c: Received paintjob ' .. tostring(filename) .. ' ' .. getPlayerName(localPlayer))
	end
	if previewPJ then previewPJ() end
	
	for k, player in ipairs(getElementsByType'player') do
		local val = getElementData(player, 'gcshop.custompaintjob')
		if val ~= nil then
			addShaders(player, val)
		else
			remShaders(player)
		end
	end
end
addEvent('serverSendsPaintjobs', true)
addEventHandler('serverSendsPaintjobs', resourceRoot, serverSendsPaintjobs)

function getMD5 ( filename )
	if not fileExists(filename) then
		error("getMD5: File " .. filename .. ' not found!', 2)
	end

	local file = fileOpen(filename, true)
	local image = fileRead(file, fileGetSize(file))
	fileClose(file)
	return md5(image)
end