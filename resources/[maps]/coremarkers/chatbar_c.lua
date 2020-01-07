------------------------------------------
-- 			  TopBarChat				--
------------------------------------------
-- Developer: Braydon Davis				--
-- File: c.lua							--
-- Copyright 2013 (C) Braydon Davis		--
-- All rights reserved.					--	
------------------------------------------
-- Script Version: 1.4					--
------------------------------------------


local maxMessages = 6; 		-- The max messages that will show (on each bar)
local DefaultTime = 8; 		-- The max time each message will show if time isn't defined.

------------------------------------------
-- For scripters only					--
------------------------------------------
local sx_, sy_ = guiGetScreenSize ( )
local sx, sy = sx_/1920, sy_/1080 -- you got xXMADEXx's resolution :3 plz no hak mi
local DefaultPos = true;
local messages_top = { }
local messages_btm = { }

function sendClientMessage ( msg, r, g, b, pos, time )
	-- Msg: String
	-- R: Int (0-255)
	-- G: Int (0-255)
	-- B: Int (0-255)
	-- Pos: Boolean
	-- Time: Int
	if ( not msg ) then return false end

	if ( pos == nil ) then pos = DefaultPos end
	local r, g, b = r or 255, g or 255, b or 255
	local time = tonumber ( time ) or DefaultTime
	local data = { 
		message = msg,
		r = r,
		g = g,
		b = b,
		alpha=0,
		locked=true,
		rTick = getTickCount ( ) + (time*1000)
	}
	--> Scripters note: 
		--> The remove and intro fades are handled in the render event
	if ( pos == true or pos == "top" ) then
		table.insert ( messages_top, data )
		return true
	elseif ( pos == false or pos == "bottom" ) then
		table.insert ( messages_btm, data )
		return true
	end
	return false
end 
addEvent ( getResourceName ( getThisResource ( ) )..":sendClientMessage", true )
addEventHandler ( getResourceName ( getThisResource ( ) )..":sendClientMessage", root, sendClientMessage )

function dxDrawNotificationBar ( )
	local doRemove = { top = { }, bottom = { } }	-- This is used so it prevents the next message from flashing
	

	-- Top Message Bar
	for i, v in pairs ( messages_top ) do
		local i = i - 1
		if ( not v.locked ) then
			v.alpha = v.alpha - 3
			if ( v.alpha <= 20 ) then
				table.insert ( doRemove.top, i+1 )
			end
			messages_top[i+1].alpha = v.alpha
		else
			if ( v.alpha < 160 ) then
				v.alpha = v.alpha + 1
				messages_top[i+1].alpha = v.alpha
			end
			if ( v.rTick <= getTickCount ( ) ) then
				v.locked = false
				messages_top[i+1].locked=false
			end
		end
		dxDrawRectangle ( (sx_/2-530/2), i*25, 530, 25, tocolor ( 0, 0, 0, v.alpha ) )
		dxDrawText ( tostring ( v.message ), 0, i*25, sx_, (i+1)*25, tocolor ( v.r, v.g, v.b, v.alpha*1.59375 ), sy*1.3, "clear", "center", "center", false, false, false, true)
	end 
	if ( #messages_top > maxMessages and messages_top[1].locked ) then
		messages_top[1].locked = false
	end 

	-- Bottom Message Bar
	for i, v in pairs ( messages_btm ) do
		if ( not v.locked ) then
			v.alpha = v.alpha - 3
			if ( v.alpha <= 20 ) then
				table.insert ( doRemove.bottom, i )
			end
			messages_btm[i].alpha = v.alpha
		else
			if ( v.alpha < 160 ) then
				v.alpha = v.alpha + 1
				messages_btm[i].alpha = v.alpha
			end
			if ( v.rTick <= getTickCount ( ) ) then
				v.locked = false
				messages_btm[i].locked=false
			end
		end
		
		local textWidth = dxGetTextWidth(tostring ( v.message ), sy*1.5, "clear", true)+10*sx
		dxDrawRectangle ( (sx_/2-textWidth/2), sy_-(i*27*sy), textWidth, 27*sy, tocolor ( 0, 0, 0, v.alpha ) )
		dxDrawText ( tostring ( v.message ), 0, sy_-(i*27*sy), sx_, sy_-((i-1)*27*sy), tocolor ( v.r, v.g, v.b, v.alpha*1.59375 ), sy*1.5, "clear", "center", "center", false, false, false, true, true)
	end 
	if ( #messages_btm > maxMessages and messages_btm[1].locked ) then
		messages_btm[1].locked = false
	end 

	-- handle message removes
	if ( #doRemove.top > 0 )then
		for i, v in pairs ( doRemove.top ) do
			table.remove ( messages_top, v )
		end
	end
	if ( #doRemove.bottom > 0 ) then
		for i, v in pairs ( doRemove.bottom ) do
			table.remove ( messages_btm, v )
		end
	end
end
addEventHandler ( "onClientRender", root, dxDrawNotificationBar )


------------------------------
-- For development			--
------------------------------
addCommandHandler ( 'rt', function ( )
	for i=1, 5 do 
		sendClientMessage ( "Testing - Index ".. tostring ( i ), 255, 255, 255, false )
		sendClientMessage ( "Testing - Index ".. tostring ( i ), 255, 255, 255, true )
	end
end )