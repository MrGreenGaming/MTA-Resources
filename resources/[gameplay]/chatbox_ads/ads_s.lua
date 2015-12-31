adMessages = { }



function loadResourceSettings()
	intervalTime = tonumber(get("intervalTime"))*60000
	prefix = tostring(get("prefix"))
end
addEventHandler("onResourceStart", resourceRoot, loadResourceSettings)
setTimer( loadResourceSettings, 30000, 0 )

addCommandHandler( "chatboxads", function(p) if hasObjectPermissionTo( p, "function.banPlayer" , false ) then triggerClientEvent( p, "editChatboxAds", resourceRoot,adMessages ) end end )

function loadAds()
	local theXML = fileExists"ads.xml" and xmlLoadFile("ads.xml") or xmlCreateFile("ads.xml", "ads")
	local childTable = xmlNodeGetChildren( theXML )
	if #childTable == 0 then xmlUnloadFile( theXML ) outputDebugString("No ads in ads.xml") return end

	for _,n in pairs(childTable) do
		local theText = tostring( xmlNodeGetValue(n) )
		table.insert(adMessages,theText)
	end
	outputDebugString(tostring(#childTable).." ads running. /chatboxads to manage them.")
	xmlUnloadFile( theXML )
end
addEventHandler("onResourceStart",resourceRoot,loadAds)




function outputAd()
	setTimer(outputAd,intervalTime,1)
	if #adMessages == 0 then return end

	local theMSG = adMessages[1]
	table.remove(adMessages,1) -- Remove from table
	table.insert(adMessages,theMSG) -- add to the back of the table

	if #theMSG+#prefix > 127 then -- if output is longer then 127 characters(outputChatBox limit)
		local stringTable = splitStringforChatBox(theMSG)
		local outputAmount = 0
		for _,s in ipairs(stringTable) do
			outputAmount = outputAmount+1
			if outputAmount <= 1 then
				outputChatBox(prefix.." "..s,root,0,255,0,true)
			else
				outputChatBox(s,root,0,255,0,true)
			end
		end
	else
		outputChatBox(prefix.." "..theMSG,root,0,255,0,true)
	end
end
setTimer(outputAd,10000,1)

function splitStringforChatBox(str)
	local max_line_length = 127-#prefix
   local lines = {}
   local line
   str:gsub('(%s*)(%S+)', 
      function(spc, word) 
         if not line or #line + #spc + #word > max_line_length then
            table.insert(lines, line)
            line = word
         else
            line = line..spc..word
         end
      end
   )
   table.insert(lines, line)
   return lines
end


addEvent("clientSendNewAds",true)
function saveAdsXML(tbl)
	local savetheXML = xmlLoadFile( "ads.xml" )
	if not savetheXML then
		savetheXML = xmlCreateFile( "ads.xml", "ads" )
	end

	local allNodes = xmlNodeGetChildren( savetheXML )
	if #allNodes > 0 then
		for d,u in pairs(allNodes) do -- remove all nodes
			xmlDestroyNode( u )
		end
	end


	for f,u in ipairs(tbl) do -- add all new nodes
		local child = xmlCreateChild( savetheXML, "ad" )
		xmlNodeSetValue( child, tostring(u) )
	end
	xmlSaveFile( savetheXML )
	xmlUnloadFile( savetheXML )
	outputDebugString("New ads saved by "..getPlayerName(client))
	adMessages = tbl
end
addEventHandler("clientSendNewAds",root,saveAdsXML)