-- Table pour stocker le kevlar des joueurs selon leur SteamID64
local ArmorAccess = {}

-- Fonction pour s'assurer que la table existe et la créer si nécessaire
local function EnsureKevlarTableExists()
    -- Crée la table si elle n'existe pas
    local query = [[
        CREATE TABLE IF NOT EXISTS armor_access (
            steamid64 TEXT PRIMARY KEY,
            kevlar INTEGER
        );
    ]]
    local result = sql.Query(query)

    if result == false then
        print("Erreur lors de la création de la table armor_access : " .. sql.LastError())
    else
        print("Table armor_access vérifiée/existante.")
    end
end

-- Fonction pour charger les données depuis SQLite
local function LoadKevlarData()
    EnsureKevlarTableExists() -- S'assure que la table existe avant de charger les données

    local rows = sql.Query("SELECT * FROM armor_access")

    -- Charge les données dans la table ArmorAccess
    ArmorAccess = {}
    if rows then
        for _, row in ipairs(rows) do
            ArmorAccess[row.steamid64] = tonumber(row.kevlar)
        end
        print("Données de kevlar chargées depuis SQLite.")
    else
        print("Aucun joueur n'a de kevlar permanent.")
    end
end

-- Fonction pour sauvegarder les données dans SQLite
local function SaveKevlarData(steamID64, kevlarAmount)
    EnsureKevlarTableExists() -- S'assure que la table existe avant d'insérer des données

    -- Insère ou met à jour les données dans la table SQLite
    local query = "INSERT OR REPLACE INTO armor_access (steamid64, kevlar) VALUES (" .. sql.SQLStr(steamID64) .. ", " .. kevlarAmount .. ")"
    local result = sql.Query(query)

    if result == false then
        print("Erreur lors de la sauvegarde des données dans SQLite : " .. sql.LastError())
    else
        print("Données de kevlar sauvegardées avec succès pour " .. steamID64)
    end
end

-- Fonction pour définir le kevlar d'un joueur à chaque spawn
hook.Add("PlayerSpawn", "NL:Kev:PlayerSpawn", function(ply, _)
    local SteamID64 = ply:SteamID64()

    if ArmorAccess[SteamID64] then
        timer.Simple(1, function()
            ply:SetArmor(ArmorAccess[SteamID64])
        end)
    end
end)

-- Commande console pour définir le kevlar d'un joueur via son SteamID64
concommand.Add("set_player_kevlar", function(ply, cmd, args)
    -- Vérifie si la commande est exécutée par le serveur (ply sera null si c'est le serveur)
    if not IsValid(ply) then
        if #args < 2 then
            print("Usage: set_player_kevlar <SteamID64> <kevlarAmount>")
            return
        end

        local steamID64 = args[1]
        local kevlarAmount = tonumber(args[2])

        if not kevlarAmount then
            print("Erreur : La quantité de kevlar doit être un nombre valide.")
            return
        end

        -- Stocke la quantité de kevlar dans la table
        ArmorAccess[steamID64] = kevlarAmount

        -- Sauvegarde les données dans SQLite
        SaveKevlarData(steamID64, kevlarAmount)

        print("Le kevlar du joueur avec le SteamID64 " .. steamID64 .. " a été défini à " .. kevlarAmount .. ".")
    else
        ply:ChatPrint("Cette commande ne peut être exécutée que par le serveur.")
    end
end)

-- Commande console pour afficher la liste des joueurs avec du kevlar permanent
concommand.Add("list_kevlar_players", function(ply)
    if not IsValid(ply) then
        local rows = sql.Query("SELECT steamid64, kevlar FROM armor_access")

        if rows then
            print("Liste des joueurs avec kevlar permanent :")
            for _, row in ipairs(rows) do
                print("SteamID64 : " .. row.steamid64 .. " | Kevlar : " .. row.kevlar)
            end
        else
            print("Aucun joueur n'a de kevlar permanent.")
        end
    else
        ply:ChatPrint("Cette commande ne peut être exécutée que par le serveur.")
    end
end)

-- Charge les données au démarrage du serveur
hook.Add("Initialize", "LoadKevlarDataOnStart", LoadKevlarData)