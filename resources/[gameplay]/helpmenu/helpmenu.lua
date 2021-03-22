GUIEditor = {
    window = {},
    staticimage = {},
    label = {}
}

--Settings
local screenW, screenH = guiGetScreenSize()
local windowW, windowH = 840, 570
local left = screenW/2 - windowW/2
local top = screenH/2 - windowH/2
local tabpanelW, tabpanelH = windowW-50, windowH-130
local motdIndent = 20
local motdW, motdH = 0.45*(tabpanelW-motdIndent), tabpanelH-(motdIndent*3.3)
local logoW, logoH = 350, 137
local adminColumnN1posX = motdIndent*2.5+motdW
local adminColumnN2posX = adminColumnN1posX+0.5*(tabpanelW-(motdIndent*4+motdW))
local adminColumnW, adminColumnH = adminColumnN2posX-adminColumnN1posX, 20
local offlineColor = { r = 100, g = 100, b = 100 }
local onlineColor = { r = 0, g = 255, b = 0 }
local languageTabs = {}
local _guiSetVisible = guiSetVisible
function guiSetVisible(element, state)
	if element == MainWindow and getResourceState(getResourceFromName('blur_box')) == 'running' then
		if MainWindowBlur then exports.blur_box:destroyBlurBox(MainWindowBlur) end
		if state == true then
			MainWindowBlur = exports.blur_box:createBlurBox( 0, 0,  screenW, screenH, 255, 255, 255, 255, true )
			MainWindowBlurIntensity = exports.blur_box:setBlurIntensity(2.5)
		end
	end
	_guiSetVisible(element, state)
end

function showhideGUI()
	if not guiGetVisible(MainWindow) then
		triggerServerEvent('requestChangelog', resourceRoot)
		triggerServerEvent('requestAdmins', resourceRoot)
		guiSetVisible(MainWindow, true)
		showCursor(true)
	else
		guiSetVisible(MainWindow, false)
		showCursor(false)
	end
end
bindKey("F9", "up", showhideGUI)

addEventHandler("onClientResourceStop", resourceRoot, function()
	exports.blur_box:destroyBlurBox(MainWindowBlur)
end)

function buildGUI()
	local screenWidth, screenHeight = guiGetScreenSize()
	MainWindow = guiCreateStaticImage(left, top, windowW, windowH, "img/dot.jpg", false)
	guiSetProperty(MainWindow, "ImageColours", "tl:FF0A0A0A tr:FF0A0A0A bl:FF0A0A0A br:FF0A0A0A") 
	GUIEditor.staticimage[2] = guiCreateStaticImage(0, 0, windowW, 10, "img/dot.jpg", false, MainWindow)
	guiSetProperty(GUIEditor.staticimage[2], "ImageColours", "tl:FF4EC857 tr:FF4EC857 bl:FF4EC857 br:FF4EC857")
	GUIEditor.staticimage[3] = guiCreateStaticImage(0, 10, windowW, 10, "img/dot.jpg", false, MainWindow)
	guiSetProperty(GUIEditor.staticimage[3], "ImageColours", "tl:FF0CB418 tr:FF0CB418 bl:FF0CB418 br:FF0CB418")
	GUIEditor.label[1] = guiCreateLabel(364, 1, 128, 16, "Welcome!", false, MainWindow)
	guiSetFont(GUIEditor.label[1], "default-bold-small")
	guiLabelSetColor(GUIEditor.label[1], 255, 255, 255)
	guiLabelSetHorizontalAlign(GUIEditor.label[1], "center", false)
	guiLabelSetVerticalAlign(GUIEditor.label[1], "center")
	guiSetProperty(GUIEditor.label[1], "AlwaysOnTop", "true")

	TabPanel = guiCreateTabPanel( 0.5*(windowW-tabpanelW), 0.08*windowH, tabpanelW, tabpanelH, false, MainWindow)
	
	AboutTab = guiCreateTab("About", TabPanel)
	
	MotdMemo = guiCreateMemo(motdIndent, motdIndent, motdW, motdH, "Welcome to the Mr. Green MTA servers!", false, AboutTab)
	guiMemoSetReadOnly(MotdMemo,true)
	
	MrGreenLogo = guiCreateStaticImage( (motdIndent+motdW)+0.5*(tabpanelW-(motdIndent+motdW)-logoW), tabpanelH*0.08, 350, 137, ":helpmenu/img/logo.png", false, AboutTab)
	
	StaffTitle = guiCreateLabel(motdW, tabpanelH*0.45, tabpanelW-(motdIndent+motdW), 20, "Mr Green Gaming Staff", false, AboutTab)
	guiSetFont(StaffTitle, "default-bold-small")
	guiLabelSetHorizontalAlign(StaffTitle, "center", false)
	guiLabelSetColor(StaffTitle, 0, 255, 0)
	
	local multiplierX = 1.0
	local multiplierY = 0.88
	offline = guiCreateLabel(adminColumnN1posX-motdIndent*multiplierX, tabpanelH*multiplierY, adminColumnW, adminColumnH, "•          ", false, AboutTab)
	guiLabelSetColor(offline, offlineColor.r, offlineColor.g, offlineColor.b)
	guiLabelSetHorizontalAlign(offline, "right", false)
	offline2 = guiCreateLabel(adminColumnN1posX-motdIndent*multiplierX, tabpanelH*multiplierY, adminColumnW, adminColumnH, "offline ", false, AboutTab)
	guiLabelSetHorizontalAlign(offline2, "right", false)
	
	online = guiCreateLabel(adminColumnN2posX-motdIndent*multiplierX, tabpanelH*multiplierY, adminColumnW, adminColumnH, " •", false, AboutTab)
	guiLabelSetColor(online, onlineColor.r, onlineColor.g, onlineColor.b)
	guiCreateLabel(adminColumnN2posX-motdIndent*multiplierX, tabpanelH*multiplierY, adminColumnW, adminColumnH, "   online", false, AboutTab)

	local m = 0
	for i=1, math.ceil(#admins/2) do --column #1
		m = m + 20
		guiCreateLabel(adminColumnN1posX, tabpanelH*0.45+m, adminColumnW, adminColumnH, admins[i].name.." - "..admins[i].title, false, AboutTab)
		admins[i].label = guiCreateLabel(adminColumnN1posX-10, tabpanelH*0.45+m, adminColumnW, adminColumnH, "•", false, AboutTab)
		guiLabelSetColor(admins[i].label, offlineColor.r, offlineColor.g, offlineColor.b)
	end
	
	local m = 0
	for i=math.ceil(#admins/2)+1, #admins do --column #2
		m = m + 20
		guiCreateLabel(adminColumnN2posX, tabpanelH*0.45+m, adminColumnW, adminColumnH, admins[i].name.." - "..admins[i].title, false, AboutTab)
		admins[i].label = guiCreateLabel(adminColumnN2posX-10, tabpanelH*0.45+m, adminColumnW, adminColumnH, "•", false, AboutTab)
		guiLabelSetColor(admins[i].label, offlineColor.r, offlineColor.g, offlineColor.b)
	end
	
	CommandsBindsTab = guiCreateTab("Commands & Binds", TabPanel)
	
	CommandsBindsMemoText = guiCreateMemo(motdIndent, motdIndent, tabpanelW-motdIndent*2, motdH, "                           _______________________________ BINDS _________________________________", false, CommandsBindsTab)
	guiMemoSetReadOnly(CommandsBindsMemoText,true)

	local cmdFile = fileOpen('commands.txt', true)
	if cmdFile then
		cmdsText = fileRead(cmdFile, fileGetSize(cmdFile))
		guiSetText(CommandsBindsMemoText, cmdsText)
		fileClose(cmdFile)
	end
	
	LogBindsTab = guiCreateTab("Changelog", TabPanel)
	
	ChangeLogUpdates = guiCreateLabel(268, 48, 20, 20, "*", false, MainWindow)
    guiLabelSetColor(ChangeLogUpdates, 253, 0, 0)
	guiSetProperty(ChangeLogUpdates, "AlwaysOnTop", "True")
	guiSetVisible(ChangeLogUpdates, false)
	
	addEventHandler("onClientGUIClick", TabPanel, function() guiSetVisible(ChangeLogUpdates, false) end, false)
	
	LogBindsMemoText = guiCreateMemo(motdIndent, motdIndent, tabpanelW-motdIndent*2, motdH, "Changelog currently isn't available for a some reason. Try to reconnect or check this tab a bit later", false, LogBindsTab)
	guiMemoSetReadOnly(LogBindsMemoText, true)

	RulesFaqsTab = guiCreateTab("English", TabPanel)
    RulesMemo = guiCreateMemo(22, 20, 340, motdH, "\n                         _____ Rules _____\n\n\n  1. Do not cheat, hack or exploit to get any advantage\n\n  2. Do not insult or provoke any players or admins\n\n  3. Do not block other players or camp in DD and SH\n\n  4. Do not flood or spam the main chat\n\n  5. Do not advertise other servers\n\n  6. Do not TeamKill in CTF\n\n  7. Using someone's else PaintJob without their permission isn't allowed and punishable\n\n  8. Do not deliberately lock other people's name\n\n 9. The Main Chat is English only. Use /Language & R to use other languages \n\n Breaking any of these rules may result in ban.\n\n", false, RulesFaqsTab)
    FaqsMemo = guiCreateMemo(tabpanelW-340-motdIndent, 20, 340, motdH, "\n          _____ Frequently Asked Questions _____\n\n\n  Q: What are GreenCoins?\n  \n  A: GreenCoins are our community currency, you can         use them on all of our servers.\n\n  Q: How do win GreenCoins?\n\n  A: You win GreenCoins by simply playing on our servers     you can also donate to get GreenCoins in return.\n\n  Q: What can I buy on this server with GreenCoins?\n\n  A: You can buy Perks, Maps, Custom Horns, Skins             and you can modify your vehicle on our GC Shop - F6\n\n If you have any other questions refer them to our staff", false, RulesFaqsTab)
	guiMemoSetReadOnly(RulesMemo, true)
	guiMemoSetReadOnly(FaqsMemo, true)
	languageTabs.EN = RulesFaqsTab
	
	--]]
	-- Turkish 
--[[	
	RulesFaqsTab = guiCreateTab("Türkçe", TabPanel)
    RulesMemo = guiCreateMemo(22, 20, 340, motdH, "\n                         _____ Rules _____\n\n\n  1. Do not cheat, hack or exploit to get any advantage\n\n  2. Do not insult or provoke any players or admins\n\n  3. Do not block other players or camp in DD and SH\n\n  4. Do not flood or spam the main chat\n\n  5. Do not advertise other servers\n\n  6. Do not TeamKill in CTF\n\n  7. Do not deliberately lock other people's name\n\n  Breaking any of these rules may result in ban.\n\n", false, RulesFaqsTab)
    FaqsMemo = guiCreateMemo(tabpanelW-340-motdIndent, 20, 340, motdH, "\n          _____ Frequently Asked Questions _____\n\n\n  Q: What are GreenCoins?\n  \n  A: GreenCoins are our community currency, you can         use them on all of our servers.\n\n  Q: How do win GreenCoins?\n\n  A: You win GreenCoins by simply playing on our servers     you can also donate to get GreenCoins in return.\n\n  Q: What can I buy on this server with GreenCoins?\n\n  A: You can buy Perks, Maps, Custom Horns, Skins             and you can modify your vehicle on our GC Shop - F6\n\n If you have any other questions refer them to our staff", false, RulesFaqsTab)
	guiMemoSetReadOnly(RulesMemo, true)
	guiMemoSetReadOnly(FaqsMemo, true)
--]]
	-- Polish / Assntitties

	RulesFaqsTab = guiCreateTab("Polski", TabPanel)

    RulesMemo = guiCreateMemo(22, 20, 340, motdH, "\n                         _____ Regulamin _____\n\n\n  1. Nie używaj cheatów, hacków ani nie wykorzystuj błędów gry w celu zdobycia przewagi.\n\n  2. Nie wyzywaj ani nie prowokuj innych graczy albo adminów\n\n  3. Nie blokuj innych graczy ani nie camp na SH i DD\n\n  4. Nie spam na czacie\n\n  5. Nie reklamuj innych serwerów\n\n  6. Nie zabijaj swojej drużyny na CTF\n\n 7. Używanie malowania innej osoby bez jej zgody jest niedozwolone i karalne\n\n 8. Nie blokuj celowo nicków innych graczy\n\n  9. Czat główny jest dostępny tylko w języku angielskim. Użyj /Language & R, aby używać innych języków\n\n Złamanie jakiejkolwiek z tych zasad może być ukarane banem.\n\n", false, RulesFaqsTab)
    FaqsMemo = guiCreateMemo(tabpanelW-340-motdIndent, 20, 340, motdH, "\n          _____ Najczęściej Zadawane Pytania _____\n\n\n  P: Co to są GreenCoinsy?\n  \n  O: GreenCoinsy są naszą walutą, możesz ich używać na każdym z naszych serwerów.\n\n  P: Jak mogę zdobyć GreenCoinsy?\n\n  O: GreenCoinsy zdobywasz poprostu grając na naszych serwerach,    możesz także wpłacić dotacje aby dostać w zamian GreenCoinsy.\n\n  P: Co mogę kupić za GreenCoinsy?\n\n  O: Możesz kupic Perki, Mapy, Niestandardowe klaksony, Skiny             a także modyfikowac pojazdy w naszym Sklepie GC - F6\n\n Jeśli masz jakiekolwiek dodatkowe pytania, kieruj je do adminstracji albo moderatorów", false, RulesFaqsTab)
    guiMemoSetReadOnly(RulesMemo, true)
    guiMemoSetReadOnly(FaqsMemo, true)
	languageTabs.PL = RulesFaqsTab
    
    -- Russian / Military
    
    RulesFaqsTab = guiCreateTab("Русский", TabPanel)
    
    RulesMemo = guiCreateMemo(22, 20, 340, motdH, "\n                          ______ Rules ______ \n\n\n  1.  Запрещено использовать читы или любые другие  программы для получения преимущества. \n\n  2. Не оскорбляйте и не провоцируйте игроков или администраторов. \n\n  3. Не блокируйте других игроков. Запрещено избегать других игроков (кэмперить, прятаться) в режимах DD и SH\n\n  4. Флуд и спам в основном чате запрещены. \n\n  5. Реклама других серверов запрещена. \n\n  6. Не убивайте своих тиммейтов в режиме CTF\n\n  7. Использование чужого PaintJob (винила для машины) без его разрешения запрещено и наказуемо.\n\n  8. Намеренная блокировка чужого никнейма (Locked Nicks) запрещена.  \n\n 9. В основной чат можно писать только на английском языке. Используйте /language для выбора языка. Для написания в языковой чат нажмите R.  \ n \ n Нарушение любого из этих правил может привести к бану.\n\n", false, RulesFaqsTab)
    FaqsMemo = guiCreateMemo(tabpanelW-340-motdIndent, 20, 340, motdH, "\n      ______Часто задаваемые вопросы______  \n \n \n Q: Что такое GreenCoins? \n \n A: GreenCoins - это валюта нашего сообщества, вы можете использовать её на всех наших серверах. \n \n Q: Где взять GreenCoins? \n \n A: Вы выигрываете GreenCoins, просто играя на наших серверах, можете задонатить, чтобы получить GreenCoins взамен. \n \n В: Что я могу купить на этом сервере с помощью GreenCoins? \n \n A: Вы можете купить Перки, Карты, Пользовательские Сигналы, Скины, также вы можете изменить свой автомобиль в нашем Магазине GC - F6 \n \n Если у вас есть другие вопросы, обратитесь к администрации или просто спросите в чате. ", false, RulesFaqsTab)
    guiMemoSetReadOnly(RulesMemo, true)
    guiMemoSetReadOnly(FaqsMemo, true)
    languageTabs.RU = RulesFaqsTab
    
	-- Spanish / Anthony

	RulesFaqsTab = guiCreateTab("Español", TabPanel)
	

    RulesMemo = guiCreateMemo(22, 20, 340, motdH, "\n                         __ Reglas __\n\n\n  1. No hacer trampas, hackear o abusar de bugs para obtener ventajas.\n\n  2. No insultar o provocar a ningun admin y/o jugador.\n\n 3. No bloquear a otros jugadores (NTS) y no campear (DD y SH).\n\n  4. No hacer flood ni spam en el chat principal.\n\n 5. No anunciar cualquier contenido de otros servidores.\n\n 6. No matar compañeros de equipo en CTF.\n\n 7.Usar el PaintJob de otra persona sin su permiso no está permitido y es punible\n\n 8. No bloquear el nombre de otros jugadores\n\n 9. El chat principal es solo en inglés. Use /Language & R para usar otros idiomas\n\nRomper cualquiera de estas reglas puede resultar en un ban.\n\n", false, RulesFaqsTab)
    FaqsMemo = guiCreateMemo(tabpanelW-340-motdIndent, 20, 340, motdH, "\n          __ Preguntas frecuentes: __\n\n\n  Q: ¿Que son los Greencoins?\n \n R: Los Greencoins son la moneda de la comunidad MrGreen, puedes hacer uso de estos en todos nuestros servidores.\n\n  Q: ¿Como puedo obtener Greencoins?\n\n R: Fácil, puedes conseguirlos jugando en nuestros servidores. Además puedes hacer donaciones monetarias y recibir Greencoins a cambio.\n\n  Q: ¿Que puedo comprar en este servidor con Greencoins?\n\n R: Puedes comprar Perks, Mapas, Silbatos únicos (Horns) y skins , además de poder modificar tus coches en nuestra tienda GC (F6)\n\n ¿Dudas?, Puedes preguntarle a cualquier miembro del staff.", false, RulesFaqsTab)
    guiMemoSetReadOnly(RulesMemo, true)
    guiMemoSetReadOnly(FaqsMemo, true)
	languageTabs.ES = RulesFaqsTab
	-- Hungarian
--[[	
		RulesFaqsTab = guiCreateTab("Magyar", TabPanel)
    RulesMemo = guiCreateMemo(22, 20, 340, motdH, "\n                         _____ Rules _____\n\n\n  1. Do not cheat, hack or exploit to get any advantage\n\n  2. Do not insult or provoke any players or admins\n\n  3. Do not block other players or camp in DD and SH\n\n  4. Do not flood or spam the main chat\n\n  5. Do not advertise other servers\n\n  6. Do not TeamKill in CTF\n\n  7. Do not deliberately lock other people's name\n\n  Breaking any of these rules may result in ban.\n\n", false, RulesFaqsTab)
    FaqsMemo = guiCreateMemo(tabpanelW-340-motdIndent, 20, 340, motdH, "\n          _____ Frequently Asked Questions _____\n\n\n  Q: What are GreenCoins?\n  \n  A: GreenCoins are our community currency, you can         use them on all of our servers.\n\n  Q: How do win GreenCoins?\n\n  A: You win GreenCoins by simply playing on our servers     you can also donate to get GreenCoins in return.\n\n  Q: What can I buy on this server with GreenCoins?\n\n  A: You can buy Perks, Maps, Custom Horns, Skins             and you can modify your vehicle on our GC Shop - F6\n\n If you have any other questions refer them to our staff", false, RulesFaqsTab)
	guiMemoSetReadOnly(RulesMemo, true)
	guiMemoSetReadOnly(FaqsMemo, true)
]]-- 
	-- BR / NITRO

	RulesFaqsTab = guiCreateTab("Português BR", TabPanel)

	RulesMemo = guiCreateMemo(22, 20, 340, motdH, "\n                         __ Regras __\n\n\n  1. Não tente enganar, hackear ou abusar de bugs para obter benefícios.\n\n  2. Não insultar ou provocar os Administradores e/ou Jogadores.\n\n 3. Não bloqueie outros jogadores (NTS) e não campere (DD e SH).\n\n  4. Sem flood ou spam no bate-papo principal.\n\n 5. Não anuncie outros servidores/IPs.\n\n 6. Não mate companheiros de equipe no CTF.\n\n 7. Usar o PaintJob de outra pessoa sem a permissão dela não é permitido e passível de punição \n\n  8. Não bloqueie nomes de outros jogadores\n\n9. O chat principal é apenas em inglês. Use /Language e R para usar outros idiomas \n\n Quebrar qualquer uma dessas regras pode resultar em uma punição ou Banimento.\n\n", false, RulesFaqsTab)
	FaqsMemo = guiCreateMemo(tabpanelW-340-motdIndent, 20, 340, motdH, "\n          __ Perguntas Frequentes __\n\n\n  Q: O que são os Greencoins?\n \n A: Os Greencoins são a moeda da Comunidade MrGreen, você pode fazer uso deslas em todos os nossos servidores.\n\n  Q: Como posso obter Greencoins?\n\n A: Fácil, você pode obtê-los jogando em nossos servidores. Você também pode fazer doações em dinheiro e receber Greencoins em troca.\n\n  Q: O que posso comprar neste servidor com Greencoins?\n\n A: Você pode comprar Perks, Mapas, Assobios personalizados (Horns) e Skins, e também poderá personalizar seus carros em nossa loja GC (F6)\n\n Duvidas?, Você pode pedir auxilio a qualquer membro da equipe (Staff).", false, RulesFaqsTab)
	guiMemoSetReadOnly(RulesMemo, true)
	guiMemoSetReadOnly(FaqsMemo, true)
	languageTabs.PT = RulesFaqsTab
	
	-- Arabic / Haxardous

-- 	RulesFaqsTab = guiCreateTab("العربية", TabPanel)

-- 	RulesMemo = guiCreateMemo(22, 20, 340, motdH, "\n                         _____ القوانين _____\n\n\n  1. لا تغش او تستخدم اي اداة تمنحك الافضلية عن الاخرين\n\n  2. يمنع السب او الشتم او التعرض للاعبين او الاداريين\n\n  3. لا تعيق طريق اللاعبين او تعيق اللاعبين وقت اللعب\n\n  4. يمنع منعا باتا السبام واعاقة الشات العام\n\n  5. يمنع النشر او الترويج للسيرفرات الاخرى\n\n  6. لا تقوم باعاقة اعضاء فريقك في كابتشر ذا فلاج\n\n  ٧. إستخدام "سكن" الآخرين بدون إذن منهم ممنوع منعاً باتاً وسيتم فرض عقوبة. \n\n ٨. يمنع منعاً باتاً إستخدام أو اقفال أسماء الأخرين. \n\n ٩. يرجى إستخدام اللغة الإنجليزية فقط في الشات العام، اذ اردت التحدث بلغتك فقم بإستخدام آمر language/ ثم قم بإستخدام زر R \n\n  كسر اياً من القوانين قد يعرضك للحظر.\n\n", false, RulesFaqsTab)
--   	FaqsMemo = guiCreateMemo(tabpanelW-340-motdIndent, 20, 340, motdH, "\n          _____ الاسئلة الشاعة _____\n\n\n  س: ماهو الجرين كوين؟?\n  \n  ج: الجرين كوين هي العملة التي تستخدم هنا, تستعمل في جميع سيرفراتنا.\n\n  س: كيف اربع الجرين كوينز؟\n\n  ج: تستطيع ان تربع الجرين كوينز فقط عن طريق اللعب داخل سيرفراتنا بكل سهولة.\n\n  س: ماذا استطيع ان اشتري بأستخادم الجرين كوينز؟\n\n  ج: تستطيع ان تشتري بعض الخواص, المابات, الابواق, الشخصيات و ايضاً تستطيع ان تضيف تعديلات على سياراتك من خلال  متجر الجرين كوين.\n\n اذ هناك اي اسئلة اخرى يرجى التواصل مع الفريق الاداري.", false, RulesFaqsTab)
-- 	guiMemoSetReadOnly(RulesMemo, true)
-- 	guiMemoSetReadOnly(FaqsMemo, true)
-- 	languageTabs.AR = RulesFaqsTab

	-- close button 

	CloseButton = guiCreateStaticImage(650, 505, 131, 21.5, "img/dot.jpg", false, MainWindow)
	CloseButtonTwo = guiCreateStaticImage(650, 505, 131, 41, "img/dot.jpg", false, MainWindow)
	guiSetProperty(CloseButton, "ImageColours", "tl:FF4EC857 tr:FF4EC857 bl:FF4EC857 br:FF4EC857")
	guiSetProperty(CloseButtonTwo, "ImageColours", "tl:FF0CB418 tr:FF0CB418 bl:FF0CB418 br:FF0CB418")
	guiSetProperty(CloseButton, "AlwaysOnTop", "true")

	CloseLabel = guiCreateLabel(650, 505, 131, 41, "Close", false, MainWindow)
	guiSetFont(CloseLabel, "default-bold-small")
	guiLabelSetHorizontalAlign(CloseLabel, "center", false)
	guiLabelSetVerticalAlign(CloseLabel, "center")
	guiSetProperty(CloseLabel, "AlwaysOnTop", "true")
	
	addEventHandler("onClientMouseEnter", CloseLabel, function()
		guiSetAlpha(CloseButton, 1)
		guiSetAlpha(CloseButtonTwo, 1)
	end)

	addEventHandler("onClientMouseLeave", CloseLabel, function()
		guiSetAlpha(CloseButton, 0.5)
		guiSetAlpha(CloseButtonTwo, 0.5)
	end)

	if on_pushButton_clicked then
		addEventHandler("onClientGUIClick", CloseLabel, on_pushButton_clicked, false)
	end
	
	-- switch button

	SwitchButtonOne = guiCreateStaticImage(350, 505, 131, 21.5, "img/dot.jpg", false, MainWindow)
	SwitchButtonTwo = guiCreateStaticImage(350, 505, 131, 41, "img/dot.jpg", false, MainWindow)
	guiSetProperty(SwitchButtonOne, "ImageColours", "tl:FF4EC857 tr:FF4EC857 bl:FF4EC857 br:FF4EC857")
	guiSetProperty(SwitchButtonTwo, "ImageColours", "tl:FF0CB418 tr:FF0CB418 bl:FF0CB418 br:FF0CB418")
	guiSetProperty(SwitchButtonOne, "AlwaysOnTop", "true")

	SwitchButton = guiCreateLabel(350, 505, 131, 41, "Switch Server", false, MainWindow)
	guiSetFont(SwitchButton, "default-bold-small")
	guiLabelSetHorizontalAlign(SwitchButton, "center", false)
	guiLabelSetVerticalAlign(SwitchButton, "center")
	guiSetProperty(SwitchButton, "AlwaysOnTop", "true")
	
	addEventHandler("onClientMouseEnter", SwitchButton, function()
		guiSetAlpha(SwitchButtonOne, 1)
		guiSetAlpha(SwitchButtonTwo, 1)
	end)

	addEventHandler("onClientMouseLeave", SwitchButton, function()
		guiSetAlpha(SwitchButtonOne, 0.5)
		guiSetAlpha(SwitchButtonTwo, 0.5)
	end)
	addEventHandler("onClientGUIClick", SwitchButton, function() triggerServerEvent('onRequestRedirect', localPlayer) end, false)
	
	-- settingsbutton

	SettingsButtonOne = guiCreateStaticImage(50, 505, 131, 21.5, "img/dot.jpg", false, MainWindow)
	SettingsButtonTwo = guiCreateStaticImage(50, 505, 131, 41, "img/dot.jpg", false, MainWindow)
	guiSetProperty(SettingsButtonOne, "ImageColours", "tl:FF4EC857 tr:FF4EC857 bl:FF4EC857 br:FF4EC857")
	guiSetProperty(SettingsButtonTwo, "ImageColours", "tl:FF0CB418 tr:FF0CB418 bl:FF0CB418 br:FF0CB418")
	guiSetProperty(SettingsButtonOne, "AlwaysOnTop", "true")

	SettingsButton = guiCreateLabel(50, 505, 131, 41, "Settings", false, MainWindow)
	guiSetFont(SettingsButton, "default-bold-small")
	guiLabelSetHorizontalAlign(SettingsButton, "center", false)
	guiLabelSetVerticalAlign(SettingsButton, "center")
	guiSetProperty(SettingsButton, "AlwaysOnTop", "true")
	
	addEventHandler("onClientMouseEnter", SettingsButton, function()
		guiSetAlpha(SettingsButtonOne, 1)
		guiSetAlpha(SettingsButtonTwo, 1)
	end)

	addEventHandler("onClientMouseLeave", SettingsButton, function()
		guiSetAlpha(SettingsButtonOne, 0.5)
		guiSetAlpha(SettingsButtonTwo, 0.5)
	end)

	if on_pushButton_2_clicked then
		addEventHandler("onClientGUIClick", SettingsButton, on_pushButton_2_clicked, false)
	end
	
	
	guiSetVisible(MainWindow, false)
	triggerServerEvent('requestMOTD', resourceRoot)
end
addEventHandler("onClientResourceStart", resourceRoot, buildGUI)


addEvent('receiveAdmins', true)
addEventHandler('receiveAdmins', resourceRoot, 
function ( onlineAdmins )
	for k, v in pairs(onlineAdmins) do
		if onlineAdmins[k] == true then
			guiLabelSetColor(admins[k].label, onlineColor.r, onlineColor.g, onlineColor.b)
		else
			guiLabelSetColor(admins[k].label, offlineColor.r, offlineColor.g, offlineColor.b)
		end
	end
end
)


addEvent('receiveChangelog', true)
addEventHandler('receiveChangelog', resourceRoot, 
function ( changelog, changelogLastUpdate, output )
	if not changelog then return end
	guiSetText(LogBindsMemoText, changelog)
	
	if isNewChangelog(changelogLastUpdate) then
		guiSetVisible(ChangeLogUpdates, true)
		if output then
			outputChatBox("[UPDATE] #FFFFFFSomething updated, press F9 -> #00ff00\"Changelog\" #FFFFFFto see what's new#00ff00!", 0, 255, 0, true)
		end
	end
end
)


local changelogFile = 'changelog.xml'
function isNewChangelog(changelogLastUpdate)
	local setting = fileExists(changelogFile) and xmlLoadFile(changelogFile) or xmlCreateFile(changelogFile, 'settings')
	local new = false
	if xmlNodeGetAttribute(setting, 'changelogLastUpdate') ~= changelogLastUpdate then
		xmlNodeSetAttribute(setting, 'changelogLastUpdate', changelogLastUpdate)
		xmlSaveFile(setting)
		new = true
	end
	xmlUnloadFile(setting)
	return new
end


addEvent('receiveMotd', true)
addEventHandler('receiveMotd', resourceRoot, 
function ( motdText, motdVersion )
	guiSetText(MotdMemo, motdText)
	
	if isNewMotd(motdVersion) then
		showhideGUI()
	end
end
)


local settingsFile = '@settings.xml'
function isNewMotd(motdVersion)
	local setting = fileExists(settingsFile) and xmlLoadFile(settingsFile) or xmlCreateFile(settingsFile, 'settings')
	local new = false
	if tonumber(xmlNodeGetAttribute(setting, 'version')) ~= motdVersion then
		xmlNodeSetAttribute(setting, 'version', motdVersion)
		xmlSaveFile(setting)
		new = true
	end
	xmlUnloadFile(setting)
	return new
end


function editmotd()
	guiMemoSetReadOnly(MotdMemo,false)
end
addCommandHandler('editmotd', editmotd)


function savemotd()
	guiMemoSetReadOnly(MotdMemo,true)
	triggerServerEvent('savemotd', resourceRoot, guiGetText(MotdMemo) )
end
addCommandHandler('savemotd', savemotd)


function on_pushButton_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then return end
	showhideGUI()
end


function on_pushButton_2_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then return end
	executeCommandHandler("settings")	
end

addEvent("sb_showHelp")
addEventHandler("sb_showHelp",root,function()
	setPlayerLanguageTab()
	if not guiGetVisible(MainWindow) then
		guiSetVisible(MainWindow, true)
		showCursor(true)
	end
end)


addEvent("sb_showServerInfo")
addEventHandler("sb_showServerInfo",root,function()
	if not guiGetVisible(MainWindow) then
		guiSetVisible(MainWindow, true)
		showCursor(true)
		guiSetSelectedTab(TabPanel,AboutTab)
	else
		guiSetVisible(MainWindow, false)
		showCursor(false)
	end
end
)



local countryLanguages = {
	['PL'] = 'PL',
	['BR'] = 'PT',
	['PT'] = 'PT',
	['ES'] = 'ES',
	['MX'] = 'ES',
	['CO'] = 'ES',
	['AR'] = 'ES',
	['PE'] = 'ES',
	['VE'] = 'ES',
	['CL'] = 'ES',
	['EC'] = 'ES',
	['GT'] = 'ES',
	['CU'] = 'ES',
	['BO'] = 'ES',
	['DO'] = 'ES',
	['HN'] = 'ES',
	['PY'] = 'ES',
	['SV'] = 'ES',
	['NI'] = 'ES',
	['CR'] = 'ES',
	['PR'] = 'ES',
	['PA'] = 'ES',
	['UY'] = 'ES',
	['GQ'] = 'ES',
	['DZ'] = 'AR',
	['BH'] = 'AR',
	['TD'] = 'AR',
	['KM'] = 'AR',
	['DJ'] = 'AR',
	['EG'] = 'AR',
	['ER'] = 'AR',
	['IQ'] = 'AR',
	['JO'] = 'AR',
	['KW'] = 'AR',
	['LB'] = 'AR',
	['LY'] = 'AR',
	['MR'] = 'AR',
	['MA'] = 'AR',
	['OM'] = 'AR',
	['PS'] = 'AR',
	['QA'] = 'AR',
	['SA'] = 'AR',
	['SO'] = 'AR',
	['SD'] = 'AR',
	['SY'] = 'AR',
	['TN'] = 'AR',
	['AE'] = 'AR',
	['YE'] = 'AR',
    ['RU'] = 'RU',
}

function setPlayerLanguageTab()
	local countryCode = getElementData(localPlayer, 'country')
	if type(countryCode) == 'string' and countryLanguages[countryCode] then
		guiSetSelectedTab(TabPanel, languageTabs[countryLanguages[countryCode]])
	else
		guiSetSelectedTab(TabPanel, languageTabs.EN)
	end
end
