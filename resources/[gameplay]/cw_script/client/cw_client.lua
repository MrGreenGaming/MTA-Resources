text_offset = 20
teams = {}
tags = {}
ffa_mode = "CW" -- CW or FFA
ffa_keep_gcshop_teams = false
ffa_keep_modshop = false
scoring = "15,13,11,9,7,5,4,3,2,1"
c_round = 0
m_round = 10
f_round = false
team_choosen = false
isAdmin = false
compact = false

c_eventName = false
c_nextMapName = false
c_subtitle = false

function outputInfoClient(info)
    outputChatBox('[Event] #ffffff' ..info, 155, 155, 255, true)
end

function getEventMode()
    return ffa_mode
end

-----------------
-- Call functions
-----------------

function serverCall(funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do
            if (type(value) == "number") then arg[key] = tostring(value) end
        end
    end
    triggerServerEvent("onClientCallsServerFunction", resourceRoot , funcname, unpack(arg))
end

function clientCall(funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do arg[key] = tonumber(value) or value end
    end
    loadstring("return "..funcname)()(unpack(arg))
end
addEvent("onServerCallsClientFunction", true)
addEventHandler("onServerCallsClientFunction", resourceRoot, clientCall)

------------------------
--GUI
------------------------

function rgb2hex(r,g,b)
	return string.format("#%02X%02X%02X", r,g,b)
end

function hex2rgb(hex)
	hex = hex:gsub("#","")
	return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

----------------------------
-- OTHER FUNCTIONS
----------------------------
function updateTeamData(team1, team2, team3)
	teams[1] = team1
	teams[2] = team2
	teams[3] = team3
	updateAdminPanelText()
end

function updateTagData(tag1, tag2)
	tags[1] = tag1
	tags[2] = tag2
	updateAdminPanelText()
end

function updateModeData(mode, keep_gcshop_teams, keep_modshop)
    ffa_mode = mode
    ffa_keep_gcshop_teams = keep_gcshop_teams
    ffa_keep_modshop = keep_modshop
    updateAdminPanelText()
end

function updateScoringData(newScoring)
    scoring = newScoring
    updateAdminPanelText()
end

function updateEventMetadata(_eventName, _nextMapName, _subtitle)
    if _eventName then
        c_eventName = _eventName
    end
    c_nextMapName = _nextMapName
		c_subtitle = _subtitle
end

function updateNextMapNameIfNotSet(_nextMapName)
    if not c_nextMapName then
        c_nextMapName = _nextMapName
    end
end

function updateEventName(_eventName)
    c_eventName = _eventName
end

function updateRoundData(c_r, max_r, f_r)
	if c_r == 0 then
		f_round = true
	else
		f_round = f_r
	end
	c_round = c_r
	m_round = max_r
	updateAdminPanelText()
end

function updateAdminInfo(obj)
	isAdmin = obj
	if isAdmin then
		createAdminGUI()
		outputInfoClient('Press #9b9bff9 #ffffffto open management panel')
	end
end

function stringToNumber(colorsString)
	local r = gettok(colorsString, 1, string.byte(','))
	local g = gettok(colorsString, 2, string.byte(','))
	local b = gettok(colorsString, 3, string.byte(','))
	if r == false or g == false or b == false then
		outputInfoClient('use - [0-255], [0-255], [0-255]')
		return 0, 255, 0
	else
		return r, g, b
	end
end
