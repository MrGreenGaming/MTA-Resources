function getAllBans(page)
	if not page then page = 0 end
	return formatBans((page-1) * max_bans, page * max_bans)
end

function getAllBansPages()
	local pages = 1
	for id_val, val in pairs(getBans()) do
		if id_val % max_bans == 0 then
			pages = pages + 1
		end
	end
	return pages
end

function formatBan(ban)
	local btime = getBanTime(ban) or ""
	local ip = getBanIP(ban) or ""
	local serial = getBanSerial(ban) or ""
	local reason = getBanReason(ban) or ""
	local admin = getBanAdmin(ban) or ""
	local nick = getBanNick(ban) or "Unknown"
	local tabletime = getRealTime(btime)
	
	if(tabletime.minute < 10) then
		tabletime.minute = "0"..tabletime.minute
	end
	if(tabletime.hour < 10) then
		tabletime.hour = "0"..tabletime.hour
	end
	if(tabletime.monthday < 10) then
		tabletime.monthday = "0"..tabletime.monthday
	end
	
	local outtime = tabletime.year + 1900 .. "/" .. tabletime.month + 1 .. "/" .. tabletime.monthday .. " " .. tabletime.hour .. ":" .. tabletime.minute
	
	local button = "<img src=\"images/delete.png\" alt=\"X\" title=\"Delete ban\" onclick=\"confrm('"
	
	if serial ~= "" then
		button = button .. serial .. "');\" />"
	elseif ip ~= "" then
		button = button .. ip .. "');\" />"
	end
	
	return "<tr><td>"..outtime.."</td><td>"..ip.."</td><td>"..serial.."</td><td>"..reason.."</td><td>"..admin.."</td><td>"..nick.."</td><td>"..button.."</td></tr>"
end

function formatBans(key_min, key_max)
	local tick = getTickCount()
	local output = {}
	local bans = getBans()
	local bansc = #bans
	
	for key=key_min, key_max, 1 do 
		local ban = bans[bansc-key]
		if ban then
			table.insert(output, formatBan(ban))
		else 
			break
		end
	end
	
	return output, getTickCount() - tick
end

_removeBan = removeBan
function removeBan(ban, val, user)
	if(ban) then
		if(hasObjectPermissionTo(g_res, "function.removeBan")) then
			if(_removeBan(ban)) then
				outputServerLog("UNBAN: Webban: ".. val ..", ".. tostring(user) .." account.")
				return true
			end
		end
	end
	return false
end

function unban(val, user)
	val = tostring(val)
	for row, ban in pairs(getBans()) do
		if(getBanSerial(ban) == val) or (getBanIP(ban) == val)then
			return removeBan(ban, val, user)
		end
	end
	return false
end

function getBansSearch(search, typeofsearch, page)
	typeofsearch = tostring(typeofsearch)
	search = string.upper(tostring(search))
	
	if not page then
		page = 1
	else
		page = tonumber(page)
	end
	
	local tick = getTickCount()
	local searchFunction = nil
	local valid = {}
	local output = {}
	local amount = 0
	local all_pages = 1
	local output_string = ""
	
	if typeofsearch == "IP" then
		searchFunction = getBanIP
	elseif typeofsearch == "Serial" then
		searchFunction = getBanSerial
	elseif typeofsearch == "Admin" then
		searchFunction = getBanAdmin
	elseif typeofsearch == "Nick" then
		searchFunction = getBanNick
	elseif typeofsearch == "Reason" then
		searchFunction = getBanReason
	end
	
	if not ( searchFunction == nil ) then
		for key, value in pairs(getBans()) do
			local ret = string.upper(tostring(searchFunction(value)))
			if string.find(ret, search, 0, true) then
				amount = amount + 1
				if amount % max_bans == 0 then
					all_pages = all_pages + 1
				end
				table.insert(output, formatBan(value))
			end
		end
	end
	
	if amount == 0 then
		all_pages = 0
	else
		local nums = #output
		for index=(page-1) * max_bans, page * max_bans, 1 do 
			local ban = output[nums-index]
			if ban then
				output_string = output_string .. ban
			else 
				break
			end
		end
	end
	
	return output_string, all_pages, getTickCount() - tick
end