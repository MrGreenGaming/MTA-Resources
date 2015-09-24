--made by Wojak aka Wojak[PL] aka [2RT]Wojak [PL]
--if you  want to edit something here dont upload yours version

addEvent("onclientbotstart",true)
addEvent("onclientfirstplayerDEAD",true)
addEvent("onclientpausestop",true)
addEvent("onnewfirstplayer",true)
addEvent("onClientMapStarting",true)

local screenWidth, screenHeight = guiGetScreenSize()
--local text = ""

--outputChatBox("test")
local state = 0
local shoot = 1
local dist = 0
function rock(veh,obj,n)
	--outputDebugString(""..n)
	local n2 = n+1
	if isTimer(rocktimer) then
		killTimer(rocktimer)
	end
	if state == 1 then
		local ox,oy,oz = getElementPosition(obj)
		local px,py,pz = getElementPosition(localfirstplayer)
		dist = getDistanceBetweenPoints2D(px,py,ox,oy)
		if localfirstplayer == getLocalPlayer() then
			if (shoot == 1) and (dist < 160) then
				--outputDebugString("boom")
				local x,y,z = getElementPosition(veh)
				local rx,ry,rz= getElementRotation(veh)
				createProjectile(getLocalPlayer(),19,x,y,z-5,1,getLocalPlayer(),rx,ry,rz,2.5*(x-ox),2.5*(y-oy),-1.2)
				setTimer(function()
					ox,oy,oz = getElementPosition(obj)
					x,y,z = getElementPosition(veh)
					rx,ry,rz= getElementRotation(veh)
					createProjectile(getLocalPlayer(),19,x,y,z-5,1,getLocalPlayer(),rx,ry,rz,3*(x-ox),3*(y-oy),-0.6)
					setTimer(function()
						ox,oy,oz = getElementPosition(obj)
						x,y,z = getElementPosition(veh)
						rx,ry,rz= getElementRotation(veh)
						createProjectile(getLocalPlayer(),19,x,y,z-5,1,getLocalPlayer(),rx,ry,rz,3.5*(x-ox),3.5*(y-oy),-0.5)
					end,1000,1)
				end,1000,1)
			end
		end
		rocktimer = setTimer(rock,3000,1,veh,obj,n2)
	end
end
function rockbufor(veh,obj,first,fstate)
	outputDebugString("source: "..getPlayerName(source))
	if isElement(first) then
		localfirstplayer = first
		outputDebugString("first: "..getPlayerName(first))
	end
	state = 0
	setTimer(function()
		state = 1
		if fstate ~= "dead" then
			shoot = 1
		end
		rock(veh,obj,1)
	end,4000,1)
end
addEventHandler("onclientbotstart", getRootElement(), rockbufor)
addEventHandler("onclientfirstplayerDEAD", getRootElement(), function()
	--text = "HuntBot will start in:"
	shoot = 0
end)
addEventHandler("onclientpausestop", getRootElement(), function()
	--text = ""
	shoot = 1
end)
addEventHandler("onnewfirstplayer", getRootElement(), function(olsfirst)
	--outputChatBox("newpla")
	localfirstplayer = source
end)
addEventHandler("onClientMapStarting", getRootElement(), function(olsfirst)
	--outputChatBox("newpla")
	state = 0
	shoot = 0
end)
--[[addEventHandler("onClientRender", getRootElement(), function(olsfirst)
	dxDrawText( text, 5, 10, screenWidth-10, screenHeight-950, tocolor ( 0, 0, 0, 255 ), 1, "default-bold", "center", "center")
end)]]
triggerServerEvent("onNewPlayerDetected", getLocalPlayer())
outputDebugString("clientload (huntbot)")