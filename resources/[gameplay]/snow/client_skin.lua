addEventHandler('onClientResourceStart', getResourceRootElement(),
function()
	  setTimer(function ()
    engineImportTXD(engineLoadTXD("SantaClaus.txd", true), 1)
    engineReplaceModel(engineLoadDFF("SantaClaus.dff", 0), 1)
    end, 1000, 1)
end
)