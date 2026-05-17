--[[
    Server Main - Logique des compétences
]]

-- Net messages
util.AddNetworkString("BWSkills:SyncData")
util.AddNetworkString("BWSkills:Roll")
util.AddNetworkString("BWSkills:RollResult")
util.AddNetworkString("BWSkills:ReplaceSkill")
util.AddNetworkString("BWSkills:CancelRoll")
util.AddNetworkString("BWSkills:UseSkill")
util.AddNetworkString("BWSkills:UpdateCooldown")
util.AddNetworkString("BWSkills:SaveKeybinds")
util.AddNetworkString("BWSkills:OpenMenu")
util.AddNetworkString("BWSkills:RequestHTML")
util.AddNetworkString("BWSkills:LoadHTML")
util.AddNetworkString("BWSkills:ThermalVision")

-- Stockage sécurisé des rolls en attente (côté serveur uniquement)
BWSkills.PendingRolls = BWSkills.PendingRolls or {}

-- Compiler le HTML au démarrage
local htmlCompiled = nil

hook.Add("Initialize", "BWSkills:CompileHTML", function()
    timer.Simple(1, function()
        if BWSkills.CompileHTML then
            htmlCompiled = BWSkills.CompileHTML()
            print("[BW Skills] HTML compilé avec succès!")
        end
    end)
end)

-- Envoyer le HTML au client
net.Receive("BWSkills:RequestHTML", function(len, ply)
    if not htmlCompiled then
        htmlCompiled = BWSkills.CompileHTML()
    end
    
    if htmlCompiled then
        net.Start("BWSkills:LoadHTML")
        net.WriteString(htmlCompiled)
        net.Send(ply)
    end
end)

-- Gérer le roll de compétence
net.Receive("BWSkills:Roll", function(len, ply)
    local steamid = ply:SteamID64()
    local data = BWSkills:GetPlayerData(ply)
    if not data then return end
    
    -- Anti-spam : vérifier si un roll est déjà en attente
    if BWSkills.PendingRolls[steamid] then
        net.Start("BWSkills:RollResult")
        net.WriteBool(false)
        net.WriteString("Vous avez déjà un roll en attente!")
        net.Send(ply)
        return
    end
    
    -- Vérifier si le joueur peut roll
    local cost = 0
    if data.rolls_used >= BWSkills.Config.FreeRolls then
        cost = BWSkills.Config.RollCost
        
        -- Vérifier les crédits
        if ply.GetCredit and ply:GetCredit() < cost then
            net.Start("BWSkills:RollResult")
            net.WriteBool(false)
            net.WriteString("Vous n'avez pas assez de crédits! (" .. cost .. " requis)")
            net.Send(ply)
            return
        end
    end
    
    -- Roll la compétence
    local skillId = BWSkills:RollSkill()
    
    if not skillId then
        net.Start("BWSkills:RollResult")
        net.WriteBool(false)
        net.WriteString("Erreur lors du roll!")
        net.Send(ply)
        return
    end
    
    -- Prélever les crédits si nécessaire
    if cost > 0 and ply.AddCredit then
        ply:AddCredit(-cost)
    end
    
    -- Incrémenter le compteur de rolls
    data.rolls_used = data.rolls_used + 1
    
    -- Déterminer où placer la compétence
    local needsReplace = data.skill1 ~= nil and data.skill2 ~= nil
    
    -- SÉCURITÉ : Stocker le roll côté serveur si remplacement nécessaire
    if needsReplace then
        BWSkills.PendingRolls[steamid] = {
            skillId = skillId,
            timestamp = CurTime()
        }
        
        -- Auto-expiration après 60 secondes
        timer.Create("BWSkills:PendingExpire:" .. steamid, 60, 1, function()
            BWSkills.PendingRolls[steamid] = nil
        end)
    end
    
    net.Start("BWSkills:RollResult")
    net.WriteBool(true)
    net.WriteString(skillId)
    net.WriteBool(needsReplace)
    net.WriteUInt(data.rolls_used, 16)
    net.Send(ply)
    
    -- Si pas besoin de remplacer, assigner directement
    if not needsReplace then
        if not data.skill1 then
            data.skill1 = skillId
        else
            data.skill2 = skillId
        end
        BWSkills:SavePlayerData(ply)
        BWSkills:SyncToClient(ply)
    end
end)

-- Gérer le remplacement de compétence (SÉCURISÉ)
net.Receive("BWSkills:ReplaceSkill", function(len, ply)
    local slot = net.ReadUInt(2) -- 1 ou 2
    -- On ignore le skillId envoyé par le client pour des raisons de sécurité
    net.ReadString() -- Consommer le string mais ne pas l'utiliser
    
    local steamid = ply:SteamID64()
    local data = BWSkills:GetPlayerData(ply)
    if not data then return end
    
    -- SÉCURITÉ : Récupérer le skill depuis le stockage serveur
    local pendingRoll = BWSkills.PendingRolls[steamid]
    if not pendingRoll then
        -- Pas de roll en attente, possible tentative de cheat
        print("[BW Skills] SECURITY: " .. ply:Nick() .. " (" .. steamid .. ") tried to replace skill without pending roll!")
        return
    end
    
    local newSkillId = pendingRoll.skillId
    
    -- Vérifier que la compétence existe toujours
    if not BWSkills.Skills[newSkillId] then
        BWSkills.PendingRolls[steamid] = nil
        return
    end
    
    -- Valider le slot
    if slot ~= 1 and slot ~= 2 then
        return
    end
    
    -- Appliquer le remplacement
    if slot == 1 then
        data.skill1 = newSkillId
    else
        data.skill2 = newSkillId
    end
    
    data.cooldowns[slot] = 0
    
    -- Nettoyer le roll en attente
    BWSkills.PendingRolls[steamid] = nil
    timer.Remove("BWSkills:PendingExpire:" .. steamid)
    
    BWSkills:SavePlayerData(ply)
    BWSkills:SyncToClient(ply)
    
    -- Log pour audit
    print("[BW Skills] " .. ply:Nick() .. " equipped skill: " .. newSkillId .. " in slot " .. slot)
end)

-- Sauvegarder les keybinds
net.Receive("BWSkills:SaveKeybinds", function(len, ply)
    local key1 = net.ReadUInt(8)
    local key2 = net.ReadUInt(8)
    
    local data = BWSkills:GetPlayerData(ply)
    if not data then return end
    
    data.key1 = key1
    data.key2 = key2
    
    BWSkills:SavePlayerData(ply)
end)

-- Gérer l'utilisation d'une compétence
net.Receive("BWSkills:UseSkill", function(len, ply)
    local slot = net.ReadUInt(2)
    
    local data = BWSkills:GetPlayerData(ply)
    if not data then return end
    
    local skillId = slot == 1 and data.skill1 or data.skill2
    if not skillId then return end
    
    local skill = BWSkills.Skills[skillId]
    if not skill then return end
    
    -- Vérifier le cooldown
    local cooldown = data.cooldowns[slot] or 0
    if cooldown > CurTime() then return end
    
    -- Vérifier si le joueur peut utiliser la compétence
    if not skill.canUse(ply) then return end
    
    -- Vérifier si le joueur est vivant
    if not ply:Alive() then return end
    
    -- Activer la compétence
    skill.onActivate(ply)
    
    -- Appliquer le cooldown
    data.cooldowns[slot] = CurTime() + skill.cooldown
    
    -- Si la compétence a une durée, programmer la désactivation
    if skill.duration > 0 then
        data.activeEffects[slot] = {
            skillId = skillId,
            endTime = CurTime() + skill.duration
        }
        
        timer.Create("BWSkills:Deactivate:" .. ply:SteamID64() .. ":" .. slot, skill.duration, 1, function()
            if IsValid(ply) then
                skill.onDeactivate(ply)
                local pdata = BWSkills:GetPlayerData(ply)
                if pdata then
                    pdata.activeEffects[slot] = nil
                end
            end
        end)
    end
    
    -- Synchroniser le cooldown
    net.Start("BWSkills:UpdateCooldown")
    net.WriteUInt(slot, 2)
    net.WriteFloat(data.cooldowns[slot])
    net.Send(ply)
end)

-- Hook pour les dégâts (bouclier, rage, vampire)
hook.Add("EntityTakeDamage", "BWSkills:DamageModifiers", function(target, dmg)
    local attacker = dmg:GetAttacker()
    
    -- Bouclier: réduire les dégâts de 75%
    if target:IsPlayer() and target.BWSkills_ShieldActive then
        dmg:ScaleDamage(0.25)
    end
    
    -- Immortalité: bloquer tous les dégâts
    if target:IsPlayer() and target.BWSkills_Immortal then
        dmg:ScaleDamage(0)
        return true
    end
    
    -- Rage: augmenter les dégâts de 40%
    if IsValid(attacker) and attacker:IsPlayer() and attacker.BWSkills_RageActive then
        dmg:ScaleDamage(1.4)
    end
    
    -- Vampire: voler 15% des dégâts en vie
    if IsValid(attacker) and attacker:IsPlayer() and attacker.BWSkills_Vampire then
        local stolenHealth = dmg:GetDamage() * 0.15
        local newHealth = math.min(attacker:Health() + stolenHealth, attacker:GetMaxHealth())
        attacker:SetHealth(newHealth)
    end
end)

-- Hook pour les dégâts de chute
hook.Add("GetFallDamage", "BWSkills:NoFallDamage", function(ply, speed)
    if ply.BWSkills_NoFallDamage then
        return 0
    end
    
    -- Rebond
    if ply.BWSkills_BounceReady then
        ply.BWSkills_BounceReady = false
        ply:SetVelocity(Vector(0, 0, speed * 0.8))
        ply:EmitSound("physics/rubber/rubber_tire_impact_bullet1.wav")
        return 0
    end
end)

-- Hook pour la marque de mort (dégâts supplémentaires)
hook.Add("EntityTakeDamage", "BWSkills:DeathMark", function(target, dmg)
    if target:IsPlayer() and target.BWSkills_DeathMarked then
        local attacker = dmg:GetAttacker()
        if IsValid(attacker) and attacker == target.BWSkills_DeathMarkedBy then
            dmg:ScaleDamage(1.5) -- 50% de dégâts en plus
        end
    end
end)

-- Hook pour la résurrection
hook.Add("PlayerDeath", "BWSkills:Resurrection", function(ply)
    if ply.BWSkills_HasResurrection then
        ply.BWSkills_HasResurrection = false
        local respawnPos = ply.BWSkills_ResurrectionPos or ply:GetPos()
        
        timer.Simple(0.5, function()
            if IsValid(ply) then
                ply:Spawn()
                ply:SetPos(respawnPos)
                ply:SetHealth(50)
                ply:SetArmor(0)
                
                -- Effet de résurrection
                local effectdata = EffectData()
                effectdata:SetOrigin(ply:GetPos())
                util.Effect("propspawn", effectdata)
                
                ply:EmitSound("ambient/energy/whiteflash.wav")
            end
        end)
    end
end)

-- Reset cooldowns à la mort
hook.Add("PlayerDeath", "BWSkills:ResetOnDeath", function(ply)
    local data = BWSkills:GetPlayerData(ply)
    if data then
        -- Désactiver les effets actifs
        for slot = 1, 2 do
            if data.activeEffects[slot] then
                local skill = BWSkills.Skills[data.activeEffects[slot].skillId]
                if skill then
                    skill.onDeactivate(ply)
                end
                timer.Remove("BWSkills:Deactivate:" .. ply:SteamID64() .. ":" .. slot)
                data.activeEffects[slot] = nil
            end
        end
    end
end)

-- Annuler un roll en attente (quand le joueur ferme le menu de sélection)
net.Receive("BWSkills:CancelRoll", function(len, ply)
    local steamid = ply:SteamID64()
    if BWSkills.PendingRolls[steamid] then
        BWSkills.PendingRolls[steamid] = nil
        timer.Remove("BWSkills:PendingExpire:" .. steamid)
        print("[BW Skills] " .. ply:Nick() .. " cancelled pending roll")
    end
end)

-- Nettoyer les rolls en attente à la déconnexion
hook.Add("PlayerDisconnected", "BWSkills:CleanupPendingRolls", function(ply)
    local steamid = ply:SteamID64()
    if BWSkills.PendingRolls[steamid] then
        BWSkills.PendingRolls[steamid] = nil
        timer.Remove("BWSkills:PendingExpire:" .. steamid)
    end
end)

-- Commande pour ouvrir le menu
hook.Add("PlayerSay", "BWSkills:ChatCommand", function(ply, text)
    local cmd = string.lower(text)
    if cmd == "/skills" or cmd == "!skills" then
        net.Start("BWSkills:OpenMenu")
        net.Send(ply)
        return ""
    end
end)
