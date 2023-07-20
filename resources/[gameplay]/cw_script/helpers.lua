function getPrefix(number)
	if number == 11 or number == 12 or number == 13 then
		return 'th'
	end

	number = number % 10

	if number == 1 then
		return 'st'
	elseif number == 2 then
		return 'nd'
	elseif number == 3 then
		return 'rd'
	else
		return 'th'
	end

end
