-- MiniGames Chat Addon pour GMod

-- Charger la configuration correctement côté serveur
if file.Exists("autorun/mg_minigames_config.lua", "LUA") then
    include("autorun/mg_minigames_config.lua")
else
    MG_MINIGAMES_CONFIG = {
        answer_time = 30,
        auto_start = true,
        auto_start_delay = 300,
        messages = {
            calcul_start = "Résous ce calcul : %s %s %s",
            win_calcul = "Le joueur %s remporte le jeu en %ss ! La réponse était : %s",
            no_winner = "Personne n'a trouvé la bonne réponse à temps !"
        }
    }
end
-- Auteur: VotreNom

util.AddNetworkString("MG_ChatMessage")
util.AddNetworkString("MG_WinnerMessage")

local activeGame = nil


_G.waitingForAnswer = false -- Rendu global pour être accessible depuis mg_start_command.lua
local playersAnswered = {}




local reactionStartTime = 0
local calculAnswer = 0
local GAME_INTERVAL = MG_MINIGAMES_CONFIG.auto_start_delay or 60

-- Déclaration anticipée de EndGame pour qu'elle soit accessible
function EndGame(winner)
    _G.waitingForAnswer = false
    timer.Remove("MG_AnswerTimer")

    local reactionTime = math.Round(CurTime() - reactionStartTime, 2)
    if IsValid(winner) then
        winner:AddCredit(10)
        BaseWars:Notify(winner, "Vous avez gagné 10 crédits pour avoir remporté le mini-jeu !", NOTIFICATION_GENERIC, 5)

        net.Start("MG_WinnerMessage")
        local msgType = "win_calcul"
        net.WriteString(msgType)
        if MG_MINIGAMES_CONFIG.messages and MG_MINIGAMES_CONFIG.messages.win_calcul then
            net.WriteString(string.format(MG_MINIGAMES_CONFIG.messages.win_calcul, winner:Nick(), reactionTime, calculAnswer))
        else
            net.WriteString("Le joueur " .. winner:Nick() .. " remporte le jeu en " .. reactionTime .. "s ! La réponse était : " .. calculAnswer)
        end
        net.WriteEntity(winner)
        net.Broadcast()
    else
        net.Start("MG_WinnerMessage")
        local msgType = "no_winner"
        net.WriteString(msgType)
        if MG_MINIGAMES_CONFIG.messages and MG_MINIGAMES_CONFIG.messages.no_winner then
            net.WriteString(MG_MINIGAMES_CONFIG.messages.no_winner)
        else
            net.WriteString("Personne n'a trouvé la bonne réponse à temps !")
        end
        net.WriteEntity(NULL)
        net.Broadcast()
    end

    timer.Simple(GAME_INTERVAL, function()
        if MG_MINIGAMES_CONFIG.auto_start ~= false then
            StartNextMiniGame()
        end
    end)
end



local function StartCalcul()
    -- Choisir une opération parmi +, -, *, /
    local opIndex = math.random(4)
    local opSym
    local a, b

    if opIndex == 1 then
        -- Addition
        opSym = "+"
        a = math.random(10, 99)
        b = math.random(10, 99)
        calculAnswer = a + b
    elseif opIndex == 2 then
        -- Soustraction (peut être négatif)
        opSym = "-"
        a = math.random(10, 99)
        b = math.random(10, 99)
        calculAnswer = a - b
    elseif opIndex == 3 then
        -- Multiplication
        opSym = "*"
        a = math.random(2, 12)
        b = math.random(2, 12)
        calculAnswer = a * b
    else
        -- Division (toujours un résultat entier)
        opSym = "/"
        b = math.random(2, 12)
        local q = math.random(2, 12) -- quotient
        a = b * q
        calculAnswer = q
    end

    _G.waitingForAnswer = true
    playersAnswered = {}
    activeGame = "calcul"
    reactionStartTime = CurTime()
    net.Start("MG_ChatMessage")
    local msgType = "calcul_start"
    net.WriteString(msgType)
    if MG_MINIGAMES_CONFIG.messages and MG_MINIGAMES_CONFIG.messages.calcul_start then
        net.WriteString(string.format(MG_MINIGAMES_CONFIG.messages.calcul_start, a, opSym, b))
    else
        net.WriteString("Résous ce calcul : " .. a .. " " .. opSym .. " " .. b)
    end
    net.Broadcast()

    timer.Create("MG_AnswerTimer", MG_MINIGAMES_CONFIG.answer_time or 30, 1, function()
        if _G.waitingForAnswer then EndGame(nil) end
    end)
end



-- Fonction rendue globale pour être accessible depuis mg_start_command.lua
function StartNextMiniGame()
    -- Démarrer uniquement le mini-jeu de calcul
    StartCalcul()
end

hook.Add("PlayerSay", "MG_ChatMiniGames", function(ply, text)
    if not _G.waitingForAnswer or playersAnswered[ply] then return end

    if activeGame == "calcul" and tonumber(text) and tonumber(text) == calculAnswer then
        playersAnswered[ply] = true
        EndGame(ply)
        return ""
    end
end)

-- Commande admin pour lancer un mini-jeu
concommand.Add("mg_start", function(ply, cmd, args)
    -- Commande mg_start exécutée depuis sv_minigames_chat.lua
    if IsValid(ply) and not ply:IsAdmin() then 
        -- Commande refusée: joueur non admin
        return 
    end
    if _G.waitingForAnswer then 
        -- Un mini-jeu est déjà en cours
        return 
    end
    -- Démarrage d'un mini-jeu via StartNextMiniGame
    StartNextMiniGame()
end)

-- Lancer automatiquement un mini-jeu au démarrage
hook.Add("Initialize", "MG_AutoStartMiniGame", function()
    -- Initialisation du système de mini-jeux
    if MG_MINIGAMES_CONFIG.auto_start ~= false then
        timer.Simple(MG_MINIGAMES_CONFIG.auto_start_delay or 5, function()
            -- Démarrage automatique du premier mini-jeu
            StartNextMiniGame()
        end)
    end
end)
