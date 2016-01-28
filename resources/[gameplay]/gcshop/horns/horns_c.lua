local screenWidth, screenHeight = guiGetScreenSize()
downloadHornList = {}
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
	[202] = "WAR, WAR NEVER CHANGES!",
	[203] = "Laugh",
	[204] = "Mr FuckFace",
	[205] = "Leeroy",
	[206] = "MadLaugh1",	
	[207] = "MadLaugh2",	
	[208] = "MadLaugh3",
	[209] = "MadLaugh4",	
	[210] = "Out Of My Way",
	[211] = "Gazuj",
	[212] = "One click headshop",
	[213] = "DubStep 2",
	[214] = "Detonate",
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

local previewHornList = {}
function playButton(button, state)
	if button == "left" and state == "up" then	
		local row, col = guiGridListGetSelectedItem(availableHornsList)
		if row == -1 or row == false then
			return
		end
		row = row + 1
		local extension
		extension = ".mp3"

		table.insert(previewHornList,"horns/files/"..tostring(row)..extension)
		downloadFile( "horns/files/"..tostring(row)..extension )
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
	if not isElement(car) then return end
	if getElementType(car) == "player" then car = getPedOccupiedVehicle( car ) end -- If var car = player then turn car into an actual car element
	if isElement(icon[car]) then destroyElement(icon[car]) end
	if isTimer(soundTimer[car]) then killTimer(soundTimer[car]) end
	if isTimer(killOtherTimer[car]) then killTimer(killOtherTimer[car]) end
	icon[car] = guiCreateStaticImage(0, 0, guix, guiy, "horns/icon.png", false )
	guiSetVisible(icon[car], false)
	local x,y,z = getElementPosition(car)

	local sound = playSound3D(horn, x, y, z, false) -- Horn argument is passed as path
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
function playerUsingHorn(horn,car)
	if (getElementData(source, "state") == "alive") and (getElementData(localPlayer, "state") == "alive") and (soundsOn == true) and (getElementData(localPlayer, "dim") == getElementData(source, "dim")) and getPedOccupiedVehicle(localPlayer) then
		local x,y,z = getElementPosition(getPedOccupiedVehicle(localPlayer))
		local rx, ry, rz = getElementPosition(car)
		local playerTriggered = getVehicleOccupant( car )
		if not playerTriggered or getElementType(playerTriggered) ~= "player" then return end
		-- DO THIS IN OTHER FUNCTION -- if getDistanceBetweenPoints3D(x,y,z,rx,ry,rz) < 40 then
		
		-- Download file first, then do this

		local extension = ".mp3"


		local hornPath = "horns/files/"..horn..extension
		table.insert(downloadHornList,{horn=hornPath,player=playerTriggered})
		downloadFile( hornPath )
			
	end	
end
addEventHandler("onPlayerUsingHorn", root,playerUsingHorn)

	


function getHornSource(path,preview)
	local found = {}
	local remove = {}

	if preview then
		for num,t in ipairs(previewHornList) do
			if t == path then
				found = true
				table.insert(remove,num)
			end
		end
		if #remove > 0 then
			for _,i in ipairs(remove) do
				table.remove(previewHornList,i)
			end
		end		
	else

		for num,t in ipairs(downloadHornList) do
			if t.horn == path then
				table.insert(found,t.player)
				table.insert(remove,num)
			end
		end
		if #remove > 0 then
			for _,i in ipairs(remove) do
				table.remove(downloadHornList,i)
			end
		end
	end

	return found
end


function onHornDownloadComplete(path,succes)
	if not succes then outputDebugString("GCSHOP: "..path.." failed to download (horns_c)") return false end
	
	if #previewHornList > 0 then
		local prevSource = getHornSource(path,true)
		if isElement(hornPreview) then
			stopSound(hornPreview) 
		end
		if prevSource then
			hornPreview = playSound( path,false )
		end
	end

	local hornSource = getHornSource(path)
	if #hornSource > 0 then
		for _,p in ipairs(hornSource) do
			createSoundForCar(p, path)
		end
	end
end
addEventHandler("onClientFileDownloadComplete",resourceRoot,onHornDownloadComplete)

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