-- Définir l'URL du webhook Discord
local webhookURL = "https://discord.com/api/webhooks/1429149192072466444/D2vhm4u6jX5YwaoGg2M-iuAy3alORZm1e57RSIkC_om33czCucyLXjECtuXmp-sIDwVY"

-- Créer la table player_ips si elle n'existe pas déjà
sql.Query("CREATE TABLE IF NOT EXISTS player_ips (steamid64 TEXT PRIMARY KEY, ip_addresses TEXT)")

-- Vérifier si la colonne 'whitelisted' existe déjà et l'ajouter si nécessaire
local columns = sql.Query("PRAGMA table_info(player_ips)")
local hasWhitelistedColumn = false

if columns then
    for _, column in ipairs(columns) do
        if column.name == "whitelisted" then
            hasWhitelistedColumn = true
            break
        end
    end
end

-- Ajouter la colonne whitelisted si elle n'existe pas encore
if not hasWhitelistedColumn then
    sql.Query("ALTER TABLE player_ips ADD COLUMN whitelisted INTEGER DEFAULT 0")
    print("Colonne 'whitelisted' ajoutée à la table player_ips.")
end

-- Fonction pour vérifier si un SteamID64 est dans la whitelist
local function isWhitelisted(steamID64)
    local result = sql.QueryRow("SELECT whitelisted FROM player_ips WHERE steamid64 = '"..steamID64.."'")
    return result and result.whitelisted == "1"
end

-- Hook pour capturer l'événement de connexion du joueur
hook.Add("PlayerInitialSpawn", "LogPlayerIPAndNotify", function(ply)
    -- Récupérer le SteamID64 et l'adresse IP du joueur
    local steamID64 = ply:SteamID64()
    local ipAddress = ply:IPAddress()

    -- Supprimer le port de l'adresse IP
    ipAddress = string.Explode(":", ipAddress)[1]

    -- Enregistrer dans la base de données
    if steamID64 and ipAddress then
        -- Vérifier si le joueur est whitelisted
        if isWhitelisted(steamID64) then
            print("Le joueur avec le SteamID64 "..steamID64.." est dans la whitelist. Aucune notification envoyée.")
            return
        end

        -- Vérifier si un autre joueur a déjà utilisé cette IP
        local result = sql.Query("SELECT steamid64 FROM player_ips WHERE ip_addresses LIKE '%"..ipAddress.."%' AND steamid64 != '"..steamID64.."'")
        
        -- Initialiser la table otherPlayers
        local otherPlayers = {}

        if result then
            for _, row in ipairs(result) do
                table.insert(otherPlayers, row.steamid64)
            end
        end

        -- Si des joueurs ont utilisé la même IP, envoyer une notification
        if #otherPlayers > 0 then
            local message = {
                embeds = {
                    {
                        title = "IP Partagée Détectée",
                        description = "Le joueur avec le SteamID64 `" .. steamID64 .. "` s'est connecté avec l'IP `" .. ipAddress .. "` qui a déjà été utilisée par un autre joueur.",
                        color = 15158332, -- Couleur rouge
                        fields = {
                            {
                                name = "SteamID64 du joueur actuel",
                                value = steamID64,
                                inline = true
                            },
                            {
                                name = "IP utilisée",
                                value = ipAddress,
                                inline = true
                            },
                            {
                                name = "Autre(s) joueur(s)",
                                value = table.concat(otherPlayers, ", "),
                                inline = true
                            }
                        },
                        footer = {
                            text = "Détection d'IP partagée"
                        },
                        timestamp = os.date("!%Y-%m-%dT%TZ")
                    }
                }
            }

            -- Envoyer la requête HTTP au webhook Discord
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

        -- Récupérer les adresses IP existantes et les stocker dans une table
        local existingEntry = sql.QueryRow("SELECT ip_addresses FROM player_ips WHERE steamid64 = '"..steamID64.."'")

        if existingEntry then
            -- Si l'IP n'est pas déjà présente, on l'ajoute à la liste des IPs
            local ipList = string.Explode(",", existingEntry.ip_addresses)
            if not table.HasValue(ipList, ipAddress) then
                table.insert(ipList, ipAddress)
                local updatedIPs = table.concat(ipList, ",")
                sql.Query("UPDATE player_ips SET ip_addresses = '"..updatedIPs.."' WHERE steamid64 = '"..steamID64.."'")
            end
        else
            -- Si c'est un nouveau joueur, insérer une nouvelle entrée avec son IP et whitelisted = 0 par défaut
            sql.Query("INSERT INTO player_ips (steamid64, ip_addresses, whitelisted) VALUES ('"..steamID64.."', '"..ipAddress.."', 0)")
        end
    end
end)

-- Fonction utilitaire pour vérifier si une commande est exécutée dans la console du serveur
local function isServerConsole(ply)
    if IsValid(ply) and ply:IsPlayer() then
        ply:ChatPrint("Cette commande ne peut être exécutée que depuis la console du serveur.")
        return false
    end
    return true
end

-- Fonction d'affichage de messages d'erreur de syntaxe incorrecte
local function printUsage(usage)
    print("Usage : " .. usage)
end

-- Fonction utilitaire pour exécuter une requête de mise à jour et afficher un message de succès
local function updateWhitelistStatus(steamID64, status)
    sql.Query("UPDATE player_ips SET whitelisted = " .. status .. " WHERE steamid64 = '" .. steamID64 .. "'")
    if status == 1 then
        print("Le SteamID64 " .. steamID64 .. " a été ajouté à la whitelist.")
    else
        print("Le SteamID64 " .. steamID64 .. " a été retiré de la whitelist.")
    end
end

-- Commande pour whitelister un SteamID64
concommand.Add("wl_steamid", function(ply, cmd, args)
    if not isServerConsole(ply) then return end
    local steamID64 = args[1]
    
    if steamID64 then
        updateWhitelistStatus(steamID64, 1)
    else
        printUsage("whitelist_steamid <SteamID64>")
    end
end)

-- Commande pour retirer un SteamID64 de la whitelist
concommand.Add("rm_wl_steamid", function(ply, cmd, args)
    if not isServerConsole(ply) then return end
    local steamID64 = args[1]
    
    if steamID64 then
        updateWhitelistStatus(steamID64, 0)
    else
        printUsage("remove_whitelist_steamid <SteamID64>")
    end
end)

-- Commande pour afficher les IPs associées à un SteamID64
concommand.Add("track_ip", function(ply, cmd, args)
    if not isServerConsole(ply) then return end
    local steamID64 = args[1]
    
    if steamID64 then
        local result = sql.QueryRow("SELECT ip_addresses FROM player_ips WHERE steamid64 = '" .. steamID64 .. "'")
        if result then
            print("Les IPs pour le SteamID64 " .. steamID64 .. " : " .. result.ip_addresses)
        else
            print("Aucune donnée trouvée pour le SteamID64 " .. steamID64 .. ".")
        end
    else
        printUsage("check_steamid <SteamID64>")
    end
end)

-- Commande pour afficher les SteamID64 associés à une adresse IP
concommand.Add("track_player", function(ply, cmd, args)
    if not isServerConsole(ply) then return end
    local ipAddress = args[1]
    
    if ipAddress then
        local result = sql.Query("SELECT steamid64 FROM player_ips WHERE ip_addresses LIKE '%" .. ipAddress .. "%'")
        if result and #result > 0 then
            local steamIDs = {}
            for _, row in ipairs(result) do
                table.insert(steamIDs, row.steamid64)
            end
            print("Les SteamID64 associés à l'IP " .. ipAddress .. " : " .. table.concat(steamIDs, ", "))
        else
            print("Aucune donnée trouvée pour l'IP " .. ipAddress .. ".")
        end
    else
        printUsage("check_ip <Adresse IP>")
    end
end)

-- Commande pour lister tous les SteamID64 dans la whitelist
concommand.Add("wl_list", function(ply, cmd, args)
    if not isServerConsole(ply) then return end
    local result = sql.Query("SELECT steamid64 FROM player_ips WHERE whitelisted = 1")
    
    if result and #result > 0 then
        local whitelistedSteamIDs = {}
        for _, row in ipairs(result) do
            table.insert(whitelistedSteamIDs, row.steamid64)
        end
        print("SteamIDs dans la whitelist : " .. table.concat(whitelistedSteamIDs, ", "))
    else
        print("Aucun SteamID whitelisted trouvé.")
    end
end)