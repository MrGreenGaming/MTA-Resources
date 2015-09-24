-- Shooter kill detection (attach a ped to local vehicle and remember who damages it)
-- crun addEventHandler('onClientVehicleDamage', root, function(...) aaaa(unpack(arg)) aaaaa(unpack(arg)) end)
-- crun function aaaa(at, we, loss, x, y, z, tyre) if we == 51 then outputDebugString('at:'  .. (at and getElementType(at) == 'player' and getPlayerName(at) or tostring(at)) ..' ' .. tostring(we) .. '     src:' .. getPlayerName(getVehicleOccupant(source))) end end
-- crun function aaaaa(at, we, loss, x, y, z, tyre) if we == 51 then outputDebugString(tostring(we) .. '     src:' .. getPlayerName(getVehicleOccupant(source)) .. ' ' .. tostring(loss)) end end

local checkingShooterKill = false
-- local ped
local lasthit, lasttick

function startShooterKillDetection(mode)

	-- outputDebugString('starting detection')
	-- if ped and isElement(ped) then destroyElement(ped) end
	lasthit = nil
	lasttick = nil
	
	-- local veh = getPedOccupiedVehicle(localPlayer)
	-- local x, y, z = getElementPosition(veh)
	-- ped = createPed(7, x, y, z)
	-- setElementAlpha(ped, 0)
	-- attachElements(ped, veh)
	checkingShooterKill = true
end
addEvent('startShooterKillDetection', true)
addEventHandler('startShooterKillDetection', resourceRoot, startShooterKillDetection)



function onClientVehicleDamage( attacker, weapon, loss, x, y, z, tyre )
		-- outputDebugString('onClientVehicleDamage')
		if not checkingShooterKill or weapon ~= 51 or attacker == localPlayer or source ~= getPedOccupiedVehicle(localPlayer) then return end
        -- outputDebugString( "onClientVehicleDamage " .. var_dump("ped", source, 'attacker', attacker, 'weapon', weapon, 'loss', loss) )
		lasthit = attacker
		lasttick = getTickCount()
end
addEventHandler("onClientVehicleDamage", root, onClientVehicleDamage)

function resetDetection()
	if not checkingShooterKill then return end
	
	-- checkingShooterKill = false
	-- if ped and isElement(ped) then destroyElement(ped) end
	-- ped = nil
	lasthit = nil
	lasttick = nil
end
addEventHandler("onClientMapStopping", root, resetDetection)

function onClientPlayerWasted()
	if not checkingShooterKill or source ~= localPlayer then return end
	
	if lasthit and isElement(lasthit) and lasttick and getTickCount() - lasttick <= 5000 then
		triggerServerEvent('shooterKill', localPlayer, lasthit)
	end
	resetDetection()
end
addEventHandler("onClientPlayerWasted", root, onClientPlayerWasted)


-- DD kill detection (remember who last touched local vehicle)

local running
local buffer = nil

function killedDDMapRunning(isRunning)
	if isRunning then
		running = true
	else
		killedreset()
	end
end
addEvent('killedDDMapRunning', true)
addEventHandler('killedDDMapRunning', resourceRoot, killedDDMapRunning)

function killednewMapStarted()
	killedreset()
end
addEventHandler('onClientMapStarting', root, killednewMapStarted)

function killedreset()
	running = nil
	buffer = nil
end

addEventHandler("onClientVehicleCollision", root,
    function ( hit, force ) 
        if ( source == getPedOccupiedVehicle(localPlayer) ) and running then
			local fDamageMultiplier = getVehicleHandling(source).collisionDamageMultiplier
			local damage = force * fDamageMultiplier
			local h = getElementHealth(source)
			local h2 = h - damage
            if ( hit == nil ) then 
				-- outputDebugString(' hit ' ..  h .. "-" .. damage .. "=" .. h2)
			elseif (getElementType(hit) == "vehicle") then
				-- outputDebugString(' hit ' .. (isElement(hit) and getVehicleOccupant(hit) and (getPlayerName(getVehicleOccupant(hit)) .. ' ' .. h .. "-" .. damage .. "=" .. h2) or '/'))
				if hit ~= buffer then
					triggerServerEvent('killedlasthit', resourceRoot, hit)
					buffer = hit
				end
			end 
        end
    end
)


-- CTF Kill Detection

local CTFRunning = false
local CTFbuffer = nil

function killedCTFMapRunning(isRunning)
	if isRunning then
		CTFRunning = true
	else
		CTFkilledreset()
	end
end
addEvent('killedCTFMapRunning', true)
addEventHandler('killedCTFMapRunning', resourceRoot, killedCTFMapRunning)

function CTFkillednewMapStarted()
	CTFkilledreset()
end
addEventHandler('onClientMapStarting', root, CTFkillednewMapStarted)

function CTFkilledreset()
	CTFRunning = false
	CTFbuffer = nil
	if isTimer(CTFBufferTimer) then killTimer(CTFBufferTimer) CTFBufferTimer = nil end
end

function removeCTFBuffer()
	CTFbuffer = false
end

addEventHandler("onClientVehicleCollision", root,
    function ( hit, force ) 
        if source == getPedOccupiedVehicle(localPlayer) and CTFRunning then

			local fDamageMultiplier = getVehicleHandling(source).collisionDamageMultiplier
			local damage = force * fDamageMultiplier
			local h = getElementHealth(source)
			local h2 = h - damage
            if ( hit == nil ) then 
				-- outputDebugString(' hit ' ..  h .. "-" .. damage .. "=" .. h2)
			elseif (getElementType(hit) == "vehicle") then
				-- outputDebugString(' hit ' .. (isElement(hit) and getVehicleOccupant(hit) and (getPlayerName(getVehicleOccupant(hit)) .. ' ' .. h .. "-" .. damage .. "=" .. h2) or '/'))
				if hit ~= CTFbuffer then
					local hitTeam = getPlayerTeam(getVehicleOccupant(hit))
					local sourceTeam = getPlayerTeam(getVehicleOccupant(source))

					if hitTeam ~= sourceTeam then -- Don't trigger when it's a teamkill
						triggerServerEvent('killedlasthit', resourceRoot, hit)

						if isTimer(CTFBufferTimer) then killTimer(CTFBufferTimer) removeCTFBuffer() end

						CTFbuffer = hit
						CTFBufferTimer = setTimer(removeCTFBuffer,5000,1)
					end


				end
			end 
        end
    end
)



-- CTF teamkill warning
--[[
addEventHandler('onClientVehicleCollision', root,
function(hitElement, force, bodyPart, x,y,z,nx,ny,nz,otherForce)
    local localVehicle = getPedOccupiedVehicle(localPlayer)
	if exports.race:getRaceMode() ~= 'Capture the flag' then
		return
	end
    if localVehicle and isElement(localVehicle) and source == localVehicle and hitElement and getElementType(hitElement) == 'vehicle' and getVehicleOccupant(hitElement) then
        if not getElementData(localPlayer, 'ctf2.flagTaker') and getPlayerTeam(localPlayer) and getPlayerTeam(localPlayer) == getPlayerTeam(getVehicleOccupant(hitElement)) then
            if not g_IgnoreVehicles[hitElement] then
                if force*getVehicleHandling(hitElement).collisionDamageMultiplier > 25 then
                    local mySpeed = getElementSpeed(localVehicle)
                    local otherSpeed = getElementSpeed(hitElement)
                    if mySpeed > otherSpeed then
                        outputChatBox("[TK] Do not teamkill! You risk getting kicked or banned!", 255,0,0)
                        g_IgnoreVehicles[hitElement] = setTimer(function(car) g_IgnoreVehicles[car] = nil end, 1500, 1, hitElement)
                    end
                end
            end
        end
    end
end)

function getElementSpeed(element)
    local x,y,z = getElementVelocity(element)
    return (x^2 + y^2 + z^2) ^ 0.5 * 1.8 * 100
end
g_IgnoreVehicles = {}
--]]


-- manhunt teamkill warning
addEventHandler("onClientPlayerWeaponFire",getRootElement(),
function(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
	if exports.race:getRaceMode() ~= 'Manhunt' then
		return
	end
    --outputChatBox("event fired")
    if source == localPlayer then
        --outputChatBox("source player firing")
        if hitElement and getElementType(hitElement) == 'vehicle' and getElementHealth(hitElement) > 253 and getVehicleOccupant(hitElement) and getPedOccupiedVehicle(localPlayer) and localPlayer ~= getVehicleOccupant(hitElement) then
            if getElementHealth ( getPedOccupiedVehicle(localPlayer) ) > 250 and getPlayerTeam(localPlayer) and getPlayerTeam(localPlayer) == getPlayerTeam(getVehicleOccupant(hitElement)) then  --detected teamkill
                setElementHealth ( getPedOccupiedVehicle(localPlayer), getElementHealth ( getPedOccupiedVehicle(localPlayer) ) - 150 )
                local x, y, z = getElementVelocity(getPedOccupiedVehicle(localPlayer))
                setElementVelocity ( getPedOccupiedVehicle(localPlayer), x , y, z + 0.2 )
                outputChatBox("[Anti-Teamkill] Do not shoot your teammates!", 0, 255, 0)
            end
        end
    end
end
)

