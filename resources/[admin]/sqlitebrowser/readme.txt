SQLite Browser allows you to browse MTA's SQLite database as well as make simple edits to it. Start the resource and use the /sqlitebrowser-command.

Editing the ACL
---------------
You need to add the resource.sqlitebrowser.browser right to the ACL of the users you want to allow to use the browser.

For example, if you want to make it useable for users in the "Admin" group, you could open the webadmin, click on "ACLs", then on "Admin", down on the bottom under "Add new right" on "Resource feature", select the "sqlitebrowser"-resource, type "browser" in the "Feature"-field and tick the "Allow access"-checkbox above to allow access. After clicking on the "add" button, you should be able to use the browser if you login to your account that is in the "Admin" group.

Please refer to other help or ask someone if you are not sure what to do.

Some remarks
------------
- If table layouts are changed (i.e. the table is deleted and newly created with different columns) you may have to restart the resource to have it correctly display the table.
- Please note that there are no confirmations in the gui on the actions (add/delete) yet, however you can view the queries that get executed in the debug window (/debugscript 3).
- The data that is displayed could be changed by other resources while you watch/edit. So please be careful when editing stuff that could affect other resources. You can always reload the current data of a table by using the "Refresh data from DB" button.
- You can toggle the visibility of all sqlitebrowser windows by entering the /sqlitebrowser command again. Please note that windows are not recreated, but only made visible/hidden.
