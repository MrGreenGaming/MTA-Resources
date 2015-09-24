addEventHandler("onResourceStart", root,
    function(resource)
		if (resourceRoot == source or getResourceName ( resource ) == 'scoreboard') then
			exports.scoreboard:addScoreboardColumn("fps", root, 35)
		end
    end
)
addEventHandler("onResourceStop", getResourceRootElement(getThisResource()),
	function()
		exports.scoreboard:removeScoreboardColumn("fps", root, 35)
	end
)
