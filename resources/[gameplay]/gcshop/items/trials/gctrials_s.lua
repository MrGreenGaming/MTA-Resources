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
	if on == '1' then
		setPerkSetting(player, ID, 'dont_flip', nil, 'GC Trials: Enabled flipping!')	-- nil so the value isn't added to the json string
	else
		setPerkSetting(player, ID, 'dont_flip', true, 'GC Trials: Disabled flipping')
	end
	triggerClientEvent(player, 'settingGCTrials', player, getPerkSettings(player, ID))
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