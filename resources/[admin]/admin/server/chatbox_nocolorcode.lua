_outputChatBox = outputChatBox
function outputChatBox(text,visibleTo,r,g,b,colorCoded)
	text = string.gsub(text,'#%x%x%x%x%x%x', '')
	visibleTo = visibleTo or getRootElement()
	r = r or 231
	g = g or 217
	b = b or 176
	if type(colorCoded) ~= "boolean" then colorCoded = false end

	_outputChatBox(text,visibleTo,r,g,b,colorCoded)
end