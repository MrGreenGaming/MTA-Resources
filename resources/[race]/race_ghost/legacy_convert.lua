function readGhostFile(path)
	local file = fileOpen(path)
	if not file then
		return nil
	end

	local data = fileRead(file, fileGetSize(file))
	fileClose(file)

	return data
end

function saveGhostFile(path, data)
	local file = fileCreate(path)
	if not file then
		return false
	end

	fileWrite(file, toJSON(data, true))
	fileClose(file)

	return true
end

function isLegacyGhost(data)
	return data:sub(1, 1) == "<"
end

-- Function to convert XML-like string to JSON using string.gsub
function legacyConvert(input)
	-- Prepare the JSON result table
	local jsonResult = {
		recording = {},
	}

	-- Extract name and bestTime from the <i> element using gsub
	input = input:gsub('<i r="(.-)" t="(.-)"[^>]*forumid="(.-)"[^>]*></i>', function(racer, bestTime, forumID)
		jsonResult.racer = racer
		jsonResult.bestTime = bestTime
		jsonResult.forumid = forumID
		return "" -- Remove the matched <i> element from input
	end)

	-- Extract entry attributes from <n> elements using gsub
	input:gsub("<n (.-)</n>", function(attributes)
		local recording = {}
		-- Iterate over key-value pairs in the attributes
		attributes:gsub('(%w+)="([^"]+)"', function(key, value)
			recording[key] = convert(value)
		end)
		table.insert(jsonResult.recording, recording)
	end)

	return jsonResult
end
