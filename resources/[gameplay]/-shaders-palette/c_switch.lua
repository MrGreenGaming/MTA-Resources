--
-- c_switch.lua
--

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
--
--	To switch on:
--			triggerEvent( "switchPalette", root, true )
--
--	To switch off:
--			triggerEvent( "switchPalette", root, false )
--
----------------------------------------------------------------
----------------------------------------------------------------



--------------------------------
-- Switch effect on or off
--------------------------------
function switchPalette( pOn )
	-- outputDebugString( "switchPalette: " .. tostring(pOn) )
	if pOn then
		enablePalette()
	else
		disablePalette()
	end
end
addEvent( "switchPalette", true )
addEventHandler( "switchPalette", resourceRoot, switchPalette )


