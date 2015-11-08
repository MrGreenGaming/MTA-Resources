-----------------
-- Items stuff --
-----------------

local ID = 9

function loadDoubleSided ( player, bool, settings )
	triggerClientEvent(player, 'loadDoubleSided', player, bool, settings)
	if bool then
		addCommandHandler('doublesided', setDoubleSided)
	else
		removeCommandHandler('doublesided', setDoubleSided)
	end
end

function setDoubleSided ( player, cmd, on )
	if on == '1' then
		setPerkSetting(player, ID, 'disabled', nil, 'GC Double Sided: Enabled')	-- nil so the value isn't added to the json string
	else
		setPerkSetting(player, ID, 'disabled', true, 'GC Double Sided: Disabled')
	end
	triggerClientEvent(player, 'settingDoubleSided', player, getPerkSettings(player, ID))
end
