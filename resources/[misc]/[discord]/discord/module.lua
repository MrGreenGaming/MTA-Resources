
addEventHandler("onResourceStart", resourceRoot,
    function ()
        local found = false

        for index, module in pairs(getLoadedModules()) do
            if module:find("ml_sockets", 1, true) then
                found = true
                break
            end
        end

        if not found then
            outputServerLog("Module 'ml_sockets' not found, please install.")
            cancelEvent()
            return
        end

        local configFile = fileOpen("config.json")
        local config = fileRead(configFile, fileGetSize(configFile))
        fileClose(configFile)
        config = fromJSON(config)
        if not config then
            outputServerLog("Could not parse config.json")
            cancelEvent()
            return
        end
        createSocketFromConfig(config)
    end,
false, "high+9")
