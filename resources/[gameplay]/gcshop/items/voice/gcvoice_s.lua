-----------------
-- Items stuff --
-----------------

local ID = 5

function loadGCVoice ( player, bool, settings )
	if bool then
		setElementData(player, 'bCanUseVoice', true)
	else
		setElementData(player, 'bCanUseVoice', nil)
	end
end

