CREATE TABLE `gc_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `forumid` int(10) unsigned NOT NULL,
  `itembought` int(10) unsigned NOT NULL,
  `expires` int(10) unsigned DEFAULT NULL,
  `options` varchar(45) DEFAULT '[ [ ] ]',
  PRIMARY KEY (`id`)
)