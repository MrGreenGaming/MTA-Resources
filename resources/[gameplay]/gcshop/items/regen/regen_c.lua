function addCarHealth ( addition )
	local car = source
	if not isElement(car) then return end
	local x = getElementHealth(car)
	setElementHealth(car, math.min(addition + x, 1000))  --105/100 = 5% addition
end
addEvent('addCarHealth', true)
addEventHandler('addCarHealth', root, addCarHealth)
