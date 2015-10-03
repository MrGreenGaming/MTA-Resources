cars = { 602, 545, 496, 517, 401, 410, 518, 600, 527, 436, 589, 580, 419, 439, 533, 549, 526, 491, 474, 445, 467, 604, 426, 507, 547, 585,
405, 587, 409, 466, 550, 492, 566, 546, 540, 551, 421, 516, 529, 581, 510, 509, 522, 481, 461, 462, 448, 521, 468, 463, 586, 485, 552, 431, 
438, 437, 574, 420, 525, 408, 416, 596, 433, 597, 427, 599, 490, 432, 528, 601, 407, 428, 544, 523, 470, 598, 499, 588, 609, 403, 498, 514, 524, 
423, 532, 414, 578, 443, 486, 406, 531, 573, 456, 455, 459, 543, 422, 583, 482, 478, 605, 554, 530, 418, 572, 582, 413, 440, 536, 575, 534, 
567, 535, 576, 412, 402, 542, 603, 475, 441, 464, 501, 465, 564, 568, 557, 424, 471, 504, 495, 457, 539, 483, 508, 571, 500, 
444, 556, 429, 411, 541, 559, 415, 561, 480, 560, 562, 506, 565, 451, 434, 558, 494, 555, 502, 477, 503, 579, 400, 404, 489, 505, 479, 442, 458, 594 }
planes = {592, 577, 511, 548, 512, 593, 425, 520, 417, 487, 553, 488, 497, 563, 476, 447, 519, 460, 469, 513}
boats = {472,473,493,595,484,430,453,452,446,454} 
--players = {}

addEvent('vehicleChanged', true)
addEventHandler('vehicleChanged', getRootElement(),
function(player, id)
	x,y,z = getElementPosition(source)
	setElementPosition(source, x,y,z+3)
	if id == 417 or id == 425 or id == 447 or id == 465 or id == 469 or id == 487 or id == 488 or id == 497 or id == 501 or id == 548 or id == 563 then --is helicopter
		triggerClientEvent(player, 'onHeliChange', player, source)
	end
end
)

function changeVehicle(vehicle, model, player)
	if model == "boat" then
		random = math.random(1, #boats)
		randomID = boats[random]
	elseif model == "plane" then
		random = math.random(1, #planes)
		randomID = planes[random]
	else random = math.random(1, #cars)
		randomID = cars[random]
	end
	--players[getVehicleOccupant(vehicle)] = randomID
	triggerEvent('vehicleChanged', vehicle, player, randomID)	
	setElementModel(vehicle, randomID)	
end

addEvent('onPlayerReachCheckpoint', true)
addEventHandler('onPlayerReachCheckpoint', getRootElement(),
function(cp)
	if (cp == 10) or (cp == 11) or (cp == 12) or (cp == 16) or (cp == 17) or (cp == 18) then
		changeVehicle(getPedOccupiedVehicle(source), "boat", source)
	elseif (cp == 20) or (cp == 21) or (cp == 22) then
		changeVehicle(getPedOccupiedVehicle(source), "plane", source)
	else changeVehicle(getPedOccupiedVehicle(source), "car", source)
	end
end
)

--[[addEventHandler('onVehicleEnter', getRootElement(),
function(thePlayer)
	if players[thePlayer] then
		x,y,z = getElementPosition(getPedOccupiedVehicle(thePlayer))
		setElementPosition(getPedOccupiedVehicle(thePlayer), x,y,z+3)
		setElementModel(getPedOccupiedVehicle(thePlayer), players[thePlayer])
	end
end
)]]

