-- phpMyAdmin SQL Dump
-- version 4.7.5
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Dec 16, 2017 at 02:22 PM
-- Server version: 5.6.38-log
-- PHP Version: 7.1.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mrgreen_mtasrvs`
--
CREATE DATABASE IF NOT EXISTS `mrgreen_mtasrvs` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `mrgreen_mtasrvs`;

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`mrgreen_gcmta`@`localhost` PROCEDURE `updateTopPositions` (IN `mapName` VARCHAR(255))  BEGIN
	#DECLARE i INT DEFAULT 1;
	SET @i := 0;
	UPDATE toptimes t SET t.pos = @i := @i + 1 WHERE t.mapname = mapName ORDER BY value ASC, date ASC;
END$$

CREATE DEFINER=`mrgreen_gcmta`@`localhost` PROCEDURE `updateTopPositionsDesc` (IN `mapName` VARCHAR(255))  BEGIN
	#DECLARE i INT DEFAULT 1;
	SET @i := 0;
	UPDATE toptimes t SET t.pos = @i := @i + 1 WHERE t.mapname = mapName ORDER BY value DESC, date ASC;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `achievements`
--

CREATE TABLE `achievements` (
  `forumID` int(11) NOT NULL,
  `achievementID` int(11) NOT NULL,
  `unlockedDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `unlocked` tinyint(1) NOT NULL DEFAULT '0',
  `progress` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `achievements_race`
--

CREATE TABLE `achievements_race` (
  `forumID` int(11) NOT NULL,
  `achievementID` int(11) NOT NULL,
  `unlockedDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `unlocked` tinyint(1) NOT NULL DEFAULT '0',
  `progress` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `blockers`
--

CREATE TABLE `blockers` (
  `serial` varchar(32) NOT NULL,
  `name` varchar(100) NOT NULL,
  `expireTimestamp` int(30) NOT NULL,
  `byAdmin` varchar(100) NOT NULL,
  `timeOfMark` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `canmodsoverride` varchar(5) NOT NULL DEFAULT 'true'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `country`
--

CREATE TABLE `country` (
  `forum_id` int(11) NOT NULL,
  `country` char(2) NOT NULL DEFAULT 'XX'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `custom_skins`
--

CREATE TABLE `custom_skins` (
  `forumid` int(11) NOT NULL,
  `skin` varchar(250) NOT NULL DEFAULT '',
  `setting` varchar(250) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `gcshop_mod_upgrades`
--

CREATE TABLE `gcshop_mod_upgrades` (
  `forumID` mediumint(9) NOT NULL,
  `vehicle` smallint(6) NOT NULL,
  `slot0` text NOT NULL,
  `slot1` text NOT NULL,
  `slot2` text NOT NULL,
  `slot3` text NOT NULL,
  `slot4` text NOT NULL,
  `slot5` text NOT NULL,
  `slot6` text NOT NULL,
  `slot7` text NOT NULL,
  `slot8` text NOT NULL,
  `slot9` text NOT NULL,
  `slot10` text NOT NULL,
  `slot11` text NOT NULL,
  `slot12` text NOT NULL,
  `slot13` text NOT NULL,
  `slot14` text NOT NULL,
  `slot15` text NOT NULL,
  `slot16` text NOT NULL,
  `slot17` text NOT NULL,
  `slot18` text NOT NULL,
  `slot19` text NOT NULL,
  `slot20` text NOT NULL,
  `slot21` text NOT NULL,
  `slot22` text NOT NULL,
  `slot23` text NOT NULL,
  `slot24` text NOT NULL,
  `slot25` text NOT NULL,
  `slot26` text NOT NULL,
  `slot27` text NOT NULL,
  `slot28` text NOT NULL,
  `slot29` text NOT NULL,
  `slot30` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `gc_autologin`
--

CREATE TABLE `gc_autologin` (
  `forumid` int(11) DEFAULT NULL,
  `last_serial` varchar(250) NOT NULL DEFAULT '',
  `last_login` varchar(250) NOT NULL DEFAULT '',
  `last_ip` varchar(250) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `gc_autologin2`
--

CREATE TABLE `gc_autologin2` (
  `forumid` int(11) DEFAULT NULL,
  `forum_email` varchar(250) DEFAULT '',
  `forum_password` varchar(250) DEFAULT '',
  `last_serial` varchar(250) NOT NULL DEFAULT '',
  `last_login` varchar(250) NOT NULL DEFAULT '',
  `last_ip` varchar(250) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `gc_horns`
--

CREATE TABLE `gc_horns` (
  `forumid` int(11) NOT NULL,
  `horns` text NOT NULL,
  `current` int(11) NOT NULL DEFAULT '0',
  `unlimited` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `gc_items`
--

CREATE TABLE `gc_items` (
  `id` int(11) NOT NULL,
  `forumid` int(10) UNSIGNED NOT NULL,
  `itembought` int(10) UNSIGNED NOT NULL,
  `expires` int(10) UNSIGNED DEFAULT NULL,
  `options` varchar(45) DEFAULT '[ [ ] ]'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `gc_nickprotection`
--

CREATE TABLE `gc_nickprotection` (
  `pNick` varchar(50) NOT NULL,
  `accountID` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `gc_nickprotection_amount`
--

CREATE TABLE `gc_nickprotection_amount` (
  `forumID` int(11) NOT NULL,
  `amount` int(11) NOT NULL DEFAULT '3'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `gc_rocketcolor`
--

CREATE TABLE `gc_rocketcolor` (
  `forumid` int(11) NOT NULL,
  `color` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `mapratings`
--

CREATE TABLE `mapratings` (
  `forumid` int(11) DEFAULT NULL,
  `serial` tinytext,
  `playername` tinytext,
  `mapresourcename` varchar(70) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `rating` tinyint(1) NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `maps`
--

CREATE TABLE `maps` (
  `mapId` int(11) UNSIGNED NOT NULL,
  `resname` varchar(255) CHARACTER SET latin1 NOT NULL,
  `mapname` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `racemode` varchar(255) CHARACTER SET latin1 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `mapstop100`
--

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

-- --------------------------------------------------------

--
-- Table structure for table `maps_del`
--

CREATE TABLE `maps_del` (
  `id` int(11) NOT NULL,
  `name` varchar(250) CHARACTER SET utf8 NOT NULL,
  `author` varchar(100) CHARACTER SET utf8 NOT NULL,
  `reason` varchar(250) CHARACTER SET utf8 NOT NULL,
  `admin_name` varchar(50) CHARACTER SET utf8 NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `resname` varchar(50) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `mute`
--

CREATE TABLE `mute` (
  `serial` varchar(32) NOT NULL,
  `name` varchar(22) NOT NULL,
  `expireTimestamp` varchar(10) NOT NULL,
  `byAdmin` varchar(22) NOT NULL,
  `whenMuted` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `IP` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `playersettings`
--

CREATE TABLE `playersettings` (
  `serial` varchar(32) NOT NULL,
  `mainlang` varchar(10) NOT NULL,
  `languages` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='LanguageChat table';

-- --------------------------------------------------------

--
-- Table structure for table `serialsDB`
--

CREATE TABLE `serialsDB` (
  `serialid` int(11) NOT NULL,
  `playername` varchar(250) NOT NULL DEFAULT '',
  `serial` varchar(250) NOT NULL DEFAULT '',
  `date` varchar(250) NOT NULL DEFAULT '',
  `ip` varchar(250) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `stats`
--

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

-- --------------------------------------------------------

--
-- Table structure for table `team`
--

CREATE TABLE `team` (
  `teamid` smallint(5) UNSIGNED NOT NULL,
  `owner` mediumint(8) NOT NULL,
  `create_timestamp` int(11) NOT NULL,
  `renew_timestamp` int(11) NOT NULL COMMENT 'timestamp when last renewed',
  `name` varchar(20) NOT NULL,
  `tag` varchar(7) NOT NULL,
  `colour` varchar(7) NOT NULL,
  `message` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `team_members`
--

CREATE TABLE `team_members` (
  `forumid` mediumint(8) NOT NULL,
  `teamid` smallint(5) UNSIGNED NOT NULL,
  `join_timestamp` int(11) NOT NULL COMMENT 'timestamp when joined current team',
  `status` int(11) NOT NULL COMMENT '1 = in team'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `toptimes`
--

CREATE TABLE `toptimes` (
  `forumid` int(11) NOT NULL,
  `mapname` varchar(255) NOT NULL,
  `pos` mediumint(9) DEFAULT NULL,
  `value` bigint(20) NOT NULL,
  `date` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `toptimes_month`
--

CREATE TABLE `toptimes_month` (
  `forumid` int(11) NOT NULL,
  `mapname` varchar(255) NOT NULL,
  `value` bigint(20) NOT NULL,
  `date` bigint(20) NOT NULL,
  `month` tinyint(12) NOT NULL,
  `rewarded` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `uploaded_maps`
--

CREATE TABLE `uploaded_maps` (
  `uploadid` int(11) NOT NULL,
  `forumid` int(11) NOT NULL,
  `uploadername` varchar(50) NOT NULL,
  `resname` varchar(255) NOT NULL,
  `mapname` varchar(255) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `comment` text NOT NULL,
  `status` varchar(20) NOT NULL,
  `manager` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `votestop100`
--

CREATE TABLE `votestop100` (
  `id` int(11) NOT NULL,
  `forumid` int(10) UNSIGNED NOT NULL,
  `choice1` varchar(70) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `choice2` varchar(70) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `choice3` varchar(70) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `choice4` varchar(70) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `choice5` varchar(70) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `achievements`
--
ALTER TABLE `achievements`
  ADD PRIMARY KEY (`forumID`,`achievementID`);

--
-- Indexes for table `blockers`
--
ALTER TABLE `blockers`
  ADD PRIMARY KEY (`serial`);

--
-- Indexes for table `country`
--
ALTER TABLE `country`
  ADD PRIMARY KEY (`forum_id`),
  ADD UNIQUE KEY `forumid` (`forum_id`);

--
-- Indexes for table `custom_skins`
--
ALTER TABLE `custom_skins`
  ADD PRIMARY KEY (`forumid`),
  ADD KEY `forumid` (`forumid`);

--
-- Indexes for table `gcshop_mod_upgrades`
--
ALTER TABLE `gcshop_mod_upgrades`
  ADD PRIMARY KEY (`forumID`,`vehicle`);

--
-- Indexes for table `gc_autologin`
--
ALTER TABLE `gc_autologin`
  ADD PRIMARY KEY (`last_serial`);

--
-- Indexes for table `gc_autologin2`
--
ALTER TABLE `gc_autologin2`
  ADD PRIMARY KEY (`last_serial`);

--
-- Indexes for table `gc_horns`
--
ALTER TABLE `gc_horns`
  ADD PRIMARY KEY (`forumid`),
  ADD UNIQUE KEY `forumid` (`forumid`);

--
-- Indexes for table `gc_items`
--
ALTER TABLE `gc_items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `gc_nickprotection`
--
ALTER TABLE `gc_nickprotection`
  ADD PRIMARY KEY (`pNick`);

--
-- Indexes for table `gc_rocketcolor`
--
ALTER TABLE `gc_rocketcolor`
  ADD UNIQUE KEY `forumid` (`forumid`);

--
-- Indexes for table `maps`
--
ALTER TABLE `maps`
  ADD PRIMARY KEY (`mapId`),
  ADD UNIQUE KEY `resname` (`resname`);

--
-- Indexes for table `mapstop100`
--
ALTER TABLE `mapstop100`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `maps_del`
--
ALTER TABLE `maps_del`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`);

--
-- Indexes for table `mute`
--
ALTER TABLE `mute`
  ADD PRIMARY KEY (`serial`),
  ADD UNIQUE KEY `serial` (`serial`);

--
-- Indexes for table `playersettings`
--
ALTER TABLE `playersettings`
  ADD PRIMARY KEY (`serial`);

--
-- Indexes for table `serialsDB`
--
ALTER TABLE `serialsDB`
  ADD PRIMARY KEY (`serialid`),
  ADD KEY `playername` (`playername`),
  ADD KEY `serial` (`serial`);

--
-- Indexes for table `stats`
--
ALTER TABLE `stats`
  ADD UNIQUE KEY `forumID` (`forumID`);

--
-- Indexes for table `team`
--
ALTER TABLE `team`
  ADD PRIMARY KEY (`teamid`),
  ADD KEY `teamname` (`name`) USING BTREE,
  ADD KEY `teamtag` (`tag`) USING BTREE,
  ADD KEY `teamowner` (`owner`) USING BTREE;

--
-- Indexes for table `team_members`
--
ALTER TABLE `team_members`
  ADD PRIMARY KEY (`forumid`),
  ADD KEY `teamid` (`teamid`);

--
-- Indexes for table `toptimes`
--
ALTER TABLE `toptimes`
  ADD PRIMARY KEY (`forumid`,`mapname`);

--
-- Indexes for table `toptimes_month`
--
ALTER TABLE `toptimes_month`
  ADD PRIMARY KEY (`mapname`,`month`);

--
-- Indexes for table `uploaded_maps`
--
ALTER TABLE `uploaded_maps`
  ADD PRIMARY KEY (`uploadid`);

--
-- Indexes for table `votestop100`
--
ALTER TABLE `votestop100`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `gc_items`
--
ALTER TABLE `gc_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7644;

--
-- AUTO_INCREMENT for table `maps`
--
ALTER TABLE `maps`
  MODIFY `mapId` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=527130;

--
-- AUTO_INCREMENT for table `mapstop100`
--
ALTER TABLE `mapstop100`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=202;

--
-- AUTO_INCREMENT for table `maps_del`
--
ALTER TABLE `maps_del`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=119;

--
-- AUTO_INCREMENT for table `serialsDB`
--
ALTER TABLE `serialsDB`
  MODIFY `serialid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=983188;

--
-- AUTO_INCREMENT for table `team`
--
ALTER TABLE `team`
  MODIFY `teamid` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=294;

--
-- AUTO_INCREMENT for table `uploaded_maps`
--
ALTER TABLE `uploaded_maps`
  MODIFY `uploadid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5160;

--
-- AUTO_INCREMENT for table `votestop100`
--
ALTER TABLE `votestop100`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `team_members`
--
ALTER TABLE `team_members`
  ADD CONSTRAINT `Team members` FOREIGN KEY (`teamid`) REFERENCES `team` (`teamid`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
