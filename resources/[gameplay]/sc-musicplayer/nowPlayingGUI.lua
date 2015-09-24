UItimeShown = 5000 -- Time shown in MS --

----------GUI-----------

	screenWidth,screenHeight = guiGetScreenSize() -- get the screen size --

function calculateDX()
    local OGscreenX, OGscreenY = 1920, 1080
    local screenX, screenY = guiGetScreenSize()
    scaleX = screenX/OGscreenX
    scaleY = screenY/OGscreenY

    -- scaleTitle = screenX/OGscreenX*1.0
    scaleTitle = 1
    -- scaleUsername = screenX/OGscreenX*1.80
    scaleUsername = 1.5

    -- disable second title line for low res
    if screenHeight <= 800 then 
        titleWordBreak = false
    else
        titleWordBreak = true
    end



    drawAvatarPopup()


end
addEventHandler("onClientResourceStart", resourceRoot, calculateDX)

function drawAvatarPopup()

  


    local backGroundPopupWidthCalculate = 0.3/2
    backGroundPopup = guiCreateStaticImage(0.5-backGroundPopupWidthCalculate, 0.05, backGroundPopupWidthCalculate*2, 0.10, "/img/Outline.png", true)


    -- 0.38,
	guiSetVisible(backGroundPopup,false)
    guiSetAlpha( backGroundPopup, 0.75 )






	-- AvatarPopup = guiCreateStaticImage (screenWidth/100*41.7, screenHeight/100*93, 60, 60, "/img/artwork-placeholder.png", false ) GOED
    AvatarPopup = guiCreateStaticImage(0.05, 0.08, 0.17, 0.75, "/img/artwork-placeholder.png", true, backGroundPopup)
    guiSetSize( AvatarPopup, 90*scaleY, 90*scaleY, false )
	guiSetVisible(AvatarPopup,false)
    guiSetAlpha( AvatarPopup, 0.85 )




    shinyPopup = guiCreateStaticImage (0.05, 0.15, 0.17, 0.75, "/img/shine.png", true, backGroundPopup )

    local avaX, avaY = guiGetPosition( AvatarPopup, true )
    guiSetPosition( shinyPopup, avaX, avaY, true )
    local avaW, avaH = guiGetSize( AvatarPopup, true )
    guiSetSize( shinyPopup, avaW, avaH, true )
    guiSetVisible(shinyPopup,false)
    guiSetAlpha( shinyPopup, 0.6 )



    -- Dummy dimentions for dxDrawText

    DUMMYtitleRelative1 = guiCreateMemo( 0.253, 0.24, 0.73, 0.28, "Get X Y pos for title", true, backGroundPopup) 
    DUMMYtitleRelative2 = guiCreateButton( 0.5, 0.53, 0.2, 0.2, "Get Y bounding Box for title", true, backGroundPopup)

    guiSetVisible(DUMMYtitleRelative1 ,true)
    guiSetAlpha( DUMMYtitleRelative1, 0 )

    DUMMYtitleWidth, DUMMYtitleHeight = guiGetSize( DUMMYtitleRelative1, false )
    guiSetVisible(DUMMYtitleRelative2 ,true)
    guiSetAlpha( DUMMYtitleRelative2, 0 )


    DUMMYusernameRelative1 = guiCreateMemo( 0.253, 0.5, 0.59, 0.4, "Get X Y pos for username", true, backGroundPopup)
    DUMMYusernameRelative2 = guiCreateButton( 0.253, 0.9, 0.59, 0.4, "Get Y bounding Box for username", true, backGroundPopup)

    guiSetVisible(DUMMYusernameRelative1 ,true)
    guiSetAlpha( DUMMYusernameRelative1, 0 )
    DUMMYusernameWidth, DUMMYusernameHeight = guiGetSize( DUMMYusernameRelative1, false )

    guiSetVisible(DUMMYusernameRelative2 ,true)
    guiSetAlpha( DUMMYusernameRelative2, 0 )





    SCLogo = guiCreateStaticImage(0.85, 0.62, 0.12, 0.28, "/img/sclogo.png", true, backGroundPopup)
    guiSetAlpha(SCLogo, 0.12)
    guiSetVisible(SCLogo,false)
    
	

	
    


end



function showUI()
    replaceArtwork()

    popUpAnim()

end



function drawUItext()
	-- 


    if currentlyPlaying["title"] ~= "nil" and currentlyPlaying["user"]["username"] ~= "nil" then
        local uiPosX, uiPosY = guiGetPosition( backGroundPopup, false )
        local title1X, title1Y = guiGetPosition( DUMMYtitleRelative1, false )
        local title2X, title2Y = guiGetPosition( DUMMYtitleRelative2, false )

        local username1X, username1Y = guiGetPosition( DUMMYusernameRelative1, false )
        local username2X, username2Y = guiGetPosition( DUMMYusernameRelative2, false )        

        title = dxDrawText(currentlyPlaying["title"], uiPosX+title1X, uiPosY+title1Y, uiPosX+title1X+DUMMYtitleWidth, uiPosY+title2Y, tocolor(0, 0, 0, 180), scaleTitle, "default", "left", "top", true, titleWordBreak, true, false, false)
        titleBG = dxDrawText(currentlyPlaying["title"], uiPosX+title1X-1, uiPosY+title1Y-1, uiPosX+title1X+DUMMYtitleWidth-1, uiPosY+title2Y-1, tocolor(255, 255, 255, 180), scaleTitle, "default", "left", "top", true, titleWordBreak, true, false, false)


        username = dxDrawText(currentlyPlaying["user"]["username"], uiPosX+username1X, uiPosY+username1Y, uiPosX+username1X+DUMMYusernameWidth, uiPosY+username2Y, tocolor(0, 0, 0, 180), scaleUsername, "default-bold", "left", "center", true, false, true, false, false)
        usernameBG = dxDrawText(currentlyPlaying["user"]["username"], uiPosX+username1X-1, uiPosY+username1Y-1, uiPosX+username1X+DUMMYusernameWidth-1, uiPosY+username2Y-1, tocolor(103, 103, 103, 180), scaleUsername, "default-bold", "left", "center", true, false, true, false, false)


    end
end



function popUpAnim()
    local windowx, windowy = guiGetPosition( backGroundPopup, true )
    -- Animation.createAndPlay(backGroundPopup, Animation.presets.guiMove(windowx, 0.05, 500, false, windowx, windowy, false))
    if isTimer( popupTimer ) then 
        killTimer( popupTimer)
        popupTimer = setTimer(popDownAnim, UItimeShown, 1)
    else
        popupTimer = setTimer(popDownAnim, UItimeShown, 1)
    end

    isPopupShowing = true

    --Show GUI
    if drawUItextSHOW ~= true then
        addEventHandler ( "onClientRender", root, drawUItext )
        drawUItextSHOW = true
    end
    
    guiSetVisible(backGroundPopup,true)
    guiSetVisible(AvatarPopup,true)
    guiSetVisible(SCLogo,true)
end

function popDownAnim()
    local windowx, windowy = guiGetPosition( backGroundPopup, true )

        isPopupShowing = false 

        --Hide GUI
        if drawUItextSHOW == true then
            removeEventHandler ( "onClientRender", root, drawUItext ) 
            drawUItextSHOW = false
        end
        guiSetVisible(backGroundPopup,false)
        guiSetVisible(AvatarPopup,false)
        guiSetVisible(SCLogo,false)

end




