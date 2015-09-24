---------------------------------------------------------------------
-- Project: irc
-- Author: MCvarial
-- Contact: mcvarial@gmail.com
-- Version: 1.0.0
-- Date: 31.10.2010
---------------------------------------------------------------------

local x,y = guiGetScreenSize()
local window = guiCreateWindow(0.25,0.3,0.5,0.6,"Internet Relay Chat",true)
local tabpanel = guiCreateTabPanel(0,0.08,1,0.9,true,window)
local tab = guiCreateTab("#MCvarial",tabpanel)

------------------------------------
-- Client
------------------------------------
guiCreateMemo(0.005,0.01,0.75,0.99,"test",true,tab)