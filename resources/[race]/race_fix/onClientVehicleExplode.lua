math.randomseed( getTickCount() )

local FireLifetime = 30000

function createPostExplosionEffect(vehicle)
local x, y, z = getElementPosition(vehicle)
local z = getGroundPosition(x, y, z)

local effects = {}
effects[1] = createEffect("fire", x, y, z-math.random(0.4, 1.2), 0, 0, 0, 100)

effects[2] = createEffect("fire", x+math.random(0.1, 2.0), y+math.random(0.1, 2.0), z-math.random(0.4, 1.2), 0, 0, 0, 100)
effects[3] = createEffect("fire", x+math.random(0.1, 2.0), y-math.random(0.1, 2.0), z-math.random(0.4, 1.2), 0, 0, 0, 100)
effects[4] = createEffect("fire", x-math.random(0.1, 2.0), y+math.random(0.1, 2.0), z-math.random(0.4, 1.2), 0, 0, 0, 100)
effects[5] = createEffect("fire", x-math.random(0.1, 2.0), y-math.random(0.1, 2.0), z-math.random(0.4, 1.2), 0, 0, 0, 100)

effects[6] = createEffect("fire", x-math.random(0.1, 2.0), y, z-math.random(0.4, 1.2), 0, 0, 0, 100)
effects[7] = createEffect("fire", x+math.random(0.1, 2.0), y, z-math.random(0.4, 1.2), 0, 0, 0, 100)
effects[8] = createEffect("fire", x, y-math.random(0.1, 2.0), z-math.random(0.4, 1.2), 0, 0, 0, 100)
effects[9] = createEffect("fire", x, y+math.random(0.1, 2.0), z-math.random(0.4, 1.2), 0, 0, 0, 100)

setTimer(function() 
			for k, effect in ipairs(effects) do  
				setTimer(function() if isElement(effect) then destroyElement(effect) end end, math.random(10000), 1)
			end 
		end, FireLifetime, 1)

end

addEvent("createPostExplosionEffect", true)
addEventHandler("createPostExplosionEffect", root, createPostExplosionEffect)



addEvent("onClientMapStarting")
addEventHandler("onClientMapStarting", root, 
function()
	for k, effect in ipairs(getElementsByType"effect") do
		destroyElement(effect)
	end
end
)