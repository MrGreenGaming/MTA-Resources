GUIEditor = {
    tab = {},
    staticimage = {},
    edit = {},
    window = {},
    label = {},
    tabpanel = {},
    checkbox = {},
    button = {},
    scrollpane = {},
    scrollbar = {},
    combobox = {}
}
addEventHandler("onClientResourceStart", resourceRoot,
    function()
local screenW, screenH = guiGetScreenSize()
        GUIEditor.window[1] = guiCreateWindow((screenW - 586) / 2, (screenH - 500) / 2, 586, 500, "Settings", false)
        guiWindowSetSizable(GUIEditor.window[1], false)

        GUIEditor.tabpanel[1] = guiCreateTabPanel(9, 19, 567, 450, false, GUIEditor.window[1])

        GUIEditor.tab[1] = guiCreateTab("Visual Settings", GUIEditor.tabpanel[1])


        GUIEditor.label[1] = guiCreateLabel(36, 32, 511, 32, "Please note that changing these options can reduce your FPS or even crash your game. You should only enable these options if your computer can handle powerful graphics.", false, GUIEditor.tab[1])
        guiLabelSetHorizontalAlign(GUIEditor.label[1], "left", true)
        GUIEditor.checkbox["bloom"] = guiCreateCheckBox(36, 74, 15, 15, "", false, false, GUIEditor.tab[1])
        GUIEditor.checkbox["contrast"] = guiCreateCheckBox(36, 99, 15, 15, "", false, false, GUIEditor.tab[1])
        GUIEditor.checkbox["radar"] = guiCreateCheckBox(36, 124, 15, 15, "", false, false, GUIEditor.tab[1])
        GUIEditor.checkbox["water"] = guiCreateCheckBox(36, 149, 15, 15, "", false, false, GUIEditor.tab[1])
        GUIEditor.checkbox["chromewheels"] = guiCreateCheckBox(36, 174, 15, 15, "", false, false, GUIEditor.tab[1])



        GUIEditor.label[2] = guiCreateLabel(36, 237+85, 222, 15, "Set Draw Distance (100 - 10000)", false, GUIEditor.tab[1])
        setTooltip(GUIEditor.label[2], "This number represents how far out you can look into the game world. Increasing it may cause low FPS!")
        GUIEditor.edit["drawdistance"] = guiCreateEdit(36, 256+85, 81, 24, "", false, GUIEditor.tab[1])
        guiEditSetMaxLength( GUIEditor.edit["drawdistance"], 5 )
        guiSetProperty(GUIEditor.edit["drawdistance"], "ValidationString", "^[0-9]*$")
        GUIEditor.button["drawdistance"] = guiCreateButton(36+85, 256+85, 33, 25, "OK", false, GUIEditor.tab[1])
        guiSetProperty(GUIEditor.button["drawdistance"], "NormalTextColour", "FFAAAAAA")
  


        GUIEditor.label["lodrange"] = guiCreateLabel(36, 237+133, 222, 15, "Set LOD range (1 - 300), 0 to disable", false, GUIEditor.tab[1])
        setTooltip(GUIEditor.label["lodrange"], "This number represents how far out you can look into the game world. Increasing it may cause low FPS!")
        GUIEditor.edit["lodrange"] = guiCreateEdit(36, 256+133, 81, 24, "", false, GUIEditor.tab[1])
        guiEditSetMaxLength( GUIEditor.edit["lodrange"], 5 )
        guiSetProperty(GUIEditor.edit["lodrange"], "ValidationString", "^[0-9]*$")
        GUIEditor.button["lodrange"] = guiCreateButton(36+85, 256+133, 33, 25, "OK", false, GUIEditor.tab[1])
        guiSetProperty(GUIEditor.button["lodrange"], "NormalTextColour", "FFAAAAAA")
      

        GUIEditor.label["bloom"] = guiCreateLabel(72, 75, 209, 14, "Enable Bloom", false, GUIEditor.tab[1])

        GUIEditor.label["fpslimit"] = guiCreateLabel(292, 272, 222, 15, "Set client FPS Limit (25 - 100)", false, GUIEditor.tab[1])
        GUIEditor.edit["fpslimit"] = guiCreateEdit(292, 272+19, 81, 24, "", false, GUIEditor.tab[1])
        guiEditSetMaxLength( GUIEditor.edit["fpslimit"], 3 )
        guiSetProperty(GUIEditor.edit["fpslimit"], "ValidationString", "^[0-9]*$")

        GUIEditor.button["fpslimit"] = guiCreateButton(292+85, 272+19, 33, 25, "OK", false, GUIEditor.tab[1])
        guiSetProperty(GUIEditor.button["fpslimit"], "NormalTextColour", "FFAAAAAA")
		
		GUIEditor.label["fpslimitboats"] = guiCreateLabel(292, 290+30, 222, 15, "Set client FPS Limit for boats (25 - 100)", false, GUIEditor.tab[1])
		setTooltip(GUIEditor.label["fpslimitboats"], "Boats may slide or swim badly with FPS >50!")
        GUIEditor.edit["fpslimitboats"] = guiCreateEdit(292, 310+30, 81, 24, "", false, GUIEditor.tab[1])
        guiEditSetMaxLength( GUIEditor.edit["fpslimitboats"], 3 )
        guiSetProperty(GUIEditor.edit["fpslimitboats"], "ValidationString", "^[0-9]*$")

        GUIEditor.button["fpslimitboats"] = guiCreateButton(292+85, 310+30, 33, 25, "OK", false, GUIEditor.tab[1])
        guiSetProperty(GUIEditor.button["fpslimitboats"], "NormalTextColour", "FFAAAAAA")

        GUIEditor.label["hdr"] = guiCreateLabel(72, 100, 209, 14, "Enable Contrast HDR", false, GUIEditor.tab[1])
        setTooltip(GUIEditor.label["hdr"],"This applies a 'High Dynamic Range' contrast effect.")

        GUIEditor.label["radar"] = guiCreateLabel(72, 124, 209, 14, "Enable Radar Shader", false, GUIEditor.tab[1])
        setTooltip(GUIEditor.label["radar"],"This shader only works with the old radar.")

        GUIEditor.label["water"] = guiCreateLabel(72, 150, 209, 14, "Enable Water Shader", false, GUIEditor.tab[1])
        GUIEditor.label["chromewheels"] = guiCreateLabel(72, 175, 209, 14, "Enable Chrome Wheels", false, GUIEditor.tab[1])

        GUIEditor.label[8] = guiCreateLabel(36, 3, 511, 29, "Visual Settings", false, GUIEditor.tab[1])
        guiSetFont(GUIEditor.label[8], "default-bold-small")
        guiLabelSetHorizontalAlign( GUIEditor.label[8], "center" )
        guiLabelSetVerticalAlign( GUIEditor.label[8], "center" )

        GUIEditor.staticimage[1] = guiCreateStaticImage(281, 75, 1, 290, "img/dot_white.png", false, GUIEditor.tab[1])
        GUIEditor.checkbox["palette"] = guiCreateCheckBox(36, 199, 15, 15, "", false, false, GUIEditor.tab[1])
        GUIEditor.label["palette"] = guiCreateLabel(72, 199, 209, 14, "Enable ENB Palette", false, GUIEditor.tab[1])
        setTooltip(GUIEditor.label["palette"],"This enables an ENB effect.")


        GUIEditor.checkbox["btwheels"] = guiCreateCheckBox(36, 224, 15, 15, "", false, false, GUIEditor.tab[1])
        GUIEditor.label["btwheels"] = guiCreateLabel(72, 224, 209, 14, "Enable BT Wheels", false, GUIEditor.tab[1])
        setTooltip(GUIEditor.label["btwheels"],"This enables Bob_Taylor's wheels mods (and will disable any other wheel mods).")

        GUIEditor.checkbox["recordghost"] = guiCreateCheckBox(36, 249, 15, 15, "", false, false, GUIEditor.tab[1])
        GUIEditor.label["recordghost"] = guiCreateLabel(72, 249, 209, 14, "Enable Ghost Recording", false, GUIEditor.tab[1])
        setTooltip(GUIEditor.label["recordghost"],"This enables the recording of your cars, so that it can be viewed later on.")

        GUIEditor.checkbox["localghost"] = guiCreateCheckBox(36, 274, 15, 15, "", false, false, GUIEditor.tab[1])
        GUIEditor.label["localghost"] = guiCreateLabel(72, 274, 209, 14, "Enable Local Ghost", false, GUIEditor.tab[1])
        setTooltip(GUIEditor.label["localghost"],"This makes a ghost car appear, driving your best time on the map.")

        GUIEditor.checkbox["bestghost"] = guiCreateCheckBox(36, 299, 15, 15, "", false, false, GUIEditor.tab[1])
        GUIEditor.label["bestghost"] = guiCreateLabel(72, 299, 209, 14, "Enable Best Ghost", false, GUIEditor.tab[1])
        setTooltip(GUIEditor.label["bestghost"],"This makes a ghost car appear, driving the top 1 time on the map.")


        GUIEditor.checkbox["dof"] = guiCreateCheckBox(292, 75, 15, 15, "", false, false, GUIEditor.tab[1])
        GUIEditor.label["dof"] = guiCreateLabel(324, 75, 209, 14, "Enable Depth of Field", false, GUIEditor.tab[1])
        setTooltip(GUIEditor.label["dof"],"Makes MTA have depth. (blurs far away objects)")

        GUIEditor.checkbox["radialblur"] = guiCreateCheckBox(292, 100, 15, 15, "", false, false, GUIEditor.tab[1])
        GUIEditor.label["radialblur"] = guiCreateLabel(324, 100, 209, 14, "Enable Radial Blur", false, GUIEditor.tab[1])
        setTooltip(GUIEditor.label["radialblur"],"Makes the screen blurry when moving.")

        GUIEditor.label["skybox"] = guiCreateLabel(324, 125, 209, 14, "Enable Sky Box", false, GUIEditor.tab[1])
        GUIEditor.checkbox["skybox"] = guiCreateCheckBox(292, 125, 15, 15, "", false, false, GUIEditor.tab[1])
        GUIEditor.combobox["skybox"] = guiCreateComboBox(292, 125+19, 136, 65, "", false, GUIEditor.tab[1])
        guiComboBoxAddItem(GUIEditor.combobox["skybox"], "Dynamic Sky")
        guiComboBoxAddItem(GUIEditor.combobox["skybox"], "SkyBox 2")
        guiComboBoxSetSelected(GUIEditor.combobox["skybox"], 0)

        GUIEditor.checkbox["carpaint"] = guiCreateCheckBox(292, 174, 15, 15, "", false, false, GUIEditor.tab[1])
        GUIEditor.label["carpaint"] = guiCreateLabel(324, 174, 209, 14, "Enable Car Paint Shader", false, GUIEditor.tab[1])
        GUIEditor.combobox["carpaint"] = guiCreateComboBox(292, 174+19, 136, 65, "", false, GUIEditor.tab[1])
        guiComboBoxAddItem(GUIEditor.combobox["carpaint"], "Car Paint 1")
        guiComboBoxAddItem(GUIEditor.combobox["carpaint"], "Car Paint 2")
        guiComboBoxSetSelected(GUIEditor.combobox["carpaint"], 0)



        GUIEditor.checkbox["nitro"] = guiCreateCheckBox(292, 223, 15, 15, "", false, false, GUIEditor.tab[1])
        GUIEditor.label["nitro"] = guiCreateLabel(324, 223, 209, 14, "Enable Nitro Color", false, GUIEditor.tab[1])
        GUIEditor.button["nitro"] = guiCreateButton(292, 223+19, 150, 25, "Set Nitro Color", false, GUIEditor.tab[1]) 

        NitroColorImage = guiCreateStaticImage(469, 223, 26, 17, "img/dot_white.png", false, GUIEditor.tab[1])
        guiSetProperty(NitroColorImage, "ImageColours", "tl:FF0078FF tr:FF0078FF bl:FF0078FF br:FF0078FF")




        GUIEditor.tab[2] = guiCreateTab("Sound Settings", GUIEditor.tabpanel[1])

        GUIEditor.label[9] = guiCreateLabel(66, 90, 126, 15, "Map Music Volume:", false, GUIEditor.tab[2])
        setTooltip(GUIEditor.label[9],"Sets the volume of the music that mapmakers put in their maps. Beware: toggling the mapmusic off and on will reset it's volume on most maps.")
        
        GUIEditor.scrollbar[1] = guiCreateScrollBar(202, 90, 255, 18, true, false, GUIEditor.tab[2])

        GUIEditor.label[10] = guiCreateLabel(467, 93, 47, 15, "100%", false, GUIEditor.tab[2])

        GUIEditor.label[11] = guiCreateLabel(66, 115, 127, 15, "Custom Horns Volume:", false, GUIEditor.tab[2])
        setTooltip(GUIEditor.label[11],"Sets the volume of custom horns from the GC shop.")

        GUIEditor.scrollbar[2] = guiCreateScrollBar(202, 115, 255, 18, true, false, GUIEditor.tab[2])

        GUIEditor.label[12] = guiCreateLabel(467, 118, 47, 15, "100%", false, GUIEditor.tab[2])

        GUIEditor.label[13] = guiCreateLabel(66, 140, 127, 18, "Announcer Volume:", false, GUIEditor.tab[2])
        setTooltip(GUIEditor.label[13],"Sets the volume of the announcer (e.g. the 'Time's up, pal' voice.)")

        GUIEditor.scrollbar[3] = guiCreateScrollBar(202, 140, 255, 18, true, false, GUIEditor.tab[2])

        GUIEditor.label[14] = guiCreateLabel(467, 143, 47, 15, "100%", false, GUIEditor.tab[2])

        GUIEditor.label[15] = guiCreateLabel(66, 168, 127, 18, "Music Player Volume:", false, GUIEditor.tab[2])
        setTooltip(GUIEditor.label[15],"Sets the volume of the music player.")

        GUIEditor.scrollbar[4] = guiCreateScrollBar(202, 168, 255, 18, true, false, GUIEditor.tab[2])

        GUIEditor.label[16] = guiCreateLabel(467, 171, 47, 15, "100%", false, GUIEditor.tab[2])
        GUIEditor.label[17] = guiCreateLabel(70, 35, 444, 45, "In this tab you can set the individual volume of sounds. For GTA SA sounds, please go into the MTA settings (esc > Settings >Sound Settings)", false, GUIEditor.tab[2])
        guiLabelSetHorizontalAlign(GUIEditor.label[17], "left", true)

        GUIEditor.label[18] = guiCreateLabel(66, 196, 127, 18, "Miscellaneous Volume:", false, GUIEditor.tab[2])
        setTooltip(GUIEditor.label[18], "Sets the volume of every other custom sound that does not have it's own slider.")

        GUIEditor.scrollbar[5] = guiCreateScrollBar(202, 196, 255, 18, true, false, GUIEditor.tab[2])

        GUIEditor.label[19] = guiCreateLabel(467, 199, 47, 15, "100%", false, GUIEditor.tab[2])
        GUIEditor.label[20] = guiCreateLabel(73, 4, 441, 31, "Sound Settings", false, GUIEditor.tab[2])
        guiSetFont(GUIEditor.label[20], "default-bold-small")
        guiLabelSetHorizontalAlign(GUIEditor.label[20], "center", false)
        guiLabelSetVerticalAlign(GUIEditor.label[20], "center")

        SoundsOffLabel = guiCreateLabel(66, 251, 448, 17, "/soundsoff is disabled.", false, GUIEditor.tab[2])
        guiSetFont(SoundsOffLabel, "default-bold-small")
        guiLabelSetColor(SoundsOffLabel, 255, 255, 255)
        guiLabelSetHorizontalAlign(SoundsOffLabel, "center", false)
        guiLabelSetVerticalAlign(SoundsOffLabel, "center")
        setTooltip(SoundsOffLabel, "With /soundsoff you can quickly mute all sounds. It won't be saved on reconnect, so its always better to set your volumes in this GUI instead.")

        GUIEditor.tab[3] = guiCreateTab("UI Settings", GUIEditor.tabpanel[1])

        GUIEditor.label[21] = guiCreateLabel(72, 44, 401, 41, "In this tab you can toggle UI settings on or off. Settings will be saved, so you won't have to set it again. ", false, GUIEditor.tab[3])
        guiLabelSetHorizontalAlign(GUIEditor.label[21], "left", true)
        GUIEditor.label[22] = guiCreateLabel(92, 4, 381, 40, "User Interface Settings", false, GUIEditor.tab[3])
        guiSetFont(GUIEditor.label[22], "default-bold-small")
        guiLabelSetHorizontalAlign(GUIEditor.label[22], "center", false)
        guiLabelSetVerticalAlign(GUIEditor.label[22], "center")



        GUIEditor.staticimage[1] = guiCreateStaticImage(152, 48+70, 34, 32, "/img/reset.png", false, GUIEditor.tab[3])
        
        GUIEditor.checkbox[5] = guiCreateCheckBox(64, 26+70, 15, 15, "Enable Rank Board", false, false, GUIEditor.tab[3])
        GUIEditor.label[23] = guiCreateLabel(104, 27+70, 113, 15, "Enable Rank Board", false, GUIEditor.tab[3])
        
        

        GUIEditor.label[24] = guiCreateLabel(104, 52+70, 123, 15, "Enable Traffic Sensor", false, GUIEditor.tab[3])
        GUIEditor.checkbox[7] = guiCreateCheckBox(64, 51+70, 15, 15, "Enable Traffic Sensor", false, false, GUIEditor.tab[3])
        setTooltip(GUIEditor.label[24],"The Traffic Sensor are the arrows that you see when other players are near you.")

        GUIEditor.label[25] = guiCreateLabel(104, 77+70, 150, 15, "Enable GreenCoins Counter", false, GUIEditor.tab[3])
        GUIEditor.checkbox[8] = guiCreateCheckBox(64, 76+70, 15, 15, "Enable GreenCoins Counter", false, false, GUIEditor.tab[3])

        GUIEditor.label[26] = guiCreateLabel(104, 102+70, 150, 14, "Enable Next Map Window", false, GUIEditor.tab[3])
        GUIEditor.checkbox[9] = guiCreateCheckBox(64, 101+70, 15, 15, "Enable Next Map Window", false, false, GUIEditor.tab[3])

        GUIEditor.checkbox[10] = guiCreateCheckBox(64, 126+70, 15, 15, "Enable Checkpoint Delay", false, false, GUIEditor.tab[3])
        GUIEditor.label[27] = guiCreateLabel(104, 126+70, 141, 15, "Enable CheckPoint Delay", false, GUIEditor.tab[3])
        setTooltip(GUIEditor.label[27],"Checkpoint Delay gives you information on your time, when reaching a checkpoint.")

        GUIEditor.checkbox[11] = guiCreateCheckBox(64, 151+70, 15, 15, "Enable Chat Bubbles", false, false, GUIEditor.tab[3])
        GUIEditor.label[28] = guiCreateLabel(104, 151+70, 141, 15, "Enable Chat Bubbles", false, GUIEditor.tab[3])
        setTooltip(GUIEditor.label[28],"A chat bubble is the image that you see when a player is typing.")

        GUIEditor.label[29] = guiCreateLabel(104, 176+70, 141, 15, "Enable Floating Messages", false, GUIEditor.tab[3])
        GUIEditor.checkbox[12] = guiCreateCheckBox(64, 176+70, 15, 15, "Enable Floating Messages", false, false, GUIEditor.tab[3])
        setTooltip(GUIEditor.label[29],"Floating messages are the messages that float on the screen, giving you information. If disabled, the information will be in the chatbox instead.")

        -- GUIEditor.label[30] = guiCreateLabel(104, 201+70, 141, 15, "Enable Progress Bar", false, GUIEditor.tab[3])
        -- GUIEditor.checkbox[13] = guiCreateCheckBox(64, 201+70, 15, 15, "Enable Progress Bar", true, false, GUIEditor.tab[3])

        GUIEditor.staticimage[2] = guiCreateStaticImage(284, 19+70, 1, 207, "/img/dot_white.png", false, GUIEditor.tab[3])
        GUIEditor.button[2] = guiCreateButton(60, 230+50, 185, 24, "Go to Progress Bar Settings", false, GUIEditor.tab[3])
        setTooltip(GUIEditor.button[2],"Here you can find all settings related to the progress bar, including an option to disable it.")

        guiSetProperty(GUIEditor.button[2], "NormalTextColour", "FFAAAAAA")
        GUIEditor.combobox[1] = guiCreateComboBox(311, 62+70, 95, 78, "", false, GUIEditor.tab[3])
        guiSetFont(GUIEditor.combobox[1], "default-bold-small")
        guiComboBoxAddItem(GUIEditor.combobox[1], "New Hud")
        guiComboBoxAddItem(GUIEditor.combobox[1], "SP Hud")
        guiComboBoxAddItem(GUIEditor.combobox[1], "Old Hud")
        GUIEditor.label[31] = guiCreateLabel(413, 28+70, 141, 15, "Speed-o-meter Mode", false, GUIEditor.tab[3])

        GUIEditor.combobox[2] = guiCreateComboBox(311, 28+70, 95, 78, "", false, GUIEditor.tab[3])
        guiSetFont(GUIEditor.combobox[2], "default-bold-small")
        guiComboBoxAddItem(GUIEditor.combobox[2], "km/h")
        guiComboBoxAddItem(GUIEditor.combobox[2], "mph")
        guiComboBoxAddItem(GUIEditor.combobox[2], "None")

        GUIEditor.label[32] = guiCreateLabel(413, 62+70, 141, 15, "HUD Mode", false, GUIEditor.tab[3])

        GUIEditor.checkbox[14] = guiCreateCheckBox(309, 170, 15, 15, "", false, false, GUIEditor.tab[3])
        GUIEditor.label[34] = guiCreateLabel(346, 170, 141, 15, "Enable New Radar", false, GUIEditor.tab[3])

        GUIEditor.checkbox[15] = guiCreateCheckBox(309, 195, 15, 15, "", false, false, GUIEditor.tab[3])
        GUIEditor.label[35] = guiCreateLabel(346, 195, 141, 15, "Enable FPS Counter", false, GUIEditor.tab[3])


        GUIEditor.checkbox[16] = guiCreateCheckBox(309, 220, 15, 15, "", false, false, GUIEditor.tab[3])
        GUIEditor.label[36] = guiCreateLabel(346, 220, 141, 15, "Enable Countdown Timer", false, GUIEditor.tab[3])

        customNameTagsCheckBox = guiCreateCheckBox(309, 245, 15, 15, "", false, false, GUIEditor.tab[3])
        customNameTagsLabel = guiCreateLabel(346, 245, 141, 15, "Enable Custom NameTags", false, GUIEditor.tab[3])
        


        GUIEditor.button[3] = guiCreateButton(505, 475, 71, 23, "Close", false, GUIEditor.window[1])
        guiSetProperty(GUIEditor.button[3], "NormalTextColour", "FFAAAAAA")
        GUIEditor.label[33] = guiCreateLabel(9, 467, 262, 21, "Settings for the Mr. Green Servers.", false, GUIEditor.window[1])
        guiSetFont(GUIEditor.label[33], "default-small")
        guiLabelSetVerticalAlign(GUIEditor.label[33], "bottom")



-- Social Tab

        GUIEditor.tab[4] = guiCreateTab("Social", GUIEditor.tabpanel[1])

        GUIEditor.label[37] = guiCreateLabel(110, 16, 347, 33, "Social Settings", false, GUIEditor.tab[4])
        guiSetFont(GUIEditor.label[37], "default-bold-small")
        guiLabelSetHorizontalAlign(GUIEditor.label[37], "center", false)
        GUIEditor.label[38] = guiCreateLabel(76, 43, 410, 39, "In this tab you can set all your social settings. Settings will be saved so you do not have to set it again.", false, GUIEditor.tab[4])
        guiLabelSetHorizontalAlign(GUIEditor.label[38], "left", true)
        GUIEditor.checkbox[17] = guiCreateCheckBox(76, 103, 15, 15, "", false, false, GUIEditor.tab[4])
        GUIEditor.label[39] = guiCreateLabel(110, 103, 144, 15, "Block Private Messages", false, GUIEditor.tab[4])
        setTooltip(GUIEditor.label[39],"If you enable this, you will not get any private messages (f3)")

        GUIEditor.checkbox[18] = guiCreateCheckBox(76, 103+25, 15, 15, "", false, false, GUIEditor.tab[4])
        GUIEditor.label[40] = guiCreateLabel(110, 103+25, 144, 15, "Block Chatbox Messages", false, GUIEditor.tab[4])
        setTooltip(GUIEditor.label[40],"If you enable this, you will not get any chatbox messages, except for admin messages.")

        GUIEditor.button[4] = guiCreateButton(78, 140+25, 176, 24, "Manage Ignored Players", false, GUIEditor.tab[4])
        guiSetProperty(GUIEditor.button[4], "NormalTextColour", "FFAAAAAA")
        setTooltip(GUIEditor.button[4],"Click to see all the players you ignored. Ignore people with the command /ignore [playername], you can not ignore an admin.")


-- end Social Tab

-- gameplay Tab

        GUIEditor.tab[5] = guiCreateTab("Gameplay Setting", GUIEditor.tabpanel[1])

        GUIEditor.label["gameplay"] = guiCreateLabel(110, 16, 347, 33, "Gameplay Settings", false, GUIEditor.tab[5])
        guiSetFont(GUIEditor.label["gameplay"], "default-bold-small")
        guiLabelSetHorizontalAlign(GUIEditor.label["gameplay"], "center", false)
        GUIEditor.label["gameplayText"] = guiCreateLabel(76, 43, 410, 39, "In this tab you can set all your gameplay settings. Settings will be saved so you do not have to set it again.", false, GUIEditor.tab[5])
        guiLabelSetHorizontalAlign(GUIEditor.label["gameplayText"], "left", true)



        GUIEditor.label["NOSMode"] = guiCreateLabel(110-30, 103, 144, 15, "NOS Mode", false, GUIEditor.tab[5])
        GUIEditor.combobox["NOSMode"] = guiCreateComboBox(78, 122, 100, 75, "", false, GUIEditor.tab[5])
        guiComboBoxAddItem(GUIEditor.combobox["NOSMode"], "old")
        guiComboBoxAddItem(GUIEditor.combobox["NOSMode"], "hybrid")
        guiComboBoxAddItem(GUIEditor.combobox["NOSMode"], "nfs")
        guiComboBoxSetSelected(GUIEditor.combobox["NOSMode"], 2)

-- end gameplay Tab


        guiSetVisible( GUIEditor.window[1], false )  
        -- showCursor( true ) 
        triggerEvent('guiShaderCreated', GUIEditor.window[1])
    end
)


function setTooltip(element, text)
    setElementData(element, "tooltip-text", text, false)
end

showGui = false

addCommandHandler('settings',
function()
 showGui = not showGui
 showCursor(showGui)
 guiSetVisible(GUIEditor.window[1], showGui)
 guiBringToFront( GUIEditor.window[1] )
end
)

addEvent("sb_showSettings")
addEventHandler("sb_showSettings",root,function()
     showGui = not showGui
     showCursor(showGui)
     guiSetVisible(GUIEditor.window[1], showGui)
     guiBringToFront( GUIEditor.window[1] )
    end)

-- bindKey("f7", "down",
-- function()
--  showGui = not showGui
--  showCursor(showGui)
--  guiSetVisible(GUIEditor.window[1], showGui)
-- end
-- )

addEventHandler("onClientGUIClick", resourceRoot, function()
    if source == GUIEditor.button[3] then
        executeCommandHandler("settings") 
    end 
end)


-- Ignored Playerlist GUI


addEventHandler("onClientResourceStart", resourceRoot,
    function()
local screenW, screenH = guiGetScreenSize()
        ignorePlayerWindow = guiCreateWindow((screenW - 277) / 2, (screenH - 392) / 2, 277, 392, "Ignored Players", false)
        guiWindowSetSizable(ignorePlayerWindow, false)
        guiSetAlpha( ignorePlayerWindow, 255 )

        ignorePlayerGridlist = guiCreateGridList(29, 84, 212, 240, false, ignorePlayerWindow)
        ignoredplayerColumn = guiGridListAddColumn(ignorePlayerGridlist, "Player Name", 0.9)
        ignoreLabelExpl = guiCreateLabel(10, 25, 249, 53, "You can manage your ignored playerlist, ignore players with the command \n/ignore [playername]", false, ignorePlayerWindow)
        guiLabelSetHorizontalAlign(ignoreLabelExpl, "center", true)
        removePlayerButton = guiCreateButton(29, 332, 96, 28, "Remove Player", false, ignorePlayerWindow)
        guiSetProperty(removePlayerButton, "NormalTextColour", "FFAAAAAA")
        ignorePlayerCloseButton = guiCreateButton(177, 333, 64, 27, "Close", false, ignorePlayerWindow)
        guiSetProperty(ignorePlayerCloseButton, "NormalTextColour", "FFAAAAAA")
        guiSetVisible(ignorePlayerWindow, false)
    end
)

function showIgnorePlayerlist()
    guiSetVisible( ignorePlayerWindow, true )
    guiBringToFront( ignorePlayerWindow )
end



