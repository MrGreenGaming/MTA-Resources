--made by Wojak aka Wojak[PL] aka [2RT]Wojak[PL]
--if you  want to edit something here dont upload yours version



local core = createObject(1155,0,0,100)
local coreveh = createVehicle(425,0,0,100)
attachElements(coreveh,core,0,1,0,0,0,0)
setVehicleDamageProof(coreveh,true)
local coreped = createPed(252,0,0,0)
warpPedIntoVehicle(coreped,coreveh,0)
local blip = createBlipAttachedTo(coreveh,20)
addEvent("onRaceStateChanging",true)
addEvent("onNewPlayerDetected",true)
addEvent("onMapStarting",true)
local racestate = ""
local activestate = 0
-----------------------------
-----------------------------
local defmodspd = 20 -----------
local defaitime = 5.2  -----------
local defsplimit = 150  --------
local defstartdely = 25
local defpause = 30
local modspd = ""
local aitime = ""
local splimit = ""
local startdely = ""
local pause = ""
-----------------------------
-----------------------------
local myTextDisplay = textCreateDisplay ()
local myTextItem = textCreateTextItem ( "HuntBot will start in:", 0.5, 0.048, "low", 255, 0, 0, 255, 1, "center")
textDisplayAddText ( myTextDisplay, myTextItem )
 function showtext()
	local players = getElementsByType("player")
	for i, p in ipairs (players) do
		textDisplayAddObserver(myTextDisplay,p)
	end
 end
 function hidetext()
	local players = getElementsByType("player")
	for i, p in ipairs (players) do
		textDisplayRemoveObserver(myTextDisplay,p)
	end
 end
function isNumSettingOK(setting,arg)
	if setting then
		if setting >= arg then
			return setting
		else
			return nil
		end
	else
		return nil
	end
end
function setupBotSettings(locals,globalse,defs)
	if locals then
		return locals
	elseif globalse then
		return globalse
	else
		return defs
	end
end
addEventHandler("onRaceStateChanging", getRootElement(),function ( state, old )
	--outputDebugString("racestate: ("..state..")")
	racestate = state
	if (state == "Running" and old ~= "MidMapVote") and (activestate == 1) then
		if startdely == 0 then
			activate()
		else
			dely_MissionTimer = exports.missiontimer:createMissionTimer (((startdely*1000) + 100),true,"%m:%s",0.5,0.08,true,"default-bold",1,255,255,255)
			--triggerClientEvent(getRootElement(),"onclientfirstplayerDEAD",core)
			showtext()
			delytimer = setTimer(function()
				--triggerClientEvent(getRootElement(),"onclientpausestop",core)
				hidetext()
				destroyElement(dely_MissionTimer)
				activate()
			end, ((startdely*1000) + 100), 1)
		end
	elseif state == "GridCountdown" then
		activestate = 1
		local localmodspd = tonumber(get(getResourceName(call(getResourceFromName("mapmanager"),"getRunningGamemodeMap"))..".modspeed"))
		localmodspd = isNumSettingOK(localmodspd,0)
		local globalmodspd = tonumber(get(getResourceName(getThisResource())..".modspeed"))
		globalmodspd = isNumSettingOK(globalmodspd,0)
		modspd = setupBotSettings(localmodspd,globalmodspd,defmodspd)
		local localaitime = tonumber(get(getResourceName(call(getResourceFromName("mapmanager"),"getRunningGamemodeMap"))..".aispeed"))
		localaitime = isNumSettingOK(localaitime,0.5)
		local globalaitime = tonumber(get(getResourceName(getThisResource())..".aispeed"))
		globalaitime = isNumSettingOK(globalaitime,0.5)
		aitime = setupBotSettings(localaitime,globalaitime,defaitime)
		local localsplimit = tonumber(get(getResourceName(call(getResourceFromName("mapmanager"),"getRunningGamemodeMap"))..".speedlimit"))
		localsplimit = isNumSettingOK(localsplimit,10)
		local glpbalsplimit = tonumber(get(getResourceName(getThisResource())..".speedlimit"))
		glpbalsplimit = isNumSettingOK(glpbalsplimit,10)
		splimit = setupBotSettings(localsplimit,glpbalsplimit,defsplimit)
		local localstartdely = tonumber(get(getResourceName(call(getResourceFromName("mapmanager"),"getRunningGamemodeMap"))..".starthuntdely"))
		localstartdely = isNumSettingOK(localstartdely,0)
		local glpbalstartdely = tonumber(get(getResourceName(getThisResource())..".starthuntdely"))
		glpbalstartdely = isNumSettingOK(glpbalstartdely,0)
		startdely = setupBotSettings(localstartdely,glpbalstartdely,defstartdely)
		local localpause = tonumber(get(getResourceName(call(getResourceFromName("mapmanager"),"getRunningGamemodeMap"))..".huntpause"))
		localpause = isNumSettingOK(localpause,5)
		local glpbalpause = tonumber(get(getResourceName(getThisResource())..".huntpause"))
		glpbalpause = isNumSettingOK(glpbalpause,5)
		pause = setupBotSettings(localpause,glpbalpause,defpause)
		outputDebugString("Settings:")
		outputDebugString("|"..modspd.. "| |"..aitime.. "| |"..splimit.."| |"..startdely.."| |"..pause.."|")
	else
		activestate = 0
	end
end)
function activate()
	local players = getElementsByType("player")
	for i,pla in ipairs(players) do
		if getElementData(pla, "race rank") == 1 then
			firstplayer = pla
		end
	end
	local firststate = getElementData(firstplayer, "state")
	for i,pla in ipairs(players) do
		triggerClientEvent(pla,"onclientbotstart",pla,coreveh,core,firstplayer,firststate)
	end
	local x,y,z = getElementPosition(firstplayer)
	setElementPosition(core, x+200, y, z+50)
	botai(firstplayer)
	triggerClientEvent(getRootElement(),"onnewfirstplayer",firstplayer,firstplayer)
end
function botai(benfirst)
	if isTimer(aitimer) then
		killTimer(aitimer)
	end
	if (racestate == "Running") or (racestate == "MidMapVote") then
		local players = getElementsByType("player")
		warpPedIntoVehicle(coreped,coreveh,0)
		for i,pla in ipairs(players) do
			if getElementData(pla, "race rank") == 1 then
				firstplayer = pla
			end
		end
		if firstplayer ~= benfirst then
			outputDebugString('newfitst: '..getPlayerName(firstplayer))
			triggerClientEvent(getRootElement(),"onnewfirstplayer",firstplayer,benfirst)
		end
		local veh = getPedOccupiedVehicle(firstplayer)
		local px,py,z = getElementPosition(firstplayer)
		local x,y = px,py
		local vx,vy,vz = 0,0,0
		if veh then
			vx,vy,vz = getElementVelocity(veh)
		end
		if vx then
			x = x + 10*modspd*vx
		end
		if vy then
			y = y + 10*modspd*vy
		end
		local bx,by,bz = getElementPosition(core)
		local waypointangle = ( 360 - math.deg ( math.atan2 ( ( x - bx ), ( y - by ) ) ) ) % 360
		local rx,ry,rz = getElementRotation(core)
		local angle = (waypointangle - rz)
		if angle < (-180) then
			angle = (360 - rz + waypointangle)
		elseif angle > 180 then
			angle = -(360 - waypointangle + rz)
		end
		--outputChatBox("calc 1")
		local distlimit = 0.36*splimit*aitime
		--outputChatBox("calc 1 "..distlimit.." ,"..getDistanceBetweenPoints2D(px,py,bx,by))
		if distlimit < getDistanceBetweenPoints2D(px,py,bx,by) then
			--outputChatBox("calc 2")
			x,y = px,py
		end
		local realdist = getDistanceBetweenPoints2D(x,y,bx,by)
		percdist = distlimit/realdist
		if percdist < 1 then
				--outputChatBox("calc 3")
			x = bx + percdist*(x - bx)
			y = by + percdist*(y - by)
		end
		realdist = getDistanceBetweenPoints2D(x,y,bx,by)
		local curspeed = realdist/(0.36*aitime)

		local wayhangle = -((30*curspeed)/100)
		if wayhangle <= -30 then
			wayhangle = -30
		end
		local hangle = (360 - rx + wayhangle)
		if hangle > 30 then
			hangle = -30
		end
		--outputDebugString("bot speed= "..curspeed..", hangle= "..hangle..", rx= "..rx..", wayhangle= "..wayhangle)
		if getElementData(benfirst, "state") == "dead" then
			moveObject(core,(0.25 * aitime * 1000) - 50,bx,by,z + 25,360-rx,0,angle)
			showtext()
			pause_MissionTimer = exports.missiontimer:createMissionTimer ((pause*1000),true,"%m:%s",0.5,0.08,true,"default-bold",1,255,255,255)
			triggerClientEvent(getRootElement(),"onclientfirstplayerDEAD",firstplayer)
			pausetimer = setTimer(function()
				destroyElement(pause_MissionTimer)
				hidetext()
				botai(firstplayer)
				if getElementData(benfirst, "state") ~= "dead" then
					triggerClientEvent(getRootElement(),"onclientpausestop",firstplayer)
				end
			end, (pause*1000), 1)
		else
			moveObject(core,(0.25 * aitime * 1000) - 50,bx + (0.25 *(x - bx)),by + (0.25 * (y - by)),z + 25,hangle,0,angle)
			aitimer = setTimer(function()
				moveObject(core, 0.75 * aitime * 1000, x,y,z+25)
			end,0.25 * aitime * 1000,1)
			setTimer(botai,(aitime * 1000) + 10,1,firstplayer)
		end
	else
		moveObject(core,(0.25 * aitime * 1000) - 50,0,0,-10,0,0,0)
		triggerClientEvent(getRootElement(),"onclientfirstplayerDEAD",firstplayer)
	end
	--outputChatBox("isend?")
end
addEventHandler("onNewPlayerDetected", getRootElement(),function ()
	local pla = source
	outputDebugString("stever player detect: "..getPlayerName(source))
	if ((racestate == "Running") or (racestate == "MidMapVote")) and (not isElement(dely_MissionTimer)) then
		setTimer(function()
			local firststate = getElementData(firstplayer, "state")
			outputDebugString("server player data send")
			triggerClientEvent(pla,"onclientbotstart",pla,coreveh,core,firstplayer,firststate)
		end,1000,1)
	end
end)
addEventHandler("onMapStarting", getRootElement(),function ()
	if isTimer(pausetimer) then
		killTimer(pausetimer)
	end
	if isTimer(delytimer) then
		killTimer(delytimer)
	end
	if isElement(dely_MissionTimer) then
		destroyElement(dely_MissionTimer)
		hidetext()
	end
	if isElement(pause_MissionTimer) then
		destroyElement(pause_MissionTimer)
		hidetext()
	end
end)
