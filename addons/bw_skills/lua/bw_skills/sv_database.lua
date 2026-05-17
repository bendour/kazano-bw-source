--[[
    Server Database - Sauvegarde des compétences
]]

-- Initialiser la base de données
hook.Add("Initialize", "BWSkills:CreateTable", function()
    timer.Simple(2, function()
        if MySQLite then
            MySQLite.query([[
                CREATE TABLE IF NOT EXISTS bw_skills(
                    steamid64 VARCHAR(17) PRIMARY KEY,
                    skill1 VARCHAR(50) DEFAULT NULL,
                    skill2 VARCHAR(50) DEFAULT NULL,
                    rolls_used INTEGER DEFAULT 0,
                    key1 INTEGER DEFAULT ]] .. BWSkills.Config.DefaultKey1 .. [[,
                    key2 INTEGER DEFAULT ]] .. BWSkills.Config.DefaultKey2 .. [[
                );
            ]])
            print("[BW Skills] Table de base de données créée/vérifiée")
        end
    end)
end)

-- Charger les données d'un joueur
function BWSkills:LoadPlayerData(ply)
    if not IsValid(ply) then return end
    
    local steamid64 = ply:SteamID64()
    
    MySQLite.query(string.format(
        "SELECT * FROM bw_skills WHERE steamid64 = %s",
        MySQLite.SQLStr(steamid64)
    ), function(result)
        if result and result[1] then
            local data = result[1]
            BWSkills.PlayerData[steamid64] = {
                skill1 = data.skill1 ~= "NULL" and data.skill1 or nil,
                skill2 = data.skill2 ~= "NULL" and data.skill2 or nil,
                rolls_used = tonumber(data.rolls_used) or 0,
                key1 = tonumber(data.key1) or BWSkills.Config.DefaultKey1,
                key2 = tonumber(data.key2) or BWSkills.Config.DefaultKey2,
                cooldowns = {0, 0},
                activeEffects = {nil, nil}
            }
        else
            -- Créer une entrée
            MySQLite.query(string.format(
                "INSERT INTO bw_skills (steamid64, rolls_used) VALUES (%s, 0)",
                MySQLite.SQLStr(steamid64)
            ))
            BWSkills.PlayerData[steamid64] = {
                skill1 = nil,
                skill2 = nil,
                rolls_used = 0,
                key1 = BWSkills.Config.DefaultKey1,
                key2 = BWSkills.Config.DefaultKey2,
                cooldowns = {0, 0},
                activeEffects = {nil, nil}
            }
        end
        
        -- Envoyer au client
        BWSkills:SyncToClient(ply)
    end)
end

-- Sauvegarder les données d'un joueur
function BWSkills:SavePlayerData(ply)
    if not IsValid(ply) then return end
    
    local steamid64 = ply:SteamID64()
    local data = BWSkills.PlayerData[steamid64]
    
    if not data then return end
    
    MySQLite.query(string.format(
        "UPDATE bw_skills SET skill1 = %s, skill2 = %s, rolls_used = %d, key1 = %d, key2 = %d WHERE steamid64 = %s",
        data.skill1 and MySQLite.SQLStr(data.skill1) or "NULL",
        data.skill2 and MySQLite.SQLStr(data.skill2) or "NULL",
        data.rolls_used,
        data.key1,
        data.key2,
        MySQLite.SQLStr(steamid64)
    ))
end

-- Synchroniser les données vers le client
function BWSkills:SyncToClient(ply)
    if not IsValid(ply) then return end
    
    local steamid64 = ply:SteamID64()
    local data = BWSkills.PlayerData[steamid64]
    
    if not data then return end
    
    net.Start("BWSkills:SyncData")
    net.WriteTable({
        skill1 = data.skill1,
        skill2 = data.skill2,
        rolls_used = data.rolls_used,
        key1 = data.key1,
        key2 = data.key2
    })
    net.Send(ply)
end

-- Obtenir les données d'un joueur
function BWSkills:GetPlayerData(ply)
    if not IsValid(ply) then return nil end
    return BWSkills.PlayerData[ply:SteamID64()]
end

-- Hook quand un joueur spawn
hook.Add("PlayerInitialSpawn", "BWSkills:LoadData", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then
            BWSkills:LoadPlayerData(ply)
        end
    end)
end)

-- Hook quand un joueur se déconnecte
hook.Add("PlayerDisconnected", "BWSkills:SaveData", function(ply)
    BWSkills:SavePlayerData(ply)
    BWSkills.PlayerData[ply:SteamID64()] = nil
end)
