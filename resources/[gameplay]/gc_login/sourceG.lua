languageStrings = {
    en = {
        ["render.input.username"] = "Username",
        ["render.input.password"] = "Password",
        ["render.input.password2"] = "Password again",
        ["render.input.email"] = "Email",
        ["render.input.rememberme"] = "Remember me",

        ["render.button.login"] = "Login",
		["render.button.register"] = "Register",
		["render.button.guest"] = "Play as Guest",

		["notification.login.success"] = "You have successfully logged in",
		["notification.login.wronguser"] = "The user does not exist or you have entered incorrect information",
		["notification.login.ban"] = "You are banned from the server"
    },
	nl = {
		["render.input.username"] = "Gebruikersnaam",
		["render.input.password"] = "Wachtwoord",
		["render.input.password2"] = "Herhaal wachtwoord",
		["render.input.email"] = "Email",
		["render.input.rememberme"] = "Onthoudt mij",

		["render.button.login"] = "Inloggen",
		["render.button.register"] = "Registreer",
		["render.button.guest"] = "Speel als gast",

		["notification.login.success"] = "Je bent succesvol ingelogd",
		["notification.login.wronguser"] = "Gebruiker bestaat niet of je hebt onjuiste gegevens ingevuld",
		["notification.login.ban"] = "Jij bent verbannen van de server",
	},
	de = {
		["render.input.username"] = "Nutzername",
		["render.input.password"] = "Passwort",
		["render.input.password2"] = "Passwort nochmal",
		["render.input.email"] = "Email",
		["render.input.rememberme"] = "Mich erinnern",

		["render.button.login"] = "Anmeldung",
		["render.button.register"] = "registrieren",
		["render.button.guest"] = "Spiele as Gast",

		["notification.login.success"] = "Sie haben sich erfolgreich angemeldet",
		["notification.login.wronguser"] = "Der Benutzer existiert nicht oder Sie haben falsche Informationen eingegeben",
		["notification.login.ban"] = "Sie sind vom Server ausgeschlossen",
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
        ["render.input.username"] = "Kullanıcı adı",
        ["render.input.password"] = "Şifre",
        ["render.input.password2"] = "Tekrardan şifre",
        ["render.input.email"] = "E-posta",
        ["render.input.rememberme"] = "Beni hatırla",

        ["render.button.login"] = "Giriş yap",
        ["render.button.register"] = "Kaydol",
        ["render.button.guest"] = "Misafir olarak oyna",

        ["notification.login.success"] = "Başarıyla giriş yaptınız.",
        ["notification.login.wronguser"] = "Böyle bir kullanıcı yok ya da yanlış bilgi girdiniz",
        ["notification.login.ban"] = "Sunucudan yasaklandınız"
    },
	ru = {
		["render.input.username"] = "Имя пользователя",
        ["render.input.password"] = "Пароль",
        ["render.input.password2"] = "Повторите пароль",
        ["render.input.email"] = "Электронная почта",
        ["render.input.rememberme"] = "Запомнить меня",

        ["render.button.login"] = "Войти",
        ["render.button.register"] = "Зарегистрироваться",
        ["render.button.guest"] = "Продолжить как гость",

        ["notification.login.success"] = "Вход выполнен успешно",
        ["notification.login.wronguser"] = "Такое имя пользователя не существует или Вы ввели неверную информацию",
        ["notification.login.ban"] = "Вы были забанены"
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