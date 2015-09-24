-------------------------------------------
---   Fix for improved vehicle models   ---
-------------------------------------------

function onGamemodeMapStop ( stoppedMap )
	triggerClientEvent ( 'onGamemodeMapStop', source, stoppedMap )
end
addEventHandler('onGamemodeMapStop', root, onGamemodeMapStop)


---------------------------------------------------
---   Fix for parked ghostmode cars
---   Fix for parked cars having gm in some maps
---------------------------------------------------

addEvent("onRaceStateChanging", true)
addEventHandler("onRaceStateChanging", root,
	function(newstate, oldstate)
		for i,j in ipairs(getElementsByType('vehicle')) do 
			if (getVehicleOccupant(j) == false) and (isVehicleBlown(j) == false) then
				setElementData ( j, 'race.collideothers', 1 )
			end	
		end
		for _, j in ipairs(getElementsByType('player')) do 
			showPlayerHudComponent(j, 'radio', true)
		end	
	end	
)


---------------------------------------
---   Fix for vortex and planes
---   Fixes annoying damaged vehicles
---------------------------------------

function quickFix ( theVehicle )
	if isElement(theVehicle) then
		local a = getElementHealth ( theVehicle )
		fixVehicle ( theVehicle )
		setTimer ( function(veh, health)
			if isElement(veh) then
				setElementHealth( veh, health )
				for i=1,6 do
					setVehiclePanelState(theVehicle, i, 0)
				end
				for i=1,5 do
					setVehicleDoorState(theVehicle, i, 0)
				end
			end	
		end, 150, 1, theVehicle, a)
	end
end

local vehicleModelVariants={
  [404]={0,1,2},
  [407]={0,1,2},
  [408]={0},
  [413]={0},
  [414]={0,1,2,3},
  [415]={0,1},
  [416]={0,1},
  [422]={0,1},
  [423]={0,1},
  [424]={0},
  [428]={0,1},
  [433]={0,1},                                                                                                                                         
  [434]={0},                                                                                                                                           
  [435]={0,1,2,3,4,5},                                                                                                                                 
  [437]={0,1},                                                                                                                                         
  [439]={0,1,2},                                                                                                                                       
  [440]={0,1,2,3,4,5},                                                                                                                                 
  [442]={0,1,2},                                                                                                                                       
  [449]={0,1,2,3,4},                                                                                                                                   
  [450]={0},                                                                                                                                           
  [453]={0,1},                                                                                                                                         
  [455]={0,1,2},                                                                                                                                       
  [456]={0,1,2,3},                                                                                                                                     
  [457]={0,1,2,3,4,5},                                                                                                                                 
  [459]={0},                                                                                                                                           
  [470]={0,1,2},                                                                                                                                       
  [472]={0,1,2},                                                                                                                                       
  [477]={0},                                                                                                                                           
  [478]={0,1,2},                                                                                                                                       
  [482]={0},                                                                                                                                           
  [483]={0,1},                                                                                                                                         
  [484]={0},                                                                                                                                           
  [485]={0,1,2},                                                                                                                                       
  [499]={0,1,2,3},                                                                                                                                     
  [500]={0,1},                                                                                                                                         
  [502]={0,1,2,3,4,5},                                                                                                                                 
  [503]={0,1,2,3,4,5},                                                                                                                                 
  [504]={0,1,2,3,4,5},                                                                                                                                 
  [506]={0},                                                                                                                                           
  [521]={0,1,2,3,4},                                                                                                                                   
  [522]={0,1,2,3,4},                                                                                                                                   
  [535]={0,1},  
  [543]={0,1,2,3,4},                                                                                                                                       
  [552]={0,1},                                                                                                                                         
  [555]={0,1},                                                                                                                                         
  [556]={0,1,2},                                                                                                                                       
  [557]={0,1},                                                                                                                                         
  [571]={0,1},                                                                                                                                         
  [581]={0,1,2,3,4},                                                                                                                                   
  [583]={0,1},                                                                                                                                         
  [595]={0,1},                                                                                                                                         
  [600]={0,1},                                                                                                                                         
  [601]={0,1,2,3},                                                                                                                                     
  [605]={0,1,2,3,4},                                                                                                                                     
  [607]={0,1,2},                                                                                                                                       
}

function vehicleChange( player, theVehicle, old )
	if not theVehicle then
		return
	elseif getVehicleType(theVehicle) == "Plane" then
		quickFix ( theVehicle )
	end
	-- make sure the nrg-500 has an engine
	if getElementModel(theVehicle) == 522 then
		local var1, var2 = getVehicleVariant( theVehicle )
		if var1 == 255 and var2 == 255 then
			setVehicleVariant ( theVehicle, 2, 4 )
		end
	-- random variant for other vehicles
	elseif vehicleModelVariants[getElementModel(theVehicle)] then
		local variants = {255,255}
		for _,v in ipairs(vehicleModelVariants[getElementModel(theVehicle)]) do
			table.insert(variants,v)
		end
		local var1,var2 = table.remove(variants,math.random(#variants)), table.remove(variants,math.random(#variants))
		setVehicleVariant ( theVehicle, var1, var2 )
	end
	-- delayed send to client
	setTimer(triggerClientEvent, 50, 1, player, 'vehicleChange', player, theVehicle, old)
end
addEventHandler ( 'onPlayerVehicleEnter', root, function(v) vehicleChange(source, v) end)
addEventHandler ( 'onElementModelChange', root, function(old)
	if getElementType(source) == "vehicle" and getVehicleOccupant(source) and getElementType(getVehicleOccupant(source)) == "player" then
		vehicleChange(getVehicleOccupant(source), source, old)
	end
end)


addEvent( "onPlayerReachCheckpoint", true)
addEventHandler( "onPlayerReachCheckpoint", root,
	function()
		checkVehicle(getPedOccupiedVehicle(source))
	end
)

function checkVehicle ( theVehicle )
	if not theVehicle then return end
	if getElementModel(theVehicle) == 539 or getVehicleType(theVehicle) == "Plane" then
		quickFix ( theVehicle )
	elseif getElementModel(theVehicle) == 522 then
		local var1, var2 = getVehicleVariant( theVehicle )
		if var1 == 255 and var2 == 255 then
			setVehicleVariant ( theVehicle, 2, 4 )
		end
	end
end


---------------------------------------------
---   Small bind that lets the player put
---   on his lights
---------------------------------------------

function changeLightState (player)
	local playerVehicle = getPedOccupiedVehicle(player)
	if not playerVehicle then return false end
	--[[local oldState = getVehicleLightState(veh, 0)
	local newState = oldState == 1 and 0 or 1
	setVehicleLightState ( veh, 0, newState )
	setVehicleLightState ( veh, 1, newState )
	setVehicleLightState ( veh, 2, newState )
	setVehicleLightState ( veh, 3, newState )]]
	if ( getVehicleOverrideLights ( playerVehicle ) ~= 2 ) then  -- if the current state isn't 'force on'
            setVehicleOverrideLights ( playerVehicle, 2 )            -- force the lights on
        else
            setVehicleOverrideLights ( playerVehicle, 1 )            -- otherwise, force the lights off
    end
	--For SDK: See example here http://wiki.multitheftauto.com/wiki/SetVehicleOverrideLights
	--setting vehicle light state means the damage state, not whether or not to actually turn on/off the lights
end
for k, v in ipairs(getElementsByType('player')) do
	bindKey ( v, 'l', 'down', changeLightState )
end
addEventHandler ( 'onPlayerJoin', root, function() bindKey ( source, 'l', 'down', changeLightState ) end)