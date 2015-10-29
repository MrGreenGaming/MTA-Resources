<?php
// File structure:
// upload.php (this file) is the main wrapper with the mrgreen layout
// -> mtamaps.php is included around line ~410 and contains some html about maps
// --> mtasettings.default.php contains the info about the servers, should be edited and renamed to mtasettings.php
// --> checkmtamap.php includes the functions that do most of the map syntax checking
// ---> mta_sdk is the "official" mta sdk 0.4 for php

	// MTA servers settings
	$mta_host_race 		= "localhost";
	$mta_host_mix		= "localhost";
	$mta_http_port_race = 22005;
	$mta_http_port_mix 	= 22105;
	$map_newsuffix		= "_newupload";
	
	// ftp server
	$ftp_server = "localhost";
	$ftp_username = "mtamapupload";
	$ftp_userpass = "mtamapupload";
	$mapfolder_race		= "/Race/";
	$mapfolder_mix		= "/RaceMix/";
	$zipsfolder			= "zips/";

	// SQL connection settings
	$sql_server = "localhost";		
	$sql_user 	= "root";
	$sql_pass 	= "root";
	$sql_dbname = "mrgreen_mtasrvs";
	
	// API access
	$appID = ;
	$appSecret = ;
?>