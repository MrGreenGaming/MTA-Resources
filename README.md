# Mr.Green-MTA-Resources
All resources used on the MrGreenGaming.com Multi Theft Auto: San Andreas (MTASA) servers (Race &amp; Race Mix).

# Local server setup
- Checkout the resources into your local MTASA server folder.
- Example maps, server config file and an ACL example can be found in the `config` folder.
- Setup GreenCoins development mode, with this you can `gclogin` with a testing account. Run this command on an admin client: `/srun set("*gc.devmode", true)`
- Restart the MTA server. Now you can login with `/gclogin <forumid> admin` or using F6, just pick a forumid as any random number. You will start with 99999 GC. Important to use a number as login and 'admin' as the password.
- Setup a MySQL database and import `config/database.sql`. (Alternatively, if you're using Docker, just run the `config/docker-compose.yml` file with the `docker compose up` command.)
- Connect to your MySQL database in the gcshop settings (with runcode for example): `/srun set("*gcshop.host", 'localhost'); set("*gcshop.dbname", 'mrgreen_mtasrvs'); set("*gcshop.user", 'root'); set("*gcshop.pass", '');`
- Restart MTA server for the last time.

# Contributing
Everyone is encouraged to contribute. Make sure your changes correspond with the gameplay and looks already in place. When in doubt, make an issue with your wished changes, before applying them in the code-base.

# License
A non-dramatic 'The MIT License' applies. See `LICENSE` file for details.

# Credits
## Active Contributors
* Nick S. (Nick_026)

## Past Contributors
* AfuSensi (KaliBwoy)
* Haxardous
* Mihail (Mihoje)
* EsDeKa (SDK)
* Alexey Yakubovskii (AleksCore)
* Hans Swart (Bierbuikje)
* Ywa
* Cena1 (Cena)

## Additional implementation
* Stijn Lindeman (Puma) - Pickup icons
* Megas97

# Links
* Development help: http://mrgreengaming.com/forums/topic/17140-development-topic-lua-github-ask-here-if-you-need-help-with-git-or-the-resources/
* Discussion forums: http://mrgreengaming.com/forums/forum/31-multi-theft-auto/
* Email: mail@mrgreengaming.com
