---------------------------------------------------------------------
-- Project: irc
-- Author: MCvarial
-- Contact: mcvarial@gmail.com
-- Version: 1.0.0
-- Date: 31.10.2010
---------------------------------------------------------------------

-- everything is saved here
users = {} -- syntax: [user] = {string name,string mode,string vhost,string email,string realname,table channels} (2nd,3rd,4th,5th argument not used)
	
------------------------------------
-- Users
------------------------------------
function func_ircSetUserMode (user,channel,mode)
	if users[user] and channels[channel] and type(mode) == "string" then
		return ircRaw(getElementParent(user),"MODE "..channels[channel][1].." "..mode.." :"..users[user][1])
	end
	return  false
end

function func_ircIsUserBot (user)
	if users[user] then
		if string.find(users[user][2],"B") then
			return true
		end
	end
	return false
end

function func_ircGetUserMode (user)
	if users[user] then
		return users[user][2]
	end
	return false
end

function func_ircGetUserNick (user)
	if users[user] then
		return users[user][1]
	end
	return false
end

function func_ircGetUserServer (user)
	if users[user] then
		return getElementParent(user)
	end
	return false
end

function func_ircGetUsers (server)
	if servers[server] then
		local users = {}
		for i,user in ipairs (ircGetUsers()) do
			if ircGetUserServer(user) == server then
				table.insert(users,user)
			end
		end
		return users
	else
		return getElementsByType("irc-user")
	end
end

function func_ircGetUserFromNick (nick)
	for i,user in ipairs (ircGetUsers()) do
		if ircGetUserNick(user) == nick then
			return user
		end
	end
	return false
end

function func_ircGetUserVhost (user)
	if users[user] then
		return users[user][3]
	end
	return false
end

-- TODO
function func_ircIsUserSecure (user)
	return false
end

function func_ircGetUserRealName (user)
	if users[user] then
		return users[user][5]
	end
	return false
end

function func_ircGetUserChannels (user)
	if users[user] then
		return users[user][6]
	end
	return false
end