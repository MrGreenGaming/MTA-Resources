languageStrings = {
    en = {
        ["render.input.username"] = "Username",
        ["render.input.password"] = "Password",
        ["render.input.password2"] = "Password again",
        ["render.input.email"] = "Email",
        ["render.input.rememberme"] = "Remember me",
        ["render.button.login"] = "Login",
		["render.button.register"] = "Register",

		["notification.login.success"] = "You have successfully logged in",
		["notification.login.wronguser"] = "The user does not exist or you have entered incorrect information",
		["notification.login.ban"] = "You are banned from the server"
    },
    pl = {
        ["render.input.username"] = "Nazwa użytkownika",
        ["render.input.password"] = "Hasło",
        ["render.input.password2"] = "Powtórz hasło",
        ["render.input.email"] = "Adres email",
        ["render.input.rememberme"] = "Zapamiętaj mnie",
        ["render.button.login"] = "Zaloguj się",
        ["render.button.register"] = "Zarejestruj się",
    },
    hu = {
		["render.input.username"] = "Felhasználónév",
        ["render.input.password"] = "Jelszó",
        ["render.input.password2"] = "Jelszó újra",
        ["render.input.email"] = "Email",
        ["render.input.rememberme"] = "Adatok megjegyzése",
        ["render.button.login"] = "Bejelentkezés",
		["render.button.register"] = "Regisztráció",
		
		["notification.login.success"] = "Sikeresen bejelentkeztél",
		["notification.login.wronguser"] = "A megadott felhasználó nem létezik, vagy ",
		["notification.login.ban"] = "A felhasználód ki van tiltva"
    },
    tr = {
        ["render.input.username"] = "Kullanıcı Adı",
        ["render.input.password"] = "Şifre",
        ["render.input.password2"] = "Tekrar Şifre",
        ["render.input.email"] = "E-Posta",
        ["render.input.rememberme"] = "Beni Hatırla",
        ["render.button.login"] = "Giriş Yap",
        ["render.button.register"] = "Kayıt Ol",
    }
}

if localPlayer then
	localizedStrings = {}

	local function initializeLocalization()
		local language = getElementData(localPlayer, "player.language") or "en"

		if languageStrings[language] then
			localizedStrings = {}

			for k, v in pairs(languageStrings[language]) do
				localizedStrings[k] = v
			end
		end
	end

	addEventHandler("onClientResourceStart", resourceRoot, initializeLocalization)
	addEventHandler("onClientElementDataChange", localPlayer, function (dataName)
		if dataName == "player.language" then
			initializeLocalization()
		end
	end)
end

function getLocalizedText(playerElement, stringCode, ...)
	if isElement(playerElement) then
		if stringCode then
			local language = getElementData(playerElement, "player.language") or "en"

			if languageStrings[language] then
				if languageStrings[language][stringCode] then
					if (...) then
						return string.format(languageStrings[language][stringCode], ...)
					else
						return languageStrings[language][stringCode]
					end
				else
					return "Undefined localization: " .. stringCode .. " (" .. language .. ")"
				end
			else
				return "Undefined language: " .. language
			end
		else
			return "String code not found"
		end
	end
end