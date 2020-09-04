volUpdateTime = 50 -- ms of volume update timer when slider gets changed
soundsoff = false

local theResourcesName = {--Change names of the resources here if they are changed.
    ["announcer"] = "race_voicepack",
    ["horn"] = "gcshop",
    ["viphorn"] = "mrgreen-vip",
    ["musicplayer"] = "sc-musicplayer",
}

theResources = {}


Volumes = {
	["map"] = 1,
	["horn"] = 1,
	["announcer"] = 1,
	["musicplayer"] = 1,
	["miscellaneous"] = 1,
}

-- Reapply settings when one of these resources (re)starts
local SND_reApplyTimer = false
-- Add resource name here when used
local resetResource = {"race_voicepack","gcshop","sc-musicplayer","race"}
addEventHandler("onClientResourceStart",root,
    function(res)
        local resName = getResourceName(res)
        for _,rn in ipairs(resetResource) do
            if rn == resName then
                -- Timer system so no settings spam
                refreshResourcePointers()
                if isTimer(SND_reApplyTimer) then killTimer(SND_reApplyTimer) end
                SND_reApplyTimer = setTimer(function() getSoundSettings() end,5000,1)
                break
            end
        end
    end
)

function refreshResourcePointers()
    for name,resname in pairs(theResourcesName) do
        theResources[name] = getResourceRootElement( getResourceFromName(resname) )
    end
end
addEventHandler("onClientResourceStart", root, refreshResourcePointers)


function getSoundSettings()

	soundXML = xmlLoadFile( "/settings/soundsettings.xml" )
	if not soundXML then
		soundXML = xmlCreateFile( "/settings/soundsettings.xml", "settings" )
		for f, u in pairs(Volumes) do
			local theChild = xmlCreateChild( soundXML, f )
			xmlNodeSetValue( theChild, tostring(u) )
		end
		xmlSaveFile( soundXML )
	end

    -- Second Check if player has all settings
    for f, u in pairs(Volumes) do
        local doIexist = xmlFindChild( soundXML, f, 0 )
        if not doIexist then
            local theChild = xmlCreateChild( soundXML, f )
            xmlNodeSetValue(theChild, tostring(u))
        end
    end

	-- Load settings into table --
	local _soundSettingsTable = {
		["map"] = xmlNodeGetValue( xmlFindChild(soundXML, "map", 0) ),
		["horn"] = xmlNodeGetValue( xmlFindChild(soundXML, "horn", 0) ),
		["announcer"] = xmlNodeGetValue( xmlFindChild(soundXML, "announcer", 0) ),
		["musicplayer"] = xmlNodeGetValue( xmlFindChild(soundXML, "musicplayer", 0) ),
		["miscellaneous"] = xmlNodeGetValue( xmlFindChild(soundXML, "miscellaneous", 0) ),
}
	Volumes = _soundSettingsTable



	xmlUnloadFile( soundXML )

	setScrollBars()
end
addEventHandler("onClientResourceStart", resourceRoot, getSoundSettings)

currentMap = false
MapSound = {}
function detectMap(theRes)
    local MaporNot = isMap(getResourceRootElement( theRes ) )

    if MaporNot == true then

        currentMap = source
        MapSound = {}
        MapSound = getElementsByType( "sound", source )
        for f, u in pairs(MapSound) do
            setElementData( u, "soundSource", "map", false )
        end
        setVol("map")
      end
end
addEventHandler("onClientResourceStart", root, detectMap)


function soundHandling(reason)

    local theSound = source
    local theResource = getElementResource(source)

    if theResource == currentMap then -- If the sound comes from the map --
        table.insert(MapSound, source) -- Insert the sound in the MapSound table --
		setSoundVolume(theSound, tonumber(Volumes["map"]))
        -- setVol("map")
        setElementData( theSound, "soundSource", "map", false ) -- Mark sound for source

    elseif theResource == theResources["announcer"] then
        setElementData( theSound, "soundSource", "announcer", false ) -- Mark sound for source
    	setVol("announcer", source)

    elseif theResource == theResources["horn"] then
        setElementData( theSound, "soundSource", "horn", false ) -- Mark sound for source
    	setVol("horn", source)
    elseif theResource == theResources["viphorn"] then
        setElementData( theSound, "soundSource", "horn", false ) -- Mark sound for source
    	setVol("horn", source)
    elseif theResource == theResources["musicplayer"] then
        setElementData( theSound, "soundSource", "musicplayer", false ) -- Mark sound for source
    	setVol("musicplayer", source)


    else
        setVol("miscellaneous", source)
    end

end
addEventHandler("onClientSoundStarted", root, soundHandling)



function setVol(reason,theSound)
    if MapSound and reason == "map" then
        for f, u in pairs(MapSound) do


        	setSoundVolume(u, tonumber(Volumes["map"]))
        	setTimer(function()
                if isElement(u) then
                    setSoundVolume(u, tonumber(Volumes["map"]))
                    if Volumes["map"] == 0 then
                        setSoundPaused( u, true )
                    end
                else u = nil
                end
        	 end, 50, 2) -- timer to set volume after map script has set volume --

        end
        -- outputDebugString("Set volume for "..reason.." "..Volumes["map"])
    elseif reason == "announcer" then


    	setSoundVolume( theSound, tonumber(Volumes["announcer"] ))
        setTimer(setSoundVolume,50,2,theSound, tonumber(Volumes["announcer"]))
    	-- outputDebugString("Set volume for "..reason)
    elseif reason == "horn" then


    	setSoundVolume( theSound, tonumber(Volumes["horn"] ))
        setTimer(setSoundVolume,50,2,theSound, tonumber(Volumes["horn"]))
    	-- outputDebugString("Set volume for "..reason)
    elseif reason == "musicplayer" then


    	setSoundVolume( theSound, tonumber(Volumes["musicplayer"] ))
        setTimer(setSoundVolume,50,2,theSound, tonumber(Volumes["musicplayer"]))
    	-- outputDebugString("Set volume for "..reason)

    elseif reason == "miscellaneous" then


    	setSoundVolume( theSound, tonumber(Volumes["miscellaneous"] ))
        setTimer(setSoundVolume,50,2,theSound, tonumber(Volumes["miscellaneous"]))
    	-- outputDebugString("Set volume for "..reason)

    end
end


function updateVolume(givenSource)
    local allSounds = getElementsByType( "sound" )
    for f, u in pairs(allSounds) do
        local theSource = getElementData( u, "soundSource" )
        if not theSource then
            theSource = "miscellaneous"
        end


        if tostring(theSource) == givenSource then
            setSoundVolume( u, tonumber(Volumes[tostring(theSource)]) )
            if tostring(theSource) == "map" then
                if isSoundPaused( u ) and Volumes["map"] ~= 0 then
                    setSoundPaused( u, false )
                end
            end
        end

        if givenSource == "soundsoff" then
            setSoundVolume( u, 0)
        elseif givenSource == "soundson" then
            setSoundVolume( u, tonumber(Volumes[tostring(theSource)]) )
        end
    end
end


function saveSoundVolumes()
    local soundXML = xmlLoadFile( "/settings/soundsettings.xml" )
    for f, u in pairs(Volumes) do
        local theChild = xmlFindChild(soundXML, f, 0)
        if theChild then
            xmlNodeSetValue( theChild, u )
        else
            local theNewChild = xmlCreateChild( soundXML, f )
            xmlNodeSetValue( theNewChild, u )
        end
    end
    xmlSaveFile( soundXML )
    xmlUnloadFile( soundXML )
    outputConsole("Sound Settings Saved!")
end


-- utils --
function isMap(resourceElement)
    if #getElementsByType('spawnpoint', resourceElement) > 0 then return true
        else return false end
end




function getElementResource (element)
        local parent = element
        repeat
                parent = getElementParent ( parent )
        until not parent or getElementType(parent) == 'resource'
        if getElementType(parent) == 'resource' then return parent
        else
        -- for _, resource in ipairs(getResources()) do
                -- if getResourceRootElement(resource) == parent then
                --         return resource
                -- end
        -- end
        return false
    end
end


-- GUI HANDLERS --
function sounds_scrollbarhandler()
    if not isTimer(IgnoreScrollOnStartup) then
        if source == GUIEditor.scrollbar[1] then
            local procent = guiScrollBarGetScrollPosition(source)
            guiSetText(GUIEditor.label[10], procent.."%")
            Volumes["map"] = guiScrollBarGetScrollPosition( source )/100
            if isTimer( soundSaveTimer ) then
                killTimer( soundSaveTimer )
                soundSaveTimer = nil
            end
            soundSaveTimer = setTimer( saveSoundVolumes, 5000, 1 )

            if isTimer(updateMapVolumeTimer) then -- Update Volumes Dynamically
                killTimer(updateMapVolumeTimer)
                updateMapVolumeTimer = nil
            end
            updateMapVolumeTimer = setTimer(updateVolume, volUpdateTime, 1, "map")

        elseif source == GUIEditor.scrollbar[2] then
            local procent = guiScrollBarGetScrollPosition(source)
            guiSetText(GUIEditor.label[12], procent.."%")
            Volumes["horn"] = guiScrollBarGetScrollPosition( source )/100
            if isTimer( soundSaveTimer ) then
                killTimer( soundSaveTimer )
                soundSaveTimer = nil
            end
            soundSaveTimer = setTimer( saveSoundVolumes, 5000, 1 )

            if isTimer(updateHornVolumeTimer) then -- Update Volumes Dynamically
                killTimer(updateHornVolumeTimer)
                updateHornVolumeTimer = nil
            end
            updateHornVolumeTimer = setTimer(updateVolume, volUpdateTime, 1, "horn")

        elseif source == GUIEditor.scrollbar[3] then
            local procent = guiScrollBarGetScrollPosition(source)
            guiSetText(GUIEditor.label[14], procent.."%")
            Volumes["announcer"] = guiScrollBarGetScrollPosition( source )/100
            if isTimer( soundSaveTimer ) then
                killTimer( soundSaveTimer )
                soundSaveTimer = nil
            end
            soundSaveTimer = setTimer( saveSoundVolumes, 5000, 1 )

            if isTimer(updateAnnouncerVolumeTimer) then -- Update Volumes Dynamically
                killTimer(updateAnnouncerVolumeTimer)
                updateAnnouncerVolumeTimer = nil
            end
            updateAnnouncerVolumeTimer = setTimer(updateVolume, volUpdateTime, 1, "announcer")

        elseif source == GUIEditor.scrollbar[4] then
            local procent = guiScrollBarGetScrollPosition(source)
            guiSetText(GUIEditor.label[16], procent.."%")
            Volumes["musicplayer"] = guiScrollBarGetScrollPosition( source )/100
            if isTimer( soundSaveTimer ) then
                killTimer( soundSaveTimer )
                soundSaveTimer = nil
            end
            soundSaveTimer = setTimer( saveSoundVolumes, 5000, 1 )

            if isTimer(updateMusicplayerVolumeTimer) then -- Update Volumes Dynamically
                killTimer(updateMusicplayerVolumeTimer)
                updateMusicplayerVolumeTimer = nil
            end
            updateMusicplayerVolumeTimer = setTimer(updateVolume, volUpdateTime, 1, "musicplayer")

        elseif source == GUIEditor.scrollbar[5] then
            local procent = guiScrollBarGetScrollPosition(source)
            guiSetText(GUIEditor.label[19], procent.."%")
            Volumes["miscellaneous"] = guiScrollBarGetScrollPosition( source )/100
            if isTimer( soundSaveTimer ) then
                killTimer( soundSaveTimer )
                soundSaveTimer = nil
            end
            soundSaveTimer = setTimer( saveSoundVolumes, 5000, 1 )

            if isTimer(updateMiscellaneousVolumeTimer) then -- Update Volumes Dynamically
                killTimer(updateMiscellaneousVolumeTimer)
                updateMiscellaneousVolumeTimer = nil
            end
            updateMiscellaneousVolumeTimer = setTimer(updateVolume, volUpdateTime, 1, "miscellaneous")

        end
    end
end
addEventHandler("onClientGUIScroll", resourceRoot, sounds_scrollbarhandler)

function setScrollBars()

    local map = tonumber(Volumes["map"])*100
    local horn = tonumber(Volumes["horn"])*100
    local announcer = tonumber(Volumes["announcer"])*100
    local musicplayer = tonumber(Volumes["musicplayer"])*100
    local misc = tonumber(Volumes["miscellaneous"])*100
    IgnoreScrollOnStartup = setTimer(function() end, 1000, 1)
	guiScrollBarSetScrollPosition( GUIEditor.scrollbar[1], map )
	guiScrollBarSetScrollPosition( GUIEditor.scrollbar[2], horn )
	guiScrollBarSetScrollPosition( GUIEditor.scrollbar[3], announcer )
	guiScrollBarSetScrollPosition( GUIEditor.scrollbar[4], musicplayer )
	guiScrollBarSetScrollPosition( GUIEditor.scrollbar[5], misc )

	guiSetText(GUIEditor.label[10], tostring(map).."%")
    guiSetText(GUIEditor.label[12], tostring(horn).."%")
    guiSetText(GUIEditor.label[14], tostring(announcer).."%")
    guiSetText(GUIEditor.label[16], tostring(musicplayer).."%")
    guiSetText(GUIEditor.label[19], tostring(misc).."%")
end

function soundsCommandHandler(cmd)
    if cmd == "soundson" then
        if not soundsoff then return end
        soundsoff = false
        soundson()
    elseif cmd == "soundsoff" then
        soundsoff = not soundsoff
        soundson()

    end
end
addCommandHandler( "soundsoff", soundsCommandHandler )
addCommandHandler("soundson", soundsCommandHandler)

function soundson()
    if soundsoff then
        outputChatBox(_("Custom Sounds disabled. (You can set individual sound volumes in the /settings menu, this command is not saved on reconnect.)"),255,0,0)

        guiSetText( SoundsOffLabel, "/soundsoff is enabled." )
        guiLabelSetColor(SoundsOffLabel, 255, 0, 0)
        guiLabelSetColor( GUIEditor.label[9], 255, 0, 0 )
        guiLabelSetColor( GUIEditor.label[10], 255, 0, 0 )
        guiLabelSetColor( GUIEditor.label[11], 255, 0, 0 )
        guiLabelSetColor( GUIEditor.label[12], 255, 0, 0 )
        guiLabelSetColor( GUIEditor.label[13], 255, 0, 0 )
        guiLabelSetColor( GUIEditor.label[14], 255, 0, 0 )
        guiLabelSetColor( GUIEditor.label[15], 255, 0, 0 )
        guiLabelSetColor( GUIEditor.label[16], 255, 0, 0 )
        guiLabelSetColor( GUIEditor.label[18], 255, 0, 0 )
        guiLabelSetColor( GUIEditor.label[19], 255, 0, 0 )

        VolumesJson = toJSON( Volumes )

        for f,u in pairs(Volumes) do
            Volumes[f] = 0
        end

        updateVolume("soundsoff")


    elseif not soundsoff then
        outputChatBox(_("Custom Sounds enabled again. (You can set individual sound volumes in the /settings menu, this command is not saved on reconnect.)"),0,255,0)

        guiSetText( SoundsOffLabel, "/soundsoff is disabled." )
        guiLabelSetColor(SoundsOffLabel, 255, 255, 255)
        guiLabelSetColor( GUIEditor.label[9], 255, 255, 255 )
        guiLabelSetColor( GUIEditor.label[10], 255, 255, 255 )
        guiLabelSetColor( GUIEditor.label[11], 255, 255, 255 )
        guiLabelSetColor( GUIEditor.label[12], 255, 255, 255 )
        guiLabelSetColor( GUIEditor.label[13], 255, 255, 255 )
        guiLabelSetColor( GUIEditor.label[14], 255, 255, 255 )
        guiLabelSetColor( GUIEditor.label[15], 255, 255, 255 )
        guiLabelSetColor( GUIEditor.label[16], 255, 255, 255 )
        guiLabelSetColor( GUIEditor.label[18], 255, 255, 255 )
        guiLabelSetColor( GUIEditor.label[19], 255, 255, 255 )

        local old_Volumes = fromJSON( VolumesJson )
        for f, u in pairs(old_Volumes) do
            Volumes[f] = u
        end

        updateVolume("soundson")
    end
end
