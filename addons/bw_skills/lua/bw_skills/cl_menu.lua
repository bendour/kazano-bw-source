--[[
    Client Menu - Interface HTML des compétences
]]

BWSkills.LocalData = BWSkills.LocalData or {}
BWSkills.MenuPanel = nil
BWSkills.DHTML = nil
BWSkills.BindingSlot = nil

-- Recevoir les données du serveur
net.Receive("BWSkills:SyncData", function()
    BWSkills.LocalData = net.ReadTable()
    BWSkills.LocalData.cooldowns = BWSkills.LocalData.cooldowns or {0, 0}
    
    -- Mettre à jour le menu HTML si ouvert
    if IsValid(BWSkills.DHTML) then
        BWSkills:UpdateHTMLData()
    end
end)

-- Recevoir le HTML compilé
net.Receive("BWSkills:LoadHTML", function()
    local html = net.ReadString()
    
    if IsValid(BWSkills.MenuPanel) then
        BWSkills.MenuPanel:Remove()
    end
    
    -- Créer le panel
    BWSkills.MenuPanel = vgui.Create("DFrame")
    BWSkills.MenuPanel:SetSize(ScrW(), ScrH())
    BWSkills.MenuPanel:SetTitle("")
    BWSkills.MenuPanel:SetDraggable(false)
    BWSkills.MenuPanel:ShowCloseButton(false)
    BWSkills.MenuPanel:MakePopup()
    BWSkills.MenuPanel:Center()
    
    BWSkills.MenuPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
    end
    
    -- Créer le DHTML
    local dhtml = vgui.Create("DHTML", BWSkills.MenuPanel)
    BWSkills.DHTML = dhtml
    dhtml:Dock(FILL)
    dhtml:SetAllowLua(true)
    
    -- Exposer les fonctions Lua au JavaScript
    dhtml:AddFunction("bwskills", "close", function()
        if IsValid(BWSkills.MenuPanel) then
            BWSkills.MenuPanel:Remove()
        end
    end)
    
    dhtml:AddFunction("bwskills", "roll", function()
        net.Start("BWSkills:Roll")
        net.SendToServer()
    end)
    
    dhtml:AddFunction("bwskills", "replace", function(slot, skillId)
        net.Start("BWSkills:ReplaceSkill")
        net.WriteUInt(tonumber(slot), 2)
        net.WriteString(skillId)
        net.SendToServer()
    end)
    
    dhtml:AddFunction("bwskills", "cancelRoll", function()
        net.Start("BWSkills:CancelRoll")
        net.SendToServer()
    end)
    
    dhtml:AddFunction("bwskills", "startBind", function(slot)
        BWSkills.BindingSlot = tonumber(slot)
    end)
    
    -- Charger le HTML
    dhtml:SetHTML(html)
    
    -- Injecter les données après chargement
    timer.Simple(0.3, function()
        if IsValid(dhtml) then
            BWSkills:UpdateHTMLData()
            BWSkills:SendSkillsToHTML()
        end
    end)
end)

-- Mettre à jour les données dans le HTML
function BWSkills:UpdateHTMLData()
    if not IsValid(BWSkills.DHTML) then return end
    
    local data = BWSkills.LocalData
    local key1Name = input.GetKeyName(data.key1 or KEY_Z) or "Z"
    local key2Name = input.GetKeyName(data.key2 or KEY_X) or "X"
    
    local jsData = string.format([[
        receiveData({
            skill1: %s,
            skill2: %s,
            rolls_used: %d,
            key1: '%s',
            key2: '%s'
        });
    ]], 
        data.skill1 and ("'" .. data.skill1 .. "'") or "null",
        data.skill2 and ("'" .. data.skill2 .. "'") or "null",
        data.rolls_used or 0,
        key1Name,
        key2Name
    )
    
    BWSkills.DHTML:Call(jsData)
end

-- Envoyer la liste des compétences au HTML
function BWSkills:SendSkillsToHTML()
    if not IsValid(BWSkills.DHTML) then return end
    
    local skillsData = {}
    for id, skill in pairs(BWSkills.Skills) do
        skillsData[id] = {
            name = skill.name,
            description = skill.description,
            rarity = skill.rarity,
            cooldown = skill.cooldown,
            duration = skill.duration
        }
    end
    
    local json = util.TableToJSON(skillsData)
    BWSkills.DHTML:Call("receiveSkills(" .. json .. ");")
end

-- Recevoir le résultat d'un roll
net.Receive("BWSkills:RollResult", function()
    local success = net.ReadBool()
    local data = net.ReadString()
    
    if success then
        local skillId = data
        local needsReplace = net.ReadBool()
        local rollsUsed = net.ReadUInt(16)
        
        BWSkills.LocalData.rolls_used = rollsUsed
        
        if IsValid(BWSkills.DHTML) then
            BWSkills.DHTML:Call(string.format("onRollResult(true, '%s', %s);", skillId, needsReplace and "true" or "false"))
        end
        
        if not needsReplace then
            local skill = BWSkills.Skills[skillId]
            if skill then
                chat.AddText(
                    Color(100, 255, 100), "[Skills] ",
                    Color(255, 255, 255), "Vous avez obtenu : ",
                    BWSkills.Rarities[skill.rarity].color, skill.name
                )
            end
        end
    else
        if IsValid(BWSkills.DHTML) then
            BWSkills.DHTML:Call(string.format("onRollResult(false, '%s', false);", string.JavascriptSafe(data)))
        end
        chat.AddText(Color(255, 100, 100), "[Skills] ", Color(255, 255, 255), data)
    end
end)

-- Recevoir la mise à jour des cooldowns
net.Receive("BWSkills:UpdateCooldown", function()
    local slot = net.ReadUInt(2)
    local cooldown = net.ReadFloat()
    
    BWSkills.LocalData.cooldowns = BWSkills.LocalData.cooldowns or {0, 0}
    BWSkills.LocalData.cooldowns[slot] = cooldown
end)

-- Ouvrir le menu
net.Receive("BWSkills:OpenMenu", function()
    BWSkills:OpenSkillsMenu()
end)

function BWSkills:OpenSkillsMenu()
    net.Start("BWSkills:RequestHTML")
    net.SendToServer()
end

-- Gestion des keybinds dans le menu
hook.Add("PlayerButtonDown", "BWSkills:MenuKeyBind", function(ply, button)
    if ply ~= LocalPlayer() then return end
    if not IsValid(BWSkills.MenuPanel) then return end
    if not BWSkills.BindingSlot then return end
    
    local keyName = input.GetKeyName(button)
    if not keyName then return end
    
    local slot = BWSkills.BindingSlot
    BWSkills.BindingSlot = nil
    
    -- Mettre à jour localement
    if slot == 1 then
        BWSkills.LocalData.key1 = button
    else
        BWSkills.LocalData.key2 = button
    end
    
    -- Envoyer au serveur
    net.Start("BWSkills:SaveKeybinds")
    net.WriteUInt(BWSkills.LocalData.key1 or KEY_Z, 8)
    net.WriteUInt(BWSkills.LocalData.key2 or KEY_X, 8)
    net.SendToServer()
    
    -- Mettre à jour le HTML
    if IsValid(BWSkills.DHTML) then
        BWSkills.DHTML:Call(string.format("finishBind(%d, '%s');", slot, keyName))
    end
end)

-- Après remplacement d'une compétence, mettre à jour
hook.Add("Think", "BWSkills:WatchSync", function()
    -- Cette fonction est appelée via SyncToClient qui déclenche BWSkills:SyncData
end)

-- Vision Thermique
BWSkills.ThermalVisionActive = false

net.Receive("BWSkills:ThermalVision", function()
    local ply = net.ReadEntity()
    local active = net.ReadBool()
    
    if ply == LocalPlayer() then
        BWSkills.ThermalVisionActive = active
    end
end)

hook.Add("PreDrawHalos", "BWSkills:ThermalVision", function()
    if not BWSkills.ThermalVisionActive then return end
    
    local players = {}
    local localPly = LocalPlayer()
    
    for _, ply in ipairs(player.GetAll()) do
        if ply ~= localPly and ply:Alive() then
            table.insert(players, ply)
        end
    end
    
    if #players > 0 then
        halo.Add(players, Color(255, 50, 50), 3, 3, 2, true, true)
    end
end)

hook.Add("HUDPaint", "BWSkills:ThermalVisionOverlay", function()
    if not BWSkills.ThermalVisionActive then return end
    
    -- Effet de scan thermique
    surface.SetDrawColor(255, 0, 0, 10)
    surface.DrawRect(0, 0, ScrW(), ScrH())
    
    -- Afficher les distances des joueurs
    local localPly = LocalPlayer()
    for _, ply in ipairs(player.GetAll()) do
        if ply ~= localPly and ply:Alive() then
            local pos = ply:GetPos():ToScreen()
            if pos.visible then
                local dist = math.floor(localPly:GetPos():Distance(ply:GetPos()) / 52.49) -- Convertir en mètres
                draw.SimpleText(dist .. "m", "DermaDefault", pos.x, pos.y - 30, Color(255, 100, 100, 200), TEXT_ALIGN_CENTER)
            end
        end
    end
end)
