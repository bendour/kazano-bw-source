-- Table pour stocker les limites de props basées sur les SteamIDs spécifiques
local NlPropsLimitSteamID = {
    ["00000000000000000"] = 500, -- Remplacer par les SteamID64
}

-- Table pour stocker les limites de props par groupe d'utilisateur
local NlPropsLimitGroup = {
    ["user"] = 30,
    ["VIP"] = 40,
    ["Premium"] = 50,
    ["TrialModerator"] = 50,
    ["Moderator"] = 50,
    ["SuperModerator"] = 50,
    ["Administrator"] = 50,
    ["superadmin"] = 50,
}

-- Table pour stocker les limites personnalisées ajoutées via la commande console
local NlCustomPropsLimit = {}

-- Fonction pour charger les limites personnalisées depuis un fichier
local function LoadCustomLimitsFromFile(filePath)
    local file = file.Open(filePath, "r", "DATA")
    if not file then
        print("Impossible d'ouvrir le fichier " .. filePath .. ", il sera créé lors de la première utilisation.")
        return
    end

    while true do
        local line = file:ReadLine()
        if not line then break end
        local steamID64, limit = string.match(line, "(%S+)%s*(%d+)")
        if steamID64 and limit then
            NlCustomPropsLimit[steamID64] = tonumber(limit)
        end
    end

    file:Close()
end

-- Fonction pour sauvegarder les limites personnalisées dans un fichier
local function SaveCustomLimitsToFile(filePath)
    local file = file.Open(filePath, "w", "DATA")
    if not file then
        print("Impossible d'ouvrir le fichier pour écriture " .. filePath)
        return
    end

    for steamID64, limit in pairs(NlCustomPropsLimit) do
        file:Write(steamID64 .. " " .. limit .. "\n")
    end

    file:Close()
end

-- Charger les limites personnalisées depuis le fichier au démarrage
LoadCustomLimitsFromFile("custom_limits.txt")

-- Commande pour modifier la limite de props d'un joueur, uniquement via la console serveur
concommand.Add("set_player_prop_limit", function(ply, cmd, args)
    -- Vérifie si la commande est exécutée par la console du serveur (ply == nil si exécutée par la console serveur)
    if ply ~= NULL then
        print("Cette commande ne peut être exécutée que par la console du serveur.")
        return
    end

    local targetSteamID64 = args[1]
    local newLimit = tonumber(args[2])

    if not targetSteamID64 or not newLimit then
        print("Usage: set_player_prop_limit <SteamID64> <Limite>")
        return
    end

    NlCustomPropsLimit[targetSteamID64] = newLimit
    SaveCustomLimitsToFile("custom_limits.txt")
    print("Limite de props pour " .. targetSteamID64 .. " définie à " .. newLimit)
end)

hook.Add("PlayerSpawnProp", "NL_PropLimit", function(ply)
    local steamID64 = ply:SteamID64() -- Récupère le SteamID64 du joueur
    local userGroup = ply:GetUserGroup() -- Récupère le groupe de l'utilisateur
    local propCount = ply:GetCount("props") -- Récupère le nombre actuel de props du joueur
    
    -- Priorité 1 : Vérifier la limite personnalisée via la commande console
    if NlCustomPropsLimit[steamID64] then
        if propCount >= NlCustomPropsLimit[steamID64] then
            ply:ChatPrint("Vous avez atteint votre limite de props personnalisée (" .. NlCustomPropsLimit[steamID64] .. ")!")
            return false
        end

    -- Priorité 2 : Vérifier la limite définie via SteamID
    elseif NlPropsLimitSteamID[steamID64] then
        if propCount >= NlPropsLimitSteamID[steamID64] then
            ply:ChatPrint("Vous avez atteint la limite de props assignée pour votre SteamID (" .. NlPropsLimitSteamID[steamID64] .. ")!")
            return false
        end

    -- Priorité 3 : Vérifier la limite basée sur le groupe utilisateur
    elseif NlPropsLimitGroup[userGroup] then
        if propCount >= NlPropsLimitGroup[userGroup] then
            ply:ChatPrint("Vous avez atteint la limite de props pour votre groupe (" .. NlPropsLimitGroup[userGroup] .. ")!")
            return false
        end
    end

    return true -- Permet la création du prop
end)