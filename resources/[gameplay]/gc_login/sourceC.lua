local screenX, screenY = guiGetScreenSize()
local isAssetsReady = false

addEventHandler("onClientResourceStart", resourceRoot, function()
	triggerEvent("onClientCheckAssets", resourceRoot)

	--if not getElementData(localPlayer, "player.loggedIn") then
		showLogin(true)
		fadeCamera(false)
	--end
end)

addEventHandler("onClientAssetsReady", getRootElement(), function(state)
	isAssetsReady = state
	
	loadAssets()
end)

addEvent("hideLogin", true)
addEventHandler("hideLogin", root, function()
	showLogin(false)
	fadeCamera(true)
end)

local animations = {}

local availableLanguages = {
	en = {"gb", "English"},
	cz = {"cz", "Czech"},
	pl = {"pl", "Polish"},
	tr = {"tr", "Turkish"},
	ru = {"ru", "Russian"},
	nl = {"nl", "Dutch"},
	de = {"de", "German"}
}

local assets = {
	images = {},
	fonts =  {},
}

local fakeInputs = {}
local inputDisabled = 0

local maskedFakeInputs = {
	password = true,
}

local backspaceTick = 0

local buttons = {}
local activeButton = false

local rememberMe = false

local logoW, logoH = 1024 * 0.3, 1024 * 0.3
local logoX, logoY = (screenX - logoW) * 0.5, (screenY - logoH) * 0.5

local inputW, inputH = 250, 30
local inputX, inputY = logoX + (logoW - inputW) * 0.5, logoY + (logoH - inputH) * 0.5

local buttonW, buttonH = 250, 30
local buttonX, buttonY = logoX + (logoW - buttonW) * 0.5, logoY + (logoH - buttonH) * 0.5

local flagW, flagH = 48, 48
local flagX, flagY = 10, screenY - flagH - 10

local checkboxW, checkboxH = 15, 15

local animStage = 0

local activePage = "login"

local isLoginFailed = false

local videoPlayer = nil
local musicPlayer = nil

function loadAssets()
	for type, table in pairs(assets) do
		for key, element in pairs(table) do
			if isElement(element) then
				destroyElement(element)
			end
		end
	end

	assets.fonts.RobotoRegular = dxCreateFont("files/Roboto-Regular.ttf", 14, false, "cleartype_natural")

	assets.images.circle = dxCreateTexture("files/circle.png", "argb", true, "clamp")
	assets.images.roundedcorner = dxCreateTexture("files/roundedcorner.png", "argb", true, "clamp")
end

function showLogin(state)
	if state then
		animStage = 1

		loadAssets()

		if isElement(videoPlayer) then
			destroyElement(videoPlayer)
		end
		videoPlayer = createBrowser(screenX, screenY, true, false)

		showChat(not state)
    	setPlayerHudComponentVisible("all", false)

		addEventHandler("onClientBrowserCreated", videoPlayer,
			function ()
				loadBrowserURL(videoPlayer, "http://mta/local/files/bg.html")

				if isElement(musicPlayer) then
					destroyElement(musicPlayer)
				end
				musicPlayer = playSound("files/bgmusic.mp3", true)
				outputDebugString("Playing Audio")

				addEventHandler("onClientRender", root, renderLogin)
				addEventHandler("onClientClick", root, onClientClick)
				addEventHandler("onClientCharacter", root, onClientCharacter)
				addEventHandler("onClientKey", root, onClientKey)
				isAssetsReady = true


				initAnimation("alphaMul", true, {0, 0, 0}, {1, 0, 0}, 1000, "Linear", function()
				logoW, logoH = 1024 * 0.3, 1024 * 0.3

				initAnimation("showLogoSize", true, {0, 0, 0}, {logoW, logoH, 0}, 1500, "InOutQuad", function()
					initAnimation("showLogoPosition", true, {0, logoY, 0}, {0, 20, 0}, 1500)
					initAnimation("showLogoSize", true, {logoW, logoH, 0}, {1024 * 0.2, 1024 * 0.2, 0}, 1500, "Linear", function()
						initAnimation("inputAlphaMul", true, {0, 0, 0}, {1, 0, 0}, 1500, "Linear", function()
							inputDisabled = 0
							showCursor(true)
						end)
					end)

					animStage = 3
					loadLoginData()
				end)

				initAnimation("showLogoRotation", false, {0, 0, 0}, {720, 0, 0}, 1499, "InOutQuad")
				
				animStage = 2
			end)

			end
		)
	else
		inputDisabled = 1
		showCursor(false)
		animStage = 4

		initAnimation("showLogoPosition", true, {logoX, 0, 0}, {screenX + logoW, 0, 0}, 1500)
		initAnimation("showLogoRotation", false, {0, 0, 0}, {720, 0, 0}, 1499, "Linear")
		initAnimation("inputAlphaMul", true, {1, 0, 0}, {0, 0, 0}, 1500, "Linear", function()
			initAnimation("alphaMul", true, {1, 0, 0}, {0, 0, 0}, 1000, "Linear", function()
				removeEventHandler("onClientRender", root, renderLogin)
				removeEventHandler("onClientClick", root, onClientClick)
				removeEventHandler("onClientCharacter", root, onClientCharacter)
				removeEventHandler("onClientKey", root, onClientKey)

				if isElement(musicPlayer) then
					stopSound(musicPlayer)
				end

				if isElement(videoPlayer) then
					destroyElement(videoPlayer)
				end

				showChat(not state)
    			setPlayerHudComponentVisible("all", false)
			end)
		end)
	end
end
addEvent("showLoginC", true)
addEventHandler("showLoginC", root, showLogin)

function renderLogin()
	if not isAssetsReady then
		return
	end
    for k, v in pairs(animations) do
        if not v.completed then
            local currentTick = getTickCount()
            local elapsedTick = currentTick - v.startTick
            local duration = v.endTick - v.startTick
            local progress = elapsedTick / duration

            v.currentValue[1], v.currentValue[2], v.currentValue[3] = interpolateBetween(
                v.startValue[1], v.startValue[2], v.startValue[3], 
                v.endValue[1], v.endValue[2], v.endValue[3], 
                progress, 
                v.easingType or "Linear"
            )

            if progress >= 1 then
                v.completed = true

                if v.completeFunction then
                    v.completeFunction(unpack(v.functionArgs))
                end
            end
        end
    end

    local absX, absY = getCursorPosition()

    buttons = {}

    if isCursorShowing() then
        absX = absX * screenX
        absY = absY * screenY
    else
        absX, absY = -1, -1
	end

	local alpha = getAnimationValue("alphaMul")[1]
	
	if isElement(videoPlayer) then
		dxDrawImage(0, 0, screenX, screenY, videoPlayer, 0, 0, 0, tocolor(255, 255, 255, 255 * alpha), true)
	end

	if isElement(musicPlayer) then
		setSoundVolume(musicPlayer, alpha)
	end

	if animStage >= 2 then
		logoW, logoH = getAnimationValue("showLogoSize")[1], getAnimationValue("showLogoSize")[2]
		if animStage == 2 then
			logoX, logoY = (screenX - logoW) * 0.5, (screenY - logoH) * 0.5
		elseif animStage == 3 then
			logoX, logoY = (screenX - logoW) * 0.5, getAnimationValue("showLogoPosition")[2]
		elseif animStage == 4 then
			logoX, logoY = getAnimationValue("showLogoPosition")[1], logoY
		end

		dxDrawImage(logoX, logoY, logoW, logoH, "files/logo.png", getAnimationValue("showLogoRotation")[1] or 0, 0, 0, tocolor(255, 255, 255, 255 * alpha), true)
	end

	local i = 0
	for k, v in pairs(availableLanguages) do
		local x = flagX + (flagW + 10) * i
		
		dxDrawImage(x, flagY, flagW, flagH, "files/flags/" .. v[1] .. ".png", 0, 0, 0, tocolor(255, 255, 255, 255 * getAnimationValue("inputAlphaMul")[1]), true)
		buttons["lang:" .. k] = {x, flagY, flagW, flagH}

		i = i + 1
	end

	if activePage == "login" then
		if animStage >= 3 then
			local inputAlphaMul = getAnimationValue("inputAlphaMul")[1]
			--print(inputAlphaMul, animStage)

			drawFakeInput("username", localizedStrings["render.input.username"], "files/icons/username.png", assets.fonts.RobotoRegular, 0.75, inputX, inputY + (inputH + 10) * 0, inputW, inputH)
			drawFakeInput("password", localizedStrings["render.input.password"], "files/icons/password.png", assets.fonts.RobotoRegular, 0.75, inputX, inputY + (inputH + 10) * 1, inputW, inputH)
			
			dxDrawRectangle(inputX, inputY + (inputH + 10) * 1 + inputH + 10, checkboxW, checkboxH, tocolor(52, 110, 68, 200 * inputAlphaMul), true)
			
			if rememberMe then
				dxDrawRectangle(inputX + 2, inputY + (inputH + 10) * 1 + inputH + 10 + 2, checkboxW - 4, checkboxH - 4, tocolor(11, 180, 25, 255 * inputAlphaMul), true)
			end

			buttons["checkbox:rememberMe"] = {inputX, inputY + (inputH + 10) * 1 + inputH + 10, checkboxW, checkboxH}

			if isLoginFailed then
				dxDrawText(localizedStrings["notification.login.wronguser"], inputX, inputY + (inputH + 10) * 1 + inputH + 25, checkboxW, checkboxH, tocolor(255, 0, 0, 255 * inputAlphaMul), 0.7, assets.fonts.RobotoRegular, "left", "top", false, false, true )
			end

			dxDrawText(localizedStrings["render.input.rememberme"], inputX + checkboxW + 10, inputY + (inputH + 10) * 1 + inputH + 10, checkboxW, checkboxH, tocolor(255, 255, 255, 255 * inputAlphaMul), 0.7, assets.fonts.RobotoRegular, "left", "top", false, false, true)

			drawButton("login", localizedStrings["render.button.login"], inputX, inputY + (inputH + 10) * 3, inputW, inputH, tocolor(255, 255, 255, 255 * inputAlphaMul), tocolor(52, 110, 68, 255 * inputAlphaMul), tocolor(11, 180, 25, 255 * inputAlphaMul), assets.images.circle, 0.7, assets.fonts.RobotoRegular)
			drawButton("guest", localizedStrings["render.button.guest"], inputX, inputY + (inputH + 10) * 4, inputW, inputH, tocolor(255, 255, 255, 255 * inputAlphaMul), tocolor(52, 110, 68, 255 * inputAlphaMul), tocolor(11, 180, 25, 255 * inputAlphaMul), assets.images.circle, 0.7, assets.fonts.RobotoRegular)

			--dxDrawText(localizedStrings["render.text.info"], inputX, inputY + (inputH + 20) * 4, inputW + inputX, inputH, tocolor(255, 255, 255, 255 * inputAlphaMul), 0.7, assets.fonts.RobotoRegular, "center")
		end
	-- elseif activePage == "register" then
	-- 	local inputAlphaMul = getAnimationValue("inputAlphaMul")[1]

	-- 	drawFakeInput("username", localizedStrings["render.input.username"], "files/icons/username.png", assets.fonts.RobotoRegular, 0.75, inputX, inputY + (inputH + 10) * 0, inputW, inputH)
	-- 	drawFakeInput("password", localizedStrings["render.input.password"], "files/icons/password.png", assets.fonts.RobotoRegular, 0.75, inputX, inputY + (inputH + 10) * 1, inputW, inputH)
	-- 	drawFakeInput("password2", localizedStrings["render.input.password2"], "files/icons/password.png", assets.fonts.RobotoRegular, 0.75, inputX, inputY + (inputH + 10) * 2, inputW, inputH)
	-- 	drawFakeInput("email", localizedStrings["render.input.email"], "files/icons/email.png", assets.fonts.RobotoRegular, 0.75, inputX, inputY + (inputH + 10) * 3, inputW, inputH)

	-- 	drawButton("register", localizedStrings["render.button.register"], inputX, inputY + (inputH + 10) * 4, inputW, inputH, tocolor(255, 255, 255, 255 * inputAlphaMul), tocolor(52, 110, 68, 255 * inputAlphaMul), tocolor(11, 180, 25, 255 * inputAlphaMul), assets.images.circle, 0.7, assets.fonts.RobotoRegular)
	-- 	drawButton("login", localizedStrings["render.button.login"], inputX, inputY + (inputH + 10) * 5, inputW, inputH, tocolor(255, 255, 255, 255 * inputAlphaMul), tocolor(52, 110, 68, 255 * inputAlphaMul), tocolor(11, 180, 25, 255 * inputAlphaMul), assets.images.circle, 0.7, assets.fonts.RobotoRegular)

		--dxDrawText(localizedStrings["render.text.info"], inputX, inputY + (inputH + 20) * 4, inputW + inputX, inputH, tocolor(255, 255, 255, 255 * inputAlphaMul), 0.7, assets.fonts.RobotoRegular, "center")
	end

    activeButton = false

    if isCursorShowing() then
        for k, v in pairs(buttons) do
            if absX >= v[1] and absX <= v[1] + v[3] and absY >= v[2] and absY <= v[2] + v[4] then
                activeButton = k
                break
            end
        end
    end
end

function onClientClick(button, state)
	if not isInputDisabled() then
		if button == "left" and state == "down" then
			if activeButton then
				local details = split(activeButton, ":")

				if details[1] == "button" then
					if details[2] == "login" then
						if activePage == "register" then
							inputDisabled = 1
							initAnimation("inputAlphaMul", true, {1, 0, 0}, {0, 0, 0}, 500, "Linear", function()
								activePage = "login"
								initAnimation("inputAlphaMul", true, {0, 0, 0}, {1, 0, 0}, 500, "Linear", function()
									inputDisabled = 0
								end)
							end)
						else
							if utfLen(fakeInputs.username) >= 3 then
								if utfLen(fakeInputs.password) >= 1 then
									triggerServerEvent("onLogin", localPlayer, fakeInputs.username, fakeInputs.password)

									saveLoginData(rememberMe)
								else
									print("Túl rövid a jelszó")
								end
							else
								print("Túl rövid a felhasznáálónév")
							end
						end
					elseif details[2] == "register" then
						if activePage == "login" then
							inputDisabled = 1
							initAnimation("inputAlphaMul", true, {1, 0, 0}, {0, 0, 0}, 500, "Linear", function()
								activePage = "register"
								initAnimation("inputAlphaMul", true, {0, 0, 0}, {1, 0, 0}, 500, "Linear", function()
									inputDisabled = 0
								end)
							end)
						else
							if utfLen(fakeInputs.username) >= 3 then
								if utfLen(fakeInputs.password) >= 8 and utfLen(fakeInputs.password2) >= 8 then
									triggerServerEvent("doRegisterS", localPlayer, localPlayer, fakeInputs.username, fakeInputs.password, fakeInputs.password2, fakeInputs.email)
								else
									print("Túl rövid a jelszó")
								end
							else
								print("Túl rövid a felhasznáálónév")
							end
						end
					elseif details[2] == "guest" then
						triggerEvent("hideLogin", source)
					end
				elseif details[1] == "lang" then
					print(details[2])
					setElementData(localPlayer, "player.language", details[2])
				elseif details[1] == "checkbox" then
					if details[2] == "rememberMe" then
						rememberMe = not rememberMe
					end
				elseif details[1] == "fakeInput" then
					activeFakeInput = details[2]
				end
			end
		end
	end
end

addEvent("onLoginSuccess", true)
addEventHandler("onLoginSuccess", root, function ()
	isLoginFailed = false
	triggerEvent("hideLogin", source)
end)

addEvent("onLoginFail", true)
addEventHandler("onLoginFail", root, function ()
	isLoginFailed = true
end)

function saveLoginData(state) 
	if state then
		if fileExists("login.dat") then
			fileDelete("login.dat")
		end

		local saveData = {
			username = fakeInputs.username,
			password = fakeInputs.password,
		}

		local loginData = fileCreate("login.dat")
		fileWrite(loginData, encodeString("tea", toJSON(saveData), { key = "!|_GreenGamingDatFile_Key_|!"}))
		fileClose(loginData)
	else
		if fileExists("login.dat") then
			fileDelete("login.dat")
		end
	end
end

	
function loadLoginData() 
	if fileExists("login.dat") then
		local loginData = fileOpen("login.dat")

		if loginData then
			local loadedData = fileRead(loginData, fileGetSize(loginData))

			if loadedData then
				loadedData = fromJSON(decodeString("tea", loadedData, { key = "!|_GreenGamingDatFile_Key_|!"}))
			end

			fileClose(loginData)

			if loadedData then
				fakeInputs.username = loadedData.username
				fakeInputs.password = loadedData.password

				rememberMe = true
			end
		end	
	end
end

function onClientCharacter(character)
	if activeFakeInput then
		if not isInputDisabled() then
			if string.find(character, "[a-zA-Z0-9.-_@]") or character == "-" or character == "*" or character == "!" then
				if activeFakeInput == "username" then
					if utfLen(fakeInputs.username) <= 20 then
						fakeInputs.username = fakeInputs.username .. character
					end
				elseif activeFakeInput == "password" or activeFakeInput == "password2" then
					if utfLen(fakeInputs[activeFakeInput]) <= 25 then
						fakeInputs[activeFakeInput] = fakeInputs[activeFakeInput] .. character
					end
				elseif activeFakeInput == "email" then
					if utfLen(fakeInputs.email) <= 48 then
						fakeInputs.email = fakeInputs.email .. character
					end
				end
			end
		end
	end
end

function onClientKey(key, press)
	if key ~= "escape" then
		cancelEvent()
	end

	if press then
		if key == "tab" then
			if not isInputDisabled() then
				if activeFakeInput == "username" then
					activeFakeInput = "password"
				else
					activeFakeInput = "username"
				end
			end
		elseif key == "enter" then
			print("Login with:")
		end
	end
end

function isInputDisabled()
	return (inputDisabled or 0) > 0
end


function initAnimation(id, storeVal, startVal, endVal, time, easing, compFunction, args)
    if not storeVal then
        animations[id] = {}
    end

    if not animations[id] then
        animations[id] = {}
    end

    animations[id].startValue = startVal
    animations[id].endValue = endVal
    animations[id].startTick = getTickCount()
    animations[id].endTick = animations[id].startTick + (time or 3000)
    animations[id].easingType = easing
    animations[id].completeFunction = compFunction
    animations[id].functionArgs = args or {}

    animations[id].currentValue = storeVal and animations[id].currentValue or {0, 0, 0}
    animations[id].completed = false
end

function getAnimationValue(id)
	if animations[id] then
		return animations[id].currentValue
	end

	return {0, 0, 0}
end

function setAnimationValue(id, val)
    animations[id].currentValue = val 
end


function drawButton(id, text, x, y, w, h, textColor, btnColor, highlightColor, cornerImage, fontSize, font)
	local highlightColor = highlightColor or btnColor
	local cornerImage = cornerImage or assets.images.circle
	local font = font or "default" 

	dxDrawRoundedRectangle("horizontal", x, y, w, h, cornerImage, activeButton == "button:" .. id and highlightColor or btnColor, true)
	dxDrawText(text, x, y, w + x, h + y, textColor, fontSize, font, "center", "center", false, false, true)

	buttons["button:" .. id] = {x, y, w, h}
end

function drawFakeInput(inputName, placeholder, icon, font, scale, x, y, sx, sy)
    local inputPaddingX = 10
    local inputPaddingY = 15
    local inputIconSize = 26

	if not inputName then
		return
	end

	if not fakeInputs[inputName] then
		fakeInputs[inputName] = ""
	end

	local alpha = 0
	if getAnimationValue("inputAlphaMul")[1] then
		alpha = getAnimationValue("inputAlphaMul")[1]
	end

	local inputColor = tocolor(50, 50, 50, 255 * alpha)
	local iconColor = tocolor(125, 125, 125, 255 * alpha)
	local textColor = iconColor
	local inputText = placeholder or ""
	local caretVisible = false

	if activeFakeInput == inputName then
		local currentTick = getTickCount()

		caretVisible = math.abs(currentTick % 750 - 375) / 375 > 0.5
		inputText = fakeInputs[inputName]

		if maskedFakeInputs[inputName] then
			inputText = string.rep("*", utf8.len(inputText))
		end

		if getKeyState("backspace") then
			if currentTick > backspaceTick then
				fakeInputs[inputName] = utf8.sub(fakeInputs[inputName], 1, -2)
				backspaceTick = currentTick + 120
			end
		end

		inputColor = tocolor(60, 60, 60, 255 * alpha)
		iconColor = tocolor(11, 180, 25, 255 * alpha)
		textColor = tocolor(255, 255, 255, 255 * alpha)
	else
		if utf8.len(fakeInputs[inputName]) > 0 then
			inputText = fakeInputs[inputName]

			if maskedFakeInputs[inputName] then
				inputText = string.rep("*", utf8.len(inputText))
			end
		end

		if activeButton == "fakeInput:" .. inputName then
			inputColor = tocolor(55, 55, 55, 255 * alpha)
			iconColor = tocolor(165, 165, 165, 255 * alpha)
			textColor = iconColor
		end
	end

	dxDrawRoundedRectangle("horizontal", x, y, sx, sy, assets.images.circle, inputColor, true)

	local fitScale = getFitFontScale(inputText, scale, font, sx - inputPaddingX - inputIconSize * 2)
	local x2 = x + inputPaddingX

	dxDrawImage(math.floor(x2), math.floor(y + (sy - inputIconSize) / 2), inputIconSize, inputIconSize, icon, 0, 0, 0, iconColor, true)

	x2 = x2 + inputPaddingX + inputIconSize

	dxDrawText(inputText, x2, y, 0, y + sy, textColor, fitScale, font, "left", "center", false, false, true)

	if caretVisible then
		local textWidth = dxGetTextWidth(inputText, fitScale, font)
		local caretHeight = sy * 0.5

		dxDrawRectangle(math.min(x2 + textWidth, x2 + sx) + 1, y + (sy - caretHeight) / 2, 1, caretHeight, textColor, true)
	end

	buttons["fakeInput:" .. inputName] = {x, y, sx, sy}
end

function getFitFontScale(text, scale, font, maxwidth)
	local sum = scale
	while true do
		if dxGetTextWidth(text, sum, font) > maxwidth then
			sum = sum - 0.01
		else
			break
		end
	end
	return sum
end

function dxDrawRoundedRectangle(alignment, x, y, width, height, cornerImage, ...)
	if not (alignment and x and y and width and height and cornerImage) then
		return
	end

	if alignment == "horizontal" then
		if width < height then
			width = height
		end

		if isElement(cornerImage) then
			dxDrawImageSection(x, y, height / 2, height, 0, 0, 400, 800, cornerImage, 0, 0, 0, ...)
			dxDrawImageSection(x + height / 2, y, width - height, height, 400, 0, 1, 800, cornerImage, 0, 0, 0, ...)
			dxDrawImageSection(x + width - height / 2, y, height / 2, height, 400, 0, 400, 800, cornerImage, 0, 0, 0, ...)
		else
			dxDrawRectangle(x, y, width, height, ...)
		end
	end

	if alignment == "vertical" then
		if height < width then
			height = width
		end

		if isElement(cornerImage) then
			dxDrawImageSection(x, y, width, width / 2, 0, 0, 800, 400, cornerImage, 0, 0, 0, ...)
			dxDrawImageSection(x, y + width / 2, width, height - width, 0, 400, 800, 1, cornerImage, 0, 0, 0, ...)
			dxDrawImageSection(x, y + height - width / 2, width, width / 2, 0, 400, 800, 400, cornerImage, 0, 0, 0, ...)
		else
			dxDrawRectangle(x, y, width, height, ...)
		end
	end
end

function dxDrawRoundedCornersRectangle(alignment, cornerSize, x, y, width, height, cornerImage, ...)
	if not (alignment and cornerSize and x and y and width and height and cornerImage) then
		return
	end

	if width < cornerSize * 2 then
		width = cornerSize * 2
	end

	if height < cornerSize * 2 then
		height = cornerSize * 2
	end

	if not isElement(cornerImage) then
		dxDrawRectangle(x, y, width, height, ...)
		return
	end

	if alignment == "full" or alignment == "top" then
		dxDrawImage(x, y, cornerSize, cornerSize, cornerImage, 0, 0, 0, ...)
		dxDrawImage(x + cornerSize + (width - cornerSize * 2), y, cornerSize, cornerSize, cornerImage, 90, 0, 0, ...)
		dxDrawRectangle(x + cornerSize, y, width - cornerSize * 2, cornerSize, ...)
	end

	if alignment == "top" then
		dxDrawRectangle(x, y + cornerSize, width, height - cornerSize, ...)
	end

	if alignment == "full" or alignment == "bottom" then
		dxDrawImage(x, y + height - cornerSize, cornerSize, cornerSize, cornerImage, 270, 0, 0, ...)
		dxDrawImage(x + cornerSize + (width - cornerSize * 2), y + height - cornerSize, cornerSize, cornerSize, cornerImage, 180, 0, 0, ...)
		dxDrawRectangle(x + cornerSize, y + height - cornerSize, width - cornerSize * 2, cornerSize, ...)
	end

	if alignment == "bottom" then
		dxDrawRectangle(x, y, width, height - cornerSize, ...)
	end

	if alignment == "full" then
		dxDrawRectangle(x, y + cornerSize, width, height - cornerSize * 2, ...)
	end
end

