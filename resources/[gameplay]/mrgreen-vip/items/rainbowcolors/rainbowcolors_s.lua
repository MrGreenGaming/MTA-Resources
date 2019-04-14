
-- function rainbowcmd (psource,cmd)
-- 	if isPlayerVIP(psource) then
-- 		if getElementData(psource,'vip.rainbow') then
-- 			removeElementData( psource, 'vip.rainbow' )
-- 			outputChatBox( 'VIP rainbow effect deactivated', psource, 0, 0, 255 )
-- 		else
-- 			setElementData( psource, 'vip.rainbow', true )
-- 			outputChatBox( 'VIP rainbow effect activated', psource, 0, 0, 255 )
-- 		end
-- 	end
-- end
-- addCommandHandler( 'viprainbow', rainbowcmd )

-- addEvent('vip-toggleRainbow', true)
-- addEventHandler('vip-toggleRainbow', root, function()	
-- 	rainbowcmd(source, 'viprainbow')
-- end)
-- [3] = {lights = false, paintjob = false, wheels = false},
function setVipRainbowColors(player,options)
	if not player or not isPlayerVIP(player) or options == nil then return end

	-- Check if valid options table
	if options.lights == nil or options.paintjob == nil or options.wheels == nil then return end

	-- Check if fully disabled

	if not options.lights and not options.paintjob and not options.wheels then
		removeElementData( player, 'vip.rainbow' )
	else
		setElementData(player,'vip.rainbow',options)
	end
end

-- Handle vip join
addEventHandler('onPlayerVip', resourceRoot,
	function(player, loggedIn)
		if player and isElement(player) and getElementType(player) == "player" then
			if loggedIn then
				local theSettings = {
					["lights"] = getVipSetting(player,3,"lights"),
					["paintjob"] = getVipSetting(player,3,"paintjob"),
					["wheels"] = getVipSetting(player,3,"wheels")
				}

				setVipRainbowColors(player, theSettings)
			else
				local theSettings = {
					["lights"] = false,
					["paintjob"] = false,
					["wheels"] = false
				}
				setVipRainbowColors(player, theSettings)
			end	
		end
	end
)


-- Handle setting changed
addEvent( 'onClientChangeVipRainbow', true )
addEventHandler( 'onClientChangeVipRainbow', root, 
	function(rainbowType, bool)
		if getElementType( source ) ~= "player" then return end

		if not isPlayerVIP(source) then
			vip_outputChatBox("Setting failed. Not VIP!",source,255,0,0)
			return
		end
		if bool == nil or rainbowType == nil then 
			vip_outputChatBox("Setting failed. Please contact a dev!",source,255,0,0)
			return 
		end


		local saved = saveVipSetting(source, 3, rainbowType, bool)
		if not saved then 
			vip_outputChatBox("Setting change failed. Please contact a dev.",source,255,0,0)
			return
		end

		local theSettings = {
			["lights"] = getVipSetting(source,3,"lights"),
			["paintjob"] = getVipSetting(source,3,"paintjob"),
			["wheels"] = getVipSetting(source,3,"wheels")
		}
		setVipRainbowColors(source,theSettings)

		if bool == true then
			vip_outputChatBox("Rainbow "..rainbowType.." is successfully enabled!",source,0,255,0)
		elseif bool == false then
			vip_outputChatBox("Rainbow "..rainbowType.." is successfully disabled!",source,0,255,0)
		end
		
	end
)

addEventHandler('onResourceStop', resourceRoot,
function()
	for i, p in ipairs(getElementsByType('player')) do
		removeElementData( p, 'vip.rainbow' )
	end
end)