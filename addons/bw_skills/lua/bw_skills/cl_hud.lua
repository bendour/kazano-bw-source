--[[
    Client HUD - Affichage des compétences et keybinds
]]

-- Variables locales
local skillHUDEnabled = true

-- Créer les fonts
surface.CreateFont("BWSkills_Name", {
    font = "Roboto",
    size = 16,
    weight = 600
})

surface.CreateFont("BWSkills_Key", {
    font = "Roboto",
    size = 24,
    weight = 800
})

surface.CreateFont("BWSkills_Cooldown", {
    font = "Roboto Mono",
    size = 14,
    weight = 500
})

-- Dessiner le HUD
hook.Add("HUDPaint", "BWSkills:DrawHUD", function()
    if not skillHUDEnabled then return end
    
    local data = BWSkills.LocalData
    if not data then return end
    
    local lp = LocalPlayer()
    if not IsValid(lp) or not lp:Alive() then return end
    
    local scrW, scrH = ScrW(), ScrH()
    local boxW, boxH = 120, 70
    local spacing = 15
    local startX = scrW / 2 - boxW - spacing / 2
    local startY = scrH - 130
    
    for slot = 1, 2 do
        local x = startX + (slot - 1) * (boxW + spacing)
        local y = startY
        
        local skillId = slot == 1 and data.skill1 or data.skill2
        local skill = skillId and BWSkills.Skills[skillId] or nil
        local keyCode = slot == 1 and data.key1 or data.key2
        local keyName = input.GetKeyName(keyCode or (slot == 1 and BWSkills.Config.DefaultKey1 or BWSkills.Config.DefaultKey2)) or "?"
        
        local cooldowns = data.cooldowns or {0, 0}
        local cooldownEnd = cooldowns[slot] or 0
        local remaining = math.max(0, cooldownEnd - CurTime())
        local onCooldown = remaining > 0
        
        -- Fond
        local bgAlpha = onCooldown and 180 or 220
        draw.RoundedBox(8, x, y, boxW, boxH, Color(20, 20, 30, bgAlpha))
        
        -- Bordure selon état
        local borderColor
        if not skill then
            borderColor = Color(60, 60, 70)
        elseif onCooldown then
            borderColor = Color(255, 100, 100, 200)
        else
            borderColor = BWSkills.Rarities[skill.rarity].color
        end
        
        surface.SetDrawColor(borderColor)
        surface.DrawOutlinedRect(x, y, boxW, boxH, 2)
        
        -- Cooldown overlay
        if onCooldown and skill then
            local totalCooldown = skill.cooldown
            local progress = remaining / totalCooldown
            local overlayH = boxH * progress
            
            draw.RoundedBox(8, x + 2, y + (boxH - overlayH), boxW - 4, overlayH - 2, Color(0, 0, 0, 150))
        end
        
        -- Contenu
        if skill then
            local rarity = BWSkills.Rarities[skill.rarity]
            
            -- Nom de la compétence
            local nameColor = onCooldown and Color(150, 150, 150) or rarity.color
            draw.SimpleText(skill.name, "BWSkills_Name", x + boxW / 2, y + 15, nameColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            -- Cooldown ou Ready
            if onCooldown then
                draw.SimpleText(string.format("%.1fs", remaining), "BWSkills_Cooldown", x + boxW / 2, y + 35, Color(255, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText("READY", "BWSkills_Cooldown", x + boxW / 2, y + 35, Color(100, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        else
            draw.SimpleText("Vide", "BWSkills_Name", x + boxW / 2, y + 25, Color(80, 80, 80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Touche
        local keyBgColor = onCooldown and Color(60, 40, 40) or Color(50, 50, 60)
        draw.RoundedBox(4, x + boxW / 2 - 15, y + boxH - 25, 30, 22, keyBgColor)
        draw.SimpleText(string.upper(keyName), "BWSkills_Key", x + boxW / 2, y + boxH - 14, Color(255, 200, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)

-- Gérer les touches
hook.Add("PlayerButtonDown", "BWSkills:KeyPress", function(ply, button)
    if ply ~= LocalPlayer() then return end
    if gui.IsGameUIVisible() or gui.IsConsoleVisible() then return end
    if IsValid(vgui.GetKeyboardFocus()) then return end
    
    local data = BWSkills.LocalData
    if not data then return end
    
    local slot = nil
    
    if button == data.key1 then
        slot = 1
    elseif button == data.key2 then
        slot = 2
    end
    
    if slot then
        local skillId = slot == 1 and data.skill1 or data.skill2
        if skillId then
            net.Start("BWSkills:UseSkill")
            net.WriteUInt(slot, 2)
            net.SendToServer()
        end
    end
end)

-- Commande console pour toggle le HUD
concommand.Add("bw_skills_hud", function(ply, cmd, args)
    skillHUDEnabled = not skillHUDEnabled
    print("[BW Skills] HUD " .. (skillHUDEnabled and "activé" or "désactivé"))
end)
