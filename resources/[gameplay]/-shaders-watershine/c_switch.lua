--
-- c_switch.lua
--

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
--
--	To switch on:
--			triggerEvent( "switchWaterShine", root, true )
--
--	To switch off:
--			triggerEvent( "switchWaterShine", root, false )
--
----------------------------------------------------------------
----------------------------------------------------------------


--------------------------------
-- Switch effect on or off
--------------------------------
function switchWaterShine( wsOn )
	-- outputDebugString( "switchWaterShine: " .. tostring(wsOn) )
	if wsOn then
		startWaterShine()
	else
		stopWaterShine()
	end
end

addEvent( "switchWaterShine", true )
addEventHandler( "switchWaterShine", resourceRoot, switchWaterShine )
