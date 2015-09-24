------Disallowed Vehicle Pickups for SH------
---------------------------------------------
---------------------------------------------

disallowedVehs = {
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



}
currentGameMode = "No Gamemode"

addEvent('onMapStarting')
addEvent("onRaceStateChanging",true)
function DetectSH(mapInfo, mapOptions, gameOptions)
	currentGameMode = string.upper(mapInfo.modename) -- Get's gamemode info, and converts it to upper case --
end
addEventHandler('onMapStarting', resourceRoot, DetectSH)

function sendToClient(newState)
	if newState == "Running" and currentGameMode == "SHOOTER" then
		triggerClientEvent( getRootElement(), "removeBannedPickups", getRootElement(  ), disallowedVehs )
	end
end
addEventHandler("onRaceStateChanging", getRootElement(), sendToClient)