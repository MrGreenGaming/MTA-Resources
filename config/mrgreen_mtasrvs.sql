-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Nov 06, 2015 at 11:21 PM
-- Server version: 5.6.19
-- PHP Version: 5.6.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
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
-- Stand-in structure for view `nickprotection`
--
CREATE TABLE `nickprotection` (
`pNick` varchar(50)
,`accountID` text
,`forum_id` int(11)
,`forum_name` varchar(255)
,`email` varchar(150)
,`steam_name` varchar(64)
,`mta_name` varchar(64)
);

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
-- Table structure for table `team`
--

CREATE TABLE `team` (
  `teamid` smallint(5) UNSIGNED NOT NULL,
  `owner` mediumint(8) NOT NULL,
  `timestamp` int(11) NOT NULL,
  `name` varchar(20) NOT NULL,
  `tag` varchar(6) NOT NULL,
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
  `timestamp` int(11) NOT NULL COMMENT 'timestamp when joined team',
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
-- Structure for view `nickprotection`
--
DROP TABLE IF EXISTS `nickprotection`;

CREATE ALGORITHM=UNDEFINED DEFINER=`mrgreen_gcmta`@`localhost` SQL SECURITY DEFINER VIEW `nickprotection`  AS  select `nick`.`pNick` AS `pNick`,`nick`.`accountID` AS `accountID`,`gc`.`forum_id` AS `forum_id`,`members`.`name` AS `forum_name`,`members`.`email` AS `email`,`gc`.`steam_name` AS `steam_name`,`gc`.`mta_name` AS `mta_name` from ((`gc_nickprotection` `nick` join `mrgreen_gc`.`green_coins` `gc`) join `mrgreen_forums`.`x_utf_l4g_members` `members`) where ((`nick`.`accountID` = `gc`.`id`) and (`gc`.`forum_id` = `members`.`member_id`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `achievements`
--
ALTER TABLE `achievements`
  ADD PRIMARY KEY (`forumID`,`achievementID`);

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
-- Indexes for table `maps_del`
--
ALTER TABLE `maps_del`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`);

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
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `gc_items`
--
ALTER TABLE `gc_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1155;
--
-- AUTO_INCREMENT for table `maps_del`
--
ALTER TABLE `maps_del`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=119;
--
-- AUTO_INCREMENT for table `serialsDB`
--
ALTER TABLE `serialsDB`
  MODIFY `serialid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=663842;
--
-- AUTO_INCREMENT for table `team`
--
ALTER TABLE `team`
  MODIFY `teamid` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `uploaded_maps`
--
ALTER TABLE `uploaded_maps`
  MODIFY `uploadid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=636;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `team`
--
ALTER TABLE `team`
  ADD CONSTRAINT `Team owner forumid` FOREIGN KEY (`owner`) REFERENCES `mrgreen_forums`.`x_utf_l4g_members` (`member_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `team_members`
--
ALTER TABLE `team_members`
  ADD CONSTRAINT `Forum account` FOREIGN KEY (`forumid`) REFERENCES `mrgreen_forums`.`x_utf_l4g_members` (`member_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Team members` FOREIGN KEY (`teamid`) REFERENCES `team` (`teamid`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
