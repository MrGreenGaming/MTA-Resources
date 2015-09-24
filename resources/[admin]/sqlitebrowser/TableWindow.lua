---
-- Creates a window for a single database table,
-- to browse data and perform simple editing operations
--
-- @author	driver2
-- @copyright	2009-2010 driver2


TableWindow = {}

--[[
-- new
--
-- Creates a new TableWindow object.
--
-- @param   string   dbTable: The name of the table.
-- @return  table    The object.
-- ]]
function TableWindow:new(dbTable)
	local object = {}
	setmetatable(object,self)
	self.__index = self
	object.dbTable = dbTable
	object.totalNumRows = 0
	object.closeButton = function()
		object:close()
	end
	object.updateDataButton = function()
		object:triggerUpdateGui()
	end
	object.updateDataForwardButton = function()
		object:triggerUpdateGui("forward")
	end
	object.updateDataBackwardButton = function()
		object:triggerUpdateGui("backward")
	end
	object.listClick = function()
		object:selectListItem()
	end
	object.removeRowButton = function()
		object:dbRemoveRow()
	end
	object.editButton = function()
		object:dbEditField()
	end
	object.addRowButton = function()
		object:openNewRowWindow()
	end
	object.resizeWindow = function()
		object:autoresizeGui()
	end

	return object
end

--------------------------------
-- General appearance of the Gui
--------------------------------

TableWindow.gui = {}

--[[
-- createGui
--
-- Create the Gui.
-- ]]
function TableWindow:createGui()
	if self.gui.window ~= nil then
		return
	end

	--outputDebugString("Creating Gui for '"..tostring(self.dbTable).."' "..tostring(self))

	self.gui = {}
	self.defaultWindowSize = {600,400}
	self.defaultListSize = {584,300}
	self.gui.window = guiCreateWindow( 320, 240, 600, 400, "SQLite Browser : "..self.dbTable, false )
	
	local w,h = guiGetSize(self.gui.window,false)

	self.gui.list = guiCreateGridList(8,26,584,300,false,self.gui.window)
	guiGridListSetSelectionMode(self.gui.list,2)
	addEventHandler("onClientGUIClick", self.gui.list, self.listClick, false)

	self.gui.numRowsLabel = guiCreateLabel(12, 334, 190, 20, "Number of rows: 0", false, self.gui.window)

	-- Edit
	self.gui.addRowButton = guiCreateButton( 500, 364, 80, 20, "Add row", false, self.gui.window )
	addEventHandler("onClientGUIClick", self.gui.addRowButton, self.addRowButton, false)

	self.gui.removeRowButton = guiCreateButton( 350, 364, 140, 20, "Remove selected row", false, self.gui.window )
	addEventHandler("onClientGUIClick", self.gui.removeRowButton, self.removeRowButton, false)

	self.gui.edit = guiCreateEdit(12, 364, 200, 20, "", false, self.gui.window)
	self.gui.editButton = guiCreateButton( 220, 364, 120, 20, "Edit selected field", false, self.gui.window )
	addEventHandler("onClientGUIClick", self.gui.editButton, self.editButton, false)

	-- Load
	--self.gui.loadNotice = guiCreateLabel(self.defaultListSize[2]/2,100,300,20,"Click on 'Load' to request data from the server.",false,self.gui.window)
	guiCreateLabel( 220, 334, 40, 20, "Start", false, self.gui.window)
	guiCreateLabel( 310, 334, 40, 20, "Limit", false, self.gui.window)
	self.gui.updateLimit1 = guiCreateEdit( 258, 334, 42, 20, "0", false, self.gui.window )
	self.gui.updateLimit2 = guiCreateEdit( 340, 334, 42, 20, "10", false, self.gui.window )
	self.gui.forwardButton = guiCreateButton( 480, 334, 30, 20, "->", false,self.gui.window)
	self.gui.backwardButton = guiCreateButton( 444, 334, 30, 20, "<-", false,self.gui.window)
	self.gui.updateButton = guiCreateButton( 390, 334, 44, 20, "Load", false, self.gui.window )
	addEventHandler("onClientGUIClick", self.gui.updateButton, self.updateDataButton, false)
	addEventHandler("onClientGUIClick", self.gui.forwardButton, self.updateDataForwardButton, false)
	addEventHandler("onClientGUIClick", self.gui.backwardButton, self.updateDataBackwardButton, false)
	addEventHandler("onClientGUIAccepted", self.gui.updateLimit1, self.updateDataButton, false)
	addEventHandler("onClientGUIAccepted", self.gui.updateLimit2, self.updateDataButton, false)

	self.gui.closeButton = guiCreateButton( 530, 334, 50, 20, "Close", false, self.gui.window )
	addEventHandler("onClientGUIClick", self.gui.closeButton, self.closeButton, false)

	addEventHandler("onClientGUISize",self.gui.window,self.resizeWindow,false)
	
	guiSetVisible(self.gui.window,false)
	self:triggerUpdateGui()
end

--[[
-- setWidthForAllColumns
--
-- Sets the same width for all gridlist columns.
--
-- @param   number   width: The width.
-- ]]
function TableWindow:setWidthForAllColumns(width)
	for k,v in pairs(self.columns) do
		guiGridListSetColumnWidth(self.gui.list,v,width,false)
	end
end

--[[
-- autoresizeGui
--
-- Resizes some Gui elements when the window is resized
-- as well as prevents some resizing.
-- ]]
function TableWindow:autoresizeGui()
	local w,h = guiGetSize(self.gui.window,false)
	local normalW = self.defaultWindowSize[1]
	local normalH = self.defaultWindowSize[2]

	-- currently, only horzintal resizing allowed
	if h ~= normalH then
		guiSetSize(self.gui.window,w,normalH,false)
		h = normalH
	end
	
	-- and also not smaller
	if w < normalW then
		guiSetSize(self.gui.window,normalW,h,false)
		w = normalW
	end

	local factorW = w / normalW
	local factorH = h / normalH
	local listW = self.defaultListSize[1]
	local listH = self.defaultListSize[2]
	guiSetSize(self.gui.list,listW * factorW,listH * factorH,false)
	self:setWidthForAllColumns(100)
end


-----------------
-- Open and close
-----------------

-- whether the window was opened/closed
TableWindow.visible = false


--[[
-- open
--
-- Opens the window.
-- ]]
function TableWindow:open()
	self:createGui()
	self.visible = true
	guiSetVisible(self.gui.window,true)
	guiBringToFront(self.gui.window)
end

--[[
-- close
--
-- Closes the window.
-- ]]
function TableWindow:close()
	self.visible = false
	guiSetVisible(self.gui.window,false)
end

--[[
-- hide
--
-- Hides or shows the window (works only if the window is currently set visible).
--
-- @param   boolean   bool: Whether to show or hide the window.
-- ]]
function TableWindow:hide(bool)
	if self.visible then
		guiSetVisible(self.gui.window,not bool)
	end
end


----------------------
-- Edit database table
----------------------

--[[
-- openNewRowWindow
--
-- Creates and opens the window for adding a new row to the database table
-- ]]
function TableWindow:openNewRowWindow()
	if self.newRowWindow ~= nil and isElement(self.newRowWindow.window) then
		destroyElement(self.newRowWindow)
	end

	local columns = self.tableInfo

	local g = {}
	local height = #columns * 28 + 80
	g.window = guiCreateWindow( 400, 240, 420, height, "Add row : "..self.dbTable, false )
	guiWindowSetSizable(g.window,false)

	local y = 30
	g.columnLabel = {}
	g.columnEdit = {}
	for k,v in ipairs(columns) do
		g.columnLabel[v.name] = guiCreateLabel( 10, y, 200, 20, v.name.." ("..v.type..")", false, g.window )
		g.columnEdit[v.name] = guiCreateEdit(210, y, 200, 20, "", false, g.window )
		y = y + 28
	end

	y = y + 10
	
	g.addButton = guiCreateButton( 50, y, 80, 20, "Add Row", false, g.window )
	self.newRowWindowAddButton = function()
		self:dbAddRow()
	end
	addEventHandler("onClientGUIClick", g.addButton, self.newRowWindowAddButton, false )

	g.closeButton = guiCreateButton( 140, y, 44, 20, "Close", false, g.window )
	self.newRowWindowCloseButton = function()
		destroyElement(self.newRowWindow.window)
	end
	addEventHandler("onClientGUIClick", g.closeButton, self.newRowWindowCloseButton, false )


	self.newRowWindow = g
end

--[[
-- dbAddRow
--
-- Adds a row to the db table.
-- ]]
function TableWindow:dbAddRow()
	local g = self.newRowWindow
	local queryColumns = ""
	local queryValues = ""
	local values = {self.dbTable}
	local seperator = ""
	for k,v in pairs(g.columnEdit) do
		local value = guiGetText(v)
		if value ~= "" then
			queryColumns = queryColumns..seperator..k
			queryValues = queryValues..seperator.."?"
			seperator = ","
			table.insert(values,value)
		end
	end
	if #values == 1 then
		outputDebugString("dbAddRow: no values")
		return
	end

	local query = "INSERT INTO ? ("..queryColumns..") VALUES ("..queryValues..")"
	self:dbExecuteQuery(query,values)
	self:triggerUpdateGui()
end

--[[
-- dbEditField
--
-- Called when the edit button is clicked and changes the selected
-- item to the new value (if its different).
-- ]]
function TableWindow:dbEditField()
	local row, column = guiGridListGetSelectedItem(self.gui.list)
	if row ~= -1 then
		local text = guiGridListGetItemText(self.gui.list,row,column)
		local editedText = guiGetText(self.gui.edit)
		local dbColumn = self:getDbColumnFromColumn(column)
		if dbColumn and editedText ~= text then
			local query = "UPDATE ? SET ? = ? WHERE rowid = ?"
			local values = {self.dbTable,dbColumn,editedText,self:getDbRowid(row)}
			self:dbExecuteQuery(query,values)
			self:triggerUpdateGui()
		end
	end
end

--[[
-- selectListItem
--
-- Called when a gridlist item selected and sets the edit box to its value.
-- ]]
function TableWindow:selectListItem()
	local row, column = guiGridListGetSelectedItem(self.gui.list)
	if row ~= -1 then
		local text = guiGridListGetItemText(self.gui.list,row,column)
		guiSetText(self.gui.edit,text)
	end
end

--[[
-- dbRemoveRow
--
-- Removes the currently selected database table row.
-- ]]
function TableWindow:dbRemoveRow()
	local row, column = guiGridListGetSelectedItem(self.gui.list)
	if row ~= -1 then
		local sqlRowid = self:getDbRowid(row)
		local query = "DELETE FROM ? WHERE rowid = ?"
		local values = {self.dbTable,sqlRowid}
		self:dbExecuteQuery(query,values)
		self:triggerUpdateGui()
	end
end

-----------------------
-- Manage Gridlist data
-----------------------

--[[
-- getDbColumnFromColumn
--
-- Returns the name of the database column from the
-- column of the gridlist.
--
-- @param   number   column: The number of the gridlist column.
-- @return  The name of the db column or false if none was found.
-- ]]
function TableWindow:getDbColumnFromColumn(column)
	for k,v in pairs(self.columns) do
		if v == column then
			return k
		end
	end
	return false
end

--[[
-- getDbRowId
--
-- Gets the database table row id from the gridlist row.
--
-- @param   number   row: The row of the gridlist.
-- @return  number   The id of the database table row.
-- ]]
function TableWindow:getDbRowid(row)
	return guiGridListGetItemText(self.gui.list,row,self.columns.rowid)
end

-------------
-- Update Gui
-------------

function TableWindow:updateGui(data)
	-- clear gridlist data and columns
	if self.columns then
		guiGridListClear(self.gui.list)
		for k,v in pairs(self.columns) do
			-- doesnt really work:
			--guiGridListRemoveColumn(self.gui.list,v)
		end
	else
		self.columns = {}
	end

	-- inititate vars and get invididual data
	local sql = data.sql
	local tableInfo = data.tableInfo
	self.tableInfo = tableInfo
	local rows = data.rows
	self.totalNumRows = data.totalNumRows

	-- add columns
	if self.columns.rowid == nil then
		self.columns.rowid = guiGridListAddColumn(self.gui.list,"#",0.1)
	end
	for k,v in ipairs(tableInfo) do
		local columnName = v.name
		if self.columns[columnName] == nil then
			self.columns[columnName] = guiGridListAddColumn(self.gui.list,columnName,0.2)
		end
	end
	self:setWidthForAllColumns(100)

	-- add data
	for k,v in ipairs(rows) do
		local rowId = guiGridListAddRow(self.gui.list)
		guiGridListSetItemText(self.gui.list,rowId,1,tostring(v.rowid),false,true)
		for k2,v2 in pairs(v) do
			guiGridListSetItemText(self.gui.list,rowId,self.columns[k2],tostring(v2),false,false)
		end
	end

	-- update labels
	guiSetText(self.gui.numRowsLabel,"Number of rows: "..tostring(#rows).."/"..tostring(data.totalNumRows))
end


------------------------------
-- Client/Server Communication
------------------------------

--[[
-- dbExecuteQuery
--
-- Sends a request to execute a db query to the server.
--
-- @param   string   query: The query
-- @param   table    values: The values
-- ]]
function TableWindow:dbExecuteQuery(query,values)
	triggerServerEvent("onSQLiteBrowserClientMessage",getLocalPlayer(),"executeQuery",{query,values})
end

--[[
-- triggerUpdateGui
--
-- Sends a request to the server to update the data in the Gui.
-- ]]
function TableWindow:triggerUpdateGui(move)
	local from = tonumber(guiGetText(self.gui.updateLimit1))
	local limit = tonumber(guiGetText(self.gui.updateLimit2))
	if type(from) ~= "number" then
		from = 0
	end
	if type(limit) ~= "number" then
		limit = 10
	end
	if move == "forward" then
		from = from + limit
		if from >= self.totalNumRows then
			from = from - limit
		end
		guiSetText(self.gui.updateLimit1,from)
	end
	if move == "backward" then
		from = from - limit
		if from < 0 then
			from = 0
		end
		guiSetText(self.gui.updateLimit1,from)
	end
	guiSetText(self.gui.numRowsLabel,"Loading..")
	triggerServerEvent("onSQLiteBrowserClientMessage",getLocalPlayer(),"getTableData",{self.dbTable,from,limit})
end
