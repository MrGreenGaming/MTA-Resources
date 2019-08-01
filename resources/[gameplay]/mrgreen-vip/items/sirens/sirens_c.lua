local sirenTable = {
	[411] = {
		[1] = {["color"]={255,0,0}, ["pos"]={-0.4,1.2,0.25}, ["phases"]={true,true,false,false}},
		[2] = {["color"]={0,0,255}, ["pos"]={0.4,1.2,0.25}, ["phases"]={false,false,true,true}},
	},
	[451] = {
		[1] = {["color"]={255,0,0}, ["pos"]={-0.4,0.8,0.25}, ["phases"]={true,false,false,true}},
		[2] = {["color"]={0,0,255}, ["pos"]={0.4,0.8,0.25}, ["phases"]={false,true,true,false}},
	},
	[415] = {
		[1] = {["color"]={255,0,0}, ["pos"]={-0.4,0.8,0.25}, ["phases"]={true,false,false,true}},
		[2] = {["color"]={0,0,255}, ["pos"]={0.4,0.8,0.25}, ["phases"]={false,true,true,false}},
	},
	[506] = {
		[1] = {["color"]={255,0,0}, ["pos"]={-0.4,0.7,0.25}, ["phases"]={true,true,false,false}},
		[2] = {["color"]={0,0,255}, ["pos"]={0.4,0.7,0.25}, ["phases"]={false,false,true,true}},
	},
	[495] = {
		[1] = {["color"]={255,0,0}, ["pos"]={-0.5,1,0.4}, ["phases"]={false,true,true,false}},
		[2] = {["color"]={0,0,255}, ["pos"]={0.5,1,0.4}, ["phases"]={true,false,false,true}},
	},
	[402] = {
		[1] = {["color"]={255,0,0}, ["pos"]={-0.4,0.7,0.25}, ["phases"]={false,false,true,true}},
		[2] = {["color"]={0,0,255}, ["pos"]={0.4,0.7,0.25}, ["phases"]={true,true,false,false}},
	},
	[541] = {
		[1] = {["color"]={255,0,0}, ["pos"]={-0.35,0.85,0.3}, ["phases"]={true,false,false,true}},
		[2] = {["color"]={0,0,255}, ["pos"]={0.35,0.85,0.3}, ["phases"]={false,true,true,false}},
	},
	[565] = {
		[1] = {["color"]={255,0,0}, ["pos"]={-0.4,0.8,0.25}, ["phases"]={true,true,false,false}},
		[2] = {["color"]={0,0,255}, ["pos"]={0.4,0.8,0.25}, ["phases"]={false,false,true,true}},
	},
	[560] = {
		[1] = {["color"]={255,0,0}, ["pos"]={-0.4,1,0.35}, ["phases"]={false,true,true,false}},
		[2] = {["color"]={0,0,255}, ["pos"]={0.4,1,0.35}, ["phases"]={true,false,false,true}},
	},
	[480] = {
		[1] = {["color"]={255,0,0}, ["pos"]={-0.4,0.45,0.25}, ["phases"]={false,false,true,true}},
		[2] = {["color"]={0,0,255}, ["pos"]={0.4,0.45,0.25}, ["phases"]={true,true,false,false}},
	},
	[559] = {
		[1] = {["color"]={255,0,0}, ["pos"]={-0.4,0.75,0.25}, ["phases"]={true,false,false,true}},
		[2] = {["color"]={0,0,255}, ["pos"]={0.4,0.75,0.25}, ["phases"]={false,true,true,false}},
	},
	[562] = {
		[1] = {["color"]={255,0,0}, ["pos"]={-0.4,0.75,0.35}, ["phases"]={true,true,false,false}},
		[2] = {["color"]={0,0,255}, ["pos"]={0.4,0.75,0.35}, ["phases"]={false,false,true,true}},
	},
	[429] = {
		[1] = {["color"]={255,0,0}, ["pos"]={-0.4,0.35,0.25}, ["phases"]={false,true,true,false}},
		[2] = {["color"]={0,0,255}, ["pos"]={0.4,0.35,0.25}, ["phases"]={true,false,false,true}},
	},
}

local playerSirens = {}

local globalTimer = false

local current = 0

-- const
local phases = 4


addEvent('vip_startSirenForPlayer', true)
addEventHandler('vip_startSirenForPlayer', root, 
function (player, status)
	if status then
		playerSirens[player] = true
	else
		local temp = playerSirens[player]
		
		if temp ~= true and temp.active then
			local sirens = playerSirens[player].active
			local dummies = playerSirens[player].dummies
			
			playerSirens[player] = nil
			
			if sirens then
				for i, s in ipairs(sirens) do
					if s then
						destroyCorona(s)
						destroyElement(dummies[i])
					end
				end
			end	
		else
			playerSirens[player] = nil
		end
	end
end)


function timer()
	current = current + 1
	
	if current > phases then
		current = 1
	end
		
	local playerVeh = false
	local vehID = false
	
	local activeSirens = {}
	
	local siren = false
	
	local temp = nil
	
	for i,p in ipairs(getElementsByType("player")) do
		activeSirens = {}
		if playerSirens[p] then
			playerVeh = getPedOccupiedVehicle(p)
		
			if playerVeh then
				vehID = getElementModel(playerVeh)
				
				if isVehicleCompatible(vehID) then
					
					if playerSirens[p] == true or playerSirens[p]["vehicle"] ~= vehID then
						temp = playerSirens[p]
						if temp ~= true and temp["active"] then
							for c, s in ipairs(playerSirens[p].active) do
								if s then
									destroyElement(playerSirens[p].dummies[c])
									destroyCorona(s)
								end
							end
						end
					
						playerSirens[p] = {["vehicle"]=vehID,["active"]={},["dummies"]={}}
						
						for v=1,#sirenTable[vehID] do
							table.insert(playerSirens[p].active, false)
							table.insert(playerSirens[p].dummies, false)
						end
					end
					
					for c, s in ipairs(sirenTable[vehID]) do
						if s.phases[current] then
							activeSirens[c] = true
						end
					end
					
					for c, s in ipairs(playerSirens[p].active) do
						if s then
							if not activeSirens[c] then
								destroyCorona(s)
								
								destroyElement(playerSirens[p].dummies[c])
								playerSirens[p].dummies[c] = false
								
								playerSirens[p].active[c] = false
							end
						else
							if activeSirens[c] then
								siren = createCorona(0,0,0,0.5,sirenTable[vehID][c].color[1],sirenTable[vehID][c].color[2],sirenTable[vehID][c].color[3],255,false)
								local dummy = createMarker(0,0,0,"cylinder",0.1)
								setElementAlpha(dummy, 0)
								playerSirens[p].dummies[c] = dummy
								attachElements(dummy, playerVeh, sirenTable[vehID][c].pos[1], sirenTable[vehID][c].pos[2], sirenTable[vehID][c].pos[3])
								playerSirens[p].active[c] = siren
							end
						end
					end
				else
					temp = playerSirens[p]
					
					if temp ~= true and temp["active"] then
						for c, s in ipairs(playerSirens[p].active) do
							if s then
								destroyElement(playerSirens[p].dummies[c])
								destroyCorona(s)
								playerSirens[p].active[c] = false
							end
						end
					end
				end
			end
		end
	end
end

addEventHandler('onClientPreRender', root,
function() 
pcall( -- pcall so lua stops spamming some bs errors
	function() 
		for i, p in ipairs(getElementsByType('player')) do
			if p and playerSirens[p] and type(playerSirens[p]["active"]) ~= nil then
				local vehicle = getPedOccupiedVehicle(p)
				if vehicle then
					local vehID = getElementModel(vehicle)
					if isVehicleCompatible(vehID) then						
						for c, s in ipairs(playerSirens[p].active) do
							if s then
								local x,y,z = getElementPosition(playerSirens[p].dummies[c])
								setCoronaPosition(s, x, y, z)
							end
						end
					end
				end
			end
		end
	end)
end)

function isVehicleCompatible(vehicleid)
	if not sirenTable[vehicleid] or sirenTable[vehicleid] == false or sirenTable[vehicleid] == nil then return false else return true end
end

addEventHandler('onClientResourceStart', resourceRoot, 
function()
	globalTimer = setTimer(timer, 100, 0)
end)

addEventHandler('onClientResourceStop', resourceRoot,
function()
	for i, p in ipairs(getElementsByType('player')) do
		pcall(function(p)
			if playerSirens[p] and playerSirens[p]["active"] then
				for c, s in ipairs(playerSirens[p].active) do
					if s then
						destroyCorona(s)
					end
				end
			end
		end, p)
	end
end)


