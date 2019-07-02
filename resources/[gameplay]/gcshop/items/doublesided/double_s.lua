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
	setPerkSetting(player, ID, 'disabled', on == '1' and nil or true)
	if on == '1' then
		setPerkSetting(player, ID, 'disabled', nil, 'GC Double Sided: Enabled')	-- nil so the value isn't added to the json string
	else
		setPerkSetting(player, ID, 'disabled', true, 'GC Double Sided: Disabled')
	end
	getPerkSettings(player, ID, 
	function(perkSetting) 
		triggerClientEvent(player, 'settingDoubleSided', player, perkSetting)
	end)
end
