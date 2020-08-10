-----------------
-- Items stuff --
-----------------

local ID = 1

function loadGCTrials ( player, bool, settings )
	triggerClientEvent(player, 'loadGCTrials', player, bool, settings)
	if bool then
		addCommandHandler('trials', setTrials)
	else
		removeCommandHandler('trials', setTrials)
	end
end


------------------
-- Trials stuff --
------------------

function setTrials ( player, cmd, on )
	local value = true
	if on == '1' then value = nil end
	setPerkSetting(player, ID, 'dont_flip', value, value and _.For(player, 'GC Trials: Disabled flipping') or _.For(player, 'GC Trials: Enabled flipping'),
	function()
		getPerkSettings(player, ID,
		function(settings)
			triggerClientEvent(player, 'settingGCTrials', player, settings)
		end)
	end)
end

function doTrickAnimation ( block, name, loop, timeMs )
	block = block or nil;
	name = name or nil;
	loop = loop or false;
	timeMs = timeMs or -1

	setPedAnimation( source, block, name, timeMs, loop, false, false );
end
addEvent( 'doTrickAnimation', true );
addEventHandler( 'doTrickAnimation', root, doTrickAnimation)
