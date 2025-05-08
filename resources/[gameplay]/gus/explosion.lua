
-- used to check how many explosion/projectile sync packets a client sends overtime
local iExplosionCheckInterval 		= 5000;	-- the interval in ms to check for players sending too many explosion and projectile sync packets
local tblPlayerProjectiles 			= {};	-- store players sending projectile sync packets
local tblRegularExplosions 			= {};	-- store players sending regular explosion sync packets
local tblVehicleExplosions 			= {};	-- store players sending vehicle explosion sync packets
local iPlayerProjectileThreshold 	= 10;	-- the threshold when we consider client suspicious for projectile creations
local iRegularExplosionThreshold 	= 10;	-- the threshold when we consider client suspicious for regular explosions
local iVehicleExplosionThreshold 	= 10;	-- the threshold when we consider client suspicious for vehicle explosions
local iRegularExplosionBanTest	= 50;	-- the threshold when we ban the client for suspicious regular explosions

-- https://wiki.multitheftauto.com/wiki/OnPlayerProjectileCreation
-- gets triggered when a player creates a projectile sync packets (eg. shoots a weapon, vehicle weapon or via createProjectile)
function clientCreateProjectile(iWeaponType, fPX, fPY, fPZ, fForce, uTarget, fRX, fRY, fRZ, fVX, fVY, fVZ)
	if(isElement(source)) then
		if(tblPlayerProjectiles[source]) then
			tblPlayerProjectiles[source] = tblPlayerProjectiles[source] + 1;
		else
			tblPlayerProjectiles[source] = 1;
		end
	end
end
addEventHandler("onPlayerProjectileCreation", root, clientCreateProjectile);

-- https://wiki.multitheftauto.com/wiki/OnExplosion
-- gets triggered when an explosion occurs, either via server script or client sync packet
function clientCreateExplosion(fPX, fPY, fPZ, iType)
	if(isElement(source)) then
		if(getElementType(source) == "player") then
			if(tblRegularExplosions[source]) then
				tblRegularExplosions[source] = tblRegularExplosions[source] + 1;
			else
				tblRegularExplosions[source] = 1;
			end
		end
	end
end
addEventHandler("onExplosion", root, clientCreateExplosion);

-- https://wiki.multitheftauto.com/wiki/OnVehicleExplode
-- gets triggered when a vehicle explodes, either via server script or client sync packet
function clientCreateVehicleExplosion(bWithExplosion, uPlayer)
	if(isElement(uPlayer)) then
		if(tblVehicleExplosions[uPlayer]) then
			tblVehicleExplosions[uPlayer] = tblVehicleExplosions[uPlayer] + 1;
		else
			tblVehicleExplosions[uPlayer] = 1;
		end
	end
end
addEventHandler("onVehicleExplode", root, clientCreateVehicleExplosion);

-- setup a timer with specified interval above and check if any client sent too many sync packets in the given time
-- thresholds need to be adjusted for your need and actions taken!
setTimer(function()
	for uPlayer, iCounter in pairs(tblPlayerProjectiles) do
		if(iCounter >= iPlayerProjectileThreshold) then
			if getResourceFromName('discord') and getResourceState(getResourceFromName('discord')) == 'running' then
				exports.discord:send("admin.log", { log = remcol(getPlayerName(uPlayer)).." has exceeded projectile threshold "..tostring(iPlayerProjectileThreshold).." - Count: "..tostring(iCounter) .. "\nSerial: " .. getPlayerSerial(uPlayer)} )
		end
		end
	end
	
	for uPlayer, iCounter in pairs(tblRegularExplosions) do
		if(iCounter >= iRegularExplosionThreshold) then
			if getResourceFromName('discord') and getResourceState(getResourceFromName('discord')) == 'running' then
				exports.discord:send("admin.log", { log = remcol(getPlayerName(uPlayer)).." has exceeded regular explosions threshold "..tostring(iRegularExplosionThreshold).." - Count: "..tostring(iCounter) .. "\nSerial: " .. getPlayerSerial(uPlayer)} )
			end
		end

		if (iCounter >= iRegularExplosionBanTest) then
			if getResourceFromName('discord') and getResourceState(getResourceFromName('discord')) == 'running' then
				exports.discord:send("admin.log", { log = remcol(getPlayerName(uPlayer)).." has been banned by the Explosion Inspector"} )
				banPlayer(uPlayer, true, false, true, "Explosion Inspector", "Too many booms, you're out! Appeal at forums.mrgreengaming.com or on Discord", 0)
			end
		end
	end
	
	for uPlayer, iCounter in pairs(tblVehicleExplosions) do
		if(iCounter >= iVehicleExplosionThreshold) then
			if getResourceFromName('discord') and getResourceState(getResourceFromName('discord')) == 'running' then
				exports.discord:send("admin.log", { log = remcol(getPlayerName(uPlayer)).." has exceeded vehicle explosions threshold "..tostring(iVehicleExplosionThreshold).." - Count: "..tostring(iCounter) .. "\nSerial: " .. getPlayerSerial(uPlayer)} )
			end
		end
	end
	
	tblPlayerProjectiles = {};
	tblRegularExplosions = {};
	tblVehicleExplosions = {};
	
end, iExplosionCheckInterval, 0);

function remcol(str)
	return string.gsub (str, '#%x%x%x%x%x%x', '' )
end