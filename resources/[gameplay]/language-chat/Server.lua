-----------------------------------------------------------------------------
-- =x=|DoN|=x= ( 7eJAzZy )
-- Date: 2014/2015
-- Skype: DON.81
-- Please don't remove my rights
-----------------------------------------------------------------------------
SpamTime = {}

local tags = { -- A bit more advanced.
	{ 'VIP', '#FFFF00[VIP] ', '[VIP]', '#FFFFFF', '%[VIP%]' },
	{ 'Killers', '#00FFFF[Mod] ', '[Mod]', '#FFFFFF', '%[Mod%]' },
	{ 'Admin', '#0099FF[Admin] ', '[Admin]', '#FFFFFF', '%[Admin%]' },
	{ 'Developer', '#FFA500[Dev] ', '[Dev]', '#FFFFFF', '%[Dev%]' },
}

-- add in the table the blocked words
BlockedMessages = {
};

addEventHandler( 'onPlayerJoin',root,
    function( )
   		bindKey(source, "R", "down", "chatbox", "Language")
    end
)
 
addEventHandler( 'onResourceStart', resourceRoot,
    function ( )
        for _, player in ipairs( getElementsByType( 'player' ) ) do
			bindKey(player, "R", "down", "chatbox", "Language")
        end
    end
)

addEvent("setNewLanguageBindKey", true)
addEventHandler("setNewLanguageBindKey",resourceRoot,
function (  )
	setElementData(source, "Language", getElementData(client, "Language"), true)
end )


addCommandHandler("Language",
function (player, cmd, ...) 
	local prefixTag = ""
	local account = getAccountName(getPlayerAccount(player))

	-- return everything if the player does not choose a language
	if getElementData(player,"Language") == false then return outputChatBox("[Language Chat]: Please select a language using /language", player, 255, 0,0 , false) end
	-- check if the player have mute
	if isPlayerMuted ( player ) then 
		return outputChatBox("[Language Chat]: You are muted",player,255,0,0,true) 
	end

	-- for blocked words
	for k,v in ipairs (BlockedMessages) do
		if string.find(table.concat ( { ... }, " " ),v) then
			return outputChatBox("Blocked word sorry bortha",player,255,0,0,true)
		end
	end

	-- Prefix like [VIP] or [Dev]
	for _, v in ipairs(tags) do
		if v[1] == "VIP" then
			if exports["mrgreen-vip"]:isPlayerVIP(player) then
				prefixTag = v[2]
			end
		elseif isObjectInACLGroup('user.' .. account, aclGetGroup(v[1])) then
			prefixTag = v[2]
		end
	end


	-- language chat
		for _,players in ipairs(getElementsByType("player")) do
			if getElementData(players,"Language") == getElementData(player,"Language") then
				local language = string.upper(getElementData(player,"Language"))
				
				outputChatBox("#FF0000".. language .."> ".. prefixTag .. getFullPlayerName(player) .. ":#FFFFFF " .. table.concat ( { ... }, " " ).."", players, 255, 255, 255, true)
				end
		end
end )


function getFullPlayerName(player)
	local playerName = getElementData( player, "vip.colorNick" ) or getPlayerName( player )
	local teamColor = "#FFFFFF"
	local team = getPlayerTeam(player)
	if (team) then
		r,g,b = getTeamColor(team)
		teamColor = string.format("#%.2X%.2X%.2X", r, g, b)
	end
	return "" .. teamColor .. playerName
end
