--
-- accounts.lua
--

SAccount = {}
SAccount.__index = SAccount
SAccount.instances = {}


---------------------------------------------------------------------------
--
-- SAccount:create()
--
--
--
---------------------------------------------------------------------------
function SAccount:create(player)
    local id = #SAccount.instances + 1
    SAccount.instances[id] = setmetatable({
        id = id,
        player = player,
        gcRecord = {},
    }, self)
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
    if self.gcRecord[1] and self.gcRecord[4] ~= 0 then
        setAccountGCInfo(self.gcRecord[1], self.gcRecord[4])
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
function SAccount:login(username, pw, player, callback)
    callback(false, player)
    outputChatBox('[GC] GC Accounts are temporarily disabled!', player, 255, 0, 0)
    if not username or not pw then
        callback(false, player)
        return
    end

    --Check if we already know our forum id
    if self.gcRecord[1] then
        callback(true, player)
        return
    end

    getPlayerLoginInfo(username, pw, function(forumID, name, emailAddress, profile, joinTimestamp, gcAmount, vipTimestamp, isBanned)
        if isBanned ~= false then
            local now = getRealTime().timestamp
            if isBanned == true then
                -- Perm ban
                outputChatBox('[GC] This account has been banned!', player, 255, 0, 0)
            elseif type(isBanned) == 'number' and now < isBanned then
                -- Temp ban
                outputChatBox('[GC] This account has been banned. This ban will expire in '..secondsToTimeDesc(isBanned - now), player, 255, 0, 0)
            end
            callback(false, player)
            return
        end

        if self.gcRecord[1] then
            callback(true, player)
            return
        end

        if not forumID then
            callback(false, player)
            return
        end

        --Check if already logged in somewhere else
        --[[for id, account in pairs(SAccount.instances) do
            if account:getForumID() == forumID then
                callback(false, player)
                return
            end
        end]]

        self.gcRecord[1] = tonumber(forumID)
        self.gcRecord[2] = nil
        self.gcRecord[3] = tonumber(gcAmount)
        self.gcRecord[4] = 0 -- earned gc this session
        self.gcRecord[5] = name
        self.gcRecord[6] = emailAddress
        self.gcRecord[7] = profile
        self.gcRecord[8] = joinTimestamp
        self.gcRecord[9] = vipTimestamp
        triggerEvent('onGreencoinsLogin', self.player)
        callback(true, player)
    end)
end

---------------------------------------------------------------------------
--
-- SAccount:loginViaForumID( forumid, player, callback )
--
--
--
---------------------------------------------------------------------------
function SAccount:loginViaForumID(givenForumID, player, callback)
    callback(false, player)
    outputChatBox('[GC] GC Accounts are temporarily disabled!', player, 255, 0, 0)

    if not givenForumID then
        callback(false, player)
        return
    end

    if self.gcRecord[1] and getElementData( player, 'gc.autoLoginCache') and tonumber(getElementData( player, 'gc.autoLoginCache')) == tonumber(self.gcRecord[1]) then -- Account Switch Bug TempFix - https://github.com/MrGreenGaming/MTA-Resources/issues/488
        callback(true, player)
        return
    end

    getForumAccountDetails(givenForumID, function(forumID, name, emailAddress, profile, joinTimestamp, gcAmount, vipTimestamp, isBanned)
        if isBanned ~= false then
            local now = getRealTime().timestamp
            if isBanned == true then
                -- Perm ban
                outputChatBox('[GC] This account has been banned!', player, 255, 0, 0)
            elseif type(isBanned) == 'number' and now < isBanned then
                -- Temp ban
                outputChatBox('[GC] This account has been banned. This ban will expire in '..secondsToTimeDesc(isBanned - now), player, 255, 0, 0)
            end
            callback(false, player)
            return
        end

        if self.gcRecord[1] and getElementData( player, 'gc.autoLoginCache') and tonumber(getElementData( player, 'gc.autoLoginCache')) == tonumber(self.gcRecord[1]) then -- Account Switch Bug TempFix - https://github.com/MrGreenGaming/MTA-Resources/issues/488
            callback(true, player)
            return
        end

        if not forumID then
            callback(false, player)
            return
        end


        if not getElementData( player, 'gc.autoLoginCache') or tonumber(forumID) ~= tonumber(getElementData( player, 'gc.autoLoginCache'))  then -- Account Switch Bug TempFix - https://github.com/MrGreenGaming/MTA-Resources/issues/488
            outputDebugString( 'GC AUTOLOGIN BUG: "'..tostring(getPlayerName( player ))..'": Autologin DB forumID: '..tostring(getElementData( player, 'gc.autoLoginCache')..' - Api forumID: '..tostring(forumID) ),  3, 0, 0, 255  )
            callback(false,player)
            return
        end
        --Check if already logged in somewhere else
        --[[for id, account in pairs(SAccount.instances) do
            if account:getForumID() == forumID then
                callback(false, player)
                return
            end
        end]]

        self.gcRecord[1] = tonumber(forumID)
        self.gcRecord[2] = nil
        self.gcRecord[3] = tonumber(gcAmount)
        self.gcRecord[4] = 0 -- earned gc this session
        self.gcRecord[5] = name
        self.gcRecord[6] = emailAddress
        self.gcRecord[7] = profile
        self.gcRecord[8] = joinTimestamp
        self.gcRecord[9] = vipTimestamp
        triggerEvent('onGreencoinsLogin', self.player)
        callback(true, player)
    end)
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
    return self.gcRecord[1] --Used to be 2
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
-- SAccount:getVipTimestamp()
--
--
--
---------------------------------------------------------------------------
function SAccount:getVipTimestamp()
    return self.gcRecord[9]
end

---------------------------------------------------------------------------
--
-- SAccount:addGreencoins()
--
--
--
---------------------------------------------------------------------------
function SAccount:addGreencoins(amount)
    if not self.gcRecord[3] then outputDebugString('addGC ' .. getPlayerName(self.player) .. ' : ' .. tostring(self.gcRecord[3])) end
    self.gcRecord[3] = self.gcRecord[3] + amount
    self.gcRecord[4] = self.gcRecord[4] + amount
    triggerClientEvent(self.player, "onGCChange", root, self.gcRecord[3])
    triggerEvent('onGCChange', self.player, amount)
end

