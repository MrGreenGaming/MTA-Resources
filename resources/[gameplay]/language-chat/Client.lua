-----------------------------------------------------------------------------
-- =x=|DoN|=x= ( 7eJAzZy )
-- Date: 2014/2015
-- Skype: DON.81
-- Please don't remove my rights
-----------------------------------------------------------------------------
local LanguageTableList = {
	{"Arabic"},
	{"Spanish"},
	{"Hindi"},
	{"Portuguese"},
	{"Russian"},
	{"German"},
	{"French"},
	{"Turkish"},
	{"Polish"},
	{"Romanian"},
	{"Dutch"},
	{"Hungarian"},
    {"Lithuanian"},
    {"Swedish"},
    {"Latvian"},
    {"Balkan"},
    {"Italian"},
}

function isLanguageInTable(language) 
	for i, v in ipairs(LanguageTableList) do
		if language == v[1] then return true end
	end
	return false
end

WindowLanguage = guiCreateWindow(0.36, 0.16, 0.31, 0.68, "Languages for Language Chat", true)
guiSetVisible ( WindowLanguage, false )
GridlistLanguage = guiCreateGridList(0.04, 0.06, 0.92, 0.69, true, WindowLanguage)

table.sort(LanguageTableList, function(a, b) return a[1]:upper() < b[1]:upper() end)

guiGridListAddColumn(GridlistLanguage, "Languages List", 0.9)
for i,v in ipairs ( LanguageTableList ) do
	local Row = guiGridListAddRow( GridlistLanguage )
   guiGridListSetItemText( GridlistLanguage, Row, 1, v[1], false, false )
end	

setNewLanguage = guiCreateButton(0.04, 0.77, 0.92, 0.09, "Set new Language", true, WindowLanguage)
Close = guiCreateButton(0.04, 0.88, 0.92, 0.09, "Close", true, WindowLanguage)


addEventHandler("onClientGUIClick",resourceRoot,
function ( )
local row, col = guiGridListGetSelectedItem ( GridlistLanguage ) 
local Group = guiGridListGetItemText(GridlistLanguage,row,1 )
	if source == setNewLanguage then
		if ( row and col and row ~= -1 and col ~= -1 ) then
			setElementData(localPlayer,"Language",Group,true)
			outputChatBox("Your new Language chat is "..getElementData(localPlayer,"Language")..". Press R to talk in Language Chat",0,255,0)
			triggerServerEvent ( "setNewLanguageBindKey",resourceRoot )

			-- Saves selected language locally in a XML file
			local languageXML = xmlLoadFile("/settings/language.xml")
			local theChild = xmlFindChild(languageXML, "language", 0)

			if theChild then
				xmlNodeSetValue(theChild, Group)
			else
				local theNewChild = xmlCreateChild(languageXML, "language")
				xmlNodeSetValue(theNewChild, Group)
			end

			xmlSaveFile(languageXML)
			xmlUnloadFile(languageXML)

			guiSetVisible( WindowLanguage , not guiGetVisible(WindowLanguage))
			showCursor(guiGetVisible(WindowLanguage))
		else
			outputChatBox("Please choose a langauge",255,0,0)
		end
	elseif source == Close then
		guiSetVisible( WindowLanguage , not guiGetVisible(WindowLanguage))
		showCursor(guiGetVisible(WindowLanguage))
	end
end )

function OpenWindow(  )
   guiSetVisible( WindowLanguage , not guiGetVisible(WindowLanguage))
   showCursor(guiGetVisible(WindowLanguage))
end
addCommandHandler("language",OpenWindow)


-- Fetches the user's language from the locally XML file
local languageXML = xmlLoadFile("/settings/language.xml")
if not languageXML then
	languageXML = xmlCreateFile("/settings/language.xml", "settings")
	xmlSaveFile(languageXML)
    OpenWindow()
else
	local theChild = xmlFindChild(languageXML, "language", 0)
	if theChild then
		local language = xmlNodeGetValue(theChild)
		if isLanguageInTable(language) then
			setElementData(localPlayer, "Language", language, true)
			triggerServerEvent ( "setNewLanguageBindKey",resourceRoot )
        else
            OpenWindow()
		end
	end
end
xmlUnloadFile(languageXML)

