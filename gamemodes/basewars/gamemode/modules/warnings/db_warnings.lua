hook.Add("BaseWars:InitializeDatabase", "BaseWars:Warnings", function()
    MySQLite.tableExists("basewars_warnings", function(bool)
        if bool then return end

        MySQLite.query(Format([[
            CREATE TABLE basewars_warnings(
            warning_id INTEGER PRIMARY KEY %s,
            player_id64 VARCHAR(17) NOT NULL,
            admin_id64 VARCHAR(17) NOT NULL,
            date INTEGER UNSIGNED NOT NULL,
            reason TEXT NOT NULL
        )]], MySQLite.isMySQL() and "AUTO_INCREMENT" or "AUTOINCREMENT"), function()
            BaseWars:SQLLogs("Created table basewars_warnings")
        end, BaseWarsSQLError)

        MySQLite.query("CREATE INDEX basewars_warnings_player_id64_index ON basewars_warnings(player_id64)", function()
            BaseWars:SQLLogs("Created index \"basewars_warnings_player_id64_index\" for table \"basewars_warnings\"")
        end, BaseWarsSQLError)
    end, BaseWarsSQLError)
end)

hook.Add("BaseWars:ClearDatabase", "BaseWars:Warnings", function()
    MySQLite.query("DROP TABLE basewars_warnings", function()
        BaseWars:SQLLogs("Deleted table \"basewars_warnings\"")
    end, BaseWarsSQLError)
end)