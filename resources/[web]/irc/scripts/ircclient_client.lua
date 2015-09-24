---------------------------------------------------------------------
-- Project: irc
-- Author: MCvarial
-- Contact: mcvarial@gmail.com
-- Version: 1.0.0
-- Date: 31.10.2010
---------------------------------------------------------------------

local tabs = {}
local edits = {}
local memos = {}
local messages = {}
local gridlists = {}
local memolines = {}
local x,y = guiGetScreenSize()

------------------------------------
-- Irc client
------------------------------------
addCommandHandler("irc",
	function ()
		if window then
			guiGridListSetSortingEnabled(gridlist,true)
			guiSetInputEnabled(true)
			guiSetVisible(window,true)
			guiSetVisible(exitbutton,true)
			showCursor(true)
		else
			triggerServerEvent("startIRCClient",getLocalPlayer())
		end
	end,false,false
)

addEvent("showIrcClient",true)
addEventHandler("showIrcClient",root,
	function (info)
		window = guiCreateWindow(0.25,0.3,0.5,0.6,"Internet Relay Chat",true)
		exitbutton = guiCreateButton(0.95,0.03,0.2,0.03,"Close",true,window)
		tabpanel = guiCreateTabPanel(0,0.08,1,0.9,true,window)
		guiSetProperty(exitbutton,"AlwaysOnTop","True")
		--guiWindowSetMovable(window,false)
		--guiWindowSetSizable(window,false)
		for i,inf in ipairs (info) do
			local chantitle = inf[1]
			local tab = guiCreateTab(chantitle,tabpanel)
			local edit = guiCreateEdit(0.005,0.915,0.74,0.07,"",true,tab)
			local memo = guiCreateMemo(0.005,0.01,0.74,0.9,"",true,tab)
			local gridlist = guiCreateGridList(0.75,0.01,0.245,0.99,true,tab)
			local column = guiGridListAddColumn(gridlist,"Users",0.8)
			guiGridListSetSortingEnabled(gridlist,true)
			for i,user in ipairs (inf[2]) do
				local row = guiGridListAddRow(gridlist)
				guiGridListSetItemText(gridlist,row,column,getIconFromLevel(user[2])..user[1],false,false)
			end
			tabs[chantitle] = tab
			edits[chantitle] = edit
			memos[chantitle] = memo
			gridlists[chantitle] = gridlist
			memolines[memo] = {}
		end
		guiBringToFront(exitbutton)
		guiSetInputEnabled(true)
		showCursor(true)
	end
)

addEventHandler("onClientGUIAccepted",root,
	function (editbox)
		for chantitle,edit in pairs (edits) do
			if edit == editbox then
				triggerServerEvent("ircSay",getLocalPlayer(),chantitle,guiGetText(editbox))
				guiSetText(editbox,"")
				return
			end
		end
	end
)

addEventHandler("onClientGUIClick",root,
	function (btn)
		if btn ~= "left" then return end
		if source == exitbutton then
			guiSetInputEnabled(false)
			guiSetVisible(window,false)
			guiSetVisible(exitbutton,false)
			showCursor(false)
		end
	end
)

addEvent("onClientIRCMessage",true)
addEventHandler("onClientIRCMessage",root,
	function (user,chantitle,message)
		memoAddLine(memos[chantitle],user..": "..message)
	end
)

addEvent("onClientIRCUserJoin",true)
addEventHandler("onClientIRCUserJoin",root,
	function (user,chantitle,vhost)
		local row = guiGridListAddRow(gridlists[chantitle])
		guiGridListSetItemText(gridlists[chantitle],row,1,user,false,false)
		memoAddLine(memos[chantitle],"* "..user.." ("..vhost..") joined")
	end
)

addEvent("onClientIRCUserPart",true)
addEventHandler("onClientIRCUserPart",root,
	function (user,chantitle,reason)
		for i=1,guiGridListGetRowCount(gridlists[chantitle]) do
			if guiGridListGetItemText(gridlists[chantitle],i,1) == user then
				guiGridListRemoveRow(gridlists[chantitle],i)
				break
			end
			if string.sub(guiGridListGetItemText(gridlists[chantitle],i,1),2) == user then
				guiGridListRemoveRow(gridlists[chantitle],i)
				break
			end
		end
		memoAddLine(memos[chantitle],"* "..user.." parted ("..(reason or "")..")")
	end
)

addEvent("onClientIRCUserQuit",true)
addEventHandler("onClientIRCUserQuit",root,
	function (user,reason)
		for i,gridlist in pairs (gridlists) do
			for i=1,guiGridListGetRowCount(gridlist) do
				if guiGridListGetItemText(gridlist,i,1) == user then
					guiGridListRemoveRow(gridlist,i)
					break
				end
			end
		end
		for i,memo in pairs (memos) do
			memoAddLine(memo,"* "..user.." ("..vhost..") quit ("..reason..")")
		end
	end
)

addEvent("onClientIRCNotice",true)
addEventHandler("onClientIRCNotice",root,
	function (user,chantitle,message)
		memoAddLine(memos[chantitle],"<notice> "..user..": "..message)
	end
)

addEvent("onClientIRCUserMode",true)
addEventHandler("onClientIRCUserMode",root,
	function (user,chantitle,positive,mode,setter,newlevel)
		if positive then
			memoAddLine(memos[chantitle],"* "..(setter or "Server").." sets mode: +"..mode.." "..user)
		else
			memoAddLine(memos[chantitle],"* "..(setter or "Server").." sets mode: -"..mode.." "..user)
		end
	end
)

addEvent("onClientIRCChannelMode",true)
addEventHandler("onClientIRCChannelMode",root,
	function (chantitle,positive,mode,setter)
		if positive then
			memoAddLine(memos[chantitle],"* "..(setter or "Server").." sets mode: +"..mode)
		else
			memoAddLine(memos[chantitle],"* "..(setter or "Server").." sets mode: -"..mode)
		end
	end
)

addEvent("onClientIRCLevelChange",true)
addEventHandler("onClientIRCLevelChange",root,
	function (user,chantitle,oldlevel,newlevel)
		for i=1,guiGridListGetRowCount(gridlists[chantitle]) do
			if guiGridListGetItemText(gridlists[chantitle],i,1) == user then
				guiGridListSetItemText(gridlists[chantitle],i,1,getIconFromLevel(newlevel)..user,false,false)
				break
			end
			if string.sub(guiGridListGetItemText(gridlists[chantitle],i,1),2) == user then
				guiGridListSetItemText(gridlists[chantitle],i,1,getIconFromLevel(newlevel)..user,false,false)
				break
			end
		end
	end
)

addEvent("onClientIRCUserChangeNick",true)
addEventHandler("onClientIRCUserChangeNick",root,
	function (oldnick,newnick)
		for i,gridlist in pairs (gridlists) do
			for i=1,guiGridListGetRowCount(gridlist) do
				if guiGridListGetItemText(gridlist,i,1) == oldnick then
					guiGridListSetItemText(gridlist,i,1,newnick,false,false)
					break
				end
				if string.sub(guiGridListGetItemText(gridlist,i,1),2) == oldnick then
					guiGridListSetItemText(gridlist,i,1,string.sub(guiGridListGetItemText(gridlist,i,1),1,1)..newnick,false,false)
					break
				end
			end
		end
	end
)

function memoAddLine (memo,line)
	if #memolines[memo] > 16 then
		table.remove(memolines[memo],1)
	end
	table.insert(memolines[memo],line)
	return guiSetText(memo,table.concat(memolines[memo],"\n"))
end

local icons = {"+","%","@","&","~"}
function getIconFromLevel (level)
	return icons[level] or ""
end