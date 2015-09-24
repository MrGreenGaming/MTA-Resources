-----------------
-- Items stuff --
-----------------

local ID = 5

function loadGCVoice ( player, bool, settings )
	if bool then
		setElementData(source, 'bCanUseVoice', true)
	else
		setElementData(player, 'bCanUseVoice', nil)
	end
end

