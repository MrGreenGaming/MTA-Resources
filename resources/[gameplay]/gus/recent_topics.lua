--[[
	Script that fetches the recent forum posts from L4G and shows them in chat
--]]

local url = "http://mrgreengaming.com/forums/forum/31-multi-theft-auto/";
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
addCommandHandler('recent', fetch);

function fetchCallback ( data, errno, ... )
	if (errno ~= 0) then
		outputDebugString("fetchRemote error: " .. tostring(errno) .. ' (' .. type(errno) .. ')');
		return error();
	end
	data = split ( data, "\n" );
	local x = -1;
	local title = "";
	local pinned = false
	outputChatBox("Recent MTA subforum topics on Mr.Green", root, 0, 255, 0 );
	for _, line in ipairs ( data ) do
		if (string.find(line, "Pinned")) then
			pinned = true
		elseif (string.find(line, "topic_title")) then
			if not pinned then
				x = x + 1;
				if x > 0 then
					title = string.match(unescape(line), "title='(.+) %- started");
					author = string.gsub(string.match(unescape(data[_+6]), "(<a .*</a>)"), "<.->", "")
					outputChatBox ( '* ' .. title .. ' (' .. author .. ')', root, 0, 255, 0 );
				end
			else
				pinned = false
			end
		end
		if (x >= showTopics) then
			return;
		end
	end
end

-- http://stackoverflow.com/questions/14899734/unescape-numeric-xml-entities-with-lua
local gsub, char = string.gsub, string.char
local entityMap  = {["lt"]="<",["gt"]=">",["amp"]="&",["quot"]='"',["apos"]="'"}
local entitySwap = function(orig,n,s)
  return entityMap[s] or n=="#" and char(s) or orig
end
function unescape(str)
  return gsub( str, '(&(#?)([%d%a]+);)', entitySwap )
end