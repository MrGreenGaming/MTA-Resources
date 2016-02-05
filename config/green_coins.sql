-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Nov 06, 2015 at 11:23 PM
-- Server version: 5.6.19
-- PHP Version: 5.6.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mrgreen_gc`
--

-- --------------------------------------------------------

--
-- Table structure for table `green_coins`
--

CREATE TABLE `green_coins` (
  `id` int(32) NOT NULL,
  `steam_id` varchar(32) DEFAULT NULL,
  `minecraft_id` varchar(32) DEFAULT NULL,
  `forum_id` int(11) DEFAULT NULL,
  `steam_name` varchar(64) DEFAULT NULL,
  `mta_name` varchar(64) DEFAULT NULL,
  `amount_current` int(11) UNSIGNED DEFAULT NULL,
  `last_edit` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `valid` tinyint(1) DEFAULT '1'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `green_coins`
--
ALTER TABLE `green_coins`
  ADD PRIMARY KEY (`id`),
  ADD KEY `forum_id` (`forum_id`),
  ADD KEY `minecraft_id` (`minecraft_id`),
  ADD KEY `steam_id` (`steam_id`),
  ADD KEY `valid` (`valid`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `green_coins`
--
ALTER TABLE `green_coins`
  MODIFY `id` int(32) NOT NULL AUTO_INCREMENT;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
