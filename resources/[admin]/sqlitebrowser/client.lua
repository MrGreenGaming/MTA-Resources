---
-- The main client file with the main browser window.
--
-- @author	driver2
-- @copyright	2009-2010 driver2

root = getRootElement()

gui = {}

--[[
-- createGui
--
-- Creates the main Gui.
-- ]]
function createGui()
	if gui.window ~= nil then
		return
	end

	gui.window = guiCreateWindow ( 320, 240, 500, 420, "SQLite Browser", false )
	guiWindowSetSizable(gui.window,false)

	-- Tabs
	gui.tabs = guiCreateTabPanel(0,20,500,360,false,gui.window)
	gui.tabTables = guiCreateTab("Tables",gui.tabs)
	gui.tabExecute = guiCreateTab("Execute",gui.tabs)
	
	-- TAB: Tables
	guiCreateLabel(140,10,30,20,"Filter:",false,gui.tabTables)
	gui.loadTablesFilter = guiCreateEdit(180,10,78,20,"",false,gui.tabTables)
	addEventHandler("onClientGUIAccepted",gui.loadTablesFilter,updateGui,false)
	gui.loadTablesButton = guiCreateButton(270,10,200,20,"Load/reload tables",false,gui.tabTables)
	addEventHandler("onClientGUIClick",gui.loadTablesButton,updateGui,false)
	gui.list = {}
	gui.list.tables = guiCreateGridList(8,34,462,200,false,gui.tabTables)
	guiGridListAddColumn(gui.list.tables,"Table",0.9)

	gui.memo = guiCreateMemo(8,244,462,80,"Please click on any row to display more information.",false,gui.tabTables)
	guiMemoSetReadOnly(gui.memo,true)

	-- TAB: Execute
	guiCreateLabel(10,10,460,20,"Enter query here (use at your own risk):",false,gui.tabExecute)
	gui.query = guiCreateMemo(8,40,462,80,"",false,gui.tabExecute)
	gui.queryResultLabel = guiCreateLabel(10,130,340,20,"Result:",false,gui.tabExecute)
	gui.queryResult = guiCreateGridList(8,154,462,170,false,gui.tabExecute)
	gui.queryExecuteButton = guiCreateButton(360,128,100,20,"Execute",false,gui.tabExecute)
	addEventHandler("onClientGUIClick",gui.queryExecuteButton,executeQuery,false)
	gui.queryResultList = {}

	gui.closeButton = guiCreateButton( 220, 390, 60, 20, "Close", false, gui.window )
	addEventHandler("onClientGUIClick",gui.closeButton,closeGui,false)

	addEventHandler("onClientGUIDoubleClick",gui.list.tables,openTableWindowOnDoubleClick,false)
	addEventHandler("onClientGUIClick",gui.list.tables,changeInfoText,false)

	guiSetVisible(gui.window,false)
end

---
-- Executes a single query entered in the GUI by sending it to the server.
function executeQuery()
	local query = guiGetText(gui.query)
	if query and #query > 4 then
		guiSetText(gui.queryResultLabel,"Result: Waiting for response from server..")
		sendMessageToServer("executeQuery",{query})
	end
end
--[[
-- changeInfoText
--
-- Changes the text in the text memo when a gridlist row is clicked.
-- ]]
function changeInfoText()
	if source == gui.list.tables then
		local row = guiGridListGetSelectedItem(gui.list.tables)
		if row == -1 then
			return
		end
		local info = guiGridListGetItemData(gui.list.tables,row,1)
		guiSetText(gui.memo,info)
	end
end

--------------------------
-- Open and close main Gui
--------------------------

--[[
-- openGui
--
-- Opens the Gui.
-- ]]
function openGui()
	createGui()
	--updateGui()
	
	guiSetVisible(gui.window,true)
	showCursor(true)
	guiSetInputEnabled(true)

	hideTableWindows(false)
end

--[[
-- closeGui
--
-- Closes the Gui.
-- ]]
function closeGui()
	guiSetVisible(gui.window,false)
	showCursor(false)
	hideTableWindows(true)
	guiSetInputEnabled(false)
end

--[[
-- toggleGui
--
-- Opens the Gui if it is hidden or close it if it is visible.
-- ]]
function toggleGui()
	if guiGetVisible(gui.window) then
		closeGui()
	else
		openGui()
	end
end

------------------------------
-- Client/Server Communication
------------------------------

--[[
-- updateGui
--
-- Sends a request to the server to update the gui data.
-- ]]
function updateGui()
	local filter = guiGetText(gui.loadTablesFilter)
	if #filter == 0 then
		filter = nil
	end
	sendMessageToServer("getTables",filter)
end

function sendMessageToServer(message,parameter)
	triggerServerEvent("onSQLiteBrowserClientMessage",getLocalPlayer(),message,parameter)
end

--[[
-- serverMessage
--
-- Interprets messages from the server.
-- 
-- @param   string   message: The message name
-- @param   mixed    parameter: Any data the server sent
-- ]]
function serverMessage(message,parameter)

	--outputDebugString("ServerResponse for "..getPlayerName(getLocalPlayer())..": "..tostring(message).." "..tostring(parameter).."")

	if message == "toggleGui" then
		toggleGui()
	end

	-- ## updating GUI related stuff
	if (gui.window == nil) then
		return
	end
	if message == "sendTables" then
		guiGridListClear(gui.list.tables)

		local tables = parameter
		for k,v in ipairs(tables) do
			local id = guiGridListAddRow(gui.list.tables)
			guiGridListSetItemText(gui.list.tables,id,1,v.name,false,false)
			guiGridListSetItemData(gui.list.tables,id,1,v.sql,false,false)
		end
	end

	if message == "sendTableData" then
		local table = parameter[1]
		local data = parameter[2]
		local tableWindow = getTableWindowFromTable(table)
		if tableWindow then
			tableWindow:updateGui(data)
		end
	end
	if message == "queryResult" then
		-- Loads the result of a query into the GUI
		local result = parameter[1]
		local sqlError = parameter[2]
		if not result then
			guiSetText(gui.queryResultLabel,"Result: An error occured")
		else
			guiSetText(gui.queryResultLabel,"Result: "..#result.." rows")
			guiGridListClear(gui.queryResult)
			for k,v in pairs(gui.queryResultList) do
				guiGridListRemoveColumn(gui.queryResult,v)
			end
			gui.queryResultList = {}

			for k,values in ipairs(result) do
				for key,_ in pairs(values) do
					if not gui.queryResultList[key] then
						gui.queryResultList[key] = guiGridListAddColumn(gui.queryResult,key,0.1)
					end
				end
				local rowIndex = guiGridListAddRow(gui.queryResult)
				for key,value in pairs(values) do
					guiGridListSetItemText(gui.queryResult,rowIndex,gui.queryResultList[key],tostring(value),false,false)
				end
			end
			for k,v in pairs(gui.queryResultList) do
				guiGridListAutoSizeColumn(gui.queryResult,v)
			end
			
		end
	end
	
end

addEvent("onClientSQLiteBrowserServerMessage",true)
addEventHandler("onClientSQLiteBrowserServerMessage",root,serverMessage)


-----------------------------
-- Manage TableWindow objects
-----------------------------

dbTableWindows = {}

--[[
-- openTableWindowOnDoubleClick
--
-- Handler function for a Double Click on a gridlist row.
-- ]]
function openTableWindowOnDoubleClick()
	if source == gui.list.tables then
		local row = guiGridListGetSelectedItem(gui.list.tables)
		if row == - 1 then
			return
		end
		local dbTable = guiGridListGetItemText(gui.list.tables,row,1)
		openTableWindow(dbTable)
	end
end

--[[
-- getTableWindowFromTable
--
-- Searches for a TableWindow object for a database table.
--
-- @param   string   dbTable: The database table you want to search for.
-- @returns          A TableWindow object if one was found, or false otherwise.
-- ]]
function getTableWindowFromTable(dbTable)
	for k,v in ipairs(dbTableWindows) do
		if v.dbTable ~= nil and v.dbTable == dbTable then
			return v
		end
	end
	return false
end

--[[
-- openTableWindow
--
-- Creates a new TableWindow for a database table or opens an existing one.
--
-- @param   string   dbTable: The database table you want to create a window for.
-- ]]
function openTableWindow(dbTable)
	local tableWindow = getTableWindowFromTable(dbTable)
	if tableWindow then
		tableWindow:open()
		return
	end
	table.insert(dbTableWindows,TableWindow:new(dbTable))
	openTableWindow(dbTable)
end

--[[
-- hideTableWindows
--
-- Hides or shows all TableWindow windows.
--
-- @param   boolean   hide: Whether to hide or not to hide (show) the windows.
-- ]]
function hideTableWindows(hide)
	for k,v in ipairs(dbTableWindows) do
		if v.dbTable ~= nil then
			v:hide(hide)
		end
	end
end
