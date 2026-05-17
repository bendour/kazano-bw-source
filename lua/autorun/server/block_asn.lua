local blockedASNFile = "blocked_asn.txt" -- Fichier pour stocker les ASN bloqués localement
local blockedASN = {} -- Table des ASN bloqués
local apiURL = "https://ipwhois.app/json/" -- URL de l'API pour obtenir l'ASN d'une IP
local webhookURL = "https://discord.com/api/webhooks/1429149192072466444/D2vhm4u6jX5YwaoGg2M-iuAy3alORZm1e57RSIkC_om33czCucyLXjECtuXmp-sIDwVY" -- Remplacez par votre URL de webhook Discord

-- Charger le module reqwest pour les webhooks Discord
require("reqwest")

-- Fonction pour charger les ASN bloqués depuis un fichier
local function LoadBlockedASN()
    if not file.Exists(blockedASNFile, "DATA") then
        file.Write(blockedASNFile, "") -- Crée le fichier s'il n'existe pas
    end

    local data = file.Read(blockedASNFile, "DATA") or ""
    blockedASN = {}

    -- Ajouter les ASN dans la table sans le préfixe "AS"
    for asn in string.gmatch(data, "[%d]+") do
        blockedASN[asn] = true
    end
end

-- Fonction pour sauvegarder les ASN bloqués dans un fichier
local function SaveBlockedASN()
    local asnList = {}
    for asn, _ in pairs(blockedASN) do
        table.insert(asnList, asn) -- Ajouter l'ASN sans le préfixe "AS"
    end
    file.Write(blockedASNFile, table.concat(asnList, "\n"))
end

-- Fonction pour récupérer l'ASN d'une IP via l'API
local function GetASNFromIP(ip, callback)
    http.Fetch(apiURL .. ip, function(body, _, _, _)
        local jsonResponse = util.JSONToTable(body)
        if jsonResponse and jsonResponse.asn then
            callback(jsonResponse.asn:sub(3)) -- Retirer le préfixe "AS" avant de le retourner
        else
            callback(nil)
        end
    end, function(error)
        callback(nil)
    end)
end

-- Fonction pour envoyer une notification Discord
local function SendDiscordNotification(steamID64, playerName, asn, action)
    local message = {
        username = "Kazano - Shield",
        content = string.format("**Action sur ASN**: %s\n**SteamID64**: %s\n**Nom du joueur**: %s\n**ASN**: %s",
            action, steamID64, playerName, asn)
    }

    reqwest({
        method = "POST",
        url = webhookURL,
        timeout = 30,
        body = util.TableToJSON(message), 
        type = "application/json",
        headers = {
            ["User-Agent"] = "Garry's Mod Server",
        },
        success = function(status, body, headers)
            print("Webhook envoyé avec succès. Statut: " .. status)
        end,
        failed = function(err, errExt)
            print("Erreur lors de l'envoi du webhook: " .. err .. " (" .. errExt .. ")")
        end
    })
end

-- Fonction pour vérifier l'ASN d'un joueur et kicker après 3 secondes
hook.Add("PlayerInitialSpawn", "CheckASNBlockAfterSpawn", function(ply)
    if not ply or not ply:IsValid() then return end

    -- Attendre 3 secondes après le spawn pour vérifier l'ASN
    timer.Simple(3, function()
        if not IsValid(ply) then return end

        local ip = ply:IPAddress():match("(%d+%.%d+%.%d+%.%d+)") -- Récupérer l'IP du joueur
        if not ip then return end

        -- Récupérer l'ASN de l'IP et vérifier après le délai
        GetASNFromIP(ip, function(asn)
            if asn then
                -- Vérifier si l'ASN est bloqué
                if blockedASN[asn] then
                    -- Si l'ASN est bloqué, expulser le joueur
                    print("[ASN Blocker] Le joueur " .. ply:Nick() .. " avec ASN " .. asn .. " est bloqué.")
                    ply:Kick("Our server is temporarily unavailable. Try again later or open a ticket on https://discord.gg/kazano if the problem persists")
                    -- Envoyer une notification Discord
                    SendDiscordNotification(ply:SteamID64(), ply:Nick(), asn, "Blocage")
                else
                    print("[ASN Blocker] ASN pour " .. ply:Nick() .. " (" .. asn .. ") n'est pas bloqué.")
                end
            else
                print("[ASN Blocker] Impossible de récupérer l'ASN pour l'IP " .. ip)
            end
        end)
    end)
end)

-- Commande pour bloquer un ASN
concommand.Add("asn_block", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end -- Superadmin uniquement
    local asn = args[1]
    if not asn or not tonumber(asn) then
        return
    end

    if blockedASN[asn] then
        return
    end

    blockedASN[asn] = true
    SaveBlockedASN()
end)

-- Commande pour débloquer un ASN
concommand.Add("asn_unblock", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end -- Superadmin uniquement
    local asn = args[1]
    if not asn or not tonumber(asn) then
        return
    end

    if not blockedASN[asn] then
        return
    end

    blockedASN[asn] = nil
    SaveBlockedASN()
end)

-- Commande pour afficher la liste des ASN bloqués
concommand.Add("asn_list", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end -- Superadmin uniquement
    for asn, _ in pairs(blockedASN) do
        print(" - " .. asn)
    end
end)

-- Charger les ASN bloqués au démarrage
LoadBlockedASN()