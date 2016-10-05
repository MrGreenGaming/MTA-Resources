function secondsToTimeDesc( seconds, formatting )
	if not seconds then return "" end
	
	if seconds < 60 then return math.floor(seconds).." seconds" end
	
	if seconds and formatting == "hours" then
		local results = {}
		local min = math.floor ( ( seconds % 3600 ) /60 )
		local hou = math.floor ( seconds/3600 )

		if hou > 0 then table.insert( results, hou .. ( hou == 1 and " hour" or " hours" ) ) end
		if min > 0 then table.insert( results, min .. ( min == 1 and " minute" or " minutes" ) ) end
		
		return table.concat ( results, ", " )
	else
		local results = {}
		local min = math.floor ( ( seconds % 3600 ) /60 )
		local hou = math.floor ( ( seconds % 86400 ) /3600 )
		local day = math.floor ( ( seconds % 31536000) /86400)
		local year = math.floor ( seconds/31536000 )

		if year > 0 then table.insert( results, year .. ( year == 1 and " year" or " years" ) ) end
		if day > 0 then table.insert( results, day .. ( day == 1 and " day" or " days" ) ) end
		if hou > 0 then table.insert( results, hou .. ( hou == 1 and " hour" or " hours" ) ) end
		if min > 0 then table.insert( results, min .. ( min == 1 and " minute" or " minutes" ) ) end
		
		return table.concat ( results, ", " )
	end
	return ""
end