--[[
    Intégration avec le menu F3 de BaseWars
]]

if CLIENT then
    -- Ajouter un onglet au menu F3
    hook.Add("BaseWars:PopulateF3Menu", "BWSkills:AddF3Tab", function(tabs)
        table.insert(tabs, {
            name = "Compétences",
            icon = "icon16/lightning.png",
            order = 50,
            panel = function(parent)
                return BWSkills:CreateF3Panel(parent)
            end
        })
    end)
    
    -- Alternative: Hook sur le menu F3 si le hook ci-dessus ne fonctionne pas
    hook.Add("BaseWars:F3Menu:AddTab", "BWSkills:AddTab", function(menu)
        if menu.AddTab then
            menu:AddTab("Compétences", function(parent)
                return BWSkills:CreateF3Panel(parent)
            end, "icon16/lightning.png")
        end
    end)
    
    -- Créer le panel pour le menu F3
    function BWSkills:CreateF3Panel(parent)
        local data = BWSkills.LocalData or {}
        
        local panel = vgui.Create("DPanel", parent)
        panel:Dock(FILL)
        panel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(25, 25, 35, 255))
        end
        
        -- Scroll panel
        local scroll = vgui.Create("DScrollPanel", panel)
        scroll:Dock(FILL)
        scroll:DockMargin(20, 20, 20, 20)
        
        -- Titre
        local title = vgui.Create("DLabel", scroll)
        title:SetText("MES COMPÉTENCES")
        title:SetFont("DermaLarge")
        title:SetTextColor(Color(255, 255, 255))
        title:Dock(TOP)
        title:SetContentAlignment(5)
        title:DockMargin(0, 0, 0, 20)
        
        -- Container pour les cartes
        local cardsContainer = vgui.Create("DPanel", scroll)
        cardsContainer:Dock(TOP)
        cardsContainer:SetTall(200)
        cardsContainer.Paint = function() end
        
        -- Créer les cartes de compétences
        for slot = 1, 2 do
            local skillId = slot == 1 and data.skill1 or data.skill2
            local skill = skillId and BWSkills.Skills[skillId] or nil
            local rarity = skill and BWSkills.Rarities[skill.rarity] or nil
            
            local card = vgui.Create("DPanel", cardsContainer)
            card:SetSize(280, 180)
            card:SetPos((slot - 1) * 300 + 20, 0)
            
            card.Paint = function(self, w, h)
                draw.RoundedBox(12, 0, 0, w, h, Color(35, 35, 45))
                
                if rarity then
                    surface.SetDrawColor(rarity.color)
                else
                    surface.SetDrawColor(60, 60, 70)
                end
                surface.DrawOutlinedRect(0, 0, w, h, 2)
                
                -- Header
                draw.RoundedBoxEx(12, 0, 0, w, 35, Color(45, 45, 55), true, true, false, false)
                draw.SimpleText("SLOT " .. slot, "DermaDefaultBold", w / 2, 17, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                if skill then
                    draw.SimpleText(skill.name, "DermaLarge", w / 2, 60, rarity.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(rarity.name, "DermaDefault", w / 2, 85, rarity.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    
                    -- Description avec wrap
                    local desc = skill.description
                    draw.DrawText(desc, "DermaDefault", w / 2, 105, Color(180, 180, 180), TEXT_ALIGN_CENTER)
                    
                    draw.SimpleText("Cooldown: " .. skill.cooldown .. "s", "DermaDefault", w / 2, 145, Color(120, 120, 120), TEXT_ALIGN_CENTER)
                    
                    -- Touche
                    local keyCode = slot == 1 and data.key1 or data.key2
                    local keyName = input.GetKeyName(keyCode or KEY_Z) or "?"
                    draw.SimpleText("[" .. string.upper(keyName) .. "]", "DermaDefaultBold", w / 2, 165, Color(255, 200, 100), TEXT_ALIGN_CENTER)
                else
                    draw.SimpleText("Aucune compétence", "DermaLarge", w / 2, h / 2, Color(80, 80, 80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end
        
        -- Infos rolls
        local rollsUsed = data.rolls_used or 0
        local freeRolls = BWSkills.Config.FreeRolls
        local rollCost = rollsUsed >= freeRolls and BWSkills.Config.RollCost or 0
        
        local infoPanel = vgui.Create("DPanel", scroll)
        infoPanel:Dock(TOP)
        infoPanel:DockMargin(20, 30, 20, 10)
        infoPanel:SetTall(50)
        infoPanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 50))
            
            if rollCost > 0 then
                draw.SimpleText("Coût du prochain roll: " .. rollCost .. " crédits", "DermaDefaultBold", w / 2, h / 2, Color(255, 200, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                local remaining = freeRolls - rollsUsed
                draw.SimpleText("Rolls gratuits restants: " .. remaining .. "/" .. freeRolls, "DermaDefaultBold", w / 2, h / 2, Color(100, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        
        -- Bouton Roll
        local rollBtn = vgui.Create("DButton", scroll)
        rollBtn:Dock(TOP)
        rollBtn:DockMargin(150, 10, 150, 10)
        rollBtn:SetTall(50)
        rollBtn:SetText("")
        rollBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(180, 0, 0) or Color(139, 0, 0)
            draw.RoundedBox(10, 0, 0, w, h, col)
            draw.SimpleText("🎲 ROLL UNE COMPÉTENCE", "DermaDefaultBold", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        rollBtn.DoClick = function()
            net.Start("BWSkills:Roll")
            net.SendToServer()
        end
        
        -- Section Keybinds
        local keybindTitle = vgui.Create("DLabel", scroll)
        keybindTitle:SetText("CONFIGURATION DES TOUCHES")
        keybindTitle:SetFont("DermaDefaultBold")
        keybindTitle:SetTextColor(Color(200, 200, 200))
        keybindTitle:Dock(TOP)
        keybindTitle:SetContentAlignment(5)
        keybindTitle:DockMargin(0, 30, 0, 10)
        
        local keybindPanel = vgui.Create("DPanel", scroll)
        keybindPanel:Dock(TOP)
        keybindPanel:DockMargin(20, 0, 20, 20)
        keybindPanel:SetTall(70)
        keybindPanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 50))
        end
        
        -- Slot 1 keybind
        local lbl1 = vgui.Create("DLabel", keybindPanel)
        lbl1:SetText("Slot 1:")
        lbl1:SetPos(80, 25)
        lbl1:SizeToContents()
        lbl1:SetTextColor(Color(200, 200, 200))
        
        local bind1 = vgui.Create("DBinder", keybindPanel)
        bind1:SetPos(130, 20)
        bind1:SetSize(120, 30)
        bind1:SetValue(data.key1 or BWSkills.Config.DefaultKey1)
        bind1.OnChange = function(self, key)
            BWSkills.LocalData.key1 = key
            net.Start("BWSkills:SaveKeybinds")
            net.WriteUInt(key, 8)
            net.WriteUInt(BWSkills.LocalData.key2 or BWSkills.Config.DefaultKey2, 8)
            net.SendToServer()
        end
        
        -- Slot 2 keybind
        local lbl2 = vgui.Create("DLabel", keybindPanel)
        lbl2:SetText("Slot 2:")
        lbl2:SetPos(350, 25)
        lbl2:SizeToContents()
        lbl2:SetTextColor(Color(200, 200, 200))
        
        local bind2 = vgui.Create("DBinder", keybindPanel)
        bind2:SetPos(400, 20)
        bind2:SetSize(120, 30)
        bind2:SetValue(data.key2 or BWSkills.Config.DefaultKey2)
        bind2.OnChange = function(self, key)
            BWSkills.LocalData.key2 = key
            net.Start("BWSkills:SaveKeybinds")
            net.WriteUInt(BWSkills.LocalData.key1 or BWSkills.Config.DefaultKey1, 8)
            net.WriteUInt(key, 8)
            net.SendToServer()
        end
        
        -- Liste des compétences disponibles
        local listTitle = vgui.Create("DLabel", scroll)
        listTitle:SetText("COMPÉTENCES DISPONIBLES")
        listTitle:SetFont("DermaDefaultBold")
        listTitle:SetTextColor(Color(200, 200, 200))
        listTitle:Dock(TOP)
        listTitle:SetContentAlignment(5)
        listTitle:DockMargin(0, 20, 0, 10)
        
        local listPanel = vgui.Create("DPanel", scroll)
        listPanel:Dock(TOP)
        listPanel:DockMargin(20, 0, 20, 20)
        listPanel:SetTall(300)
        listPanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45))
        end
        
        local skillList = vgui.Create("DScrollPanel", listPanel)
        skillList:Dock(FILL)
        skillList:DockMargin(10, 10, 10, 10)
        
        -- Trier par rareté
        local sortedSkills = {}
        for id, skill in pairs(BWSkills.Skills) do
            table.insert(sortedSkills, {id = id, skill = skill})
        end
        table.sort(sortedSkills, function(a, b) return a.skill.rarity > b.skill.rarity end)
        
        for _, entry in ipairs(sortedSkills) do
            local skill = entry.skill
            local rarity = BWSkills.Rarities[skill.rarity]
            
            local row = vgui.Create("DPanel", skillList)
            row:Dock(TOP)
            row:DockMargin(0, 0, 0, 5)
            row:SetTall(50)
            row.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(45, 45, 55))
                surface.SetDrawColor(rarity.color.r, rarity.color.g, rarity.color.b, 100)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
                
                draw.SimpleText(skill.name, "DermaDefaultBold", 15, 12, rarity.color, TEXT_ALIGN_LEFT)
                draw.SimpleText(rarity.name, "DermaDefault", 15, 32, rarity.color, TEXT_ALIGN_LEFT)
                draw.SimpleText(skill.description, "DermaDefault", 150, h / 2, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText("CD: " .. skill.cooldown .. "s", "DermaDefault", w - 15, h / 2, Color(120, 120, 120), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
        
        return panel
    end
end
