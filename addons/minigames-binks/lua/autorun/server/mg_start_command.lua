-- Commandes pour les Mini-Jeux
-- Ce fichier ajoute des commandes supplémentaires pour démarrer les mini-jeux
-- Chargement des commandes supplémentaires

-- Attendre que le fichier principal soit chargé
hook.Add("Initialize", "MG_CommandsInit", function()
    -- Commande console alternative
    concommand.Add("minigame_start", function(ply, cmd, args)
        -- Commande minigame_start exécutée
        if IsValid(ply) and not ply:IsAdmin() then 
            -- Commande refusée: joueur non admin
            return 
        end
        
        -- Vérifier si un jeu est déjà en cours
        if _G.waitingForAnswer then 
            if IsValid(ply) then
                ply:ChatPrint("[Mini-Jeu] Un mini-jeu est déjà en cours!")
            else
                -- Un mini-jeu est déjà en cours
            end
            return 
        end
        
        -- Démarrer un mini-jeu directement
        if StartNextMiniGame then
            -- Démarrage d'un mini-jeu via StartNextMiniGame
            StartNextMiniGame()
        else
            -- ERREUR: Fonction StartNextMiniGame non trouvée
            RunConsoleCommand("mg_start")
        end
    end)

    -- Commandes chat pour les admins
    hook.Add("PlayerSay", "MG_AdminCommands", function(ply, text)
        if not IsValid(ply) or not ply:IsAdmin() then return end
        
        local lowerText = string.lower(text)
        if lowerText == "!minigame" or lowerText == "!mg" then
            -- Commande chat exécutée par " .. ply:Nick()
            
            -- Vérifier si un jeu est déjà en cours
            if _G.waitingForAnswer then
                ply:ChatPrint("[Mini-Jeu] Un mini-jeu est déjà en cours!")
                return ""
            end
            
            -- Démarrer un mini-jeu directement
            if StartNextMiniGame then
                -- Démarrage d'un mini-jeu via StartNextMiniGame
                StartNextMiniGame()
            else
                -- ERREUR: Fonction StartNextMiniGame non trouvée
                RunConsoleCommand("mg_start")
            end
            return ""
        end
    end)
    
    -- Commandes supplémentaires chargées
end)