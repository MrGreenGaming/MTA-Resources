--GUI
SearchResultTEXT = {}
Results_Add = {}

postGUI = false


addEventHandler("onClientResourceStart", resourceRoot,
    function()
local screenW, screenH = guiGetScreenSize()
        guiSetInputMode("no_binds_when_editing")

        theAlpha = 255

        MainWindow = guiCreateStaticImage((screenW - 624) / 2, (screenH - 468) / 2, 624, 468, "/img/artwork-placeholder.png", false) -- Invisible Window


        MainWindowX, MainWindowY = guiGetPosition( MainWindow, false )

        PlayButton = guiCreateStaticImage(61, 430, 32, 28, "/img/p_play.png", false, MainWindow)


        PreviousButton = guiCreateStaticImage(23, 435, 23, 19, "/img/p_previous.png", false, MainWindow)



        NextButton = guiCreateStaticImage(103, 435, 23, 20, "/img/p_next.png", false, MainWindow)



        -- SettingsButton = guiCreateStaticImage(10, 5, 34, 26, "/img/p_settings_button.png", false, MainWindow)

        CloseButton = guiCreateStaticImage(580, 5, 34, 26, "/img/p_close_button.png", false, MainWindow)


        SearchButton = guiCreateStaticImage(585, 71, 20, 20, "/img/p_search.png", false, MainWindow)


        SearchBox = guiCreateEdit(420, 66, 155, 25, "", false, MainWindow)


        SearchResult1 = guiCreateStaticImage(382, 125, 241, 31, "/img/p_lineSpacer.png", false, MainWindow)
        local sr1x, sr1y, sr1w, sr1h = getDummyDimensions(SearchResult1, true)
        SearchResult1TEXT = guiCreateLabel( sr1x+5, sr1y+4.5, sr1w-33, sr1h-9.5, " ", false, MainWindow )
        guiLabelSetHorizontalAlign(SearchResult1TEXT, "left", true)
        guiLabelSetVerticalAlign(SearchResult1TEXT, "top")
        guiSetFont( SearchResult1TEXT, "default-small" )

        SearchResult2 = guiCreateStaticImage(382, 156, 241, 31, "/img/p_lineSpacer.png", false, MainWindow)
        local sr2x, sr2y, sr2w, sr2h = getDummyDimensions(SearchResult2, true)
        SearchResult2TEXT = guiCreateLabel( sr2x+5, sr2y+4.5, sr2w-33, sr2h-9.5, " ", false, MainWindow )
        guiLabelSetHorizontalAlign(SearchResult2TEXT, "left", true)
        guiLabelSetVerticalAlign(SearchResult2TEXT, "top")
        guiSetFont( SearchResult2TEXT, "default-small" )

        SearchResult3 = guiCreateStaticImage(382, 187, 241, 31, "/img/p_lineSpacer.png", false, MainWindow)
        local sr3x, sr3y, sr3w, sr3h = getDummyDimensions(SearchResult3, true)
        SearchResult3TEXT = guiCreateLabel( sr3x+5, sr3y+4.5, sr3w-33, sr3h-9.5, " ", false, MainWindow )
        guiLabelSetHorizontalAlign(SearchResult3TEXT, "left", true)
        guiLabelSetVerticalAlign(SearchResult3TEXT, "top")
        guiSetFont( SearchResult3TEXT, "default-small" )

        SearchResult4 = guiCreateStaticImage(382, 218, 241, 31, "/img/p_lineSpacer.png", false, MainWindow)
        local sr4x, sr4y, sr4w, sr4h = getDummyDimensions(SearchResult4, true)
        SearchResult4TEXT = guiCreateLabel( sr4x+5, sr4y+4.5, sr4w-33, sr4h-9.5, " ", false, MainWindow )
        guiLabelSetHorizontalAlign(SearchResult4TEXT, "left", true)
        guiLabelSetVerticalAlign(SearchResult4TEXT, "top")
        guiSetFont( SearchResult4TEXT, "default-small" )

        SearchResult5 = guiCreateStaticImage(382, 249, 241, 31, "/img/p_lineSpacer.png", false, MainWindow)
        local sr5x, sr5y, sr5w, sr5h = getDummyDimensions(SearchResult5, true)
        SearchResult5TEXT = guiCreateLabel( sr5x+5, sr5y+4.5, sr5w-33, sr5h-9.5, " ", false, MainWindow )
        guiLabelSetHorizontalAlign(SearchResult5TEXT, "left", true)
        guiLabelSetVerticalAlign(SearchResult5TEXT, "top")
        guiSetFont( SearchResult5TEXT, "default-small" )

        SearchResult6 = guiCreateStaticImage(382, 280, 241, 31, "/img/p_lineSpacer.png", false, MainWindow)
        local sr6x, sr6y, sr6w, sr6h = getDummyDimensions(SearchResult6, true)
        SearchResult6TEXT = guiCreateLabel( sr6x+5, sr6y+4.5, sr6w-33, sr6h-9.5, " ", false, MainWindow )
        guiLabelSetHorizontalAlign(SearchResult6TEXT, "left", true)
        guiLabelSetVerticalAlign(SearchResult6TEXT, "top")
        guiSetFont( SearchResult6TEXT, "default-small" )

        SearchResult7 = guiCreateStaticImage(382, 311, 241, 31, "/img/p_lineSpacer.png", false, MainWindow)
        local sr7x, sr7y, sr7w, sr7h = getDummyDimensions(SearchResult7, true)
        SearchResult7TEXT = guiCreateLabel( sr7x+5, sr7y+4.5, sr7w-33, sr7h-9.5, " ", false, MainWindow )
        guiLabelSetHorizontalAlign(SearchResult7TEXT, "left", true)
        guiLabelSetVerticalAlign(SearchResult7TEXT, "top")
        guiSetFont( SearchResult7TEXT, "default-small" )

        SearchResult8 = guiCreateStaticImage(382, 342, 241, 31, "/img/p_lineSpacer.png", false, MainWindow)
        local sr8x, sr8y, sr8w, sr8h = getDummyDimensions(SearchResult8, true)
        SearchResult8TEXT = guiCreateLabel( sr8x+5, sr8y+4.5, sr8w-33, sr8h-9.5, " ", false, MainWindow )
        guiLabelSetHorizontalAlign(SearchResult8TEXT, "left", true)
        guiLabelSetVerticalAlign(SearchResult8TEXT, "top")
        guiSetFont( SearchResult8TEXT, "default-small" )

        SearchResultTEXT[1] = SearchResult1TEXT
        SearchResultTEXT[2] = SearchResult2TEXT
        SearchResultTEXT[3] = SearchResult3TEXT
        SearchResultTEXT[4] = SearchResult4TEXT
        SearchResultTEXT[5] = SearchResult5TEXT
        SearchResultTEXT[6] = SearchResult6TEXT
        SearchResultTEXT[7] = SearchResult7TEXT
        SearchResultTEXT[8] = SearchResult8TEXT


        -- Results_PLAY = guiCreateStaticImage(10, 10, 16, 16, "/img/p_RESULT_play.png", false, MainWindow)
        Results_Add1 = guiCreateStaticImage(215, 10, 16, 16, "/img/p_add.png", false, SearchResult1)
        -- guiSetVisible( Results_PLAY, false )
        guiSetVisible( Results_Add1, false )

        -- Results_PLAY2 = guiCreateStaticImage(10, 10, 16, 16, "/img/p_RESULT_play.png", false, SearchResult2)
        Results_Add2 = guiCreateStaticImage(215, 10, 16, 16, "/img/p_add.png", false, SearchResult2)
        guiSetVisible( Results_Add2, false )

        -- Results_PLAY3 = guiCreateStaticImage(10, 10, 16, 16, "/img/p_RESULT_play.png", false, SearchResult3)
        Results_Add3 = guiCreateStaticImage(215, 10, 16, 16, "/img/p_add.png", false, SearchResult3)
        guiSetVisible( Results_Add3, false )

        -- Results_PLAY4 = guiCreateStaticImage(10, 10, 16, 16, "/img/p_RESULT_play.png", false, SearchResult4)
        Results_Add4 = guiCreateStaticImage(215, 10, 16, 16, "/img/p_add.png", false, SearchResult4)
        guiSetVisible( Results_Add4, false )

        -- Results_PLAY5 = guiCreateStaticImage(10, 10, 16, 16, "/img/p_RESULT_play.png", false, SearchResult5)
        Results_Add5 = guiCreateStaticImage(215, 10, 16, 16, "/img/p_add.png", false, SearchResult5)
        guiSetVisible( Results_Add5, false )

        -- Results_PLAY6 = guiCreateStaticImage(10, 10, 16, 16, "/img/p_RESULT_play.png", false, SearchResult6)
        Results_Add6 = guiCreateStaticImage(215, 10, 16, 16, "/img/p_add.png", false, SearchResult6)
        guiSetVisible( Results_Add6, false )

        -- Results_PLAY7 = guiCreateStaticImage(10, 10, 16, 16, "/img/p_RESULT_play.png", false, SearchResult7)
        Results_Add7 = guiCreateStaticImage(215, 10, 16, 16, "/img/p_add.png", false, SearchResult7)
        guiSetVisible( Results_Add7, false )

        -- Results_PLAY8 = guiCreateStaticImage(10, 10, 16, 16, "/img/p_RESULT_play.png", false, SearchResult8)
        Results_Add8 = guiCreateStaticImage(215, 10, 16, 16, "/img/p_add.png", false, SearchResult8)
        guiSetVisible( Results_Add8, false )

        Results_Add[1] = Results_Add1
        Results_Add[2] = Results_Add2
        Results_Add[3] = Results_Add3
        Results_Add[4] = Results_Add4
        Results_Add[5] = Results_Add5
        Results_Add[6] = Results_Add6
        Results_Add[7] = Results_Add7
        Results_Add[8] = Results_Add8


        QueueList = guiCreateGridList(35, 138, 311, 213, false, MainWindow)
        guiGridListAutoSizeColumn(QueueList,1)
        guiGridListSetSortingEnabled(QueueList,false)




        QueueList_Title = guiGridListAddColumn(QueueList, "Playlist", 0.95)
        -- Queuelist_Duration = guiGridListAddColumn(QueueList, "Duration", 0.5)
        -- guiGridListAddRow(QueueList)
        -- guiGridListSetItemText(QueueList, 0, 1, "-", false, false)
        -- guiGridListSetItemText(QueueList, 0, 2, "-", false, false)

        deleteSelectedSongBUTTON_Mainwindow = guiCreateButton(35, 360, 80, 20, "Delete Song", false, MainWindow)
        clearPlaylistBUTTON_Mainwindow = guiCreateButton(120, 360, 50, 20, "Clear", false, MainWindow)
        savePlaylistBUTTON_Mainwindow = guiCreateButton(240, 360, 50, 20, "Save", false, MainWindow)
        loadPlaylistBUTTON_Mainwindow = guiCreateButton(295, 360, 50, 20, "Load", false, MainWindow)
        

        Avatar = guiCreateStaticImage(35, 52, 70, 70, "/img/artwork-placeholder.png", false, MainWindow)
        shiny = guiCreateStaticImage(35, 52, 70, 70, "/img/shine.png", false, MainWindow)
        guiSetVisible( shiny, false )

        ProgressBar = guiCreateStaticImage(195, 430, 346, 20, "/img/p_timebar.png", false, MainWindow)
        ProgressBarX, ProgressBarY, ProgressBarW, ProgressBarH = getDummyDimensions(ProgressBar, false)
        
        -- Dummies
        SongTitle_DUMMY = guiCreateButton(113, 52, 253, 29, "SONG TITLE DUMMY DIMENTION", false, MainWindow)
        guiSetAlpha(SongTitle_DUMMY, 0)
        SongTitleX, SongTitleY, SongTitleW, SongTitleH = getDummyDimensions(SongTitle_DUMMY)



        SongUsername_DUMMY = guiCreateButton(114, 81, 252, 35, "SONG USERNAME DUMMY DIMENTION", false, MainWindow)
        guiSetAlpha(SongUsername_DUMMY, 0)
        SongUsernameX, SongUsernameY, SongUsernameW, SongUsernameH = getDummyDimensions(SongUsername_DUMMY)

        SearchLabel_DUMMY = guiCreateButton(423, 36, 152, 25, "SEARCH DUMMY DIMENTION", false, MainWindow)
        guiSetAlpha(SearchLabel_DUMMY, 0)
        SearchLabelX, SearchLabelY, SearchLabelW, SearchLabelH = getDummyDimensions(SearchLabel_DUMMY)


        WindowTitle_DUMMY = guiCreateButton(222, 2, 181, 34, "Window Title", false, MainWindow)
        guiSetAlpha(WindowTitle_DUMMY, 0)
        WindowTitleX, WindowTitleY, WindowTitleW, WindowTitleH = getDummyDimensions(WindowTitle_DUMMY)

        ElapsedTime_DUMMY = guiCreateButton(523, 431, 69, 20, "", false, MainWindow)
        guiSetAlpha(ElapsedTime_DUMMY, 0)
        ElapsedTimeX, ElapsedTimeY, ElapsedTimeW, ElapsedTimeH = getDummyDimensions(ElapsedTime_DUMMY)

        guiSetVisible( MainWindow, false )


        -- Save Playlist GUI

        SavePlaylistWindow = guiCreateStaticImage((screenW - 624) / 2, (screenH - 468) / 2, 624, 468, "img/artwork-placeholder.png", false)

        SavePlaylist_Gridlist = guiCreateGridList(111, 124, 403, 328, false, SavePlaylistWindow)
        SavePlaylist_GridlistColumn = guiGridListAddColumn(SavePlaylist_Gridlist, "All Playlists", 0.9)


        SavePlaylist_EditBox_Name = guiCreateEdit(112, 72, 214, 27, "", false, SavePlaylistWindow)
        guiSetProperty(SavePlaylist_EditBox_Name, "ValidationString", "^[a-zA-Z ]*$") -- disallows wierd characters that can break the script

        SavePlaylist_SaveButton = guiCreateButton(336, 68, 61, 31, "Save", false, SavePlaylistWindow)
        guiSetProperty(SavePlaylist_SaveButton, "NormalTextColour", "FFAAAAAA")
        PlaylistNameLABEL = guiCreateLabel(175, 50, 102, 22, "Playlist Name", false, SavePlaylistWindow)
        SavePlaylist_CancelButton = guiCreateButton(453, 68, 61, 31, "Cancel", false, SavePlaylistWindow)
        guiSetProperty(SavePlaylist_CancelButton, "NormalTextColour", "FFAAAAAA")  

        CloseButton_SavePlaylist = guiCreateStaticImage(580, 5, 34, 26, "/img/p_close_button.png", false, SavePlaylistWindow)

        guiSetVisible(SavePlaylistWindow, false)  

        -- Load Playlist GUI

        LoadPlaylistWindow = guiCreateStaticImage((screenW - 624) / 2, (screenH - 468) / 2, 624, 468, "img/artwork-placeholder.png", false)

        LoadPlaylist_Gridlist = guiCreateGridList(111, 70, 403, 328, false, LoadPlaylistWindow)
        LoadPlaylist_GridlistColumn = guiGridListAddColumn(LoadPlaylist_Gridlist, "All Playlists", 0.9)

        LoadPlaylist_LoadButton = guiCreateButton(530, 68, 61, 31, "Load", false, LoadPlaylistWindow)
        guiSetProperty(LoadPlaylist_LoadButton, "NormalTextColour", "FFAAAAAA")

        LoadPlaylist_DeleteButton = guiCreateButton(530, 120, 61, 31, "Delete", false, LoadPlaylistWindow)
        guiSetProperty(LoadPlaylist_DeleteButton, "NormalTextColour", "FFAAAAAA")

        -- PlaylistNameLABEL = guiCreateLabel(175, 50, 102, 22, "Playlist Name", false, LoadPlaylistWindow)
        LoadPlaylist_CancelButton = guiCreateButton(530, 400, 61, 31, "Cancel", false, LoadPlaylistWindow)
        guiSetProperty(LoadPlaylist_CancelButton, "NormalTextColour", "FFAAAAAA")  

        CloseButton_LoadPlaylist = guiCreateStaticImage(580, 5, 34, 26, "/img/p_close_button.png", false, LoadPlaylistWindow)

        guiSetVisible(LoadPlaylistWindow, false)  

    end
)


function getDummyDimensions(TheGui, trueorfalse)
    if TheGui ~= nil and trueorfalse ~= true then
        local Xmin, Ymin = guiGetPosition(TheGui, false)
        local X = Xmin+MainWindowX
        local Y = Ymin+MainWindowY
        local Wide, High = guiGetSize(TheGui, false)
        local W = X+Wide
        local H = Y+High
        return X, Y, W, H
    else
        local Xmin, Ymin = guiGetPosition(TheGui, false)
        local X = Xmin
        local Y = Ymin
        local Wide, High = guiGetSize(TheGui, false)
        local W = Wide
        local H = High
        return X, Y, W, H

    end

    
end


function drawDX()
    local winX, winY = guiGetPosition( MainWindow, false )
    local MainWindowVisibility = guiGetVisible(MainWindow)
    local SavePlaylistWindowVisibility = guiGetVisible(SavePlaylistWindow)
    local LoadPlaylistWindowVisibility = guiGetVisible(LoadPlaylistWindow)
    
    if MainWindowVisibility then -- draw window image
        DX_MainWindow = dxDrawImage( winX, winY, 624, 468, "/img/BG.png", 0, 0, 0, tocolor(255,255,255,255), false )
    elseif SavePlaylistWindowVisibility or LoadPlaylistWindowVisibility then
        DX_MainWindow = dxDrawImage( winX, winY, 624, 468, "/img/BGClear.png", 0, 0, 0, tocolor(255,255,255,255), false )
        
    end

    if MainWindowVisibility then
        
        

        DX_songTitle_Shadow = dxDrawText( nowPlaying_SongTitle, SongTitleX, SongTitleY , SongTitleW, SongTitleH, tocolor(0, 0, 0, 255), 1.00, "default", "left", "top", true, true, postGUI, false, false)
        DX_songTitle = dxDrawText( nowPlaying_SongTitle, SongTitleX-1, SongTitleY-1 , SongTitleW-1, SongTitleH-1, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", true, true, postGUI, false, false)

        DX_songUsername_Shadow = dxDrawText(nowPlaying_SongUsername, SongUsernameX, SongUsernameY , SongUsernameW, SongUsernameH, tocolor(0, 0, 0, 255), 1, "default-bold", "left", "center", true, false, postGUI, false, false)
        DX_songUsername = dxDrawText(nowPlaying_SongUsername, SongUsernameX-1, SongUsernameY-1 , SongUsernameW-1, SongUsernameH-1, tocolor(152, 152, 152, 255), 1, "default-bold", "left", "center", true, false, postGUI, false, false)
    
        DX_WindowTitle_Shadow = dxDrawText("SoundCloud Player", WindowTitleX, WindowTitleY, WindowTitleW, WindowTitleH, tocolor(0, 0, 0, 255), 2.00, "sans", "center", "center", false, false, postGUI, false, false)
        DX_WindowTitle = dxDrawText("SoundCloud Player", WindowTitleX-1, WindowTitleY-1, WindowTitleW-1, WindowTitleH-1, tocolor(255, 255, 255, 255), 2.00, "sans", "center", "center", false, false, postGUI, false, false)


        DX_SearchLabel_Shadow = dxDrawText("Search", SearchLabelX, SearchLabelY, SearchLabelW, SearchLabelH, tocolor(0, 0, 0, 255), 1.20, "default-bold", "center", "center", false, false, postGUI, false, false)
        DX_SearchLabel = dxDrawText("Search", SearchLabelX-1, SearchLabelY-1, SearchLabelW-1, SearchLabelH-1, tocolor(255, 255, 255, 255), 1.20, "default-bold", "center", "center", false, false, postGUI, false, false)

        
        
        if isTimer(nowPlaying_ElapsedTime) then

            local Time_Formatted = msToReadable(nowPlaying_SongDurationSeconds-getTimerDetails(nowPlaying_ElapsedTime))
            Time_FullDuration = msToReadable(nowPlaying_SongDurationSeconds )
            -- DX_TimeFormatted_Shadow = dxDrawText( Time_Formatted, ElapsedTimeX, ElapsedTimeY, ElapsedTimeW, ElapsedTimeH, tocolor(0, 0, 0, 255), 0.8, "default", "left", "center", false, false, true, false, false)
            DX_TimeFormatted = dxDrawText( Time_Formatted, ElapsedTimeX-383, ElapsedTimeY, ElapsedTimeW-400, ElapsedTimeH, tocolor(255, 255, 255, 255), 1, "default", "center", "center", true, false, postGUI, false, false)
            DX_TimeFullDuration = dxDrawText( Time_FullDuration, ElapsedTimeX+30, ElapsedTimeY, ElapsedTimeW, ElapsedTimeH, tocolor(255, 255, 255, 255), 1, "default", "left", "center", false, false, postGUI, false, false)
            
            paused_Time_Formatted = Time_Formatted

            --Progress Bar - 346 = max width
            local remainingTime_ProgressBar = getTimerDetails( nowPlaying_ElapsedTime )
            local toPercentage_ProgressBar = toPercent(tonumber(remainingTime_ProgressBar),tonumber(nowPlaying_SongDurationSeconds))
            local realPercentage = 100-toPercentage_ProgressBar
            local progressWidth = toAbsolute(realPercentage, 346)

            paused_ProgressWidth = progressWidth
            DX_ProgressBar = dxDrawRectangle( ProgressBarX, ProgressBarY+2, progressWidth, 18, tocolor(255,255,255,255), true)

        elseif isSongPaused then
            DX_TimeFormatted = dxDrawText( paused_Time_Formatted, ElapsedTimeX-383, ElapsedTimeY, ElapsedTimeW-400, ElapsedTimeH, tocolor(255, 255, 255, 255), 1, "default", "center", "center", true, false, postGUI, false, false)
            DX_TimeFullDuration = dxDrawText( Time_FullDuration, ElapsedTimeX+30, ElapsedTimeY, ElapsedTimeW, ElapsedTimeH, tocolor(255, 255, 255, 255), 1, "default", "left", "center", false, false, postGUI, false, false)

            DX_ProgressBar = dxDrawRectangle( ProgressBarX, ProgressBarY+2, paused_ProgressWidth, 18, tocolor(255,255,255,255), true)
        end

    elseif SavePlaylistWindowVisibility then 
        -- local winX, winY = guiGetPosition( SavePlaylistWindow, false )
        -- DX_SavePlaylistWindow = dxDrawImage( winX, winY, 624, 468, "/img/BG.png", 0, 0, 0, tocolor(255,255,255,255), false )
        DX_WindowTitle_Shadow = dxDrawText("Save Playlist", WindowTitleX, WindowTitleY, WindowTitleW, WindowTitleH, tocolor(0, 0, 0, 255), 2.00, "sans", "center", "center", false, false, postGUI, false, false)
        DX_WindowTitle = dxDrawText("Save Playlist", WindowTitleX-1, WindowTitleY-1, WindowTitleW-1, WindowTitleH-1, tocolor(255, 255, 255, 255), 2.00, "sans", "center", "center", false, false, postGUI, false, false)
   
    elseif LoadPlaylistWindowVisibility then 
        -- local winX, winY = guiGetPosition( LoadPlaylistWindow, false )
        -- DX_LoadPlaylistWindow = dxDrawImage( winX, winY, 624, 468, "/img/BG.png", 0, 0, 0, tocolor(255,255,255,255), false )
        DX_WindowTitle_Shadow = dxDrawText("Load Playlist", WindowTitleX, WindowTitleY, WindowTitleW, WindowTitleH, tocolor(0, 0, 0, 255), 2.00, "sans", "center", "center", false, false, postGUI, false, false)
        DX_WindowTitle = dxDrawText("Load Playlist", WindowTitleX-1, WindowTitleY-1, WindowTitleW-1, WindowTitleH-1, tocolor(255, 255, 255, 255), 2.00, "sans", "center", "center", false, false, postGUI, false, false)


    end


end
addEventHandler("onClientRender", root, drawDX)

function PlayPauseButton()
    if isSongPaused == true then -- if song is paused
        setSoundPaused( playingSong, false )
        guiStaticImageLoadImage( PlayButton, "/img/p_play.png" )
        isSongPaused = false
    elseif isSongPaused == false then -- if song is not paused
        setSoundPaused( playingSong, true )
        guiStaticImageLoadImage( PlayButton, "/img/p_pause.png" )
        isSongPaused = true

    end
end


function on_MouseEnterHandler() -- Hover 
    local hcR, hcG, hcB = 112,112,112
    if source == PlayButton and isSongPaused == true  then -- If song is not paused
        guiStaticImageLoadImage( PlayButton, "/img/p_play_hover.png" )

    elseif source == PlayButton and isSongPaused == false then -- If song is paused
        guiStaticImageLoadImage( PlayButton, "/img/p_pause_hover.png" )
    
    elseif source == PreviousButton then
        guiStaticImageLoadImage( PreviousButton, "/img/p_previous_hover.png" )

    elseif source == NextButton then
        guiStaticImageLoadImage( NextButton, "/img/p_next_hover.png" )

    elseif source == SearchButton then
        guiStaticImageLoadImage( SearchButton, "/img/p_search_click.png" )


    elseif source == SettingsButton then
        guiStaticImageLoadImage( SettingsButton, "/img/p_settings_button_hover.png" ) 

    elseif source == SearchResult1TEXT then 
        guiLabelSetColor( SearchResult1TEXT, hcR, hcG, hcB )
        guiBringToFront(source)

    elseif source == SearchResult2TEXT then 
        guiLabelSetColor( SearchResult2TEXT, hcR, hcG, hcB )
        guiBringToFront(source)

    elseif source == SearchResult3TEXT then 
        guiLabelSetColor( SearchResult3TEXT, hcR, hcG, hcB )
        guiBringToFront(source)

    elseif source == SearchResult4TEXT then 
        guiLabelSetColor( SearchResult4TEXT, hcR, hcG, hcB )
        guiBringToFront(source)

    elseif source == SearchResult5TEXT then 
        guiLabelSetColor( SearchResult5TEXT, hcR, hcG, hcB )
        guiBringToFront(source)

    elseif source == SearchResult6TEXT then
        guiLabelSetColor( SearchResult6TEXT, hcR, hcG, hcB )
        guiBringToFront(source)

    elseif source == SearchResult7TEXT then 
        guiLabelSetColor( SearchResult7TEXT, hcR, hcG, hcB )
        guiBringToFront(source)

    elseif source == SearchResult8TEXT then 
        guiLabelSetColor( SearchResult8TEXT, hcR, hcG, hcB )
        guiBringToFront(source)



    elseif source == Results_Add1 then 
        guiStaticImageLoadImage( source, "/img/p_add_hover.png" )
        

    elseif source == Results_Add2 then 
        guiStaticImageLoadImage( source, "/img/p_add_hover.png" )
        

    elseif source == Results_Add3 then 
        guiStaticImageLoadImage( source, "/img/p_add_hover.png" )
        

    elseif source == Results_Add4 then 
        guiStaticImageLoadImage( source, "/img/p_add_hover.png" )
        

    elseif source == Results_Add5 then 
        guiStaticImageLoadImage( source, "/img/p_add_hover.png" )
        

    elseif source == Results_Add6 then
        guiStaticImageLoadImage( source, "/img/p_add_hover.png" )
        

    elseif source == Results_Add7 then 
        guiStaticImageLoadImage( source, "/img/p_add_hover.png" )
        

    elseif source == Results_Add8 then 
        guiStaticImageLoadImage( source, "/img/p_add_hover.png" )
        



    elseif source == CloseButton then 
        guiStaticImageLoadImage( CloseButton, "/img/p_close_button_hover.png" ) 
    elseif source == CloseButton_SavePlaylist then 
        guiStaticImageLoadImage( CloseButton_SavePlaylist, "/img/p_close_button_hover.png" ) 
    elseif source == CloseButton_LoadPlaylist then 
        guiStaticImageLoadImage( CloseButton_LoadPlaylist, "/img/p_close_button_hover.png" ) 


    end
end
addEventHandler( "onClientMouseEnter", resourceRoot, on_MouseEnterHandler )


function on_MouseLeaveHandler() -- Remove hover
    if source == PlayButton and isSongPaused == true then -- If song is not paused
        guiStaticImageLoadImage( PlayButton, "/img/p_play.png" )


    elseif source == PlayButton and isSongPaused == false then -- If song is paused
        guiStaticImageLoadImage( PlayButton, "/img/p_pause.png" )
        

    elseif source == PreviousButton then
        guiStaticImageLoadImage( PreviousButton, "/img/p_previous.png" )

    elseif source == NextButton then
        guiStaticImageLoadImage( NextButton, "/img/p_next.png" )

    elseif source == SearchButton then
        guiStaticImageLoadImage( SearchButton, "/img/p_search.png" )

    elseif source == SettingsButton then
        guiStaticImageLoadImage( SettingsButton, "/img/p_settings_button.png" ) 

    elseif source == SearchResult1TEXT then 
        guiLabelSetColor( SearchResult1TEXT, 255, 255, 255 )

    elseif source == SearchResult2TEXT then 
        guiLabelSetColor( SearchResult2TEXT, 255, 255, 255 )

    elseif source == SearchResult3TEXT then 
        guiLabelSetColor( SearchResult3TEXT, 255, 255, 255 )

    elseif source == SearchResult4TEXT then 
        guiLabelSetColor( SearchResult4TEXT, 255, 255, 255 )

    elseif source == SearchResult5TEXT then 
        guiLabelSetColor( SearchResult5TEXT, 255, 255, 255 )

    elseif source == SearchResult6TEXT then
        guiLabelSetColor( SearchResult6TEXT, 255, 255, 255 )

    elseif source == SearchResult7TEXT then 
        guiLabelSetColor( SearchResult7TEXT, 255, 255, 255 )

    elseif source == SearchResult8TEXT then 
        guiLabelSetColor( SearchResult8TEXT, 255, 255, 255 )



    elseif source == Results_Add1 then 
        guiStaticImageLoadImage( source, "/img/p_add.png" )
        guiMoveToBack(source)

    elseif source == Results_Add2 then 
        guiStaticImageLoadImage( source, "/img/p_add.png" )
        guiMoveToBack(source)

    elseif source == Results_Add3 then 
        guiStaticImageLoadImage( source, "/img/p_add.png" )
        guiMoveToBack(source)

    elseif source == Results_Add4 then 
        guiStaticImageLoadImage( source, "/img/p_add.png" )
        guiMoveToBack(source)

    elseif source == Results_Add5 then 
        guiStaticImageLoadImage( source, "/img/p_add.png" )
        guiMoveToBack(source)

    elseif source == Results_Add6 then
        guiStaticImageLoadImage( source, "/img/p_add.png" )
        guiMoveToBack(source)

    elseif source == Results_Add7 then 
        guiStaticImageLoadImage( source, "/img/p_add.png" )
        guiMoveToBack(source)

    elseif source == Results_Add8 then 
        guiStaticImageLoadImage( source, "/img/p_add.png" )
        guiMoveToBack(source)



    elseif source == CloseButton then 
        guiStaticImageLoadImage( CloseButton, "/img/p_close_button.png" ) 
    elseif source == CloseButton_SavePlaylist then 
        guiStaticImageLoadImage( CloseButton_SavePlaylist, "/img/p_close_button.png" ) 
    elseif source == CloseButton_LoadPlaylist then 
        guiStaticImageLoadImage( CloseButton_LoadPlaylist, "/img/p_close_button.png" ) 


    end
end
addEventHandler( "onClientMouseLeave", resourceRoot, on_MouseLeaveHandler )

function on_MouseClickHandler() 
    if source == PlayButton then -- If song is not paused
        PlayPauseButton()


    elseif source == CloseButton then
        guiSetVisible( MainWindow, false )
        showCursor( false )
        guiSetInputEnabled(false)

    elseif source == CloseButton_LoadPlaylist then
        guiSetVisible( LoadPlaylistWindow, false )
        showCursor( false )
        guiSetInputEnabled(false)

    elseif source == CloseButton_SavePlaylist then
        guiSetVisible( SavePlaylistWindow, false )
        showCursor( false )
        guiSetInputEnabled(false)



        --save playlist window--

    elseif source == savePlaylistBUTTON_Mainwindow then
        populatePlaylistGridlist(SavePlaylist_Gridlist)
        guiSetVisible( MainWindow, false )
        guiSetVisible(SavePlaylistWindow, true)

    elseif source == SavePlaylist_CancelButton then
        guiSetVisible(SavePlaylistWindow, false)
        guiSetVisible( MainWindow, true )


    elseif source == SavePlaylist_SaveButton then -- the button in the save playlist window
        saveCurrentPlaylist()

    elseif source == SavePlaylist_Gridlist then
    	SavePlaylist_OverrideName()

        -- load playlist window

    elseif source == loadPlaylistBUTTON_Mainwindow then
    	populatePlaylistGridlist(LoadPlaylist_Gridlist)
    	guiSetVisible( MainWindow, false )
    	guiSetVisible(LoadPlaylistWindow, true)

    elseif source == LoadPlaylist_LoadButton then
    	loadPlaylist()

    elseif source == LoadPlaylist_DeleteButton then
    	deletePlaylist()
   	

    elseif source == LoadPlaylist_CancelButton then
    	guiSetVisible( MainWindow, true )
    	guiSetVisible(LoadPlaylistWindow, false)

    	--clear playlist button
    elseif source == clearPlaylistBUTTON_Mainwindow then
    	clearCurrentPlaylist()



       -- search results add to playlist 
    elseif source == Results_Add1 then 
        AddToPlaylistButton(1)
    elseif source == Results_Add2 then 
        AddToPlaylistButton(2)
    elseif source == Results_Add3 then 
        AddToPlaylistButton(3)
    elseif source == Results_Add4 then 
        AddToPlaylistButton(4)
    elseif source == Results_Add5 then 
        AddToPlaylistButton(5)
    elseif source == Results_Add6 then
        AddToPlaylistButton(6)
    elseif source == Results_Add7 then 
        AddToPlaylistButton(7)
    elseif source == Results_Add8 then 
        AddToPlaylistButton(8)


        -- play from search results --
    elseif source == SearchResult1TEXT then
        soundHandler(searchResults[1])
    elseif source == SearchResult2TEXT then
        soundHandler(searchResults[2])
    elseif source == SearchResult3TEXT then
        soundHandler(searchResults[3])
    elseif source == SearchResult4TEXT then
        soundHandler(searchResults[4])
    elseif source == SearchResult5TEXT then
        soundHandler(searchResults[5])
    elseif source == SearchResult6TEXT then
        soundHandler(searchResults[6])
    elseif source == SearchResult7TEXT then
        soundHandler(searchResults[7])
    elseif source == SearchResult8TEXT then
        soundHandler(searchResults[8])
    elseif source == SearchResult8TEXT then
        soundHandler(searchResults[8])



        -- Next and Previous Button --
    elseif source == PreviousButton then
    	NextorPrev("prev")
    elseif source == NextButton then
        NextorPrev("next")

        -- Delete Song Button --
    elseif source == deleteSelectedSongBUTTON_Mainwindow then
    	deleteSelectedSong()


    end
end
addEventHandler( "onClientGUIClick", resourceRoot, on_MouseClickHandler )

function on_MouseDoubleClickHandler()
    --Queuelist DoubleClick --
    if source == QueueList then
        clickedOnPlaylist()
    end
end
addEventHandler("onClientGUIDoubleClick", resourceRoot, on_MouseDoubleClickHandler)


function guiFocusHandler()
	if source == SearchBox then
		guiSetInputEnabled(true)
	elseif source == SavePlaylist_EditBox_Name then
		guiSetInputEnabled(true)

	end
end
addEventHandler( "onClientGUIFocus", resourceRoot, guiFocusHandler )

function guiBlurHandler()
	if source == SearchBox then
		guiSetInputEnabled(false)
	elseif source == SavePlaylist_EditBox_Name then
		guiSetInputEnabled(false)

	end
end
addEventHandler( "onClientGUIBlur", resourceRoot, guiBlurHandler )




function clearSearchResults()
    guiSetText(SearchResult1TEXT, " ")
    guiSetVisible( Results_Add1, false )
    guiSetText(SearchResult2TEXT, " ")
    guiSetVisible( Results_Add2, false )
    guiSetText(SearchResult3TEXT, " ")
    guiSetVisible( Results_Add3, false )
    guiSetText(SearchResult4TEXT, " ")
    guiSetVisible( Results_Add4, false )
    guiSetText(SearchResult5TEXT, " ")
    guiSetVisible( Results_Add5, false )
    guiSetText(SearchResult6TEXT, " ")
    guiSetVisible( Results_Add6, false )
    guiSetText(SearchResult7TEXT, " ")
    guiSetVisible( Results_Add7, false )
    guiSetText(SearchResult8TEXT, " ")
    guiSetVisible( Results_Add8, false )
end

-- Progress Bar, Math sucks --
function toPercent(currentValue, maxValue)
    return currentValue/maxValue*100
end


function toAbsolute(percent,maxValue)
    return maxValue/100*percent
end
-- end Progress Bar--


function OpenGUI()
    if not guiGetVisible( MainWindow) then
    	guiSetVisible(SavePlaylistWindow,false)
    	guiSetVisible(LoadPlaylistWindow,false)
        guiSetVisible( MainWindow, true )
        showCursor( true )
        local closex, closey = getDummyDimensions( CloseButton)
        setCursorPosition(closex+10,closey+10)
        
    elseif guiGetVisible(SavePlaylistWindow) == true or guiGetVisible(LoadPlaylistWindow) == true or guiGetVisible(MainWindow) == true then
        guiSetVisible(SavePlaylistWindow,false)
        guiSetVisible(LoadPlaylistWindow,false)
        guiSetVisible( MainWindow, false )
        showCursor( false )
    end
end
bindKey("f7","up",OpenGUI)
addEvent("sb_showMusicPlayer")
addEventHandler("sb_showMusicPlayer",root,OpenGUI)

-- Artwork Stuff

function replaceArtwork(songTable)
    if songTable["artwork_url"] ~= nil and songTable["artwork_url"] ~= "nil" then
        local artworkAvatarURL = songTable["artwork_url"]
        local artworkURL_HTTP = string.gsub(artworkAvatarURL, "https", "http") -- change HTTPS into HTTP
        local explodedURL = string.explode(artworkURL_HTTP, "?")


        local loadArtwork = guiStaticImageLoadImage( Avatar, explodedURL[1] )
        local loadArtworkPopup = guiStaticImageLoadImage(AvatarPopup, explodedURL[1])
        guiSetVisible(shiny,true)
        guiSetVisible(shinyPopup,true)

    else
        local loadArtwork = guiStaticImageLoadImage( Avatar, "/img/ava.png" )
        local loadArtworkPopup = guiStaticImageLoadImage( AvatarPopup, "/img/ava.png" )
        guiSetVisible(shiny,true)
        guiSetVisible(shinyPopup,true)
    end
end


local _loadingImage = "/img/artwork-placeholder.png"
local _waitingForImage = {}
local _imgsOnCache = {}
 
function isUrl( str )
    return string.sub(str, 1, 4) == "http"
end
 
function getExtension( str )
    return string.match(str, "([^%.]+)$")
end
 
local _guiCreateStaticImage = guiCreateStaticImage
function guiCreateStaticImage( x, y, width, height, path, relative, parent )
    if not isUrl(path) then return _guiCreateStaticImage( x, y, width, height, path, relative, parent ) end
    local img = _guiCreateStaticImage( x, y, width, height, _loadingImage, relative, parent )
    setRemoteImage(img, path)
    return img
end
 
local _guiStaticImageLoadImage = guiStaticImageLoadImage
function guiStaticImageLoadImage( elem, path )
    if not isUrl(path) then return _guiStaticImageLoadImage( elem, path ) end
    return setRemoteImage( elem, path )
end
 
function generateTmpFilename( img, path )
    local str = tostring(img).."_"..tostring(getTickCount()).."."..tostring(getExtension(path))
    str = string.gsub(str, "userdata: ", "")
    return str
end
 
function setRemoteImage( img, path )
    local currentPath = getElementData(img, "_url")
    if path ~= currentPath then
        setElementData(img, "_url", path)
        setElementData(img, "_tmpfile", generateTmpFilename(img, path))
        table.insert(_waitingForImage, img)
        return triggerServerEvent("onClientImageRequest", localPlayer, path)
    end
end
 
addEvent("onClientGotImageResponse", true)
function onClientGotImageResponse( path, datas, errno )
    local img, index = nil, nil
    for k, simage in ipairs (_waitingForImage) do
        if getElementData(simage, "_url") == path then
            img = simage
            index = k
            break
        end
    end
    if img and isElement(img) then
        local filename = getElementData(img, "_tmpfile")
        imageWriteToFile( filename, datas )
        _guiStaticImageLoadImage(img, filename)
        table.remove(_waitingForImage, index)
    end
end
addEventHandler("onClientGotImageResponse", root, onClientGotImageResponse)
 
function imageWriteToFile( filename, datas )
    local file = fileExists(filename) and fileOpen(filename) or fileCreate(filename)
    if file then
        fileWrite(file, datas)
        fileClose(file)
        table.insert(_imgsOnCache, filename)
    end
end
 
function cleanUp ()
    for k, filename in ipairs(_imgsOnCache) do
        fileDelete( filename )
    end
    if #_imgsOnCache > 0 then
        _imgsOnCache = {}
    end
end
addEventHandler("onClientResourceStop", resourceRoot, cleanUp)









function string.explode(self, separator)
    Check("string.explode", "string", self, "ensemble", "string", separator, "separator")
 
    if (#self == 0) then return {} end
    if (#separator == 0) then return { self } end
 
    return loadstring("return {\""..self:gsub(separator, "\",\"").."\"}")()
end

function Check(funcname, ...)
    local arg = {...}
 
    if (type(funcname) ~= "string") then
        error("Argument type mismatch at 'Check' ('funcname'). Expected 'string', got '"..type(funcname).."'.", 2)
    end
    if (#arg % 3 > 0) then
        error("Argument number mismatch at 'Check'. Expected #arg % 3 to be 0, but it is "..(#arg % 3)..".", 2)
    end
 
    for i=1, #arg-2, 3 do
        if (type(arg[i]) ~= "string" and type(arg[i]) ~= "table") then
            error("Argument type mismatch at 'Check' (arg #"..i.."). Expected 'string' or 'table', got '"..type(arg[i]).."'.", 2)
        elseif (type(arg[i+2]) ~= "string") then
            error("Argument type mismatch at 'Check' (arg #"..(i+2).."). Expected 'string', got '"..type(arg[i+2]).."'.", 2)
        end
 
        if (type(arg[i]) == "table") then
            local aType = type(arg[i+1])
            for _, pType in next, arg[i] do
                if (aType == pType) then
                    aType = nil
                    break
                end
            end
            if (aType) then
                error("Argument type mismatch at '"..funcname.."' ('"..arg[i+2].."'). Expected '"..table.concat(arg[i], "' or '").."', got '"..aType.."'.", 3)
            end
        elseif (type(arg[i+1]) ~= arg[i]) then
            error("Argument type mismatch at '"..funcname.."' ('"..arg[i+2].."'). Expected '"..arg[i].."', got '"..type(arg[i+1]).."'.", 3)
        end
    end
end

-- End Artwork Stuff

function var_dump(...)
    -- default options
    local verbose = false
    local firstLevel = true
    local outputDirectly = true
    local noNames = false
    local indentation = "\t\t\t\t\t\t"
    local depth = nil
 
    local name = nil
    local output = {}
    for k,v in ipairs(arg) do
        -- check for modifiers
        if type(v) == "string" and k < #arg and v:sub(1,1) == "-" then
            local modifiers = v:sub(2)
            if modifiers:find("v") ~= nil then
                verbose = true
            end
            if modifiers:find("s") ~= nil then
                outputDirectly = false
            end
            if modifiers:find("n") ~= nil then
                verbose = false
            end
            if modifiers:find("u") ~= nil then
                noNames = true
            end
            local s,e = modifiers:find("d%d+")
            if s ~= nil then
                depth = tonumber(string.sub(modifiers,s+1,e))
            end
        -- set name if appropriate
        elseif type(v) == "string" and k < #arg and name == nil and not noNames then
            name = v
        else
            if name ~= nil then
                name = ""..name..": "
            else
                name = ""
            end
 
            local o = ""
            if type(v) == "string" then
                table.insert(output,name..type(v).."("..v:len()..") \""..v.."\"")
            elseif type(v) == "userdata" then
                local elementType = "no valid MTA element"
                if isElement(v) then
                    elementType = getElementType(v)
                end
                table.insert(output,name..type(v).."("..elementType..") \""..tostring(v).."\"")
            elseif type(v) == "table" then
                local count = 0
                for key,value in pairs(v) do
                    count = count + 1
                end
                table.insert(output,name..type(v).."("..count..") \""..tostring(v).."\"")
                if verbose and count > 0 and (depth == nil or depth > 0) then
                    table.insert(output,"\t{")
                    for key,value in pairs(v) do
                        -- calls itself, so be careful when you change anything
                        local newModifiers = "-s"
                        if depth == nil then
                            newModifiers = "-sv"
                        elseif  depth > 1 then
                            local newDepth = depth - 1
                            newModifiers = "-svd"..newDepth
                        end
                        local keyString, keyTable = var_dump(newModifiers,key)
                        local valueString, valueTable = var_dump(newModifiers,value)
 
                        if #keyTable == 1 and #valueTable == 1 then
                            table.insert(output,indentation.."["..keyString.."]\t=>\t"..valueString)
                        elseif #keyTable == 1 then
                            table.insert(output,indentation.."["..keyString.."]\t=>")
                            for k,v in ipairs(valueTable) do
                                table.insert(output,indentation..v)
                            end
                        elseif #valueTable == 1 then
                            for k,v in ipairs(keyTable) do
                                if k == 1 then
                                    table.insert(output,indentation.."["..v)
                                elseif k == #keyTable then
                                    table.insert(output,indentation..v.."]")
                                else
                                    table.insert(output,indentation..v)
                                end
                            end
                            table.insert(output,indentation.."\t=>\t"..valueString)
                        else
                            for k,v in ipairs(keyTable) do
                                if k == 1 then
                                    table.insert(output,indentation.."["..v)
                                elseif k == #keyTable then
                                    table.insert(output,indentation..v.."]")
                                else
                                    table.insert(output,indentation..v)
                                end
                            end
                            for k,v in ipairs(valueTable) do
                                if k == 1 then
                                    table.insert(output,indentation.." => "..v)
                                else
                                    table.insert(output,indentation..v)
                                end
                            end
                        end
                    end
                    table.insert(output,"\t}")
                end
            else
                table.insert(output,name..type(v).." \""..tostring(v).."\"")
            end
            name = nil
        end
    end
    local string = ""
    for k,v in ipairs(output) do
        if outputDirectly then
            outputConsole(v)
        end
        string = string..v
    end
    return string, output
end




function msToReadable( lengte )
    if lengte then
        local lengte = lengte/1000

        local hours = 0
        local minutes = 0
        local secs = 0
        local theseconds = lengte
        if theseconds >= 60*60*24 then
            days = math.floor(theseconds / (60*60*24))
            theseconds = theseconds - ((60*60*24)*days)
        end
        if theseconds >= 60*60 then
            hours = math.floor(theseconds / (60*60))
            theseconds = theseconds - ((60*60)*hours)
        end
        if theseconds >= 60 then
            minutes = math.floor(theseconds / (60))
            theseconds = theseconds - ((60)*minutes)
        end
        if theseconds >= 1 then
            secs = theseconds
            theseconds = theseconds - theseconds
        end

        if hours < 10 then hours = "0"..hours end
        if minutes < 10 then minutes = "0"..minutes end 
        if secs == 60 then secs = 59 end
        if secs < 10 then secs = "0"..string.format("%.0f",secs)
        else secs = string.format("%.0f",secs) end




        if tonumber(hours) > 0 then -- With Hours
            return hours..":"..minutes..":"..secs
        else
            return minutes..":"..secs
        end
    end
    return ""
end

function guiGridListGetSelectedItemText ( gridList, column )
    local item = guiGridListGetSelectedItem ( gridList )
 
    if item then
        return guiGridListGetItemText ( gridList, item, column or 1 )
    end
 
    return false
end