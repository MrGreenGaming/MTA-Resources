--- Make sure to rename `your_database` with the name of your database

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;


DELIMITER $$
CREATE DEFINER=`your_database`@`localhost` PROCEDURE `updateTopPositions` (IN `mapName` VARCHAR(255))  BEGIN
	#DECLARE i INT DEFAULT 1;
	SET @i := 0;
	UPDATE toptimes t SET t.pos = @i := @i + 1 WHERE t.mapname = mapName ORDER BY value ASC, date ASC;
END$$

CREATE DEFINER=`your_database`@`localhost` PROCEDURE `updateTopPositionsDesc` (IN `mapName` VARCHAR(255))  BEGIN
	#DECLARE i INT DEFAULT 1;
	SET @i := 0;
	UPDATE toptimes t SET t.pos = @i := @i + 1 WHERE t.mapname = mapName ORDER BY value DESC, date ASC;
END$$

DELIMITER ;

CREATE TABLE `achievements` (
  `forumID` int(11) NOT NULL,
  `achievementID` int(11) NOT NULL,
  `unlockedDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `unlocked` tinyint(1) NOT NULL DEFAULT '0',
  `progress` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `achievements_race` (
  `forumID` int(11) NOT NULL,
  `achievementID` int(11) NOT NULL,
  `unlockedDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `unlocked` tinyint(1) NOT NULL DEFAULT '0',
  `progress` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `blockers` (
  `serial` varchar(32) NOT NULL,
  `name` varchar(100) NOT NULL,
  `expireTimestamp` int(30) NOT NULL,
  `byAdmin` varchar(100) NOT NULL,
  `timeOfMark` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `canmodsoverride` varchar(5) NOT NULL DEFAULT 'true'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `country` (
  `forum_id` int(11) NOT NULL,
  `country` char(2) NOT NULL DEFAULT 'XX'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `custom_skins` (
  `forumid` int(11) NOT NULL,
  `skin` varchar(250) NOT NULL DEFAULT '',
  `setting` varchar(250) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `gcshop_mod_upgrades` (
  `forumID` mediumint(9) NOT NULL,
  `vehicle` smallint(6) NOT NULL,
  `slot0` text,
  `slot1` text,
  `slot2` text,
  `slot3` text,
  `slot4` text,
  `slot5` text,
  `slot6` text,
  `slot7` text,
  `slot8` text,
  `slot9` text,
  `slot10` text,
  `slot11` text,
  `slot12` text,
  `slot13` text,
  `slot14` text,
  `slot15` text,
  `slot16` text,
  `slot17` text,
  `slot18` text,
  `slot19` text,
  `slot20` text,
  `slot21` text,
  `slot22` text,
  `slot23` text,
  `slot24` text,
  `slot25` text,
  `slot26` text,
  `slot27` text,
  `slot28` text,
  `slot29` text,
  `slot30` text
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `gc_autologin` (
  `forumid` int(11) DEFAULT NULL,
  `last_serial` varchar(250) NOT NULL DEFAULT '',
  `last_login` varchar(250) NOT NULL DEFAULT '',
  `last_ip` varchar(250) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `gc_autologin2` (
  `forumid` int(11) DEFAULT NULL,
  `forum_email` varchar(250) DEFAULT '',
  `forum_password` varchar(250) DEFAULT '',
  `last_serial` varchar(250) NOT NULL DEFAULT '',
  `last_login` varchar(250) NOT NULL DEFAULT '',
  `last_ip` varchar(250) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `gc_horns` (
  `forumid` int(11) NOT NULL,
  `horns` text NOT NULL,
  `current` int(11) NOT NULL DEFAULT '0',
  `unlimited` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `gc_items` (
  `id` int(11) NOT NULL,
  `forumid` int(10) UNSIGNED NOT NULL,
  `itembought` int(10) UNSIGNED NOT NULL,
  `expires` int(10) UNSIGNED DEFAULT NULL,
  `options` varchar(45) DEFAULT '[ [ ] ]'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `gc_nickprotection` (
  `pNick` varchar(50) NOT NULL,
  `accountID` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `gc_nickprotection_amount` (
  `forumID` int(11) NOT NULL,
  `amount` int(11) NOT NULL DEFAULT '3'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `gc_rocketcolor` (
  `forumid` int(11) NOT NULL,
  `color` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `mapratings` (
  `forumid` int(11) DEFAULT NULL,
  `serial` tinytext,
  `playername` tinytext,
  `mapresourcename` varchar(70) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `rating` tinyint(1) NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `maps` (
  `mapId` int(11) UNSIGNED NOT NULL,
  `resname` varchar(255) CHARACTER SET latin1 NOT NULL,
  `mapname` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `racemode` varchar(255) CHARACTER SET latin1 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `mapstop100` (
  `id` int(11) NOT NULL,
  `mapresourcename` varchar(70) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `mapname` varchar(70) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `author` varchar(70) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `gamemode` varchar(70) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `rank` int(11) DEFAULT NULL,
  `votes` int(11) DEFAULT NULL,
  `balance` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `maps_del` (
  `id` int(11) NOT NULL,
  `name` varchar(250) CHARACTER SET utf8 NOT NULL,
  `author` varchar(100) CHARACTER SET utf8 NOT NULL,
  `reason` varchar(250) CHARACTER SET utf8 NOT NULL,
  `admin_name` varchar(50) CHARACTER SET utf8 NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `resname` varchar(50) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `mute` (
  `serial` varchar(32) NOT NULL,
  `name` varchar(22) NOT NULL,
  `expireTimestamp` varchar(10) NOT NULL,
  `byAdmin` varchar(22) NOT NULL,
  `whenMuted` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `IP` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `playersettings` (
  `serial` varchar(32) NOT NULL,
  `mainlang` varchar(10) NOT NULL,
  `languages` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='LanguageChat table';

CREATE TABLE `serialsDB` (
  `serialid` int(11) NOT NULL,
  `playername` varchar(250) NOT NULL DEFAULT '',
  `serial` varchar(250) NOT NULL DEFAULT '',
  `date` varchar(250) NOT NULL DEFAULT '',
  `ip` varchar(250) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `stats` (
  `forumID` int(11) NOT NULL,
  `id1` int(11) DEFAULT '0' COMMENT 'Race Starts',
  `id2` int(11) DEFAULT '0' COMMENT 'Race Finishes',
  `id3` int(11) DEFAULT '0' COMMENT 'Race Wins',
  `id4` int(11) DEFAULT '0' COMMENT 'Checkpoints Collected',
  `id5` bigint(20) DEFAULT '0' COMMENT 'Hours In-Game',
  `id6` int(11) DEFAULT '0' COMMENT 'Total Deaths',
  `id7` int(11) DEFAULT '0' COMMENT 'NTS Starts',
  `id8` int(11) DEFAULT '0' COMMENT 'NTS Finishes',
  `id9` int(11) DEFAULT '0' COMMENT 'NTS Wins',
  `id10` int(11) DEFAULT '0' COMMENT 'RTF Starts',
  `id11` int(11) DEFAULT '0' COMMENT 'RTF Wins',
  `id12` int(11) DEFAULT '0' COMMENT 'DD Deaths',
  `id13` int(11) DEFAULT '0' COMMENT 'DD Wins',
  `id14` int(11) DEFAULT '0' COMMENT 'DD Kills',
  `id15` int(11) DEFAULT '0' COMMENT 'CTF Flags Delivered',
  `id16` int(11) DEFAULT '0' COMMENT 'Shooter Deaths',
  `id17` int(11) DEFAULT '0' COMMENT 'Shooter Wins',
  `id18` int(11) DEFAULT '0' COMMENT 'Shooter Kills'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `team` (
  `teamid` smallint(5) UNSIGNED NOT NULL,
  `owner` mediumint(8) NOT NULL,
  `create_timestamp` int(11) NOT NULL,
  `renew_timestamp` int(11) NOT NULL COMMENT 'timestamp when last renewed',
  `name` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
  `tag` varchar(7) CHARACTER SET utf8mb4 NOT NULL,
  `colour` varchar(7) NOT NULL,
  `message` varchar(255) CHARACTER SET utf8mb4 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `team_members` (
  `forumid` mediumint(8) NOT NULL,
  `teamid` smallint(5) UNSIGNED NOT NULL,
  `join_timestamp` int(11) NOT NULL COMMENT 'timestamp when joined current team',
  `status` int(11) NOT NULL COMMENT '1 = in team'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `toptimes` (
  `forumid` int(11) NOT NULL,
  `mapname` varchar(255) NOT NULL,
  `pos` mediumint(9) DEFAULT NULL,
  `value` bigint(20) NOT NULL,
  `date` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `toptimes_month` (
  `forumid` int(11) NOT NULL,
  `mapname` varchar(255) NOT NULL,
  `value` bigint(20) NOT NULL,
  `date` bigint(20) NOT NULL,
  `month` tinyint(12) NOT NULL,
  `rewarded` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `uploaded_maps` (
  `uploadid` int(11) NOT NULL,
  `forumid` int(11) NOT NULL DEFAULT '0',
  `uploadername` varchar(50) NOT NULL,
  `resname` varchar(255) NOT NULL,
  `mapname` varchar(255) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `comment` text,
  `status` varchar(20) NOT NULL,
  `manager` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `votestop100` (
  `id` int(11) NOT NULL,
  `forumid` int(10) UNSIGNED NOT NULL,
  `choice1` varchar(70) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `choice2` varchar(70) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `choice3` varchar(70) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `choice4` varchar(70) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `choice5` varchar(70) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


ALTER TABLE `achievements`
  ADD PRIMARY KEY (`forumID`,`achievementID`);

ALTER TABLE `blockers`
  ADD PRIMARY KEY (`serial`);

ALTER TABLE `country`
  ADD PRIMARY KEY (`forum_id`),
  ADD UNIQUE KEY `forumid` (`forum_id`);

ALTER TABLE `custom_skins`
  ADD PRIMARY KEY (`forumid`),
  ADD KEY `forumid` (`forumid`);

ALTER TABLE `gcshop_mod_upgrades`
  ADD PRIMARY KEY (`forumID`,`vehicle`);

ALTER TABLE `gc_autologin`
  ADD PRIMARY KEY (`last_serial`);

ALTER TABLE `gc_autologin2`
  ADD PRIMARY KEY (`last_serial`);

ALTER TABLE `gc_horns`
  ADD PRIMARY KEY (`forumid`),
  ADD UNIQUE KEY `forumid` (`forumid`);

ALTER TABLE `gc_items`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `gc_nickprotection`
  ADD PRIMARY KEY (`pNick`);

ALTER TABLE `gc_rocketcolor`
  ADD UNIQUE KEY `forumid` (`forumid`);

ALTER TABLE `maps`
  ADD PRIMARY KEY (`mapId`),
  ADD UNIQUE KEY `resname` (`resname`);

ALTER TABLE `mapstop100`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `maps_del`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`);

ALTER TABLE `mute`
  ADD PRIMARY KEY (`serial`),
  ADD UNIQUE KEY `serial` (`serial`);

ALTER TABLE `playersettings`
  ADD PRIMARY KEY (`serial`);

ALTER TABLE `serialsDB`
  ADD PRIMARY KEY (`serialid`),
  ADD KEY `playername` (`playername`),
  ADD KEY `serial` (`serial`);

ALTER TABLE `stats`
  ADD UNIQUE KEY `forumID` (`forumID`);

ALTER TABLE `team`
  ADD PRIMARY KEY (`teamid`),
  ADD KEY `teamname` (`name`) USING BTREE,
  ADD KEY `teamtag` (`tag`) USING BTREE,
  ADD KEY `teamowner` (`owner`) USING BTREE;

ALTER TABLE `team_members`
  ADD PRIMARY KEY (`forumid`),
  ADD KEY `teamid` (`teamid`);

ALTER TABLE `toptimes`
  ADD PRIMARY KEY (`forumid`,`mapname`);

ALTER TABLE `toptimes_month`
  ADD PRIMARY KEY (`mapname`,`month`);

ALTER TABLE `uploaded_maps`
  ADD PRIMARY KEY (`uploadid`);

ALTER TABLE `votestop100`
  ADD PRIMARY KEY (`id`);


ALTER TABLE `gc_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `maps`
  MODIFY `mapId` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `mapstop100`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `maps_del`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `serialsDB`
  MODIFY `serialid` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `team`
  MODIFY `teamid` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `uploaded_maps`
  MODIFY `uploadid` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `votestop100`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;


ALTER TABLE `team_members`
  ADD CONSTRAINT `Team members` FOREIGN KEY (`teamid`) REFERENCES `team` (`teamid`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
