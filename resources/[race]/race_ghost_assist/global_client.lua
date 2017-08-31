_DEBUG = false


function outputDebug( ... )
	if _DEBUG then
		-- outputDebugString( ... )
		-- outputChatBox("* DBG: " .. ..., 0, 255, 0)
		outputDebugString("ASSIST: " .. ...)
	end
end

-- DEBUG
-- !!!
-- remove this later
function assistdebug(player)
	_DEBUG = not _DEBUG
	outputChatBox("* Racing assist debug: "..inspect(_DEBUG), 230, 220, 180)
end
addCommandHandler('assistdebug', assistdebug)


function FormatDate(timestamp)
	local t =  getRealTime(timestamp)
	return string.format("%04d.%02d.%02d. %02d:%02d", t.year + 1900, t.month+1, t.monthday, t.hour, t.minute)
end

function RemoveHEXColorCode(s) 
    return s:gsub('#%x%x%x%x%x%x', '') or s 
end


function msToTimeStr(ms)
	if not ms then
		return ''
	end
	local centiseconds = tostring(math.floor(math.fmod(ms, 1000)/10))
	if #centiseconds == 1 then
		centiseconds = '0' .. centiseconds
	end
	local s = math.floor(ms / 1000)
	local seconds = tostring(math.fmod(s, 60))
	if #seconds == 1 then
		seconds = '0' .. seconds
	end
	local minutes = tostring(math.floor(s / 60))
	return minutes .. ':' .. seconds .. ':' .. centiseconds
end

function removeColorCoding(name)
	return type(name)=='string' and string.gsub(name, '#%x%x%x%x%x%x', '') or name
end


function math.clamp(low, value, high)
	return math.max(low, math.min(value, high))
end