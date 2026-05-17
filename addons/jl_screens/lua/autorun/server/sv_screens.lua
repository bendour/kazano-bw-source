Config = Config or {}
Config.Panels = Config.Panels or {}

util.AddNetworkString("Update3D2DPanels")

local function fetchData()
    if not MySQLite then return end
    
    local data = {}

    MySQLite.query("SELECT player_id64, kills FROM basewars_player_stats ORDER BY kills DESC, player_id64 ASC LIMIT 10", function(result)
        data.kills = result or {}
    end)
    
    MySQLite.query("SELECT player_id64, MAX(prestige) as prestige FROM basewars_prestige GROUP BY player_id64 ORDER BY prestige DESC LIMIT 10", function(result)
        data.prestige = result or {}
    end)
    
    MySQLite.query("SELECT player_id64, time_played FROM basewars_player ORDER BY time_played DESC LIMIT 10", function(result)
        data.time_played = result or {}
    end)
    
    MySQLite.query("SELECT steam_id as player_id64, monthly_votes FROM vote_rewards_players ORDER BY monthly_votes DESC LIMIT 10", function(result)
        data.votes = result or {}
    end)
    
    timer.Simple(1, function()
        net.Start("Update3D2DPanels")
        net.WriteTable(data)
        net.Broadcast()
    end)
end

-- Attendre que MySQLite soit chargé
timer.Simple(5, function()
    timer.Create("Refresh3D2DPanels", Config.RefreshRate or 30, 0, fetchData)
    fetchData()
end)
