tableasd = {2,{{{{anothertable,1}}}}}
clientTable = false
x,y = guiGetScreenSize()
startY = 0
bottomDistance = y-((1/4)*y)
textHeight = 20
maxVisibleRanks = 8 -- maximum visible ranks
rankBoardPosX,rankBoardPosY = math.ceil(x * 0.014), math.ceil(y * 0.394) 
countmode = false -- down = countdown (no respawn modes), up = countup (race modes), cargame = gamemode cargame

rankRenderTarget = dxCreateRenderTarget(math.ceil(x * 0.248), math.ceil(textHeight * maxVisibleRanks),true) -- All ranks are rendered in this
localPlayerRenderTarget = dxCreateRenderTarget(math.ceil(x * 0.248), math.ceil(textHeight),true) -- If localplayer is not in top visibleRanks then localplayer time goes here



addEvent('onClientMapStopping', true)
addEventHandler('onClientMapStopping', root,
function()
	clientTable = false
	localPlayerRendered = false
	countmode = false
	localPlayerFinishInfo = false
end
)

function msToTimeStr(ms)
	if not ms then
		return ''
	end
	local centiseconds = tostring(math.floor(math.fmod(ms, 1000)/10))
	if #centiseconds == 1 then
		centiseconds = '0' .. centiseconds
	end
	local s = math.floor(ms / 1000)
	local seconds = tostring(math.fmod(s, 60))
	if #seconds == 1 then
		seconds = '0' .. seconds
	end
	local minutes = tostring(math.floor(s / 60))
	return tonumber(minutes), tonumber(seconds), tonumber(centiseconds)
end

addEvent("updatePlayerTimes", true)
addEventHandler("updatePlayerTimes", getRootElement(),
function(playerTable,downup)
	countmode = downup
	clientTable = playerTable
	if clientTable ~= false then 
		drawnTexts = {}
		shadowDrawnTexts = {}


		if localPlayerFinishInfo == false then
			for _,t in ipairs(clientTable) do
				if t.name == getPlayerName(localPlayer) then
					localPlayerFinishInfo = t
				end
			end
		end


	end
end
)



function dxDrawColorText(str, ax, ay, bx, by, color, scale, font, alignX, alignY)
 
	if alignX then
		if alignX == "center" then
			local w = dxGetTextWidth(str:gsub("#%x%x%x%x%x%x",""), scale, font)
			ax = ax + (bx-ax)/2 - w/2
		elseif alignX == "right" then
			local w = dxGetTextWidth(str:gsub("#%x%x%x%x%x%x",""), scale, font)
			ax = bx - w
		end
	end

	if alignY then
		if alignY == "center" then
			local h = dxGetFontHeight(scale, font)
			ay = ay + (by-ay)/2 - h/2
		elseif alignY == "bottom" then
			local h = dxGetFontHeight(scale, font)
			ay = by - h
		end
	end

	local pat = "(.-)#(%x%x%x%x%x%x)"
	local s, e, cap, col = str:find(pat, 1)
	local last = 1
	while s do
		if cap == "" and col then color = tocolor(tonumber("0x"..col:sub(1, 2)), tonumber("0x"..col:sub(3, 4)), tonumber("0x"..col:sub(5, 6)), 255) end
		if s ~= 1 or cap ~= "" then
			local w = dxGetTextWidth(cap, scale, font)
			dxDrawText(cap, ax, ay, ax + w, by, color, scale, font)
			ax = ax + w
			color = tocolor(tonumber("0x"..col:sub(1, 2)), tonumber("0x"..col:sub(3, 4)), tonumber("0x"..col:sub(5, 6)), 255)
		end
		last = e + 1
		s, e, cap, col = str:find(pat, last)
	end
	if last <= #str then
		cap = str:sub(last)
		local w = dxGetTextWidth(cap, scale, font)
		dxDrawText(cap, ax, ay, ax + w, by, color, scale, font)
	end
end


drawnTexts = {}
localPlayerFinishInfo = false
local rScale = 1
local theFont = "clear"
addEventHandler('onClientRender', getRootElement(),
function()
	if clientTable == false then return end
	if not rankRenderTarget or not localPlayerRenderTarget then return end




	add = 0 
	if countmode == "up" then
		for number, tableRank in ipairs(clientTable) do 
			dxSetRenderTarget(rankRenderTarget,true)
			dxSetBlendMode("add")
			if number <= maxVisibleRanks then
				rank = number
				name = tableRank.name
				time = tableRank.time

				local theColor = tocolor(255,255,255,255)
				local timeColor = "#FFFFFF"

				if name == getPlayerName(localPlayer) then theColor = tocolor(1,255,255,255) timeColor = "#01FFFF" localPlayerRendered = true end 


				if (add == 0) then
					minutes, seconds, ms = msToTimeStr(time)
					if (seconds < 10) and (seconds >= 0) then
						seconds = tostring(seconds)
						seconds = "0"..seconds
					end
					if (ms < 10) and (ms >=0) then
						ms = tostring(ms)
						ms = "0"..ms
					end	
					firstTimeMS = time
					shadowName = string.gsub(name, '#%x%x%x%x%x%x', '' )
					shadowDrawnTexts[name] = dxDrawText(tostring(rank)..") "..tostring(shadowName).."  "..tostring(minutes)..":"..tostring(seconds)..":"..tostring(ms), 1, startY+add+1, x, startY+add+15+1, tocolor(0,0,0, 255), rScale, theFont, "left","center",true,false,false,true,true)
					drawnTexts[rank] = dxDrawColorText(tostring(rank)..") "..tostring(name).."  "..timeColor..""..tostring(minutes)..":"..tostring(seconds)..":"..tostring(ms), 0, startY+add, x, startY+add+15, theColor, rScale, theFont, "left","center",true,false,false,true,true)
				else
					msNext = time - firstTimeMS
					minutes, seconds, ms = msToTimeStr(msNext)
					if (seconds < 10) and (seconds >= 0) then
						seconds = tostring(seconds)
						seconds = "0"..seconds
					end
					if (ms < 10) and (ms >=0) then
						ms = tostring(ms)
						ms = "0"..ms
					end
					startX = 0
					
					shadowName = string.gsub(name, '#%x%x%x%x%x%x', '' )	
					shadowDrawnTexts[rank] = dxDrawText(tostring(rank)..") "..tostring(shadowName).." +"..tostring(minutes)..":"..tostring(seconds)..":"..tostring(ms), startX+1, startY+add+1, x, startY+add+15+1, tocolor(0,0,0, 255), rScale, theFont, "left","center",true,false,false,true,true)
					drawnTexts[rank] = dxDrawColorText(tostring(rank)..") "..tostring(name).."" ..timeColor.." +"..tostring(minutes)..":"..tostring(seconds)..":"..tostring(ms), startX, startY+add, x, startY+add+15, theColor, rScale, theFont, "left","center",true,false,false,true,true)
				end
				

				add = add + textHeight
			end
		end
		-- dxSetBlendMode("blend")
		dxSetRenderTarget()
		local sizeX,sizeY = dxGetMaterialSize(rankRenderTarget)
		dxSetBlendMode("add")	
		dxDrawImage(rankBoardPosX, rankBoardPosY, sizeX, sizeY,rankRenderTarget)
		dxSetBlendMode("blend")

		-- if not false then -- Test 
		if not localPlayerRendered and localPlayerFinishInfo ~= false then -- if local player isnt rendered but is finished

			local name = getPlayerName(localPlayer)
			local rank = localPlayerFinishInfo.rank
			local time = localPlayerFinishInfo.time


			dxSetRenderTarget(localPlayerRenderTarget,true)
			dxSetBlendMode("add")

			msNext = time - firstTimeMS
			minutes, seconds, ms = msToTimeStr(msNext)
			if (seconds < 10) and (seconds >= 0) then
				seconds = tostring(seconds)
				seconds = "0"..seconds
			end
			if (ms < 10) and (ms >=0) then
				ms = tostring(ms)
				ms = "0"..ms
			end
			startX = 0
			
			shadowName = string.gsub(name, '#%x%x%x%x%x%x', '' )	
			shadowDrawnTexts[rank] = dxDrawText(tostring(rank)..") "..tostring(shadowName).." +"..tostring(minutes)..":"..tostring(seconds)..":"..tostring(ms), 1, 1, x, textHeight+1, tocolor(0,0,0, 255), rScale, theFont, "left","center",true,false,false,true,true)
			drawnTexts[rank] = dxDrawColorText(tostring(rank)..") "..tostring(name).." #01FFFF+"..tostring(minutes)..":"..tostring(seconds)..":"..tostring(ms), 0, 0, x, textHeight, tocolor(1,255,255,255), rScale, theFont, "left","center",true,false,false,true,true)

			
			-- dxSetBlendMode("blend")
			dxSetRenderTarget()

			local boardsizeX,boardsizeY = dxGetMaterialSize(rankRenderTarget)
			local sizeX,sizeY = dxGetMaterialSize(localPlayerRenderTarget)
			dxSetBlendMode("add")
			dxDrawImage(rankBoardPosX, rankBoardPosY + boardsizeY, sizeX, sizeY,localPlayerRenderTarget)
			dxSetBlendMode("blend")
		end


	elseif countmode == "down" then
		localPlayerRendered = false
		for number, tableRank in ipairs(clientTable) do 
			dxSetRenderTarget(rankRenderTarget,true)
			dxSetBlendMode("add")
			if number <= maxVisibleRanks then
				rank = tableRank.rank
				name = tableRank.name
				time = tableRank.time
				kills = tableRank.kills or false

				local killString = ""
				if kills then 
					killString = " Kills: "..tostring(kills) 
				end

				local theColor = tocolor(255,255,255,255)
				local timeColor = "#FFFFFF"

				if name == getPlayerName(localPlayer) then theColor = tocolor(1,255,255,255) timeColor = "#01FFFF" localPlayerRendered = true end 


				if (add == 0) then
					minutes, seconds, ms = msToTimeStr(time)
					if (seconds < 10) and (seconds >= 0) then
						seconds = tostring(seconds)
						seconds = "0"..seconds
					end
					if (ms < 10) and (ms >=0) then
						ms = tostring(ms)
						ms = "0"..ms
					end	
					firstTimeMS = time
					shadowName = string.gsub(name, '#%x%x%x%x%x%x', '' )
					shadowDrawnTexts[name] = dxDrawText(tostring(rank)..") "..tostring(shadowName)..killString, 1, startY+add+1, x, startY+add+15+1, tocolor(0,0,0, 255), rScale, theFont, "left","center",true,false,false,true,true)
					drawnTexts[rank] = dxDrawColorText(tostring(rank)..") "..tostring(name)..timeColor..killString, 0, startY+add, x, startY+add+15, theColor, rScale, theFont, "left","center",true,false,false,true,true)
				else
					msNext = time - firstTimeMS
					minutes, seconds, ms = msToTimeStr(msNext)
					if (seconds < 10) and (seconds >= 0) then
						seconds = tostring(seconds)
						seconds = "0"..seconds
					end
					if (ms < 10) and (ms >=0) then
						ms = tostring(ms)
						ms = "0"..ms
					end
					startX = 0
		
					shadowName = string.gsub(name, '#%x%x%x%x%x%x', '' )	
					shadowDrawnTexts[rank] = dxDrawText(tostring(rank)..") "..tostring(shadowName)..killString, startX+1, startY+add+1, x, startY+add+15+1, tocolor(0,0,0, 255), rScale, theFont, "left","center",true,false,false,true,true)
					drawnTexts[rank] = dxDrawColorText(tostring(rank)..") "..tostring(name)..timeColor..killString, startX, startY+add, x, startY+add+15, theColor, rScale, theFont, "left","center",true,false,false,true,true)
				end
				

				add = add + textHeight
			end
		end
		-- dxSetBlendMode("blend")
		dxSetRenderTarget()
		local sizeX,sizeY = dxGetMaterialSize(rankRenderTarget)
		dxSetBlendMode("add")	
		dxDrawImage(rankBoardPosX, rankBoardPosY, sizeX, sizeY,rankRenderTarget)
		dxSetBlendMode("blend")

		-- if not false then -- Test 
		if not localPlayerRendered and localPlayerFinishInfo ~= false then -- if local player isnt rendered but is finished

			local name = getPlayerName(localPlayer)
			local rank = localPlayerFinishInfo.rank
			local time = localPlayerFinishInfo.time
			local kills = localPlayerFinishInfo.kills or false


			local killString = ""
			if kills then 
				killString = " (Kills: "..tostring(kills)..")" 
			end

			dxSetRenderTarget(localPlayerRenderTarget,true)
			dxSetBlendMode("add")

			msNext = time - firstTimeMS
			minutes, seconds, ms = msToTimeStr(msNext)
			if (seconds < 10) and (seconds >= 0) then
				seconds = tostring(seconds)
				seconds = "0"..seconds
			end
			if (ms < 10) and (ms >=0) then
				ms = tostring(ms)
				ms = "0"..ms
			end
			startX = 0
			
			shadowName = string.gsub(name, '#%x%x%x%x%x%x', '' )	
			shadowDrawnTexts[rank] = dxDrawText(tostring(rank)..") "..tostring(shadowName)..killString, 1, 1, x, textHeight+1, tocolor(0,0,0, 255), rScale, theFont, "left","center",true,false,false,true,true)
			drawnTexts[rank] = dxDrawColorText(tostring(rank)..") "..tostring(name).."#01FFFF"..killString, 0, 0, x, textHeight, tocolor(1,255,255,255), rScale, theFont, "left","center",true,false,false,true,true)

			
			-- dxSetBlendMode("blend")
			dxSetRenderTarget()

			local boardsizeX,boardsizeY = dxGetMaterialSize(rankRenderTarget)
			local sizeX,sizeY = dxGetMaterialSize(localPlayerRenderTarget)
			dxSetBlendMode("add")
			dxDrawImage(rankBoardPosX, rankBoardPosY + boardsizeY, sizeX, sizeY,localPlayerRenderTarget)
			dxSetBlendMode("blend")
		end

	elseif countmode == "cargame" then
		localPlayerRendered = false
		for number, tableRank in ipairs(clientTable) do 
			dxSetRenderTarget(rankRenderTarget,true)
			dxSetBlendMode("add")
			if number <= maxVisibleRanks then
				-- outputChatBox(tostring(tableRank.time))
				rank = tableRank.rank
				name = tableRank.name
				time = tableRank.time
				kills = tableRank.kills or false
				level = tableRank.level or 1

				local killString = ""
				if kills then 
					killString = " level: "..tostring(level) 
				end

				local theColor = tocolor(255,255,255,255)
				local timeColor = "#FFFFFF"

				if name == getPlayerName(localPlayer) then theColor = tocolor(1,255,255,255) timeColor = "#01FFFF" localPlayerRendered = true end 


				if (add == 0) then
					minutes, seconds, ms = msToTimeStr(time)
					if (seconds < 10) and (seconds >= 0) then
						seconds = tostring(seconds)
						seconds = "0"..seconds
					end
					if (ms < 10) and (ms >=0) then
						ms = tostring(ms)
						ms = "0"..ms
					end	
					firstTimeMS = time
					shadowName = string.gsub(name, '#%x%x%x%x%x%x', '' )
					shadowDrawnTexts[rank] = dxDrawText(tostring(rank)..") "..tostring(shadowName)..killString.." ("..tostring(minutes)..":"..tostring(seconds)..":"..tostring(ms)..")", 1, 1, x, textHeight+1, tocolor(0,0,0, 255), rScale, theFont, "left","center",true,false,false,true,true)
					drawnTexts[rank] = dxDrawColorText(tostring(rank)..") "..tostring(name).."#01FFFF"..killString.." ("..tostring(minutes)..":"..tostring(seconds)..":"..tostring(ms)..")", 0, 0, x, textHeight, tocolor(1,255,255,255), rScale, theFont, "left","center",true,false,false,true,true)
				else
					msNext = time - firstTimeMS
					minutes, seconds, ms = msToTimeStr(msNext)
					if (seconds < 10) and (seconds >= 0) then
						seconds = tostring(seconds)
						seconds = "0"..seconds
					end
					if (ms < 10) and (ms >=0) then
						ms = tostring(ms)
						ms = "0"..ms
					end
					startX = 0
		
					shadowName = string.gsub(name, '#%x%x%x%x%x%x', '' )	
					shadowDrawnTexts[rank] = dxDrawText(tostring(rank)..") "..tostring(shadowName)..killString, startX+1, startY+add+1, x, startY+add+15+1, tocolor(0,0,0, 255), rScale, theFont, "left","center",true,false,false,true,true)
					drawnTexts[rank] = dxDrawColorText(tostring(rank)..") "..tostring(name)..timeColor..killString, startX, startY+add, x, startY+add+15, theColor, rScale, theFont, "left","center",true,false,false,true,true)
				end
				

				add = add + textHeight
			end
		end
		-- dxSetBlendMode("blend")
		dxSetRenderTarget()
		local sizeX,sizeY = dxGetMaterialSize(rankRenderTarget)
		dxSetBlendMode("add")	
		dxDrawImage(rankBoardPosX, rankBoardPosY, sizeX, sizeY,rankRenderTarget)
		dxSetBlendMode("blend")

		-- if not false then -- Test 
		if not localPlayerRendered and localPlayerFinishInfo ~= false then -- if local player isnt rendered but is finished

			local name = getPlayerName(localPlayer)
			local rank = localPlayerFinishInfo.rank
			local time = localPlayerFinishInfo.time
			local kills = localPlayerFinishInfo.kills or false


			local killString = ""
			if kills then 
				killString = " (Kills: "..tostring(kills)..")" 
			end

			dxSetRenderTarget(localPlayerRenderTarget,true)
			dxSetBlendMode("add")

			msNext = time - firstTimeMS
			minutes, seconds, ms = msToTimeStr(msNext)
			if (seconds < 10) and (seconds >= 0) then
				seconds = tostring(seconds)
				seconds = "0"..seconds
			end
			if (ms < 10) and (ms >=0) then
				ms = tostring(ms)
				ms = "0"..ms
			end
			startX = 0
			
			shadowName = string.gsub(name, '#%x%x%x%x%x%x', '' )	
			shadowDrawnTexts[rank] = dxDrawText(tostring(rank)..") "..tostring(shadowName)..killString, 1, 1, x, textHeight+1, tocolor(0,0,0, 255), rScale, theFont, "left","center",true,false,false,true,true)
			drawnTexts[rank] = dxDrawColorText(tostring(rank)..") "..tostring(name).."#01FFFF"..killString, 0, 0, x, textHeight, tocolor(1,255,255,255), rScale, theFont, "left","center",true,false,false,true,true)

			
			-- dxSetBlendMode("blend")
			dxSetRenderTarget()

			local boardsizeX,boardsizeY = dxGetMaterialSize(rankRenderTarget)
			local sizeX,sizeY = dxGetMaterialSize(localPlayerRenderTarget)
			dxSetBlendMode("add")
			dxDrawImage(rankBoardPosX, rankBoardPosY + boardsizeY, sizeX, sizeY,localPlayerRenderTarget)
			dxSetBlendMode("blend")
		end
	-- end
	end


		
end
)


addEventHandler('onClientResourceStart', getResourceRootElement(),
function()
	--ask the server for the client table if any
	triggerServerEvent("onJoinedPlayerRequireList", getLocalPlayer())
end
)

function getPlayerFinishInfo(name)
	for i,t in ipairs(clientTable) do
		if t.name == name then
			return t.rank, t.time, t.kills or false
		end
	end
	return false, false
end
