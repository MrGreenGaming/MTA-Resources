function addScoreboard(resource)
    if (resourceRoot == source or getResourceName(resource) == "scoreboard") then
        exports.scoreboard:scoreboardAddColumn("controller", root, 12, "", 1.6)
    end
end
addEventHandler("onResourceStart", root, addScoreboard)

function removeScoreboard()
    exports.scoreboard:removeScoreboardColumn("controller")
end
addEventHandler("onResourceStop", resourceRoot, removeScoreboard)
