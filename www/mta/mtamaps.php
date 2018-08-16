<?php
// File structure:
// upload.php (this file) is the main wrapper with the mrgreen layout
// -> mtamaps.php is included around line ~410 and contains some html about maps
// --> mtasettings.default.php contains the info about the servers, should be edited and renamed to mtasettings.php
// --> checkmtamap.php includes the functions that do most of the map syntax checking
// ---> mta_sdk is the "official" mta sdk 0.4 for php


// Script that handles logging in/out and uploading/sending maps,
// html at the bottom based on the variables we set in this part

// Import mta and sql connection settings
include( "mtasettings.php" );
// Import functions to check mta map
include( "checkmtamap.php" );

// Create mysql connection
$mysqli = @getDB($sql_server, $sql_user, $sql_pass, $sql_dbname);
if ($mysqli->connect_error)	exit("Database connection failed, try again later: " . $mysqli->connect_error);

// Handle login/logout
$loginerror = false;
if($_SERVER['REQUEST_METHOD'] == 'POST') { 
	if(isset($_POST['user'], $_POST['pass'])) {
		
		$user = trim($_POST['user']); //Username or emailaddress. Latter is preferred.
		$password = trim($_POST['pass']);
		 
		$url = 'https://mrgreengaming.com/api/account/login';
		$fields = array(
		'user' => urlencode($user),
		'password' => urlencode($password),
		'appId' => urlencode($appID),
		'appSecret' => urlencode($appSecret),
		);
		 
		//open connection
		$ch = curl_init();
		 
		//set the url, number of POST vars, POST data
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_POST, count($fields));
		curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($fields));
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		 
		//execute post
		$resultstring = curl_exec($ch);
		 
		//close connection
		curl_close($ch);
		 
		//Returns JSON. Use json_decode to decode
		$result = json_decode($resultstring);
		// var_dump($result);
		
		if ($resultstring == false || $result == null) {
			$loginerror = true;
			$loginmessage = "An error happened while connecting to mrgreengaming.com.";
		}
		elseif ($result->error == 0) {
			// Correct login details, set session variables
			$_SESSION['logged_in'] = true; 
			$_SESSION['user'] = $result->name;
			$_SESSION['forumid'] = $result->userId;
		}
		elseif ($result->error != 0) {
			$loginerror = true;
			$loginmessage = $result->errorMessage;
		}


		/*
		// User logging in, check password in database
		$stmt = $mysqli->prepare("SELECT member_id, members_pass_hash, members_pass_salt, mta_name FROM mrgreen_forums.x_utf_l4g_members m, mrgreen_gc.green_coins g WHERE (m.name=? OR m.email=?) AND m.member_id = g.forum_id AND g.valid = 1");
		if (!$stmt) exit("Statement failed, try again later");
		$user = trim($_POST['user']);
		$stmt->bind_param( "ss", $user, $user ); 
		$stmt->execute();
		$stmt->bind_result($member_id, $members_pass_hash, $members_pass_salt, $mta_name);
		$stmt->fetch();
		if ( md5(md5($members_pass_salt).md5(trim($_POST['pass']))) == $members_pass_hash ){
			// Correct login details, set session variables (mta nickname, forumid)
			$_SESSION['logged_in'] = true; 
			$_SESSION['user'] = $mta_name;
			$_SESSION['forumid'] = $member_id;
		}
		else
			$loginerror = true;	// Wrong password, show warning
		$stmt->close();
		*/
	}
	elseif(isset($_POST['submit']) && $_POST['submit'] == "Logout") {
		// Logging out, reset session variables
		$_SESSION['logged_in'] = false; 
		unset($_SESSION['user']); 
		unset($_SESSION['forumid']);
	}
} 


// Check if a map was uploaded
if (isset($_POST["upload"], $_FILES["zip_file"])) {
	$zip_file = $_FILES["zip_file"];
	
	// Messages to show to uploader
	$zipmessage = "";
	$mapmessage = "";
	$modemessage = "";
	$servermessage = "";
	
	// Map details
	$prefix = "";
	$filename = "";
	
	// Check if the zip file is valid
	$zipmessage = checkZipFile($zip_file, $prefix, $filename);
	if ($zipmessage == "Ok") {
		// Zip file is ok, move and unzip
		
		// Check which MTA server
		if ($prefix == "race") {
			$mta_host  = $mta_host_race;
			$mapfolder = $mapfolder_race;
			$http_port = $mta_http_port_race;
		} else {
			$mta_host  = $mta_host_mix;
			$mapfolder = $mapfolder_mix;
			$http_port = $mta_http_port_mix;
		}
		
		// Move target for the zip is in the [upload_maps]\zips
		$zip_path = $mapfolder.$zipsfolder.$filename.".zip";
		// Unpack target for new maps is in the upload folder/filename + suffix
		$folder_path = $mapfolder.$filename.$map_newsuffix.'/';
		
		// Open the zip and check the map files (meta, .map, scripts, source)
		$zip = new ZipArchive();
		$res = $zip->open($zip_file["tmp_name"]);
		if ($res != true)
			$mapmessage = "Your .zip file could not be opened. " . $res;

		// Check if the map should be added to the server
		elseif (($mapmessage = checkMTAMap($zip, $prefix, $modemessage)) != "Ok")
			$servermessage = "Map not ok.";
			
		// Check if the mode should be added to the server
		elseif ($modemessage != "Ok")
			$servermessage = "Map not ok.";
			
		elseif ( isset($_POST['onlytest']) ) 
			$servermessage = "Test upload, not adding map to the MTA server.";
			
		// Check if the zip can be moved to FTP
		elseif(!( $ftp_conn = ftp_connect($ftp_server) ))
			$servermessage = "There was a problem with the FTP server. Please try again later.";
			
		elseif(! ftp_login($ftp_conn, $ftp_username, $ftp_userpass) )
			$servermessage = "There was a problem with the FTP server login. Please try again.";
						
		else {
			// FTP connection ok, upload files
			ftp_pasv($ftp_conn, true);
			ftp_set_option($ftp_conn, FTP_TIMEOUT_SEC, 10);
			
			// if (ftp_is_dir($ftp_conn, $folder_path) )
				// $servermessage = "This map is already uploaded in the map queue";
				
			// elseif(! ftp_put($ftp_conn, $zip_path, $zip_file["tmp_name"], FTP_BINARY) )
			if(! ftp_put($ftp_conn, $zip_path, $zip_file["tmp_name"], FTP_BINARY) )
				$servermessage = "There was a problem with moving the zipfile to FTP. Please try again.";
				
			// Extract zip to folder in [uploaded_maps] dir with newmap suffix
			else {
				$servermessage = "Your zip file was uploaded to the mta server. Testing loading now...";
				ftp_mkdir($ftp_conn, $folder_path);
				$zip->open($zip_file["tmp_name"]);
				for($i = 0; $i < $zip->numFiles; $i++) {
					$iname = $zip->getNameIndex($i);
					// var_dump($iname,"zip://".$zip_file["tmp_name"]."#".$iname, is_dir("zip://".$zip_file["tmp_name"]."#".$iname), pathinfo($iname)); echo ".";
					if (substr($iname,-1) == "/")
						ftp_mkdir($ftp_conn, $folder_path.$iname);
					else
						ftp_put($ftp_conn, $folder_path.$iname, "zip://".$zip_file["tmp_name"]."#".$iname, FTP_BINARY);
				}
				$zip->close();

				// Notify the server a new mta map was uploaded
				$returns = false;
				$mtaServer = new mta($mta_host, $http_port);
				try { $returns = $mtaServer->getResource("maptools")->call("newMap", $filename, $_SESSION['forumid'], $_SESSION['user']); }
				catch (Exception $e) {}
				$mta_error = $returns[0];
				$status = $returns[1];
				
				// Check the response from the mta server, if something is wrong then remove the folder again
				if (!$returns) {	// Couldn't connect to mta
					$servermessage = "Could not connect with the MTA server, check if it is online and try again";
					ftp_rdel($ftp_conn, $folder_path);
				}
				elseif (strlen($mta_error) > 1 ) {	// MTA server reported an error
					// $servermessage = "Error while loading map: " . $mta_error;
					// ftp_rdel($ftp_conn, $folder_path);
					
					// Try again, quick try for a fix 17/01/2016
					// Notify the server a new mta map was uploaded
					$returns = false;
					try { $returns = $mtaServer->getResource("maptools")->call("newMap", $filename, $_SESSION['forumid'], $_SESSION['user']); }
					catch (Exception $e) {}
					$mta_error = $returns[0];
					$status = $returns[1];
					
					// Check the response from the mta server, if something is wrong then remove the folder again
					if (!$returns) {	// Couldn't connect to mta
						$servermessage = "Could not connect with the MTA server, check if it is online and try again";
						ftp_rdel($ftp_conn, $folder_path);
					}
					elseif (strlen($mta_error) > 1 ) {	// MTA server reported an error
						$servermessage = "Error while loading map: " . $mta_error;
						ftp_rdel($ftp_conn, $folder_path);
					}
					else {
						// MTA server reported adding is ok, add map to database
						$stmt = $mysqli->prepare("INSERT INTO `uploaded_maps` (forumid, uploadername, resname, status, comment) VALUES (?,?,?,?,?)");
						$stmt->bind_param("issss", $forumid, $uploadername, $filename, $status, $comment);
						$forumid = (int)$_SESSION['forumid'];
						$uploadername = $_SESSION['user'];
						$comment = substr(trim($_POST['comment']), 0, 255);
						$stmt->execute();
						
						$servermessage = "Map loaded successfully. Now wait untill a mapmanager tests it!";
					}
				}
				else {
					// MTA server reported adding is ok, add map to database
					$stmt = $mysqli->prepare("INSERT INTO `uploaded_maps` (forumid, uploadername, resname, status, comment) VALUES (?,?,?,?,?)");
					$stmt->bind_param("issss", $forumid, $uploadername, $filename, $status, $comment);
					$forumid = (int)$_SESSION['forumid'];
					$uploadername = $_SESSION['user'];
					$comment = substr(trim($_POST['comment']), 0, 255);
					$stmt->execute();
					
					$servermessage = "Map loaded successfully. Now wait untill a mapmanager tests it!";
				}
			}
		}
	}
}
?>

<h3>Map upload</h3><br/>
<?php if(!isset($_SESSION['logged_in']) || $_SESSION['logged_in'] == false) { ?>
	<!-- Login form for uploading -->
	<form method="post" action=""> 
		<p> 
			<label for="user">Forum email:</label> 
			<input type="text" name="user" id="users" /> 
		</p>
		<p> 
			<label for="pass">Forum password:</label> 
			<input type="password" name="pass" id="pass" /> 
		</p>
		<?php if ($loginerror == true) {
			echo '<br/><p style="color:red">' . htmlspecialchars($loginmessage) . '</p><br/>';
		} ?>
		<p> 
			<input type="submit" value="Login" /> 
		</p> 
	</form>
<?php } else { ?>
	<form method="post" action="">
		<p>Hello <?php echo htmlspecialchars($_SESSION['user']." (".$_SESSION['forumid']) .")"; ?>
			<input type="submit" name="submit" value="Logout" />
		</p>
	</form>
	
	<br>
	<?php if( isset($_POST["upload"]) ) {
		echo "<h3>Upload results </h3><br/>";
		echo "<p> File " . htmlspecialchars($_FILES["zip_file"]["name"] . ' ('. $_FILES["zip_file"]["size"]) . ")</p>";
		echo "<p> Zip: " . htmlspecialchars($zipmessage) . "</p>";
		echo "<p> Map: " . htmlspecialchars($mapmessage) . "</p>";
		echo "<p> " . htmlspecialchars($prefix) . " mode: " . htmlspecialchars($modemessage) . "</p>";
		echo "<p> Server: " . htmlspecialchars($servermessage) . "</p>";
		echo "<br/>";
	} ?>
	
	<form enctype="multipart/form-data" method="post" action="">
		<label>Choose a zip file to upload: <input type="file" name="zip_file" /></label><br/><br/>
		Comment about map (optional): <input type="text" name="comment" value="" size="100" maxlength="100" /><br/><br/>
		<input type="checkbox" name="onlytest" value="Bike"> Don't upload map to server, check this if you want to test the map syntax</input><br/><br/>
		<input type="submit" name="submit" value="Upload" />
		<input type="hidden" name="upload" value="Upload" /><br/><br/>
	</form>
<?php } ?>
<br>
<h3>Uploads</h3>
<br>
<table id="mtauploadstable" class="display">
	<thead>
		<tr>
			<th>#</th>
			<th>Map Name</th>
			<th>Uploader</th>
			<th>Date</th>
			<th>Status</th>
			<th>Manager</th>
			<th>Comment</th>
		</tr>
	</thead>
	<tbody>
	<?php	
		$results = $mysqli->query("SELECT * FROM `uploaded_maps` ORDER BY date DESC");
		while($row = $results->fetch_assoc()) {
			echo "<tr>";
				echo '<td class="uploadid">' . htmlspecialchars($row['uploadid']) . "</td>";
				echo "<td>" . htmlspecialchars($row['resname']) . "</td>";
				echo "<td>" . htmlspecialchars($row['uploadername']) . "</td>";
				echo '<td class="date">' . htmlspecialchars($row['date']) . "</td>";
				echo "<td>" . htmlspecialchars($row['status']) . "</td>";
				echo "<td>" . htmlspecialchars($row['manager']) . "</td>";
				echo '<td class="comment">' . htmlspecialchars($row['comment']) . "</td>";
			echo "</tr>";
		}
	?>
	</tbody>
</table>
<script type="text/javascript">
tcJq(document).ready(function() {
    tcJq('#mtauploadstable').DataTable( {
        "order": [[ 0, "desc" ]]
    } );
} );</script>
<style type='text/css'>
td.comment {
	width: 33%;
}
td.uploadid, td.date {
    width: 1px;
    white-space: nowrap;
}
</style>