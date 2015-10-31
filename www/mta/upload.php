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
	<html lang="en"  xmlns:fb="http://www.facebook.com/2008/fbml">
	<head>
		<meta charset="UTF-8" />
		<title>Mr. Green Gaming Upload MTA maps</title>
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<link rel="shortcut icon" href='http://mrgreengaming.com/forums/favicon.ico' />
		<link rel="image_src" href='http://mrgreengaming.com/forums/public/style_images/tctc91_glare/meta_image.png' />
		
	
				
	

				
	

				
	

				
	

				
	

				
	

				
	
	
		<link rel="stylesheet" type="text/css" media='screen,print' href="http://mrgreengaming.com/forums/public/min/index.php?ipbv=44263936a383e51f73db32be26439659&amp;f=public/style_css/css_12/facebook_like_box.css,public/style_css/css_12/tctc91_general.css,public/style_css/css_12/ipb_help.css,public/style_css/css_12/ipb_styles.css,public/style_css/css_12/calendar_select.css,public/style_css/css_12/ipb_common.css,public/style_css/css_12/ipshoutbox.css" />
	

<!--[if lte IE 7]>
	<link rel="stylesheet" type="text/css" title='Main' media="screen" href="http://mrgreengaming.com/forums/public/style_css/css_12/ipb_ie.css" />
<![endif]-->
<!--[if lte IE 8]>
	<style type='text/css'>
		.ipb_table { table-layout: fixed; }
		.ipsLayout_content { width: 99.5%; }
	</style>
<![endif]-->

	<style type='text/css'>
		img.bbc_img { max-width: 100% !important; }
	</style>

		<meta property="og:title" content="Mr. Green Gaming"/>
		<meta property="og:site_name" content="Mr. Green Gaming"/>
		<meta property="og:type" content="article" />
		
	
		
		
			<meta name="description" content="Mr. Green Gaming providers gameservers for various games." />
		
		
		
			<meta property="og:description" content="Mr. Green Gaming providers gameservers for various games." />
		
		
	

		
		
			<meta name="identifier-url" content="http://mrgreengaming.com/forums/" />
		
		
			<meta property="og:url" content="http://mrgreengaming.com/forums/" />
		
		
		
	

<meta property="og:image" content="http://mrgreengaming.com/forums/public/style_images/tctc91_glare/meta_image.png"/>
		
		


	
		
			
			
			
			
				<link id="ipsCanonical" rel="canonical" href="http://mrgreengaming.com/forums/" />
			
		
	

		
			
			
				<link rel="alternate" type="application/rss+xml" title="Community Calendar" href="http://forums.mrgreengaming.com/rss/calendar/1-community-calendar/" />
			
			
			
		
	

	



		
<style type='text/css'>
#content, .main_width { width: 1200px; !important; }
body { font: normal 13px "Helvetica", helvetica, arial, sans-serif; }

#primary_nav, .maintitle, .category_block .ipb_table h4, .ipsSideBlock h3,
#breadcrumb .left, #footer, #user_navigation a, .popupInner h3, .guestMessage,
.ipsType_pagetitle, .ipsType_subtitle, table.ipb_table h4, table.ipb_table .topic_title,
#branding .siteLogo
{ 
font-family: "Titillium Web", helvetica, arial, sans-serif; 
}


#search { display: none; visibility: hidden; }

</style>

<!--<link href='//fonts.googleapis.com/css?family=Titillium+Web:400,700&subset=latin,latin-ext' rel='stylesheet' type='text/css'>-->

<!-- tomchristian.co.uk Custom JS -->
<script type="text/javascript">
	isjQuery = false;
	if (!window.jQuery) {
		document.write("<" + "script type='text/javascript' src='https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js'></" + "script>");
		isjQuery = true;
	}
</script>
<script type="text/javascript">
	if(isjQuery){
		tcJq = jQuery.noConflict();
	} else {
		tcJq = jQuery;
	}
</script>
<script type="text/javascript" src="http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/js/cookie.js"></script>
<script type="text/javascript" src="http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/js/main.js"></script>
<link href='http://fonts.googleapis.com/css?family=Titillium+Web:400,700&subset=latin,latin-ext' rel='stylesheet' type='text/css'>

<link rel="stylesheet" type="text/css" media='screen,print' href="https://cdn.datatables.net/1.10.8/css/jquery.dataTables.min.css" />
<script type="text/javascript" src="//cdn.datatables.net/1.10.8/js/jquery.dataTables.min.js"></script>

	</head>
	<body id='ipboard_body'>
<!--		<div class="topWarning">
Receiving emails from the forums finally works. Didn't receive email validation? Send an email to mail@mrgreengaming.com
		</div>-->
		<p id='content_jump' class='hide'><a id='top'></a><a href='#j_content' title='Jump to content' accesskey='m'>Jump to content</a></p>
		<div id='ipbwrapper' class='tcGlare'>
			<!-- ::: BRANDING STRIP: Logo, nav and search box ::: -->
			<div id='branding'>
				<div class='main_width'>	
					<!-- ::: TOP BAR: Sign in / register or user drop down and notification alerts ::: -->
					<div id="header_right" class="right">
						<div id='header_bar' class='clearfix'>
							<div id='user_navigation' class='not_logged_in'>
									<ul class='ipsList_inline right'>
																			
									</ul>
								</div>
						</div>						
					</div><!-- /header_right -->				
					<div id="headerPanel">
						<div id='logo'>
							
								
<a href='http://mrgreengaming.com/forums' title='Go to community index' rel="home" accesskey='1'><div class="siteLogo"><h1>Mr. Green Gaming</h1><span>Your Multiplayer Community</span></div></a>

							
						</div>	
						<!-- ::: APPLICATION TABS ::: -->

						<div class="headerRight">
							<div id='primary_nav' class='clearfix'>
								<ul class='ipsList_inline' id='community_app_menu'>
											<li id='nav_other_search'>
													<a href='http://mrgreengaming.com/forums/index.php?app=core&amp;module=search&amp;search_in=forums' title='Advanced Search' accesskey='4' rel="search" class='jq_show_search'><img src="http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/transparent.png" alt="Search" class="sprite icon_nav_search" /></a>

												</li>
												<div id='search' class='right'>
	<form action="http://mrgreengaming.com/forums/index.php?app=core&amp;module=search&amp;do=search&amp;fromMainBar=1" method="post" id='search-box' >
		<fieldset>
			<label for='main_search' class='hide'>Search</label>
			<a href='http://mrgreengaming.com/forums/index.php?app=core&amp;module=search&amp;search_in=forums' title='Advanced Search' accesskey='4' rel="search" id='adv_search' class='right'>Advanced</a>
			<span id='search_wrap' class='right'>
				<input type='text' id='main_search' name='search_term' class='inactive' size='17' tabindex='100' />
				<span class='choice ipbmenu clickable' id='search_options' style='display: none'></span>
				<ul id='search_options_menucontent' class='ipbmenu_content ipsPad' style='display: none'>
					<li class='title'><strong>Search section:</strong></li>
					
					
					
					<li class='app'><label for='s_forums' title='Forums'><input type='radio' name='search_app' class='input_radio' id='s_forums' value="forums" checked="checked" />Forums</label></li>
					<li class='app'><label for='s_members' title='Members'><input type='radio' name='search_app' class='input_radio' id='s_members' value="members"  />Members</label></li>
					<li class='app'><label for='s_core' title='Help Files'><input type='radio' name='search_app' class='input_radio' id='s_core' value="core"  />Help Files</label></li>
					
						
					

						
					

						
					

						<li class='app'>
								<label for='s_calendar' title='Calendar'>
									<input type='radio' name='search_app' class='input_radio' id='s_calendar' value="calendar"  />Calendar
								</label>
							</li>
					

						
					

						
					
				</ul>
				<input type='submit' class='submit_input clickable' value='Search' />
			</span>
			
		</fieldset>
	</form>
</div>
									
<li id='nav_mapupload' class='left active'><a href='upload.php' title='Upload maps to the MTA servers'><b>Map upload</b></a></li>
<li id='nav_greencoins' class='left'><a href='http://mrgreengaming.com/greencoins.php' title='GreenCoins'><b>GreenCoins</b></a></li>
<li id='nav_chat' class='left'><a href='http://mrgreengaming.com/chat.php' title='Join our chat'>Chat</a></li>
									
											
												
											

												
																										<li id='nav_app_members' class="left "><a href='http://mrgreengaming.com/forums/members/' title='Go to Members'>Members</a></li>
												
											

												
																										<li id='nav_app_forums' class="left"><a href='http://mrgreengaming.com/forums/' title='Go to Forums'>Forums</a></li>
												
											

												
											

												
											

												
											
										
									<!--<li id='nav_other_apps' style='display: none'>
										<a href='#' class='ipbmenu' id='more_apps'>More <img src='http://mrgreengaming.com/forums/public/style_images/tctc91_glare/useropts_arrow.png' /></a>
									</li>-->
								</ul>
							</div><!-- /primary_nav -->	
						</div>
					</div>
				</div><!-- /main_width -->

				

			</div><!-- /branding -->

			<!-- ::: NAVIGATION BREADCRUMBS ::: -->
<!--<div align="center" style="font-size: 20px;font-weight:bold;padding:4px;text-decoration:underline;"><a href="http://mrgreengaming.com/forums/topic/14944-team-fortress-fun-event/?p=125166">Todays TF2 Fun Event has been CANCELLED and will be rescheduled</a></div>-->
			<div id='breadcrumb' class='clearfix'>
					<div class="main_width">
						<div class="crumb left">
							
								<a href='http://mrgreengaming.com/forums/' itemprop="url"><span></span></a>
								
							<div id='secondary_navigation' class='clearfix'>
								
							</div><!-- /secondary_navigation -->
						</div><!-- /crumb_left -->
						<div class="social_media">
						<!-- FACEBOOK -->
	
		<div class="social_links">
			<a target="_blank" href="https://www.facebook.com/mrgreengaming"><img data-tooltip="Like us on Facebook!" src="http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/transparent.png" alt="social" class="_social icon_facebook icon_reg" /></a>
			<a target="_blank" href="https://www.facebook.com/mrgreengaming"><img src="http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/transparent.png" alt="social" class="_social icon_facebook_b icon_hover" /></a>
		</div>
	
	<!-- / FACEBOOK -->
	<!-- TWITTER -->
	
	<!-- / TWITTER -->
	<!-- GOOGLE+-->
	
		<div class="social_links">
			<a target="_blank" href="https://plus.google.com/103561350129065546893"><img data-tooltip="Follow us on Google+" src="http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/transparent.png" alt="social" class="_social icon_google icon_reg" /></a>
			<a target="_blank" href="https://plus.google.com/103561350129065546893"><img src="http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/transparent.png" alt="social" class="_social icon_google_b icon_hover" /></a>
		</div>
	
	<!-- / GOOGLE+-->
	<!-- YOUTUBE -->	
	
	<!-- / YOUTUBE  -->
	<!-- RSS -->
	
	<!-- / RSS -->
	<!-- LINKEDIN-->
	
	<!-- / LINKEDIN-->
	<!-- PAYPAL-->
	
	<!-- / PAYPAL-->
	<!-- SKYPE-->
	
	<!-- / SKYPE-->
	<!-- VIMEO -->
	
	<!-- / VIMEO -->
	<!-- LASTFM -->
	
	<!-- / LASTFM -->
						</div><!-- /social_media -->
					</div><!-- /main_width -->
				</div><!-- /Breadcrumb-->
			<noscript>
				<div class='message error'>
					<strong>Javascript Disabled Detected</strong>
					<p>You currently have javascript disabled. Several functions may not work. Please re-enable javascript to access full functionality.</p>
				</div>
				<br />
			</noscript>
				
			<!-- ::: MAIN CONTENT AREA ::: -->
			<div id='content' class='clearfix'>

				<style type='text/css'>
.bgChooser ul li a#bg-1 { background: url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-1.jpg) no-repeat -1006px -250px; }
.bgChooser ul li a#bg-2 { background: url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-2.jpg) no-repeat -625px -450px; }
.bgChooser ul li a#bg-3 { background: url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-3.jpg) no-repeat 0 0; }
.bgChooser ul li a#bg-4 { background: url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-4.jpg) no-repeat -655px -450px; }
.bgChooser ul li a#bg-5 { background: url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-5.jpg) no-repeat -792px -142px; }
.bgChooser ul li a#bg-6 { background: url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-6.jpg) no-repeat -655px -450px; }
.bgChooser ul li a#bg-7 { background: url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-7.jpg) no-repeat 0 0; }
.bgChooser ul li a#bg-8 { background: url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-8.jpg) no-repeat 0 0; }

body.bg-default #branding, body.bg-default .maintitle, body.bg-default #footer, body.bg-default .ipsSideBlock h3,
body.bg-default #profile_panes_wrap .general_box h3 {

	background: url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-5.jpg);

}

body.bg-1 #branding, body.bg-1 .maintitle, body.bg-1 #footer, body.bg-1 .ipsSideBlock h3,
body.bg-1 #profile_panes_wrap .general_box h3 {
	background: #fff url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-1.jpg);
}

body.bg-2 #branding, body.bg-2 .maintitle, body.bg-2 #footer, body.bg-2 .ipsSideBlock h3,
body.bg-2 #profile_panes_wrap .general_box h3 {
	background: #fff url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-2.jpg);
}

body.bg-3 #branding, body.bg-3 .maintitle, body.bg-3 #footer, body.bg-3 .ipsSideBlock h3,
body.bg-3 #profile_panes_wrap .general_box h3 {
	background: #fff url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-3.jpg);
}

body.bg-4 #branding, body.bg-4 .maintitle, body.bg-4 #footer, body.bg-4 .ipsSideBlock h3,
body.bg-4 #profile_panes_wrap .general_box h3 {
	background: #fff url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-4.jpg);
}

body.bg-5 #branding, body.bg-5 .maintitle, body.bg-5 #footer, body.bg-5 .ipsSideBlock h3,
body.bg-5 #profile_panes_wrap .general_box h3 {
	background: #fff url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-5.jpg);
}

body.bg-6 #branding, body.bg-6 .maintitle, body.bg-6 #footer, body.bg-6 .ipsSideBlock h3,
body.bg-6 #profile_panes_wrap .general_box h3 {
	background: #fff url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-6.jpg);
}

body.bg-7 #branding, body.bg-7 .maintitle, body.bg-7 #footer, body.bg-7 .ipsSideBlock h3,
body.bg-7 #profile_panes_wrap .general_box h3 {
	background: #fff url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-7.jpg);
}

body.bg-8 #branding, body.bg-8 .maintitle, body.bg-8 #footer, body.bg-8 .ipsSideBlock h3,
body.bg-8 #profile_panes_wrap .general_box h3 {
	background: #fff url(http://mrgreengaming.com/forums/public/style_images/tctc91_glare/_custom/backgrounds/bg-8.jpg);
}
</style>


				
				<!-- ::: CONTENT ::: -->
				<?php include( "mtamaps.php" ); ?>

				
			</div>
			<!-- ::: FOOTER (Change skin, language, mark as read, etc) ::: -->
			<div id="footer">
				<div class="main_width">	
					<div id='footer_utilities' class='clearfix clear'>
					</div>
					
					<span style="display:none;"><div><img src='http://mrgreengaming.com/forums/index.php?s=acb7bb1480d9f5d7dabefa651d6844cc&amp;app=core&amp;module=task' alt='' style='border: 0px;height:1px;width:1px;' /></div></span>
					
					
					<div id='inline_login_form' style="display:none">
		<form action="https://mrgreengaming.com/forums/index.php?app=core&amp;module=global&amp;section=login&amp;do=process" method="post" id='login'>
				<input type='hidden' name='auth_key' value='880ea6a14ea49e853634fbdc5015a024' />
				<input type="hidden" name="referer" value="http://mrgreengaming.com/forums/" />
				<h3>Sign In</h3>
				<div class='ipsBox_notice'>
						<ul class='ipsList_inline'>
							
								<li><a href="https://mrgreengaming.com/forums/index.php?app=core&amp;module=global&amp;section=login&amp;serviceClick=facebook" class='ipsButton_secondary'><img src="http://mrgreengaming.com/forums/public/style_images/tctc91_glare/loginmethods/facebook.png" alt="Facebook" /> &nbsp; Use Facebook</a></li>
							
							
								<li><a href="https://mrgreengaming.com/forums/index.php?app=core&amp;module=global&amp;section=login&amp;serviceClick=twitter" class='ipsButton_secondary'><img src="http://mrgreengaming.com/forums/public/style_images/tctc91_glare/loginmethods/twitter.png" alt="Twitter" /> &nbsp; Use Twitter</a></li>
							
							
							
						</ul>
					</div>
				<br />
				<div class='ipsForm ipsForm_horizontal'>
					<fieldset>
						<ul>
							<li class='ipsField'>
								<div class='ipsField_content'>
									Need an account? <a href="https://mrgreengaming.com/forums/index.php?app=core&amp;module=global&amp;section=register" title='Register now!'>Register now!</a>
								</div>
							</li>
							<li class='ipsField ipsField_primary'>
								<label for='ips_username' class='ipsField_title'>Username</label>
								<div class='ipsField_content'>
									<input id='ips_username' type='text' class='input_text' name='ips_username' size='30' tabindex='0' />
								</div>
							</li>
							<li class='ipsField ipsField_primary'>
								<label for='ips_password' class='ipsField_title'>Password</label>
								<div class='ipsField_content'>
									<input id='ips_password' type='password' class='input_text' name='ips_password' size='30' tabindex='0' /><br />
									<a href='https://mrgreengaming.com/forums/index.php?app=core&amp;module=global&amp;section=lostpass' title='Retrieve password'>I've forgotten my password</a>
								</div>
							</li>
							<li class='ipsField ipsField_checkbox'>
								<input type='checkbox' id='inline_remember' checked='checked' name='rememberMe' value='1' class='input_check' tabindex='0' />
								<div class='ipsField_content'>
									<label for='inline_remember'>
										<strong>Remember me</strong><br />
										<span class='desc lighter'>This is not recommended for shared computers</span>
									</label>
								</div>
							</li>
							
							
							<li class='ipsPad_top ipsForm_center desc ipsType_smaller'>
								<a rel="nofollow" href='http://mrgreengaming.com/forums/privacypolicy/'>Privacy Policy</a>
							</li>
							
						</ul>
					</fieldset>
					
					<div class='ipsForm_submit ipsForm_center'>
						<input type='submit' class='ipsButton' value='Sign In' tabindex='0' />
					</div>
				</div>
			</form>
	</div>
				</div><!-- /main_width -->
			</div><!-- /footer -->			
		</div><!-- /ipbwrapper -->		
		
			
	</body>
</html>