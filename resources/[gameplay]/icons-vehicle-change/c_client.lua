local signs = {
	-- checkpoint { vehType: String, cpType: String showSign: boolean, x, y, z: int, guiImage}
}
local cpIds = {}
local enabled = true

local drawDistance = 300


local screenSizeX, screenSizeY = guiGetScreenSize()
local guiX = screenSizeX * 0.1
local guiY = screenSizeX * 0.1
local globalScale = 5
local globalAlpha = .50
local checkpoints
local playerZCoord

function renderIcons()
	for i, cpId in ipairs(cpIds) do
		if signs[cpId].showSign and signs[cpId].z and enabled then
			local playerx, playery, playerz = getCameraMatrix()
			local dist = getDistanceBetweenPoints3D(signs[cpId].x, signs[cpId].y, signs[cpId].z, playerx, playery, playerz)
			if dist < drawDistance and (isLineOfSightClear(signs[cpId].x, signs[cpId].y, signs[cpId].z+3, playerx, playery, playerz, true, false, false, false)) then
				local screenX, screenY;

				if (signs[cpId].cpType == false or signs[cpId].cpType == "checkpoint") then
					-- Checkpoint is a default checkpoint in which the height doesn't matter. The icon is relative to the player's height
					local playerX, playerY, playerZ = getElementPosition(localPlayer)
                    if playerZCoord then
						playerZ = playerZCoord
					end
					screenX, screenY = getScreenFromWorldPosition(signs[cpId].x, signs[cpId].y, playerZ + 1)
					dxDrawTextOnElement(signs[cpId].x, signs[cpId].y, playerZ - 2, signs[cpId].name)
				else
					-- This is a checkpoint in which the height does matter. The icon is relative to the checkpoint's position
					screenX, screenY = getScreenFromWorldPosition(signs[cpId].x, signs[cpId].y, signs[cpId].z+3)
					dxDrawTextOnElement(signs[cpId].x, signs[cpId].y, signs[cpId].z, signs[cpId].name)
				end

				if (screenX and screenY) then
					local scaled = screenSizeX * (1/(2*(dist+5))) * 0.6
					local relx, rely = scaled * globalScale, scaled * globalScale
					guiSetAlpha(signs[cpId].guiImage, globalAlpha)
					guiSetSize(signs[cpId].guiImage, relx, rely, false)
					guiSetPosition(signs[cpId].guiImage, screenX - (relx / 2), screenY, false)
					guiSetVisible(signs[cpId].guiImage, true)

				else
					guiSetVisible(signs[cpId].guiImage, false)
				end
			else 
				guiSetVisible(signs[cpId].guiImage, false)
			end
		else
			guiSetVisible(signs[cpId].guiImage, false)
		end
	end
end
addEventHandler("onClientRender", root, renderIcons)

function setSigns(index, position, vehType, name, cpType)
	if vehType == "Monster Truck" then vehType = "MonsterTruck" end

	table.insert(cpIds, index)
	signs[index] = {}
	signs[index].vehType = vehType
	signs[index].cpType = cpType
	signs[index].name = name
	signs[index].x = position[1]
	signs[index].y = position[2]
	signs[index].z = position[3]
	signs[index].guiImage = guiCreateStaticImage(0, 0, guiX, guiY, "./icons/" .. vehType ..".png", false)
	guiSetVisible(signs[index].guiImage, false)

	if index <= 1 then signs[index].showSign = true
	else signs[index].showSign = false
	end
end
addEvent("setSign", true)
addEventHandler("setSign", root, setSigns)

function showSign(index)
	if signs[index] then
		signs[index].showSign = true
	end
end
addEvent("showSign", true)
addEventHandler("showSign", root, showSign)

function hideSign(index)
	if signs[index] then
		signs[index].showSign = false
	end
end
addEvent("hideSign", true)
addEventHandler("hideSign", root, hideSign)

function deleteSigns()
	for i, cpId in ipairs(cpIds) do
		guiSetVisible(signs[cpId].guiImage, false)
	end
	signs = {}
	cpIds = {}
end
addEvent("deleteSigns", true)
addEventHandler("deleteSigns", root, deleteSigns)


function dxDrawTextOnElement(x, y, z,text,size,height,distance,R,G,B,alpha,font,...)
	local x2, y2, z2 = getCameraMatrix()
	z = z + 1
	local distance = distance or drawDistance
	local height = height or -1

	if (isLineOfSightClear(x, y, z+2, x2, y2, z2, ...)) then
		local sx, sy = getScreenFromWorldPosition(x, y, z+height)
		if(sx) and (sy) then
			local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
			if(distanceBetweenPoints < distance) then
				dxDrawText(text, sx+2, sy+2, sx, sy, tocolor(R or 255, G or 255, B or 255, alpha or (255 * 0.65)), (size or 1)-(distanceBetweenPoints / distance), font or "pricedown", "center", "center")
			end
		end
	end
end

function enableCPNextVehicleInfoUI()
	enabled = true
end

function disableCPNextVehicleInfoUI()
	enabled = false
end

addEvent("onClientMapStarting", true)
function onClientMapStarting()
	checkpoints = exports.race:getCheckPoints()
	playerZCoord = nil
end
addEventHandler("onClientMapStarting", root, onClientMapStarting)

addEvent("showVehChangeIcon", true)
function showVehChangeIcon()
	setTimer(function()
		local player = false
		local target = getCameraTarget(localPlayer)
		if target and getElementType(target) == "vehicle" then
			player = getVehicleOccupant(target)
		elseif target and getElementType(target) == "player" then
			player = target
		end
		if player and player ~= localPlayer then
			local cp = getElementData(player, "race.checkpoint")
			if cp then
				checkpoints = exports.race:getCheckPoints()
				for i, checkpoint in ipairs(checkpoints) do
					triggerEvent("hideSign", root, i)
				end
				local x, y, z = getElementPosition(player)
				playerZCoord = z
				triggerEvent("showSign", root, cp)
			end
			unbindKey("arrow_l", "down", showVehChangeIcon)
			unbindKey("arrow_r", "down", showVehChangeIcon)
			bindKey("arrow_l", "down", showVehChangeIcon)
			bindKey("arrow_r", "down", showVehChangeIcon)
		else
			playerZCoord = nil
			unbindKey("arrow_l", "down", showVehChangeIcon)
			unbindKey("arrow_r", "down", showVehChangeIcon)
		end
	end, 100, 1)
end
addEventHandler("showVehChangeIcon", root, showVehChangeIcon)
addCommandHandler("s", showVehChangeIcon)
addCommandHandler("spec", showVehChangeIcon)
addCommandHandler("spectate", showVehChangeIcon)
addCommandHandler("Toggle spectator", showVehChangeIcon)
addCommandHandler("afk", showVehChangeIcon)
bindKey("enter", "down", showVehChangeIcon)

addEvent("updateIconsPosition", true)
function updateIconsPosition(zPos)
	if zPos then
		playerZCoord = zPos
	end
end
addEventHandler("updateIconsPosition", root, updateIconsPosition)
