# Mr.Green-MTA-Resources
All resources used on the MrGreenGaming.com Multi Theft Auto: San Andreas (MTASA) servers (Race &amp; Race Mix).

# Goal
TBA

# Setting up a local server
- Checkout the resources into your local MTA server folder
- You can use the Mr.Green-MTA-Resources/config/mtaserver.conf file to use as an example server config
- A lot of resources need access to MySQL and GC accounts to work:
  1. Older resources still need their SQL tables created before they can run, use the dumps Mr.Green-MTA-Resources/config/green_coins.sql and Mr.Green-MTA-Resources/config/mrgreen_mtasrvs.sql to create them
  2. Set up the connection to your MySQL server in the gcshop settings (with runcode for example): `/srun set("*gcshop.host", 'localhost'); set("*gcshop.dbname", 'mrgreen_mtasrvs'); set("*gcshop.user", 'root'); set("*gcshop.pass", '');`
  3. Set up gc devmode, this skips the need to check passwords with /gclogin: `/srun set("*gc.devmode", true)`
    * Now you can login with `/gclogin <forumid> admin`, the forumid is the id for an account you can choose

# Contributing
Anyone is welcome to contribute. Make sure your changes correspond with our goal. When in doubt, make an issue with your wished changes, before applying them in the code-base.

# License
A non-dramatic GNU license applies. See LICENSE file for details.

# Credits
## Project team
* Jarno Veuger (Ywa) - Owner, merger, issue management
* (SDK) - Merger, issue management
* (KaliBwoy) - Merger, issue management

## Implementation
* (SDK)
* (KaliBwoy)
* (AleksCore)

## Additional implementation
* Stijn Lindeman (Puma) - Pickup icons

# Links
* Dev topic: http://mrgreengaming.com/forums/topic/17140-development-topic-lua-github-ask-here-if-you-need-help-with-git-or-the-resources/
* Discussion forums: http://mrgreengaming.com/forums/forum/31-multi-theft-auto/
* Direct communication: mail@mrgreengaming.com
test