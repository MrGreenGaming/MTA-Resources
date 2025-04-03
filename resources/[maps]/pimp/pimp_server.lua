
pimpElementNames =
	{ "2dText", "3dText", "Teleport", "Boost", "SetVehicleGravity", "Blip", "CameraPosition", "CameraTargetPlayer", "SetRotation",
	"EnableCheat", "BlowVehicle", "FixVehicle", "SetDamageProof", "SetGameSpeed", "SetWorldGravity", "SetVehicleHandling", "ResetVehicleHandling" }
	
handlingProperties = {
	mass = "mass",
	turnMass = "turnMass",
	dragCoeff = "dragCoeff",
	centOfMass = "centerOfMass",
	percSubmerged = "percentSubmerged",
	tracMultiplier = "tractionMultiplier",
	tracLoss = "tractionLoss",
	tracBias = "tractionBias",
	gears = "numberOfGears",
	maxVelocity = "maxVelocity",
	acceleration = "engineAcceleration",
	engInertia = "engineInertia",
	driveType = "driveType",
	engineType = "engineType",
	brakeDeceleration = "brakeDeceleration",
	brakeBias = "brakeBias",
	steeringLock = "steeringLock",
	susForLevel = "suspensionForceLevel",
	susDamping = "suspensionDamping",
	susHiSpeDamping = "suspensionHighSpeedDamping",
	susUpLimit = "suspensionUpperLimit",
	susLoLimit = "suspensionLowerLimit",
	susFrReBias = "suspensionFrontRearBias",
	susAnDiMultiplier = "suspensionAntiDiveMultiplier",
	colDamMultiplier = "collisionDamageMultiplier"
				}
				
blips = {}
	
function checkMapForPimpElements ( resource )
	for i, string in pairs ( pimpElementNames ) do
		local elementType = "pimp" .. string
		if #getElementsByType ( elementType ) > 0 then
			for j, element in pairs ( getElementsByType ( elementType ) ) do
				local hideMarker = getElementData ( element, "hideMarkers" )
				local parent = getElementParent ( element )
				if parent and hideMarker and hideMarker == "true" then
					setElementAlpha ( parent, 0 )
				end
			end
		end			
	end
	
	local outputMessage = false

	for i, string in pairs ( pimpElementNames ) do
		if #getElementsByType ( "pimp" .. string ) > 0 then
			outputMessage = true
		end
	end
	
	local pimp3dTextElements = getElementsByType ( "pimp3dText" )
	pimp3dTextElementTable = {}
	for i, element in pairs ( pimp3dTextElements ) do
		local parent = getElementParent ( element )
		if parent and isElement ( parent ) then
			local x, y, z = getElementPosition ( parent )
			table.insert ( pimp3dTextElementTable, { getAllElementData ( element ), {x,y,z} } )
		end
	end
	triggerClientEvent ( "onClientReceive3dTextElements", getRootElement(), pimp3dTextElementTable )
	
	pimpTeleports = {}
	for i, teleport in pairs ( getElementsByType ( "pimpTeleport" ) ) do
		local data = getAllElementData ( teleport )
		local teleportTo = data.teleportTo
		local teleportToElement
		if teleportTo and type(teleportTo) == "string" and getElementByID ( teleportTo ) then	
			teleportToElement = getElementByID ( teleportTo )
		end
		if teleportToElement and isElement ( teleportToElement ) then
			local x, y, z = getElementPosition ( teleportToElement )
			local rx, ry, rz = getElementRotation ( teleportToElement )
			local model = getElementModel ( teleportToElement )
			setElementData ( teleport, "teleportToPos", { x, y, z, rx, ry, rz, model } )
			destroyElement ( teleportToElement )
		end
	end
	
	blips = {}

	for i, child in pairs ( getElementsByType ( "pimpBlip" ) ) do
		local parent = getElementParent ( child )
		if parent then			
			local data = getAllElementData ( child )
			local type, iconID, size, color, distance = data.type, data.iconID, data.size, data.color, data.distance
			local iconID, size, distance = tonumber(iconID), tonumber(size), tonumber(distance)
			if iconID < 0 or iconID > 63 then iconID = 0 end
			if size < 0.1 then size = 0.1 end
			if distance <= 0 then distance = 65535 end
			local r, g, b, a = hexToRGB ( color )
			if type == "attach to marker" then
				local newBlip = createBlipAttachedTo ( parent, iconID, size, r, g, b, a, 0, distance )
				table.insert ( blips, newBlip )
			end
		end
	end
	
	if outputMessage then
		-- PLEASE DO NOT REMOVE THOSE LINES, GIVE ME SOME CREDIT FOR MY WORK :)
		outputChatBox ( "#ffe615>> #97ffb2Marker actions #00fa41are done by #ffe615PIMP", getRootElement(), 255, 255, 255, true )
		outputChatBox ( "#ffe615>> #97ffb2P#00fa41uma's #97ffb2I#00fa41ncredible #97ffb2M#00fa41arker #97ffb2P#00fa41lug-in", getRootElement(), 255, 255, 255, true )
	end
end
function request3dTextElements ()
	if pimp3dTextElementTable and #pimp3dTextElementTable > 0 then
		triggerClientEvent ( source, "onClientReceive3dTextElements", getRootElement(), pimp3dTextElementTable )
	end
end
addEvent ( "onRequest3dTextElements", true )
addEventHandler ( "onRequest3dTextElements", getRootElement(), request3dTextElements )
addEvent ( "onGamemodeMapStart", true )
addEventHandler ( "onGamemodeMapStart", getRootElement(), function()setTimer(checkMapForPimpElements,1000,1)end )

function gamemodeMapStop()
	for i, blip in pairs ( blips ) do
		destroyElement ( blip )
	end
	blips = {}
	pimp3dTextElementTable = false
	triggerClientEvent ( "onClientReceive3dTextElements", getRootElement() )
	triggerClientEvent ( "onClientCameraTargetPlayer", getRootElement() )
end
addEvent ( "onGamemodeMapStop", true )
addEventHandler ( "onGamemodeMapStop", getRootElement(), gamemodeMapStop )

function resourceStart ()
	if ( exports.mapmanager:getRunningGamemodeMap() )then
		checkMapForPimpElements()
	end
end
addEventHandler ( "onResourceStart", getResourceRootElement(), resourceStart )

function markerHit ( element )
	local p
	if getElementType ( element ) == "player" and not getPedOccupiedVehicle ( element ) then
		p = element
	elseif getElementType ( element ) == "vehicle" and getVehicleOccupant ( element ) then
		p = getVehicleOccupant ( element )
	end
	
	if p and isElement(p) then	
		local v = getPedOccupiedVehicle ( p )
		for i, child in pairs ( getElementChildren ( source ) ) do
			local elementType = getElementType ( child )
			if string.find ( elementType, "pimp" ) then
				if elementType == "pimp2dText" then
					triggerClientEvent ( p, "onClientNewPimp2dText", source, child, getAllElementData(child) )
				elseif elementType == "pimpTeleport" then
					local data = getAllElementData ( child )
					local teleportToPos = data.teleportToPos
					if teleportToPos and type(teleportToPos) == "table" then
						local x, y, z, rx, ry, rz, model = unpack(teleportToPos)
						
						if data.changeModel == "don't change model" then model = false end
						
						local rotX, rotY, rotZ
						if v then rotX, rotY, rotZ = getElementRotation ( v ) else rotX, rotY, rotZ = 0, 0, getPedRotation(p) end
						
						local vx, vy, vz
						if v then 
							vx, vy, vz = getElementVelocity ( v )						
							local sx, sy, sz = vx, vy, vz
							local t, p, f = math.rad(rotX), math.rad(rotY), math.rad(rotZ)
							local ct, st, cp, sp, cf, sf = math.cos(t), math.sin(t), math.cos(p), math.sin(p), math.cos(f), math.sin(f)
							vz = ct*cp*sz + (sf*st*cp + cf*sp)*sx + (-cf*st*cp + sf*sp)*sy
							vx = -ct*sp*sz + (-sf*st*sp + cf*cp)*sx + (cf*st*sp + sf*cp)*sy
							vy = st*sz - sf*ct*sx + cf*ct*sy
						end
						
						local changedVx, changedVy, changedVz
						local tvx, tvy, tvz 
						if v then
							tvx, tvy, tvz = getElementAngularVelocity ( v )
						end
						if data.velocity and data.velocity == "change (fill in below)" then
							if data.velocityX and tonumber(data.velocityX) then changedVx = tonumber(data.velocityX) end
							if data.velocityY and tonumber(data.velocityY) then changedVy = tonumber(data.velocityY) end
							if data.velocityZ and tonumber(data.velocityZ) then changedVz = tonumber(data.velocityZ) end
						end
						if data.turnVelocity and data.turnVelocity == "change (fill in below)" then
							if data.turnVelX and tonumber(data.turnVelX) then tvx = tonumber(data.turnVelX) end
							if data.turnVelY and tonumber(data.turnVelY) then tvy = tonumber(data.turnVelY) end
							if data.turnVelZ and tonumber(data.turnVelZ) then tvz = tonumber(data.turnVelZ) end
						end
						local fadeTime = data.fadeTime
						if data.fadeScreen == "true" and fadeTime and tonumber(fadeTime) and tonumber(fadeTime) >= 50 then
							triggerClientEvent ( p, "onClientPimpFadeScreen", getRootElement(), fadeTime )
							setTimer ( teleport, fadeTime, 1, p, v, x, y, z, rx, ry, rz, vx, vy, vz, tvx, tvy, tvz, data.freezeTime, changedVx, changedVy, changedVz, data.velocity, model )
						else
							teleport ( p, v, x, y, z, rx, ry, rz, vx, vy, vz, tvx, tvy, tvz, data.freezeTime, changedVx, changedVy, changedVz, data.velocity, model )
						end
					end						
				elseif elementType == "pimpBoost" then
					if v then
						local data = getAllElementData ( child )
						local vx, vy, vz = data.velocityX, data.velocityY, data.velocityZ
						if vx then vx = tonumber(vx) end if vy then vy = tonumber ( vy ) end if vz then vz = tonumber ( vz ) end
						if data.type == "along world's axes" then
							setElementVelocity ( v, vx or 0, vy or 0, vz or 0 )
						else
							triggerClientEvent ( p, "onClientSetElementVelocity", getRootElement(), p, v, vx, vy, vz )
						end
						local tvx, tvy, tvz = getElementAngularVelocity ( v )
						if data.turnVelocity and data.turnVelocity == "change (fill in below)" then
							if data.turnVelX and tonumber(data.turnVelX) then tvx = tonumber(data.turnVelX) end
							if data.turnVelY and tonumber(data.turnVelY) then tvy = tonumber(data.turnVelY) end
							if data.turnVelZ and tonumber(data.turnVelZ) then tvz = tonumber(data.turnVelZ) end
						end
						setElementAngularVelocity ( v, tvx, tvy, tvz )
					end
				elseif elementType == "pimpSetVehicleGravity" then
					if v then
						local data = getAllElementData ( child )
						local gx, gy, gz = data.gravityX, data.gravityY, data.gravityZ
						local gx, gy, gz = tonumber(gx), tonumber(gy), tonumber(gz)
						local doFor = data.doFor
						if doFor == "player" then
							triggerClientEvent ( p, "onClientSetVehicleGravity", getRootElement(), gx, gy, gz )
						elseif doFor == "all other players" then
							for i, player in pairs ( getElementsByType ( "player" ) ) do
								if player ~= p then
									triggerClientEvent ( player, "onClientSetVehicleGravity", getRootElement(), gx, gy, gz )
								end
							end
						else
							triggerClientEvent ( "onClientSetVehicleGravity", getRootElement(), gx, gy, gz )
						end
					end
				elseif elementType == "pimpBlip" then
					local data = getAllElementData ( child )
					local type, iconID, size, color, distance = data.type, data.iconID, data.size, data.color, data.distance
					local iconID, size, distance = tonumber(iconID), tonumber(size), tonumber(distance)
					if iconID < 0 or iconID > 63 then iconID = 0 end
					if size < 0.1 then size = 0.1 end
					if distance <= 0 then distance = 65535 end
					local r, g, b, a = hexToRGB ( color )
					if type == "attach to player" then
						local newBlip = createBlipAttachedTo ( p, iconID, size, r, g, b, a, 0, distance )
						table.insert ( blips, newBlip )
					end
				elseif elementType == "pimpCameraPosition" then
					local data = getAllElementData ( child )
					local posElementID, lookAt, lookAtMarkerID, rollAngle, fov, time, doFor = data.posElement, data.lookAt, data.lookAtMarker, data.rollAngle, data.fov, data.time, data.doFor
					local fadeScreen, fadeTime = data.fadeScreen, data.fadeTime
					if fadeTime and tonumber(fadeTime) and tonumber(fadeTime) >= 50 then
						fadeTime = tonumber(fadeTime)
					elseif fadeTime and tonumber(fadeTime) and tonumber(fadeTime) < 50 then 
						fadeTime = false
					end
					local rollAngle, fov, time = tonumber(rollAngle or 0), tonumber(fov or 70), tonumber(time or 3000)
					if doFor == "player" then
						if fadeScreen and fadeScreen == "true" and fadeTime and type(fadeTime) == "number" then
							triggerClientEvent ( p, "onClientPimpFadeScreen", getRootElement(), fadeTime )
							setTimer ( triggerClientEvent, fadeTime, 1, p, "onClientCameraPosition", getRootElement(), posElementID, lookAt, lookAtMarkerID, rollAngle, fov, time, fadeTime )
						else
							triggerClientEvent ( p, "onClientCameraPosition", getRootElement(), posElementID, lookAt, lookAtMarkerID, rollAngle, fov, time )
						end
					else
						if fadeScreen and fadeScreen == "true" and fadeTime and type(fadeTime) == "number" then
							triggerClientEvent ( "onClientPimpFadeScreen", getRootElement(), fadeTime )
							setTimer ( triggerClientEvent, fadeTime, 1, "onClientCameraPosition", getRootElement(), posElementID, lookAt, lookAtMarkerID, rollAngle, fov, time, fadeTime )
						else
							triggerClientEvent ( "onClientCameraPosition", getRootElement(), posElementID, lookAt, lookAtMarkerID, rollAngle, fov, time )
						end
					end
				elseif elementType == "pimpCameraTargetPlayer" then
					local data = getAllElementData ( child )
					local wait, doFor = data.wait, data.doFor
					if wait and tonumber ( wait ) and tonumber ( wait ) >= 50 then
						setTimer ( function ( doFor )
							if doFor == "player" then
								triggerClientEvent ( p, "onClientCameraTargetPlayer", getRootElement() )
							else
								triggerClientEvent ( "onClientCameraTargetPlayer", getRootElement() )
							end
						end, tonumber ( wait ), 1, doFor )
					else
						if doFor == "player" then
							triggerClientEvent ( p, "onClientCameraTargetPlayer", getRootElement() )
						else
							triggerClientEvent ( "onClientCameraTargetPlayer", getRootElement() )
						end
					end
				elseif elementType == "pimpSetRotation" then
					if v then
						local data = getAllElementData ( child )
						local rx, ry, rz = data.Xrot, data.Yrot, data.Zrot
						if rx and tonumber(rx) then rx = tonumber ( rx ) end if ry and tonumber(ry) then ry = tonumber ( ry ) end if rz and tonumber(rz) then rz = tonumber ( rz ) end
						
						local orx, ory, orz = getElementRotation ( v )
						
						if data.type == "add to current rotation" then
							setElementRotation ( v, orx + ( rx or 0 ), ory + ( ry or 0 ), orz + ( rz or 0 ) )
						else
							setElementRotation ( v, rx or orx, ry or ory, rz or orz )
						end
					end					
				elseif elementType == "pimpEnableCheat" then
					local data = getAllElementData ( child )
					local type, enabled, time, doFor = data.type, data.enabled, data.time, data.doFor
					if doFor == "player" then
						triggerClientEvent ( p, "onClientEnableCheat", getRootElement(), type, enabled, time )
					else
						triggerClientEvent ( "onClientEnableCheat", getRootElement(), type, enabled, time )
					end
				elseif elementType == "pimpBlowVehicle" then
					local data = getAllElementData ( child )
					local explode, doFor = data.explode, data.doFor
					if explode == "true" then
						explode = true
					else
						explode = false
					end
					if doFor == "player" and v then
						blowVehicle ( v, explode )
					else
						for i, player in pairs ( getElementsByType ( "player" ) ) do
							if ( ( doFor == "all other players" and player ~= p ) or doFor == "everyone" ) and getPedOccupiedVehicle(player) then
								blowVehicle ( getPedOccupiedVehicle ( player ), explode )
							end
						end
					end				
				elseif elementType == "pimpFixVehicle" then
					local data = getAllElementData ( child )
					local health, doFor = data.health, data.doFor
					if healt and tonumber ( health ) then health = tonumber ( health ) else health = 100 end
					if health < 0 then health = 0 elseif health > 100 then health = 100 end
					local health = health * 7.5+250
					if doFor == "player" and v then
						setElementHealth ( v, health )
					else
						for i, player in pairs ( getElementsByType ( "player" ) ) do
							if getPedOccupiedVehicle ( player ) then
								setElementHealth ( getPedOccupiedVehicle ( player ), health )
							end
						end
					end
				elseif elementType == "pimpSetDamageProof" then
					local data = getAllElementData ( child )
					local enabled = data.enabled
					if v and enabled == "true" then
						setVehicleDamageProof ( v, true )
					elseif v then
						setVehicleDamageProof ( v, false )
					end
				elseif elementType == "pimpSetVehicleModel" then
					local data = getAllElementData ( child )
					local model = data.modelID
					local offsetZ = data.offsetZ
					local doFor = data.doFor
					if doFor == "player" and v then
						setElementModel ( v, tonumber(model) )
						if offsetZ and tonumber(offsetZ) then
							local vx, vy, vz = getElementVelocity ( v )
							local tvx, tvy, tvz = getElementAngularVelocity ( v )
							local x, y, z = getElementPosition ( v )
							setElementPosition ( v, x, y, z + tonumber(offsetZ) )
							setElementVelocity ( v, vx, vy, vz )
							setElementAngularVelocity ( v, tvx, tvy, tvz )
						end
					else
						for i, player in pairs ( getElementsByType ( "player" ) ) do
							if ( ( doFor == "all other players" and player ~= p ) or doFor == "everyone" ) and getPedOccupiedVehicle(player) then
								local pv = getPedOccupiedVehicle ( player )
								setElementModel ( pv, tonumber(model) )
								if offsetZ and tonumber(offsetZ) then
									local vx, vy, vz = getElementVelocity ( pv )
									local tvx, tvy, tvz = getElementAngularVelocity ( pv )
									local x, y, z = getElementPosition ( pv )
									setElementPosition ( pv, x, y, z + tonumber(offsetZ) )
									setElementVelocity ( pv, vx, vy, vz )
									setElementAngularVelocity ( pv, tvx, tvy, tvz )
								end
							end
						end
					end	
					
				elseif elementType == "pimpSetGameSpeed" then
					local data = getAllElementData ( child )
					local speed, doFor = data.speed, data.doFor
					local speed = tonumber ( speed )
					if speed < 0 then speed = 0 end
					if doFor == "everyone" then
						setGameSpeed ( speed )
					else
						triggerClientEvent ( p, "onClientSetGameSpeed", getRootElement(), speed )
					end
				elseif elementType == "pimpSetWorldGravity" then
					local data = getAllElementData ( child )
					local gravity, doFor = data.gravity, data.doFor
					local gravity = tonumber ( gravity )
					if gravity < 0 then gravity = 0 end
					if doFor == "everyone" then
						setGravity ( gravity )
						for i, ped in pairs ( getElementsByType ( "ped" ) ) do
							setPedGravity ( ped, gravity )
						end
					else
						triggerClientEvent ( p, "onClientSetGravity", getRootElement(), gravity )
					end
				elseif elementType == "pimpSetVehicleHandling" then
					local data = getAllElementData ( child )
					local doFor = data.doFor
					local comX, comY, comZ = data.COMX, data.COMY, data.COMZ
					local centerOfMass
					if comX or comY or comZ then
						if comX and tonumber(comX) then comX = tonumber ( comX ) end
						if comY and tonumber(comY) then comY = tonumber ( comY ) end
						if comZ and tonumber(comZ) then comZ = tonumber ( comZ ) end
						local origHandling = getOriginalHandling ( getElementModel(v) )
						local origCOMTable = origHandling["centerOfMass"]
						centerOfMass = { comX or origCOMTable[1], comY or origCOMTable[2], comZ or origCOMTable[3] }
						if doFor == "player" and v then
							setVehicleHandling ( v, "centerOfMass", centerOfMass )
						else
							for i, player in pairs ( getElementsByType ( "player" ) ) do
								if ( ( doFor == "all other players" and player ~= p ) or doFor == "everyone" ) and getPedOccupiedVehicle(player) then
									setVehicleHandling ( getPedOccupiedVehicle ( player ), "centerOfMass", centerOfMass )
								end
							end
						end	
					end
					for key, value in pairs ( data ) do
						if handlingProperties[key] and value and ( tonumber(value) or ( type(value) == "string" and value ~= "don't change") ) then
							if key == "driveType" then
								if value=="frontwheeldrive"then value="fwd"elseif value=="rearwheeldrive"then value="rwd"elseif value=="fourwheeldrive"then value="awd"end
							end
							if doFor == "player" and v then
								setVehicleHandling ( v, handlingProperties[key], tonumber(value) or value )
							else
								for i, player in pairs ( getElementsByType ( "player" ) ) do
									if ( ( doFor == "all other players" and player ~= p ) or doFor == "everyone" ) and getPedOccupiedVehicle(player) then
										setVehicleHandling ( getPedOccupiedVehicle ( player ), handlingProperties[key], tonumber(value) or value )
									end
								end
							end	
						end
					end
				elseif elementType == "pimpResetVehicleHandling" then
					local data = getAllElementData ( child )
					local doFor = data.doFor
					for key, value in pairs ( data ) do
						if handlingProperties[key] and value == "true" then
							if doFor == "player" and v then
								local origHandling = getOriginalHandling ( getElementModel(v) )
								setVehicleHandling ( v, handlingProperties[key], origHandling[handlingProperties[key]] )
							else
								for i, player in pairs ( getElementsByType ( "player" ) ) do
									if ( ( doFor == "all other players" and player ~= p ) or doFor == "everyone" ) and getPedOccupiedVehicle(player) then
										local v = getPedOccupiedVehicle(player)
										local origHandling = getOriginalHandling ( getElementModel(v) )
										setVehicleHandling ( v, handlingProperties[key], origHandling[handlingProperties[key]] )
									end
								end
							end	
						end
					end
				end
			end
		end
	end
end
addEventHandler ( "onMarkerHit", getRootElement(), markerHit )

function teleport ( p, v, x, y, z, rx, ry, rz, vx, vy, vz, tvx, tvy, tvz, freezeTime, changedVx, changedVy, changedVz, velocityType, model )
	if v then
		setElementPosition ( v, x, y, z )
		setElementRotation ( v, rx, ry, rz )
		setElementVelocity ( v, 0, 0, 0 )
		setElementAngularVelocity ( v, 0, 0, 0 )
		setElementFrozen ( v, true )
		if model and tonumber(model) then
			setElementModel ( v, tonumber(model) )
		end
		setTimer ( function ( p, v, x, y, z, rx, ry, rz, vx, vy, vz, tvx, tvy, tvz, freezeTime, changedVx, changedVy, changedVz, velocityType, model )
			if freezeTime and tonumber ( freezeTime ) and tonumber ( freezeTime ) >= 50 then
				setTimer ( function ( v, vx, vy, vz, tvx, tvy, tvz, changedVx, changedVy, changedVz, velocityType )
					setElementFrozen ( v, false )
					triggerClientEvent ( p, "onClientSetElementVelocity", getRootElement(), p, v, vx, vy, vz, changedVx, changedVy, changedVz, velocityType )
					setElementAngularVelocity ( v, tvx, tvy, tvz )
				end, tonumber(freezeTime), 1, v, vx, vy, vz, tvx, tvy, tvz, changedVx, changedVy, changedVz, velocityType )
			else
				setElementFrozen ( v, false )
				triggerClientEvent ( p, "onClientSetElementVelocity", getRootElement(), p, v, vx, vy, vz, changedVx, changedVy, changedVz, velocityType )
				setElementAngularVelocity ( v, tvx, tvy, tvz )
			end
		end, 50, 1, p, v, x, y, z, rx, ry, rz, vx, vy, vz, tvx, tvy, tvz, freezeTime, changedVx, changedVy, changedVz, velocityType, model )
	else
		setElementPosition ( p, x, y, z )
		setPedRotation ( p, rz )
		if freezeTime and tonumber ( freezeTime ) and tonumber ( freezeTime ) >= 50 then
			setTimer ( function ( p, vx, vy, vz, changedVx, changedVy, changedVz, velocityType )
				setElementFrozen ( p, false )
				triggerClientEvent ( p, "onClientSetElementVelocity", getRootElement(), p, v, vx, vy, vz, changedVx, changedVy, changedVz, velocityType )
			end, tonumber(freezeTime), 1, p, vx, vy, vz, changedVx, changedVy, changedVz, velocityType )
		else
			triggerClientEvent ( p, "onClientSetElementVelocity", getRootElement(), p, v, vx, vy, vz, changedVx, changedVy, changedVz, velocityType )
		end
	end
end

function hexToRGB ( hex )
	local hex = hex:gsub("#","")
	return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)), tonumber("0x"..hex:sub(7,8))
end