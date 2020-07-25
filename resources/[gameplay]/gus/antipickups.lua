------Disallowed Vehicle Pickups------
---------------------------------------------
---------------------------------------------

disallowedVehs = {
	["DEADLINE"] = {
		432, -- Rhino
		449, -- Tram
		537, -- Freight
		538, -- Brown Streak
		570, -- Brown Streak Carriage
		569, -- Flat Freight
		590, -- Box Freight
		444, -- Monster 1
		556, -- Monster 2
		557, -- Monster 3
		--Air vehicles
		592, --Andromada
		577, --AT-400
		511, --Beagle
		512, --Cropduster
		593, --Dodo
		520, --Hydra
		553, --Nevada
		476, --Rustler
		519, --Shamal
		460, --Skimmer
		513, --Stuntplane
		548, --Cargobob
		425, --Hunter
		417, --Leviathan
		487, --Maverick
		488, --News Chopper
		497, --Police Maverick
		563, --Raindance
		447, --Seasparrow
		469, --Sparrow
	},
	["SHOOTER"] = {
		--Bikes--
		581, --BF-400
		509, --Bike
		481, --BMX
		462, --Faggio
		521, --FCR-900
		463, --Freeway
		510, --Mountain Bike
		522, --NRG-500
		461, --PCJ-600
		448, --Pizza Boy
		468, --Sanchez
		586, --Wayfarer
		471, --Quadbike

		--RC--
		441, --RC Bandit
		464, --RC Baron
		501, --RC Goblin
		465, --RC Raider
		564, --RC Tiger

		--Other--
		571, --Kart
		432, -- Rhino
		449, -- Tram
		537, -- Freight
		538, -- Brown Streak
		570, -- Brown Streak Carriage
		569, -- Flat Freight
		590, -- Box Freight

		425, -- hunter
	},
	["DESTRUCTION DERBY"] = {
		441, --RC Bandit
		464, --RC Baron
		501, --RC Goblin
		465, --RC Raider
		564, --RC Tiger
		592, --Andromada
		553, --Nevada
		577, --AT-400
		488, --News Chopper
		511, --Beagle
		497, --Police Maverick
		548, --Cargobob
		563, --Raindance
		512, --Cropduster
		476, --Rustler
		593, --Dodo
		447, --Seasparrow
		425, --Hunter
		519, --Shamal
		520, --Hydra
		460, --Skimmer
		417, --Leviathan
		469, --Sparrow
		487, --Maverick
		513, --Stuntplane

	}



}

currentGameMode = "No Gamemode"

addEvent('onMapStarting')
addEvent("onRaceStateChanging",true)
function detectGamemode(mapInfo, mapOptions, gameOptions)
	currentGameMode = string.upper(mapInfo.modename) -- Get's gamemode info, and converts it to upper case --
end
addEventHandler('onMapStarting', resourceRoot, detectGamemode)

function sendToClient(newState)
	if newState == "Running" and disallowedVehs[currentGameMode] then
		triggerClientEvent( getRootElement(), "removeBannedPickups", getRootElement(  ), disallowedVehs[currentGameMode] )
	end
end
addEventHandler("onRaceStateChanging", getRootElement(), sendToClient)


