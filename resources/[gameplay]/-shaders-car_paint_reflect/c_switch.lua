--
-- c_switch.lua
--

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
--
--	To switch on:
--			triggerEvent( "switchCarPaintReflect", root, true )
--
--	To switch off:
--			triggerEvent( "switchCarPaintReflect", root, false )
--
----------------------------------------------------------------
----------------------------------------------------------------



--------------------------------
-- Switch effect on or off
--------------------------------
function switchCarPaintReflect( cprOn )
	-- outputDebugString( "switchCarPaintReflect: " .. tostring(cprOn) )
	if cprOn then
		startCarPaintReflect()
	else
		stopCarPaintReflect()
	end
end

addEvent( "switchCarPaintReflect", true )
addEventHandler( "switchCarPaintReflect", resourceRoot, switchCarPaintReflect )
