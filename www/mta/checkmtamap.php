<?php
// File structure:
// upload.php (this file) is the main wrapper with the mrgreen layout
// -> mtamaps.php is included around line ~410 and contains some html about maps
// --> mtasettings.default.php contains the info about the servers, should be edited and renamed to mtasettings.php
// --> checkmtamap.php includes the functions that do most of the map syntax checking
// ---> mta_sdk is the "official" mta sdk 0.4 for php


// check mapname and mode
// send to correct server
// login
// allow delete uploads that are not checked yet

include( "mta_sdk.php" );

// Create connection
function getDB($servername, $username, $password, $dbname) {
	return new mysqli($servername, $username, $password, $dbname);
}

function rrmdir($dir) { 
	if (is_dir($dir)) { 
		$objects = scandir($dir); 
		foreach ($objects as $object) { 
			if ($object != "." && $object != "..") { 
				if (filetype($dir."/".$object) == "dir") rrmdir($dir."/".$object); else unlink($dir."/".$object); 
			} 
		} 
		reset($objects); 
		rmdir($dir); 
	} 
}

function ftp_rdel ($handle, $path) {

  if (@ftp_delete ($handle, $path) === false) {

    if ($children = @ftp_nlist ($handle, $path)) {
      foreach ($children as $p)
        ftp_rdel ($handle,  $p);
    }

    @ftp_rmdir ($handle, $path);
  }
}

function ftp_is_dir($ftp, $dir)
{
    $pushd = ftp_pwd($ftp);

    if ($pushd !== false && @ftp_chdir($ftp, $dir))
    {
        ftp_chdir($ftp, $pushd);   
        return true;
    }

    return false;
}

// Checks if the zip file is valid (name, not corrupted)
// If it's acceptable returns "Ok', else a reason
function checkZipFile($zip, &$prefix, &$filename) {
	// Check if a file was uploaded
	if(!isset($_SESSION['logged_in']) || $_SESSION['logged_in'] == false)
		return "You are not logged in!";
	
	// Check the dots in the filename
	$dotexplode = explode(".", strtolower($zip["name"]));
	if (count($dotexplode) != 2 )
		return "Mta maps need one . dot in the filename!";
	elseif ($dotexplode[1] != "zip")
		return "The file you are trying to upload is not a .zip file. Please try again. (2)";
	$filename = $dotexplode[0];
	
	if (preg_match('/[^A-z0-9\-_.]/', $zip["name"]))
		return "Map filename contains illegal characters (allowed: A-z, 0-9, _)";
	
	// Check the mime_type of the file
	// $mime_type_okay = false;
	// $accepted_types = array('application/zip', 'application/x-zip-compressed', 'multipart/x-zip', 'application/x-compressed', 'application/octet-stream');
	// foreach($accepted_types as $mime_type) if($mime_type == $zip["type"]) $mime_type_okay = true;
	// if(!$mime_type_okay)
		// return "The file you are trying to upload is not a .zip file. Please try again. (3) $type";
	
	// Check the mode prefix
	$dashexplode = explode("-", strtolower($zip["name"]));
	$prefix = $dashexplode[0];
	if (strlen($zip["name"]) < strlen("dd-d.zip") || !($prefix=="race" or $prefix=="rtf" or $prefix=="ctf" or $prefix=="nts" or $prefix=="dd" or $prefix=="sh"))
		return "Map filename has to start with race- or rtf- or ctf- or nts- or dd- or sh-";

	// Check the size of the zip
	if ($zip["size"] > 5*1024*1024)
		return "Max file size is 5 MB zipped ($size)";
	
	// Check if the zip can be opened
	$tmpZip = new ZipArchive;
	$res = $tmpZip->open($zip["tmp_name"], ZipArchive::CHECKCONS);
	if ($res === TRUE)
		$tmpZip->close();
	else {
		switch($res){
            case ZipArchive::ER_EXISTS: 
                $ErrMsg = "File already exists";
                break;

            case ZipArchive::ER_INCONS: 
                $ErrMsg = "Zip archive inconsistent";
                break;
                
            case ZipArchive::ER_MEMORY: 
                $ErrMsg = "Malloc failure";
                break;
                
            case ZipArchive::ER_NOENT: 
                $ErrMsg = "No such file";
                break;
                
            case ZipArchive::ER_NOZIP: 
                $ErrMsg = "Not a zip archive";
                break;
                
            case ZipArchive::ER_OPEN: 
                $ErrMsg = "Can't open file";
                break;
                
            case ZipArchive::ER_READ: 
                $ErrMsg = "Read error";
                break;
                
            case ZipArchive::ER_SEEK: 
                $ErrMsg = "Seek error";
                break;
            
            default: 
                $ErrMsg = "Unknown (Code ".$res.")";
                break;
		}
		return "The zip file could not be opened! (" . $ErrMsg . ")";
	}
	
	// Check if the map already is uploaded
	// if (file_exists($target_path) )
		// return "This map name is already uploaded in the map queue";
	return "Ok";
}

function checkMTAMap($zip, $prefix, &$modemessage){
	// Check if the resource has the meta file
	if ( $zip->getFromName("meta.xml") == false) {
		return "Your map has no meta.xml";
	}
	
	// Parse the meta.xml file
	$meta = $zip->getFromName("meta.xml");
	$meta=preg_replace('/&(?!#?[a-z0-9]+;)/', '&amp;', $meta);
	libxml_use_internal_errors(true);
	$metaxml = simplexml_load_string($meta);
	if (!$metaxml) {
		$message = "Could not parse meta.xml! Errors:";
		foreach(libxml_get_errors() as $error)
			$message .= "<br> * " . $error->message;
		return $message;
	}
	
	// Check meta node
	if ($metaxml->getName() != "meta")
		return "No < meta > node in meta.xml.";

	// Check if all script/map/file sources exist
	$infonode = false;
	$srcmissing = false;
	$messagemissing = "Meta.xml: Missing files:";
	$maps = 0;
	$mapsrc = false;
	foreach($metaxml->children() as $node) { 
		$n = $node->getName();
		$attr = $node->attributes();
		if ($n == "info")
			$infonode = $node;
		elseif ($n == "script" || $n == "map" || $n == "file" || $n == "config" || $n == "html") {
			if ($n == "map") {
				$maps++;
				$mapsrc = $attr["src"];
			}
			if (!isset($attr["src"]) or $attr["src"] == ""){
				$srcmissing = true;
				$messagemissing .= "<br/>* Missing < $n > src";
			}
			elseif ($zip->getFromName($attr["src"]) == false) {
				$srcmissing = true;
				$messagemissing .= "<br/>* < $n > src not found: " . $attr["src"];
			}
		}
	}
	
	// Check missing source
	if ($srcmissing)
		return $messagemissing;
	
	// Check if there's one map file
	if ($maps != 1)
		return "Meta.xml: You need to have one map file in your meta";
	
	// Check the info node
	if (!$infonode)
		return "Missing info node in meta.xml";
	
	// Check resource type = map
	if ($infonode["type"] != "map")
		return "Meta.xml info: type is not map";
	
	// Check gamemode = race
	if ($infonode["gamemodes"] != "race")
		return "Meta.xml info: gamemodes is not race";
	
	// Parse the .map file
	$mapfile = $zip->getFromName($mapsrc);
	libxml_use_internal_errors(true);
	$mapxml = simplexml_load_string($mapfile);
	if (!$mapxml) {
		$message = "Could not parse $mapsrc! Errors:";
		foreach(libxml_get_errors() as $error)
			$message .= "<br> * " . $error->message;
		return $message;
	}
	
	$racemode_i = $infonode["racemode"];
	
	foreach($metaxml->settings[0]->children() as $node){
		if ($node->getName() == "setting" && $node["name"] == "#racemode"){
			$racemode_s = $node['value'];
		}
	}
	
	// Resource parsing is ok, do mode checks now
	switch($prefix){
		case "rtf":
			if ( isset($racemode_i) ) {	if (strtolower($racemode_i) != "rtf") return "RTF: Not a valid racemode info in meta.xml";
			} elseif ( isset($racemode_s) ) { if ( !($racemode_s == "RTF" || $racemode_s == '[ "RTF" ]') ) return "RTF: Not a valid racemode setting in meta.xml";
			} else return "RTF: No racemode in meta.xml";
			$modemessage = checkRTFMap($mapxml);
			break;
		
		case "ctf":
			if ( isset($racemode_i) ) {	if (strtolower($racemode_i) != "ctf") return "CTF: Not a valid racemode info in meta.xml";
			} elseif ( isset($racemode_s) ) { if ( !($racemode_s == "CTF" || $racemode_s == '[ "CTF" ]') ) return "CTF: Not a valid racemode setting in meta.xml";
			} else return "CTF: No racemode in meta.xml";
			$modemessage = checkCTFMap($mapxml);
			break;
		
		case "nts":
			$modemessage = checkNTSMap($mapxml);
			if ( isset($racemode_i) ) {	if (strtolower($racemode_i) != "nts") return "NTS: Not a valid racemode info in meta.xml";
			} elseif ( isset($racemode_s) ) { if ( !($racemode_s == "NTS" || $racemode_s == '[ "NTS" ]') ) return "NTS: Not a valid racemode setting in meta.xml";
			} else return "NTS: No racemode in meta.xml";
			break;
		
		case "sh":
			if ( isset($racemode_i) ) {	if (strtolower($racemode_i) != "shooter") return "Shooter: Not a valid racemode info in meta.xml";
			} elseif ( isset($racemode_s) ) { if ( !($racemode_s == "Shooter" || $racemode_s == '[ "Shooter" ]') ) return "Shooter: Not a valid racemode setting in meta.xml";
			} else return "Shooter: No racemode in meta.xml";
			$modemessage = checkDDSHMap($mapxml);
			break;
		
		case "dd":
			$modemessage = checkDDSHMap($mapxml);
			break;
		
		default: // race
			$modemessage = checkRaceMap($mapxml);
			break;
	}

	$zip->close();
	return "Ok";
}

function checkRaceMap($mapxml) {
	// Check spawns and checkpoints
	$spawns = 0;
	$checkpoints = 0;
	foreach($mapxml->children() as $node) { 
		$n = $node->getName();
		if ($n == "spawnpoint")	$spawns++;
		elseif ($n == "checkpoint") $checkpoints++;
	}
	
	if ($spawns < 50)
		return "Need 50 spawnpoints ($spawns/50)";
	elseif ($checkpoints == 0)
		return "Need checkpoints in a race map";
	
	return "Ok";
}

function checkRTFMap($mapxml) {
	// Check spawns and rtf element
	$spawns = 0;
	$rtf = 0;
	foreach($mapxml->children() as $node) { 
		$n = $node->getName();
		if ($n == "spawnpoint")	$spawns++;
		elseif ($n == "rtf") $rtf++;
	}
	
	if ($spawns < 50)
		return "Need 50 spawnpoints ($spawns/50)";
	elseif ($rtf != 1)
		return "Need one rtf flag ($rtf/1)";
	
	return "Ok";
}

function checkCTFMap($mapxml) {
	// Check team spawns, and rtf element
	$spawnsblue = 0;
	$spawnsred = 0;
	$ctfred = 0;
	$ctfblue = 0;
	foreach($mapxml->children() as $node) { 
		$n = $node->getName();
		$attr = $node->attributes();
		if ($n == "spawnpoint")	{
			if (!isset($attr["team"]) or !($attr["team"] == "red" or $attr["team"] == "blue") )	return ("Spawnpoint #$spawnsblue+$spawnsred+1 has no correct team set");
			elseif ($attr["team"] == "red") 	$spawnsred++;
			elseif ($attr["team"] == "blue") 	$spawnsblue++;
		}
		elseif ($n == "ctfred") $ctfred++;
		elseif ($n == "ctfblue") $ctfblue++;
	}
	
	if ($spawnsblue < 25)
		return "Need 25 blue spawnpoints ($spawnsblue/25)";
	elseif ($spawnsred < 25)
		return "Need 25 red spawnpoints ($spawnsred/25)";
	elseif ($ctfred != 1)
		return "Need one red flag ($ctfred/1)";
	elseif ($ctfblue != 1)
		return "Need one blue flag ($ctfblue/1)";
	
	return "Ok";
}

function checkNTSMap($mapxml) {
	// Check spawns and nts checkpoints
	$spawns = 0;
	$checkpoints = 0;
	foreach($mapxml->children() as $node) { 
		$n = $node->getName();
		$attr = $node->attributes();
		if ($n == "spawnpoint")	$spawns++;
		elseif ($n == "checkpoint") {
			if (!isset($attr["nts"]) or !($attr["nts"] == "vehicle" or $attr["nts"] == "boat" or $attr["nts"] == "air"))
				return ("Checkpoint #$checkpoints+1 has no correct nts type (vehicle/air/boat) set");
			$checkpoints++;
		}
	}
	
	if ($spawns < 50)
		return "Need 50 spawnpoints ($spawns/50)";
	elseif ($checkpoints == 0)
		return "Need checkpoints in a nts map";
	
	return "Ok";
}


function checkDDSHMap($mapxml) {
	// Check spawns
	$spawns = 0;
	foreach($mapxml->children() as $node) { 
		$n = $node->getName();
		if ($n == "spawnpoint")	$spawns++;
	}
	
	if ($spawns < 50)
		return "Need 50 spawnpoints ($spawns/50)";

	return "Ok";
}

?>
