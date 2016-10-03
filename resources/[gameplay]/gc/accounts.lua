--
-- accounts.lua
--

SAccount = {}
SAccount.__index = SAccount
SAccount.instances = {}

accDB = "gc"
gcDB = "gc"

---------------------------------------------------------------------------
--
-- SAccount:create()
--
--
--
---------------------------------------------------------------------------

function SAccount:create( player )
    local id = #SAccount.instances + 1
    SAccount.instances[id] = setmetatable(
        {
            id = id,
            player = player,
            gcRecord = {},
        },
        self
    )
    return SAccount.instances[id]
end

---------------------------------------------------------------------------
--
-- SAccount:destroy()
--
--
--
---------------------------------------------------------------------------

function SAccount:destroy(quick)
    if ( self.gcRecord[1] and self.gcRecord[2] and quick ) then
        setAccountGCInfo(self, self.gcRecord[2], self.gcRecord[4], quick)   --quick for quick saving the GC on STOP of resource
	elseif ( self.gcRecord[1] and self.gcRecord[2] ) then
		setAccountGCInfo(self, self.gcRecord[2], self.gcRecord[4])
    end
    self.gcRecord = {}
    SAccount.instances[self.id] = nil
    self.id = 0
end

---------------------------------------------------------------------------
--
-- SAccount:login( username, password, player, callback )
--
--
--
---------------------------------------------------------------------------

function SAccount:login(email, pw, player, callback)
    if not self.gcRecord[1] and pw then
        getPlayerLoginInfo(email, pw, function (forumID, name, emailAddress, profile, joinTimestamp)
			if not self.gcRecord[1] and forumID then
				for id, account in pairs (SAccount.instances) do
					if account:getForumID() == forumID then return callback(false, player) end
				end
				self.gcRecord[1] = forumID
				local gcID, gcAmount = getPlayerGCInfo(forumID)
				--outputDebugString(tostring(gcID))
				if gcID and gcAmount then
					self.gcRecord[2] = gcID
					self.gcRecord[3] = gcAmount
					self.gcRecord[4] = 0 -- earned gc this session
					self.gcRecord[5] = name
					self.gcRecord[6] = emailAddress
					self.gcRecord[7] = profile
					self.gcRecord[8] = joinTimestamp
					triggerEvent('onGreencoinsLogin', self.player)
					return callback(true, player)
				else
					outputChatBox ( "Attention!", self.player, 255, 0, 0 )
					outputChatBox ( "It seems that you don't have your green-coins set up yet.", self.player, 255, 0, 0 )
					outputChatBox ( "Visit mrgreengaming.com -> Green-Coins to do so!", self.player, 255, 0, 0 )
				end
			end
			return callback(false, player)
		end)
    else
		return callback(false, player)
	end
end

---------------------------------------------------------------------------
--
-- SAccount:loginViaForumID( forumid, player, callback )
--
--
--
---------------------------------------------------------------------------

function SAccount:loginViaForumID(forumID, player, callback)
	if not self.gcRecord[1] and forumID then
		getForumAccountDetails ( forumID, function(name, emailAddress, profile, joinTimestamp)
			for id, account in pairs (SAccount.instances) do
				if account:getForumID() == forumID then return callback(false, player) end
			end
			self.gcRecord[1] = forumID
			local gcID, gcAmount = getPlayerGCInfo(forumID)
			--outputDebugString(tostring(gcID))
			if gcID and gcAmount then
				self.gcRecord[2] = gcID
				self.gcRecord[3] = gcAmount
				self.gcRecord[4] = 0 -- earned gc this session
				self.gcRecord[5] = name
				self.gcRecord[6] = emailAddress
				self.gcRecord[7] = profile
				self.gcRecord[8] = joinTimestamp
				triggerEvent('onGreencoinsLogin', self.player)
				return callback(true, player)
			else
				outputChatBox ( "Attention!", self.player, 255, 0, 0 )
				outputChatBox ( "It seems that you don't have your green-coins set up yet.", self.player, 255, 0, 0 )
				outputChatBox ( "Visit mrgreengaming.com -> Green-Coins to do so!", self.player, 255, 0, 0 )
			end
		end)
    else
		return callback(false, player)
	end
end

---------------------------------------------------------------------------
--
-- SAccount:getGreencoins()
--
--
--
---------------------------------------------------------------------------

function SAccount:getGreencoins()
    return self.gcRecord[3]
end

---------------------------------------------------------------------------
--
-- SAccount:getSessionGreencoins()
--
--
--
---------------------------------------------------------------------------

function SAccount:getSessionGreencoins()
    return self.gcRecord[4]
end

---------------------------------------------------------------------------
--
-- SAccount:getForumID()
--
--
--
---------------------------------------------------------------------------

function SAccount:getForumID()
    return self.gcRecord[1]
end

---------------------------------------------------------------------------
--
-- SAccount:getGreencoinsID()
--
--
--
---------------------------------------------------------------------------

function SAccount:getGreencoinsID()
    return self.gcRecord[2]
end

---------------------------------------------------------------------------
--
-- SAccount:getForumName()
--
--
--
---------------------------------------------------------------------------

function SAccount:getForumName()
    return self.gcRecord[5]
end

---------------------------------------------------------------------------
--
-- SAccount:getLoginEmail()
--
--
--
---------------------------------------------------------------------------

function SAccount:getLoginEmail()
    return self.gcRecord[6]
end

---------------------------------------------------------------------------
--
-- SAccount:getProfileData()
--
--
--
---------------------------------------------------------------------------

function SAccount:getProfileData()
    return self.gcRecord[7]
end

---------------------------------------------------------------------------
--
-- SAccount:getJoinTimestamp()
--
--
--
---------------------------------------------------------------------------

function SAccount:getJoinTimestamp()
    return self.gcRecord[8]
end

---------------------------------------------------------------------------
--
-- SAccount:addGreencoins()
--
--
--
---------------------------------------------------------------------------

function SAccount:addGreencoins(amount)
	if not self.gcRecord[3] then outputDebugString ('addGC ' .. getPlayerName(self.player) .. ' : ' .. tostring(self.gcRecord[3])) end
    self.gcRecord[3] = self.gcRecord[3]+amount
    self.gcRecord[4] = self.gcRecord[4]+amount
    triggerClientEvent(self.player, "onGCChange", root, self.gcRecord[3])
end

