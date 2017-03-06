local languages = { -- { google, name, language flag, {country codes}}
{"auto", "Detect language","fam",{"FAM","AQ","BW","BZ","CX","GH","MV","PG","PH","TK","ZM"}}, -- Detect flag
{"af", "African","za",{"NA","ZA"}},
{"sq", "Albanian","al",{"AL"}},
{"am", "Amharic","et",{"ET"}},
{"ar", "Arabic","ae",{"AE","BH","DZ","EG","EH","ER","IQ","JO","KM","KW","LB","LY","MA","MR","OM","PS","QA","SA","SY","TN","YE"}},
{"ay", "Armenian","am",{"AM"}},
{"az", "Azerbaijani","az",{"AZ"}},
{"eu", "Basque","es",{}},
{"be", "Belarusian","by",{"BY"}},
{"bn", "Bengal","bd",{"BD"}},
{"bs", "Bosnian","ba",{"BA"}},
{"bg", "Bulgarian","bg",{"BG"}},
{"my", "Burmese","mm",{"MM"}},
{"ca", "Catalonian","es",{}},
{"ceb", "Cebuano","ph",{}},
{"ny", "Chichewa","mw",{"MW"}},
{"zh-CN", "Chinese","cn",{"CN","HK","TW"}},
{"co", "Corsican","fr",{}},
{"hr", "Croatian","hr",{"HR"}},
{"cs", "Czech","cz",{"CZ"}},
{"da", "Danish","dk",{"DK","FO","GL"}},
{"nl", "Dutch","nl",{"AW","BE","BQ","CW","NL","SR","SX"}},
{"en", "English","gb",{"AG","AI","AU","BB","BM","BS","CA","CK","DM","FJ","FK","FM","GB","GD","GG","GI","GM","GS","GU","GY","HM","IM","IO","JE","JM","KE","KI",
"KN","KY","LC","LR","MH","MP","MS","MU","NF","NR","NU","NZ","PN","PW","SB","SG","SH","SL","SS","SZ","TC","TO","TT","TV","UM","US","VC","VG","VI","VU"}},
{"eo", "Esperanto","fam",{}}, -- Esperanto flag
{"et", "Estonian","ee",{"EE"}},
{"fi", "Finnish","fi",{"FI"}},
{"fr", "French","fr",{"BF","BI","BJ","BL","CD","CF","CG","CI","CM","FR","GA","GF","GN","GP","MC","MF","ML","MQ","NC","PF","PM","RE","RW","SC","SN","TD",
"TF","TG","WF","YT"}},
{"fy", "Frisian","nl",{}},
{"gl", "Galician","es",{}},
{"ka", "Georgian","ge",{"GE"}},
{"de", "German","de",{"AT","CH","DE","LI"}},
{"el", "Greek","gr",{"CY","GR"}},
{"gu", "Gujarati","in",{}},
{"ht", "Haitian creole","ht",{"HT"}},
{"ha", "Hausa","ne",{"NE","NG"}},
{"haw", "Hawaiian","us",{}},
{"iw", "Hebrew","il",{"IL"}},
{"hi", "Hindi","in",{"IN"}},
{"hmn", "Hmong","cn",{}},
{"hu", "Hungarian","hu",{"HU"}},
{"is", "Icelandic","is",{"IS"}},
{"ig", "Igbo","ng",{}},
{"id", "Indonesian","id",{"ID"}},
{"ga", "Irish","ie",{"IE"}},
{"it", "Italian","it",{"IT","SM","VA"}},
{"ja", "Japanese","jp",{"JP"}},
{"jw", "Javanese","id",{}},
{"ka", "Kannada","in",{}},
{"kk", "Kazakh","kz",{"KZ"}},
{"km", "Khmer","kh",{"KH"}},
{"ky", "Kirghiz","kg",{"KG"}},
{"ko", "Korean","kr",{"KP","KR"}},
{"ku", "Kurdish","iq",{}},
{"lo", "Lao","la",{"LA"}},
{"la", "Latin","va",{}},
{"lv", "Latvian","lv",{"LV"}},
{"lt", "Lithuanian","li",{"LT"}},
{"lb", "Luxembourgish","lu",{"LU"}},
{"mk", "Macedonian","mk",{"MK"}},
{"mg", "Malagasy","mg",{"MG"}},
{"ms", "Malay","my",{"BN","CC","MY"}},
{"ml", "Malayalam","in",{}},
{"mt", "Maltese","mt",{"MT"}},
{"mi", "Maori","nz",{}},
{"mr", "Marathi","in",{}},
{"mn", "Mongolian","mn",{"MN"}},
{"ne", "Nepalese","np",{"BT","NP"}},
{"no", "Norwegian","no",{"BV","NO","SJ"}},
{"ps", "Pashto","af",{"AF"}},
{"fa", "Persian","ir",{"IR"}},
{"pl", "Polish","pl",{"PL"}},
{"pt", "Portuguese","pt",{"AO","BR","CV","GW","MO","MZ","PT","ST","TL"}},
{"pa", "Punjabi","pk",{"PK"}},
{"ro", "Romanian","ro",{"MD","RO"}},
{"ru", "Russian","ru",{"RU","TM"}},
{"sm", "Samoan","ws",{"AS","WS"}},
{"gd", "Scottish Celtic","gb",{}},
{"sr", "Serbian","rs",{"ME","RS"}},
{"st", "Sesotho","ls",{"LS"}},
{"sn", "Shona","zw",{"ZW"}},
{"sd", "Sindhi","pk",{}},
{"si", "Sinhala","lk",{"LK"}},
{"sk", "Slovak","sk",{"SK"}},
{"sl", "Slovenian","si",{"SI"}},
{"so", "Somalian","so",{"DJ","SO"}},
{"es", "Spanish","es",{"AD","AR","BO","CL","CO","CR","CU","DO","EC","ES","GQ","GT","HN","MX","NI","PA","PE","PR","PY","SV","UY","VE"}},
{"su", "Sudanese","sd",{"SD"}},
{"sw", "Swahili","tz",{"TZ","UG"}},
{"sv", "Swedish","se",{"AX","SE"}},
{"tg", "Tadjik","tj",{"TJ"}},
{"tl", "Tagalog","ph",{}},
{"ta", "Tamil","in",{}},
{"te", "Telugu","in",{}},
{"th", "Thai","th",{"TH"}},
{"tr", "Turkish","tr",{"TR"}},
{"uk", "Ukrainian","ua",{"UA"}},
{"ur", "Urdu","pk",{}},
{"uz", "Uzbek","uz",{"UZ"}},
{"vi", "Vietnamese","vn",{"VN"}},
{"cy", "Welsh","gb",{}},
{"xh", "Xhosa","za",{}},
{"yi", "Yiddish","ru",{}},
{"yo", "Yoruba","ng",{}},
{"zu", "Zulu","za",{}}
}

local translateGUI = {
    tab = {},
    tabpanel = {},
    edit = {},
    button = {},
    window = {},
    label = {},
    gridlist = {},
	combobox = {},
	image = {},
	memo = {},
	scrollbar = {},
	scrollpane = {}
}

local langGUI = {
    tab = {},
    tabpanel = {},
    edit = {},
    button = {},
    window = {},
    label = {},
    gridlist = {},
	combobox = {},
	image = {},
	memo = {},
	scrollbar = {},
	scrollpane = {},
	flag = {}
}

local chatboxGUI = {
	chatID = {},
	name = {},
	labelF = {},
	labelT = {},
	whiteF = {},
	whiteT = {},
	flagF = {},
	flagT = {}
}

local excluded = {34, 35, 38, 60, 62, 92} -- " # & < > \
local keys = {}
local keyValues = {48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122}
local forbiddenKeys = {}
local from = "nl"
local to = "en"
local fromNo = 1
local toNo = 1
local chatbox = {} -- {chatID, player name tag, country code, message, from, to, translation, from flag, to flag}
local chatboxMax = 50
local chatID = 0
local enabled = true
local selectedID = 0
local selectedFlag

function translateBuildGUI()
	local screenW, screenH = guiGetScreenSize()
	
	translateGUI.window[1] = guiCreateWindow((screenW - 768) / 2, (screenH - 512) / 2, 768, 512, "MTA Translate", false)
	guiWindowSetSizable(translateGUI.window[1], false)
	
	translateGUI.button[1] = guiCreateButton(320, 480, 128, 24, "Close", false, translateGUI.window[1])
	addEventHandler("onClientGUIClick",translateGUI.button[1],translateButton,false)
	
	translateGUI.tabpanel[1] = guiCreateTabPanel(8, 24, 752, 448, false, translateGUI.window[1])
	
	translateGUI.tab[1] = guiCreateTab("Translator", translateGUI.tabpanel[1])
	
	translateGUI.button[2] = guiCreateButton(312, 24, 128, 24, "Translate", false, translateGUI.tab[1])
	addEventHandler("onClientGUIClick",translateGUI.button[2],translateButton,false)
	
	translateGUI.button[3] = guiCreateButton(312, 56, 128, 24, "Swap languages", false, translateGUI.tab[1])
	addEventHandler("onClientGUIClick",translateGUI.button[3],translateButton,false)
	
	translateGUI.combobox[1] = guiCreateComboBox(92, 40, 128, 384, "from", false, translateGUI.tab[1])
	for i,v in ipairs(languages) do
		guiComboBoxAddItem(translateGUI.combobox[1], v[2])
		if v[1] == from then
			fromNo = i - 1
		end
	end
	guiComboBoxSetSelected(translateGUI.combobox[1], fromNo)
	
	translateGUI.combobox[2] = guiCreateComboBox(532, 40, 128, 384, "to", false, translateGUI.tab[1])
	for i,v in ipairs(languages) do
		guiComboBoxAddItem(translateGUI.combobox[2], v[2])
		if v[1] == to then
			toNo = i - 1
		end
	end
	guiComboBoxSetSelected(translateGUI.combobox[2], toNo)
	
	translateGUI.memo[1] = guiCreateMemo(24, 104, 340, 192, "", false, translateGUI.tab[1])
	translateGUI.memo[2] = guiCreateMemo(388, 104, 340, 192, "", false, translateGUI.tab[1])
	translateGUI.memo[3] = guiCreateMemo(24, 320, 704, 80, "", false, translateGUI.tab[1])
	
	translateGUI.tab[2] = guiCreateTab("Chatbox", translateGUI.tabpanel[1])
	
	translateGUI.image[2] = guiCreateStaticImage(0, 0, 752, 445, "img/blackPixel.png", false, translateGUI.tab[2])
	guiSetAlpha(translateGUI.image[2],0)
	
	translateGUI.scrollpane[1] = guiCreateScrollPane(8, 8, 736, 408, false, translateGUI.tab[2])
	
	guiSetVisible(translateGUI.window[1],false)
	
	
	
	langGUI.window[1] = guiCreateWindow((screenW - 128) / 2, (screenH - 384) / 2, 192, 384, "Languages", false)
	guiWindowSetSizable(langGUI.window[1], false)
	
	langGUI.button[1] = guiCreateButton(48, 352, 96, 24, "Close", false, langGUI.window[1])
	addEventHandler("onClientGUIClick",langGUI.button[1],translateButton,false)
	
	langGUI.scrollpane[1] = guiCreateScrollPane(8, 24, 176, 320, false, langGUI.window[1])
	
	langGUI.image[1] = guiCreateStaticImage(8, 0, 148, 16, "img/whitePixel.png", false, langGUI.scrollpane[1])
	langGUI.flag[1] = guiCreateStaticImage(12, 3, 16, 11, "img/nl.png", false, langGUI.scrollpane[1])
	langGUI.label[1] = guiCreateLabel(32, 0, 112, 16, "Dutch", false, langGUI.scrollpane[1])
	guiSetAlpha(langGUI.image[1], 0)
	
	langGUI.image[2] = guiCreateStaticImage(8, 16, 148, 16, "img/whitePixel.png", false, langGUI.scrollpane[1])
	langGUI.flag[2] = guiCreateStaticImage(12, 19, 16, 11, "img/fam.png", false, langGUI.scrollpane[1])
	langGUI.label[2] = guiCreateLabel(32, 16, 112, 16, "Detect language", false, langGUI.scrollpane[1])
	guiSetAlpha(langGUI.image[2], 0)
	
	langGUI.image[3] = guiCreateStaticImage(8, 32, 148, 16, "img/whitePixel.png", false, langGUI.scrollpane[1])
	langGUI.flag[3] = guiCreateStaticImage(12, 35, 16, 11, "img/fam.png", false, langGUI.scrollpane[1])
	langGUI.label[3] = guiCreateLabel(32, 32, 112, 16, "------------------------------", false, langGUI.scrollpane[1])
	guiSetAlpha(langGUI.image[3], 0)
	
	local j = 3
	for i,v in ipairs(languages) do
		if not (i == 1) then
			j = j + 1
			langGUI.image[j] = guiCreateStaticImage(8, (j*16)-16, 148, 16, "img/whitePixel.png", false, langGUI.scrollpane[1])
			langGUI.flag[j] = guiCreateStaticImage(12, (j*16)-16+3, 16, 11, "img/" .. languages[i][3] .. ".png", false, langGUI.scrollpane[1])
			langGUI.label[j] = guiCreateLabel(32, (j*16)-16, 112, 16, languages[i][2], false, langGUI.scrollpane[1])
			guiSetAlpha(langGUI.image[j], 0)
		end
	end
	
	guiSetVisible(langGUI.window[1],false)
end
addEventHandler("onClientResourceStart",resourceRoot,translateBuildGUI)

addEvent("translateOpenCloseGUI",true)
function translateButton(button, state)
	if button and state then
		if state == "up" and button == "left" then
			if source == translateGUI.button[1] then
				if guiGetVisible(langGUI.window[1]) then guiSetVisible(langGUI.window[1], false) end
				guiSetVisible(translateGUI.window[1],false)
				showCursor(false)
				guiSetInputMode("allow_binds")
				clearChatbox()
			end
			if source == translateGUI.button[2] then
				local text = guiGetText(translateGUI.memo[1])
				local from = guiComboBoxGetItemText(translateGUI.combobox[1], guiComboBoxGetSelected(translateGUI.combobox[1]))
				local to = guiComboBoxGetItemText(translateGUI.combobox[2], guiComboBoxGetSelected(translateGUI.combobox[2]))
				for i,v in ipairs(languages) do
					if v[2] == from then
						from = v[1]
					end
					if v[2] == to then
						to = v[1]
					end
				end
				translateRequest(text, from, to, "main")
			end
			if source == translateGUI.button[3] then
				translateSwap()
			end
			if source == langGUI.button[1] then
				guiSetVisible(langGUI.window[1],false)
			end
		end
	else
		if guiGetVisible(translateGUI.window[1]) then
			if guiGetVisible(langGUI.window[1]) then guiSetVisible(langGUI.window[1], false) end
			guiSetVisible(translateGUI.window[1],false)
			showCursor(false)
			guiSetInputMode("allow_binds")
			clearChatbox()
		else
			guiSetVisible(translateGUI.window[1],true)
			guiBringToFront(translateGUI.window[1])
			showCursor(true)
			guiSetInputMode("no_binds_when_editing")
			clearChatbox()
			chatMessage(chatID)
		end
	end
end
addEventHandler("translateOpenCloseGUI",root,translateButton)

function translateRequest(text, from, to, target)
	if enabled == false then return end
	translationsDelay(false)
	text = removeLines(text)
	original = text
	text = cleanText(text)
	triggerServerEvent("translateGetTranslation", resourceRoot, localPlayer, text, from, to, original, target)
end

function translateSwap()
	local input = guiGetText(translateGUI.memo[1])
	local output = guiGetText(translateGUI.memo[2])
	local from = guiComboBoxGetItemText(translateGUI.combobox[1], guiComboBoxGetSelected(translateGUI.combobox[1]))
	local to = guiComboBoxGetItemText(translateGUI.combobox[2], guiComboBoxGetSelected(translateGUI.combobox[2]))
	local fromNo = 1
	local toNo = 1
	for i,v in ipairs(languages) do
		if v[2] == from then
			fromNo = i - 1
		end
		if v[2] == to then
			toNo = i - 1
		end
	end
	guiComboBoxSetSelected(translateGUI.combobox[1], toNo)
	guiComboBoxSetSelected(translateGUI.combobox[2], fromNo)
	guiSetText(translateGUI.memo[1], output)
	guiSetText(translateGUI.memo[2], input)
end

addEvent("translateSendTranslation",true)
function translateSendTranslation(translation, original, target, from)
	translationsDelay(true)
	if target == "main" then guiSetText(translateGUI.memo[3], translation) end
	translation = getTranslations(translation,from)
	translation = decodeTranslation(translation, original)
	if translation then
		if target == "main" then guiSetText(translateGUI.memo[2], translation)
		else
			for i,v in ipairs(chatbox) do
				if target == v[1] then
					chatbox[i][7] = translation
					cleanChats(chatbox[i][1])
					buildChats(chatbox[i][1])
					break
				end
			end
		end
	else outputDebugString("mtatranslate: translation error") end
end
addEventHandler("translateSendTranslation",root,translateSendTranslation)

function removeLines(text)
	local length = utf8.len(text)
	local tByte = {}
	local i = 0
	while i < length do
		i = i + 1
		table.insert(tByte, utf8.byte(utf8.sub(text, i, i),1))
	end
	
	text = ""
	for i,v in ipairs(tByte) do
		if i ~= length then
			if v == 10 then v = 32 end
		end
		text = text .. utf8.char(v)
	end
	
	return text
end

function cleanText(text)
	local length = utf8.len(text)
	local tByte = {}
	local i = 0
	while i < length do
		i = i + 1
		table.insert(tByte, utf8.byte(utf8.sub(text, i, i),1))
	end
	
	local str = ""
	local c = ""
	local k = ""
	for i,v in ipairs(tByte) do
		for j,w in ipairs(excluded) do
			if v == w then
				k = createKey(w, text)
			else
				c = utf8.char(v)
			end
		end
		if k ~= "" then str = str .. " " .. k .. " "
		elseif c ~= "" then str = str .. c end
		k = ""
		c = ""
	end
	text = str

	return text
end

function getTranslations(text,from)
	local start = 1
	local tQuot = {}
	local i = 0
	repeat
		i = i + 1
		a,b = utf8.find(text,utf8.char(34), start)
		if a == nil then break end
		c,d = utf8.find(text,utf8.char(34), a + 1)
		if c == nil then break end
		table.insert(tQuot, {a,c,i})
		start = c + 1
	until a == nil or c == nil
	
	local maxNo = 0
	local i = 0
	repeat
		i = i + 1
		if tQuot[i][3] > maxNo then maxNo = tQuot[i][3] end
		local number = tQuot[i][3] / 2
		if number == math.ceil(number) and number == math.floor(number) then
			table.remove(tQuot, i)
			i = i - 1
		end
	until tQuot[i+1] == nil
	
	local str = ""
	for i,v in ipairs(tQuot) do
		if v[3] == maxNo then 
			table.remove(tQuot, i)
		elseif from == "auto" and v[3] == (maxNo - 2) then
			table.remove(tQuot, i)
		else
			if v[1] < v[2] then
				str = str .. utf8.sub(text, v[1] + 1, v[2] - 1)
			end
		end
	end
	text = str
	
	return text
end

function createKey(symbol, text)
	for i,v in ipairs(keys) do
		if v[1] == symbol then
			key = v[2]
			return key
		end
	end
	
	local ran = 0
	local all = 0
	local key = ""
	repeat
		repeat
			ran = math.random(1,#keyValues)
			key = key .. utf8.char(keyValues[ran])
		until utf8.len(key) == 6
		a,b = utf8.find(text, key)
	until a == nil
	table.insert(keys, {symbol, key})
	return key
end

function decodeTranslation(text, original)
	for i,v in ipairs(keys) do
		local replaces = 0
		repeat
			a,b = utf8.find(text,v[2])
			if a == nil then break end
			replaces = replaces + 1
			if a == 1 then
				text = utf8.char(v[1]) .. utf8.sub(text, b + 1)
			else
				text = utf8.sub(text, 1, a - 1) .. utf8.char(v[1]) .. utf8.sub(text, b + 1)
			end
		until a == nil
		if replaces == 0 then
			table.insert(forbiddenKeys,v[2])
			return false
		end
	end
	
	local tByte = {}
	local oByte = {}
	for i,v in ipairs(keys) do
		local length = utf8.len(text)
		local j = 0
		local count = 0
		while j < length do
			j = j + 1
			if utf8.byte(utf8.sub(text, j, j),1) == v[1] then
				count = count + 1
				table.insert(tByte,{v[1],count})
			end
		end
	end
	for i,v in ipairs(keys) do
		local length = utf8.len(original)
		local j = 0
		local count = 0
		while j < length do
			j = j + 1
			if utf8.byte(utf8.sub(original, j, j),1) == v[1] then
				count = count + 1
				table.insert(oByte,{v[1],count,j})
			end
		end
	end
	
	for i,v in ipairs(keys) do
		local length = utf8.len(text)
		local j = 0
		local count = 0
		while j < length do
			j = j + 1
			if utf8.byte(utf8.sub(text, j, j),1) == v[1] then
				count = count + 1
				for l,y in ipairs(oByte) do
					if y[1] == v[1] and y[2] == count then
						if utf8.byte(utf8.sub(original,y[3]-1,y[3]-1)) ~= 32 and utf8.byte(utf8.sub(original,y[3]-1,y[3]-1)) ~= nil then
							if utf8.byte(utf8.sub(text,j-1,j-1)) == 32 then
								if (j-1) == 1 then text = utf8.sub(text,j)
								else text = utf8.sub(text,1,j-2) .. utf8.sub(text,j) end
								j = j - 1
							end
						end
						if utf8.byte(utf8.sub(original,y[3]+1,y[3]+1)) ~= 32 and utf8.byte(utf8.sub(original,y[3]+1,y[3]+1)) ~= nil then
							if utf8.byte(utf8.sub(text,j+1,j+1)) == 32 then
								if (j+2) > length then text = utf8.sub(text,1,j)
								else text = utf8.sub(text,1,j) .. utf8.sub(text,j+2) end
							end
						end
						table.remove(oByte,l)
						j = 0
						length = utf8.len(text)
					end
				end
			end
		end
	end
	
	keys = {}
	
	return text
end

function chatMessage(id)
	if not id then id = 0 end
	if guiGetVisible(translateGUI.window[1]) then
		for i,v in ipairs(chatbox) do if v[1] > id then id = v[1] end end
		chatID = id
		triggerServerEvent("translateFetchChatbox", resourceRoot, localPlayer, id)
	end
end

function clientChat()
	chatMessage(chatID)
end
addEventHandler("onClientChatMessage", getRootElement(), clientChat)

function clearChatbox()
	if #chatbox > chatboxMax then
		repeat
		table.remove(chatbox, 1)
		until #chatbox == chatboxMax
	end
	cleanChats(0)
	buildChats(0)
end

addEvent("translateSendChatbox",true)
function translateSendChatbox(t,id)
	for i,v in ipairs(t) do
		if t[i][5] == "" then
			for j,w in ipairs(languages) do
				for k,x in ipairs(w[4]) do
					if x == t[i][3] then
						t[i][5] = w[1]
						t[i][8] = w[3]
					end
				end
			end
		end
		if t[i][6] == "" then
			t[i][6] = "en"
			t[i][9] = "gb"
		end
		t[i][4] = utf8.gsub(t[i][4], "#%x%x%x%x%x%x", "")
		table.insert(chatbox,v)
	end
	
	cleanChats(id)
	buildChats(id)
end
addEventHandler("translateSendChatbox",root,translateSendChatbox)

function cleanChats(id)
	local j = 0
	for i,v in ipairs(chatboxGUI.chatID) do
		if chatboxGUI.chatID[i] > j then j = chatboxGUI.chatID[i] end
		if chatboxGUI.chatID[i] >= id then
			destroyElement(chatboxGUI.name[i])
			destroyElement(chatboxGUI.labelF[i])
			destroyElement(chatboxGUI.labelT[i])
			destroyElement(chatboxGUI.whiteF[i])
			destroyElement(chatboxGUI.whiteT[i])
			destroyElement(chatboxGUI.flagF[i])
			destroyElement(chatboxGUI.flagT[i])
		end
	end
	
	while j >= id do
	chatboxGUI.name[j] = nil
	chatboxGUI.labelF[j] = nil
	chatboxGUI.labelT[j] = nil
	chatboxGUI.whiteF[j] = nil
	chatboxGUI.whiteT[j] = nil
	chatboxGUI.flagF[j] = nil
	chatboxGUI.flagT[j] = nil
	chatboxGUI.chatID[j] = nil
	j = j - 1
	end
end

function buildChats(id) -- 28 karakters per line
	for i,v in ipairs(chatbox) do
		if chatbox[i][1] >= id then
			local original,lineO = rewriteText(chatbox[i][4])
			local translation,lineT = rewriteText(chatbox[i][7])
			local from = chatbox[i][5]
			local to = chatbox[i][6]
			local fromFlag = chatbox[i][8]
			local toFlag = chatbox[i][9]
			local name = chatbox[i][2]
			
			if from == "" then
				from = "auto"
				chatbox[i][5] = "auto"
			end
			if to == "" then
				to = "en"
				chatbox[i][6] = "en"
			end
			if fromFlag == "" then
				fromFlag = "fam"
				chatbox[i][8] = "fam"
			end
			if toFlag == "" then
				toFlag = "gb"
				chatbox[i][9] = "gb"
			end
			
			local line = 1
			if lineO > lineT then line = lineO else line = lineT end
			local x,y = 24,16
			local w,h = 200,16*line
			if chatboxGUI.labelF[i-1] then
				x,y = guiGetPosition(chatboxGUI.labelF[i-1],false)
				w,h = guiGetSize(chatboxGUI.labelF[i-1],false)
			end
			
			chatboxGUI.chatID[i] = chatbox[i][1]
			chatboxGUI.whiteF[i] = guiCreateStaticImage(20, 0+y+h, 388, 16*line, "img/whitePixel.png", false, translateGUI.scrollpane[1])
			chatboxGUI.whiteT[i] = guiCreateStaticImage(472, 0+y+h, 256, 16*line, "img/whitePixel.png", false, translateGUI.scrollpane[1]) -- 712
			chatboxGUI.name[i] = guiCreateLabel(24, 0+y+h, 128, 16*line, name, false, translateGUI.scrollpane[1])
			chatboxGUI.labelF[i] = guiCreateLabel(156, 0+y+h, 248, 16*line, original, false, translateGUI.scrollpane[1])
			chatboxGUI.labelT[i] = guiCreateLabel(476, 0+y+h, 248, 16*line, translation, false, translateGUI.scrollpane[1])
			chatboxGUI.flagF[i] = guiCreateStaticImage(416, (0+y+h+((16*line)/2)-5), 16, 11, "img/" .. fromFlag .. ".png", false, translateGUI.scrollpane[1])
			chatboxGUI.flagT[i] = guiCreateStaticImage(448, (0+y+h+((16*line)/2)-5), 16, 11, "img/" .. toFlag .. ".png", false, translateGUI.scrollpane[1])
			guiLabelSetVerticalAlign(chatboxGUI.name[i], "center")
			guiSetAlpha(chatboxGUI.whiteF[i], 0)
			guiSetAlpha(chatboxGUI.whiteT[i], 0)
		end
	end
end

function rewriteText(text)
	local text = removeLines(text)
	local separator = {32}
	local loc = {}
	
	local i = 0
	local length = utf8.len(text)
	while i < length do
		i = i + 1
		local str = utf8.sub(text,i,i)
		for j,w in ipairs(separator) do
			if utf8.byte(str) == w then
				table.insert(loc,{utf8.byte(str),i})
			end
		end
	end
	
	local raw = ""
	local str = ""
	local pos = 1
	local a = 0
	local leng = 28 - 1
	local line = 0
	
	repeat
		line = line + 1
		str = utf8.sub(text,pos)
		a = 0
		if utf8.len(str) < leng then
			leng = utf8.len(str)
			a = leng
		else
			for i,v in ipairs(loc) do
				if v[2] >= pos and v[2] <= (pos + leng) then
					if v[2] > a then a = v[2] - pos end
				end
			end
		end
		if a == 0 then a = utf8.len(text) - pos end
		if a > leng then a = leng end
		if a == utf8.len(str) then raw = raw .. utf8.sub(text,pos,pos+a)
		else raw = raw .. utf8.sub(text,pos,pos+a) .. utf8.char(10) end
		pos = pos + a + 1
	until pos > utf8.len(text)
	
	return raw,line
end

function mouseEnter(x,y,leftGUI)
	for i,v in ipairs(chatboxGUI.chatID) do
		if source == chatboxGUI.labelF[i] or source == chatboxGUI.labelT[i] or source == chatboxGUI.name[i] then
			guiSetAlpha(chatboxGUI.whiteF[i],0.1)
			guiSetAlpha(chatboxGUI.whiteT[i],0.1)
			break
		end
	end
	for i,v in ipairs(langGUI.label) do
		if source == langGUI.label[i] or source == langGUI.image[i] or source == langGUI.flag[i] then
			guiSetAlpha(langGUI.image[i],0.1)
			break
		end
	end
end
addEventHandler( "onClientMouseEnter", getRootElement(), mouseEnter)

function mouseLeave(x,y,enteredGUI)
	for i,v in ipairs(chatboxGUI.chatID) do
		if source == chatboxGUI.labelF[i] or source == chatboxGUI.labelT[i] or source == chatboxGUI.name[i] then
			guiSetAlpha(chatboxGUI.whiteF[i],0)
			guiSetAlpha(chatboxGUI.whiteT[i],0)
			break
		end
	end
	for i,v in ipairs(langGUI.label) do
		if source == langGUI.label[i] or source == langGUI.image[i] or source == langGUI.flag[i] then
			guiSetAlpha(langGUI.image[i],0)
			break
		end
	end
end
addEventHandler( "onClientMouseLeave", getRootElement(), mouseLeave)

function mouseDoubleClick(button, state)
	if button == "left" and state == "up" then
		for i,v in ipairs(chatboxGUI.chatID) do
			if source == chatboxGUI.labelF[i] or source == chatboxGUI.labelT[i] or source == chatboxGUI.name[i] then
				for j,w in ipairs(chatbox) do
					if w[1] == chatboxGUI.chatID[i] then
						translateRequest(chatbox[j][4], chatbox[j][5], chatbox[j][6], chatbox[j][1])
						break
					end
				end
			elseif source == chatboxGUI.flagF[i] or source == chatboxGUI.flagT[i] then
				
				-- get Chatbox table info
				for j,w in ipairs(chatbox) do
					if w[1] == chatboxGUI.chatID[i] then -- if chatbox chatID == chatboxGUI.chatID
						if w[3] == nil or w[3] == "" then w[3] = "FAM" end
						
						-- get languages table info
						for k,x in ipairs(languages) do
						
							-- get country codes of languages table info
							for l,y in ipairs(x[4]) do
								if y == w[3] then -- if languages country code == country code of player
									guiStaticImageLoadImage(langGUI.flag[1], "img/" .. x[3] .. ".png")
									guiSetText(langGUI.label[1], x[2])
									guiSetVisible(langGUI.window[1],true)
									guiBringToFront(langGUI.window[1])
									selectedID = chatboxGUI.chatID[i]
									selectedFlag = source
									break
								end
							end
							
						end
						
					end
				end
				
			end
		end
		for i,v in ipairs(langGUI.label) do
			if source == langGUI.label[i] or source == langGUI.image[i] or source == langGUI.flag[i] then
				local text = guiGetText(langGUI.label[i])
				langSelect(text)
			end
		end
	end
end
addEventHandler( "onClientGUIDoubleClick", getRootElement(), mouseDoubleClick)

function translationsDelay(bool)
	enabled = bool
	guiSetEnabled(translateGUI.button[2],bool)
	
	for i,v in ipairs(chatboxGUI.chatID) do
		guiSetEnabled(chatboxGUI.labelF[i],bool)
		guiSetEnabled(chatboxGUI.labelT[i],bool)
		guiSetEnabled(chatboxGUI.name[i], bool)
	end
	if bool then
		addEventHandler( "onClientMouseEnter", getRootElement(), mouseEnter)
		guiSetAlpha(translateGUI.image[2],0)
	else
		removeEventHandler("onClientMouseEnter", getRootElement(), mouseEnter)
		guiSetAlpha(translateGUI.image[2],0.5)
	end
end

function langSelect(lang)
	if lang == nil then return end
	local flag = false
	local fromto = false
	for i,v in ipairs(languages) do
		if v[2] == lang then
			flag = v[3]
			fromto = v[1]
			break
		end
	end
	
	local from = false
	local to = false
	for i,v in ipairs(chatboxGUI.chatID) do
		if selectedFlag == chatboxGUI.flagF[i] then
			from = true
			break
		elseif selectedFlag == chatboxGUI.flagT[i] then
			to = true
			break
		end
	end
	
	for i,v in ipairs(chatbox) do
		if v[1] == selectedID then
			if from then
				if flag and fromto then
					v[8] = flag
					v[5] = fromto
					guiStaticImageLoadImage(selectedFlag, "img/" .. flag .. ".png")
				end
			elseif to then
				if flag then
					v[9] = flag
					v[6] = fromto
					guiStaticImageLoadImage(selectedFlag, "img/" .. flag .. ".png")
				end
			end
		end
	end
	
	guiSetVisible(langGUI.window[1],false)
end

-- Export function for translations