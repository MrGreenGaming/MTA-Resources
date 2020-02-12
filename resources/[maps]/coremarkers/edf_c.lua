function onStart() --Callback triggered by EDF
	engineImportTXD( engineLoadTXD(":coremarkers/crate.txd"), 3798)
end

addEventHandler( "onClientElementStreamIn", root,
    function()
		if getElementModel(source) == 3798 then
			setObjectScale(source, 0.6)
		end
    end
)