
local team_sql = [[
CREATE TABLE IF NOT EXISTS `team` (
 `teamid` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
 `owner` mediumint(8) NOT NULL,
 `expires` int(11) NOT NULL,
 `name` varchar(20) NOT NULL,
 `tag` varchar(6) NOT NULL,
 `colour` float NOT NULL,
 `message` varchar(255) DEFAULT NULL,
 PRIMARY KEY (`teamid`),
 KEY `owner` (`owner`),
 CONSTRAINT `Team owner forumid` FOREIGN KEY (`owner`) REFERENCES `mrgreen_forums`.`x_utf_l4g_members` (`member_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8
]]
local team_members_sql = [[
CREATE TABLE IF NOT EXISTS `team_members` (
 `forumid` mediumint(8) NOT NULL,
 `teamid` smallint(5) unsigned NOT NULL,
 `date` int(11) NOT NULL COMMENT 'timestamp when joined team',
 `status` int(11) NOT NULL COMMENT '1 = in team',
 PRIMARY KEY (`forumid`),
 KEY `teamid` (`teamid`),
 CONSTRAINT `Forum account` FOREIGN KEY (`forumid`) REFERENCES `mrgreen_forums`.`x_utf_l4g_members` (`member_id`) ON DELETE CASCADE ON UPDATE CASCADE,
 CONSTRAINT `Team members` FOREIGN KEY (`teamid`) REFERENCES `team` (`teamid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8
]]

addEventHandler('shopStarted', root, function()
	-- Create tables if they don't exist yet on shop start
	dbExec ( handlerConnect, team_sql )
	dbExec ( handlerConnect, team_members_sql )
end)

addEventHandler('onShopInit', root, function()
end)

addEventHandler("onGCShopLogin", root, function()
	-- triggerClientEvent(source, "skinsLogin", source)
end)

addEventHandler("onGCShopLogout", root, function()
	-- triggerClientEvent(source, "skinsLogout", source)
end)


