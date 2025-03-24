nametag = {}
local nametags = {}
local g_screenX,g_screenY = guiGetScreenSize()
local bHideNametags, bOnlyHealthBar = false, false
local bEnableNametags = true -- use enableNametags() to change it

enableCustomNametags = false
-- Vanilla nametag values --
NAMETAG_SCALE = 0.3 --Overall adjustment of the nametag, use this to resize but constrain proportions
NAMETAG_ALPHA_DISTANCE = 50 --Distance to start fading out
NAMETAG_DISTANCE = 120 --Distance until we're gone
NAMETAG_ALPHA = 120 --The overall alpha level of the nametag
--The following arent actual pixel measurements, they're just proportional constraints
NAMETAG_TEXT_BAR_SPACE = 2
NAMETAG_WIDTH = 50
NAMETAG_HEIGHT = 5
NAMETAG_TEXTSIZE = 0.7
NAMETAG_OUTLINE_THICKNESS = 1.2
NAMETAG_TEXTBORDERSIZE = 0
--
NAMETAG_ALPHA_DIFF = NAMETAG_DISTANCE - NAMETAG_ALPHA_DISTANCE
NAMETAG_SCALE = 1/NAMETAG_SCALE * 800 / g_screenY
font = "default"

NAMETAG_VIP_TEX = nil
NAMETAG_VIP_PLUS_TEX = nil

enableCustomNametags = false
function setNametagValues(bool)
	if bool then
		enableCustomNametags = true
		-- Custom nametag values --
		NAMETAG_SCALE = 0.3 --Overall adjustment of the nametag, use this to resize but constrain proportions
		NAMETAG_ALPHA_DISTANCE = 50 --Distance to start fading out
		NAMETAG_DISTANCE = 120 --Distance until we're gone
		NAMETAG_ALPHA = 120 --The overall alpha level of the nametag
		--The following arent actual pixel measurements, they're just proportional constraints
		NAMETAG_TEXT_BAR_SPACE = -1.5
		NAMETAG_WIDTH = 80
		NAMETAG_HEIGHT = 7
		NAMETAG_TEXTSIZE = 0.7
		NAMETAG_OUTLINE_THICKNESS = 1.2
		NAMETAG_TEXTBORDERSIZE = 0.8
		--
		NAMETAG_ALPHA_DIFF = NAMETAG_DISTANCE - NAMETAG_ALPHA_DISTANCE
		NAMETAG_SCALE = 1/NAMETAG_SCALE * 800 / g_screenY
		--
		font = exports.fonts:getFont("OpenSans")


	else
		enableCustomNametags = false
		-- Vanilla nametag values --
		NAMETAG_SCALE = 0.3 --Overall adjustment of the nametag, use this to resize but constrain proportions
		NAMETAG_ALPHA_DISTANCE = 50 --Distance to start fading out
		NAMETAG_DISTANCE = 120 --Distance until we're gone
		NAMETAG_ALPHA = 120 --The overall alpha level of the nametag
	--The following arent actual pixel measurements, they're just proportional constraints
		NAMETAG_TEXT_BAR_SPACE = 2
		NAMETAG_WIDTH = 50
		NAMETAG_HEIGHT = 5
		NAMETAG_TEXTSIZE = 0.7
		NAMETAG_OUTLINE_THICKNESS = 1.2
		NAMETAG_TEXTBORDERSIZE = 0
	--
		NAMETAG_ALPHA_DIFF = NAMETAG_DISTANCE - NAMETAG_ALPHA_DISTANCE
		NAMETAG_SCALE = 1/NAMETAG_SCALE * 800 / g_screenY
		font = "default"
	end
end
-- addEventHandler("onClientResourceStart",resourceRoot,setNametagValues)

-- Set VIP Badge Textures
addEventHandler("onClientResourceStart",resourceRoot,function ()
	NAMETAG_VIP_TEX = dxCreateTexture('img/mrgreen_vip.png')
	NAMETAG_VIP_PLUS_TEX = dxCreateTexture('img/mrgreen_vip_plus.png')
end)




-- Ensure the name tag doesn't get too big
local maxScaleCurve = { {0, 0}, {3, 3}, {13, 5} }
-- Ensure the text doesn't get too small/unreadable
local textScaleCurve = { {0, 0.8}, {0.8, 1.2}, {99, 99} }
-- Make the text a bit brighter and fade more gradually
local textAlphaCurve = { {0, 0}, {25, 100}, {120, 190}, {255, 190} }

-- Toggle Custom Tags --
addEvent("toggleNameTags")
addEventHandler("toggleNameTags", root,
	function(bool)
		if bool == true or bool == false then
			enableCustomNametags = bool
			setNametagValues(enableCustomNametags)
		end
	end	)
-----------------------


function nametag.create ( player )
	nametags[player] = true
end

function nametag.destroy ( player )
	nametags[player] = nil
end

function nametagHandler()
		-- Hideous quick fix --
		for i,player in ipairs(g_Players) do
			if player ~= g_Me then
				setPlayerNametagShowing ( player, false )
				if not nametags[player] then
					nametag.create ( player )
				end
			end
		end
		if bHideNametags then
			return
		end
		-- Font double check, return to vanilla if font can't be loaded --
		if not font and enableCustomNametags then
			font = exports.fonts:getFont("OpenSans")
		end

		if not font and enableCustomNametags then
			setNametagValues(false)
		end
		-- End Double Font Check --

		local x,y,z = getCameraMatrix()
		for player in pairs(nametags) do
			while true do
				if not isPedInVehicle(player) or isPedDead(player) then break end

				local playerState = getElementData(player, "player state")

				if playerState == "away" or playerState == "spectating" or playerState == "dead" then break end

				local vehicle = getPedOccupiedVehicle(player)
				local px,py,pz = getElementPosition ( vehicle )
				-- Better positioning for custom nametag
				if enableCustomNametags then
					minx,miny,minz,maxx,maxy,maxz = getElementBoundingBox( vehicle )
					pedminx,pedminy,pedminz,pedmaxx,pedmaxy,pedmaxz = getElementBoundingBox( player )
					if pedmaxz > maxz then maxz = pedmaxz
					elseif maxz > 1.3 then maxz = 1.3 end
				end

				local pdistance = getDistanceBetweenPoints3D ( x,y,z,px,py,pz )
				if pdistance <= NAMETAG_DISTANCE then
					--Get screenposition
					if not enableCustomNametags then
						sx,sy = getScreenFromWorldPosition ( px, py, pz+0.95, 0.06 )
					else
						sx,sy = getScreenFromWorldPosition ( px, py, pz+maxz+0.2, 0.06 )
					end
					if not sx or not sy then break end
					--Calculate our components
					local scale = 1/(NAMETAG_SCALE * (pdistance / NAMETAG_DISTANCE))
					local alpha = ((pdistance - NAMETAG_ALPHA_DISTANCE) / NAMETAG_ALPHA_DIFF)
					alpha = (alpha < 0) and NAMETAG_ALPHA or NAMETAG_ALPHA-(alpha*NAMETAG_ALPHA)
					scale = math.evalCurve(maxScaleCurve,scale)
					local textscale = math.evalCurve(textScaleCurve,scale)
					local textalpha = math.evalCurve(textAlphaCurve,alpha)
					local outlineThickness = NAMETAG_OUTLINE_THICKNESS*(scale)

					if enableCustomNametags then
						local vehAlpha = getElementAlpha(vehicle)
						if vehAlpha < 50 then textalpha = vehAlpha alpha = vehAlpha end
					end
					--Draw our text
					local r,g,b = 255,255,255
					local team = getPlayerTeam(player)
					local name = getElementData(player, 'vip.colorNick') or _getPlayerName(player)
					if team then
						r,g,b = getTeamColor(team)
						if not getElementData(team, 'gcshop.teamid') then
							name = getElementData(player, 'vip.colorNick') or getPlayerName(player)
						end
					end
					if player and getElementData(player, 'markedblocker') then
						name = name .. ' #FFFFFF[GHOST]'
					end
					if player and getElementData(player, 'markedlagger') then
						name = name .. ' #FFFFFF[LAGGER]'
					end
					local offset = (scale) * NAMETAG_TEXT_BAR_SPACE/2
					-- Edit #1 Colour nicknames
					if not bOnlyHealthBar then
						if not enableCustomNametags then
							dxDrawText ( name, sx, sy - offset, sx, sy - offset, tocolor(r,g,b,textalpha), textscale*NAMETAG_TEXTSIZE, "default", "center", "bottom", false, false, false, true )
						elseif enableCustomNametags then
							dxDrawText ( name:gsub("#%x%x%x%x%x%x",""), sx+NAMETAG_TEXTBORDERSIZE, sy - offset+NAMETAG_TEXTBORDERSIZE, sx+NAMETAG_TEXTBORDERSIZE, sy - offset+NAMETAG_TEXTBORDERSIZE, tocolor(0,0,0,textalpha/100*50), textscale*NAMETAG_TEXTSIZE/100*7, font, "center", "bottom", false, false, false, false ,true)
							dxDrawText ( name, sx, sy - offset, sx, sy - offset, tocolor(r,g,b,textalpha), textscale*NAMETAG_TEXTSIZE/100*7, font, "center", "bottom", false, false, false, true,true )

							local isPlayerVIP = getElementData(player,'gcshop.vipbadge')

							if isPlayerVIP then
								local vipBadgeSize = textscale*NAMETAG_TEXTSIZE*20
								local badgeMarginBottom = vipBadgeSize/4
								local badge_drawX = sx - (vipBadgeSize/2)
								local badge_drawY = sy - offset - vipBadgeSize - (NAMETAG_HEIGHT*scale) - badgeMarginBottom
								dxDrawImage( badge_drawX, badge_drawY, vipBadgeSize, vipBadgeSize, NAMETAG_VIP_TEX, 0, 0, 0, tocolor(255,255,255,textalpha) )
								if isPlayerVIP == 'vip' and NAMETAG_VIP_TEX then
									dxDrawImage( badge_drawX, badge_drawY, vipBadgeSize, vipBadgeSize, NAMETAG_VIP_TEX, 0, 0, 0, tocolor(255,255,255,textalpha) )
								elseif isPlayerVIP == 'vip+' and NAMETAG_VIP_PLUS_TEX then
									dxDrawImage( badge_drawX, badge_drawY, vipBadgeSize, vipBadgeSize, NAMETAG_VIP_PLUS_TEX, 0, 0, 0, tocolor(255,255,255,textalpha) )
								end


							end

						end
					end
					--We draw three parts to make the healthbar.  First the outline/background
					local drawX = sx - NAMETAG_WIDTH*scale/2
					drawY = sy + offset
					local width,height =  NAMETAG_WIDTH*scale, NAMETAG_HEIGHT*scale
					dxDrawRectangle ( drawX, drawY, width, height, tocolor(0,0,0,alpha) )
					--Next the inner background
					local _health = getElementHealth(vehicle)
					health = math.max(_health - 250, 0)/750
					local p = -510*(health^2)
					local r,g = math.max(math.min(p + 255*health + 255, 255), 0), math.max(math.min(p + 765*health, 255), 0)
					dxDrawRectangle ( 	drawX + outlineThickness,
										drawY + outlineThickness,
										width - outlineThickness*2,
										height - outlineThickness*2,
										tocolor(r,g,0,0.4*alpha)
									)
					--Finally, the actual health
					dxDrawRectangle ( 	drawX + outlineThickness,
										drawY + outlineThickness,
										health*(width - outlineThickness*2),
										height - outlineThickness*2,
										tocolor(r,g,0,alpha)
									)

					if enableCustomNametags then
						-- Draw % of health
						local healthUnits = _health/10
						if string.find(tostring(healthUnits),"%.") then
							local exp = 1 and 10^1 or 1
							healthUnits = math.ceil(healthUnits*exp-0.5)/exp
							-- healthUnits = string.explode(tostring(healthUnits),"%.")
							-- healthUnits = healthUnits[1]
						end
						local healthRight = drawX + outlineThickness + width - outlineThickness*2
						local healthBottom = drawY + outlineThickness + height - outlineThickness*2
						-- health shadow
						dxDrawText( 		tostring(healthUnits).."%",
											drawX + outlineThickness+0.5,
											drawY + outlineThickness+0.5 ,
											healthRight+0.5,
											healthBottom+0.5,
											tocolor(0,0,0,textalpha/100*50),
											textscale*NAMETAG_TEXTSIZE/100*51.5,
											"clear",
											"center",
											"center",
											true,
											false,
											false,
											false,
											true
											)
						-- health text
						dxDrawText( 		tostring(healthUnits).."%",
											drawX + outlineThickness,
											drawY + outlineThickness ,
											healthRight,
											healthBottom,
											tocolor(255,255,255,textalpha),
											textscale*NAMETAG_TEXTSIZE/100*51.5,
											"clear",
											"center",
											"center",
											true,
											false,
											false,
											false,
											true
											)
					end
				end
				break
			end
		end
end
addEventHandler ( "onClientRender", g_Root, nametagHandler)


---------------THE FOLLOWING IS THE MANAGEMENT OF NAMETAGS-----------------
addEventHandler('onClientResourceStart', g_ResRoot,
	function()
		for i,player in ipairs(getElementsByType"player") do
			if player ~= g_Me then
				nametag.create ( player )
			end
		end
	end
)

addEventHandler ( "onClientPlayerJoin", g_Root,
	function()
		if source == g_Me then return end
		setPlayerNametagShowing ( source, false )
		nametag.create ( source )
	end
)

addEventHandler ( "onClientPlayerQuit", g_Root,
	function()
		nametag.destroy ( source )
	end
)


addEvent ( "onClientScreenFadedOut", true )
addEventHandler ( "onClientScreenFadedOut", g_Root,
	function()
		bHideNametags = true
	end
)

addEvent ( "onClientScreenFadedIn", true )
addEventHandler ( "onClientScreenFadedIn", g_Root,
	function()
		bHideNametags = false
		bOnlyHealthBar = false
	end
)

function hideNameTags ( bool )
	bHideNametags = not not bool
end

function showOnlyHealthBar ( bool )	-- reset on map switch
	bOnlyHealthBar = not not bool
end

-- use /enablenametags or exports.race:enableNametags(false|true)
-- toggle player names and health bars
function enableNametags(mode)
    -- check function parameter, "mode" is optional
	if type(mode) == "boolean" then
		bEnableNametags = mode
	else bEnableNametags = not bEnableNametags
	end

	-- show
	if bEnableNametags then
		addEventHandler("onClientRender", g_Root, nametagHandler)
		outputConsole("Showing nametags.")
	-- hide
	else
		removeEventHandler("onClientRender", g_Root, nametagHandler)
		outputConsole("Hiding nametags.")
	end
end -- function
addCommandHandler("enablenametags", enableNametags)
-- addEvent("onClientMapStarting", true) -- might need this

-- hide default nametags too (they kept reappearing)
addEventHandler("onClientMapStarting", g_Root,
	function()
		if bEnableNametags == false then
			for key, player in ipairs(getElementsByType("player")) do
				setPlayerNametagShowing(player, false)
			end
		end
	end -- function
)
