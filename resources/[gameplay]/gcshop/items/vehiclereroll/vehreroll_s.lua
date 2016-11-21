local isRerollAllowed = false
local rerollIntervalTime = 10000 -- time between rerolls in ms
local rerollPlayer = {}

local playerRolledAmount = {} -- [player] = amount 
local maxRollsPerMap = 1

local vehroll_firstcheckpoint = false -- don't allow before first checkpoint reached
local vehroll_firstCheckpointPlayer = {}

local vehreroll_vehs = { -- [gamemode] = {car = {}, boat = {}, plane = {} }
	["Never the same"] = {
		["car"] = {	602, 545, 496, 517, 401, 410, 518, 600, 527, 436, 589, 580, 419, 439, 533, 549, 526, 491, 474, 445, 467, 604, 426, 507, 547, 585,
					405, 587, 409, 466, 550, 492, 566, 546, 540, 551, 421, 516, 529, 581, 510, 509, 522, 481, 461, 462, 448, 521, 468, 463, 586, 485, 552, 431, 
					438, 437, 574, 420, 525, 408, 416, 596, 433, 597, 427, 599, 490, 528, 601, 407, 428, 544, 523, 470, 598, 499, 588, 609, 403, 498, 514, 524,
					423, 532, 414, 578, 443, 486, 406, 531, 573, 456, 455, 459, 543, 422, 583, 482, 478, 605, 554, 530, 418, 572, 582, 413, 440, 536, 575, 534, 
					567, 535, 576, 412, 402, 542, 603, 475, 568, 557, 424, 471, 504, 495, 457, 539, 483, 508, 571, 500, 411, 515,
					444, 556, 429, 541, 559, 415, 561, 480, 560, 562, 506, 565, 451, 434, 558, 494, 555, 502, 477, 503, 579, 400, 404, 489, 505, 479, 442, 458
				},

		["plane"] = {592, 577, 511, 548, 512, 593, 425, 520, 417, 487, 553, 488, 497, 563, 476, 447, 519, 460, 469, 513},
		["boat"] = {472,473,493,595,484,430,453,452,446,454},
	},
	["Destruction derby"] = {
		["car"] = {602, 545, 496, 517, 401, 410, 518, 600, 527, 436, 589, 580, 419, 439, 533, 549, 526, 491, 474, 445, 467, 604, 426, 507, 547, 585,
					405, 587, 409, 466, 550, 492, 566, 546, 540, 551, 421, 516, 529, 581, 510, 509, 522, 481, 461, 462, 448, 521, 468, 463, 586, 485, 552, 431,
					438, 437, 574, 420, 525, 408, 416, 596, 433, 597, 427, 599, 490, 432, 528, 601, 407, 428, 544, 523, 470, 598, 499, 588, 609, 403, 498, 514, 524,
					423, 532, 414, 578, 443, 486, 406, 531, 573, 456, 455, 459, 543, 422, 583, 482, 478, 605, 554, 530, 418, 572, 582, 413, 440, 536, 575, 534,
					567, 535, 576, 412, 402, 542, 603, 475, 568, 557, 424, 471, 504, 495, 457, 483, 508, 571, 500,
					444, 556, 429, 411, 541, 559, 415, 561, 480, 560, 562, 506, 565, 451, 434, 558, 494, 555, 502, 477, 503, 579, 400, 404, 489, 505, 479, 442, 458
				},
	}
}
local vehreroll_disallowedVehicles = {[441] = true, [464] = true, [465] = true, [501] = true, [564] = true, [594] = true, [449] = true, [537] = true, [538] = true, [569] = true, [570] = true, [590] = true, [435] = true, [450] = true, [584] = true, [591] = true, [606] = true, [607] = true, [608] = true, [610] = true, [612] = true}




function loadVehicleReroll(player,bool)
	
	if bool then
		vehreroll_setBinds(player,bool)
	else
		vehreroll_setBinds(player,bool)
	end
end




function vehroll_raceState(state)

	if state == "Running" and vehreroll_vehs[exports.race:getRaceMode()] then
		if exports.race:getRaceMode() == "Never the same" then
			vehroll_firstcheckpoint = true
			vehroll_firstCheckpointPlayer = {}
		end

		playerRolledAmount = {}
		rerollPlayer = {}
		isRerollAllowed = true
	elseif state == "SomeoneWon" then -- exceptions here

		return

	else -- reset
		isRerollAllowed = false
		vehroll_firstcheckpoint = false
		vehroll_firstCheckpointPlayer = {}
	end
	
end
addEvent("onRaceStateChanging",true)
addEventHandler("onRaceStateChanging",root,vehroll_raceState)

function vehroll_handleCPReached(checkpoint)
	if vehroll_firstcheckpoint and checkpoint == 1 then
		vehroll_firstCheckpointPlayer[source] = true
	end
end
addEvent("onPlayerReachCheckpoint")
addEventHandler("onPlayerReachCheckpoint",root,vehroll_handleCPReached)



addCommandHandler( "rerollvehicle", function(player) if isKeyBound( player, "c", "down", rerollPlayerVehicle) then rerollPlayerVehicle(player) end end )
function rerollPlayerVehicle(player)
	if not isRerollAllowed then return end


	if 
		not player or 
		not isElement(player) or 
			getElementType(player) ~= "player" or
			getElementData(player,"state") ~= "alive" then 
		return 
	end

	if rerollPlayer[player] then
		if getTickCount() - rerollPlayer[player] < rerollIntervalTime then
			return
		end
	end

	if playerRolledAmount[player] and playerRolledAmount[player] >= maxRollsPerMap then
		outputChatBox("Maximum vehicle reroll per map reached ("..tostring(maxRollsPerMap)..")",player)
		return
	end

	if vehroll_firstcheckpoint and not vehroll_firstCheckpointPlayer[player] then return end

	local gm = exports.race:getRaceMode()
	local checkpoints
	if gm == "Never the same" then
		checkpoints = exports.race:getCheckPoints()
	else
		checkpoints = false
	end
	
	local vehicle = getPedOccupiedVehicle( player )

	local vehicleID = getElementModel(vehicle)
	if vehreroll_disallowedVehicles[vehicleID] then outputChatBox("Reroll not allowed with this vehicle.",player,255,0,0) return end

	local randomVehID = vehreroll_getRandomVehicleID(vehicleID, player, checkpoints)
	if not randomVehID then return end

	

	local isSet = exports.race:export_setPlayerVehicle( player, randomVehID )

	if isSet then
		rerollPlayer[player] = getTickCount()

		if playerRolledAmount[player] then
			playerRolledAmount[player] = playerRolledAmount[player] + 1
		else
			playerRolledAmount[player] = 1
		end
		-- output for root
		outputChatBox(getPlayerName(player).." #22FF00has rerolled his vehicle from " .. getVehicleNameFromModel(vehicleID) .. " to "..getVehicleName(vehicle)..". (Reroll GC perk) ",root,255,255,255,true)
	end

	return true
end

function vehreroll_setBinds(player,bool)
	if not player then return end

	if bool then
		bindKey(player,"c","down",rerollPlayerVehicle)
	else
		unbindKey( player, "c", "down", rerollPlayerVehicle )
	end
end

function vehreroll_getRandomVehicleID(ID, player, checkpoints)
	local gm = exports.race:getRaceMode()
	
	if gm == "Never the same" then
		local playerCP = getElementData(player, "race.checkpoint") - 1
		local cpType
		if playerCP == 0 then
			cpType = "none"
		else
			cpType = checkpoints[playerCP].nts
		end
		
		if cpType == "custom" then
			local models = tostring(checkpoints[playerCP].models)
			if not models then return false end
			local custom = {}
			local modelCount = 1
			for model in string.gmatch(models, "([^;]+)") do
				if tonumber(model) then
					if getVehicleNameFromModel(model) == "" then
						--outputDebugString("Model " .. model .. " not valid for checkpoint " .. checkpoint.id, 0, 255, 0, 213)
					else
						custom[modelCount] = tonumber(model)
						modelCount = modelCount + 1
					end
				end
			end
			if #custom == 0 then return false end
			local returnID
			for i=1, 10 do
				returnID = custom[math.random(1,#custom)]
				if returnID ~= ID then break end
			end
			return returnID
		else
			local vehType
			if cpType == "none" then
				vehType = vehreroll_getVehicleType(ID)
			elseif cpType == "vehicle" then
				vehType = "car"
			elseif cpType == "air" then
				vehType = "plane"
			end
			if not vehType then return false end
		
			if vehreroll_vehs[gm] and vehreroll_vehs[gm][vehType] then
				local theTable = vehreroll_vehs[gm][vehType]
				
				local returnID
				for i=1, 10 do
					returnID = theTable[math.random(1,#theTable)]
					if returnID ~= ID then break end
				end
				
				return returnID
			end
		end
	else
		local vehType = vehreroll_getVehicleType(ID)
		if not vehType then return false end
		
		
	
		if vehreroll_vehs[gm] and vehreroll_vehs[gm][vehType] then
			local theTable = vehreroll_vehs[gm][vehType]
			
			local returnID
			for i=1, 10 do
				returnID = theTable[math.random(1,#theTable)]
				if returnID ~= ID then break end
			end
			
			return returnID
		end
	end

	return false
end



	


function vehreroll_getVehicleType(vehicleID)
	if not vehicleID then return false end
	

	local boat = {430, 446, 452, 453, 454, 472, 473, 484, 493, 595}
	local plane = {460, 476, 511, 512, 513, 519, 520, 553, 577, 592, 593, 417, 425, 447, 469, 487, 488, 497, 548, 563}

	
	
	if not vehicleID then return false end

	for _,id in ipairs(boat) do
		if tonumber(id) == tonumber(vehicleID) then
			return "boat"
		end
	end

	for _,id in ipairs(plane) do
		if tonumber(id) == tonumber(vehicleID) then
			return "plane"
		end
	end

	return "car"
end



function disableReRoll()
	isRerollAllowed = false
end