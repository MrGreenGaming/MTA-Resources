
-- SEARCH CURL = http://api.soundcloud.com/tracks.json?q=QUERY&streamable=true&limit=10&client_id=e796074ad95696e84774e2eaa0c78369

searchFetcherURL = "http://mrgreengaming.com/stuff/SoundCloudFetcher/searchFetch.php" -- the URL to the php page with cURL code to fetch song info --
clientID = "e796074ad95696e84774e2eaa0c78369"
function fetchSearchResults(q, pSer) --Sends URL to webserver to fetch soundcloud info--

	local encodedQ = url_encode(q)
	local searchCURL = "http://api.soundcloud.com/tracks.json?q="..encodedQ.."&streamable=true&limit=15&client_id="..clientID
	fetchRemote (searchCURL, receiveSearchData, "", false, pSer)




end
addEvent( "onClientAskSearch", true)
addEventHandler( "onClientAskSearch", resourceRoot, fetchSearchResults )



function receiveSearchData(a,b,c)
	local requestedPlayerSerial = c
	a = a:gsub([["[%a_]-":null,]], '') -- Credit to SDK --
	searchData = {fromJSON(a)}


	if searchData then


			-- strip unused data from table --
			for f, u in ipairs(searchData) do
				u["created_at"] = nil
				u["commentable"] = nil
				u["created_at"] = nil
				u["state"] = nil
				u["original_content_size"] = nil
				u["last_modified"] = nil
				u["sharing"] = nil
				u["tag_list"] = nil
				u["description"] = nil
				u["label_name"] = nil
				u["release"] = nil
				u["track_type"] = nil
				u["key_signature"] = nil
				u["isrc"] = nil
				u["license"] = nil
				u["waveform_url"] = nil
				u["stream_url"] = nil
				u["download_url"] = nil
				u["playback_count"] = nil
				u["download_count"] = nil
				u["favoritings_count"] = nil
				u["comment_count"] = nil
				u["attachments_uri"] = nil
				u["policy"] = nil
				u["purchase_url"] = nil
				u["embeddable_by"] = nil
				u["permalink"] = nil
				u["release_day"] = nil
				u["uri"] = nil
				u["release_year"] = nil
				u["original_format"] = nil
				u["release_month"] = nil								
				u["user"]["permalink_url"] = nil
				u["user"]["permalink"] = nil
				u["user"]["uri"] = nil
				u["user"]["last_modified"] = nil
				u["user"]["last_modified"] = nil

			
			end
			-- end stripping -- 


		triggerClientEvent( getPlayerFromSerial(requestedPlayerSerial), "onSendSearchResultstoClient", getRootElement(), searchData ) -- Send Search Result Table to client
		searchData = {}
	end
end



function giveClientID(pSerial)
	triggerClientEvent( getPlayerFromSerial(pSerial), "serverSendClientID", resourceRoot, clientID )
end
addEvent("onClientAskClientID", true)
addEventHandler("onClientAskClientID", resourceRoot, giveClientID)




function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end


function getPlayerFromSerial ( serial )
    assert ( type ( serial ) == "string" and #serial == 32, "getPlayerFromSerial - invalid serial" )
    for index, player in ipairs ( getElementsByType ( "player" ) ) do
        if ( getPlayerSerial ( player ) == serial ) then
            return player
        end
    end
    return false
end

--Artwork--
addEvent("onClientImageRequest", true)
addEventHandler("onClientImageRequest", root,
    function ( url, id )
        fetchRemote(url, function ( datas, errno, player, url )
                triggerLatentClientEvent( player, "onClientGotImageResponse", player, url, datas, errno ) end, "", false, client, url)
    end
)
-- end Artwork--


function var_dump(...)
	-- default options
	local verbose = false
	local firstLevel = true
	local outputDirectly = true
	local noNames = false
	local indentation = "\t\t\t\t\t\t"
	local depth = nil
 
	local name = nil
	local output = {}
	for k,v in ipairs(arg) do
		-- check for modifiers
		if type(v) == "string" and k < #arg and v:sub(1,1) == "-" then
			local modifiers = v:sub(2)
			if modifiers:find("v") ~= nil then
				verbose = true
			end
			if modifiers:find("s") ~= nil then
				outputDirectly = false
			end
			if modifiers:find("n") ~= nil then
				verbose = false
			end
			if modifiers:find("u") ~= nil then
				noNames = true
			end
			local s,e = modifiers:find("d%d+")
			if s ~= nil then
				depth = tonumber(string.sub(modifiers,s+1,e))
			end
		-- set name if appropriate
		elseif type(v) == "string" and k < #arg and name == nil and not noNames then
			name = v
		else
			if name ~= nil then
				name = ""..name..": "
			else
				name = ""
			end
 
			local o = ""
			if type(v) == "string" then
				table.insert(output,name..type(v).."("..v:len()..") \""..v.."\"")
			elseif type(v) == "userdata" then
				local elementType = "no valid MTA element"
				if isElement(v) then
					elementType = getElementType(v)
				end
				table.insert(output,name..type(v).."("..elementType..") \""..tostring(v).."\"")
			elseif type(v) == "table" then
				local count = 0
				for key,value in pairs(v) do
					count = count + 1
				end
				table.insert(output,name..type(v).."("..count..") \""..tostring(v).."\"")
				if verbose and count > 0 and (depth == nil or depth > 0) then
					table.insert(output,"\t{")
					for key,value in pairs(v) do
						-- calls itself, so be careful when you change anything
						local newModifiers = "-s"
						if depth == nil then
							newModifiers = "-sv"
						elseif  depth > 1 then
							local newDepth = depth - 1
							newModifiers = "-svd"..newDepth
						end
						local keyString, keyTable = var_dump(newModifiers,key)
						local valueString, valueTable = var_dump(newModifiers,value)
 
						if #keyTable == 1 and #valueTable == 1 then
							table.insert(output,indentation.."["..keyString.."]\t=>\t"..valueString)
						elseif #keyTable == 1 then
							table.insert(output,indentation.."["..keyString.."]\t=>")
							for k,v in ipairs(valueTable) do
								table.insert(output,indentation..v)
							end
						elseif #valueTable == 1 then
							for k,v in ipairs(keyTable) do
								if k == 1 then
									table.insert(output,indentation.."["..v)
								elseif k == #keyTable then
									table.insert(output,indentation..v.."]")
								else
									table.insert(output,indentation..v)
								end
							end
							table.insert(output,indentation.."\t=>\t"..valueString)
						else
							for k,v in ipairs(keyTable) do
								if k == 1 then
									table.insert(output,indentation.."["..v)
								elseif k == #keyTable then
									table.insert(output,indentation..v.."]")
								else
									table.insert(output,indentation..v)
								end
							end
							for k,v in ipairs(valueTable) do
								if k == 1 then
									table.insert(output,indentation.." => "..v)
								else
									table.insert(output,indentation..v)
								end
							end
						end
					end
					table.insert(output,"\t}")
				end
			else
				table.insert(output,name..type(v).." \""..tostring(v).."\"")
			end
			name = nil
		end
	end
	local string = ""
	for k,v in ipairs(output) do
		if outputDirectly then
			outputConsole(v)
		end
		string = string..v
	end
	return string, output
end



-- SDK's Solution to the JSON parser bug --
-- local url = "http://api.soundcloud.com/tracks.json?q=QUERY&streamable=true&limit=10&client_id=e796074ad95696e84774e2eaa0c78369"
-- fetchRemote ( url, function ( a, b )
--         a = a:gsub([["[%a_]-":null,]], '')
--         data = {fromJSON(a)}
--         for k,v in pairs (data) do
--                 outputDebugString(k .. ' id ' .. tostring(v.id))
--                 outputDebugString(k .. ' title ' .. tostring(v.title))
--                 outputDebugString(k .. ' duration ' .. tostring(v.duration))
--                 outputDebugString(k .. ' username ' .. tostring(v.user.username))
--                 outputDebugString(k .. ' url ' .. tostring(v.permalink_url))
--                 outputDebugString(k .. ' artwork ' .. tostring(v.artwork_url))
--         end
--         var_dump("-v", a)
-- end
-- )

