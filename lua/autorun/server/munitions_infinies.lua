-- Fichier de sauvegarde des SteamID64 autorisés
local dataFileName = "infinite_ammo_steamids.txt"

-- Charge les SteamID64 depuis le fichier de données
local function LoadSteamIDs()
    if file.Exists(dataFileName, "DATA") then
        local data = file.Read(dataFileName, "DATA")
        return util.JSONToTable(data) or {}
    else
        return {}
    end
end

-- Sauvegarde les SteamID64 dans le fichier de données
local function SaveSteamIDs(steamIDList)
    file.Write(dataFileName, util.TableToJSON(steamIDList))
end

-- Initialisation de la liste des SteamID64
local steamID64List = LoadSteamIDs()

-- Fonction pour donner des munitions infinies au joueur
local function GiveInfiniteAmmo(ply)
    if IsValid(ply) and ply:IsPlayer() then
        for _, weapon in pairs(ply:GetWeapons()) do
            if IsValid(weapon) then
                local primaryAmmoType = weapon:GetPrimaryAmmoType()
                local secondaryAmmoType = weapon:GetSecondaryAmmoType()

                -- Vérifie si le type de munition est valide pour l'arme principale
                if primaryAmmoType ~= -1 then
                    ply:GiveAmmo(9999, primaryAmmoType, true)
                end

                -- Vérifie si le type de munition est valide pour l'arme secondaire
                if secondaryAmmoType ~= -1 then
                    ply:GiveAmmo(9999, secondaryAmmoType, true)
                end
            end
        end
    end
end


-- Fonction appelée lorsqu'un joueur est spawn
hook.Add("PlayerSpawn", "GivePlayerInfiniteAmmo", function(ply)
    if IsValid(ply) and ply:IsPlayer() then
        local steamID64 = ply:SteamID64()

        -- Vérifie si le SteamID64 du joueur est dans la liste
        if table.HasValue(steamID64List, steamID64) then
            timer.Simple(1, function()
                if IsValid(ply) then
                    GiveInfiniteAmmo(ply)
                end
            end)
        end
    end
end)

-- Hook pour redonner des munitions infinies lorsque le joueur obtient une nouvelle arme (comme via le menu F4)
hook.Add("PlayerLoadout", "GiveAmmoOnWeaponBuy", function(ply)
    if IsValid(ply) and ply:IsPlayer() then
        local steamID64 = ply:SteamID64()

        -- Vérifie si le joueur a des munitions infinies
        if table.HasValue(steamID64List, steamID64) then
            timer.Simple(1, function()
                if IsValid(ply) then
                    GiveInfiniteAmmo(ply)
                end
            end)
        end
    end
end)

-- Commandes de la console du serveur
concommand.Add("sv_add_infinite_ammo", function(ply, cmd, args)
    if not IsValid(ply) then -- Vérification que la commande est lancée depuis la console serveur
        local steamID64 = args[1]
        if steamID64 and not table.HasValue(steamID64List, steamID64) then
            table.insert(steamID64List, steamID64)
            SaveSteamIDs(steamID64List)
            print("Le joueur avec le SteamID64 " .. steamID64 .. " a maintenant des munitions infinies.")
        else
            print("Ce SteamID64 est déjà dans la liste ou est invalide.")
        end
    end
end)

concommand.Add("sv_remove_infinite_ammo", function(ply, cmd, args)
    if not IsValid(ply) then -- Vérification que la commande est lancée depuis la console serveur
        local steamID64 = args[1]
        if steamID64 and table.HasValue(steamID64List, steamID64) then
            table.RemoveByValue(steamID64List, steamID64)
            SaveSteamIDs(steamID64List)
            print("Le joueur avec le SteamID64 " .. steamID64 .. " n'a plus de munitions infinies.")
        else
            print("Ce SteamID64 n'est pas dans la liste ou est invalide.")
        end
    end
end)

concommand.Add("sv_list_infinite_ammo", function(ply, cmd, args)
    if not IsValid(ply) then -- Vérification que la commande est lancée depuis la console serveur
        print("Liste des joueurs avec des munitions infinies :")
        for _, steamID64 in ipairs(steamID64List) do
            print(steamID64)
        end
    end
end)