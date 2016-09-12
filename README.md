# Mr.Green-MTA-Resources
All resources used on the MrGreenGaming.com Multi Theft Auto: San Andreas (MTASA) servers (Race &amp; Race Mix).
# Setting up a local server
- Checkout the resources into your local MTA server folder.
- Example maps, server config, ACL and SQL tables can be found in the `config` folder.
- A lot of resources need access to MySQL and GC accounts to work:
  1. Older resources still need their SQL tables created before they can run, use the dumps `config/green_coins.sql` and `config/mrgreen_mtasrvs.sql` to create them.
  2. Set up the connection to your MySQL server in the gcshop settings (with runcode for example): `/srun set("*gcshop.host", 'localhost'); set("*gcshop.dbname", 'mrgreen_mtasrvs'); set("*gcshop.user", 'root'); set("*gcshop.pass", '');`
  3. Set up gc devmode, this skips the need to check passwords with /gclogin: `/srun set("*gc.devmode", true)`
    * Now you can login with `/gclogin <forumid> admin`, the forumid is the id for an account you can choose.

# Contributing
Everyone is encouraged to contribute. Make sure your changes correspond with the gameplay and looks already in place. When in doubt, make an issue with your wished changes, before applying them in the code-base.

# License
A non-dramatic 'The MIT License' applies. See `LICENSE` file for details.

# Credits
## Project team
* Jarno Veuger (Ywa) - Founder, merger, issue management
* EsDeKa (SDK) - Merger, issue management
* Alexey Yakubovskii (AleksCore) - Merger, issue management

## Implementation
* EsDeKa (SDK)
* AfuSensi (KaliBwoy)
* Alexey Yakubovskii (AleksCore)

## Additional implementation
* Stijn Lindeman (Puma) - Pickup icons
* Megas97

# Links
* Development help: http://mrgreengaming.com/forums/topic/17140-development-topic-lua-github-ask-here-if-you-need-help-with-git-or-the-resources/
* Discussion forums: http://mrgreengaming.com/forums/forum/31-multi-theft-auto/
* Email: mail@mrgreengaming.com
