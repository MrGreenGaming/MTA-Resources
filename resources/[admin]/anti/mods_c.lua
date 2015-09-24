
GUIEditor = {
    gridlist = {},
    window = {},
    label = {}
}
addEventHandler("onClientResourceStart", resourceRoot,
    function()
        GUIEditor.window[1] = guiCreateWindow(0.20, 0.37, 0.59, 0.57, "MODDED FILES DETECTED", true)
        guiSetVisible( GUIEditor.window[1], false )
        guiWindowSetSizable(GUIEditor.window[1], false)

        GUIEditor.label[1] = guiCreateLabel(0.00, 0.06, 1.00, 0.14, "You have modded files.\nUnless you remove all files in this list, you can not play here.", true, GUIEditor.window[1])
        guiSetFont(GUIEditor.label[1], "default-bold-small")
        guiLabelSetColor(GUIEditor.label[1], 255, 0, 0)
        guiLabelSetHorizontalAlign(GUIEditor.label[1], "center", false)
        GUIEditor.gridlist[1] = guiCreateGridList(0.07, 0.24, 0.88, 0.69, true, GUIEditor.window[1])
        guiGridListAddColumn(GUIEditor.gridlist[1], "Modified Files", 0.9)    
    end
)

addEvent("displayModdedPlayer",true)
function triggerModdedState(modTable)
    
    for f,u in pairs(modTable) do
        local row = guiGridListAddRow( GUIEditor.gridlist[1] )
        guiGridListSetItemText( GUIEditor.gridlist[1], row, 1, tostring(u), false, false )
        outputConsole("Modded file: "..tostring(u))
    end
    guiSetVisible( GUIEditor.window[1], true )
    showCursor(true)
    guiGridListSetScrollBars(GUIEditor.gridlist[1],true,true)
end
addEventHandler("displayModdedPlayer",resourceRoot,triggerModdedState)