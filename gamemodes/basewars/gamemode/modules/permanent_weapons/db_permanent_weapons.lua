hook.Add("BaseWars:InitializeDatabase", "BaseWars:PermanentWeapons", function()
    MySQLite.tableExists("basewars_permanent_weapons", function(bool)
        if bool then return end

        MySQLite.query(Format([[
            CREATE TABLE basewars_permanent_weapons(
            weapon_id INTEGER PRIMARY KEY %s,
            player_id64 VARCHAR(17) NOT NULL,
            admin_id64 VARCHAR(17) NOT NULL,
            date INTEGER UNSIGNED NOT NULL,
            active BIT NOT NULL,
            weapon_class VARCHAR(255) NOT NULL
        )]], MySQLite.isMySQL() and "AUTO_INCREMENT" or "AUTOINCREMENT"), function()
            BaseWars:SQLLogs("Created table basewars_permanent_weapons")
        end, BaseWarsSQLError)

        MySQLite.query("CREATE INDEX basewars_permanent_weapons_player_id64_index ON basewars_permanent_weapons(player_id64)", function()
            BaseWars:SQLLogs("Created index \"basewars_permanent_weapons_player_id64_index\" for table \"basewars_permanent_weapons\"")
        end, BaseWarsSQLError)
    end, BaseWarsSQLError)
end)

hook.Add("BaseWars:ClearDatabase", "BaseWars:PermanentWeapons", function()
    MySQLite.query("DROP TABLE basewars_permanent_weapons", function()
        BaseWars:SQLLogs("Deleted table \"basewars_permanent_weapons\"")
    end, BaseWarsSQLError)
end)