addEventHandler("onResourceStart", root,
    function(resource)
		if (resourceRoot == source or getResourceName ( resource ) == 'scoreboard') then
			exports.scoreboard:scoreboardAddColumn("fps", root, 32, "FPS", 40)
		end
    end
)
addEventHandler("onResourceStop", getResourceRootElement(getThisResource()),
	function()
		exports.scoreboard:removeScoreboardColumn("fps", root, 35)
	end
)
