---
-- Main server script reading data from the SQLite database
-- 
-- @author	driver2
-- @copyright	2009-2010 driver2

local root = getRootElement()

------------------------------
-- Client/Server Communication
------------------------------

--[[
-- clientMessage
--
-- Interprets client messages and also checks if the client is allowed to use sqlitebrowser.
-- ]]
function clientMessage(message,parameter)
	local player = client
	-- check here if player has permission to request any data or execute queries
	if not hasObjectPermissionTo(player,"resource.sqlitebrowser.browser",false) then
		return
	end

	if message == "getTables" then
		sendMessageToClient(player,"sendTables",sqlGetTables(parameter))
	end
	if message == "getTableData" then
		sendMessageToClient(player,"sendTableData",{parameter[1],sqlGetTableData(parameter[1],parameter[2],parameter[3])})
	end
	if message == "executeQuery" then
		local result,sqlError = sqlExecuteQuery(parameter[1],parameter[2])
		sendMessageToClient(player,"queryResult",{result,sqlError})
	end
end

addEvent("onSQLiteBrowserClientMessage",true)
addEventHandler("onSQLiteBrowserClientMessage",root,clientMessage)

--[[
-- sendMessageToClient
--
-- Sends a message to a client.
--
-- @param   player   player: The player to send the message to.
-- @param   string   message: The name of the message.
-- @param   mixed    parameter: Any parameter that should be sent to the client.
-- ]]
function sendMessageToClient(player,message,parameter)
	triggerClientEvent(player,"onClientSQLiteBrowserServerMessage",root,message,parameter)
end



---------
-- SQLite
---------

--[[
-- sqlExecuteQuery
--
-- Executes a db query.
--
-- @param   string   query: The query.
-- @param   table    values: The values to bind to the query.
-- ]]
function sqlExecuteQuery(query,values)
	local debugString = ""
	local seperator = ""
	if not values then
		values = {}
	end
	for k,v in ipairs(values) do
		debugString = debugString..seperator..tostring(v)
		seperator = ", "
	end
	outputDebugString("SQLite Browser: "..tostring(query).." ("..debugString..")")
	return executeSQLQuery(query,unpack(values))
end

--[[
-- sqlGetTables
--
-- Gets a table of all db tables.
-- ]]
function sqlGetTables(filter)
	local result = nil
	if filter == nil then
		result = executeSQLQuery("SELECT name, sql FROM sqlite_master WHERE type='table' ORDER BY name")
	else
		result = executeSQLQuery("SELECT name, sql FROM sqlite_master WHERE type='table' AND name LIKE ? ORDER BY name","%"..tostring(filter).."%")
	end
	if not result then
		return {}
	end
	return result
end

--[[
-- sqlGetTableData
--
-- Gets information and data from a specific table.
--
-- @param   string   dbTable: The database table.
-- ]]
function sqlGetTableData(dbTable,from,limit)
	if type(from) ~= "number" or type(limit) ~= "number" then
		from = 0
		limit = 10
	end
	local result = executeSQLQuery("SELECT sql FROM sqlite_master WHERE type='table' AND name=?",dbTable)
	if result and #result == 1 then
		local sql = result[1].sql
		local tableInfo = sqlGetTableInfo(dbTable)
		local rows = executeSQLQuery("SELECT rowid, * FROM ? ORDER BY rowid LIMIT "..from..","..limit.."",dbTable)
		local totalNumRows = executeSQLQuery("SELECT count(*) AS count FROM ?",dbTable)
		return {sql=sql,tableInfo=tableInfo,rows=rows,totalNumRows=totalNumRows[1].count}
		
	end
end



--[[
-- sqlGetTableInfo
--
-- Gets information about a specific table.
--
-- @param   string   dbTable: The database table.
-- @return           A table with information.
-- ]]

function sqlGetTableInfo(dbTable)
	local result = executeSQLQuery("PRAGMA table_info(?)",dbTable)
	if result and #result > 0 then
		return result
	else
		return {}
	end
end

-----------
-- Commands
-----------

--[[
-- toggleGui
--
-- Shows/hides the Gui if the player has permission to use sqlitebrowser.
-- ]]
function toggleGui(player)
	if hasObjectPermissionTo(player,"resource.sqlitebrowser.browser",false) then
		sendMessageToClient(player,"toggleGui")
	end
end
addCommandHandler("sqlitebrowser",toggleGui)
addCommandHandler("sqlb",toggleGui)
