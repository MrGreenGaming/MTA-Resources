﻿screenWidth, screenHeight = guiGetScreenSize()
local rootElement = getRootElement()

local voteWindow
local boundVoteKeys = {}
local nameFromVoteID = {}
local voteIDFromName = {}
local optionLabels = {}

local isVoteActive
local hasAlreadyVoted = false
local isChangeAllowed = false

local timeLabel
local finishTime

local cacheVoteNumber
local cacheTimer
last = 1


local timeCache = false
local function updateTime()
	local seconds = math.ceil( (finishTime - getTickCount()) / 1000 )
	if timeCache ~= seconds and seconds > -1 then
		if tostring(seconds) == "-0" then seconds = 0 end
		timeCache = seconds

		countdown_text = tostring(seconds)
	end
end

addEvent("doShowPoll", true)
addEvent("doSendVote", true)
addEvent("doStopPoll", true)

addEventHandler("doShowPoll", rootElement,
	function (pollData, pollOptions, pollTime)

		--clear the send vote cache
		cacheVoteNumber = ""
		--clear the bound keys table
		boundVoteKeys = {}
		--store the vote option names in the array nameFromVoteID
		nameFromVoteID = pollOptions
		--then build a reverse table
		voteIDFromName = {}


		
		--determine if we have to append nomination number
		local nominationString = ""
		if pollData.nomination > 1 then 
			nominationString = " (nomination "..pollData.nomination..")"
		end
		
		isChangeAllowed = pollData.allowchange

        -- layout.title.width  = layout.window.width - 20
        -- layout.option.width = layout.window.width
        -- layout.cancel.width = layout.window.width
        -- layout.time.width   = layout.window.width
		
        local screenX, screenY = guiGetScreenSize()
        

		
		--for each option, bind 
		for index, option in ipairs(pollOptions) do
			--bind the number key and add it to the bound keys table
			local optionKey = tostring(index)
			bindKey(optionKey, "down", sendVote_bind)
			bindKey("num_"..optionKey, "down", sendVote_bind)
			
			table.insert(boundVoteKeys, optionKey)
		end
		
		--bind 0 keys if there are more than 9 options
		if #pollOptions > 9 then
			bindKey("0", "down", sendVote_bind)
			bindKey("num_0", "down", sendVote_bind)
			table.insert(boundVoteKeys, "0")
		end
		
		if isChangeAllowed then
			bindKey("backspace", "down", sendVote_bind)
		end

        -- Set table up
		optionTable = pollOptions
		-- Set up Width

		local highestW = 0
		for i,opt in ipairs(optionTable) do
			local _w = dxGetTextWidth( i..". "..opt, 1.00, fontBold ) + textXoffset + 20
			
			if _w > highestW then highestW = _w end
		end

		if highestW > backgroundMinWidth then backgroundWidth = highestW else backgroundWidth = backgroundMinWidth end



		description_text = pollData.title


		setPollVisible(true)
		isVoteActive = true
		finishTime = getTickCount() + pollTime
		addEventHandler("onClientRender", rootElement, updateTime)

	end
)

function setOption(number)
	if number == -1 then
		selectedVote = false
	else
		selectedVote = number
	end
end



addEventHandler("doStopPoll", rootElement,
	function ()
		isVoteActive = false
		hasAlreadyVoted = false

		for i, key in ipairs(boundVoteKeys) do
			unbindKey(key, "down", sendVote_bind)
			unbindKey("num_"..key, "down", sendVote_bind)
		end
		
		unbindKey("backspace", "down", sendVote_bind)
		setPollVisible(false)
		removeEventHandler("onClientRender", rootElement, updateTime)
	end
)

function sendVote_bind(key)
	if key ~= "backspace" then
		key = key:gsub('num_', '')
		if #nameFromVoteID < 10 then
			return sendVote(tonumber(key))
		else
			cacheVoteNumber = cacheVoteNumber..key
			if #cacheVoteNumber > 1 then
				if isTimer(cacheTimer) then
					killTimer(cacheTimer)
				end
				cacheVoteNumber = tonumber(cacheVoteNumber)
				if nameFromVoteID[cacheVoteNumber] then
					if cacheVoteNumber < 10 then
						return sendVote(cacheVoteNumber)
					else
						cacheTimer = setTimer(sendVote, 500, 1, cacheVoteNumber)
					end
					cacheVoteNumber = key
				else
					cacheVoteNumber = ""
				end
			else		
				cacheTimer = setTimer(sendVote, 500, 1, tonumber(cacheVoteNumber))
			end
		end
	else
		return sendVote(-1)
	end
end

function sendVote(voteID)
	if not isVoteActive then
		return
	end
	
	--if option changing is not allowed, unbind the keys
	if not isChangeAllowed and voteID ~= -1 then
		for i, key in ipairs(boundVoteKeys) do
			unbindKey(key, "down", sendVote_bind)
			unbindKey("num_"..key, "down", sendVote_bind)
		end
	end
	
	--if the player hasnt voted already (or if vote change is allowed anyway), update the vote text
	if not hasAlreadyVoted or isChangeAllowed then

		if voteID ~= -1 then
			setOption(voteID)

		end
	end

	if voteID == -1 then
		setOption(voteID)
	end
	
	--clear the send vote cache
	cacheVoteNumber = ""
	hasAlreadyVoted = voteID
	
	--send the vote to the server
	triggerServerEvent("onClientSendVote", localPlayer, voteID)
end
addEventHandler("doSendVote", rootElement, sendVote)

addCommandHandler("vote",
	function (command, ...)
		--join all passed parameters separated by spaces
		local voteString = table.concat({...}, ' ')
		--try to get the voteID number
		local voteID = tonumber(voteString) or voteIDFromName[voteString]
		--if vote number is valid, send it
		if voteID and (nameFromVoteID[voteID] or voteID == -1) then
			sendVote(voteID)
		end
	end
)

addCommandHandler("cancelvote",
	function ()
		sendVote(-1)
	end
)


function table.insertUnique(t,val)
	for k,v in pairs(t) do
        if v == val then
			return
		end
	end
    table.insert(t,val)
end





-- GUI --
local screenW, screenH = guiGetScreenSize()

optionTable =  {
    "Option text",
    "Option text",
    "Option text",
}
option_amount = #optionTable -- This changes with poll
selectedVote = false
backgroundWidth = 535 -- should change with text width
backgroundMinWidth = 250
backgroundHeight = 400 -- should change with option amounts
backgroundX = screenW/2-(backgroundWidth/2)
backgroundY = screenH -- used to hide before animation
title_height = 35
descriptionYoffset = 40
textXoffset = 22
descriptionHeight = 40
first_option_text_Yoffset = 65
option_text_height = 25
countdown_text_height = 35 
unvote_text_height = 22
backgroundHeight = (option_text_height*option_amount)+option_text_height+first_option_text_Yoffset+countdown_text_height+unvote_text_height+2
trueBackgroundY = false -- True Y position where it should go after anim

font = "default"
fontBold = "default-bold"
bigFont = "default-bold"

countdown_text = "10"
description_text = "Vote Description text:"


local isPostGUI = true
function draw()
    local background =            dxDrawRectangle(backgroundX, backgroundY, backgroundWidth, backgroundHeight, tocolor(0, 0, 0, 200), isPostGUI,false)
    local title =                 dxDrawRectangle(backgroundX, backgroundY, backgroundWidth, title_height, tocolor(11, 138, 25, 255), isPostGUI,false)
	local titleGlass =            dxDrawRectangle(backgroundX, backgroundY, backgroundWidth, 17.5, tocolor(11, 180, 25, 255), isPostGUI,false)
    local title_text_draw =            dxDrawText("Vote", backgroundX, backgroundY, backgroundX + backgroundWidth, backgroundY+title_height, tocolor(255, 255, 255, 255), 1, bigFont, "center", "center", false, false, isPostGUI, false, false)
    local description_text_draw =      dxDrawText(description_text, backgroundX+textXoffset, backgroundY+descriptionYoffset, backgroundX + backgroundWidth - 20, backgroundY+descriptionYoffset+descriptionHeight, tocolor(255, 255, 255, 255), 1, fontBold, "left", "top", false, true, isPostGUI, false, false)
    
    -- Draw options
    for i, option in ipairs(optionTable) do
        if i == selectedVote then
            dxDrawRectangle(backgroundX, backgroundY+first_option_text_Yoffset+(option_text_height*i), backgroundWidth, option_text_height, tocolor(255, 255, 255, 228), isPostGUI,false)
            dxDrawText(i..". "..option, backgroundX+textXoffset, backgroundY + first_option_text_Yoffset + (option_text_height*i), backgroundX+backgroundWidth, backgroundY + first_option_text_Yoffset + (option_text_height*i) + option_text_height, tocolor(10, 10, 10, 255), 1.00, fontBold, "left", "center", false, false, isPostGUI, false, false)
        else
            dxDrawText(i..". "..option, backgroundX+textXoffset, backgroundY + first_option_text_Yoffset + (option_text_height*i), backgroundX+backgroundWidth, backgroundY + first_option_text_Yoffset + (option_text_height*i) + option_text_height, tocolor(255, 255, 255, 255), 1.00, font, "left", "center", false, false, isPostGUI, false, false)
        end

    end


    local countdown =             dxDrawText(countdown_text, backgroundX, backgroundY+(option_text_height*option_amount)+option_text_height+first_option_text_Yoffset, backgroundX+backgroundWidth, backgroundY+(option_text_height*option_amount)+option_text_height+first_option_text_Yoffset+countdown_text_height, tocolor(255, 255, 255, 255), 1, bigFont, "center", "center", false, false, isPostGUI, false, false)
    if isChangeAllowed then
        local unvote_text =           dxDrawText("(backspace to cancel)", backgroundX, backgroundY+(option_text_height*option_amount)+option_text_height+first_option_text_Yoffset+countdown_text_height, backgroundX+backgroundWidth, backgroundY+(option_text_height*option_amount)+option_text_height+first_option_text_Yoffset+countdown_text_height+unvote_text_height, tocolor(255, 255, 255, 255), 1.00, "arial", "center", "center", false, false, isPostGUI, false, false)
    end
end
-- addEventHandler("onClientRender",root,draw)




anim = {}
anim.popWindowUp = {}
anim.popWindowDown = {}
breakAnimation = false -- If poll comes up within animation then break it and start new one
function setPollVisible(bool)
    if bool then
    	-- reset vars
    	breakAnimation = true
    	option_amount = #optionTable -- This changes with poll
		selectedVote = false
		backgroundX = screenW/2-(backgroundWidth/2)
		backgroundY = screenH -- used to hide before animation
		backgroundHeight = (option_text_height*option_amount)+option_text_height+first_option_text_Yoffset+countdown_text_height+unvote_text_height+2
		trueBackgroundY = (screenH * 0.8) - backgroundHeight -- True Y position where it should go after anim



    	-- animations
        anim.popWindowUp.startTime = getTickCount()
        anim.popWindowUp.startSize = {backgroundX,screenH}
        anim.popWindowUp.endSize = {backgroundX,trueBackgroundY}
        anim.popWindowUp.endTime = anim.popWindowUp.startTime + 600
        addEventHandler("onClientRender",root,draw)
        addEventHandler("onClientRender", getRootElement(), popWindowUp)
    else
        anim.popWindowDown.startTime = getTickCount()
        anim.popWindowDown.startSize = {backgroundX,trueBackgroundY}
        anim.popWindowDown.endSize = {backgroundX,screenH}
        anim.popWindowDown.endTime = anim.popWindowDown.startTime + 400
        addEventHandler("onClientRender", getRootElement(), popWindowDown)
    end
end




function popWindowUp()
    local now = getTickCount()
    local elapsedTime = now - anim.popWindowUp.startTime
    local duration = anim.popWindowUp.endTime - anim.popWindowUp.startTime
    local progress = elapsedTime / duration
 
    local width, height, _ = interpolateBetween ( 
        anim.popWindowUp.startSize[1], anim.popWindowUp.startSize[2], 0, 
        anim.popWindowUp.endSize[1], anim.popWindowUp.endSize[2], 0, 
        progress, "InOutBack")
 
    backgroundY = height
 
    if now >= anim.popWindowUp.endTime then
    	breakAnimation = false

        removeEventHandler("onClientRender", getRootElement(), popWindowUp)

    end
end


function popWindowDown()
    local now = getTickCount()
    local elapsedTime = now - anim.popWindowDown.startTime
    local duration = anim.popWindowDown.endTime - anim.popWindowDown.startTime
    local progress = elapsedTime / duration
 
    local width, height, _ = interpolateBetween ( 
        anim.popWindowDown.startSize[1], anim.popWindowDown.startSize[2], 0, 
        anim.popWindowDown.endSize[1], anim.popWindowDown.endSize[2], 0, 
        progress, "InOutBack")
 
    backgroundY = height
 
    if now >= anim.popWindowDown.endTime or breakAnimation then
    	breakAnimation = false
    	backgroundY = screenH
        removeEventHandler("onClientRender",root,draw)
        removeEventHandler("onClientRender", getRootElement(), popWindowDown)

    end
end




 

-- showit = false
-- setTimer(function() showPoll(not showit) showit = not showit end,5000,0)



local fontsLoad = {

    {"fonts/Roboto-Bold.ttf",13,true,"cleartype"},

    {"fonts/Roboto-Regular.ttf",13,false,"cleartype"},

}
function createFonts()

    local f = fontsLoad[1]
    local b = fontsLoad[2]
    bigFont = dxCreateFont(f[1],20,f[3],f[4]) or "default-bold"
    fontBold = dxCreateFont(f[1],f[2],f[3],f[4]) or "default-bold"
    font = dxCreateFont(b[1],b[2],b[3],b[4]) or "default"
end
addEventHandler("onClientResourceStart",resourceRoot,createFonts)