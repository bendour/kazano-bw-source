CH_Advent.SQL = CH_Advent.SQL or {}

--[[
	Configure your SQL details
--]]
CH_Advent.SQL.UseMySQLOO = false

CH_Advent.SQL.Host = ""
CH_Advent.SQL.Username = ""
CH_Advent.SQL.Password = ""
CH_Advent.SQL.Database = ""
CH_Advent.SQL.Port = 3306

--[[
	Require mysqloo if enabled, connect to database and add the sqlquery and create table functions.
	
	Or else just create query and create table functions for sqlite 
--]]
local function CH_Advent_CreateSQLTables()
	CH_Advent.SQL.CreateTables( "ch_advent_players", [[
		Nick VARCHAR(32) NOT NULL,
		Squares TEXT NOT NULL,
		Coal INTEGER NOT NULL,
		SteamID64 VARCHAR(20) NOT NULL PRIMARY KEY,
		HasAccess INTEGER DEFAULT 0
	]] )
	
	-- Migration: Add HasAccess column to existing tables
	timer.Simple( 1, function()
		CH_Advent.SQL.Query( "SELECT HasAccess FROM ch_advent_players LIMIT 1;", function()
			-- Column exists, do nothing
		end, function()
			-- Column doesn't exist, add it
			if CH_Advent.SQL.UseMySQLOO then
				CH_Advent.SQL.Query( "ALTER TABLE ch_advent_players ADD COLUMN HasAccess INTEGER DEFAULT 0;" )
			else
				CH_Advent.SQL.Query( "ALTER TABLE ch_advent_players ADD COLUMN HasAccess INTEGER DEFAULT 0;" )
			end
			print( "[CH Advent] Added HasAccess column to database" )
		end, true )
	end )
	
	if CH_Advent.SQL.UseMySQLOO then
		CH_Advent.SQL.CreateTables( "ch_advent_history", [[
			ID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
			Nick VARCHAR(32) NOT NULL,
			Square INTEGER NOT NULL,
			Reward INTEGER NOT NULL,
			Date INTEGER NOT NULL,
			SteamID64 VARCHAR(20) NOT NULL
		]] )
	else
		CH_Advent.SQL.CreateTables( "ch_advent_history", [[
			ID INTEGER PRIMARY KEY AUTOINCREMENT,
			Nick VARCHAR(32) NOT NULL,
			Square INTEGER NOT NULL,
			Reward INTEGER NOT NULL,
			Date INTEGER NOT NULL,
			SteamID64 VARCHAR(20) NOT NULL
		]] )
	end
end

if CH_Advent.SQL.UseMySQLOO then
    require( "mysqloo" )
	
	-- Setup the sql connection
    CH_Advent.SQL.DB = mysqloo.connect( CH_Advent.SQL.Host, CH_Advent.SQL.Username, CH_Advent.SQL.Password, CH_Advent.SQL.Database, CH_Advent.SQL.Port )
	
	-- What to do if successfully connected
    CH_Advent.SQL.DB.onConnected = function() 
        print( "[CH Advent Calendar MySQL] Database has connected!" ) 
        CH_Advent_CreateSQLTables()
    end
	
	-- Print error to console if we fail
    CH_Advent.SQL.DB.onConnectionFailed = function( db, err )
		print( "[CH Advent Calendar MySQL] Connection to database failed! Error: " .. err )
	end
	
	-- Connect
    CH_Advent.SQL.DB:connect()
    
	-- Here's our MySQL query function
    function CH_Advent.SQL.Query( query, func, singleRow )
        local query = CH_Advent.SQL.DB:query( query )
		
        if func then
            function query:onSuccess( data ) 
                if singleRow then
                    data = data[1]
                end
    
                func( data ) 
            end
        end
		
        function query:onError( err )
			print( "[CH Advent Calendar MySQL] An error occured while executing the query: " .. err )
		end
		
        query:start()
    end

    function CH_Advent.SQL.CreateTables( tableName, sqlLiteQuery, mySqlQuery )
        CH_Advent.SQL.Query( "CREATE TABLE IF NOT EXISTS " .. tableName .. " ( " .. ( mySqlQuery or sqlLiteQuery ) .. " );" )
        print( "[CH Advent Calendar MySQL] " .. tableName .. " table validated!" )
    end    
else
    function CH_Advent.SQL.Query( querystr, func, singleRow )
        local query
        if not singleRow then
            query = sql.Query( querystr )
        else
            query = sql.QueryRow( querystr, 1 )
        end
        
        if query == false then
            print( "[CH Advent Calendar SQLite] ERROR", sql.LastError() )
        elseif func then
            func( query )
        end
    end

    function CH_Advent.SQL.CreateTables( tableName, sqlLiteQuery, mySqlQuery )
        if not sql.TableExists( tableName ) then
            CH_Advent.SQL.Query( "CREATE TABLE " .. tableName .. " ( " .. ( sqlLiteQuery or mySqlQuery ) .. " );" )
        end

        print( "[CH Advent Calendar SQLite] " .. tableName .. " table validated!" )
    end
	
	CH_Advent_CreateSQLTables()
end

--[[
	Escape function based on sql
--]]
function CH_Advent.SQL.Escape( input )
    return CH_Advent.SQL.UseMySQLOO and CH_Advent.SQL.DB:escape( input ) or SQLStr( input, true )
end