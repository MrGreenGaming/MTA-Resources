local models = {
	["13101"] = {
		col = "countrye_3.col",
	},
}

addEventHandler("onClientResourceStart", resourceRoot, function()
	setTimer(function()
		for id, data in pairs(models) do
			local n = tonumber(id)
			engineReplaceCOL(engineLoadCOL(data.col, n), n)
		end
	end, 1000, 1)
end)
