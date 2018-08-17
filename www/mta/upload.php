<?php 
// File structure:
// upload.php (this file) is the main wrapper with the mrgreen layout
// -> mtamaps.php is included around line ~410 and contains some html about maps
// --> mtasettings.default.php contains the info about the servers, should be edited and renamed to mtasettings.php
// --> checkmtamap.php includes the functions that do most of the map syntax checking
// ---> mta_sdk is the "official" mta sdk 0.4 for php

session_start(); 
?>
<!DOCTYPE html>
	<html lang="en">
	<head>
		<meta charset="UTF-8" />
		<title>Mr. Green Gaming Upload MTA maps</title>
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <style>
            body {
                font-family: sans-serif;
                background-color: #7D9984;
                margin: 0;
                padding: 0;
            }

            body > div {
                max-width: 1000px;
                background-color: #FFF;
                box-sizing: border-box;
                border: 2px solid #47995d;
                margin: 10px;
                padding: 10px;
                text-align: left;
            }

            table {
                width: 100%;
            }
        </style>
    </head>
    <body>
        <div>
				<!-- ::: CONTENT ::: -->
				<?php include( "mtamaps.php" ); ?>
        </div>
    </body>
</html>