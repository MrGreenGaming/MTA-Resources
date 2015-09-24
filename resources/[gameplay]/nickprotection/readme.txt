Features
--------

Nick protection allows registered players to protected one or more nicks from being taken by other players. Players who join with a protected nick are asked to login (if the nick is associated with their account) or change nick, otherwise they will be kicked or their nick changed automatically. Protected nicks can be set to expire after some time, if they are not used.

Also included is an optional nickchange spam protection, which will prevent players from flooding the server with nickchanges, by only allowing players to change their nick a few times in a certain time.

More help on commands and usage is available in the help.xml. Many settings can be changed via the admin panel (double-click on the nickProtection resource there).


Installation
------------

Besides putting the resource files into the appropriate folder on your server, you may also have to do the following:

- If you want the script to kick players, you may have to modify your server's ACL in order to allow kicking.
- You may also want to add the resource.nickProtection.extended right to players you want to allow to have more protected nicks than regular players (e.g. admins).