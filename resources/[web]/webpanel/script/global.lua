g_root = getRootElement()
g_res = getThisResource()
g_rroot = getResourceRootElement(g_res)

_players = {}
_messages = {}
_bans = {}

max_bans = tonumber(get("@webpanel.max_bansPerPage") or 10)
max_chat = tonumber(get("@webpanel.max_chatMsgs") or 20)

function startHandler(resource)
	if getThisResource() == resource then
		IP = hasObjectPermissionTo(getThisResource(), "function.getPlayerIP")
		
		if(not hasObjectPermissionTo(resource, "function.removeBan")) then
			outputDebugString("Resource '".. getResourceName(g_res) .."' does not have enough rights (function.removeBan).", 1, 255, 0, 0)
		end
		
		if(not IP) then
			outputDebugString("Resource '".. getResourceName(g_res) .."' does not have enough rights (function.getPlayerIP).", 1, 255, 0, 0)
		end
	end
end

addEventHandler("onResourceStart", g_rroot, startHandler)