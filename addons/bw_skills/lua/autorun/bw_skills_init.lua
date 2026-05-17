--[[
    BW Skills - Système de Compétences pour BaseWars
    Par Kazano
]]

BWSkills = BWSkills or {}
BWSkills.Config = BWSkills.Config or {}
BWSkills.Skills = BWSkills.Skills or {}
BWSkills.PlayerData = BWSkills.PlayerData or {}

-- Configuration
BWSkills.Config.MaxSkills = 2                    -- Nombre max de compétences
BWSkills.Config.FreeRolls = 2                    -- Rolls gratuits
BWSkills.Config.RollCost = 1000                  -- Coût d'un roll en crédits
BWSkills.Config.DefaultKey1 = KEY_Z              -- Touche par défaut slot 1
BWSkills.Config.DefaultKey2 = KEY_X              -- Touche par défaut slot 2
BWSkills.Config.CooldownColor = Color(255, 100, 100)
BWSkills.Config.ReadyColor = Color(100, 255, 100)

-- Couleurs de rareté
BWSkills.Rarities = {
    [1] = {name = "Commun", color = Color(180, 180, 180)},
    [2] = {name = "Rare", color = Color(0, 150, 255)},
    [3] = {name = "Épique", color = Color(180, 70, 255)},
    [4] = {name = "Légendaire", color = Color(255, 180, 0)}
}

-- Probabilités de rareté (sur 100)
BWSkills.RarityChances = {
    [1] = 50,   -- 50% Commun
    [2] = 30,   -- 30% Rare
    [3] = 15,   -- 15% Épique
    [4] = 5     -- 5% Légendaire
}

if SERVER then
    AddCSLuaFile()
    AddCSLuaFile("bw_skills/sh_skills.lua")
    AddCSLuaFile("bw_skills/cl_menu.lua")
    AddCSLuaFile("bw_skills/cl_hud.lua")
    AddCSLuaFile("bw_skills/cl_f3integration.lua")
    
    -- Fichiers HTML (non inclus client-side, envoyés via net)
    AddCSLuaFile("bw_skills/html/skills_menu.html.lua")
    AddCSLuaFile("bw_skills/html/styles.css.lua")
    AddCSLuaFile("bw_skills/html/skills_menu.js.lua")
    
    include("bw_skills/sh_skills.lua")
    include("bw_skills/sv_database.lua")
    include("bw_skills/html_loader.lua")
    include("bw_skills/sv_main.lua")
end

if CLIENT then
    include("bw_skills/sh_skills.lua")
    include("bw_skills/cl_menu.lua")
    include("bw_skills/cl_hud.lua")
    include("bw_skills/cl_f3integration.lua")
end

print("[BW Skills] Addon chargé avec succès!")
