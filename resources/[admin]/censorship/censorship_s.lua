-- Frequent advertisements:
local ads = {
"vk.com",
"new_era_mta",
"vk.com/newˍeraˍmta",
'Dayz Mod "New Era"'
}

function resourceStart()	
	--outputDebugString("Hello world!",0)
end
addEventHandler('onResourceStart', getResourceRootElement(),resourceStart)

function onPlayerChat_s(msg, msgType)
	msg = string.gsub(msg, "#%x%x%x%x%x%x", "")
	msg = string.lower(msg)
	for a,b in ipairs(ads) do b = string.lower(b) end
	
	local bool = false
	for a,b in ipairs(ads) do
		local s,e = string.find(msg, b)
		if not (s == nil) and not (e == nil) then
			bool = true
			break
		end
	end
	
	if not bool then return end
	cancelEvent()
	local playerName = string.gsub(getPlayerName(source), "#%x%x%x%x%x%x", "")
	outputServerLog("[CANCELED]CHAT: " .. getPlayerName(source) .. ": " .. msg)
	outputDebugString("[CANCELED]CHAT: " .. playerName .. ": " .. msg,3)
	
	local ip = getPlayerIP(source)
	local serial = getPlayerSerial(source)
	local timeMs = 0
	if hasObjectPermissionTo(source, "command.ban") then timeMs = 60*30 end
	addBan(ip, nil, serial, getRootElement(), "Advertising", timeMs)
	outputDebugString("Banned player: " .. playerName .. " IP: " .. ip .. " Serial: " .. serial,3)
end
addEventHandler("onPlayerChat", root, onPlayerChat_s)