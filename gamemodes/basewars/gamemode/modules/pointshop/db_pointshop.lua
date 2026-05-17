hook.Add("BaseWars:InitializeDatabase", "BaseWars:Pointshop", function()
    MySQLite.tableExists("basewars_pointshop", function(bool)
        if bool then
            -- Migration: Add purchasable column if it doesn't exist
            MySQLite.query("SELECT purchasable FROM basewars_pointshop LIMIT 1", function(result)
                -- Column exists, check if any values are NULL and fix them
                MySQLite.query("UPDATE basewars_pointshop SET purchasable = 1 WHERE purchasable IS NULL", function()
                    BaseWars:SQLLogs("Fixed NULL purchasable values in basewars_pointshop")
                end, BaseWarsSQLError)
            end, function(err)
                -- Column doesn't exist, add it with default value 1
                if string.find(err, "no such column") or string.find(err, "Unknown column") then
                    local alterQuery = MySQLite.isMySQL() 
                        and "ALTER TABLE basewars_pointshop ADD COLUMN purchasable TINYINT(1) NOT NULL DEFAULT 1"
                        or "ALTER TABLE basewars_pointshop ADD COLUMN purchasable INTEGER NOT NULL DEFAULT 1"
                    
                    MySQLite.query(alterQuery, function()
                        BaseWars:SQLLogs("Added purchasable column to basewars_pointshop")
                    end, BaseWarsSQLError)
                end
            end)
            return
        end

        local createQuery = MySQLite.isMySQL()
            and [[
                CREATE TABLE basewars_pointshop(
                skin_id INTEGER PRIMARY KEY AUTO_INCREMENT,
                model TEXT NOT NULL,
                price INTEGER UNSIGNED NOT NULL,
                reserved BLOB NOT NULL,
                is_vip TINYINT(1) NOT NULL,
                purchasable TINYINT(1) NOT NULL DEFAULT 1
            )]]
            or [[
                CREATE TABLE basewars_pointshop(
                skin_id INTEGER PRIMARY KEY AUTOINCREMENT,
                model TEXT NOT NULL,
                price INTEGER UNSIGNED NOT NULL,
                reserved BLOB NOT NULL,
                is_vip INTEGER NOT NULL,
                purchasable INTEGER NOT NULL DEFAULT 1
            )]]

        MySQLite.query(createQuery, function()
            BaseWars:SQLLogs("Created table basewars_pointshop")
        end, BaseWarsSQLError)
    end, BaseWarsSQLError)

    MySQLite.tableExists("basewars_pointshop_player", function(bool)
        if bool then return end

        MySQLite.query([[
            CREATE TABLE basewars_pointshop_player(
            player_id64 INTEGER PRIMARY KEY,
            pointshop INTEGER UNSIGNED NOT NULL,
            credits INTEGER UNSIGNED NOT NULL,
            skins TEXT NOT NULL,
            active_skin INTEGER NOT NULL
        )]], function()
            BaseWars:SQLLogs("Created table basewars_pointshop_player")
        end, BaseWarsSQLError)
    end, BaseWarsSQLError)
end)

hook.Add("BaseWars:ClearDatabase", "BaseWars:Pointshop", function()
    MySQLite.query("DROP TABLE basewars_pointshop", function()
        BaseWars:SQLLogs("Deleted table \"basewars_pointshop\"")
    end, BaseWarsSQLError)

    MySQLite.query("DROP TABLE basewars_pointshop_player", function()
        BaseWars:SQLLogs("Deleted table \"basewars_pointshop_player\"")
    end, BaseWarsSQLError)
end)