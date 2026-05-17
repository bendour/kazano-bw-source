--[[
    Définition des Compétences (Shared)
]]

BWSkills.Skills = {}

-- Fonction pour enregistrer une compétence
function BWSkills:RegisterSkill(id, data)
    self.Skills[id] = {
        id = id,
        name = data.name or "Unknown",
        description = data.description or "",
        icon = data.icon or "icon16/star.png",
        rarity = data.rarity or 1,
        cooldown = data.cooldown or 10,
        duration = data.duration or 0,
        onActivate = data.onActivate or function() end,
        onDeactivate = data.onDeactivate or function() end,
        canUse = data.canUse or function() return true end
    }
end

-- Fonction pour obtenir une compétence aléatoire par rareté
function BWSkills:GetRandomSkillByRarity(rarity)
    local skills = {}
    for id, skill in pairs(self.Skills) do
        if skill.rarity == rarity then
            table.insert(skills, id)
        end
    end
    if #skills > 0 then
        return skills[math.random(#skills)]
    end
    return nil
end

-- Fonction pour roll une rareté
function BWSkills:RollRarity()
    local roll = math.random(1, 100)
    local cumulative = 0
    
    for rarity, chance in ipairs(self.RarityChances) do
        cumulative = cumulative + chance
        if roll <= cumulative then
            return rarity
        end
    end
    
    return 1 -- Commun par défaut
end

-- Fonction pour roll une compétence
function BWSkills:RollSkill()
    local rarity = self:RollRarity()
    local skillId = self:GetRandomSkillByRarity(rarity)
    
    -- Si aucune compétence de cette rareté, chercher dans une rareté inférieure
    while not skillId and rarity > 0 do
        rarity = rarity - 1
        skillId = self:GetRandomSkillByRarity(rarity)
    end
    
    return skillId
end

--[[
    ===============================
    DÉFINITION DES COMPÉTENCES
    ===============================
]]

-- DASH (Commun)
BWSkills:RegisterSkill("dash", {
    name = "Dash",
    description = "Effectue un dash rapide dans la direction de déplacement.",
    icon = "icon16/arrow_right.png",
    rarity = 1,
    cooldown = 5,
    duration = 0,
    onActivate = function(ply)
        if SERVER then
            local vel = ply:GetVelocity()
            local dir = ply:GetAimVector()
            dir.z = 0
            dir:Normalize()
            
            -- Si le joueur bouge, utiliser sa direction de mouvement
            local moveDir = Vector(0, 0, 0)
            if ply:KeyDown(IN_FORWARD) then moveDir = moveDir + ply:GetForward() end
            if ply:KeyDown(IN_BACK) then moveDir = moveDir - ply:GetForward() end
            if ply:KeyDown(IN_MOVERIGHT) then moveDir = moveDir + ply:GetRight() end
            if ply:KeyDown(IN_MOVELEFT) then moveDir = moveDir - ply:GetRight() end
            
            if moveDir:Length() > 0 then
                moveDir:Normalize()
                dir = moveDir
            end
            
            dir.z = 0.1
            ply:SetVelocity(dir * 800)
            
            -- Effet visuel
            local effectdata = EffectData()
            effectdata:SetOrigin(ply:GetPos())
            effectdata:SetEntity(ply)
            util.Effect("propspawn", effectdata)
        end
    end
})

-- DOUBLE SAUT (Commun)
BWSkills:RegisterSkill("double_jump", {
    name = "Double Saut",
    description = "Permet d'effectuer un second saut en l'air.",
    icon = "icon16/arrow_up.png",
    rarity = 1,
    cooldown = 3,
    duration = 0,
    canUse = function(ply)
        return not ply:OnGround()
    end,
    onActivate = function(ply)
        if SERVER then
            local vel = ply:GetVelocity()
            vel.z = 350
            ply:SetVelocity(vel - ply:GetVelocity() + Vector(0, 0, 350))
            
            -- Effet
            local effectdata = EffectData()
            effectdata:SetOrigin(ply:GetPos())
            util.Effect("propspawn", effectdata)
        end
    end
})

-- HEAL (Rare)
BWSkills:RegisterSkill("heal", {
    name = "Régénération",
    description = "Restaure 25 points de vie instantanément.",
    icon = "icon16/heart.png",
    rarity = 2,
    cooldown = 30,
    duration = 0,
    onActivate = function(ply)
        if SERVER then
            local newHealth = math.min(ply:Health() + 25, ply:GetMaxHealth())
            ply:SetHealth(newHealth)
            
            -- Effet
            local effectdata = EffectData()
            effectdata:SetOrigin(ply:GetPos() + Vector(0, 0, 40))
            effectdata:SetScale(1)
            util.Effect("bloodspray", effectdata)
        end
    end
})

-- SPEED BOOST (Rare)
BWSkills:RegisterSkill("speed_boost", {
    name = "Sprint",
    description = "Augmente la vitesse de 50% pendant 5 secondes.",
    icon = "icon16/lightning.png",
    rarity = 2,
    cooldown = 20,
    duration = 5,
    onActivate = function(ply)
        if SERVER then
            local baseSpeed = ply:GetWalkSpeed()
            ply:SetWalkSpeed(baseSpeed * 1.5)
            ply:SetRunSpeed(ply:GetRunSpeed() * 1.5)
            ply.BWSkills_OldWalkSpeed = baseSpeed
            ply.BWSkills_OldRunSpeed = ply:GetRunSpeed() / 1.5
        end
    end,
    onDeactivate = function(ply)
        if SERVER then
            if ply.BWSkills_OldWalkSpeed then
                ply:SetWalkSpeed(ply.BWSkills_OldWalkSpeed)
                ply:SetRunSpeed(ply.BWSkills_OldRunSpeed)
            end
        end
    end
})

-- INVISIBILITÉ (Épique)
BWSkills:RegisterSkill("invisibility", {
    name = "Invisibilité",
    description = "Devient invisible pendant 4 secondes.",
    icon = "icon16/eye.png",
    rarity = 3,
    cooldown = 45,
    duration = 4,
    onActivate = function(ply)
        if SERVER then
            ply:SetRenderMode(RENDERMODE_TRANSALPHA)
            ply:SetColor(Color(255, 255, 255, 20))
            ply:DrawShadow(false)
        end
    end,
    onDeactivate = function(ply)
        if SERVER then
            ply:SetRenderMode(RENDERMODE_NORMAL)
            ply:SetColor(Color(255, 255, 255, 255))
            ply:DrawShadow(true)
        end
    end
})

-- BOUCLIER (Épique)
BWSkills:RegisterSkill("shield", {
    name = "Bouclier",
    description = "Réduit les dégâts de 75% pendant 3 secondes.",
    icon = "icon16/shield.png",
    rarity = 3,
    cooldown = 40,
    duration = 3,
    onActivate = function(ply)
        if SERVER then
            ply.BWSkills_ShieldActive = true
        end
    end,
    onDeactivate = function(ply)
        if SERVER then
            ply.BWSkills_ShieldActive = false
        end
    end
})

-- TÉLÉPORTATION (Légendaire)
BWSkills:RegisterSkill("teleport", {
    name = "Téléportation",
    description = "Se téléporte à l'endroit visé (max 500 unités).",
    icon = "icon16/arrow_switch.png",
    rarity = 4,
    cooldown = 60,
    duration = 0,
    onActivate = function(ply)
        if SERVER then
            local trace = ply:GetEyeTrace()
            local targetPos = trace.HitPos
            local dist = ply:GetPos():Distance(targetPos)
            
            if dist > 500 then
                -- Limiter à 500 unités
                local dir = (targetPos - ply:GetPos()):GetNormalized()
                targetPos = ply:GetPos() + dir * 500
            end
            
            -- Trouver une position valide
            local tr = util.TraceHull({
                start = targetPos + Vector(0, 0, 50),
                endpos = targetPos,
                mins = ply:OBBMins(),
                maxs = ply:OBBMaxs(),
                filter = ply
            })
            
            if not tr.Hit then
                ply:SetPos(targetPos + Vector(0, 0, 10))
            else
                ply:SetPos(tr.HitPos + Vector(0, 0, 10))
            end
            
            -- Effet
            local effectdata = EffectData()
            effectdata:SetOrigin(ply:GetPos())
            util.Effect("propspawn", effectdata)
        end
    end
})

-- EXPLOSION (Légendaire)
BWSkills:RegisterSkill("explosion", {
    name = "Nova",
    description = "Repousse tous les ennemis autour de vous et inflige 30 dégâts.",
    icon = "icon16/bomb.png",
    rarity = 4,
    cooldown = 50,
    duration = 0,
    onActivate = function(ply)
        if SERVER then
            local pos = ply:GetPos() + Vector(0, 0, 40)
            local radius = 300
            
            for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
                if IsValid(ent) and ent:IsPlayer() and ent ~= ply then
                    -- Vérifier si c'est un ennemi (pas dans la même faction)
                    local canDamage = true
                    if BaseWars and BaseWars.Factions then
                        local myFaction = BaseWars.Factions:GetPlayerFaction(ply)
                        local theirFaction = BaseWars.Factions:GetPlayerFaction(ent)
                        if myFaction and theirFaction and myFaction.id == theirFaction.id then
                            canDamage = false
                        end
                    end
                    
                    if canDamage then
                        -- Repousser
                        local dir = (ent:GetPos() - pos):GetNormalized()
                        dir.z = 0.5
                        ent:SetVelocity(dir * 600)
                        
                        -- Dégâts
                        local dmg = DamageInfo()
                        dmg:SetDamage(30)
                        dmg:SetAttacker(ply)
                        dmg:SetInflictor(ply)
                        dmg:SetDamageType(DMG_BLAST)
                        ent:TakeDamageInfo(dmg)
                    end
                end
            end
            
            -- Effet
            local effectdata = EffectData()
            effectdata:SetOrigin(pos)
            effectdata:SetScale(2)
            util.Effect("Explosion", effectdata)
        end
    end
})

--[[
    ===============================
    NOUVELLES COMPÉTENCES
    ===============================
]]

-- GLISSADE (Commun)
BWSkills:RegisterSkill("slide", {
    name = "Glissade",
    description = "Effectue une glissade au sol, passant sous les obstacles.",
    icon = "icon16/arrow_down.png",
    rarity = 1,
    cooldown = 4,
    duration = 0.8,
    canUse = function(ply)
        return ply:OnGround() and not ply:Crouching()
    end,
    onActivate = function(ply)
        if SERVER then
            local dir = ply:GetForward()
            dir.z = 0
            dir:Normalize()
            
            ply:SetVelocity(dir * 500)
            ply:SetCrouchSpeedScale(2)
            ply:ConCommand("+duck")
            ply.BWSkills_Sliding = true
        end
    end,
    onDeactivate = function(ply)
        if SERVER then
            ply:SetCrouchSpeedScale(0.3)
            ply:ConCommand("-duck")
            ply.BWSkills_Sliding = false
        end
    end
})

-- RECHARGEMENT RAPIDE (Commun)
BWSkills:RegisterSkill("quick_reload", {
    name = "Rechargement Éclair",
    description = "Recharge instantanément l'arme actuelle.",
    icon = "icon16/arrow_refresh.png",
    rarity = 1,
    cooldown = 15,
    duration = 0,
    onActivate = function(ply)
        if SERVER then
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) then
                local maxClip = wep:GetMaxClip1()
                if maxClip > 0 then
                    wep:SetClip1(maxClip)
                    ply:EmitSound("weapons/smg1/smg1_reload.wav")
                end
            end
        end
    end
})

-- SAUT AMORTI (Commun)
BWSkills:RegisterSkill("soft_landing", {
    name = "Atterrissage Félin",
    description = "Annule les dégâts de chute pour les 5 prochaines secondes.",
    icon = "icon16/arrow_down.png",
    rarity = 1,
    cooldown = 12,
    duration = 5,
    onActivate = function(ply)
        if SERVER then
            ply.BWSkills_NoFallDamage = true
        end
    end,
    onDeactivate = function(ply)
        if SERVER then
            ply.BWSkills_NoFallDamage = false
        end
    end
})

-- VAMPIRE (Rare)
BWSkills:RegisterSkill("vampire", {
    name = "Vampire",
    description = "Vos attaques volent 15% des dégâts en vie pendant 8 secondes.",
    icon = "icon16/heart_delete.png",
    rarity = 2,
    cooldown = 35,
    duration = 8,
    onActivate = function(ply)
        if SERVER then
            ply.BWSkills_Vampire = true
        end
    end,
    onDeactivate = function(ply)
        if SERVER then
            ply.BWSkills_Vampire = false
        end
    end
})

-- ARMURE TEMPORAIRE (Rare)
BWSkills:RegisterSkill("temp_armor", {
    name = "Armure d'Urgence",
    description = "Gagne 50 points d'armure temporaires.",
    icon = "icon16/shield.png",
    rarity = 2,
    cooldown = 25,
    duration = 0,
    onActivate = function(ply)
        if SERVER then
            local newArmor = math.min(ply:Armor() + 50, 100)
            ply:SetArmor(newArmor)
            ply:EmitSound("items/battery_pickup.wav")
        end
    end
})

-- GRENADE FUMIGÈNE (Rare)
BWSkills:RegisterSkill("smoke_bomb", {
    name = "Bombe Fumigène",
    description = "Crée un nuage de fumée qui bloque la vision pendant 6 secondes.",
    icon = "icon16/weather_clouds.png",
    rarity = 2,
    cooldown = 30,
    duration = 0,
    onActivate = function(ply)
        if SERVER then
            local pos = ply:GetPos()
            
            -- Créer plusieurs particules de fumée
            for i = 1, 5 do
                timer.Simple(i * 0.1, function()
                    if IsValid(ply) then
                        local smokePos = pos + Vector(math.random(-50, 50), math.random(-50, 50), math.random(0, 30))
                        local effectdata = EffectData()
                        effectdata:SetOrigin(smokePos)
                        effectdata:SetScale(3)
                        util.Effect("explosion", effectdata)
                    end
                end)
            end
            
            -- Créer une entité de fumée persistante
            local smoke = ents.Create("env_smokestack")
            smoke:SetPos(pos)
            smoke:SetKeyValue("InitialState", "1")
            smoke:SetKeyValue("BaseSpread", "100")
            smoke:SetKeyValue("SpreadSpeed", "50")
            smoke:SetKeyValue("Speed", "30")
            smoke:SetKeyValue("StartSize", "200")
            smoke:SetKeyValue("EndSize", "300")
            smoke:SetKeyValue("Rate", "50")
            smoke:SetKeyValue("JetLength", "100")
            smoke:SetKeyValue("rendercolor", "100 100 100")
            smoke:SetKeyValue("renderamt", "200")
            smoke:Spawn()
            smoke:Activate()
            smoke:Fire("TurnOn")
            
            timer.Simple(6, function()
                if IsValid(smoke) then
                    smoke:Fire("TurnOff")
                    timer.Simple(2, function()
                        if IsValid(smoke) then
                            smoke:Remove()
                        end
                    end)
                end
            end)
        end
    end
})

-- VISION THERMIQUE (Épique)
BWSkills:RegisterSkill("thermal_vision", {
    name = "Vision Thermique",
    description = "Voir les joueurs à travers les murs pendant 8 secondes.",
    icon = "icon16/eye.png",
    rarity = 3,
    cooldown = 50,
    duration = 8,
    onActivate = function(ply)
        if SERVER then
            ply.BWSkills_ThermalVision = true
            
            -- Envoyer à tous les clients pour le rendu
            net.Start("BWSkills:ThermalVision")
            net.WriteEntity(ply)
            net.WriteBool(true)
            net.Send(ply)
        end
    end,
    onDeactivate = function(ply)
        if SERVER then
            ply.BWSkills_ThermalVision = false
            
            net.Start("BWSkills:ThermalVision")
            net.WriteEntity(ply)
            net.WriteBool(false)
            net.Send(ply)
        end
    end
})

-- RAGE (Épique)
BWSkills:RegisterSkill("rage", {
    name = "Rage",
    description = "Augmente les dégâts de 40% mais réduit l'armure de 50% pendant 6 secondes.",
    icon = "icon16/fire.png",
    rarity = 3,
    cooldown = 40,
    duration = 6,
    onActivate = function(ply)
        if SERVER then
            ply.BWSkills_RageActive = true
            ply.BWSkills_OldArmor = ply:Armor()
            ply:SetArmor(math.floor(ply:Armor() * 0.5))
            
            -- Effet visuel rouge
            ply:SetColor(Color(255, 100, 100, 255))
        end
    end,
    onDeactivate = function(ply)
        if SERVER then
            ply.BWSkills_RageActive = false
            ply:SetColor(Color(255, 255, 255, 255))
        end
    end
})

-- ÉCHANGE (Épique)
BWSkills:RegisterSkill("swap", {
    name = "Échange",
    description = "Échange votre position avec le joueur visé (max 400 unités).",
    icon = "icon16/arrow_switch.png",
    rarity = 3,
    cooldown = 45,
    duration = 0,
    onActivate = function(ply)
        if SERVER then
            local trace = ply:GetEyeTrace()
            local target = trace.Entity
            
            if IsValid(target) and target:IsPlayer() then
                local dist = ply:GetPos():Distance(target:GetPos())
                
                if dist <= 400 then
                    local myPos = ply:GetPos()
                    local theirPos = target:GetPos()
                    
                    ply:SetPos(theirPos)
                    target:SetPos(myPos)
                    
                    -- Effets
                    local effectdata = EffectData()
                    effectdata:SetOrigin(myPos)
                    util.Effect("propspawn", effectdata)
                    
                    effectdata:SetOrigin(theirPos)
                    util.Effect("propspawn", effectdata)
                    
                    ply:EmitSound("ambient/machines/teleport1.wav")
                end
            end
        end
    end
})

-- IMMORTALITÉ (Légendaire)
BWSkills:RegisterSkill("immortality", {
    name = "Immortalité",
    description = "Devient invincible pendant 2.5 secondes.",
    icon = "icon16/star.png",
    rarity = 4,
    cooldown = 90,
    duration = 2.5,
    onActivate = function(ply)
        if SERVER then
            ply.BWSkills_Immortal = true
            ply:GodEnable()
            
            -- Effet doré
            ply:SetColor(Color(255, 215, 0, 255))
            ply:SetRenderMode(RENDERMODE_TRANSALPHA)
        end
    end,
    onDeactivate = function(ply)
        if SERVER then
            ply.BWSkills_Immortal = false
            ply:GodDisable()
            
            ply:SetColor(Color(255, 255, 255, 255))
            ply:SetRenderMode(RENDERMODE_NORMAL)
        end
    end
})

-- FRAPPE SISMIQUE (Légendaire)
BWSkills:RegisterSkill("seismic_slam", {
    name = "Frappe Sismique",
    description = "Saute en l'air puis frappe le sol, étourdissant les ennemis proches.",
    icon = "icon16/arrow_down.png",
    rarity = 4,
    cooldown = 55,
    duration = 0,
    canUse = function(ply)
        return ply:OnGround()
    end,
    onActivate = function(ply)
        if SERVER then
            -- Propulser en l'air
            ply:SetVelocity(Vector(0, 0, 600))
            
            -- Attendre la retombée
            timer.Simple(0.8, function()
                if IsValid(ply) then
                    -- Slam vers le bas
                    ply:SetVelocity(Vector(0, 0, -1500))
                    
                    -- Détecter l'impact au sol
                    timer.Create("BWSkills_SeismicCheck_" .. ply:SteamID64(), 0.05, 40, function()
                        if not IsValid(ply) then 
                            timer.Remove("BWSkills_SeismicCheck_" .. ply:SteamID64())
                            return 
                        end
                        
                        if ply:OnGround() then
                            timer.Remove("BWSkills_SeismicCheck_" .. ply:SteamID64())
                            
                            local pos = ply:GetPos()
                            local radius = 350
                            
                            -- Effet d'impact
                            util.ScreenShake(pos, 10, 5, 1, radius * 2)
                            
                            local effectdata = EffectData()
                            effectdata:SetOrigin(pos)
                            effectdata:SetScale(3)
                            util.Effect("Explosion", effectdata)
                            
                            -- Affecter les ennemis
                            for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
                                if IsValid(ent) and ent:IsPlayer() and ent ~= ply then
                                    -- Dégâts + stun
                                    local dmg = DamageInfo()
                                    dmg:SetDamage(40)
                                    dmg:SetAttacker(ply)
                                    dmg:SetInflictor(ply)
                                    dmg:SetDamageType(DMG_BLAST)
                                    ent:TakeDamageInfo(dmg)
                                    
                                    -- Stun (ralentissement)
                                    local oldWalk = ent:GetWalkSpeed()
                                    local oldRun = ent:GetRunSpeed()
                                    ent:SetWalkSpeed(oldWalk * 0.3)
                                    ent:SetRunSpeed(oldRun * 0.3)
                                    
                                    timer.Simple(2, function()
                                        if IsValid(ent) then
                                            ent:SetWalkSpeed(oldWalk)
                                            ent:SetRunSpeed(oldRun)
                                        end
                                    end)
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end
})

-- CLONE (Légendaire)
BWSkills:RegisterSkill("clone", {
    name = "Clone Holographique",
    description = "Crée un clone de vous-même et vous rend complètement invisible pendant 4 secondes.",
    icon = "icon16/user.png",
    rarity = 4,
    cooldown = 60,
    duration = 4,
    onActivate = function(ply)
        if SERVER then
            -- Créer le clone avec l'apparence exacte du joueur
            local clone = ents.Create("prop_physics")
            clone:SetModel(ply:GetModel())
            clone:SetPos(ply:GetPos())
            clone:SetAngles(ply:GetAngles())
            clone:Spawn()
            clone:SetSolid(SOLID_NONE)
            clone:SetMoveType(MOVETYPE_NONE)
            clone:SetSkin(ply:GetSkin())
            
            -- Copier les bodygroups du joueur
            for i = 0, ply:GetNumBodyGroups() - 1 do
                clone:SetBodygroup(i, ply:GetBodygroup(i))
            end
            
            -- Couleur normale (pas bleuté, pour tromper les ennemis)
            clone:SetColor(Color(255, 255, 255, 255))
            clone:SetRenderMode(RENDERMODE_NORMAL)
            
            -- Le clone "marche" vers l'avant
            local dir = ply:GetForward()
            
            timer.Create("BWSkills_CloneMove_" .. ply:SteamID64(), 0.1, 50, function()
                if IsValid(clone) then
                    local newPos = clone:GetPos() + dir * 5
                    clone:SetPos(newPos)
                end
            end)
            
            -- Rendre le joueur invisible
            ply:SetColor(Color(255, 255, 255, 0))
            ply:SetRenderMode(RENDERMODE_TRANSALPHA)
            ply:SetNoDraw(true)
            ply:DrawShadow(false)
            
            -- Cacher aussi l'arme
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) then
                wep:SetNoDraw(true)
            end
            
            -- Marquer le joueur comme invisible pour d'autres systèmes
            ply.BWSkillsInvisible = true
            
            -- Retirer l'invisibilité après 4 secondes
            timer.Simple(4, function()
                if IsValid(ply) then
                    ply:SetColor(Color(255, 255, 255, 255))
                    ply:SetRenderMode(RENDERMODE_NORMAL)
                    ply:SetNoDraw(false)
                    ply:DrawShadow(true)
                    ply.BWSkillsInvisible = false
                    
                    -- Rendre l'arme visible à nouveau
                    local currentWep = ply:GetActiveWeapon()
                    if IsValid(currentWep) then
                        currentWep:SetNoDraw(false)
                    end
                    
                    -- Effet de réapparition sur le joueur
                    local effectdata = EffectData()
                    effectdata:SetOrigin(ply:GetPos())
                    util.Effect("propspawn", effectdata)
                end
            end)
            
            -- Supprimer le clone après 5 secondes
            timer.Simple(5, function()
                if IsValid(clone) then
                    -- Effet de disparition
                    local effectdata = EffectData()
                    effectdata:SetOrigin(clone:GetPos())
                    util.Effect("propspawn", effectdata)
                    
                    clone:Remove()
                end
                timer.Remove("BWSkills_CloneMove_" .. ply:SteamID64())
            end)
        end
    end,
    onDeactivate = function(ply)
        if SERVER then
            -- S'assurer que le joueur redevient visible si la compétence est interrompue
            if IsValid(ply) then
                ply:SetColor(Color(255, 255, 255, 255))
                ply:SetRenderMode(RENDERMODE_NORMAL)
                ply:SetNoDraw(false)
                ply:DrawShadow(true)
                ply.BWSkillsInvisible = false
                
                local wep = ply:GetActiveWeapon()
                if IsValid(wep) then
                    wep:SetNoDraw(false)
                end
            end
        end
    end
})

--[[
    ===============================
    COMPÉTENCES SUPPLÉMENTAIRES
    ===============================
]]

-- HOOK DE GRAPPIN (Commun)
BWSkills:RegisterSkill("grapple", {
    name = "Grappin",
    description = "Lance un grappin qui vous tire vers le point d'impact.",
    icon = "icon16/anchor.png",
    rarity = 1,
    cooldown = 8,
    duration = 0,
    onActivate = function(ply)
        if SERVER then
            local trace = ply:GetEyeTrace()
            if trace.Hit then
                local dir = (trace.HitPos - ply:GetPos()):GetNormalized()
                local dist = ply:GetPos():Distance(trace.HitPos)
                local speed = math.Clamp(dist * 2, 400, 1200)
                
                ply:SetVelocity(dir * speed)
                ply:EmitSound("weapons/crossbow/bolt_fly4.wav")
            end
        end
    end
})

-- REBOND (Commun)
BWSkills:RegisterSkill("bounce", {
    name = "Rebond",
    description = "Le prochain impact au sol vous propulse vers le haut.",
    icon = "icon16/arrow_up.png",
    rarity = 1,
    cooldown = 6,
    duration = 5,
    onActivate = function(ply)
        if SERVER then
            ply.BWSkills_BounceReady = true
        end
    end,
    onDeactivate = function(ply)
        if SERVER then
            ply.BWSkills_BounceReady = false
        end
    end
})

-- CAMOUFLAGE (Commun)
BWSkills:RegisterSkill("camouflage", {
    name = "Camouflage",
    description = "Réduit votre visibilité de 60% pendant 4 secondes.",
    icon = "icon16/contrast.png",
    rarity = 1,
    cooldown = 12,
    duration = 4,
    onActivate = function(ply)
        if SERVER then
            ply:SetRenderMode(RENDERMODE_TRANSALPHA)
            ply:SetColor(Color(255, 255, 255, 100))
        end
    end,
    onDeactivate = function(ply)
        if SERVER then
            ply:SetRenderMode(RENDERMODE_NORMAL)
            ply:SetColor(Color(255, 255, 255, 255))
        end
    end
})

-- ADRÉNALINE (Rare)
BWSkills:RegisterSkill("adrenaline", {
    name = "Adrénaline",
    description = "Restaure 15 HP et augmente la vitesse de 30% pendant 4 secondes.",
    icon = "icon16/lightning_go.png",
    rarity = 2,
    cooldown = 28,
    duration = 4,
    onActivate = function(ply)
        if SERVER then
            -- Heal
            local newHealth = math.min(ply:Health() + 15, ply:GetMaxHealth())
            ply:SetHealth(newHealth)
            
            -- Speed boost
            ply.BWSkills_OldWalkSpeed2 = ply:GetWalkSpeed()
            ply.BWSkills_OldRunSpeed2 = ply:GetRunSpeed()
            ply:SetWalkSpeed(ply:GetWalkSpeed() * 1.3)
            ply:SetRunSpeed(ply:GetRunSpeed() * 1.3)
            
            ply:EmitSound("player/heartbeat1.wav")
        end
    end,
    onDeactivate = function(ply)
        if SERVER then
            if ply.BWSkills_OldWalkSpeed2 then
                ply:SetWalkSpeed(ply.BWSkills_OldWalkSpeed2)
                ply:SetRunSpeed(ply.BWSkills_OldRunSpeed2)
            end
        end
    end
})

-- MINE PIÉGÉE (Rare)
BWSkills:RegisterSkill("trap_mine", {
    name = "Mine Piégée",
    description = "Place une mine invisible qui explose au contact ennemi (75 dégâts + dégâts de zone).",
    icon = "icon16/bomb.png",
    rarity = 2,
    cooldown = 35,
    duration = 0,
    onActivate = function(ply)
        if SERVER then
            local pos = ply:GetPos() + Vector(0, 0, 5)
            
            -- Créer une mine invisible
            local mine = ents.Create("prop_physics")
            mine:SetModel("models/props_junk/sawblade001a.mdl")
            mine:SetPos(pos)
            mine:Spawn()
            mine:SetMoveType(MOVETYPE_NONE)
            mine:SetSolid(SOLID_NONE)
            mine:SetRenderMode(RENDERMODE_TRANSALPHA)
            mine:SetColor(Color(255, 255, 255, 30))
            mine:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            mine.BWSkills_MineOwner = ply
            
            -- Vérifier les ennemis proches
            timer.Create("BWSkills_Mine_" .. mine:EntIndex(), 0.2, 150, function()
                if not IsValid(mine) then return end
                
                for _, ent in ipairs(ents.FindInSphere(mine:GetPos(), 80)) do
                    if IsValid(ent) and ent:IsPlayer() and ent ~= ply then
                        local minePos = mine:GetPos()
                        
                        -- Exploser avec effet
                        local effectdata = EffectData()
                        effectdata:SetOrigin(minePos)
                        effectdata:SetScale(3)
                        util.Effect("Explosion", effectdata)
                        
                        -- Son d'explosion
                        sound.Play("weapons/explode3.wav", minePos, 100, 100, 1)
                        
                        -- Dégâts de zone à tous les joueurs proches (sauf le propriétaire)
                        local blastRadius = 150
                        for _, target in ipairs(ents.FindInSphere(minePos, blastRadius)) do
                            if IsValid(target) and target:IsPlayer() and target ~= ply then
                                local dist = target:GetPos():Distance(minePos)
                                local falloff = 1 - (dist / blastRadius) * 0.5 -- 100% à 50% selon distance
                                local damage = math.floor(75 * falloff)
                                
                                local dmg = DamageInfo()
                                dmg:SetDamage(damage)
                                dmg:SetAttacker(IsValid(ply) and ply or target)
                                dmg:SetInflictor(mine)
                                dmg:SetDamageType(DMG_BLAST)
                                dmg:SetDamagePosition(minePos)
                                target:TakeDamageInfo(dmg)
                                
                                -- Propulser légèrement les victimes
                                local pushDir = (target:GetPos() - minePos):GetNormalized()
                                target:SetVelocity(pushDir * 300 + Vector(0, 0, 200))
                            end
                        end
                        
                        mine:Remove()
                        timer.Remove("BWSkills_Mine_" .. mine:EntIndex())
                        return
                    end
                end
            end)
            
            -- Auto-destruction après 30 secondes
            timer.Simple(30, function()
                if IsValid(mine) then
                    mine:Remove()
                end
            end)
        end
    end
})

-- DRAIN D'ÉNERGIE (Rare)
BWSkills:RegisterSkill("energy_drain", {
    name = "Drain d'Énergie",
    description = "Vole 20 HP à l'ennemi le plus proche dans un rayon de 150 unités.",
    icon = "icon16/arrow_rotate_clockwise.png",
    rarity = 2,
    cooldown = 22,
    duration = 0,
    onActivate = function(ply)
        if SERVER then
            local pos = ply:GetPos()
            local closest = nil
            local closestDist = 150
            
            for _, ent in ipairs(ents.FindInSphere(pos, 150)) do
                if IsValid(ent) and ent:IsPlayer() and ent ~= ply and ent:Alive() then
                    local dist = pos:Distance(ent:GetPos())
                    if dist < closestDist then
                        closest = ent
                        closestDist = dist
                    end
                end
            end
            
            if IsValid(closest) then
                -- Voler la vie
                local dmg = DamageInfo()
                dmg:SetDamage(20)
                dmg:SetAttacker(ply)
                dmg:SetInflictor(ply)
                dmg:SetDamageType(DMG_GENERIC)
                closest:TakeDamageInfo(dmg)
                
                local newHealth = math.min(ply:Health() + 20, ply:GetMaxHealth())
                ply:SetHealth(newHealth)
                
                ply:EmitSound("ambient/energy/zap1.wav")
            end
        end
    end
})

-- CHAMP DE FORCE (Épique)
BWSkills:RegisterSkill("force_field", {
    name = "Champ de Force",
    description = "Crée une barrière qui bloque les projectiles et joueurs pendant 3 secondes.",
    icon = "icon16/shield.png",
    rarity = 3,
    cooldown = 45,
    duration = 3,
    onActivate = function(ply)
        if SERVER then
            local pos = ply:GetPos() + ply:GetForward() * 80 + Vector(0, 0, 50)
            local ang = ply:GetAngles()
            
            -- Créer le bouclier principal (solide)
            local shield = ents.Create("prop_physics")
            shield:SetModel("models/hunter/plates/plate2x2.mdl")
            shield:SetPos(pos)
            shield:SetAngles(Angle(90, ang.y, 0))
            shield:Spawn()
            shield:SetMoveType(MOVETYPE_NONE)
            shield:SetSolid(SOLID_VPHYSICS)
            shield:SetRenderMode(RENDERMODE_TRANSALPHA)
            shield:SetColor(Color(50, 150, 255, 180))
            shield:SetMaterial("models/props_combine/portalball001_sheet")
            shield:SetCollisionGroup(COLLISION_GROUP_NONE) -- Collision normale
            
            local phys = shield:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false)
                phys:SetMass(50000) -- Très lourd pour ne pas bouger
            end
            
            -- Rendre le bouclier invincible
            shield:SetHealth(999999)
            shield:SetMaxHealth(999999)
            
            -- Empêcher la destruction du bouclier
            shield.CanTool = function() return false end
            shield.PhysgunDisabled = true
            
            ply.BWSkills_ForceField = shield
            
            -- Effet visuel périodique
            timer.Create("BWSkills_ForceFieldFX_" .. ply:SteamID64(), 0.3, 10, function()
                if IsValid(shield) then
                    local effectdata = EffectData()
                    effectdata:SetOrigin(shield:GetPos())
                    effectdata:SetScale(1)
                    util.Effect("cball_bounce", effectdata)
                end
            end)
            
            timer.Simple(3, function()
                if IsValid(shield) then
                    -- Effet de disparition
                    local effectdata = EffectData()
                    effectdata:SetOrigin(shield:GetPos())
                    util.Effect("cball_explode", effectdata)
                    
                    shield:Remove()
                end
                timer.Remove("BWSkills_ForceFieldFX_" .. ply:SteamID64())
            end)
        end
    end,
    onDeactivate = function(ply)
        if SERVER then
            if IsValid(ply.BWSkills_ForceField) then
                ply.BWSkills_ForceField:Remove()
            end
            timer.Remove("BWSkills_ForceFieldFX_" .. ply:SteamID64())
        end
    end
})

-- MARQUE DE MORT (Épique)
BWSkills:RegisterSkill("death_mark", {
    name = "Marque de Mort",
    description = "Marque l'ennemi visé, lui infligeant 50% de dégâts supplémentaires pendant 6 secondes.",
    icon = "icon16/cross.png",
    rarity = 3,
    cooldown = 40,
    duration = 0,
    onActivate = function(ply)
        if SERVER then
            local trace = ply:GetEyeTrace()
            local target = trace.Entity
            
            if IsValid(target) and target:IsPlayer() and target:Alive() then
                target.BWSkills_DeathMarked = true
                target.BWSkills_DeathMarkedBy = ply
                target:SetColor(Color(255, 100, 100, 255))
                
                timer.Simple(6, function()
                    if IsValid(target) then
                        target.BWSkills_DeathMarked = false
                        target.BWSkills_DeathMarkedBy = nil
                        target:SetColor(Color(255, 255, 255, 255))
                    end
                end)
                
                ply:EmitSound("buttons/blip1.wav")
            end
        end
    end
})

-- PHASAGE (Épique)
BWSkills:RegisterSkill("phase", {
    name = "Phasage",
    description = "Traverse les entités et joueurs pendant 2 secondes.",
    icon = "icon16/shape_square.png",
    rarity = 3,
    cooldown = 35,
    duration = 2,
    onActivate = function(ply)
        if SERVER then
            -- Sauvegarder l'état original
            ply.BWSkills_OriginalCollisionGroup = ply:GetCollisionGroup()
            
            -- COLLISION_GROUP_WORLD permet de passer à travers tout sauf le monde
            ply:SetCollisionGroup(COLLISION_GROUP_WORLD)
            
            -- Effet visuel fantôme
            ply:SetRenderMode(RENDERMODE_TRANSALPHA)
            ply:SetColor(Color(100, 180, 255, 100))
            
            -- Marquer le joueur comme en phase
            ply.BWSkills_IsPhasing = true
            
            -- Désactiver les dégâts pendant le phasage
            ply:GodEnable()
        end
    end,
    onDeactivate = function(ply)
        if SERVER then
            -- Restaurer les collisions normales
            ply:SetCollisionGroup(ply.BWSkills_OriginalCollisionGroup or COLLISION_GROUP_PLAYER)
            ply:SetRenderMode(RENDERMODE_NORMAL)
            ply:SetColor(Color(255, 255, 255, 255))
            
            ply.BWSkills_IsPhasing = false
            ply.BWSkills_OriginalCollisionGroup = nil
            
            -- Réactiver les dégâts
            ply:GodDisable()
            
            -- Vérifier si le joueur est coincé dans un mur/entité
            local tr = util.TraceHull({
                start = ply:GetPos(),
                endpos = ply:GetPos(),
                mins = ply:OBBMins(),
                maxs = ply:OBBMaxs(),
                filter = ply,
                mask = MASK_PLAYERSOLID
            })
            
            -- Si coincé, essayer de le déplacer
            if tr.StartSolid then
                -- Chercher une position valide autour
                local offsets = {
                    Vector(0, 0, 50),
                    Vector(50, 0, 0),
                    Vector(-50, 0, 0),
                    Vector(0, 50, 0),
                    Vector(0, -50, 0),
                    Vector(0, 0, 100)
                }
                
                for _, offset in ipairs(offsets) do
                    local testPos = ply:GetPos() + offset
                    local testTr = util.TraceHull({
                        start = testPos,
                        endpos = testPos,
                        mins = ply:OBBMins(),
                        maxs = ply:OBBMaxs(),
                        filter = ply,
                        mask = MASK_PLAYERSOLID
                    })
                    
                    if not testTr.StartSolid then
                        ply:SetPos(testPos)
                        break
                    end
                end
            end
        end
    end
})

-- RÉSURRECTION (Légendaire)
BWSkills:RegisterSkill("resurrection", {
    name = "Seconde Chance",
    description = "La prochaine mort dans les 10 secondes vous ressuscite avec 50 HP.",
    icon = "icon16/heart_add.png",
    rarity = 4,
    cooldown = 120,
    duration = 10,
    onActivate = function(ply)
        if SERVER then
            ply.BWSkills_HasResurrection = true
            ply.BWSkills_ResurrectionPos = ply:GetPos()
        end
    end,
    onDeactivate = function(ply)
        if SERVER then
            ply.BWSkills_HasResurrection = false
        end
    end
})

-- FOUDRE (Légendaire)
BWSkills:RegisterSkill("lightning", {
    name = "Foudre Divine",
    description = "Appelle la foudre sur tous les ennemis dans un rayon de 400 unités.",
    icon = "icon16/lightning.png",
    rarity = 4,
    cooldown = 70,
    duration = 0,
    onActivate = function(ply)
        if SERVER then
            local pos = ply:GetPos()
            local targets = {}
            
            for _, ent in ipairs(ents.FindInSphere(pos, 400)) do
                if IsValid(ent) and ent:IsPlayer() and ent ~= ply and ent:Alive() then
                    table.insert(targets, ent)
                end
            end
            
            for i, target in ipairs(targets) do
                timer.Simple(i * 0.2, function()
                    if IsValid(target) and target:Alive() then
                        -- Effet de foudre
                        local effectdata = EffectData()
                        effectdata:SetOrigin(target:GetPos() + Vector(0, 0, 500))
                        effectdata:SetStart(target:GetPos())
                        util.Effect("ToolTracer", effectdata)
                        
                        -- Dégâts
                        local dmg = DamageInfo()
                        dmg:SetDamage(25)
                        dmg:SetAttacker(ply)
                        dmg:SetInflictor(ply)
                        dmg:SetDamageType(DMG_SHOCK)
                        target:TakeDamageInfo(dmg)
                        
                        target:EmitSound("ambient/energy/zap" .. math.random(1, 9) .. ".wav")
                        
                        -- Screen shake
                        util.ScreenShake(target:GetPos(), 5, 5, 0.5, 200)
                    end
                end)
            end
        end
    end
})

-- TEMPS RALENTI (Légendaire)
BWSkills:RegisterSkill("time_slow", {
    name = "Ralentissement Temporel",
    description = "Ralentit tous les ennemis proches de 60% pendant 4 secondes.",
    icon = "icon16/clock.png",
    rarity = 4,
    cooldown = 65,
    duration = 0,
    onActivate = function(ply)
        if SERVER then
            local pos = ply:GetPos()
            local affected = {}
            
            for _, ent in ipairs(ents.FindInSphere(pos, 350)) do
                if IsValid(ent) and ent:IsPlayer() and ent ~= ply and ent:Alive() then
                    -- Sauvegarder les vitesses
                    local data = {
                        ply = ent,
                        walk = ent:GetWalkSpeed(),
                        run = ent:GetRunSpeed()
                    }
                    table.insert(affected, data)
                    
                    -- Ralentir
                    ent:SetWalkSpeed(ent:GetWalkSpeed() * 0.4)
                    ent:SetRunSpeed(ent:GetRunSpeed() * 0.4)
                    ent:SetColor(Color(100, 100, 200, 255))
                end
            end
            
            -- Restaurer après 4 secondes
            timer.Simple(4, function()
                for _, data in ipairs(affected) do
                    if IsValid(data.ply) then
                        data.ply:SetWalkSpeed(data.walk)
                        data.ply:SetRunSpeed(data.run)
                        data.ply:SetColor(Color(255, 255, 255, 255))
                    end
                end
            end)
            
            ply:EmitSound("ambient/machines/machine1_hit1.wav")
        end
    end
})
