local screenWidth, screenHeight = guiGetScreenSize()

hornsTable = {
	[1] = "Birdo-geluidje",
	[2] = "Boo-gebulder",
	[3] = "Come on! - Wario",
	[4] = "Dry Bones-gegiechel",
	[5] = "Hatsjwao! Oh sorry.. - Luigi",
	[6] = "Hey Stinky! - Mario",
	[7] = "Mushroom! - Toadette",
	[8] = "Peach-annoy",
	[9] = "Toad-boeee",
	[10] = "Yoshi-cool geluid",
	[11] = "You know I'll win! - Daisy",
	[12] = "You're lousy! - Waluigi",
	[13] = "The Dukes of hazzard",
	[14] = "Adios",
	[15] = "Aww crap",
	[16] = "Bad Boys",
	[17] = "Beat it!",
	[18] = "Billnye",
	[19] = "Callonme",
	[20] = "Come out",
	[21] = "Do'h",
	[22] = "English",
	[23] = "Feel good",
	[24] = "Haha",
	[25] = "Hello",
	[26] = "Madness",
	[27] = "Muh",
	[28] = "Muhaha",
	[29] = "Noobs",
	[30] = "Omg",
	[31] = "Sparta",
	[32] = "Suck",
	[33] = "Suckers",
	[34] = "Wazza",
	[35] = "Woohoo",
	[36] = "Yaba",
	[37] = "stewie",
	[38] = "titten",
	[39] = "buggle call",
	[40] = "random",
	[41] = "ring",
	[42] = "mario win",
	[43] = "goodbadugly",
	[44] = "who cares",
	[45] = "loser",
	[46] = "noooo",
	[47] = "cartman",
	[48] = "such a noob",
	[49] = "Screw you, that's funny",
	[50] = "hello again",
	[51] = "haaaaaai",
	[52] = "knock knock",
	[53] = "giggity",
	[54] = "shade aran",
	[55] = "YES,YES.",
	[56] = "Burn baby burn.",
	[57] = "Cry some moar!",
	[58] = "Davaj do svidanija",
	[59] = "WHAT YOU GONNA DO",
	[60] = "Dr.Zaius",
	[61] = "Here we go",
	[62] = "Holy Shit",
	[63] = "It's my life",
	[64] = "JAAZZZZ",
	[65] = "Let's get ready to rumble",
	[66] = "What did you say nigga!?",
	[67] = "Not a big surprise",
	[68] = "Livin' on a prayer",
	[69] = "Low Rider",
	[70] = "MammaMia",
	[71] = "Mariodeath",
	[72] = "My horse is amazing",
	[73] = "U can't touch this",
	[74] = "We are the champions",
	[75] = "We will rock you",
	[76] = "Bye have a great time",
	[77] = "Damn son! Where'd you find this",
	[78] = "Denied!",
	[79] = "Derp!1!",
	[80] = "Fart SFX",
	[81] = "Fatality",
	[82] = "Finish him!",
	[83] = "Giggity",
	[84] = "Gotya bitch",
	[85] = "Headshot!",
	[86] = "Hehe! Alright",
	[87] = "Here We Go!",
	[88] = "Like A Baus",
	[89] = "Prepare to be astonished",
	[90] = "Smoke Weed Everyday",
	[91] = "Tah daah",
	[92] = "That's nasty",
	[93] = "Toasty!",
	[94] = "Whaaat",
	[95] = "You got knocked the fuck out",
	[96] = "You suck sound effect",
	[97] = "Haha You Suck",
	[98] = "Imma bust you up",
	[99] = "It's on, Baby",
	[100] = "Mess with the best",
	[101] = "That's gotta hurt",
	[102] = "Yo Whassup",
	[103] = "F--k you ceelo",
	[104] = "Stewie Mummy",
	[105] = "Hah, Ghaay",
	[106] = "J's on my feet",
	[107] = "Jim Carrey",
	[108] = "Minion laugh",
	[109] = "My nigga my nigga",
	[110] = "Darude - Sandstorm",
	[111] = "So it begins",
	[112] = "What are you doing",
	[113] = "Whoooaah",
	[114] = "Wiggle wiggle wiggle",
	[115] = "You shall not pass!",
	[116] = "Higher",
	[117] = "I need a dollar",
	[118] = "M-O Wall-E",
	[119] = "Wall-E",
	[120] = "Help!..nope",
	[121] = "I dare you",
	[122] = "Iragenerghvjksah",
	[123] = "KAR Spring Breeze",
	[124] = "Let's do this again",
	[125] = "Oh you",
	[126] = "Brush heavy's hair!",
	[127] = "OKTOBERFEST MAGGOT",
	[128] = "Full of SANDWITCHES!",
	[129] = "Scary",
	[130] = "Ugly, AAAH",
	[131] = "You're not a real soldier!",
	[132] = "1,2,3 Let's GO!",
	[133] = "Airporn",
	[134] = "Black & Yellow",
	[135] = "Don't look down",
	[136] = "Dreamscape",
	[137] = "GET NOSOCOPED!",
	[138] = "Oh baby a triple",
	[139] = "Put your hands up!!!",
	[140] = "Really, nigga?",
	[141] = "Schnappi",
	[142] = "Smoke Weed Everyday remix",
	[143] = "Spacemen",
	[144] = "They call it Merther!",
	[145] = "Sad violin air horn",
	[146] = "Fucking bi#@h!",
	[147] = "Nice and strong Cena",
	[148] = "Dikke BMW",
	[149] = "Burp!",
	[150] = "Meep-meep!",
	[151] = "Angels are crying",
	[152] = "Bocka bass",
	[153] = "I can't get no sleep",
	[154] = "Ja pierdole kurwa",
	[155] = "Komodo",
	[156] = "Let go",
	[157] = "Pop Hold it Down",
	[158] = "Sacrifice",
	[159] = "Single ladies",
	[160] = "Feel Good Drag",
	[161] = "They see me rollin",
	[162] = "OH. MY. GOD.",
	[163] = "F1 Horn",
	[164] = "Evil Laugh",
	[165] = "Antonioooo",		
 	[166] = "Hero",		
 	[167] = "GTALibertyCity",		
 	[168] = "PersonalJesus",		
 	[169] = "Unforgiven",
	[170] = "Kappa",
	[171] = "Adele - Hello",
	[172] = "Magiiiik",
	[173] = "Keep the Change You Filthy Animal",
	[174] = "Crazy santa",
	[175] = "Dumb Florida Moron",
	[176] = "AMG",
	[177] = "Audi",
	[178] = "Chase the sun",
	[179] = "Give Me A Sign",
	[180] = "Heads Will Roll (A Trak remix)",
	[181] = "Holy Ghost",
	[182] = "I Am Jacks Hungry Heart Vocal 2",
	[183] = "I Am Jacks Hungry Heart Vocal",
	[184] = "I Am Jacks Hungry Heart",
	[185] = "I Believe In Dreams",
	[186] = "I Can't Stop",
	[187] = "Insomnia",
	[188] = "Komodoo",
	[189] = "Love Sex American Express",
	[190] = "Nighttrain",
	[191] = "Step it up",
	[192] = "Tobi King",
	[193] = "Tsunami",
	[194] = "DubStep!!",
	[195] = "Disturbed - Fear",
	[196] = "Knife Party - Nya",
	[197] = "Feel Dog Inc",
	[198] = "Reality - Melody",
	[199] = "Reality - Original",
	[200] = "Bellini - Samba De Janeiro",
	[201] = "Do You See Me Now?",
}

extensions = {
	[16] = "ogg",
	[13] = "mp3",
	[17] = "mp3",
	[18] = "mp3",
	[19] = "mp3",
	[26] = "mp3",
	[29] = "mp3",
	[30] = "mp3",
	[13] = "mp3",
	[31] = "mp3",
	[33] = "mp3",
	[36] = "mp3",
	[37] = "mp3",
	[39] = "mp3",
	[13] = "mp3",
	[42] = "mp3",
	[40] = "mp3",
	[43] = "mp3",
	[44] = "mp3",
	[45] = "mp3",
	[46] = "mp3",
	[47] = "mp3",
	[48] = "mp3",
	[51] = "mp3",
	[53] = "mp3",
	[55] = "mp3",
	[56] = "mp3",
	[57] = "mp3",
	[58] = "mp3",
	[59] = "mp3",
	[60] = "mp3",
	[61] = "mp3",
	[62] = "mp3",
	[63] = "mp3",
	[64] = "mp3",
	[65] = "mp3",
	[66] = "mp3",
	[67] = "mp3",
	[68] = "mp3",
	[69] = "mp3",
	[70] = "mp3",
	[71] = "mp3",
	[72] = "mp3",
	[73] = "mp3",
	[74] = "mp3",
	[75] = "mp3",
	[75] = "mp3",
	[76] = "mp3",
	[77] = "mp3",
	[78] = "mp3",
	[79] = "mp3",
	[80] = "mp3",
	[81] = "mp3",
	[82] = "mp3",
	[83] = "mp3",
	[84] = "mp3",
	[85] = "mp3",
	[86] = "mp3",
	[87] = "mp3",
	[88] = "mp3",
	[89] = "mp3",
	[90] = "mp3",
	[91] = "mp3",
	[92] = "mp3",
	[93] = "mp3",
	[94] = "mp3",
	[95] = "mp3",
	[96] = "mp3",
	[97] = "mp3",
	[98] = "mp3",
	[99] = "mp3",
	[100] = "mp3",
	[101] = "mp3",
	[102] = "mp3",
	[103] = "mp3",
	[104] = "mp3",
	[105] = "mp3",
	[106] = "mp3",
	[107] = "mp3",
	[108] = "mp3",
	[109] = "mp3",
	[110] = "mp3",
	[111] = "mp3",
	[112] = "mp3",
	[113] = "mp3",
	[114] = "mp3",
	[115] = "mp3",
	[116] = "mp3",
	[117] = "mp3",
	[118] = "mp3",
	[119] = "mp3",
	[120] = "mp3",
	[121] = "mp3",
	[122] = "mp3",
	[123] = "mp3",
	[124] = "mp3",
	[125] = "mp3",
	[126] = "mp3",
	[127] = "mp3",
	[128] = "mp3",
	[129] = "mp3",
	[130] = "mp3",
	[131] = "mp3",
	[132] = "mp3",
	[133] = "mp3",
	[134] = "mp3",
	[135] = "mp3",
	[136] = "mp3",
	[137] = "mp3",
	[138] = "mp3",
	[139] = "mp3",
	[140] = "mp3",
	[141] = "mp3",
	[142] = "mp3",
	[143] = "mp3",
	[144] = "mp3",
	[145] = "mp3",
	[146] = "mp3",
	[147] = "mp3",
	[148] = "mp3",
	[149] = "mp3",
	[150] = "mp3",
	[151] = "mp3",
	[152] = "mp3",
	[153] = "mp3",
	[154] = "mp3",
	[155] = "mp3",
	[156] = "mp3",
	[157] = "mp3",
	[158] = "mp3",
	[159] = "mp3",
	[160] = "mp3",
	[161] = "mp3",
	[162] = "mp3",
	[163] = "mp3",
	[164] = "mp3",
	[165] = "mp3",		
 	[166] = "mp3",		
 	[167] = "mp3",		
 	[168] = "mp3",		
 	[169] = "mp3",
	[170] = "mp3",
	[171] = "mp3",
	[172] = "mp3",
	[173] = "mp3",
	[174] = "mp3",
	[175] = "mp3",
	[176] = "mp3",
	[177] = "mp3",
	[178] = "mp3",
	[179] = "mp3",
	[180] = "mp3",
	[181] = "mp3",
	[182] = "mp3",
	[183] = "mp3",
	[184] = "mp3",
	[185] = "mp3",
	[186] = "mp3",
	[187] = "mp3",
	[188] = "mp3",
	[189] = "mp3",
	[190] = "mp3",
	[191] = "mp3",
	[192] = "mp3",
	[193] = "mp3",
	[194] = "mp3",
	[195] = "mp3",
	[196] = "mp3",
	[197] = "mp3",
	[198] = "mp3",
	[199] = "mp3",
	[200] = "mp3",
	[201] = "mp3",
}

function onShopInit ( tabPanel )
	shopTabPanel = tabPanel
	--triggerServerEvent('getHornsData', localPlayer)
	
	if isElement(hornsTab) then return end
	
	--// Tab Panels //--
	hornsTab = guiCreateTab("Custom Horns", shopTabPanel)
	buyHornsTabPanel = guiCreateTabPanel(35, 30, 641, 381, false, hornsTab)
	buyHornsTab = guiCreateTab("Buy horns", buyHornsTabPanel)
	perkTab = guiCreateTab("Horn Perks", buyHornsTabPanel)
	
	
	--// Gridlists //--
	availableHornsList = guiCreateGridList(0.05, 0.11, 0.42, 0.66, true, buyHornsTab)
	guiGridListSetSortingEnabled(availableHornsList, false)
	local column = guiGridListAddColumn(availableHornsList, "Available horns", 0.9)
	for id, horn in ipairs(hornsTable) do 
		local row = guiGridListAddRow(availableHornsList)
		guiGridListSetItemText(availableHornsList, row, column, tostring(id)..") "..horn, false, false)
	end
	--
	myHornsList = guiCreateGridList(0.53, 0.11, 0.42, 0.66, true, buyHornsTab)
	guiGridListSetSortingEnabled(myHornsList, false)
	myHornsNameColumn = guiGridListAddColumn(myHornsList, "My horns", 0.7)
	myHornsKeyColumn = guiGridListAddColumn(myHornsList, "Key", 0.2)

	
	
	--// Labels //--
	guiCreateLabel(0.05, 0.04, 0.9, 0.15,'Select a horn out of the left box and press "Buy" to buy for regular usage or double-click to listen it.',true,buyHornsTab)
	guiCreateLabel(0.14, 0.78, 0.9, 0.15,'Double-click to listen horn.',true,buyHornsTab)
	guiCreateLabel(0.04, 0.08, 0.9, 0.15,"Horns can only be used 3 times per map (10 secs cool-off). However, you can buy\nunlimited usage of the custom horn for 5000 GC. This item applies to all horns.",true,perkTab)
	guiCreateLabel(0.60, 0.78, 0.9, 0.15,'Double-click to bind horn to a key.',true,buyHornsTab)
	
	
	--// Buttons //--
	local buy = guiCreateButton(0.14, 0.83, 0.22, 0.12, "Buy selected horn\nPrice: 1500 GC (each)", true, buyHornsTab)
	local unbindall = guiCreateButton(0.62, 0.83, 0.22, 0.12, "Unbind all horns", true, buyHornsTab)
	unlimited = guiCreateButton(0.77, 0.05, 0.20, 0.15, "Buy unlimited usage\nPrice: 5000 GC", true, perkTab)	

	
	--// Event Handlers //--
	addEventHandler ( "onClientGUIClick",buy, buyButton,false)
	addEventHandler ( "onClientGUIDoubleClick",myHornsList, preBindKeyForHorn,false)
	addEventHandler ( "onClientGUIDoubleClick",availableHornsList, playButton,false)
	addEventHandler ( "onClientGUIClick",unbindall, unbindAllHorns,false)
	addEventHandler ( "onClientGUIClick",unlimited, unlimitedHorn,false)
end
addEvent('onShopInit', true)
addEventHandler('onShopInit', root, onShopInit )


function playButton(button, state)
	if button == "left" and state == "up" then	
		if isElement(soundTest) then
			stopSound(soundTest) 
		end
		local row, col = guiGridListGetSelectedItem(availableHornsList)
		if row == -1 or row == false then
			return
		end
		row = row + 1
		local extension
		extension = ".wav"
		if extensions[row] then 
			extension = "." .. extensions[row]
		end	
		soundTest = playSound("horns/files/"..tostring(row)..extension, false)
	end
end

function buyButton(button, state)
	if button == "left" and state == "up" then
		local row, col = guiGridListGetSelectedItem(availableHornsList)
		if row == -1 or row == false then
			outputChatBox("Select a horn first", 255, 0, 0)
			return
		end
		row = row + 1
		triggerServerEvent('onPlayerBuyHorn', localPlayer, row)
	end
end


------------------
-- Horn binding --
------------------
function getKeyForHorn(key, state) 
	if state then 
		if key == "escape" then
			unbindKeyForHorn()
			cancelEvent()
		else	
			bindKeyForHorn(key) 
		end	
		removeEventHandler("onClientKey", root, getKeyForHorn)
		destroyElement(bindingWindow)
	end 
end

function preBindKeyForHorn()
	local row, col = guiGridListGetSelectedItem(source)
	if row == -1 or row == false then
		outputChatBox("Select a horn first", 255, 0, 0)
		return
	end
	soundName = guiGridListGetItemData(source, row, col)
	bindingWindow = guiCreateWindow(0.4*screenWidth/1920, 0.45*screenHeight/1080, 0.2*screenWidth/1920, 0.08*screenHeight/1080, "Binding a key to horn", true)
	guiCreateLabel(0.25, 0.5, 1, 1, "Press a key to bind or escape to clear", true, bindingWindow)
	guiWindowSetMovable(bindingWindow, false)
	guiSetAlpha(bindingWindow, 1)
	addEventHandler("onClientKey", root, getKeyForHorn)
end

function bindKeyForHorn(keyNew)
	for i,j in ipairs(hornsTable) do 
		if j == soundName then
			hornBinded = false
			bindsXML = xmlLoadFile ('horns/binds-' .. getElementData(localPlayer, "mrgreen_gc_forumID").. '.xml')
			
			for x=0, 1000 do
				local bindNode = xmlFindChild(bindsXML, "bind", x)
			
				if bindNode then
					local keyOld = xmlNodeGetAttribute(bindNode, "key")
					local hornID = xmlNodeGetAttribute(bindNode, "hornID")
					
					if hornID == tostring(i) then
						xmlNodeSetAttribute(bindNode, "key", keyNew)
						triggerServerEvent("bindHorn", localPlayer, keyNew, i, soundName, false)
						triggerServerEvent("unbindHorn", localPlayer, keyOld)
						xmlSaveFile(bindsXML)
						hornBinded = true
					end
					
				else --elseif no bindNode then create it:
					if not hornBinded then
						local bindNode = xmlCreateChild(bindsXML, "bind")
						xmlNodeSetAttribute(bindNode, "key", keyNew)
						xmlNodeSetAttribute(bindNode, "hornID", i)
						xmlNodeSetAttribute(bindNode, "hornName", soundName)
						triggerServerEvent("bindHorn", localPlayer, keyNew, i, soundName, false)
						xmlSaveFile(bindsXML)
					end
					
					xmlUnloadFile(bindsXML) 
					triggerServerEvent('getHornsData', localPlayer)
					break  
				end
			end 
		end	
	end
end

function unbindKeyForHorn()
	for i,j in ipairs(hornsTable) do 
		if j == soundName then
			bindsXML = xmlLoadFile ('horns/binds-' .. getElementData(localPlayer, "mrgreen_gc_forumID").. '.xml')
			for x=0, 1000 do
				local bindNode = xmlFindChild(bindsXML, "bind", x)
				if bindNode then
					local key = xmlNodeGetAttribute(bindNode, "key")
					local hornID = xmlNodeGetAttribute(bindNode, "hornName")
					if hornID == soundName then
						xmlDestroyNode(bindNode)
						triggerServerEvent("unbindHorn", localPlayer, key)
						xmlSaveFile(bindsXML)
						xmlUnloadFile(bindsXML) 
						triggerServerEvent('getHornsData', localPlayer)
						break  
					end
				end
			end
		end
	end
end

function unbindAllHorns()
triggerServerEvent("unbindAllHorns", resourceRoot)

bindsXML = xmlLoadFile ('horns/binds-' .. getElementData(localPlayer, "mrgreen_gc_forumID").. '.xml')
	for i=0, 1000 do
		if bindsXML then
			local bindNode = xmlFindChild(bindsXML, "bind", i)
			if bindNode then
				local key = xmlNodeGetAttribute(bindNode, "key")
				if key ~= nil then
					triggerServerEvent("unbindHorn", localPlayer, key)
				end
			else 
				bindsXML = xmlCreateFile('horns/binds-' .. getElementData(localPlayer, "mrgreen_gc_forumID").. '.xml', "binds")
				xmlSaveFile(bindsXML)
				xmlUnloadFile(bindsXML)
				triggerServerEvent('getHornsData', localPlayer)
			break  
			end
		end 
	end
end

function unlimitedHorn(button, state)
	if button == "left" and state == "up" then
		triggerServerEvent('onPlayerBuyUnlimitedHorn', localPlayer)
	end
end



addEvent('onClientSuccessBuyHorn', true)
addEventHandler('onClientSuccessBuyHorn', root,
function(success)
	if success then
		outputChatBox("Horn successfully bought")
		triggerServerEvent('getHornsData', localPlayer)
	else
		outputChatBox("Either not logged in, or not enough GC, or you already have this horn.")
	end
end
)

addEvent("hornsLogin", true)
addEventHandler("hornsLogin", root,
function(isUnlimited, forumid)
	setElementData(localPlayer, "mrgreen_gc_forumID", forumid)
	if isUnlimited then
		guiSetText(unlimited, "Buy unlimited usage\nPrice: 5000 GC\nBought!")
		guiSetEnabled(unlimited, false)
	end
	triggerServerEvent('getHornsData', localPlayer)
end
)

addEvent("hornsLogout", true)
addEventHandler("hornsLogout", root,
function()
	triggerServerEvent("unbindAllHorns", resourceRoot)
	
	guiGridListClear(myHornsList)
	guiSetText(unlimited, "Buy unlimited usage\nPrice: 5000 GC")
	guiSetEnabled(unlimited, true)
end
)

addEvent('sendHornsData', true)
addEventHandler('sendHornsData', root,
function(boughtHorns)
	guiGridListClear(myHornsList)
	for i,j in ipairs(boughtHorns) do
		local row = guiGridListAddRow(myHornsList)
		guiGridListSetItemText(myHornsList, row, myHornsNameColumn, tostring(j)..") "..hornsTable[tonumber(j)], false, false)
		guiGridListSetItemData(myHornsList, row, myHornsNameColumn, hornsTable[tonumber(j)])
		guiGridListSetItemText(myHornsList, row, myHornsKeyColumn, getKeyBoundToHorn( tostring(j) ), false, false)
	end
end
)

function getKeyBoundToHorn(horn)
	bindsXML = xmlLoadFile ('horns/binds-' .. getElementData(localPlayer, "mrgreen_gc_forumID").. '.xml')
	if not bindsXML then
		bindsXML = xmlCreateFile('horns/binds-' .. getElementData(localPlayer, "mrgreen_gc_forumID").. '.xml', "binds")
		xmlSaveFile(bindsXML)
	end
	
	for i=0, 1000 do
		local bindNode = xmlFindChild(bindsXML, "bind", i)
		if bindNode then
			local key = xmlNodeGetAttribute(bindNode, "key")
			local hornID = xmlNodeGetAttribute(bindNode, "hornID")
			if key ~= nil and horn == hornID then
				if string.len(hornID) >=5 then
					triggerServerEvent("bindHorn", localPlayer, key, hornID, nil, true)
				elseif string.len(hornID) >= 1 and string.len(hornID) <= 3 then
					triggerServerEvent("bindHorn", localPlayer, key, hornID, nil, false)
				end
				xmlUnloadFile(bindsXML)
				return key
			end
		else xmlUnloadFile(bindsXML) return "-"  
		end
	end 
end


soundTimer = {}
killOtherTimer = {}
local screenSizex, screenSizey = guiGetScreenSize()
local guix = screenSizex * 0.1
local guiy = screenSizex * 0.1
local globalscale = 1
local globalalpha = 1
icon = {}

function createSoundForCar(car, horn)
	if isElement(icon[car]) then destroyElement(icon[car]) end
	if isTimer(soundTimer[car]) then killTimer(soundTimer[car]) end
	if isTimer(killOtherTimer[car]) then killTimer(killOtherTimer[car]) end
	icon[car] = guiCreateStaticImage(0, 0, guix, guiy, "horns/icon.png", false )
	guiSetVisible(icon[car], false)
	local x,y,z = getElementPosition(car)
	local extension
	extension = ".wav"
	if extensions[tonumber(horn)] then
		extension = "." .. extensions[tonumber(horn)]
	end	
	local sound = playSound3D("horns/files/"..horn..extension, x, y, z, false)
	setSoundMaxDistance(sound, 50)
	local length = getSoundLength(sound)
	length = length * 1000
	soundTimer[car] = setTimer(function(sound, car)
		if not isElement(sound) or not isElement(car) then return end
		local rx,ry,rz = getElementPosition(car)
		setElementPosition(sound, rx, ry, rz)
		
		
		local playerx, playery, playerz = getElementPosition( getPedOccupiedVehicle(localPlayer) )
		cp_x, cp_y, cp_z = getElementPosition( car)
		local dist = getDistanceBetweenPoints3D ( cp_x, cp_y, cp_z, playerx, playery, playerz )
		if dist and dist < 40 and ( isLineOfSightClear(cp_x, cp_y, cp_z+1.2, playerx, playery, playerz, true, false, false, false )) then
			local screenX, screenY = getScreenFromWorldPosition ( cp_x, cp_y, cp_z+1.2 )
			local scaled = screenSizex * (1/(2*(dist+5))) *.85
			local relx, rely = scaled * globalscale, scaled * globalscale
			
			guiSetAlpha(icon[car], globalalpha)
			guiSetSize(icon[car], relx, rely, false)
			if(screenX and screenY) then
				guiSetPosition(icon[car], screenX, screenY, false)
				guiSetVisible(icon[car], true)
			else
				guiSetVisible(icon[car], false)
			end
		else
		 guiSetVisible(icon[car], false)
		end
		
		
		
	end, 50, 0, sound,car)
	
	killOtherTimer[car] = setTimer(function(theTimer, car) if isTimer(theTimer) then killTimer(theTimer) if isElement(icon[car]) then destroyElement(icon[car]) end end  end, length, 50, soundTimer[car], car)
end

addEvent("onPlayerUsingHorn", true)
addEventHandler("onPlayerUsingHorn", root,
function(horn, car)
	if (getElementData(source, "state") == "alive") and (getElementData(localPlayer, "state") == "alive") and (soundsOn == true) and (getElementData(localPlayer, "dim") == getElementData(source, "dim")) and getPedOccupiedVehicle(localPlayer) then
		local x,y,z = getElementPosition(getPedOccupiedVehicle(localPlayer))
		local rx, ry, rz = getElementPosition(car)
		if getDistanceBetweenPoints3D(x,y,z,rx,ry,rz) < 40 then
			createSoundForCar(car, horn)
		end	
	end	
end
)

soundsOn = true

addEvent('onClientSuccessBuyUnlimitedUsage', true)
addEventHandler('onClientSuccessBuyUnlimitedUsage', root,
function(success)
	if success then
		guiSetText(unlimited, "Buy unlimited usage\nPrice: 5000 GC\nBought!")
		guiSetEnabled(unlimited, false)
	end
end
)