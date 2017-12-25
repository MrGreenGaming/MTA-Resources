--[[
	Script that fetches the recent forum posts from forum and shows them in chat
--]]

local url = "https://mrgreengaming.com/forums/forum/31-multi-theft-auto.xml";
local showTopics = 4;
local interval = 3 * 60 * 60 * 1000;
local chatDelay = 10 * 1000;

local fetchTimer, chatDelayTimer = nil;
function onStart()
	fetchTimer = setTimer(getReadyForFetch, interval, 0);
end
addEventHandler ( 'onResourceStart', resourceRoot, onStart);

function getReadyForFetch()
	chatDelayTimer = setTimer ( fetch, chatDelay, 1 );
end

function delayFetch()
	if ( isTimer(chatDelayTimer) ) then
		resetTimer(chatDelayTimer);
		resetTimer(fetchTimer);
	end
end
addEventHandler('onPlayerChat', root, delayFetch);

function fetch()
	fetchRemote ( url , fetchCallback );
end
-- addCommandHandler('recent', fetch);

function fetchCallback ( data, errno, ... )
	if (errno ~= 0) then
		outputDebugString("fetchRemote error: " .. tostring(errno) .. ' (' .. type(errno) .. ')');
		return error();
	end

	outputChatBox("Recent MTA subforum topics on Mr.Green", root, 0, 255, 0 );
	if data then
		local f = fileCreate'recent.xml'
		fileWrite(f, data)
		fileClose(f)
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
