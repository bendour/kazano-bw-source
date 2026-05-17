-- Table pour stocker la santé des joueurs selon leur SteamID64
local HealthAccess = {}

-- Fonction pour s'assurer que la table existe et la créer si nécessaire
local function EnsureHealthTableExists()
    -- Crée la table si elle n'existe pas
    local query = [[
        CREATE TABLE IF NOT EXISTS health_access (
            steamid64 TEXT PRIMARY KEY,
            health INTEGER
        );
    ]]
    local result = sql.Query(query)

    if result == false then
        print("Erreur lors de la création de la table health_access : " .. sql.LastError())
    else
        print("Table health_access vérifiée/existante.")
    end
end

-- Fonction pour charger les données depuis SQLite
local function LoadHealthData()
    EnsureHealthTableExists() -- S'assure que la table existe avant de charger les données

    local rows = sql.Query("SELECT * FROM health_access")

    -- Charge les données dans la table HealthAccess
    HealthAccess = {}
    if rows then
        for _, row in ipairs(rows) do
            HealthAccess[row.steamid64] = tonumber(row.health)
        end
        print("Données de santé chargées depuis SQLite.")
    else
        print("Aucun joueur n'a de santé permanente.")
    end
end

-- Fonction pour sauvegarder les données dans SQLite
local function SaveHealthData(steamID64, healthAmount)
    EnsureHealthTableExists() -- S'assure que la table existe avant d'insérer des données

    -- Insère ou met à jour les données dans la table SQLite
    local query = "INSERT OR REPLACE INTO health_access (steamid64, health) VALUES (" .. sql.SQLStr(steamID64) .. ", " .. healthAmount .. ")"
    local result = sql.Query(query)

    if result == false then
        print("Erreur lors de la sauvegarde des données dans SQLite : " .. sql.LastError())
    else
        print("Données de santé sauvegardées avec succès pour " .. steamID64)
    end
end

-- Fonction pour définir la santé d'un joueur à chaque spawn
hook.Add("PlayerSpawn", "NL:Health:PlayerSpawn", function(ply, _)
    local SteamID64 = ply:SteamID64()

    if HealthAccess[SteamID64] then
        timer.Simple(1, function()
            ply:SetHealth(HealthAccess[SteamID64])
        end)
    end
end)

-- Commande console pour définir la santé d'un joueur via son SteamID64
concommand.Add("set_player_health", function(ply, cmd, args)
    -- Vérifie si la commande est exécutée par le serveur (ply sera null si c'est le serveur)
    if not IsValid(ply) then
        if #args < 2 then
            print("Usage: set_player_health <SteamID64> <healthAmount>")
            return
        end

        local steamID64 = args[1]
        local healthAmount = tonumber(args[2])

        if not healthAmount then
            print("Erreur : La quantité de santé doit être un nombre valide.")
            return
        end

        -- Stocke la quantité de santé dans la table
        HealthAccess[steamID64] = healthAmount

        -- Sauvegarde les données dans SQLite
        SaveHealthData(steamID64, healthAmount)

        print("La santé du joueur avec le SteamID64 " .. steamID64 .. " a été définie à " .. healthAmount .. ".")
    else
        ply:ChatPrint("Cette commande ne peut être exécutée que par le serveur.")
    end
end)

-- Commande console pour afficher la liste des joueurs avec une santé permanente
concommand.Add("list_health_players", function(ply)
    if not IsValid(ply) then
        local rows = sql.Query("SELECT steamid64, health FROM health_access")

        if rows then
            print("Liste des joueurs avec santé permanente :")
            for _, row in ipairs(rows) do
                print("SteamID64 : " .. row.steamid64 .. " | Santé : " .. row.health)
            end
        else
            print("Aucun joueur n'a de santé permanente.")
        end
    else
        ply:ChatPrint("Cette commande ne peut être exécutée que par le serveur.")
    end
end)

-- Charge les données au démarrage du serveur
hook.Add("Initialize", "LoadHealthDataOnStart", LoadHealthData)
