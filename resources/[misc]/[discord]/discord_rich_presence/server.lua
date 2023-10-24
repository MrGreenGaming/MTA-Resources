local appId
local websiteUrl
local serverUrl

function clientRequestInitialization()
    appId = get("discord_rich_presence.appId") or nil
    websiteUrl = get("discord_rich_presence.forumUrl") or "https://mrgreengaming.com"
    serverUrl = get("discord_rich_presence.serverUrl") or nil
    if appId then
        triggerClientEvent(source, "onDiscordRichPresenceInitialize", resourceRoot, appId, websiteUrl, serverUrl)
    end
end
addEvent("onClientRequestDiscordInitialization", true)
addEventHandler("onClientRequestDiscordInitialization", root, clientRequestInitialization)

