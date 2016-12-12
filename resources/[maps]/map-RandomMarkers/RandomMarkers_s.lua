markersize = 4 -- Set Marker Size --
aboveheadTime = 2000 -- (1sec = 1000) Put the time that objects are above player's heads if they pick something up --
givelightstrength = 25 --(0 - 255) strength of the marker that is created when player object above head --
playsoundonmarkerhit = 43
SpikeStripLifeTime = 12500 -- Time a spikestrip should stay on the ground once dropped (in ms)
removeCols = {}





addEvent('onMapStarting')
function checkGameTypeforFunctions(mapInfo, mapOptions, gameOptions)




currentGameMode = string.upper(mapInfo.modename) -- Get's gamemode info, and converts it to upper case --



if currentGameMode == "DESTRUCTION DERBY" then -- Checkt voor DD
	  outputConsole( tostring(mapInfo.modename).." Random Markers script by KaliBwoy Started!")
      outputConsole( "For information on how to use Random Markers in your map, go to:")
      outputConsole( "http://mrgreengaming.com/forums/topic/14437-random-markers-script/")

functionstable =   { 
"Tec9", 
"Rocket", 
"Jump", 
"NOS", 
"FullHealth", 
"Barrel",
"Haybale", 
"SuperRam", 
"SpikeStrip", 
}


elseif currentGameMode == "FREEROAM" then -- Checkt voor RACE
      outputConsole( tostring(mapInfo.modename).." Random Markers script by KaliBwoy Started!")
      outputConsole( "For information on how to use Random Markers in your map, go to:")
      outputConsole( "http://mrgreengaming.com/forums/topic/14437-random-markers-script/")



functionstable =   { 
"Tec9", 
"Rocket", 
"Jump", 
"NOS", 
"FullHealth", 
"Barrel",
"Haybale", 
"SuperRam", 
"SpikeStrip", 
}


elseif currentGameMode == "SPRINT" then -- Checkt voor RACE
      outputConsole( tostring(mapInfo.modename).." Random Markers script by KaliBwoy Started!")
      outputConsole( "For information on how to use Random Markers in your map, go to:")
      outputConsole( "http://mrgreengaming.com/forums/topic/14437-random-markers-script/")






functionstable =   { 
"Tec9", 
"Rocket", 
-- "Jump",  -- Uncomment
"NOS", 
"FullHealth", 
"Barrel",
"Haybale", 
-- "SuperRam", -- Uncomment 
"SpikeStrip", 
}

elseif currentGameMode == "CAPTURE THE FLAG" then -- Checkt voor CTF
      outputConsole( tostring(mapInfo.modename).." Random Markers script by KaliBwoy Started!")
      outputConsole( "For information on how to use Random Markers in your map, go to:")
      outputConsole( "http://mrgreengaming.com/forums/topic/14437-random-markers-script/")

functionstable =   { 
"Tec9", 
"Rocket", 
"Jump", 
"NOS", 
"FullHealth", 
"Barrel",
"Haybale", 
"SuperRam", 
"SpikeStrip", 
}

elseif currentGameMode == "REACH THE FLAG" then -- Checkt voor RTF
      outputConsole( tostring(mapInfo.modename).." Random Markers script by KaliBwoy Started!")
      outputConsole( "For information on how to use Random Markers in your map, go to:")
      outputConsole( "http://mrgreengaming.com/forums/topic/14437-random-markers-script/")

functionstable =   { 
"Tec9", 
"Rocket", 
-- "Jump", 
"NOS", 
"FullHealth", 
"Barrel",
"Haybale", 
-- "SuperRam", 
"SpikeStrip", 
}




elseif currentGameMode == "NEVER THE SAME" then -- Checkt voor NTS

      outputConsole( tostring(mapInfo.modename).." Random Markers script by KaliBwoy Started!")
      outputConsole( "For information on how to use Random Markers in your map, go to:")
      outputConsole( "http://mrgreengaming.com/forums/topic/14437-random-markers-script/")

functionstable =   { 
"Tec9", 
"Rocket", 
-- "Jump", 
"NOS", 
"FullHealth", 
"Barrel",
"Haybale", 
-- "SuperRam", 
"SpikeStrip", 
}



elseif currentGameMode == "SHOOTER" or currentGameMode == "SHOOTER" then -- Checkt voor SH

      outputConsole( tostring(mapInfo.modename).." Random Markers script by KaliBwoy Started!")
      outputConsole( "For information on how to use Random Markers in your map, go to:")
      outputConsole( "http://mrgreengaming.com/forums/topic/14437-random-markers-script/")

OutputChatBox("Random Markers is not compatible with the gamemode Shooter")
functionstable =   { 
-- "Tec9", 
-- "Rocket", 
-- "Jump", 
-- "NOS", 
-- "FullHealth", 
-- "Barrel",
-- "Haybale", 
-- "SuperRam", 
-- "SpikeStrip", 
}
else
	outputChatBox("Invalid Gamemode Detected. (only NTS, Race, DD, CTF, RTF allowed!)")

functionstable =   { 
-- "Tec9", 
-- "Rocket", 
-- "Jump", 
-- "NOS", 
-- "FullHealth", 
-- "Barrel",
-- "Haybale", 
-- "SuperRam", 
-- "SpikeStrip", 
}
end
end

addEventHandler('onMapStarting', resourceRoot, checkGameTypeforFunctions)




function getAliveRacers()
    local count = 0
    for i, v in ipairs(getElementsByType('player')) do
        if getElementData(v, 'state') == 'alive' then
            count = count + 1000
        end
    end
    return count
end
 
setTimer (function ()
    respawntime = getAliveRacers()
    if respawntime <= 15000 then
      respawntime = 15000 elseif 
      respawntime >= 40000 then
      respawntime = 39000
    end

end, 1000,0)




local createdMarkers = {}

function createRandomMarkers()
      local newDetection = getElementsByType("randommarker")
      if #newDetection > 0 then -- New randommarkers placement used (elements in .map)
            for _,t in ipairs(newDetection) do
                  local pos = getAllElementData(t)
                  if pos.posX and pos.posY and pos.posZ then
                        local createdmarker = createMarker(tonumber(pos.posX),tonumber(pos.posY),tonumber(pos.posZ),"cylinder", markersize, 0, 255, 0, 150)
                        table.insert(createdMarkers,createdmarker)
                  end
            end
      else  -- LEGACY -- Checks for heads, replaces it with markers and makes the heads invisible and with no collision --
            local allObjects = getElementsByType ( "object" )
            for _, t in pairs( allObjects ) do
                  if ( getElementModel (t) == 2908 ) then
                        local x,y,z = getElementPosition (t) -- Gets xyz position from the heads
                        local createdmarker = createMarker (x, y, z, "cylinder", markersize, 0, 255, 0, 150) -- Creates the markers
                        table.insert(createdMarkers, createdmarker)
                        setElementAlpha ( t, 0 )
                        setElementCollisionsEnabled(t, false)
                  end
            end
      end
end
addEventHandler ( "onResourceStart", resourceRoot, createRandomMarkers )


function MarkerColorChange () -- Random Colors for the markers
      for _, mrkr in pairs( createdMarkers ) do
            setMarkerColor ( mrkr, math.random (0,255), math.random (0,255), math.random (0,255), 50 )
      end
end
setTimer ( MarkerColorChange, 120, 0 )


--------------------HIT FUNCTIONS-----------------
function SpikeStrip (hitElement)
      playSoundFrontEnd(hitElement, playsoundonmarkerhit)
            -- Make spikestrip appear above player--
      local hitElementVehicle = getPedOccupiedVehicle (hitElement) -- gets players car
      local spikex, spikey, spikez = getElementPosition ( hitElementVehicle ) --Get the players position
      local spikestrip = createObject ( 2892, spikex, spikey, spikez ) --Creates the object
      local givelight = createMarker ( 0, 0, 0, "corona", 1, 255, 255, 255, givelightstrength )
      attachElements ( givelight, hitElementVehicle, 0, -0.25, 2, 0, 0, 0 )
      attachElements ( spikestrip, hitElementVehicle, 0, 0, 2, 180, 180, -90 )
      setElementCollisionsEnabled (spikestrip,false)
      setObjectScale (spikestrip,0.4)
      setTimer(function() destroyElement (spikestrip) end,aboveheadTime,1)
      setTimer(function() destroyElement (givelight) end,aboveheadTime,1)
      triggerClientEvent(hitElement,"onSpikeStrip",hitElement)
      --END Make spikestrip appear above player --

end

function DropSpikeStrip(spikedropx,spikedropy,spikedropz,spikerotx,spikeroty,spikerotz,playerveh,groundz)
      local playerhealth = getElementHealth(playerveh)
      local vehrotx,vehroty,vehrotz = getElementRotation(playerveh)
      local colshapesize = 1
	  local droppedspikestrip
      local spikecolshape1dummy
      local spikecolshape2dummy
      local spikecolshape3dummy
      local spikecolshape4dummy
      local spikecolshape5dummy
      local spikecolshape6dummy
      if spikedropz - groundz > 1 then -- If the ground is more then 1 away from the object--
            droppedspikestrip = createObject ( 2892, spikedropx, spikedropy, spikedropz + 0.1 ) --Creates DROPPED spikestrip--
            setObjectScale(droppedspikestrip,0.5)
            setElementRotation(droppedspikestrip,0,0,vehrotz - 90)
            setTimer(destroyElement, SpikeStripLifeTime, 1, droppedspikestrip)
            setElementHealth(playerveh,playerhealth) 
            --colshape--
            local spikelocx,spikelocy,spikelocz = getElementPosition(droppedspikestrip)

            --MAKE COL SHAPES --
            spikecolshape1dummy = createColSphere(spikelocx, spikelocy, spikelocz, 0.3)
            spikecolshape2dummy = createColSphere(spikelocx, spikelocy, spikelocz, 0.3)
            spikecolshape3dummy = createColSphere(spikelocx, spikelocy, spikelocz, 0.3)
            spikecolshape4dummy = createColSphere(spikelocx, spikelocy, spikelocz, 0.3)
            spikecolshape5dummy = createColSphere(spikelocx, spikelocy, spikelocz, 0.3)
            spikecolshape6dummy = createColSphere(spikelocx, spikelocy, spikelocz, 0.3)
      else 
        	droppedspikestrip = createObject ( 2892, spikedropx, spikedropy, groundz + 0.1  ) --Creates DROPPED spikestrip--

            setElementRotation(droppedspikestrip,0,0,vehrotz - 90)
            setTimer(destroyElement, SpikeStripLifeTime, 1, droppedspikestrip)
            setObjectScale(droppedspikestrip,0.5)
            setElementHealth(playerveh,playerhealth) 


            local spikelocx,spikelocy,spikelocz = getElementPosition(droppedspikestrip)

            --MAKE COL SHAPES --
            spikecolshape1dummy = createColSphere(spikelocx, spikelocy, spikelocz, 0.5)
            spikecolshape2dummy = createColSphere(spikelocx, spikelocy, spikelocz, 0.5)
            spikecolshape3dummy = createColSphere(spikelocx, spikelocy, spikelocz, 0.5)
            spikecolshape4dummy = createColSphere(spikelocx, spikelocy, spikelocz, 0.5)
            spikecolshape5dummy = createColSphere(spikelocx, spikelocy, spikelocz, 0.5)
            spikecolshape6dummy = createColSphere(spikelocx, spikelocy, spikelocz, 0.5)
      end
	-- END MAKE COL SHAPES --
	--Attach Colshapes to SpikeStrip --
	attachElements(spikecolshape1dummy,droppedspikestrip, 0, 0.5)
	attachElements(spikecolshape2dummy,droppedspikestrip, 0, 1)
	attachElements(spikecolshape3dummy,droppedspikestrip, 0, 1.5)
	attachElements(spikecolshape4dummy,droppedspikestrip, 0, -0.5)
	attachElements(spikecolshape5dummy,droppedspikestrip, 0, -1)
	attachElements(spikecolshape6dummy,droppedspikestrip, 0, -1.5)
	
	--END Attach Colshapes to SpikeStrip END --
	
	-- GET COLSHAPE POSITIONS, MAKES NEW COLSHAPES AND DELETE ATTACHED ONES --
	local spikecolshape = {}
		--Colshape 1--
		local spikecol1x,spikecol1y,spikecol1z = getElementPosition(spikecolshape1dummy)
		spikecolshape[1] = createColSphere(spikecol1x, spikecol1y, spikecol1z + 0.5, colshapesize)
		destroyElement(spikecolshape1dummy)
		
		
		--Colshape 2--
		local spikecol2x,spikecol2y,spikecol2z = getElementPosition(spikecolshape2dummy)
		spikecolshape[2] = createColSphere(spikecol2x, spikecol2y, spikecol2z + 0.5, colshapesize)
		destroyElement(spikecolshape2dummy)
		
		--Colshape 3--
		local spikecol3x,spikecol3y,spikecol3z = getElementPosition(spikecolshape3dummy)
		spikecolshape[3] = createColSphere(spikecol3x, spikecol3y, spikecol3z + 0.5, colshapesize)
		destroyElement(spikecolshape3dummy)
		
		--Colshape 4--
		local spikecol4x,spikecol4y,spikecol4z = getElementPosition(spikecolshape4dummy)
		spikecolshape[4] = createColSphere(spikecol4x, spikecol4y, spikecol4z + 0.5, colshapesize)
		destroyElement(spikecolshape4dummy)
		
		--Colshape 5--
		local spikecol5x,spikecol5y,spikecol5z = getElementPosition(spikecolshape5dummy)
		spikecolshape[5] = createColSphere(spikecol5x, spikecol5y, spikecol5z + 0.5, colshapesize)
		destroyElement(spikecolshape5dummy)
		
		--Colshape 6--
		local spikecol6x,spikecol6y,spikecol6z = getElementPosition(spikecolshape6dummy)
		spikecolshape[6] = createColSphere(spikecol6x, spikecol6y, spikecol6z + 0.5, colshapesize)
		destroyElement(spikecolshape6dummy)
	
	local nr = 1
	local nrBool = true
	while nrBool do
		if removeCols[nr] then
			nr = nr + 1
		else
			nrBool = false
		end
	end
	removeCols[nr] = spikecolshape
	-- END GET COLSHAPE POSITIONS, MAKES NEW COLSHAPES AND DELETE ATTACHED ONES END --
	
	--Remove Collision shapes after spike lifetime --
	setTimer(function()
		destroyElement(removeCols[nr][1])
		destroyElement(removeCols[nr][2])
		destroyElement(removeCols[nr][3])
		destroyElement(removeCols[nr][4])
		destroyElement(removeCols[nr][5])
		destroyElement(removeCols[nr][6])
		removeCols[nr] = nil
	end, SpikeStripLifeTime, 1)
	
	--END Remove Collision shapes after spike lifetime END--
end
addEvent( "DropSpikeStripEvent", true )
addEventHandler( "DropSpikeStripEvent", root, DropSpikeStrip )



function onPlayerHitSpikeStrip(hitElement)
	typeofelement = getElementType(hitElement)
	outputChatBox("Hit Spike 1 " .. typeofelement)
	
	if typeofelement == "player" then
		local hit = false
		for _ in pairs(removeCols) do
			if source == removeCols[_][1] then hit = true end
			if source == removeCols[_][2] then hit = true end
			if source == removeCols[_][3] then hit = true end
			if source == removeCols[_][4] then hit = true end
			if source == removeCols[_][5] then hit = true end
			if source == removeCols[_][6] then hit = true end
			outputChatBox("Loop")
		end
		if hit then

			local playerveh = getPedOccupiedVehicle(hitElement)
			outputChatBox("Hit Spike 2")
				-- get wheel states
				local wheelstates = {}
				local o,t,tr,f = getVehicleWheelStates(playerveh)
				table.insert(wheelstates,o) table.insert(wheelstates,t) table.insert(wheelstates,tr) table.insert(wheelstates,f)
				for _,v in ipairs(wheelstates) do
					if v > 1 then
							v = 1
					end
				end
	
				-- set wheel states
			setVehicleWheelStates(playerveh, math.random (wheelstates[1],1), math.random (wheelstates[2],1), math.random (wheelstates[3],1), math.random (wheelstates[4],1))

		end
	end
end
addEventHandler("onColShapeHit", resourceRoot, onPlayerHitSpikeStrip)




function SuperRam (hitElement)
      playSoundFrontEnd(hitElement, playsoundonmarkerhit)
            -- Make arrow appear above player--
      local hitElementVehicle = getPedOccupiedVehicle (hitElement) -- gets players car
      local superRamx, superRamy, superRamz = getElementPosition ( hitElementVehicle ) --Get the players position
      local arrow = createObject ( 1318, superRamx, superRamy, superRamz ) --Creates the object
      local givelight = createMarker ( 0, 0, 0, "corona", 1, 255, 255, 255, givelightstrength )
      attachElements ( givelight, hitElementVehicle, 0, -0.25, 2, 0, 0, 0 )
      attachElements ( arrow, hitElementVehicle, 0, 0, 2, 180, 90, -90 )
      setElementCollisionsEnabled (arrow,false)
      setObjectScale (arrow,0.7)
      setTimer(function() destroyElement (arrow) end,aboveheadTime,1)
      setTimer(function() destroyElement (givelight) end,aboveheadTime,1)
      triggerClientEvent(hitElement,"onSuperRam",hitElement)
      --END Make arrow appear above player --

end


function Tec9 (hitElement)
      playSoundFrontEnd(hitElement, playsoundonmarkerhit)
      -- Make tec9 appear above player--
      local hitElementVehicle = getPedOccupiedVehicle (hitElement) -- gets players car
      local tec9x, tec9y, tec9z = getElementPosition ( hitElementVehicle ) --Get the players position
      local tec9 = createObject ( 372, tec9x, tec9y, tec9z ) --Creates the tec9
      local givelight = createMarker ( 0, 0, 0, "corona", 1, 255, 255, 255, givelightstrength )
      attachElements ( givelight, hitElementVehicle, 0, 0, 2, 0, 0, 0 )
      attachElements ( tec9, hitElementVehicle, 0, 0, 2, 0, 0, 90 )
      setElementCollisionsEnabled (tec9,false)
      setObjectScale (tec9,2)



      setTimer(function() destroyElement (tec9) end,aboveheadTime,1)
      setTimer(function() destroyElement (givelight) end,aboveheadTime,1)
      --END Make tec9 appear above player --
      giveWeapon( hitElement, 32, 10000) -- Gives player a Tec-9 with 0 ammo (so he cant use it yet) --
      triggerClientEvent(hitElement,"onTec9",hitElement)
end

function takeTec9Ammo(player)
      takeWeapon(player,32)
end
addEvent("removeAmmo",true)
addEventHandler("removeAmmo", root, takeTec9Ammo)

function Jump (hitElement)
      playSoundFrontEnd(hitElement, playsoundonmarkerhit)
      -- Make arrow appear above player--
      local hitElementVehicle = getPedOccupiedVehicle (hitElement) -- gets players car
      local jumpx, jumpy, jumpz = getElementPosition ( hitElementVehicle ) --Get the players position
      local arrow = createObject ( 1318, jumpx, jumpy, jumpz ) --Creates the object
      local givelight = createMarker ( 0, 0, 0, "corona", 1, 255, 255, 255, givelightstrength )
      attachElements ( givelight, hitElementVehicle, 0, -0.25, 2, 0, 0, 0 )
      attachElements ( arrow, hitElementVehicle, 0, 0, 2, 180, 0, 90 )
      setElementCollisionsEnabled (arrow,false)
      setObjectScale (arrow,0.7)
      setTimer(function() destroyElement (arrow) end,aboveheadTime,1)
      setTimer(function() destroyElement (givelight) end,aboveheadTime,1)
      triggerClientEvent(hitElement,"onJump",hitElement)
      --END Make arrow appear above player --
end

function NOS (hitElement)
      playSoundFrontEnd(hitElement, playsoundonmarkerhit)
      -- Make healthico appear above player--
      local hitElementVehicle = getPedOccupiedVehicle (hitElement) -- gets players car
      local nosx, nosy, nosz = getElementPosition ( hitElementVehicle ) --Get the players position
      local nosico = createObject ( 2221, nosx, nosy, nosz ) --Creates the object
      local givelight = createMarker ( 0, 0, 0, "corona", 1, 255, 255, 255, givelightstrength )
      attachElements ( givelight, hitElementVehicle, 0, -0.25, 2, 0, 0, 0 )
      attachElements ( nosico, hitElementVehicle, 0, 0, 2, 0, 0 )
      setElementCollisionsEnabled (nosico,false)
      setObjectScale (nosico,0.60)
      setTimer(function() destroyElement (nosico) end,aboveheadTime,1)
      setTimer(function() destroyElement (givelight) end,aboveheadTime,1)
      --END Make barrel appear above player --
      triggerClientEvent(hitElement,"onNOS",hitElement)
end


function Barrel (hitElement)
      playSoundFrontEnd(hitElement, playsoundonmarkerhit)
      -- Make barrel appear above player--
      local hitElementVehicle = getPedOccupiedVehicle (hitElement) -- gets players car
      local barx, bary, barz = getElementPosition ( hitElementVehicle ) --Get the players position
      local barrel = createObject ( 1225, barx, bary, barz ) --Creates the object
      local givelight = createMarker ( 0, 0, 0, "corona", 1, 255, 255, 255, givelightstrength )
      attachElements ( givelight, hitElementVehicle, 0, -0.25, 2, 0, 0, 0 )
      attachElements ( barrel, hitElementVehicle, 0, 0, 2, 0, 0, 90 )
      setElementCollisionsEnabled (barrel,false)
      setObjectScale (barrel,0.7)
      setTimer(function() destroyElement (barrel) end,aboveheadTime,1)
      setTimer(function() destroyElement (givelight) end,aboveheadTime,1)
      --END Make barrel appear above player --
      triggerClientEvent(hitElement,"onBarrel",hitElement)
end

function DropBarrel(bardropx,bardropy,bardropz,playerveh)
      local playerhealth = getElementHealth(playerveh)
      local droppedbarrel = createObject ( 1225, bardropx, bardropy, bardropz ) --Creates DROPPED barrel--
      setElementHealth(playerveh,playerhealth)
end
addEvent( "DropBarrelEvent", true )
addEventHandler( "DropBarrelEvent", root, DropBarrel )


function Haybale (hitElement)
      playSoundFrontEnd(hitElement, playsoundonmarkerhit)
      -- Make haybale appear above player--
      local hitElementVehicle = getPedOccupiedVehicle (hitElement) -- gets players car
      local hayx, hayy, hayz = getElementPosition ( hitElementVehicle ) --Get the players position
      local haybale = createObject ( 3374, hayx, hayy, hayz ) --Creates the object
      local givelight = createMarker ( 0, 0, 0, "corona", 1, 255, 255, 255, givelightstrength )
      attachElements ( givelight, hitElementVehicle, 0, -0.25, 2, 0, 0, 0 )
      attachElements ( haybale, hitElementVehicle, 0, 0, 2, 0, 0, 90 )
      setElementCollisionsEnabled (haybale,false)
      setObjectScale (haybale,0.3)
      setTimer(function() destroyElement (haybale) end,aboveheadTime,1)
      setTimer(function() destroyElement (givelight) end,aboveheadTime,1)

      --END Make haybale appear above player --
      triggerClientEvent(hitElement,"onHaybale",hitElement)
end

function DropHaybale(haydropx,haydropy,haydropz,playerveh)
      local playerhealth = getElementHealth(playerveh)
      droppedbarrel = createObject ( 3374, haydropx, haydropy, haydropz+0.70 ) --Creates DROPPED barrel--
      setElementHealth(playerveh,playerhealth)
end
addEvent( "DropHaybaleEvent", true )
addEventHandler( "DropHaybaleEvent", root, DropHaybale )


function Rocket (hitElement)
      playSoundFrontEnd(hitElement, playsoundonmarkerhit)
      -- Make rocket appear above player--
      local hitElementVehicle = getPedOccupiedVehicle (hitElement) -- gets players car
      local rocketx, rockety, rocketz = getElementPosition ( hitElementVehicle ) -- gets players car position


      local missile = createObject ( 359, rocketx, rockety, rocketz ) --Creates the object
      local givelight = createMarker ( 0, 0, 0, "corona", 1, 255, 255, 255, givelightstrength )
      attachElements ( givelight, hitElementVehicle, 0, -0.25, 2, 0, 0, 0 )
      attachElements ( missile, hitElementVehicle, 0, 0, 2, 0, 0, 90 )
      setElementCollisionsEnabled (missile,false)
      setTimer(function() destroyElement (missile) end,aboveheadTime,1)
      setTimer(function() destroyElement (givelight) end,aboveheadTime,1)

      --END Make rocket appear above player --
      triggerClientEvent ( hitElement, "onRocket", hitElement )

end

function FullHealth(hitElement)
      playSoundFrontEnd(hitElement, playsoundonmarkerhit)
      -- Make healthico appear above player--
      local hitElementVehicle = getPedOccupiedVehicle (hitElement) -- gets players car
      local heax, heay, heaz = getElementPosition ( hitElementVehicle ) --Get the players position
      local healthico = createObject ( 2222, heax, heay, heaz ) --Creates the object
      local givelight = createMarker ( 0, 0, 0, "corona", 1, 255, 255, 255, givelightstrength )
      attachElements ( givelight, hitElementVehicle, 0, -0.25, 2, 0, 0, 0 )
      attachElements ( healthico, hitElementVehicle, 0, 0, 2, 0, 0 )
      setElementCollisionsEnabled (healthico,false)
      setObjectScale (healthico,0.60)
      setTimer(function() destroyElement (healthico) end,aboveheadTime,1)
      setTimer(function() destroyElement (givelight) end,aboveheadTime,1)

      --END Make barrel appear above player --
      triggerClientEvent ( hitElement, "onFullHealth", hitElement )
end

-------------------END HIT FUNCTIONS-------------

math.randomseed( getTickCount() )

local lastPickup = {}
function randomPickup(hitElement)
      local rndm = functionstable[math.random(1,#functionstable)]
      if lastPickup[hitElement] then
            if lastPickup[hitElement] ~= rndm then
                  lastPickup[hitElement] = rndm
                  return rndm
            else
                  for i= 1, 50 do
                        rndm = functionstable[math.random(1,#functionstable)]

                        if lastPickup[hitElement] ~= rndm then

                              break
                        end
                  end
                  lastPickup[hitElement] = rndm
                  return rndm
            end
      else

            lastPickup[hitElement] = rndm
            return rndm
      end
      
end


function hittingthemarker ( hitElement )
      if getElementType(hitElement) ~= "player" then return end
      local randomfunctionfromtable = functionstable[math.random(1,#functionstable)]
      local whatsizeisthemarker = getMarkerSize ( source )
      if getElementType( hitElement ) == "player" and  isPedInVehicle( hitElement ) and whatsizeisthemarker == markersize and getElementData (hitElement, "isItemPickedUp") == "no" then
            setElementData (hitElement, "isItemPickedUp", "yes", true)
            
            local theRandomPickup = randomPickup(hitElement)
            setTimer (_G[theRandomPickup], 50, 1, hitElement) 


            local sx,sy,sz = getElementPosition(source)
            setElementPosition ( source, 0,0,-600) -- makes marker go away --
            local disappearedmarker = source -- targets the marker that went away --
            setTimer (setElementPosition, respawntime, 1, disappearedmarker, sx,sy,sz)
	else
            triggerClientEvent ( hitElement, "useitemWarning", hitElement, source )
      end
end 

addEventHandler('onMarkerHit', resourceRoot, hittingthemarker)



function HideGUI ()
      triggerClientEvent ( source, "ClientHideGUI", source )
end
addEventHandler("onPlayerWasted", root, HideGUI)

function ShowGUI ()
      triggerClientEvent ( source, "ClientShowGUI", source )
end
addEventHandler("onPlayerVehicleEnter", root, ShowGUI)
