function GetRecordHolder()
	local streakXML = xmlLoadFile("streaks.xml")
	if not streakXML then
		streakXML = xmlCreateFile("streaks.xml", "streaks")
		xmlSaveFile(streakXML)
	else
		local recordNameChild = xmlFindChild(streakXML, 'recordName', 0)
		local recordAmountChild = xmlFindChild(streakXML, 'recordAmount', 0)
		if recordNameChild and recordAmountChild then
			local recordNameValue = xmlNodeGetValue(recordNameChild)
			local recordAmountValue = xmlNodeGetValue(recordAmountChild)

			local toReturn = {}
			toReturn[0] = recordNameValue
			toReturn[1] = recordAmountValue

			return toReturn
		end
	end
	return {}
end

function SaveRecordHolder(playername, streak)
	local streakXML = xmlLoadFile("streaks.xml")

	SetNodeValue(streakXML, "recordName", playername)
	SetNodeValue(streakXML, "recordAmount", streak)

	xmlSaveFile(streakXML)
	xmlUnloadFile(streakXML)
end

function SetNodeValue(file, node, value)
	local child = xmlFindChild(file, node, 0)

	if child then
		xmlNodeSetValue(child, value)
	else
		local newChild = xmlCreateChild(file, node)
		xmlNodeSetValue(newChild, value)
	end
end