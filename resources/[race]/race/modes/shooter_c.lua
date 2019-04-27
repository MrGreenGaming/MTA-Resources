local shooterJumpHeight = 0.25

function clientReceiveShooterSettings(jumpHeight,autoRepair)
	shooterJumpHeight = jumpHeight or 0.25
	if autoRepair then
		removeEventHandler( 'onClientVehicleDamage', root, shooterAutoRepair )
		addEventHandler('onClientVehicleDamage', root, shooterAutoRepair)
	else
		removeEventHandler( 'onClientVehicleDamage', root, shooterAutoRepair )
	end
end


function createRocket()
	local occupiedVehicle = getPedOccupiedVehicle(localPlayer)
	local x,y,z = getElementPosition(occupiedVehicle)
	local rX,rY,rZ = getElementRotation(occupiedVehicle)
	local x = x+4*math.cos(math.rad(rZ+90))
	local y = y+4*math.sin(math.rad(rZ+90))
	createProjectile(occupiedVehicle, 19, x, y, z, 1.0, nil)
	sh_cd_handler("shoot")

end

function shooterAutoRepair(attacker, weapon, loss)
	if source ~= getPedOccupiedVehicle(localPlayer) then return end
	
	if weapon == 51 then
		-- Do stuff when hit by rocket
	elseif getElementHealth(source) > 249 then
		for i=0, 6 do
			setVehiclePanelState(source,i,0)
			setVehicleDoorState(source,i,0)
		end
		cancelEvent()
	end
end


function shooterJump()
	local veh = getPedOccupiedVehicle(localPlayer)
	local vehID = getElementModel( veh )
	if vehID == 444 or vehID == 556 or vehID == 557 then -- If veh is a monster --
		local posX, posY, posZ = getElementPosition( veh )
		local grndZ = getGroundPosition(posX,posY,posZ)

		if posZ-grndZ < 2 then
			local vx, vy, vz = getElementVelocity ( veh )
       			setElementVelocity ( veh ,vx, vy, vz + shooterJumpHeight )
       			sh_cd_handler("jump")
		end
	elseif (isVehicleOnGround(veh)) then
		local vx, vy, vz = getElementVelocity ( veh )
       		setElementVelocity ( veh ,vx, vy, vz + shooterJumpHeight )
       		sh_cd_handler("jump")
	end
end


-- TIME BARS
local sh_shootCD = 3000
local sh_jumpCD = 2000
local sh_jumpCDTimer = false
local sh_shootCDTimer = false


function sh_redGreen_prc(percent)
	return tocolor(r,g,0)
end

function sh_cd_handler(shootorjump)
	if shootorjump == "shoot" then
		sh_shootCDTimer = setTimer(function() sh_shootCDTimer = false end,sh_shootCD,1)
	elseif shootorjump == "jump" then
		sh_jumpCDTimer = setTimer(function() sh_jumpCDTimer = false end,sh_jumpCD,1)
	end
end


local screenW, screenH = guiGetScreenSize()
local scaleH = screenH/1080
local jumpBar_x = math.ceil(screenW * 0.415)
local jumpBar_y = math.ceil(screenH * 0.860)
local jumpBar_w = math.ceil(screenW * 0.194)
local jumpBar_h = math.ceil(screenH * 0.020)
local jumpBar_color = tocolor(0, 255, 0, 100)

local shootBar_x = math.ceil(screenW * 0.415)
local shootBar_y = math.ceil(screenH * 0.824)
local shootBar_w = math.ceil(screenW * 0.194)
local shootBar_h = math.ceil(screenH * 0.020)
local shootBar_color = tocolor(0, 255, 0, 100)

local percentColor = {}
function sh_draw_timerbars()
	if getElementData(localPlayer,"state") ~= "alive" then return end -- draw only when player is alive
	
	local shootWidth = shootBar_w
	local jumpWidth = jumpBar_w
	local jumpDynamicColor = jumpBar_color
	local shootDynamicColor = shootBar_color

	if isTimer(sh_shootCDTimer) then -- check Shoot timer
		local msLeft = getTimerDetails(sh_shootCDTimer)
		local percentageLeft = msLeft/sh_shootCD*100-100
		shootWidth = shootWidth/100*math.abs(percentageLeft)

		-- color
		local red,green = sh_getColorFromPercent(math.floor(math.abs(percentageLeft)))
		if red and green then
			shootDynamicColor = tocolor(red,green,0,100)
		end
	end
	if isTimer(sh_jumpCDTimer) then -- Check jump timer
		local msLeft = getTimerDetails(sh_jumpCDTimer)
		local percentageLeft = msLeft/sh_jumpCD*100-100
		jumpWidth = jumpWidth/100*math.abs(percentageLeft)
		
		-- color
		local red,green = sh_getColorFromPercent(math.floor(math.abs(percentageLeft)))
		if red and green then
			jumpDynamicColor = tocolor(red,green,0,100)
		end
	end

	-- Spawn protection for cargame
	if getElementData( localPlayer, "overrideAlpha.cargame" ) then
		shootDynamicColor = tocolor(255,0,0,100)
		shootWidth = 0
	end



	local bg = dxDrawRectangle(screenW * 0.385, screenH * 0.813, screenW * 0.230, screenH * 0.078, tocolor(0, 0, 0, 181), false)
	local jumpBar_bg_outline = dxDrawRectangle( jumpBar_x - 1, jumpBar_y - 1, jumpBar_w + 2, jumpBar_h + 2, tocolor(0, 0, 0, 255), false)
	local jumpBar_bg = dxDrawRectangle(jumpBar_x, jumpBar_y, jumpBar_w, jumpBar_h, tocolor(15, 15, 15, 255), false)
	local jumpBar = dxDrawRectangle(jumpBar_x, jumpBar_y, jumpWidth, jumpBar_h, jumpDynamicColor, false)

	local shootBar_bg_outline = dxDrawRectangle(shootBar_x - 1, shootBar_y - 1, shootBar_w + 2, shootBar_h + 2, tocolor(0, 0, 0, 255), false)
	local shootBar_bg = dxDrawRectangle(shootBar_x, shootBar_y, shootBar_w, shootBar_h, tocolor(15, 15, 15, 255), false)
	local shootBar = dxDrawRectangle(shootBar_x, shootBar_y, shootWidth, shootBar_h, shootDynamicColor, false)
	
	local rocketIMG = dxDrawImage(math.ceil(screenW * 0.393), math.ceil(screenH * 0.824), math.ceil(screenW * 0.013), math.ceil(screenW * 0.013), "img/rocket66.png", 0, 0, 0, shootDynamicColor, false)
	local jumpIMG = dxDrawImage(math.ceil(screenW * 0.393), math.ceil(screenH * 0.859), math.ceil(screenW * 0.013), math.ceil(screenW * 0.013), "img/arrow-up.png", 0, 0, 0, jumpDynamicColor, false)


end

function sh_initTimeBars()
	playerLevel = 1
	addEventHandler("onClientRender",root,sh_draw_timerbars)
end

function sh_stopTimeBars()
	removeEventHandler("onClientRender",root,sh_draw_timerbars)
end

function sh_getColorFromPercent(percentage)
	local percentage = tonumber(percentage)
    if not percentage or percentage and type(percentage) ~= "number" or percentage > 100 or percentage < 0 then outputDebugString( "Invalid argument @ 'getRGColorFromPercentage'", 2 ) return false end
    if percentage > 50 then
	local temp = 100 - percentage
        return temp*5.1, 255
    elseif percentage == 50 then
	return 255, 255
    else
	return 255, percentage*5.1
    end
end
-- CARGAME FUNCTIONS
local font , txtcolor, lvlcolor
local playerLevel = 1
local carGameKillDetection = false
local cg_playerDamage = {}
local carGameLevelBrowser = false



local screenW, screenH = guiGetScreenSize()
local scaleW = screenW/1920
local scaleH = screenH/1080

local isLocalPlayerDead
carGameLevelBrowser = createBrowser(screenW, screenH, true, true)
function cgStart()
	isLocalPlayerDead = false
	playerLevel = 1


	txtcolor = tocolor(255,255,255,200)
	lvlcolor = tocolor(255,255,255,200)

	-- carGameLevelBrowser = createBrowser(screenW, screenH, true, true)
	addEventHandler("onClientRender",root,drawCargameLevel)
	cg_playerDamage = {}
	carGameKillDetection = true
	addEventHandler("onClientExplosion",root,cg_handleExplosions)
end


addEventHandler("onClientBrowserCreated", root, 
	function()

		if source ~= carGameLevelBrowser then return end
		loadBrowserURL(carGameLevelBrowser, "http://mta/local/modes/cargamefiles/cargame.html")
		
		
		-- addEventHandler("onClientRender",root,drawCargameLevel)
	end
)


function cgEnd()
	removeEventHandler("onClientRender",root,drawCargameLevel)
	removeEventHandler("onClientRender",root,sh_draw_timerbars)
	-- if isElement(carGameLevelBrowser) then destroyElement(carGameLevelBrowser) carGameLevelBrowser = false end
	playerLevel = 1
	cg_playerDamage = {}
	carGameKillDetection = false
	removeEventHandler("onClientExplosion",root,cg_handleExplosions)
	
end

function setCGLevel(lvl)
	playerLevel = lvl
end




function getCGLevel()
	return playerLevel
end

function onClientCGLevelChange(old,new)
	cgBrowserChangeLevel(tonumber(new))
	local isPromotion = false
	if old == new then -- nothing changed
		-- do nothing
	elseif old > new then -- If demoted
		-- do demote stuff
	elseif old < new then -- if promoted
		--do promote stuff
		isPromotion = true
	end
	playerLevel = new
	
	
end

local showLvl = false
function showLevelDX(bool)
	showLvl = bool
end


function cgBrowserChangeLevel(level)
	if not carGameLevelBrowser or type(level) ~= "number" then return end


	if level ~= 10 then
		executeBrowserJavascript(carGameLevelBrowser,
			'changeText("level",'..tostring(level)..');'
		)
	elseif level == 10 then
		executeBrowserJavascript(carGameLevelBrowser,
			'changeText("levelText",""); changeText("level","You Won!");'
		)
	end

end


function drawCargameLevel()
	if not showLvl then return end
	if not isPlayerSpectating(localPlayer) then

		if carGameLevelBrowser then
			dxDrawImage(0, screenH * 0.042,screenW,screenH,carGameLevelBrowser,0,0,0,tocolor(255,255,255,180),false)
		end
	end
end




function cgRocket()
	local occupiedVehicle = getPedOccupiedVehicle(localPlayer)
	local x,y,z = getElementPosition(occupiedVehicle)
	local rX,rY,rZ = getElementRotation(occupiedVehicle)
	local x = x+4*math.cos(math.rad(rZ+90))
	local y = y+4*math.sin(math.rad(rZ+90))
	createProjectile(occupiedVehicle, 19, x, y, z, 1.0, nil)
	sh_cd_handler("shoot")

end

function cgJump()
	local veh = getPedOccupiedVehicle(localPlayer)
	local vehID = getElementModel( veh )
		if vehID == 444 or 556 or 557 then -- If veh is a monster --
			local posX, posY, posZ = getElementPosition( veh )
			local grndZ = getGroundPosition(posX,posY,posZ)
			

			if posZ-grndZ < 2 then
				local vx, vy, vz = getElementVelocity ( veh )
       			setElementVelocity ( veh ,vx, vy, vz + shooterJumpHeight )
       			sh_cd_handler("jump")
			end

		elseif (isVehicleOnGround(veh)) then
			local vx, vy, vz = getElementVelocity ( veh )
       		setElementVelocity ( veh ,vx, vy, vz + shooterJumpHeight )
       		sh_cd_handler("jump")
		end
end


-- CG Kill detection







function cg_Damage( attacker, weapon, loss, x, y, z, tyre )
		if source ~= getPedOccupiedVehicle(localPlayer) then return end
		if not loss or loss < 100 then return end -- Minimum damage
		if not carGameKillDetection or isLocalPlayerDead then return end
		if weapon ~= 51 then cancelEvent() return end
		-- check fire for vehicle blow
		if source == getPedOccupiedVehicle(localPlayer) then cg_handleVehicleBurn(loss) end

		if not isElement(attacker) or getElementType(attacker) ~= "player" then return end
		-- if attacker == localPlayer or source ~= getPedOccupiedVehicle(localPlayer) then return end

		
		

		local lasthit = attacker
		local lasttick = getTickCount()
		

		if attacker ~= localPlayer then
			if getPlayerName(localPlayer) == "KaliBwoy" then
				outputDebugString("CG killdetection: FALSE local player damage")
			end
			cg_playerDamage = {lasthit,lasttick}
		elseif attacker == localPlayer then
			if getPlayerName(localPlayer) == "KaliBwo0y" then
				outputDebugString("CG killdetection: TRUE local player damage")
			end
			cg_localPlayerDamage = {lasthit,lasttick}
		end
		
		-- Player is not invincible to rockets anymore, while on fire
end
addEventHandler("onClientVehicleDamage", root, cg_Damage)

function cg_handleRespawn ( )
	if isLocalPlayerDead and carGameKillDetection then
		cg_resetDetection()
		isLocalPlayerDead = false
	end
end
-- add this function as a handler for any player that spawns
addEventHandler ( "onClientPlayerSpawn", getLocalPlayer(), cg_handleRespawn )

local max_lastHitTime = 3000 -- Max time where a hit counts as a kill
local max_localLastHitTime = 200
function cg_wasted()
	if not carGameKillDetection or source ~= localPlayer then return end
	isLocalPlayerDead = true
	-- set up killer data

	

	local killer = cg_playerDamage[1] or false
	local killerTick = cg_playerDamage[2] or false
	local killerLastHitTime = false
	if isElement(killer) and getElementType(killer) == "player" then
		if tonumber(killerTick) then killerLastHitTime = getTickCount() - killerTick end -- Count time since hit
		if tonumber(killerLastHitTime) and killerLastHitTime > max_lastHitTime then killerLastHitTime = false end -- count if hit should count as kill
	end

	-- set up localPlayer damage data
	local localPlayerTick = false
	if cg_localPlayerDamage then
		localPlayerTick = cg_localPlayerDamage[2] or false
	end
	local localPlayerLastHitTime = false
	if localPlayerTick then
		if tonumber(localPlayerTick) then localPlayerLastHitTime = getTickCount() - localPlayerTick end
		if tonumber(localPlayerLastHitTime) and localPlayerLastHitTime > max_localLastHitTime then localPlayerLastHitTime = false end -- count if hit should count as kill
	end

	-- Detect if death is suicide
	local suicide = false
	if killerLastHitTime and localPlayerLastHitTime and localPlayerLastHitTime > killerLastHitTime then
		suicide = true
	elseif localPlayerLastHitTime and not killerLastHitTime then	-- If the player is the one that hit itself last
		killer = localPlayer
		suicide = true
	end
	if killerLastHitTime or localPlayerLastHitTime then
		triggerServerEvent('cargamekill', localPlayer, localPlayer,killer, suicide)
	end
	cg_resetDetection()
end
addEventHandler("onClientPlayerWasted", root, cg_wasted)


function cg_handleVehicleBurn()

	local vehicle = getPedOccupiedVehicle(localPlayer)
	if isVehicleBlown(vehicle) then return end
	setTimer(function()
		if isElement(vehicle) and not isVehicleBlown(vehicle) then
			if getElementHealth(vehicle) < 250 then
				setElementHealth(localPlayer,0)
				setTimer(blowVehicle,100,1,vehicle)
			end
		end
	end,400,1)
end


function cg_handleExplosions(x,y,z,theType) -- If other player's vehicles explode, it will not count as kill because explosion is recreated, so KMZ's won't get kills that way
	if isElement(source) and getElementType(source) == "player" and source ~= localPlayer and theType == 4 then
		cancelEvent()
		createExplosion(x,y,z,4,true,-1.0,false)
	end
end

function cg_resetDetection()
	if not carGameKillDetection then return end
	
	cg_playerDamage = {}
	cg_localPlayerDamage = {}
end
addEventHandler("onClientMapStopping", root, cg_resetDetection)
