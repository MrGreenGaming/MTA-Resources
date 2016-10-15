--------------------------------------------------------
-- Name: irc                                          --
-- Author: MCvarial <MCvarial@gmail.com>              --
-- Date: 02-05-2010                                   --
--------------------------------------------------------

----------------------------------------------
-- Hook for showing IRC commands to discord --
----------------------------------------------

commands = {}
usingDiscordCommand = false
discordNick = ""
discordRoles = {}

function addIRCCommandHandler_ (cmd, fn)
	commands[cmd] = fn
	return addIRCCommandHandler(cmd, fn)
end
local addIRCCommandHandler = addIRCCommandHandler_

-- replaced functions to output to discord if usingDiscordCommand is set
local function ircSay (...)
	if (usingDiscordCommand) then
		exports.discord:send("chat.message.action", { author = ">", text = removemIRCChars(({...})[2]) })
	else
		return func_ircSay(unpack{...})
	end
end

local function ircNotice (...)
	if (usingDiscordCommand) then
		exports.discord:send("chat.message.action", { author = ">", text = removemIRCChars(({...})[2]) })
	else
		return func_ircNotice(unpack{...})
	end
end

local function outputIRC (...)
	if (usingDiscordCommand) then
		exports.discord:send("chat.message.action", { author = ">", text = removemIRCChars(({...})[1]) })
	else
		return func_outputIRC(unpack{...})
	end
end

local function ircIsEchoChannel (...)
	if (usingDiscordCommand) then
		return true
	else
		return func_ircIsEchoChannel(unpack{...})
	end
end

local function ircIsCommandEchoChannelOnly (...)
	if (usingDiscordCommand) then
		return true
	else
		return func_ircIsCommandEchoChannelOnly(unpack{...})
	end
end

local function ircGetUserNick (...)
	if (usingDiscordCommand) then
		return discordNick
	else
		return func_ircGetUserNick(unpack{...})
	end
end

local function ircGetUserLevel (...)
	if (usingDiscordCommand) then
		for _, role in pairs(discordRoles) do
			if role == "Admins" then
				return 6
			end
		end
		return 0
	else
		return func_ircGetUserLevel(unpack{...})
	end
end

function removemIRCChars(text)
	return text:gsub("%d%d?", "")
end

addEvent("onDiscordUserCommand")
addEventHandler("onDiscordUserCommand", root, function(author, message)
	usingDiscordCommand = false
	local cmd = message.command
	if not (cmd and type(cmd) == "string" and #cmd > 0) then
		return
	end
	
	
	
	-- local outputIRC_ = outputIRC
	-- local outputIRC = function(text)
		-- exports.discord:send("chat.message.action", { author = ">", text = text })
	-- end
	if commands['!' .. cmd] then
		usingDiscordCommand = true
		discordNick = author.name or "Noname"
		discordRoles = author.roles or {}
		-- setTimer(function() usingDiscordCommand = false end, 50, 1)
		if (tonumber(ircGetCommandLevel(cmd) or 6)) <= (tonumber(ircGetUserLevel()) or 0) then
			commands['!' .. cmd](server, channel, user, cmd, unpack(message.params))
		end
		usingDiscordCommand = false
	else
		exports.discord:send("chat.message.action", { author = ">", text = "That command does not exist!" })
	end
end)
------------------------------------
-- Echo
------------------------------------
local cc2cid = {[false]=0,["AP"]=1,["EU"]=2,["AD"]=3,["AE"]=4,["AF"]=5,["AG"]=6,["AI"]=7,["AL"]=8,["AM"]=9,["AN"]=10,["AO"]=11,["AQ"]=12,["AR"]=13,["AS"]=14,["AT"]=15,["AU"]=16,["AW"]=17,["AZ"]=18,["BA"]=19,["BB"]=20,["BD"]=21,["BE"]=22,["BF"]=23,["BG"]=24,["BH"]=25,["BI"]=26,["BJ"]=27,["BM"]=28,["BN"]=29,["BO"]=30,["BR"]=31,["BS"]=32,["BT"]=33,["BV"]=34,["BW"]=35,["BY"]=36,["BZ"]=37,["CA"]=38,["CC"]=39,["CD"]=40,["CF"]=41,["CG"]=42,["CH"]=43,["CI"]=44,["CK"]=45,["CL"]=46,["CM"]=47,["CN"]=48,["CO"]=49,["CR"]=50,["CU"]=51,["CV"]=52,["CX"]=53,["CY"]=54,["CZ"]=55,["DE"]=56,["DJ"]=57,["DK"]=58,["DM"]=59,["DO"]=60,["DZ"]=61,["EC"]=62,["EE"]=63,["EG"]=64,["EH"]=65,["ER"]=66,["ES"]=67,["ET"]=68,["FI"]=69,["FJ"]=70,["FK"]=71,["FM"]=72,["FO"]=73,["FR"]=74,["FX"]=75,["GA"]=76,["GB"]=77,["GD"]=78,["GE"]=79,["GF"]=80,["GH"]=81,["GI"]=82,["GL"]=83,["GM"]=84,["GN"]=85,["GP"]=86,["GQ"]=87,["GR"]=88,["GS"]=89,["GT"]=90,["GU"]=91,["GW"]=92,["GY"]=93,["HK"]=94,["HM"]=95,["HN"]=96,["HR"]=97,["HT"]=98,["HU"]=99,["ID"]=100,["IE"]=101,["IL"]=102,["IN"]=103,["IO"]=104,["IQ"]=105,["IR"]=106,["IS"]=107,["IT"]=108,["JM"]=109,["JO"]=110,["JP"]=111,["KE"]=112,["KG"]=113,["KH"]=114,["KI"]=115,["KM"]=116,["KN"]=117,["KP"]=118,["KR"]=119,["KW"]=120,["KY"]=121,["KZ"]=122,["LA"]=123,["LB"]=124,["LC"]=125,["LI"]=126,["LK"]=127,["LR"]=128,["LS"]=129,["LT"]=130,["LU"]=131,["LV"]=132,["LY"]=133,["MA"]=134,["MC"]=135,["MD"]=136,["MG"]=137,["MH"]=138,["MK"]=139,["ML"]=140,["MM"]=141,["MN"]=142,["MO"]=143,["MP"]=144,["MQ"]=145,["MR"]=146,["MS"]=147,["MT"]=148,["MU"]=149,["MV"]=150,["MW"]=151,["MX"]=152,["MY"]=153,["MZ"]=154,["NA"]=155,["NC"]=156,["NE"]=157,["NF"]=158,["NG"]=159,["NI"]=160,["NL"]=161,["NO"]=162,["NP"]=163,["NR"]=164,["NU"]=165,["NZ"]=166,["OM"]=167,["PA"]=168,["PE"]=169,["PF"]=170,["PG"]=171,["PH"]=172,["PK"]=173,["PL"]=174,["PM"]=175,["PN"]=176,["PR"]=177,["PS"]=178,["PT"]=179,["PW"]=180,["PY"]=181,["QA"]=182,["RE"]=183,["RO"]=184,["RU"]=185,["RW"]=186,["SA"]=187,["SB"]=188,["SC"]=189,["SD"]=190,["SE"]=191,["SG"]=192,["SH"]=193,["SI"]=194,["SJ"]=195,["SK"]=196,["SL"]=197,["SM"]=198,["SN"]=199,["SO"]=200,["SR"]=201,["ST"]=202,["SV"]=203,["SY"]=204,["SZ"]=205,["TC"]=206,["TD"]=207,["TF"]=208,["TG"]=209,["TH"]=210,["TJ"]=211,["TK"]=212,["TM"]=213,["TN"]=214,["TO"]=215,["TL"]=216,["TR"]=217,["TT"]=218,["TV"]=219,["TW"]=220,["TZ"]=221,["UA"]=222,["UG"]=223,["UM"]=224,["US"]=225,["UY"]=226,["UZ"]=227,["VA"]=228,["VC"]=229,["VE"]=230,["VG"]=231,["VI"]=232,["VN"]=233,["VU"]=234,["WF"]=235,["WS"]=236,["YE"]=237,["YT"]=238,["RS"]=239,["ZA"]=240,["ZM"]=241,["ME"]=242,["ZW"]=243,["A1"]=244,["A2"]=245,["O1"]=246,["AX"]=247,["GG"]=248,["IM"]=249,["JE"]=250,["BL"]=251,["MF"]=252}
local cid2countryname = {"Asia/Pacific Region","Europe","Andorra","United Arab Emirates","Afghanistan","Antigua and Barbuda","Anguilla","Albania","Armenia","Netherlands Antilles","Angola","Antarctica","Argentina","American Samoa","Austria","Australia","Aruba","Azerbaijan","Bosnia and Herzegovina","Barbados","Bangladesh","Belgium","Burkina Faso","Bulgaria","Bahrain","Burundi","Benin","Bermuda","Brunei Darussalam","Bolivia","Brazil","Bahamas","Bhutan","Bouvet Island","Botswana","Belarus","Belize","Canada","Cocos (Keeling) Islands","Democratic Republic of the Congo","Central African Republic","Congo","Switzerland","Cote D'Ivoire","Cook Islands","Chile","Cameroon","China","Colombia","Costa Rica","Cuba","Cape Verde","Christmas Island","Cyprus","Czech Republic","Germany","Djibouti","Denmark","Dominica","Dominican Republic","Algeria","Ecuador","Estonia","Egypt","Western Sahara","Eritrea","Spain","Ethiopia","Finland","Fiji","Falkland Islands (Malvinas)","Micronesia,Federated States of","Faroe Islands","France","France,Metropolitan","Gabon","United Kingdom","Grenada","Georgia","French Guiana","Ghana","Gibraltar","Greenland","Gambia","Guinea","Guadeloupe","Equatorial Guinea","Greece","South Georgia and the South Sandwich Islands","Guatemala","Guam","Guinea-Bissau","Guyana","Hong Kong","Heard Island and McDonald Islands","Honduras","Croatia","Haiti","Hungary","Indonesia","Ireland","Israel","India","British Indian Ocean Territory","Iraq","Iran","Iceland","Italy","Jamaica","Jordan","Japan","Kenya","Kyrgyzstan","Cambodia","Kiribati","Comoros","Saint Kitts and Nevis","North Korea","South Korea","Kuwait","Cayman Islands","Kazakhstan","Lao People's Democratic Republic","Lebanon","Saint Lucia","Liechtenstein","Sri Lanka","Liberia","Lesotho","Lithuania","Luxembourg","Latvia","Libyan Arab Jamahiriya","Morocco","Monaco","Moldova","Madagascar","Marshall Islands","Macedonia","Mali","Myanmar","Mongolia","Macau","Northern Mariana Islands","Martinique","Mauritania","Montserrat","Malta","Mauritius","Maldives","Malawi","Mexico","Malaysia","Mozambique","Namibia","New Caledonia","Niger","Norfolk Island","Nigeria","Nicaragua","Netherlands","Norway","Nepal","Nauru","Niue","New Zealand","Oman","Panama","Peru","French Polynesia","Papua New Guinea","Philippines","Pakistan","Poland","Saint Pierre and Miquelon","Pitcairn Islands","Puerto Rico","Palestinian Territory","Portugal","Palau","Paraguay","Qatar","Reunion","Romania","Russian Federation","Rwanda","Saudi Arabia","Solomon Islands","Seychelles","Sudan","Sweden","Singapore","Saint Helena","Slovenia","Svalbard and Jan Mayen","Slovakia","Sierra Leone","San Marino","Senegal","Somalia","Suriname","Sao Tome and Principe","El Salvador","Syrian Arab Republic","Swaziland","Turks and Caicos Islands","Chad","French Southern Territories","Togo","Thailand","Tajikistan","Tokelau","Turkmenistan","Tunisia","Tonga","Timor-Leste","Turkey","Trinidad and Tobago","Tuvalu","Taiwan","Tanzania","Ukraine","Uganda","United States Minor Outlying Islands","United States","Uruguay","Uzbekistan","Holy See (Vatican City State)","Saint Vincent and the Grenadines","Venezuela","Virgin Islands,British","Virgin Islands,U.S.","Vietnam","Vanuatu","Wallis and Futuna","Samoa","Yemen","Mayotte","Serbia","South Africa","Zambia","Montenegro","Zimbabwe","Anonymous Proxy","Satellite Provider","Other","Aland Islands","Guernsey","Isle of Man","Jersey","Saint Barthelemy","Saint Martin"}

handlerConnect = nil
addEventHandler('onResourceStart', getResourceRootElement(),
	function()
	handlerConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname", get("*gcshop.user"), get("*gcshop.pass"))
	end
)		

function getSerial(playername)
	--if not canScriptWork then return false end
	local cmd = ''
	local query 
	local sql
	if handlerConnect then
		cmd = "SELECT serial, ip, playername FROM serialsDB WHERE playername = ? LIMIT 1"
		query = dbQuery(handlerConnect, cmd, playername)
		sql = dbPoll(query, -1)
		if sql[1] then
			return { serial = sql[1].serial, ip = sql[1].ip }
		else return false
		end
	end	
end

function findPastNames(serial)
	local cmd = ''
	local query 
	local sql
	if handlerConnect then
		local stringOfPlayers = ""
		cmd = "SELECT serial, playername FROM serialsDB WHERE serial = ?"
		query = dbQuery(handlerConnect, cmd, serial)
		sql = dbPoll(query, -1)
		if #sql > 0 then
			for i = 1, #sql do 			
					if #stringOfPlayers == 0 then
						stringOfPlayers = sql[i].playername
					else
						stringOfPlayers = stringOfPlayers.." , "..sql[i].playername
					end			
			end		
			return stringOfPlayers 
		else return false	
		end
	else return false	
	end
end

g_PlayerTickcount = {}
spamTime = 4000
g_PlayerChatNum = {}
g_PlayerMuted = {}
g_PlayerTimer = {}
local updates = {}

function addIRCCommands ()

function say (server,channel,user,command,...)
	if g_PlayerMuted[user] == true or exports.gus:chatDisabled() then return end
    local message = table.concat({...}," ")
    if not message then ircNotice(user,"syntax is !s <message>") return end
	if g_PlayerTickcount[user] then
		if getTickCount() - g_PlayerTickcount[user] > 4000 then
			g_PlayerChatNum[user] = 1
			g_PlayerTickcount[user] = getTickCount()
		else
			g_PlayerChatNum[user] = g_PlayerChatNum[user] + 1
			if g_PlayerChatNum[user] > 3 then
				--g_PlayerTickcount[user] = getTickCount()
				ircNotice(user,"Please do not spam.")
				ircNotice(user,"Muted from !say for 30 seconds.")
				g_PlayerMuted[user] = true
				g_PlayerTimer[user] = setTimer(function(player) g_PlayerMuted[player] = false ircNotice(player, "Unmuted.") end, 30000, 1, user)
				return
			end
		end	
	else	
		g_PlayerTickcount[user] = getTickCount()
		g_PlayerChatNum[user] = 1
		g_PlayerMuted[user] = false
	end
	outputChatBox("* "..ircGetUserNick(user).."[IRC]: "..message,root,255,168,0)
	outputIRC("07* "..ircGetUserNick(user).."[IRC]: "..message)
	triggerEvent('onInterchatMessage', resourceRoot, "IRC", ircGetUserNick(user), message)
	if command ~= 'say' then
		outputIRC("You can speak ingame without using !say or !s now, messages are directly shown ingame")
	end
end
addIRCCommandHandler("!say",say)
addIRCCommandHandler("!s",say)
addIRCCommandHandler("!m",say)

function ircGetSerial(server,channel,user,command,par)
	if not par then ircNotice(user, "State the full name of a player") return end
	par = string.gsub (par, '#%x%x%x%x%x%x', '' )
	local theInfo = getSerial(par)
	if theInfo then
			local theSerial = theInfo.serial
	local theIP = theInfo.ip
		if theIP == nil then
			ircNotice(user,"Most recent used serial for "..par.." is: "..theSerial)
		else
			ircNotice(user,"Most recent used serial and IP for "..par.." is: "..theSerial.." and "..theIP)
		end	
	else 	
		ircNotice(user,"No match found")
	end	
end

addIRCCommandHandler("!serial", ircGetSerial)

function ircGetBanDetails(server,channel,user,command,banType, par) 
	if banType == nil then ircNotice(user,"Usage: '!isBan <type> <who>'  where <type> can be serial/nick/ip/reason") return end
	if par == nil then ircNotice(user,"Usage: '!isBan <type> <who>'  Need a 3rd argument") return end
	local searchBan = nil
	local count = 0
	if banType == 'serial' then searchBan = getBanSerial 
	elseif banType == 'ip' then searchBan = getBanIP
	elseif banType == 'nick' then searchBan = getBanNick
	elseif banType == 'reason' then searchBan = getBanReason
	end
	if searchBan == nil then ircNotice(user,"Usage: '!isBan <type> <who>'  where <type> can be serial/nick/ip/reason") return end
	for _ , ban in ipairs(getBans()) do 
		local banFound = string.lower(tostring(searchBan(ban)))
		if string.find(banFound, string.lower(par)) then
			count = count + 1
			if count > 7 then ircNotice(user,"****************Please narrow down your search. Too many results to display****************") return end
			local bNick = getBanNick(ban)
			local bAdmin = getBanAdmin(ban)
			local bIP = getBanIP(ban)
			local bReason = getBanReason(ban)
			local bTime = getBanTime(ban)
			local bSerial = getBanSerial(ban)
			local bUsername = getBanUsername(ban)
			local bUnbanTime = getUnbanTime(ban)
			local bBanTime = getBanTime(ban)
			local bExpire
			local toOutput = 'Ban result('..count.. ') found. Name '..(not bNick and 'N/A ' or '\''..bNick..'\'').. ' banned by Admin ' .. (not bAdmin and 'N/A' or '\''..bAdmin..'\'') .. ' for reason of ' .. (not bReason and 'N/A' or '\''..bReason..'\'') .. ' having IP ' .. (not bIP and 'N/A' or '\''..bIP..'\'') .. ' and serial ' .. (not bSerial and 'N/A' or '\''..bSerial..'\'')
			if bUnbanTime and bBanTime then
				bExpire = bUnbanTime - bBanTime
				if bExpire < 0 then
					bExpire = 'never'
					toOutput = toOutput..' Expire date: \''..bExpire..'\''
				else
					bExpire = tostring(bExpire)
					toOutput = toOutput..' Expire date: \''..bExpire..'\' seconds'
				end
			end	
			ircNotice(user,toOutput)
		end
	end
	if count == 0 then
		ircNotice(user, par..' is not banned.')
	end
end

addIRCCommandHandler("!isBan", ircGetBanDetails)

function displayVersion(server,channel,user,command,par)
	local allVersion = ""
	for _, j in ipairs(getElementsByType('player')) do
		local stringVersion = getPlayerVersion(j)
		stringVersion = string.sub(stringVersion,10,13)
		allVersion = allVersion..", "..getPlayerName(j).."(".."r"..stringVersion..")"
	end
	ircNotice(user, allVersion)	
end

addIRCCommandHandler("!version", displayVersion)

addIRCCommandHandler("!names",
function(server,channel,user,command,par)
	if not par then ircNotice(user,"Input a player's name to get his past nicknames.") return end
	if (#par == 32) then
		local pastNames = findPastNames(par)
		if pastNames then
			ircNotice(user,"Names found: "..pastNames)
		end	
	else
		local playerElement = getPlayerFromPartialName(par)
		if not playerElement then ircNotice(user,"State a player's partial name.") return end
		local playerSerial = getPlayerSerial(playerElement)
		local pastNames = findPastNames(playerSerial)
		if pastNames then
			ircNotice(user, "Names found: "..pastNames)
		end
	end
end
)

addIRCCommandHandler("!addban",
function(server,channel,user,command,...)
	if not (arg[1]) then ircNotice(user, "State the player's full name (no color codes).") return end
	local banPlayerName = string.gsub (arg[1], '#%x%x%x%x%x%x', '' )
	local theInfo = getSerial(banPlayerName)
	if theInfo then
		local theSerial = theInfo.serial
		local theIP = theInfo.ip
		local reason = "(Nick: "..banPlayerName..") - No reason specified"
		if (#arg>1) then
			reason = ""
			arg[1] = "(Nick: "..banPlayerName..") - "
			reason = table.concat(arg," ")
		end
		theBan = addBan(theIP, nil, theSerial, player, reason, 0)
		if not theBan then ircNotice(user, "An error has occured. Can't ban player.")
		else 
			outputIRC(banPlayerName.." has been banned by "..ircGetUserNick(user))	
		end
	else ircNotice(user, "No player match. Try again.")	
	end
end
)

addIRCCommandHandler("!seen",
function(server, channel, user,command, par)
	if not par then ircNotice(user, "State the player's full name.") return end
	if getPlayerFromName(par) then outputIRC("07* "..par.." is online right now.") return end
	par = string.gsub (par, '#%x%x%x%x%x%x', '' )
	local cmd = ''
	local query 
	local sql
	if handlerConnect then
		cmd = "SELECT date, playername FROM serialsDB WHERE playername = ?"
		query = dbQuery(handlerConnect, cmd, par)
		sql = dbPoll(query, -1)
		if #sql > 0 then
			local name = sql[1].playername
			local date = sql[1].date
			if date == nil then 
				outputIRC("No database entry available yet for "..name)
			else
				outputIRC("07* "..name.." was last seen on: "..date.." (GMT time)")
			end
		else outputIRC(par.." was never seen online.")
		end	
	end	
end
)

addIRCCommandHandler("!admins",
function(server,channel, user,command,par)
	local admins = {}
	local adminString = ""
	local k = 0
	local players = getElementsByType('player')
	for i,j in ipairs(players) do 
		if hasObjectPermissionTo(j, "function.banPlayer", false) then
			k = k + 1
			admins[k] = getPlayerName(j):gsub('#%x%x%x%x%x%x', '')
		end
	end
	if #admins > 0 then	
		adminString = table.concat(admins, " , ")
		outputIRC("07* Online admins: "..adminString)
	else outputIRC("07* No online admins")
	end
end
)

addIRCCommandHandler("!redirect",
function(server,channel, user,command,arg1, arg2, arg3, arg4)
	if not arg1 then ircNotice(user,"Syntax: !redirect <name> <server> <port> <password> Note: Password and port arguments are optional. Port:22003") return end
	if not arg2 then ircNotice(user,"Syntax: !redirect <name> <server> <port> <password> Note: Password and port arguments are optional. Port:22003") return end
	if not arg3 then 
		arg3 = "22003"
	end	
	local player = getPlayerFromPartialName(arg1)
	if player then
		if arg4 then
			redirectPlayer(player, arg2,arg3,arg4)
		else
			redirectPlayer(player, arg2, arg3)
		end	
	else 
		ircNotice(user,"No player found")
	end	
end
)

function country(server,channel,user,command,name)
		if not name then ircSay(channel,"12* "..'/country <partial name>') return end
	local arg = getPlayerFromPartialName(name)
	if arg then
		local country = getElementData(arg, 'country')
			if country == '' then
				ircSay(channel,"12* "..'Unknown country for player.')
			else
				if getElementData(arg, 'fullCountryName') then
					ircSay(channel,"12* "..string.gsub(getPlayerName(arg), '#%x%x%x%x%x%x', '' ).."'s country is: "..getElementData(arg, 'fullCountryName'))
				else
					if cc2cid[country] then
						if cid2countryname[cc2cid[country]] then
							ircSay(channel,"12* "..string.gsub(getPlayerName(arg), '#%x%x%x%x%x%x', '' ).."'s country is: "..cid2countryname[cc2cid[country]])
						else
							ircSay(channel,"12* "..'Unknown country for player.')
						end
					else
						ircSay(channel,"12* "..'Unknown country for player.')
					end
				end
			end
	else
		ircSay(channel,"12* "..'Player inexistent.')
	end	
end
addIRCCommandHandler("!c", country)
addIRCCommandHandler("!country", country)

addIRCCommandHandler("!map",
	function(server,channel,user,command,name)
		local tmp = getResourceFromName("mapmanager")
		if tmp then
            local map
            map = call(tmp, "getRunningGamemodeMap")
			map = getResourceInfo(map, "name")
			ircSay(channel,"12* Current map: "..map)
		end
	end
)

addIRCCommandHandler("!pm",
        function (server,channel,user,command,name,...)
                local message = table.concat({...}," ")
                if not name then ircNotice(user,"syntax is !pm <name> <message>") return end
                if not message then ircNotice(user,"syntax is !pm <name> <message>") return end
                local player = getPlayerFromPartialName(name)
                if player then
                        outputChatBox("* PM from "..ircGetUserNick(user).." on irc: "..message,player,255,168,0)
                        ircNotice(user,"Your pm has been send to "..getPlayerName(player))
                else
                        ircNotice(user,"'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!kick",
        function (server,channel,user,command,name,...)
                if not name then ircNotice(user,"syntax is !kick <name> <reason>") return end
                local reason = table.concat({...}," ") or ""
                local player = getPlayerFromPartialName(name)
                if player then
                        local nick = getPlayerName(player)
                        kickPlayer(player,reason)
                        outputChatBox("* "..nick.." was kicked from the game by "..ircGetUserNick(user).." ("..reason..")",root,255,100,100)
                else
                        ircNotice(user,"'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!ban",
        function (server,channel,user,command,name,...)
                if not name then ircNotice(user,"syntax is !ban <name> [reason] (time)") return end
                local reason = table.concat({...}," ") or ""
                local t = split(reason,40)
                local time
                if #t > 1 then
                        time = "("..t[#t]
                end
                local player = getPlayerFromPartialName(name)
                if player then
                        if time then
                                addBan(getPlayerIP(player),nil,getPlayerSerial(player),ircGetUserNick(user),reason,toMs(time)/1000)
                        else
                                addBan(getPlayerIP(player),nil,getPlayerSerial(player),ircGetUserNick(user),reason)
                        end
                else
                        ircNotice(user,"'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!mute",
        function (server,channel,user,command,name,...)
                if not name then ircNotice(user,"syntax is !mute <name> [reason] [(time)]") return end
                local reason = table.concat({...}," ") or ""
                local t = split(reason,40)
                local time
                if #t > 1 then
                        time = "("..t[#t]
                end
                local player = getPlayerFromPartialName(name)
                if player then
                        if time then
                                muteSerial(getPlayerSerial(player),reason,toMs(time))
                        end
                        setPlayerMuted(player,true)
                        if reason then
                                outputChatBox("* "..getPlayerName(player).." was muted by "..ircGetUserNick(user).." ("..reason..")",root,255,0,0)
                                ircSay(channel,"12* "..getPlayerName(player).." was muted by "..ircGetUserNick(user).." ("..reason..")")
                        else
                                outputChatBox("* "..getPlayerName(player).." was muted by "..ircGetUserNick(user),root,0,0,255)
                                ircSay(channel,"12* "..getPlayerName(player).." was muted by "..ircGetUserNick(user))
                        end
                else
                        ircNotice(user,"'"..name.."' no such player")
                end
        end
)
addIRCCommandHandler("!kill",
        function (server,channel,user,command,name,...)
                if not name then ircNotice(user,"syntax is !kill <name> [reason]") return end
                local reason = table.concat({...}," ") or ""
                local player = getPlayerFromPartialName(name)
                if player then
                        killPed(player)
                        outputChatBox("* "..getPlayerName(player).." was killed by "..ircGetUserNick(user).." ("..reason..")",root,0,0,255)
                        ircSay(channel,"12* "..getPlayerName(player).." was killed by "..ircGetUserNick(user).." ("..reason..")")
                else
                        ircNotice(user,"'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!unmute",
        function (server,channel,user,command,name,...)
                if not name then ircNotice(user,"syntax is !unmute <name>") return end
                local player = getPlayerFromPartialName(name)
                if player then
                        setPlayerMuted(player,false)
                        outputChatBox("* "..getPlayerName(player).." was unmuted by "..ircGetUserNick(user),root,0,0,255)
                        ircSay(channel,"12* "..getPlayerName(player).." was unmuted by "..ircGetUserNick(user))
                else
                        ircNotice(user,"'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!freeze",
        function (server,channel,user,command,name,...)
                if not name then ircNotice(user,"syntax is !freeze <name> [reason]") return end
                local reason = table.concat({...}," ") or ""
                local reason = table.concat({...}," ") or ""
                local t = split(reason,40)
                local time
                if #t > 1 then
                        time = "("..t[#t]
                end
                local player = getPlayerFromPartialName(name)
                if player then
                        if isPedInVehicle(player) then
                                setElementFrozen(getPedOccupiedVehicle(player),true)
                                setTimer(setElementFrozen,time,1,getPedOccupiedVehicle(player),false)
                        end
                        setElementFrozen(player,true)
                        setTimer(setElementFrozen,time,1,player,false)
                        outputChatBox("* "..getPlayerName(player).." was frozen by "..ircGetUserNick(user).." ("..reason..")",root,0,0,255)
                        ircSay(channel,"12* "..getPlayerName(player).." was frozen by "..ircGetUserNick(user).." ("..reason..")")
                else
                        ircNotice(user,"'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!unfreeze",
        function (server,channel,user,command,name)
                if not name then ircNotice(user,"syntax is !unfreeze <name>") return end
                local player = getPlayerFromPartialName(name)
                if player then
                        if isPedInVehicle(player) then
                                setElementFrozen(getPedOccupiedVehicle(player),false)
                        end
                        setElementFrozen(player,false)
                        outputChatBox("* "..getPlayerName(player).." was unfrozen by "..ircGetUserNick(user),root,0,0,255)
                        ircSay(channel,"12* "..getPlayerName(player).." was unfrozen by "..ircGetUserNick(user))
                else
                        ircNotice(user,"'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!slap",
        function (server,channel,user,command,name,hp,...)
                if not name then ircNotice(user,"syntax is !slap <name> <hp> [reason]") return end
                if not hp then ircNotice(user,"syntax is !slap <name> <hp> [reason]") return end
                local reason = table.concat({...}," ") or ""
                local player = getPlayerFromPartialName(name)
                if player then
                        setElementVelocity((getPedOccupiedVehicle(player) or player),0,0,hp*0.01)
                        setElementHealth((getPedOccupiedVehicle(player) or player),(getElementHealth((getPedOccupiedVehicle(player) or player)) - hp))
                        outputChatBox("* "..getPlayerName(player).." was slaped by "..ircGetUserNick(user).." ("..reason..")("..hp.."HP)",root,0,0,255)
                        ircSay(channel,"12* "..getPlayerName(player).." was slaped by "..ircGetUserNick(user).." ("..reason..")("..hp.."HP)")
                else
                        ircNotice(user,"'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!getip",
        function (server,channel,user,command,name)
                if not name then ircNotice(user,"syntax is !getip <name>") return end
                local player = getPlayerFromPartialName(name)
                if player then
                        ircNotice(user,getPlayerName(player).."'s IP: "..getPlayerIP(player))
                else
                        ircNotice(user,"'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!getserial",
        function (server,channel,user,command,name)
                if not name then ircNotice(user,"syntax is !getserial <name>") return end
                local player = getPlayerFromPartialName(name)
                if player then
                        ircNotice(user,getPlayerName(player).."'s Serial: "..getPlayerSerial(player))
                else
                        ircNotice(user,"'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!unban",
        function (server,channel,user,command,name)
                if not name then ircNotice(user,"syntax is !unban <name>") return end
                for i,ban in ipairs (getBans()) do
                        if getBanNick(ban) == name then
                                removeBan(ban)
                        end
                end
        end
)

addIRCCommandHandler("!unbanip",
        function (server,channel,user,command,ip)
                if not ip then ircNotice(user,"syntax is !unbanip <ip>") return end
                for i,ban in ipairs (getBans()) do
                        if getBanIP(ban) == ip then
                                removeBan(ban)
                        end
                end
        end
)

addIRCCommandHandler("!unbanserial",
        function (server,channel,user,command,serial)
                if not serial then ircNotice(user,"syntax is !unbanserial <serial>") return end
                for i,ban in ipairs (getBans()) do
                        if getBanSerial(ban) == serial then
                                removeBan(ban)
                        end
                end
        end
)

addIRCCommandHandler("!banname",
        function (server,channel,user,command,name,...)
                if not name then ircNotice(user,"syntax is !banname <name> (<reason>)") return end
                local reason = table.concat({...}," ") or ""
                local t = split(reason,40)
                local time
                if #t > 1 then
                        time = "("..t[#t]
                end
                if time then
                        addBan(nil,name,nil,ircGetUserNick(user),reason,toMs(time)/1000)
                else
                        addBan(nil,name,nil,ircGetUserNick(user),reason)
                end
        end
)

addIRCCommandHandler("!banserial",
        function (server,channel,user,command,serial,...)
                if not serial then ircNotice(user,"syntax is !banserial <name> (<reason>)") return end
                local reason = table.concat({...}," ") or ""
                local t = split(reason,40)
                local time
                if #t > 1 then
                        time = "("..t[#t]
                end
                if time then
                        addBan(nil,nil,serial,ircGetUserNick(user),reason,toMs(time)/1000)
                else
                        addBan(nil,nil,serial,ircGetUserNick(user),reason)
                end
        end
)

addIRCCommandHandler("!banip",
        function (server,channel,user,command,ip,...)
                if not ip then ircNotice(user,"syntax is !banname <name> (<reason>)") return end
                local reason = table.concat({...}," ") or ""
                local t = split(reason,40)
                local time
                if #t > 1 then
                        time = "("..t[#t]
                end
                if time then
                        addBan(ip,nil,nil,ircGetUserNick(user),reason,toMs(time)/1000)
                else
                        addBan(ip,nil,nil,ircGetUserNick(user),reason)
                end
        end
)

addIRCCommandHandler("!bans",
        function (server,channel)
                ircSay(channel,"There are "..#getBans().." bans on the server!")
        end
)

addIRCCommandHandler("!uptime",
        function (server,channel,user,command,...)
                ircNotice(user,"Hi "..ircGetUserNick(user)..", my uptime is: "..getTimeString(getTickCount()))
        end
)

function players(server,channel,user,command,name)
		if not name then
		if getPlayerCount() == 0 then
			ircSay(channel,"There are no players ingame")
		else
			local players = getElementsByType("player")
			for i,player in ipairs (players) do
				players[i] = getNameNoColor(player)
                local accName = getAccountName ( getPlayerAccount ( player ) )
                if accName and isObjectInACLGroup ("user."..accName, aclGetGroup ( "Admin" ) ) then
                    players[i] = "12"..players[i].."6"
                elseif accName and isObjectInACLGroup ("user."..accName, aclGetGroup ( "Killers" ) ) then
                    players[i] = "4"..players[i].."6"
                elseif getElementData ( player, "adminapplicant" ) then
                    players[i] = "13"..players[i].."6"
                end
				if getElementData(player, "player state") == "away" then
					players[i] = ""..players[i].."(💤)"
				end
			end
			ircSay(channel,"6There are "..getPlayerCount().." players ingame: "..table.concat(players,", "))
		end
		else 
			local theTable = { } 
			local k = 0 
			local theName = string.lower(name)
			for i,j in ipairs(getElementsByType('player')) do 
				if string.find(string.lower(getNameNoColor(j)), theName, 1, true) then
					k = k + 1
					theTable[k] = getPlayerName(j)
				end
			end
			if k == 0 then
				ircSay(channel,"No player found")
			elseif k == 1 then
				ircSay(channel,"6There is "..k.." '"..name.."' player ingame: "..table.concat(theTable,", "))
			else
				ircSay(channel,"6There are "..k.." '"..name.."' players ingame: "..table.concat(theTable,", "))
			end	
		end
	end
	addIRCCommandHandler("!players", players)
	addIRCCommandHandler("!P", players)
addIRCCommandHandler("!p", players)
addIRCCommandHandler("!Players", players)

addIRCCommandHandler("!run",
        function (server,channel,user,command,...)
                local str = table.concat({...}," ")
                if not str then ircNotice(user,"syntax is !run <string>") return end
                runString(str,root,ircGetUserNick(user))
        end
)

addIRCCommandHandler("!crun",
        function (server,channel,user,command,...)
                local t = {...}
                local str = table.concat(t," ")
                if not str then ircNotice(user,"syntax is !crun <string>") return end
                if #getElementsByType("player") == 0 then
                        ircNotice(user,"No player ingame!")
                end
                for i,player in ipairs (getElementsByType("player")) do
                        if i == 1 then
                                triggerClientEvent(player,"doCrun",root,str,false)
                        else
                                triggerClientEvent(player,"doCrun",root,str,false)
                        end
                end
        end
)

-- addIRCCommandHandler("!resources",
        -- function (server,channel,user,command)
                -- local resources = getResources()
                -- for i,resource in ipairs (resources) do
                        -- if getResourceState(resource) == "running" then
                                -- resources[i] = "03"..getResourceName(resource).."01"
                        -- elseif getResourceState(resource) == "failed to load" then
                                -- resources[i] = "04"..getResourceName(resource).." ("..getResourceLoadFailureReason(resource)..")01"
                        -- else
                                -- resources[i] = "07"..getResourceName(resource).."01"
                        -- end
                -- end
                -- ircSay(channel,"07Resources: "..table.concat(resources,", "))
        -- end
-- )

addIRCCommandHandler("!start",
        function (server,channel,user,command,resName)
                if not resName then ircNotice(user,"syntax is !start <resourcename>") return end
                local resource = getResourceFromPartialName(resName)
                if resource then
                        if not startResource(resource) then
                                ircNotice(user,"Failed to start '"..getResourceName(resource).."'")
                        end
                else
                        ircNotice(user,"Resource '"..resName.."' not found!")
                end
        end
)

addIRCCommandHandler("!restart",
        function (server,channel,user,command,resName)
                if not resName then ircNotice(user,"syntax is !restart <resourcename>") return end
                local resource = getResourceFromPartialName(resName)
                if resource then
                        if not restartResource(resource) then
                                ircNotice(user,"Failed to restart '"..getResourceName(resource).."'")
                        end
                else
                        ircNotice(user,"Resource '"..resName.."' not found!")
                end
        end
)

addIRCCommandHandler("!stop",
        function (server,channel,user,command,resName)
                if not resName then ircNotice(user,"syntax is !stop <resourcename>") return end
                local resource = getResourceFromPartialName(resName)
                if resource then
                        if not stopResource(resource) then
                                ircNotice(user,"Failed to stop '"..getResourceName(resource).."'")
                        end
                else
                        ircNotice(user,"Resource '"..resName.."' not found!")
                end
        end
)
function outputCommands (server,channel,user,command)
        local cmds = {}
        for i,cmd in ipairs (ircGetCommands()) do
                if ircIsCommandEchoChannelOnly(cmd) then
                        if ircIsEchoChannel(channel) then
                                if (tonumber(ircGetCommandLevel(cmd) or 6)) <= (tonumber(ircGetUserLevel(user,channel)) or 0) then
                                        table.insert(cmds,cmd)
                                end
                        end
                else
                        if ircGetCommandLevel(cmd) <= ircGetUserLevel(user,channel) then
                                table.insert(cmds,cmd)
                        end
                end
        end
        ircSay(channel,ircGetUserNick(user)..", you can use these commands: "..table.concat(cmds,", "))
end
addIRCCommandHandler("!commands",outputCommands)
addIRCCommandHandler("!cmds",outputCommands)

addIRCCommandHandler("!account",
        function (server,channel,user,command,name)
                if not name then ircNotice(user,"syntax is !account <name>") return end
                local player = getPlayerFromPartialName(name)
                if player then
                        ircNotice(user,getPlayerName(player).."'s account name: "..(getAccountName(getPlayerAccount(player)) or "Guest Account"))
                else
                        ircNotice(user,"'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!money",
        function (server,channel,user,command,name)
                if not name then ircNotice(user,"syntax is !money <name>") return end
                local player = getPlayerFromPartialName(name)
                if player then
                        ircNotice(user,getPlayerName(player).."'s money: "..tostring(getPlayerMoney(player)))
                else
                        ircNotice(user,"'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!health",
        function (server,channel,user,command,name)
                if not name then ircNotice(user,"syntax is !health <name>") return end
                local player = getPlayerFromPartialName(name)
                if player then
                        ircNotice(user,getPlayerName(player).."'s health: "..tostring(getPlayerHealth(player)))
                else
                        ircNotice(user,"'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!wantedlevel",
        function (server,channel,user,command,name)
                if not name then ircNotice(user,"syntax is !wantedlevel <name>") return end
                local player = getPlayerFromPartialName(name)
                if player then
                        outputIRC(getPlayerName(player).."'s wanted level: "..tostring(getPlayerWantedLevel(player)))
                else
                        outputIRC("'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!team",
        function (server,channel,user,command,name)
                if not name then ircNotice(user,"syntax is !team <name>") return end
                local player = getPlayerFromPartialName(name)
                if player then
                        local team = getPlayerTeam(player)
                        if team then
                                outputIRC(getPlayerName(player).."'s team: "..getTeamName(team))
                        else
                                outputIRC(getPlayerName(player).." is in no team")
                        end
                else
                        outputIRC("'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!ping",
        function (server,channel,user,command,name)
                if not name then ircNotice(user,"syntax is !ping <name>") return end
                local player = getPlayerFromPartialName(name)
                if player then
                        outputIRC(getPlayerName(player).."'s ping: "..getPlayerPing(player))
                else
                        outputIRC("'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!community",
        function (server,channel,user,command,name)
                if not name then ircNotice(user,"syntax is !community <name>") return end
                local player = getPlayerFromPartialName(name)
                if player then
                        ircNotice(user,getPlayerName(player).."'s community account name: "..(getPlayerUserName(player) or "None"))
                else
                        ircNotice(user,"'"..name.."' no such player")
                end
        end
)

addIRCCommandHandler("!changemap",
        function (server,channel,user,command,...)
                local map = table.concat({...}," ")
                if not map then ircNotice(user,"syntax is !changemap <name>") return end
                local maps = {}
                for i,resource in ipairs (getResources()) do
                        if getResourceInfo(resource,"type") == "map" then
                                if string.find(string.lower(getResourceName(resource)),string.lower(map)) then
                                        table.insert(maps,resource)
                                elseif string.find(string.lower(getResourceInfo(resource,"name")),string.lower(map)) then
                                        table.insert(maps,resource)
                                end
                        end
                end
                if #maps == 0 then
                        ircNotice(user,"No maps found!")
                elseif #maps == 1 then
                        exports.mapmanager:changeGamemodeMap(maps[1])
                else
                        for i,resource in ipairs (maps) do
                                maps[i] = getResourceName(resource)
                        end
                        ircNotice(user,"Found "..#maps.." matches: "..table.concat(maps,", "))
                end
        end
)

addIRCCommandHandler("!modules",
        function (server,channel,user,command, resname)
                ircSay(channel,"07Loaded modules: "..table.concat(getLoadedModules(),", "))
        end
)

addIRCCommandHandler("!update",
        function (server,channel,user,command,...)
			for k,resname in ipairs{...} do
				local res = getResourceFromName(resname)
				if not res then
					ircNotice(user, command .. ': res ' .. tostring(resname) .. ' not found')
				else
					table.insert(updates, {resname, user})
					ircNotice(user, command .. ': restarting ' .. tostring(resname) .. ' after map is finished')
				end
			end
        end
)

addEvent'onPostFinish'
addEventHandler('onPostFinish', root, function()
	for k, v in ipairs(updates) do
		local resname, user = v[1], v[2]
		local res = getResourceFromName(resname)
		if res then
			setTimer(function()
				ircNotice(user, 'update: restarting ' .. tostring(resname) .. ' updating')
				if getResourceState(res) == 'running' then
					restartResource(res)
				else
					startResource(res)
				end
			end, 500*(k), 1)
		else
			ircNotice(user, 'update: res ' .. tostring(resname) .. ' not found')
		end
	end
	updates = {}
end)


end     
