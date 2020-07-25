# CoreMarkers
Random pickups for MTA San Andreas race maps

## Important for server owners
CoreMarkers resource require ACL rights to stopResource() function to prevent bug when resource not stopping on map change. Admin can add rights by executing the command below in the console:
`aclrequest allow coremarkers all`

##  I want to use your markers in my maps, what should I do?
1) Download coremarkers resource and put in your server resource folder (Example: `C:\Games\MTA San Andreas\server\mods\deathmatch\resources`)
2) Start Map Editor
3) Add coremarkers to definitions list in map editor, then you will find an icon in the left bottom corner (point mouse to icons and use scroll to change dimension)
4) Once you finish with your map and close map editor, open your meta.xml file in map folder and place this line:
`<include resource="coremarkers" />`
Example:
`<meta>
    <include resource="coremarkers" />
    <info gamemodes="race" type="map" version="1.0.0"></info>
    <map src="123.map" dimension="0"></map>
    <settings>
        <setting name="#skins" value='[ &quot;cj&quot; ]'></setting>
        <setting name="#coremarkers_respawn" value="[ 0 ]"></setting>
        <setting name="#maxplayers" value="[ 128 ]"></setting>
        <setting name="#useLODs" value="[ false ]"></setting>
        <setting name="#gamespeed" value="[ 1 ]"></setting>
        <setting name="#ghostmode" value='[ &quot;false&quot; ]'></setting>
        <setting name="#time" value="12:0"></setting>
        <setting name="#vehicleweapons" value='[ &quot;false&quot; ]'></setting>
        <setting name="#minplayers" value="[ 0 ]"></setting>
        <setting name="#weather" value="[ 0 ]"></setting>
        <setting name="#gravity" value="[ 0.0080000004 ]"></setting>
        <setting name="#waveheight" value="[ 0 ]"></setting>
        <setting name="#respawntime" value="[ 5 ]"></setting>
        <setting name="#locked_time" value="[ false ]"></setting>
        <setting name="#duration" value="[ 1800 ]"></setting>
        <setting name="#respawn" value='[ &quot;timelimit&quot; ]'></setting>
    </settings>
    <script src="mapEditorScriptingExtension_s.lua" type="server"></script>
    <script src="mapEditorScriptingExtension_c.lua" type="client" validate="false"></script>
</meta>
`

Testing in Map Editor not fully working, it will only spam in chat: "You picked up a CoreMarkers pickup".