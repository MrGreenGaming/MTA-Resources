-- Countdown Timer

function askForTimer()
	triggerServerEvent("onAskCD",root)
end
setTimer(askForTimer,5000,1)

cdTimer = false
addEvent("serverSendCD",true)
function receiveTimer(s)
	cdTimer = setTimer(function() end,s*1000,1)
end
addEventHandler("serverSendCD",root,receiveTimer)

local screenW, screenH = guiGetScreenSize()

function drawTimer()
	if isTimer(cdTimer) then
		local timeleft = getTimerDetails(cdTimer) / 1000
		if not timeleft then return end
		local realTimeLeft = secondsToTimeDesc(timeleft)
		-- outputDebugString(realTimeLeft)
		if not realTimeLeft then outputDebugString("realtimeleft false") return end

        dxDrawText("Time until event:\n"..realTimeLeft, screenW * 0.399+1, screenH * 0.930+1, screenW * 0.611+1, screenH * 0.979+1, tocolor(0, 0, 0, 255), 1.00, "default-bold", "center", "center", false, false, false, false, false)
        dxDrawText("Time until event:\n"..realTimeLeft, screenW * 0.399, screenH * 0.930, screenW * 0.611, screenH * 0.979, tocolor(255, 255, 255, 255), 1.00, "default-bold", "center", "center", false, false, false, false, false)
	end

end
addEventHandler("onClientRender",root,drawTimer)




function secondsToTimeDesc( seconds )
	if seconds then
		local results = {}
		local sec = math.floor(( seconds %60 ))
		local min = math.floor ( ( seconds % 3600 ) /60 )
		local hou = math.floor ( ( seconds % 86400 ) /3600 )
		local day = math.floor ( seconds /86400 )

 
		if day > 0 then table.insert( results, day .. ( day == 1 and " day" or " days" ) ) end
		if hou > 0 then table.insert( results, hou .. ( hou == 1 and " hour" or " hours" ) ) end
		if min > 0 then table.insert( results, min .. ( min == 1 and " minute" or " minutes" ) ) end
		if sec > 0 then table.insert( results, sec .. ( sec == 1 and " second" or " seconds" ) ) end
 
		return string.reverse ( table.concat ( results, ", " ):reverse():gsub(" ,", " dna ", 1 ) )
	end
	return ""
end
-- --------
-- --------
-- -------
-- --------
-- ----------
-- --------

-- local textureVehicle = {
-- [500] = { "vehiclegrunge256","*map*" }, 
-- [520] = "hydrabody256", 
-- [552] = { "vehiclegrunge256","*map*" }, 
-- [584] = {"petrotr92interior128","petroltr92decal256"}, 
-- [521] = "fcr90092body128", 
-- [405] = { "vehiclegrunge256","*map*" }, 
-- [585] = { "vehiclegrunge256","*map*" }, 
-- [437] = {"vehiclegrunge256","*map*","bus92decals128","coach92interior128","vehiclegeneric256"}, 
-- [453] = "vehiclegrunge256","*map*", 
-- [469] = "sparrow92body128", 
-- [485] = "vehiclegrunge256","*map*", 
-- [501] = "rcgoblin92texpage128", 
-- [522] = {"nrg50092body128","vehiclegeneric256" },
-- [554] = "vehiclegrunge256","*map*", 
-- [586] = {"wayfarerbody8bit128"}, 
-- [523] = "copbike92body128", 
-- [406] = "vehiclegrunge256","*map*" , 
-- [587] = "vehiclegrunge256","*map*" , 
-- [438] = { "vehiclegrunge256","*map*" }, 
-- [454] = { "vehiclegrunge256","*map*" }, 
-- [470] = { "vehiclegrunge256","*map*" }, 
-- [486] = { "vehiclegrunge256","*map*" }, 
-- [502] = { "vehiclegrunge256","*map*" }, 
-- [524] = { "vehiclegrunge256","*map*" }, 
-- [556] = "monstera92body256a", 
-- [588] = "hotdog92body256", 
-- [525] = { "vehiclegrunge256","*map*" }, 
-- [407] = { "vehiclegrunge256","*map*" }, 
-- [589] = { "vehiclegrunge256","*map*" }, 
-- [439] = { "vehiclegrunge256","*map*" }, 
-- [455] = { "vehiclegrunge256","*map*" }, 
-- [471] = { "vehiclegrunge256","*map*" }, 
-- [487] = "maverick92body128", 
-- [503] = { "vehiclegrunge256","*map*" }, 
-- [526] = { "vehiclegrunge256","*map*" }, 
-- [558] = { "vehiclegrunge256","*map*","@hite" }, 
-- [590] = "freibox92texpage256", 
-- [527] = { "vehiclegrunge256","*map*" }, 
-- [408] = { "vehiclegrunge256","*map*" }, 
-- [424] = { "vehiclegrunge256","*map*" }, 
-- [440] = {"rumpo92adverts256","vehiclegrunge256"}, 
-- [456] = { "yankee92logos", "vehiclegrunge256","*map*" }, 
-- [472] = { "vehiclegrunge256","*map*" }, 
-- [488] = { "vehiclegrunge256","*map*","polmavbody128a"}, 
-- [504] = { "vehiclegrunge256","*map*" }, 
-- [528] = { "vehiclegrunge256","*map*" }, 
-- [560] = { "vehiclegrunge256","*map*","#emapsultanbody256" }, 
-- [592] = {"andromeda92wing", "andromeda92body"}, 
-- [529] = { "vehiclegrunge256","*map*" }, 
-- [409] = { "vehiclegrunge256","*map*" }, 
-- [593] = "dodo92body8bit256", 
-- [441] = "vehiclegeneric256", 
-- [457] = { "vehiclegrunge256","*map*" }, 
-- [473] = { "vehiclegrunge256","*map*" }, 
-- [489] = { "vehiclegrunge256","*map*" }, 
-- [505] = { "vehiclegrunge256","*map*" }, 
-- [530] = { "vehiclegrunge256","*map*" }, 
-- [562] = { "vehiclegrunge256","*map*" }, 
-- [594] = "rccam92pot64", 
-- [531] = { "vehiclegrunge256","*map*" }, 
-- [410] = { "vehiclegrunge256","*map*" }, 
-- [426] = { "vehiclegrunge256","*map*" }, 
-- [442] = { "vehiclegrunge256","*map*" }, 
-- [458] = { "vehiclegrunge256","*map*" }, 
-- [474] = { "vehiclegrunge256","*map*" }, 
-- [490] = { "vehiclegrunge256","*map*" }, 
-- [506] = { "vehiclegrunge256","*map*" }, 
-- [532] = "combinetexpage128", 
-- [564] = "rctiger92body128", 
-- [596] = { "vehiclegrunge256","*map*" }, 
-- [533] = { "vehiclegrunge256","*map*" }, 
-- [411] = { "vehiclegrunge256","*map*" }, 
-- [597] = { "vehiclegrunge256","*map*" }, 
-- [443] = { "vehiclegrunge256","*map*" }, 
-- [459] = { "vehiclegrunge256","*map*" }, 
-- [475] = { "vehiclegrunge256","*map*" }, 
-- [491] = { "vehiclegrunge256","*map*" }, 
-- [507] = { "vehiclegrunge256","*map*" }, 
-- [534] = { "vehiclegrunge256","*map*","*map*" }, 
-- [566] = { "vehiclegrunge256","*map*" }, 
-- [598] = { "vehiclegrunge256","*map*" }, 
-- [535] = { "vehiclegrunge256","*map*","#emapslamvan92body128" }, 
-- [567] = { "vehiclegrunge256","*map*","*map*" }, 
-- [599] = { "vehiclegrunge256","*map*" }, 
-- [444] = { "vehiclegrunge256","*map*" }, 
-- [460] = {"skimmer92body128","vehiclegrunge256","*map*"}, 
-- [476] = "rustler92body256", 
-- [492] = { "vehiclegrunge256","*map*" }, 
-- [508] = { "vehiclegrunge256","*map*" }, 
-- [536] = { "vehiclegrunge256","*map*" }, 
-- [568] = "bandito92interior128", 
-- [600] = { "vehiclegrunge256","*map*" }, 
-- [591] = { "vehiclegrunge256","*map*" }, 
-- [537] = { "vehiclegrunge256","*map*" }, 
-- [413] = { "vehiclegrunge256","*map*" }, 
-- [601] = { "vehiclegrunge256","*map*" }, 
-- [445] = { "vehiclegrunge256","*map*" }, 
-- [461] = { "vehiclegrunge256","*map*" }, 
-- [477] = { "vehiclegrunge256","*map*" }, 
-- [493] = { "vehiclegeneric256" }, 
-- [509] = { "vehiclegrunge256","*map*" }, 
-- [538] = { "vehiclegrunge256","*map*" }, 
-- [570] = { "vehiclegrunge256","*map*" }, 
-- [602] = { "vehiclegrunge256","*map*" }, 
-- [605] = { "vehiclegrunge256","*map*" }, 
-- [425] = "hunterbody8bit256a", 
-- [415] = { "vehiclegrunge256","*map*" }, 
-- [611] = { "vehiclegrunge256","*map*" }, 
-- [569] = { "vehiclegrunge256","*map*" }, 
-- [539] = { "vehiclegrunge256","*map*" }, 
-- [414] = { "vehiclegrunge256","*map*" }, 
-- [430] = {"predator92body128","vehiclegrunge256","*map*"}, 
-- [446] = { "vehiclegrunge256","*map*" }, 
-- [462] = { "vehiclegrunge256","*map*" }, 
-- [478] = { "vehiclegrunge256","*map*" }, 
-- [494] = { "vehiclegrunge256","*map*" }, 
-- [510] = { "vehiclegrunge256","*map*" }, 
-- [540] = { "vehiclegrunge256","*map*" }, 
-- [572] = { "vehiclegrunge256","*map*" }, 
-- [604] = { "vehiclegrunge256","*map*" }, 
-- [557] = "monsterb92body256a", 
-- [607] = { "vehiclegrunge256","*map*" }, 
-- [579] = { "vehiclegrunge256","*map*" }, 
-- [400] = { "vehiclegrunge256","*map*" }, 
-- [404] = { "vehiclegrunge256","*map*" }, 
-- [541] = { "vehiclegrunge256","*map*" }, 
-- [573] = { "vehiclegrunge256","*map*" }, 
-- [431] = {"vehiclegrunge256","*map*","bus92decals128","dash92interior128"}, 
-- [447] = "sparrow92body128", 
-- [463] = { "vehiclegrunge256","*map*" }, 
-- [479] = { "vehiclegrunge256","*map*" }, 
-- [495] = { "vehiclegrunge256","*map*" }, 
-- [511] =  {"vehiclegrunge256","*map*","beagle256"},
-- [542] = { "vehiclegrunge256","*map*" }, 
-- [574] = { "vehiclegrunge256","*map*" }, 
-- [606] = { "vehiclegrunge256","*map*" }, 
-- [555] = { "vehiclegrunge256","*map*" }, 
-- [563] = "raindance92body128", 
-- [428] = { "vehiclegrunge256","*map*" }, 
-- [565] = { "vehiclegrunge256","*map*","@hite" }, 
-- [561] = { "vehiclegrunge256","*map*" }, 
-- [543] = { "vehiclegrunge256","*map*" }, 
-- [416] = { "vehiclegrunge256","*map*" }, 
-- [432] = "rhino92texpage256", 
-- [448] = { "vehiclegrunge256","*map*" }, 
-- [464] = "rcbaron92texpage64", 
-- [480] = { "vehiclegrunge256","*map*" }, 
-- [496] = { "vehiclegrunge256","*map*" }, 
-- [512] = "cropdustbody256", 
-- [544] = { "vehiclegrunge256","*map*" }, 
-- [576] = { "vehiclegrunge256","*map*" }, 
-- [608] = { "vehiclegrunge256","*map*" }, 
-- [559] = { "vehiclegrunge256","*map*" }, 
-- [429] = { "vehiclegrunge256","*map*" }, 
-- [571] = { "vehiclegrunge256","*map*" }, 
-- [427] = { "vehiclegrunge256","*map*" }, 
-- [513] = "stunt256", 
-- [545] = { "vehiclegrunge256","*map*" }, 
-- [577] = "at400_92_256", 
-- [433] = { "vehiclegrunge256","*map*" }, 
-- [449] = { "vehiclegrunge256","*map*" }, 
-- [465] = "rcraider92texpage128", 
-- [481] = "vehiclegeneric256", 
-- [497] = {"polmavbody128a", "vehiclegrunge256","*map*"}, 
-- [514] = { "vehiclegrunge256","*map*" }, 
-- [546] = { "vehiclegrunge256","*map*" }, 
-- [578] = { "vehiclegrunge256","*map*" }, 
-- [610] = { "vehiclegrunge256","*map*" }, 
-- [603] = { "vehiclegrunge256","*map*" }, 
-- [402] = { "vehiclegrunge256","*map*" }, 
-- [412] = { "vehiclegrunge256","*map*" }, 
-- [575] = { "vehiclegrunge256","*map*","remapbroadway92body128" }, 
-- [515] = { "vehiclegrunge256","*map*" }, 
-- [547] = { "vehiclegrunge256","*map*" }, 
-- [418] = { "vehiclegrunge256","*map*" }, 
-- [434] = { "hotknifebody128a", "hotknifebody128b"},
-- [450] = { "vehiclegrunge256","*map*" }, 
-- [466] = { "vehiclegrunge256","*map*" }, 
-- [482] = { "vehiclegrunge256","*map*" }, 
-- [498] = { "vehiclegrunge256","*map*" }, 
-- [516] = { "vehiclegrunge256","*map*" }, 
-- [548] = {"cargobob92body256" ,"vehiclegrunge256","*map*"}, 
-- [580] = { "vehiclegrunge256","*map*" }, 
-- [583] = { "vehiclegrunge256","*map*" }, 
-- [422] = { "vehiclegrunge256","*map*" }, 
-- [423] = { "vehiclegrunge256","*map*" }, 
-- [403] = { "vehiclegrunge256","*map*" }, 
-- [609] = { "vehiclegrunge256","*map*" }, 
-- [517] = { "vehiclegrunge256","*map*" }, 
-- [549] = { "vehiclegrunge256","*map*" }, 
-- [419] = { "vehiclegrunge256","*map*" }, 
-- [435] = "artict1logos", 
-- [451] = { "vehiclegrunge256","*map*" }, 
-- [467] = { "vehiclegrunge256","*map*" }, 
-- [483] = { "vehiclegrunge256","*map*" }, 
-- [499] = { "vehiclegrunge256","*map*" }, 
-- [518] = { "vehiclegrunge256","*map*" }, 
-- [550] = { "vehiclegrunge256","*map*" }, 
-- [582] = { "vehiclegrunge256","*map*" }, 
-- [421] = { "vehiclegrunge256","*map*" }, 
-- [595] = { "vehiclegrunge256","*map*" }, 
-- [553] = { "vehiclegrunge256","*map*","nevada92body256"}, 
-- [581] = "bf40092body128", 
-- [417] = "leviathnbody8bit256", 
-- [519] = "shamalbody256", 
-- [551] = { "vehiclegrunge256","*map*" }, 
-- [420] = { "vehiclegrunge256","*map*" }, 
-- [436] = { "vehiclegrunge256","*map*" }, 
-- [452] = { "vehiclegrunge256","*map*" }, 
-- [468] = { "vehiclegrunge256","*map*" }, 
-- [484] = { "vehiclegrunge256","*map*", "vehiclegeneric256","marquis92interior128" }, 
-- [401] = { "vehiclegrunge256","*map*" },}

-- local webBrowser, shader
-- addEvent('fancy', true)
-- addEventHandler('fancy', root, 
-- function ()
-- 	if webBrowser then destroyElement(webBrowser) end
-- 	if shader then destroyElement(shader) end
-- 	webBrowser = createBrowser(500, 500, true, false)
-- 	local p = source
-- 	addEventHandler("onClientBrowserCreated", webBrowser, 
-- 	function()
-- 		--After the browser has been initialized, we can load our file.
-- 		loadBrowserURL(webBrowser, "dive-into-the-rainbow.gif")
-- 		--Now we can start to render the browser.
-- 		shader, tec = dxCreateShader( "paintjob.fx" )
	   
-- 		--bit of sanity checking
-- 		if not shader then
-- 			outputConsole( "Could not create shader. Please use debugscript 3" )
-- 			destroyElement( texture )
-- 			return false
-- 		elseif not webBrowser then
-- 			outputConsole( "loading texture failed" )
-- 			destroyElement ( shader )
-- 			tec = nil
-- 			return false
-- 		end
-- 		dxSetShaderValue ( shader, "gTexture", webBrowser )
-- 		applyPJtoVehicle(shader,getPedOccupiedVehicle(p))
-- 	end
-- )
-- end)


-- function applyPJtoVehicle(shader,veh)
-- 	if not veh then return false end
-- 	if not shader then return false end
-- 	local player = getVehicleOccupant(veh)
-- 	if not player then return end

-- 	-- removeWorldTexture(player,shader)

-- 	local vehID = getElementModel(veh)
-- 	local apply = false


-- 	if type(textureVehicle[vehID]) == "table" then -- texturegrun -- textureVehicle[vehID]
-- 		for _, texture in ipairs(textureVehicle[vehID]) do
-- 			apply = engineApplyShaderToWorldTexture(shader,texture,veh)

			
-- 		end
-- 	else
-- 		apply = engineApplyShaderToWorldTexture(shader,textureVehicle[vehID],veh)
		
-- 	end

-- 	return apply
-- end

