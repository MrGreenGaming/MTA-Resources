--
-- c_switch.lua
--

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
--
--	To switch on:
--			triggerEvent( "switchBloom", root, true )
--
--	To switch off:
--			triggerEvent( "switchBloom", root, false )
--
----------------------------------------------------------------
----------------------------------------------------------------


--------------------------------
-- Switch effect on or off
--------------------------------
function switchBloom( blOn )
	-- outputDebugString( "switchBloom: " .. tostring(blOn) )
	if blOn then
		enableBloom()
	else
		disableBloom()
	end
end

addEvent( "switchBloom", true )
addEventHandler( "switchBloom", resourceRoot, switchBloom )
