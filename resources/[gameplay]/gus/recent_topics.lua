--[[
	Script that fetches the recent forum posts from forum and shows them in chat
--]]

local url = "https://forums.mrgreengaming.com/forum/99-mta-events.xml";
local interval = 30 * 60 * 1000;

function onStart()
	setTimer(fetch, interval, 0);
end
addEventHandler ( 'onResourceStart', resourceRoot, onStart);

function fetch()
	fetchRemote ( url , fetchCallback );
end
-- addCommandHandler('recent', fetch);

function fetchCallback ( data, errno, ... )
	if (errno ~= 0) then
		outputDebugString("fetchRemote error: " .. tostring(errno) .. ' (' .. type(errno) .. ')');
		return error();
	end

	outputChatBox("Check out the latest events on the Forums/Discord:", root, 0, 255, 0 );
	local showTopics = getNumber('gus.showTopics', 1);
	if data then
		local f = fileCreate'recent.xml'
		fileWrite(f, data)
		fileClose(f)

		if showTopics < 1 then return end

		local x = xmlLoadFile'recent.xml'
		if x then
			local c = xmlFindChild(x, 'channel', 0)
			if c then
				for i=1,showTopics do
					local item = xmlFindChild(c, 'item', i-1)
					if item then
						local title = xmlFindChild(item, 'title', 0)
						-- outputChatBox ( '* ' .. xmlNodeGetValue(title) .. ' (' .. author .. ')', root, 0, 255, 0 );
						outputChatBox ( '* ' .. xmlNodeGetValue(title), root, 0, 255, 0 );
					else
						break
					end
				end
			end
			xmlUnloadFile(x)
		end
		fileDelete'recent.xml'
	else
		outputDebugString'recent forum topics error'
	end
end


function getNumber(var,default)
	local result = get(var)
	if not result then
			return default
	end
	return tonumber(result)
end