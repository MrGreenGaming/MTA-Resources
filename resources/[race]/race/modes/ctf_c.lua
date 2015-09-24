local maxWins
local teams = {}
local blueFlag, redFlag = nil, nil
local blueBlip, redBlip = nil, nil
local blueBlip2, redBlip2 = nil, nil
local redPoints, bluePoints = 0, 0


local red_shader,blue_shader
function ctfStart(red, blue, maxWins_)
	engineImportTXD(engineLoadTXD('model/' .. 'rcflagxred' .. '.txd'), 2914)
	engineReplaceModel(engineLoadDFF('model/' .. 'kmb_rcflag' .. '.dff', 2914), 2914)
	engineSetModelLODDistance( 2914, 60 )

	engineImportTXD(engineLoadTXD('model/' .. 'rcflagxblue' .. '.txd'), 2048)
	engineReplaceModel(engineLoadDFF('model/' .. 'kmb_rcflag' .. '.dff', 2048), 2048)
	engineSetModelLODDistance( 2048, 60 )
	addEventHandler('onClientPreRender', root, ctfRender)
	teams = {}
	redFlag, blueFlag = red, blue
	if getResourceFromName'customblips' then
		blueBlip = exports.customblips:createCustomBlip ( -20, -20, 16, 16, 'model/Blipid53.png', 50000 )
		redBlip  = exports.customblips:createCustomBlip ( -30, -30, 16, 16, 'model/Blipid19.png', 50000 )
	end
	
	blueBlip2 = createBlipAttachedTo(blueFlag, 59, 3, 255, 255, 255, 255, 500, 0)
	redBlip2  = createBlipAttachedTo(redFlag,  59, 3, 255, 255, 255, 255, 500, 0)

	setElementData(blueBlip2,"customBlipPath",':race/model/Blipid53.png')
	setElementData(redBlip2, "customBlipPath",':race/model/Blipid19.png')
	setElementData(blueBlip2,"customBlipIgnoreDist", true)
	setElementData(redBlip2, "customBlipIgnoreDist", true)
	
	redPoints, bluePoints = 0, 0
	maxWins = maxWins_

	-- Make team shaders
	CTFvehIDCheckTimer = setTimer(ctfCheckVehID,200,0)
	local red_texture = dxCreateTexture ( ':race/img/pj_red.png' )
	local blue_texture = dxCreateTexture ( ':race/img/pj_blue.png' )

	red_shader = dxCreateShader( ":race/shaders/paintjob.fx" )
	blue_shader = dxCreateShader( ":race/shaders/paintjob.fx" )

	-- fail checks --
	if not red_shader or not blue_shader then destroyElement(blue_shader) destroyElement(red_shader) destroyElement(red_texture) destroyElement(blue_texture) return end
	if not red_texture or not blue_texture then 
		destroyElement(red_shader) 
		destroyElement(blue_shader) 
		local r = red_texture 
		local b = blue_texture 
		if isElement(r) then 
			destroyElement(r) 
		end 
		if isElement(b) then 
			destoryElement(b) 
		end
		return
	end

	dxSetShaderValue ( red_shader, "gTexture", red_texture )
	dxSetShaderValue ( blue_shader, "gTexture", blue_texture )

	-- end fail checks --





end






function ctfStop()
	if isTimer(CTFvehIDCheckTimer) then killTimer(CTFvehIDCheckTimer) end
	if isElement(red_shader) then destroyElement(red_shader) red_shader = false end
	if isElement(blue_shader) then destroyElement(blue_shader) blue_shader = false end

	engineRestoreModel(2914)
	engineRestoreModel(2048)
	if blueBlip then 
		if getResourceFromName'customblips' then
			exports.customblips:destroyCustomBlip(blueBlip)
		end
		blueBlip = nil
	end
	if redBlip then 
		if getResourceFromName'customblips' then
			exports.customblips:destroyCustomBlip(redBlip)
		end
		redBlip = nil
	end
	if blueBlip2 then
		if isElement(blueBlip2) then
			destroyElement(blueBlip2)
		end
		blueBlip2 = nil
	end
	if redBlip2 then
		if isElement(redBlip2) then
			destroyElement(redBlip2)
		end
		redBlip2 = nil
	end
	teams = {}
	removeEventHandler('onClientPreRender', root, ctfRender)
end

function ctfCarrier(team, player)
	if not teams[team] then
		teams[team] = {}
	end
	teams[team].FLAG_TAKER = player
end

function ctfTeamPoints(team, points)
	if (getTeamName(team) == 'Red team') then
		redPoints = points
	elseif (getTeamName(team) == 'Blue team') then
		bluePoints = points
	end
end


local screnX, screnY = guiGetScreenSize()
function ctfRender()
	-- Rotate flags
	local angle = math.fmod((getTickCount() - g_PickupStartTick) * 360 / 2000, 360)
	for _, obj in ipairs(getElementsByType('object')) do 
		if getElementModel(obj) == 2914 or getElementModel(obj) == 2048 then
			setElementRotation(obj, 0, 0,angle)
		end
	end
	
	-- Team points text
	dxDrawText( 'Red Team Points: '..redPoints .. '/' .. maxWins, 0, 0, screnX+2, screnY-25+2, tocolor ( 0, 0, 0, 255 ), 1.0, 'bankgothic', "center", "bottom", false, false, false)
	dxDrawText( 'Red Team Points: '..redPoints .. '/' .. maxWins, 0, 0, screnX, screnY-25, tocolor ( 255, 0, 0, 255 ), 1.0, 'bankgothic', "center", "bottom", false, false, false)
	dxDrawText( 'Blue Team Points: '..bluePoints .. '/' .. maxWins, 0, 0, screnX+2, screnY+2, tocolor ( 0, 0, 0, 255 ), 1.0, 'bankgothic', "center", "bottom", false, false, false)
	dxDrawText( 'Blue Team Points: '..bluePoints .. '/' .. maxWins, 0, 0, screnX, screnY, tocolor ( 0, 0, 255, 255 ), 1.0, 'bankgothic', "center", "bottom", false, false, false)
	
	-- Taken flags text
	local i = 0
	for team, data in pairs(teams) do
		local FLAG_TAKEN = team
		local FLAG_TAKER = data.FLAG_TAKER
		if FLAG_TAKEN and isElement(FLAG_TAKEN) and FLAG_TAKER and isElement(FLAG_TAKER) then
			dxDrawText( getTeamName(FLAG_TAKEN) .. '\'s flag is taken', 15, 0 + 35 * i, screnX*3/4 + 2, screnY-25+2, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "left", "center", true, false, false)
			dxDrawText( getTeamName(FLAG_TAKEN) .. '\'s flag is taken', 15, 0 + 35 * i, screnX*3/4, screnY-25, tocolor ( getTeamColor(FLAG_TAKEN) ), 0.8, 'bankgothic', "left", "center", true, false, false)
			dxDrawText( 'Flag holder: '..getPlayerName(FLAG_TAKER), 15, 35 + 35 * i, screnX*3/4 + 2, screnY-25+2, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "left", "center", true, false, false)
			dxDrawText( 'Flag holder: '..string.format("#%.2X%.2X%.2X", getTeamColor(getPlayerTeam(FLAG_TAKER))) .. getPlayerName(FLAG_TAKER), 15, 35 + 35 * i, screnX*3/4, screnY-25, tocolor ( getTeamColor(FLAG_TAKEN) ), 0.8, 'bankgothic', "left", "center", true, false, false, true)
		end
		i = i + 2
	end
	
	-- Custom flag blips
	if not getResourceFromName'customblips' then
		if blueBlip then blueBlip = nil end
		if  redBlip then  redBlip = nil end
	else
		if blueBlip and blueFlag and isElement(blueFlag) then
			local worldX, worldY = getElementPosition(blueFlag)
			exports.customblips:setCustomBlipPosition ( blueBlip, worldX, worldY )
		end
		if redBlip and redFlag and isElement(redFlag) then
			local worldX, worldY = getElementPosition(redFlag)
			exports.customblips:setCustomBlipPosition ( redBlip, worldX, worldY )
		end
	end
end


local textureVehicle = { -- Used to determine what textures to color for the shader
[500] = { "vehiclegrunge256","*map*" }, 
[520] = {"hydrabody256"}, 
[552] = { "vehiclegrunge256","*map*" }, 
[584] = {"petrotr92interior128","petroltr92decal256"}, 
[521] = {"fcr90092body128"}, 
[405] = { "vehiclegrunge256","*map*" }, 
[585] = { "vehiclegrunge256","*map*" }, 
[437] = {"vehiclegrunge256","*map*","bus92decals128","coach92interior128","vehiclegeneric256"}, 
[453] = {"vehiclegrunge256","*map*"}, 
[469] = {"sparrow92body128"}, 
[485] = {"vehiclegrunge256","*map*"}, 
[501] = {"rcgoblin92texpage128"}, 
[522] = {"nrg50092body128","vehiclegeneric256" },
[554] = {"vehiclegrunge256","*map*"}, 
[586] = {"wayfarerbody8bit128"}, 
[523] = {"copbike92body128"}, 
[406] = {"vehiclegrunge256","*map*" }, 
[587] = {"vehiclegrunge256","*map*" }, 
[438] = { "vehiclegrunge256","*map*" }, 
[454] = { "vehiclegrunge256","*map*" }, 
[470] = { "vehiclegrunge256","*map*" }, 
[486] = { "vehiclegrunge256","*map*" }, 
[502] = { "vehiclegrunge256","*map*" }, 
[524] = { "vehiclegrunge256","*map*" }, 
[556] = {"monstera92body256a"}, 
[588] = {"hotdog92body256"}, 
[525] = { "vehiclegrunge256","*map*" }, 
[407] = { "vehiclegrunge256","*map*" }, 
[589] = { "vehiclegrunge256","*map*" }, 
[439] = { "vehiclegrunge256","*map*" }, 
[455] = { "vehiclegrunge256","*map*" }, 
[471] = { "vehiclegrunge256","*map*" }, 
[487] = {"maverick92body128"}, 
[503] = { "vehiclegrunge256","*map*" }, 
[526] = { "vehiclegrunge256","*map*" }, 
[558] = { "vehiclegrunge256","*map*","@hite" }, 
[590] = {"freibox92texpage256"}, 
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
[593] = {"dodo92body8bit256"}, 
[441] = {"vehiclegeneric256"}, 
[457] = { "vehiclegrunge256","*map*" }, 
[473] = { "vehiclegrunge256","*map*" }, 
[489] = { "vehiclegrunge256","*map*" }, 
[505] = { "vehiclegrunge256","*map*" }, 
[530] = { "vehiclegrunge256","*map*" }, 
[562] = { "vehiclegrunge256","*map*" }, 
[594] = {"rccam92pot64"}, 
[531] = { "vehiclegrunge256","*map*" }, 
[410] = { "vehiclegrunge256","*map*" }, 
[426] = { "vehiclegrunge256","*map*" }, 
[442] = { "vehiclegrunge256","*map*" }, 
[458] = { "vehiclegrunge256","*map*" }, 
[474] = { "vehiclegrunge256","*map*" }, 
[490] = { "vehiclegrunge256","*map*" }, 
[506] = { "vehiclegrunge256","*map*" }, 
[532] = {"combinetexpage128"}, 
[564] = {"rctiger92body128"}, 
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
[476] = {"rustler92body256"}, 
[492] = { "vehiclegrunge256","*map*" }, 
[508] = { "vehiclegrunge256","*map*" }, 
[536] = { "vehiclegrunge256","*map*" }, 
[568] = {"bandito92interior128"}, 
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
[425] = {"hunterbody8bit256a"}, 
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
[557] = {"monsterb92body256a"}, 
[607] = { "vehiclegrunge256","*map*" }, 
[579] = { "vehiclegrunge256","*map*" }, 
[400] = { "vehiclegrunge256","*map*" }, 
[404] = { "vehiclegrunge256","*map*" }, 
[541] = { "vehiclegrunge256","*map*" }, 
[573] = { "vehiclegrunge256","*map*" }, 
[431] = {"vehiclegrunge256","*map*","bus92decals128","dash92interior128"}, 
[447] = {"sparrow92body128"}, 
[463] = { "vehiclegrunge256","*map*" }, 
[479] = { "vehiclegrunge256","*map*" }, 
[495] = { "vehiclegrunge256","*map*" }, 
[511] =  {"vehiclegrunge256","*map*","beagle256"},
[542] = { "vehiclegrunge256","*map*" }, 
[574] = { "vehiclegrunge256","*map*" }, 
[606] = { "vehiclegrunge256","*map*" }, 
[555] = { "vehiclegrunge256","*map*" }, 
[563] = {"raindance92body128"}, 
[428] = { "vehiclegrunge256","*map*" }, 
[565] = { "vehiclegrunge256","*map*","@hite" }, 
[561] = { "vehiclegrunge256","*map*" }, 
[543] = { "vehiclegrunge256","*map*" }, 
[416] = { "vehiclegrunge256","*map*" }, 
[432] = {"rhino92texpage256"}, 
[448] = { "vehiclegrunge256","*map*" }, 
[464] = {"rcbaron92texpage64"}, 
[480] = { "vehiclegrunge256","*map*" }, 
[496] = { "vehiclegrunge256","*map*" }, 
[512] = {"cropdustbody256"}, 
[544] = { "vehiclegrunge256","*map*" }, 
[576] = { "vehiclegrunge256","*map*" }, 
[608] = { "vehiclegrunge256","*map*" }, 
[559] = { "vehiclegrunge256","*map*" }, 
[429] = { "vehiclegrunge256","*map*" }, 
[571] = { "vehiclegrunge256","*map*" }, 
[427] = { "vehiclegrunge256","*map*" }, 
[513] = {"stunt256"}, 
[545] = { "vehiclegrunge256","*map*" }, 
[577] = {"at400_92_256"}, 
[433] = { "vehiclegrunge256","*map*" }, 
[449] = { "vehiclegrunge256","*map*" }, 
[465] = {"rcraider92texpage128"}, 
[481] = {"vehiclegeneric256"}, 
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
[435] = {"artict1logos"}, 
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
[581] = {"bf40092body128"}, 
[417] = {"leviathnbody8bit256"}, 
[519] = {"shamalbody256"}, 
[551] = { "vehiclegrunge256","*map*" }, 
[420] = { "vehiclegrunge256","*map*" }, 
[436] = { "vehiclegrunge256","*map*" }, 
[452] = { "vehiclegrunge256","*map*" }, 
[468] = { "vehiclegrunge256","*map*" }, 
[484] = { "vehiclegrunge256","*map*", "vehiclegeneric256","marquis92interior128" }, 
[401] = { "vehiclegrunge256","*map*" },
}

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



function applyTeamColorShader(player,retry)
	if not red_shader or not blue_shader then
		local retry = retry
		if not retry then retry = 0 end
		if retry < 3 then 
			local retry = retry + 1 
			setTimer(applyTeamColorShader,2000,1,player,retry)
		elseif retry >= 3 then
			-- local pv = getPedOccupiedVehicle(player)
			-- local r,g,b = getTeamColor(getPlayerTeam(player))
			-- setVehicleColor(pv,r,g,b,r,g,b,r,g,b,r,g,b)
		end 
		return 
	end

	if not player then return end

	local teamName = getTeamName(getPlayerTeam(player))
	if not teamName then return end


	local pVeh = getPedOccupiedVehicle(player)
	local vehID = getElementModel(pVeh)



	-- Remove and Apply shader texture to vehicle

	--remove
	for _,texture in pairs(removeTable) do
		if string.find(teamName,"Red") then
			engineRemoveShaderFromWorldTexture(red_shader,texture,pVeh)
		elseif string.find(teamName,"Blue") then
			engineRemoveShaderFromWorldTexture(blue_shader,texture,pVeh)
		end
	end

	--apply
	for _, texture in ipairs(textureVehicle[vehID]) do
		if string.find(teamName,"Red") then
			local apply = engineApplyShaderToWorldTexture(red_shader,texture,pVeh)
			-- if apply then
			-- 	setVehicleColor(pVeh,255,255,255,255,255,255,255,255,255,255,255,255)
			-- end
		elseif string.find(teamName,"Blue") then
			local apply = engineApplyShaderToWorldTexture(blue_shader,texture,pVeh)
			-- if apply then
			-- 	setVehicleColor(pVeh,255,255,255,255,255,255,255,255,255,255,255,255)
			-- end
		end
	end

end


-- Veh ID checker for recoloring --
local currentID = false
function ctfCheckVehID()
	local pvh = getPedOccupiedVehicle(localPlayer)
	if not pvh then return end
	
	local vehID = getElementModel(pvh)
	if currentID ~= vehID then
		currentID = vehID
		triggerServerEvent("ctf_clientVehChange",localPlayer)
	end
end