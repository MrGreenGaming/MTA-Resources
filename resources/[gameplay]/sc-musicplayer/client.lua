mySerial = getPlayerSerial( localPlayer )
nowPlaying_SongTitle = " "
nowPlaying_SongUsername = " "
currentlyPlaying = {}
paused_NewTimer = 0
Playlist = {}
MaxPlaylistSongs = 200


function askforClientID()
    triggerServerEvent( "onClientAskClientID", resourceRoot, mySerial )
end
addEventHandler("onClientResourceStart", resourceRoot, askforClientID)

function receiveClientID(theID)
    clientID = theID
end
addEvent( "serverSendClientID",true )
addEventHandler("serverSendClientID", resourceRoot, receiveClientID)



function makePlaylistXML()
    local PlaylistPointer = xmlLoadFile("playlist.xml")
    if not PlaylistPointer then
        local PlaylistPointerNew = xmlCreateFile("playlist.xml", "playlist")
        xmlSaveFile(PlaylistPointerNew)
        xmlUnloadFile(PlaylistPointerNew)
        outputDebugString("playlist.xml added to resource folder")
        else xmlUnloadFile(PlaylistPointer) end
    
        
end
addEventHandler("onClientResourceStart", resourceRoot, makePlaylistXML)



function AddToPlaylistButton(searchResultNumber)
    if #Playlist > MaxPlaylistSongs then outputChatBox("Only "..MaxPlaylistSongs.." songs are allowed in a playlist.", 255, 0, 0) return end
    local nextInLine = #Playlist+1
    Playlist[tonumber(nextInLine)] = searchResults[tonumber(searchResultNumber)]
    updatePlaylist()


    
end

function updatePlaylist()

 	guiGridListClear(QueueList)
 	for f, u in ipairs(Playlist) do
 		local row = guiGridListAddRow(QueueList, Playlist[f]["title"])
 		guiGridListSetItemText(QueueList, row, 1, Playlist[f]["title"], false, false)
 		guiGridListSetItemData(QueueList, row, 1, tonumber(f))
 	end
    




end


function saveCurrentPlaylist()
    local name = guiGetText(SavePlaylist_EditBox_Name)

    if #Playlist == 0 then outputChatBox("Please add songs to your playlist before saving it.", 255, 0, 0) return end
    if name == false then outputChatBox("Please give your playlist a name.", 255, 0, 0) return end
    if #guiGetText(SavePlaylist_EditBox_Name) < 2 then outputChatBox("Your playlist name needs to be longer then 2 characters", 255, 0, 0) return end

    thePlaylist_save = xmlLoadFile("playlists/"..name..".xml") -- load playlist
    if thePlaylist_save then 
        xmlUnloadFile(thePlaylist_save)
        fileDelete("playlists/"..name..".xml")
    end
        thePlaylist_new = xmlCreateFile("playlists/"..name..".xml", "playlist")
        if thePlaylist_new then
            -- save --
            for f, u in ipairs(Playlist) do
                local theChild = xmlCreateChild(thePlaylist_new, "s"..tostring(f))
                local title = xmlNodeSetAttribute(theChild, "title", Playlist[f]["title"])
                local duration = xmlNodeSetAttribute(theChild, "duration", Playlist[f]["duration"])
                local username = xmlNodeSetAttribute(theChild, "username", Playlist[f]["user"]["username"])
                local permalink = xmlNodeSetAttribute(theChild, "permalink_url", Playlist[f]["permalink_url"])
                local id = xmlNodeSetAttribute(theChild, "id", Playlist[f]["id"])
                local avatarURL = xmlNodeSetAttribute(theChild, "artwork_url", Playlist[f]["artwork_url"])
            end
            xmlSaveFile(thePlaylist_new)
            xmlUnloadFile(thePlaylist_new)


            local PlaylistPointer = xmlLoadFile("playlist.xml")
            if PlaylistPointer then
                local nameWithoutSpace = xmlName(name)
                local bestaIk = xmlFindChild(PlaylistPointer, nameWithoutSpace, 0)
                if not bestaIk then -- If child doesnt exist
                    local child = xmlCreateChild(PlaylistPointer, nameWithoutSpace)
                                    xmlNodeSetAttribute(child, "Name", name)
                end
            else outputChatBox("Loading playlist.xml failed.",255,0,0) return end
            xmlSaveFile(PlaylistPointer)
            xmlUnloadFile(PlaylistPointer)
            outputChatBox('Succesfully saved playlist "'..name..'"', 0, 255, 0)
            guiSetVisible(SavePlaylistWindow, false)
            guiSetVisible( MainWindow, true )
        end
end


function SavePlaylist_OverrideName()
    local selected = guiGridListGetSelectedItem(SavePlaylist_Gridlist)
    if selected then
        local theSelectedName = guiGridListGetItemText(SavePlaylist_Gridlist, selected, 1)
        guiSetText(SavePlaylist_EditBox_Name, theSelectedName)
    end
end


function populatePlaylistGridlist(whatGridlist)
    if whatGridlist == SavePlaylist_Gridlist then guiSetText(SavePlaylist_EditBox_Name, "") end
    guiGridListClear(whatGridlist)

    local PlaylistPointer = xmlLoadFile("playlist.xml")
    if PlaylistPointer then
        local PlaylistPointerTable = xmlNodeGetChildren(PlaylistPointer)
        for f, u in ipairs(PlaylistPointerTable) do

            local theName = xmlNodeGetAttribute(u, "Name")
            local row = guiGridListAddRow(whatGridlist)
            guiGridListSetItemText(whatGridlist, row, 1, theName, false, false)
        end
    end

end

function loadPlaylist()
    local theSelectedItem = guiGridListGetSelectedItem(LoadPlaylist_Gridlist)
    if theSelectedItem == -1 or theSelectedItem == false then outputChatBox("No playlist selected.", 255,0,0) return end

    local theSelectedPlaylistText = guiGridListGetSelectedItemText(LoadPlaylist_Gridlist)


    local thePlaylistXML = xmlLoadFile("playlists/"..theSelectedPlaylistText..".xml")
    if not thePlaylistXML then outputChatBox("Playlist failed to load, please try again.",255,0,0) return end
    local childrenFromPlaylistXML = xmlNodeGetChildren(thePlaylistXML)


    Playlist = {}
        for num, songdata in ipairs(childrenFromPlaylistXML) do -- loop to fetch from xml
            local num = string.gsub(num,'s','')
            local playlistNumber = num
            local playlistTitle = xmlNodeGetAttribute(songdata, "title")
            local playlistUsername = xmlNodeGetAttribute(songdata, "username")
            local playlistDuration = xmlNodeGetAttribute(songdata, "duration") 
            local playlistPermaLink = xmlNodeGetAttribute(songdata, "permalink_url")
            local playlistTrackID = xmlNodeGetAttribute(songdata, "id")
            local playlistArtworkurl = xmlNodeGetAttribute(songdata, "artwork_url")

            local xmlSongData = {
                                    ["title"] = playlistTitle,
                                    ["duration"] = tonumber(playlistDuration),
                                    ["permalink_url"] = playlistPermaLink,
                                    ["id"] = playlistTrackID,
                                    ["user"] = {
                                                ["username"] = playlistUsername
                                                        }                                
                                }
                                if playlistArtworkurl then xmlSongData["artwork_url"] = playlistArtworkurl end

            Playlist[tonumber(playlistNumber)] = xmlSongData
            local xmlSongData = nil

        end

        guiGridListClear(QueueList)
        for f, u in ipairs(Playlist) do
            local row = guiGridListAddRow(QueueList)
            guiGridListSetItemText( QueueList, row, 1, Playlist[f]["title"], false, false )
            guiGridListSetItemData(QueueList, row, 1, tonumber(f))
        end

        xmlSaveFile(thePlaylistXML)
        xmlUnloadFile(thePlaylistXML)

        guiSetVisible(LoadPlaylistWindow, false)
        guiSetVisible( MainWindow, true )

        outputDebugString(#Playlist.." songs loaded into the playlist.")



end

function deletePlaylist()

    local theSelectedItem = guiGridListGetSelectedItem(LoadPlaylist_Gridlist)
    local theSelectedPlaylistText = guiGridListGetSelectedItemText(LoadPlaylist_Gridlist)

    if theSelectedItem == -1 or theSelectedItem == false then outputChatBox("No playlist selected.", 255,0,0) return end

    local thePlaylistXMLforDelete = fileDelete("playlists/"..theSelectedPlaylistText..".xml")

    local nameWithoutSpace = xmlName(theSelectedPlaylistText)
    local PlaylistPointer = xmlLoadFile("playlist.xml")
    local theChild = xmlFindChild(PlaylistPointer,nameWithoutSpace ,0)
    xmlDestroyNode(theChild)

    xmlSaveFile(PlaylistPointer)
    xmlUnloadFile(PlaylistPointer)
    outputChatBox("Playlist Deleted",0,255,0)
    
    guiSetVisible(LoadPlaylistWindow, false)
    guiSetVisible( MainWindow, true )


end

function clearCurrentPlaylist()
    Playlist = {}
    guiGridListClear(QueueList)
    outputChatBox("Current Playlist Cleared",0,255,0)
    nowPlaying_Next = nil
    nowPlaying_Prev = nil
end

function SearchHandler()
    if source == SearchBox then
        local searchQuery = guiGetText( source )
            if isTimer( searchCooldown ) then
                killTimer( searchCooldown )
            end
        searchCooldown = setTimer(function()  triggerServerEvent("onClientAskSearch", resourceRoot, searchQuery, mySerial) clearSearchResults() end, 750,1)
        
    end
end
addEventHandler("onClientGUIChanged", root, SearchHandler)





function ReceiveSearchResults(searchData)
    searchResults = {}
    local nummer = 0
    for i, k in ipairs(searchData) do
        -- var_dump("-v", k)
        if k["streamable"] == false then
            k = nil
            -- outputChatBox("false")
        elseif k["streamable"] == true then
            -- outputChatBox("true")
            nummer = nummer + 1
            searchResults[nummer] = k
        end
    end

    clearSearchResults()

    for n, k in ipairs(searchResults) do

        if k["title"] and n < 9 then
            guiSetText(SearchResultTEXT[n], k["title"])
            guiSetVisible( Results_Add[n], true )
        end
    end
   
end
addEvent( "onSendSearchResultstoClient", true)
addEventHandler("onSendSearchResultstoClient", resourceRoot, ReceiveSearchResults)


function NextorPrev(whatDirection)
    if whatDirection == "next" then 
        if nowPlaying_Next and Playlist[nowPlaying_Next] then -- if next exists, play that song
            soundHandler(Playlist[nowPlaying_Next])

            guiGridListSetSelectedItem(QueueList, nowPlaying_Next-1, 1)

            nowPlaying_Next = nowPlaying_Next+1
            nowPlaying_Prev = nowPlaying_Prev+1

            


        elseif Playlist[1] then -- if playlist exist, play song 1
            soundHandler(Playlist[1])

            nowPlaying_Next = 2
            nowPlaying_Prev = 1

            guiGridListSetSelectedItem(QueueList, 0, 1)
        end
    elseif whatDirection == "prev" then
        if nowPlaying_Prev and Playlist[nowPlaying_Prev] and nowPlaying_Prev ~= 1 then -- if previous exists, play that
            soundHandler(Playlist[nowPlaying_Prev])

            guiGridListSetSelectedItem(QueueList, nowPlaying_Prev-1, 1)

            nowPlaying_Next = nowPlaying_Next-1
            nowPlaying_Prev = nowPlaying_Prev-1


        elseif Playlist[1] then -- if playlist exist, play song 1
            soundHandler(Playlist[1])
            
            nowPlaying_Next = 2
            nowPlaying_Prev = 1

            guiGridListSetSelectedItem(QueueList, 0, 1)
        end
    end
end



function soundHandler(songInfoTable)
    if playingSong ~= nil then 
        if getElementType(playingSong) == "sound" then
            stopSound( playingSong )
        end
    end
    currentlyPlaying = songInfoTable
    local theSongID = currentlyPlaying["id"]

    playingSong = playSound("http://api.soundcloud.com/tracks/"..theSongID.."/stream?client_id="..clientID,false)
end

function playingSong_SuccesorFail(succes)
    if source == playingSong then
        if succes == true then

            nowPlaying_ElapsedTime = setTimer( function() end, currentlyPlaying["duration"], 1 )
            nowPlaying_SongTitle = currentlyPlaying["title"]
            nowPlaying_SongUsername = currentlyPlaying["user"]["username"]
            nowPlaying_SongDurationReadable = msToReadable(currentlyPlaying["duration"])
            nowPlaying_SongDurationSeconds = currentlyPlaying["duration"]
            nowPlaying_SongURL = currentlyPlaying["permalink_url"]
            cleanUp ()
            theArtwork = replaceArtwork(currentlyPlaying)
            
            isSongPaused = false
            guiStaticImageLoadImage( PlayButton, "/img/p_pause.png")

            outputConsole(" ")
            outputConsole( "Title: "..nowPlaying_SongTitle )
            outputConsole( "Uploaded By: "..nowPlaying_SongUsername )
            outputConsole( "SoundCloud URL: "..nowPlaying_SongURL )
            outputConsole(" ")

            muteMapMusic()
            popUpAnim()

        else
            outputConsole( "Song failed to stream.")
            outputChatBox("Song failed to stream.",255 )
        end
    end

end
addEventHandler("onClientSoundStream", resourceRoot, playingSong_SuccesorFail)

function playingSong_Stop(reason)

    if reason == "finished" then

        if isTimer(nowPlaying_ElapsedTime) then
            killTimer( nowPlaying_ElapsedTime )
            nowPlaying_ElapsedTime = nil
        end
        nowPlaying_SongTitle = ""
        nowPlaying_SongUsername = ""
        nowPlaying_SongDurationReadable = ""
        nowPlaying_SongDurationSeconds = ""
        nowPlaying_ElapsedTime = nil

        guiSetVisible( shiny, false )
        guiStaticImageLoadImage( Avatar, "/img/artwork-placeholder.png" )
        guiStaticImageLoadImage( PlayButton, "/img/p_play.png" )
        isSongPaused = nil
        playingSong = nil
        

        NextorPrev("next")
    elseif reason == "destroyed" then
        if isTimer(nowPlaying_ElapsedTime) then
            killTimer( nowPlaying_ElapsedTime )
            nowPlaying_ElapsedTime = nil
        end
        nowPlaying_SongTitle = ""
        nowPlaying_SongUsername = ""
        nowPlaying_SongDurationReadable = ""
        nowPlaying_SongDurationSeconds = ""
        nowPlaying_ElapsedTime = nil

        guiSetVisible( shiny, false )
        guiStaticImageLoadImage( Avatar, "/img/artwork-placeholder.png" )
        playingSong = nil


    elseif reason == "paused" then

         paused_NewTimer = getTimerDetails( nowPlaying_ElapsedTime )
         killTimer( nowPlaying_ElapsedTime )
         nowPlaying_ElapsedTime = nil



        end
end
addEventHandler("onClientSoundStopped", resourceRoot, playingSong_Stop)


function playingSong_Start(reason)
    if reason == "resumed" then
        nowPlaying_ElapsedTime = setTimer( function() end, paused_NewTimer, 1 )
        nowPlaying_SongTitle = currentlyPlaying["title"]
        nowPlaying_SongUsername = currentlyPlaying["user"]["username"]
        nowPlaying_SongDurationReadable = msToReadable(currentlyPlaying["duration"])
        nowPlaying_SongDurationSeconds = currentlyPlaying["duration"]
        replaceArtwork(currentlyPlaying)
        isSongPaused = false
        guiStaticImageLoadImage( PlayButton, "/img/p_pause.png" )
        muteMapMusic()

    end
end
addEventHandler("onClientSoundStarted", resourceRoot, playingSong_Start)

function clickedOnPlaylist()

    local theSelectedItem = guiGridListGetSelectedItem(QueueList)
    if theSelectedItem == -1 or theSelectedItem == false then outputChatBox("No song selected.", 255,0,0) return end
    local theNumber = guiGridListGetItemData(QueueList,theSelectedItem,1)
    soundHandler(Playlist[theNumber])
    nowPlaying_Next = theNumber+1
    nowPlaying_Prev = theNumber-1

end


function xmlName(stringtoConvert)
    if stringtoConvert then
    stringtoConvert = string.gsub(stringtoConvert, "%s+", "_") return stringtoConvert
    end
end




currentMap = false
MapSound = {}
function detectMap(theMap) -- werkt
    local MaporNot = isMap(getResourceRootElement( theMap ) )

    if MaporNot == true then

        currentMap = source
        MapSound = getElementsByType( "sound", source )
        muteMapMusic()
      end
end
addEventHandler("onClientResourceStart", root, detectMap)


function DetectMapMusic(reason)

    local theResource = getElementResource(source)


    if theResource == currentMap then -- If the sound comes from the map --
        table.insert(MapSound, source) -- Insert the sound in the MapSound table --
        muteMapMusic()
    end

end
addEventHandler("onClientSoundStarted", root, DetectMapMusic)



function muteMapMusic()
    if MapSound and isSongPaused == false then

        for f, u in pairs(MapSound) do
            setSoundVolume(u, 0)
            if not isSoundPaused(u) then
                setSoundPaused(u, true)
            end
        end
    end
end





 
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





function deleteSelectedSong()
    local theSelectedItem = guiGridListGetSelectedItem(QueueList)



    if theSelectedItem == -1 or theSelectedItem == false then outputChatBox("No song selected.", 255,0,0) return end
    local theSelectedItem = theSelectedItem+1
    table.remove(Playlist,theSelectedItem)

    updatePlaylist()
end

function PauseBind()
    if isSongPaused == true then -- if song is paused
        setSoundPaused( playingSong, false )
        guiStaticImageLoadImage( PlayButton, "/img/p_play.png" )
        isSongPaused = false
        popUpAnim()
    elseif isSongPaused == false then -- if song is not paused
        setSoundPaused( playingSong, true )
        guiStaticImageLoadImage( PlayButton, "/img/p_pause.png" )
        isSongPaused = true
    end
end
bindKey("m", "down", PauseBind)