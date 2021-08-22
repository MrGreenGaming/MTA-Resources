MapInfoWindow = {}
local screenX, screenY = guiGetScreenSize()
-- Set x and y after scaling
local x, y = 0, 0
local alphaFade = 1
-- Declare dimensions, will automatically be scaled
local dims = {}
dims.window = {
    width = 500,
    height = 140
}

dims.icons = {
    width = 20,
    height = 20,
    padding = 5
}

dims.lightHeader = {
    height = 13
}

dims.darkHeader = {
    height = 27
}

dims.leftColumn = {
    x = 30,
    firstY = 35,
    secondY = 65,
}

dims.rightColumn = {
    x = 320,
    firstY = 35,
    secondY = 65,
    thirdY = 90,
    fourthY = 115
}

dims.mapName = {
    startX = 20,
    endX = dims.window.width - 20,
    startY = 0,
    endY = dims.darkHeader.height,
    fontSize = 1.5
}

dims.likes = {
    iconX = dims.rightColumn.x,
    iconY = dims.rightColumn.firstY,
    startX = dims.rightColumn.x + dims.icons.width + dims.icons.padding,
    startY = dims.rightColumn.firstY,
    endX = 390,
    endY = dims.rightColumn.firstY + dims.icons.height,
    fontSize = 1,
}

dims.dislikes = {
    iconX = 400,
    iconY = dims.rightColumn.firstY,
    startX = 400 + dims.icons.width + dims.icons.padding,
    startY = dims.rightColumn.firstY,
    endX = 500,
    endY = dims.rightColumn.firstY + dims.icons.height,
    fontSize = 1,
}

dims.ratingsBar = {
    x = dims.likes.iconX,
    y = dims.likes.iconY + 24,
    width = 150
}

dims.rounds = {
    iconX = dims.likes.iconX,
    iconY = dims.rightColumn.secondY,
    startX = dims.likes.startX,
    startY = dims.rightColumn.secondY,
    endX = dims.likes.endX,
    endY = dims.rightColumn.secondY + dims.icons.height,
    fontSize = 1
}

dims.timesPlayed = {
    iconX = dims.dislikes.iconX,
    iconY = dims.rightColumn.secondY,
    startX = dims.dislikes.startX,
    startY = dims.rightColumn.secondY,
    endX = dims.dislikes.endX,
    endY = dims.rightColumn.secondY + dims.icons.height,
    fontSize = 1
}

dims.lastPlayed = {
    iconX = dims.likes.iconX,
    iconY = dims.rightColumn.thirdY,
    startX = dims.likes.startX,
    startY = dims.rightColumn.thirdY,
    endX = dims.likes.endX,
    endY = dims.rightColumn.thirdY + dims.icons.height,
    fontSize = 1
}

dims.uploadDate = {
    iconX = dims.lastPlayed.iconX,
    iconY = dims.rightColumn.fourthY,
    startX = dims.lastPlayed.startX,
    startY = dims.rightColumn.fourthY,
    endX = dims.lastPlayed.endX,
    endY = dims.rightColumn.fourthY + dims.icons.height,
    fontSize = 1
}

dims.author = {
    iconX = dims.leftColumn.x,
    iconY = dims.leftColumn.firstY,
    startX = dims.leftColumn.x + dims.icons.width + dims.icons.padding,
    startY = dims.leftColumn.firstY,
    endX = dims.rightColumn.x - dims.icons.width,
    endY = dims.leftColumn.firstY + dims.icons.height,
    fontSize = 1
}

dims.description = {
    iconX = dims.leftColumn.x,
    iconY = dims.leftColumn.secondY,
    startX = dims.leftColumn.x + dims.icons.width + dims.icons.padding,
    startY = dims.leftColumn.secondY,
    endX = dims.rightColumn.x - dims.icons.width,
    endY = dims.leftColumn.secondY + dims.icons.height + 25,
    fontSize = 1
}

dims.nextmap = {
    bgX = 0,
    bgY = 115,
    bgHeight = dims.window.height - 115,
    bgWidth = dims.window.width,
    iconX = dims.leftColumn.x,
    iconY = 117,
    startX = dims.leftColumn.x + dims.icons.width + dims.icons.padding,
    startY = 115,
    endX = 365,
    endY = dims.window.height,
    fontSize = 1,

    likeIconX = 370,
    likeStartX = 370 + dims.icons.width + 2,
    likeEndX = 500,


    dislikeIconX = 435,
    dislikeStartX = 435 + dims.icons.width + 2,
    dislikeEndX = dims.window.width,
}

local function calculatePosition()
    local screenX, screenY = guiGetScreenSize()
    x = (screenX-dims.window.width)/2
	y = screenY*3/4
end

local function scaleDimValues()
    local fromX, fromY = 1920, 1080
    local minimumScale = 1
    local scaleValue = math.max(minimumScale, screenY / fromY)

    for componentName, componentValue in pairs(dims) do
        for propertyName, protertyValue in pairs(componentValue) do
            dims[componentName][propertyName] = scaleValue * protertyValue
        end
    end
    calculatePosition()
end
scaleDimValues()

function MapInfoWindow.render()
    ------------------------
    ------ BACKGROUND ------
    ------------------------
    -- Window Backgrond
    dxDrawRectangle(x, y, dims.window.width, dims.window.height, tocolor(0, 0 , 0, 150 * alphaFade))

    --------------------
    ------ HEADER ------
    --------------------
    -- Header Dark background
    dxDrawRectangle(x, y, dims.window.width, dims.darkHeader.height, tocolor(25, 81, 61, 255 * alphaFade))
    -- Header Light background
    dxDrawRectangle(x, y, dims.window.width, dims.lightHeader.height, tocolor(30, 86, 66, 255 * alphaFade))

    ----------------------
    ------ MAP NAME ------
    ----------------------
    local shortName = MapData.currentMapInfo.name
    -- Test width to fit

    while dxGetTextWidth(shortName, dims.mapName.fontSize, "default-bold") > dims.mapName.endX - dims.mapName.startX do
        shortName = string.sub(shortName, 1, #shortName - 1)
    end
    -- dxDrawText(shortName, 5 + 8, 0 + 8, dimensions.width-5, dimensions.headerHeight, tocolor(0, 0, 0, 100), mapNameFontSize, "default-bold", "center", "center", true, false, false, false, true)
    dxDrawText(shortName, x + dims.mapName.startX, y + dims.mapName.startY - 3, x + dims.mapName.endX - 3, y + dims.mapName.endY, tocolor(0, 0, 0, 50 * alphaFade), dims.mapName.fontSize, "default-bold", "center", "center", true, false, false, false, true)
    dxDrawText(shortName, x + dims.mapName.startX, y + dims.mapName.startY, x + dims.mapName.endX, y + dims.mapName.endY, tocolor(255, 255, 255, 255 * alphaFade), dims.mapName.fontSize, "default-bold", "center", "center", true, false, false, false, true)

    -----------------
    -----RATINGS-----
    -----------------
    local likeColor = MapData.currentMapUserRate == 1 and tocolor(90, 189, 117, 255 * alphaFade) or tocolor(255,255,255, 255 * alphaFade)
    local dislikeColor = MapData.currentMapUserRate == 0 and tocolor(255,0,0, 255 * alphaFade) or tocolor(255,255,255, 255 * alphaFade)
    -- Like
    dxDrawImage(x + dims.likes.iconX, y + dims.likes.iconY, dims.icons.height, dims.icons.width, "/icons/thumbs-up.png", 0, 0, 0, likeColor)
    dxDrawText(formatLongNumber(MapData.currentMapRatings.likes), x + dims.likes.startX, y + dims.likes.startY, x + dims.likes.endX, y + dims.likes.endY, likeColor, dims.likes.fontSize,  "default-bold", "left", "center", true, false, false)

    -- Dislike
    dxDrawImage(x + dims.dislikes.iconX, y + dims.dislikes.iconY, dims.icons.height, dims.icons.width, "/icons/thumbs-down.png", 0, 0, 0, dislikeColor)
    dxDrawText(formatLongNumber(MapData.currentMapRatings.dislikes), x + dims.dislikes.startX, y + dims.dislikes.startY, x + dims.dislikes.endX, y + dims.dislikes.endY, dislikeColor, dims.dislikes.fontSize,  "default-bold", "left", "center", true, false, false)

    -- Base ratings bar
    dxDrawRectangle(x + dims.ratingsBar.x, y + dims.ratingsBar.y, dims.ratingsBar.width, 1, tocolor(255, 255, 255, 255 * alphaFade), false, true)

    -- Rating bar fill
    local likePercentage = dims.ratingsBar.width / 100 * (( MapData.currentMapRatings.likes + 1 ) / (MapData.currentMapRatings.likes + MapData.currentMapRatings.dislikes) * 100)
    likePercentage = likePercentage <= 0 and 0 or (likePercentage >= dims.ratingsBar.width and dims.ratingsBar.width or likePercentage)
    dxDrawRectangle(x + dims.ratingsBar.x, y + dims.ratingsBar.y, likePercentage , 1, tocolor(90, 189, 117, 255 * alphaFade), false, true)

    ---------------
    -- PLAY INFO --
    ---------------
    -- Rounds
    local roundsColor = {
        tocolor(90, 189, 117, 255 * alphaFade),
        tocolor(255, 246, 69, 255 * alphaFade),
        tocolor(255, 0, 0, 255 * alphaFade)
    }
    dxDrawImage(x + dims.rounds.iconX, y + dims.rounds.iconY, dims.icons.height, dims.icons.width, "/icons/repeat.png")
    dxDrawText(MapData.mapRoundsInfo.current.." / "..MapData.mapRoundsInfo.maximum, x + dims.rounds.startX, y + dims.rounds.startY, x + dims.rounds.endX, y + dims.rounds.endY, roundsColor[MapData.mapRoundsInfo.current or #roundsColor], dims.rounds.fontSize, "default-bold", "left", "center", false, false, false)

    -- Times Played
    dxDrawImage(x + dims.timesPlayed.iconX, y + dims.timesPlayed.iconY, dims.icons.height, dims.icons.width, "/icons/play.png")
    dxDrawText(MapData.currentMapInfo.timesPlayed .. " times", x + dims.timesPlayed.startX, y + dims.timesPlayed.startY, x + dims.timesPlayed.endX, y + dims.timesPlayed.endY, tocolor(255,255,255,255), dims.timesPlayed.fontSize, "default-bold", "left", "center", false, false, false)


    -- Last time played
    dxDrawImage(x + dims.lastPlayed.iconX, y + dims.lastPlayed.iconY, dims.icons.height, dims.icons.width, "/icons/history.png")
    dxDrawText(MapData.currentMapInfo.lastTimePlayed or "First time", x + dims.lastPlayed.startX, y + dims.lastPlayed.startY, x + dims.lastPlayed.endX, y + dims.lastPlayed.endY, tocolor(255,255,255 * alphaFade), dims.lastPlayed.fontSize, "default-bold", "left", "center", false, false, false)

    -- Upload date
    dxDrawImage(x + dims.uploadDate.iconX, y + dims.uploadDate.iconY, dims.icons.height, dims.icons.width, "/icons/upload.png")
    dxDrawText(MapData.currentMapInfo.uploadDate or "Unknown", x + dims.uploadDate.startX, y + dims.uploadDate.startY, x + dims.uploadDate.endX, y + dims.uploadDate.endY, tocolor(255,255,255 * alphaFade), dims.uploadDate.fontSize, "default-bold", "left", "center", false, false, false)

    ------------
    -- AUTHOR --
    ------------
    dxDrawImage(x + dims.author.iconX, y + dims.author.iconY, dims.icons.width, dims.icons.height, "/icons/user.png")
    dxDrawText(MapData.currentMapInfo.author, x + dims.author.startX, y + dims.author.startY, x + dims.author.endX, y + dims.author.endY, tocolor(90, 189, 117, 255 * alphaFade), dims.author.fontSize, "default-bold", "left", "center", true, false, false)

    ---------------
    --DESCRIPTION--
    ---------------

    local shortDescription = MapData.currentMapInfo.description ~= "" and MapData.currentMapInfo.description or "“This map does not have a description.”"
    dxDrawImage(x + dims.description.iconX, y + dims.description.iconY, dims.icons.width, dims.icons.height, "/icons/info.png")
    dxDrawText(shortDescription, x + dims.description.startX, y + dims.description.startY, x + dims.description.endX, y + dims.description.endY, tocolor(210, 210, 210, 255 * alphaFade), dims.description.fontSize, "default", "left", "top", true, true, false)

    ----------------------
    ------ NEXT MAP ------
    ----------------------
    --! Disabled next map UI since it's obsolete with more choices
    local nextmapColor = tocolor(255,255,255, 150 * alphaFade)
    -- background
    dxDrawRectangle(x + dims.nextmap.bgX, y + dims.nextmap.bgY, dims.nextmap.bgWidth, dims.nextmap.bgHeight, tocolor(0,0,0,100 * alphaFade))
    dxDrawLine(x + dims.nextmap.bgX, y + dims.nextmap.bgY, x + dims.nextmap.bgX + dims.window.width, y + dims.nextmap.bgY, tocolor(255, 255, 255, 100 * alphaFade), 1)

    -- -- Next map name
    -- dxDrawImage(x + dims.nextmap.iconX, y + dims.nextmap.iconY, dims.icons.width, dims.icons.height, "/icons/arrow-right.png", 0, 0, 0, nextmapColor)
    -- dxDrawText(MapData.nextMapRatings.name, x + dims.nextmap.startX, y + dims.nextmap.startY, x + dims.nextmap.endX, y + dims.nextmap.endY, nextmapColor, dims.nextmap.fontSize, "default", "left", "center", true, false, false)

    -- -- Next map ratings
    -- dxDrawImage(x + dims.nextmap.likeIconX, y + dims.nextmap.iconY, dims.icons.width, dims.icons.height, "/icons/thumbs-up.png", 0, 0, 0, nextmapColor)
    -- dxDrawText(formatLongNumber(MapData.nextMapRatings.likes), x + dims.nextmap.likeStartX, y + dims.nextmap.startY, x + dims.nextmap.likeEndX, y + dims.nextmap.endY, nextmapColor, dims.nextmap.fontSize, "default", "left", "center", true, false, false)

    -- dxDrawImage(x + dims.nextmap.dislikeIconX, y + dims.nextmap.iconY, dims.icons.width, dims.icons.height, "/icons/thumbs-down.png", 0, 0, 0, nextmapColor)
    -- dxDrawText(formatLongNumber(MapData.nextMapRatings.dislikes), x + dims.nextmap.dislikeStartX, y + dims.nextmap.startY, x + dims.nextmap.dislikeEndX, y + dims.nextmap.endY, nextmapColor, dims.nextmap.fontSize, "default", "left", "center", true, false, false)
end
local isShow = false

function stopShowing()
	isShow = false
	removeEventHandler('onClientRender', root, MapInfoWindow.render)
	if isTimer(timerAlpha) then killTimer(timerAlpha) end
end

function showmapinfo(commandname, ...)
	if #{...}>0 then
		arg = table.concat({...},' ')
	else arg = nil
	end
	if not isShow then
		isShow = true
		timerAlpha = setTimer(stopShowing, 15000, 1)
		addEventHandler('onClientRender', root, MapInfoWindow.render)
    else
        removeEventHandler('onClientRender', root, MapInfoWindow.render)
		isShow = false
		if isTimer(timerAlpha) then killTimer(timerAlpha) end
	end
end
addCommandHandler('mapinfo',showmapinfo)
bindKey('f5', 'down', function() showmapinfo() end)

addEvent('onClientMapStarting', true)
addEventHandler('onClientMapStarting', root, function()
    -- Quick fix for resetting when already open at map starting
    if isShow then
        showmapinfo()
    end

    showmapinfo()

end)
