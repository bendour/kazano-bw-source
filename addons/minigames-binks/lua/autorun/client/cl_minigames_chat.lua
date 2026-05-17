-- Charger la configuration correctement côté client
if file.Exists("autorun/mg_minigames_config.lua", "LUA") then
    include("autorun/mg_minigames_config.lua")
elseif MG_MINIGAMES_CONFIG then
    -- La configuration a déjà été chargée via autorun
else
    error("[Mini-Jeux] Fichier de configuration mg_minigames_config.lua introuvable !")
end

local MG_COLORS = {
    prefix = Color(unpack(MG_MINIGAMES_CONFIG.colors.prefix)),
    message = Color(unpack(MG_MINIGAMES_CONFIG.colors.message)),
    winner = Color(unpack(MG_MINIGAMES_CONFIG.colors.winner)),
    error = Color(unpack(MG_MINIGAMES_CONFIG.colors.error)),
}

-- Création des objets Color pour les variables
local MG_VARIABLE_COLORS = {}
if MG_MINIGAMES_CONFIG.colors.variables then
    for type, color in pairs(MG_MINIGAMES_CONFIG.colors.variables) do
        MG_VARIABLE_COLORS[type] = Color(unpack(color))
    end
else
    -- Fallback si l'ancienne configuration est utilisée
    local oldVarColor = MG_MINIGAMES_CONFIG.colors.variable or {255, 255, 0}
    MG_VARIABLE_COLORS.default = Color(unpack(oldVarColor))
end

-- Récupération du préfixe depuis la configuration
local MG_PREFIX = MG_MINIGAMES_CONFIG.prefix

-- Fonction pour traiter les messages avec séparateurs
local function ProcessMessage(msg)
    if string.find(msg, "<separator>") then
        -- Remplacer le séparateur par une chaîne vide
        return string.gsub(msg, "<separator>", "")
    end
    return msg
end

-- Fonction pour obtenir la couleur d'une variable en fonction de son type et de sa position
local function GetVariableColor(msgType, varIndex)
    if not MG_MINIGAMES_CONFIG.variable_types or not MG_MINIGAMES_CONFIG.variable_types[msgType] then
        return MG_VARIABLE_COLORS.default
    end
    
    local varType = MG_MINIGAMES_CONFIG.variable_types[msgType][varIndex] or "default"
    return MG_VARIABLE_COLORS[varType] or MG_VARIABLE_COLORS.default
end

-- Fonction pour colorer les variables %s dans un message
local function ColorizeVariables(msg, colorFunc, msgType)
    local parts = {}
    local lastPos = 1
    local varIndex = 1
    local pattern = "(.-)(%%s)(.*)"
    
    while true do
        local before, placeholder, after = string.match(msg, pattern, lastPos)
        
        if not before then break end
        
        table.insert(parts, {text = before, color = colorFunc()})
        
        -- Déterminer la couleur de la variable en fonction de son type
        local varColor = MG_VARIABLE_COLORS.default
        if msgType and MG_MINIGAMES_CONFIG.variable_types and MG_MINIGAMES_CONFIG.variable_types[msgType] then
            local varType = MG_MINIGAMES_CONFIG.variable_types[msgType][varIndex] or "default"
            varColor = MG_VARIABLE_COLORS[varType] or MG_VARIABLE_COLORS.default
        end
        
        table.insert(parts, {text = placeholder, color = varColor})
        
        msg = after
        lastPos = 1
        varIndex = varIndex + 1
        
        if msg == "" then break end
    end
    
    if msg ~= "" then
        table.insert(parts, {text = msg, color = colorFunc()})
    end
    
    return parts
end

-- Fonction pour afficher un message avec des variables colorées
local function DisplayColorizedMessage(prefix, msg, baseColor, msgType)
    local colorFunc = function() return baseColor end
    local parts = ColorizeVariables(msg, colorFunc, msgType)
    
    -- Construire le message final avec les couleurs
    local finalMessage = ""
    for _, part in ipairs(parts) do
        finalMessage = finalMessage .. part.text
    end
    
    -- Utiliser la syntaxe BaseWars pour afficher le message
    chat.AddText(MG_COLORS.prefix, prefix, baseColor, " » ", finalMessage)
end

-- Réception des messages normaux
net.Receive("MG_ChatMessage", function()
    local msgType = net.ReadString()
    local msg = net.ReadString()
    msg = ProcessMessage(msg)
    
    -- Vérifier si le préfixe contient un séparateur
    if string.find(MG_PREFIX, "<separator>") then
        -- Utiliser le préfixe sans le séparateur
        local prefix = string.gsub(MG_PREFIX, "<separator>", "")
        DisplayColorizedMessage(prefix, msg, MG_COLORS.message, msgType)
    else
        DisplayColorizedMessage(MG_PREFIX, msg, MG_COLORS.message, msgType)
    end
    
    -- Jouer un son pour attirer l'attention
    surface.PlaySound("buttons/button15.wav")
end)

-- Réception des messages de victoire
net.Receive("MG_WinnerMessage", function()
    local msgType = net.ReadString()
    local msg = net.ReadString()
    local winner = net.ReadEntity()
    
    msg = ProcessMessage(msg)
    
    -- Vérifier si le préfixe contient un séparateur
    if string.find(MG_PREFIX, "<separator>") then
        -- Utiliser le préfixe sans le séparateur
        local prefix = string.gsub(MG_PREFIX, "<separator>", "")
        DisplayColorizedMessage(prefix, msg, MG_COLORS.winner, msgType)
    else
        DisplayColorizedMessage(MG_PREFIX, msg, MG_COLORS.winner, msgType)
    end
    
    -- Jouer un son spécial pour le gagnant
    if LocalPlayer() == winner then
        surface.PlaySound("garrysmod/content_downloaded.wav")
    end
end)

-- Message d'initialisation pour vérifier que le script client est chargé
-- Script client chargé avec succès