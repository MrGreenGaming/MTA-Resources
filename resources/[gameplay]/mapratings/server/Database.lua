Database = {}
local connection = false

function Database.connect()
    local tryConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname" .. ';charset=utf8mb4', get("*gcshop.user"), get("*gcshop.pass"))
    if not tryConnect then
        cancelEvent("Could not connect to database.")
        connection = false
    end
    connection = tryConnect
    return connection
end

function Database.getConnection()
    return connection
end
