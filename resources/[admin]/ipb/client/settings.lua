
g_Settings = {}

addEvent("ipb.syncSettings", true)
addEventHandler("ipb.syncSettings", localPlayer,
    function (settings)
        g_Settings = settings
    end,
false)

addEvent("ipb.updateSetting", true)
addEventHandler("ipb.updateSetting", resourceRoot,
    function (name, value)
        g_Settings[name] = value
    end,
false)
