CREATE TABLE `achievements` (
  `forumID` int(11) NOT NULL,
  `achievementID` int(11) NOT NULL,
  `unlockedDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `unlocked` tinyint(1) NOT NULL DEFAULT '0',
  `progress` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`forumID`,`achievementID`)
);
