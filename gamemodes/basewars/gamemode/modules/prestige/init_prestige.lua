BaseWars:AddDefaultConfig("Prestige", BWCONFIGTYPE_KEYVALUE, {
    Enable = true,
    BaseLevel = 10000,
    MoreLevel = 5000,
    Point = 2,
    ResetPrice = 1e12,
    RemoveProps = false,
}, {
    ["fr"] = {
        name = "Prestige",
        desc = "Information par rapport au module de prestige.",
        extra = {
            Enable = {
                name = "Prestige",
                desc = "Activer/Désactiver le module de prestige.",
            },
            BaseLevel = {
                name = "Niveau.",
                desc = "Le niveau de base pour prestige.",
            },
            MoreLevel = {
                name = "Extra Niveau",
                desc = "La quantitée de niveau qu'il faut en plus par prestige. [BaseLevel + (MoreLevel * PrestigeDuJoueur)]",
            },
            Point = {
                name = "Point Prestige",
                desc = "Combien de point prestige UN SEUL prestige donne.",
            },
            ResetPrice = {
                name = "Réinitialiser Les Point",
                desc = "Le prix pour réinitialiser UN SEUL point prestige. [ResetPrice * PointDuJoueur]",
            },
            RemoveProps = {
                name = "Retirer les props",
                desc = "Retirer tout les props du joueur quand il prestige",
            }
        }
    },
    ["en"] = {
        name = "Prestige",
        desc = "Configuration the prestige module.",
        extra = {
            Enable = {
                name = "Prestige",
                desc = "Enable/Disable the prestige module.",
            },
            BaseLevel = {
                name = "Base Level",
                desc = "The base level for prestige.",
            },
            MoreLevel = {
                name = "Extra Levels",
                desc = "The number of additional levels required per prestige. [BaseLevel + (MoreLevel * Player's Prestige)]",
            },
            Point = {
                name = "Prestige Points",
                desc = "How many prestige points a SINGLE prestige gives.",
            },
            ResetPrice = {
                name = "Reset Points Price",
                desc = "The price to reset a SINGLE prestige point. [ResetPrice * Player's Points]",
            },
            RemoveProps = {
                name = "Remove Props",
                desc = "When a player prestige, remove all their props",
            }
        }
    }
})

BaseWars:AddTranslation("prestige_progression", "fr", "PROGRESSION DU PRESTIGE")
BaseWars:AddTranslation("prestige_duringRaid", "fr", "Vous ne pouvez pas prestige durant un raid")
BaseWars:AddTranslation("prestige_doPrestige", "fr", "Passer prestige %s")
BaseWars:AddTranslation("prestige_prestigePoint", "fr", "Vous avez %s points disponible")
BaseWars:AddTranslation("prestige_tooExpensive", "fr", "Vous ne pouvez pas vous permettre cela")
BaseWars:AddTranslation("prestige_buyPerkNotif", "fr", "Vous avez acheté un niveau de compétence «%s»")
BaseWars:AddTranslation("prestige_playerPrestiged", "fr", "%s est passé prestige %s")
BaseWars:AddTranslation("prestige_buyPerk", "fr", "Acheter pour %s points")
BaseWars:AddTranslation("prestige_maxPerk", "fr", "Niveau de compétence maximum atteint")
BaseWars:AddTranslation("prestige_notEnoughPoint", "fr", "Pas assez de points (%s)")
BaseWars:AddTranslation("prestige_resetPoint", "fr", "Réinitialiser vos points pour %s")
BaseWars:AddTranslation("prestige_level", "fr", "Niveau:")
BaseWars:AddTranslation("prestige_bankInterest", "fr", "Vous avez reçu %s en intérêt de votre banque")
BaseWars:AddTranslation("prestige_bombDefuseSuccess", "fr", "Désamorçage rapide niveau %s réussi !")
BaseWars:AddTranslation("prestige_bombHardeningApplied", "fr", "Bombe renforcée niveau %s appliquée !")
BaseWars:AddTranslation("prestige_price", "fr", "Prix:")
BaseWars:AddTranslation("prestige_perks", "fr", {
    playerHealthName = "Vie",
    playerHealthDesc = "Vous rajoute 10 PV par niveau de compétence.",
    playerArmorName = "Armure",
    playerArmorDesc = "Vous rajoute 10 d'armure par niveau de compétence.",
    playerSpeedName = "Vitesse",
    playerSpeedDesc = "Vous rend 5% plus vite par niveau de compétence.",
    printerUpgradeCostName = "Coût d'amélioration",
    printerUpgradeCostDesc = "Réduit le coût d'amélioration des printer de 5% par niveau de compétence.",
    moreXPName = "XP Augmenté",
    moreXPDesc = "Vous donne 5% plus d'XP par niveau de compétence.",
    playerDamageName = "Dégât Augmenté",
    playerDamageDesc = "Vous ferez 5% plus de dégât par niveau de compétence.",
    morePrinterName = "Plus de printer",
    morePrinterDesc = "Vous donne la possibilité de faire apparaitre un printer de plus par niveau de compétence.",
    moreMoneyDefaultName = "Argent de prestige",
    moreMoneyDefaultDesc = "Vous donne " .. BaseWars.LANG.Currency .. "20,000 par niveau de compétence de plus quand vous passez un prestige.",
    propHealthName = "Vie des props",
    propHealthDesc = "Vos props auront 50 PV de plus par niveau de compétence.",
    bankInterestName = "intérêt sur la banque",
    bankInterestDesc = "Votre banque vous donne 10% de l'argent qu'elle contient toutes les 15 minutes",
    printerSpeedName = "Imprimantes Rapide",
    printerSpeedDesc = "Vos imprimantes produise 0.05 seconde plus vite par niveau de compétence",
    entityHealthName = "Vie des entitées",
    entityHealthDesc = "Vos entitées auront 250 PV de plus par niveau de compétence",
    healthRegenerationName = "Régénération de Vie",
    healthRegenerationDesc = "Régénère 1 PV par seconde par niveau de compétence après 10 secondes sans dégâts. Fonctionne même pendant les raids.",
    armorRegenerationName = "Régénération d'Armure",
    armorRegenerationDesc = "Régénère 1 d'armure par seconde par niveau de compétence après 10 secondes sans dégâts. Fonctionne même pendant les raids.",
    hemorrhageName = "Hémorragie",
    hemorrhageDesc = "25% de chance de provoquer une hémorragie pour 1-2 dégâts par seconde pendant 5 secondes. Ne se cumule pas.",
    slowDownName = "Ralentissement",
    slowDownDesc = "Ralentit les ennemis de 10% par niveau lorsque vous leur infligez des dégâts. Chance : 25% + 5% par niveau. Cooldown : 5 secondes. Durée : 4 secondes.",
    bombDefuseName = "Désamorçage Rapide",
    bombDefuseDesc = "Réduit le temps de désamorçage des bombes de 8% par niveau de compétence pendant les raids.",
    bombHardeningName = "Bombes Renforcées",
    bombHardeningDesc = "Augmente le temps de désamorçage de vos bombes de 15% par niveau de compétence pendant les raids.",
})

BaseWars:AddTranslation("prestige_progression", "en", "PRESTIGE PROGRESSION")
BaseWars:AddTranslation("prestige_duringRaid", "en", "You cannot prestige during a raid")
BaseWars:AddTranslation("prestige_doPrestige", "en", "Prestige %s")
BaseWars:AddTranslation("prestige_prestigePoint", "en", "You have %s points available")
BaseWars:AddTranslation("prestige_tooExpensive", "en", "You cannot afford this")
BaseWars:AddTranslation("prestige_buyPerkNotif", "en", "You bought a \"%s\" skill level")
BaseWars:AddTranslation("prestige_playerPrestiged", "en", "%s is now prestige %s")
BaseWars:AddTranslation("prestige_buyPerk", "en", "Buy for %s points")
BaseWars:AddTranslation("prestige_maxPerk", "en", "Maximum perk level reached")
BaseWars:AddTranslation("prestige_notEnoughPoint", "en", "Not enough points (%s)")
BaseWars:AddTranslation("prestige_resetPoint", "en", "Reset your points for %s")
BaseWars:AddTranslation("prestige_level", "en", "Level:")
BaseWars:AddTranslation("prestige_price", "en", "Price:")
BaseWars:AddTranslation("prestige_bankInterest", "en", "You received %s in interest from your bank")
BaseWars:AddTranslation("prestige_perks", "en", {
    playerHealthName = "Health",
    playerHealthDesc = "Adds 10 HP per skill level.",
    playerArmorName = "Armor",
    playerArmorDesc = "Adds 10 armor per skill level.",
    playerSpeedName = "Speed",
    playerSpeedDesc = "Makes you 5% faster per skill level.",
    printerUpgradeCostName = "Upgrade Cost",
    printerUpgradeCostDesc = "Reduces the cost of printer upgrades by 5% per skill level.",
    moreXPName = "Increased XP",
    moreXPDesc = "Gives you 5% more XP per skill level.",
    playerDamageName = "Increased Damage",
    playerDamageDesc = "Deals 10% more damage per skill level.",
    morePrinterName = "More Printers",
    morePrinterDesc = "Allows you to spawn one more printer per skill level.",
    moreMoneyDefaultName = "Prestige Money",
    moreMoneyDefaultDesc = "Gives you " .. BaseWars.LANG.Currency .. "20,000 more per skill level when you prestige.",
    propHealthName = "Props Health",
    propHealthDesc = "Adds 50 HP per skill level to your props.",
    bankInterestName = "Bank Interest",
    bankInterestDesc = "Your bank gives you 10% of its money every 15 minutes",
    printerSpeedName = "Fast Printers",
    printerSpeedDesc = "Your printers make money 0.05 second faster per skill level",
    entityHealthName = "Entities Health",
    entityHealthDesc = "Adds 250 HP per skill level to your entities",
    healthRegenerationName = "Health Regeneration",
    healthRegenerationDesc = "Regenerates 1 HP per second per skill level after 10 seconds without taking damage. Works even during raids.",
    armorRegenerationName = "Armor Regeneration",
    armorRegenerationDesc = "Regenerates 1 armor per second per skill level after 10 seconds without taking damage. Works even during raids.",
    hemorrhageName = "Hemorrhage",
    hemorrhageDesc = "25% chance to cause hemorrhage for 1-2 damage per second for 5 seconds. Does not stack.",
    slowDownName = "Slow Down",
    slowDownDesc = "Slows down enemies by 10% per level when you damage them. Chance: 25% + 5% per level. Cooldown: 5 seconds. Duration: 4 seconds.",
    bombDefuseName = "Fast Defuse",
    bombDefuseDesc = "Reduces bomb defuse time by 8% per skill level during raids.",
    bombHardeningName = "Bomb Hardening",
    bombHardeningDesc = "Increases defuse time of your bombs by 15% per skill level during raids.",
})

hook.Add("BaseWars:Initialize", "BaseWars:Prestige", function()
    if CLIENT then
        BaseWars:AddBaseWarsMenuTab("#bwm_prestige", "basewars_materials/f3/prestige.png", "BaseWars.F3Menu.Prestige", 10)
    end

    BaseWars:AddPrestigPerk("playerHealth", 5, 1, function()
        if not SERVER then return end

        local function func(ply)
            local extra = ply:GetPrestigePerk("playerHealth") * 10

            timer.Simple(0, function()
                ply:SetMaxHealth(ply:GetMaxHealth() + extra)
                ply:SetHealth(ply:GetMaxHealth())
            end)
        end

        hook.Add("PlayerSpawn", "BaseWars:Prestige:Health", func)
        hook.Add("BaseWars:Prestige:RestorePlayerData", "BaseWars:Prestige:Health", func)
    end)

    BaseWars:AddPrestigPerk("playerArmor", 5, 1, function()
        if not SERVER then return end

        local function func(ply)
            local extra = ply:GetPrestigePerk("playerArmor") * 10

            timer.Simple(0, function()
                ply:SetMaxArmor(ply:GetMaxArmor() + extra)
            end)
        end

        hook.Add("PlayerSpawn", "BaseWars:Prestige:Armor", func)
        hook.Add("BaseWars:Prestige:RestorePlayerData", "BaseWars:Prestige:Armor", func)
    end)

    BaseWars:AddPrestigPerk("playerSpeed", 5, 1, function()
        if not SERVER then return end

        local function func(ply)
            local walkSpeed = 1 + ply:GetPrestigePerk("playerSpeed") * .05
            local runSpeed = 1 + ply:GetPrestigePerk("playerSpeed") * .05

            timer.Simple(0, function()
                ply:SetWalkSpeed(ply:GetWalkSpeed() * walkSpeed)
                ply:SetRunSpeed(ply:GetRunSpeed() * runSpeed)
            end)
        end

        hook.Add("PlayerSpawn", "BaseWars:Prestige:WalkSpeed", func)
        hook.Add("BaseWars:Prestige:RestorePlayerData", "BaseWars:Prestige:WalkSpeed", func)
    end)

    BaseWars:AddPrestigPerk("printerUpgradeCost", 5, 2, function()
        if not SERVER then return end

        hook.Add("BaseWars:BuyEntity", "BaseWars:Prestige:printerUpgradeCost", function(ply, entity, entityID)
            local multiplier = 1 - .05 * ply:GetPrestigePerk("printerUpgradeCost")

            if entity.IsPrinter then
                entity:SetupPrinterCost(BaseWars:GetBaseWarsEntity(entityID):GetPrice() * multiplier)
            end

            if entity.IsBank then
                entity:SetCapacityCost(20000 * multiplier)
                entity:SetHealthCost(entity:GetCapacityCost() * 8)
            end
        end)
    end)

    BaseWars:AddPrestigPerk("moreXP", 5, 2, function()
        if not SERVER then return end

        hook.Add("BaseWars:PlayerGainXP", "BaseWars:Prestige", function(ply)
            return 1 + ply:GetPrestigePerk("moreXP") * .05
        end)
    end)

    BaseWars:AddPrestigPerk("playerDamage", 3, 2, function()
        if not SERVER then return end

        hook.Add("EntityTakeDamage", "BaseWars:Prestige", function(ent, dmg)
            local att = dmg:GetAttacker()
            if att:IsPlayer() then
                local multiplier = 1 + att:GetPrestigePerk("playerDamage") * .05
                dmg:ScaleDamage(multiplier)
            end
        end)
    end)

    BaseWars:AddPrestigPerk("morePrinter", 4, 2, function()
        hook.Add("BaseWars:PrinterCap", "BaseWars:Prestige", function(ply)
            return ply:GetPrestigePerk("morePrinter")
        end)
    end)

    BaseWars:AddPrestigPerk("moreMoneyDefault", 4, 2, function()
        if not SERVER then return end

        hook.Add("BaseWars:Prestige:OnPlayerPrestige", "BaseWars:Prestige", function(ply)
            local money = BaseWars.Config.StartMoney + ply:GetPrestigePerk("moreMoneyDefault") * 20000

            ply:SetMoney(money)
        end)
    end)

    BaseWars:AddPrestigPerk("propHealth", 4, 2, function()
        if not SERVER then return end

        hook.Add("BaseWars:PostSetPropHealth", "BaseWars:Prestige", function(ply, prop)
            local extra = 50 * ply:GetPrestigePerk("propHealth")

            prop:SetMaxHealth(prop:GetMaxHealth() + extra)
            prop:SetHealth(prop:GetMaxHealth())
        end)
    end)

    BaseWars:AddPrestigPerk("printerSpeed", 4, 4, function()
        if not SERVER then return end

        hook.Add("BaseWars:BuyEntity", "BaseWars:Prestige:printerSpeed", function(ply, entity, entityID)
            local level = ply:GetPrestigePerk("printerSpeed")

            if entity.IsPrinter then
                entity:SetPrintInterval(entity:GetPrintInterval() - .05 * level)
            end
        end)
    end)

    BaseWars:AddPrestigPerk("entityHealth", 3, 2, function()
        if not SERVER then return end

        hook.Add("BaseWars:BuyEntity", "BaseWars:Prestige:entityHealth", function(ply, entity, entityID)
            local extra = 250 * ply:GetPrestigePerk("entityHealth")
            local entityHealth = entity:GetMaxHealth()

            entity.PresetHealth = entityHealth + extra
            entity:SetMaxHealth(entityHealth + extra)
            entity:SetHealth(entity:GetMaxHealth())
        end)
    end)

    BaseWars:AddPrestigPerk("healthRegeneration", 5, 1, function()
        if not SERVER then return end

        local playerHealthRegenData = {}
        
        local function ValidatePlayer(ply)
            if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then
                return false
            end
            return true
        end
        
        local function GetValidatedHealthRegenLevel(ply)
            if not ValidatePlayer(ply) then return 0 end
            
            local level = ply:GetPrestigePerk("healthRegeneration") or 0
            if level < 0 or level > 5 then
                BaseWars:Log("Invalid health regeneration level detected for player " .. ply:Nick() .. ": " .. level, "warning")
                return 0
            end
            return level
        end
        
        local function InitializePlayerHealthRegen(ply)
            if not ValidatePlayer(ply) then return end
            
            local steamID = ply:SteamID()
            playerHealthRegenData[steamID] = {
                lastDamageTime = 0,
                isRegenerating = false,
                lastRegenTime = 0
            }
        end
        
        hook.Add("EntityTakeDamage", "BaseWars:Prestige:HealthRegeneration:TrackDamage", function(ent, dmg)
            if not ent:IsPlayer() then return end
            
            local ply = ent
            if not ValidatePlayer(ply) then return end
            
            local level = GetValidatedHealthRegenLevel(ply)
            if level <= 0 then return end
            
            local steamID = ply:SteamID()
            if not playerHealthRegenData[steamID] then
                InitializePlayerHealthRegen(ply)
            end
            
            playerHealthRegenData[steamID].lastDamageTime = CurTime()
            playerHealthRegenData[steamID].isRegenerating = false
        end)
        
        hook.Add("PlayerInitialSpawn", "BaseWars:Prestige:HealthRegeneration:Initialize", function(ply)
            InitializePlayerHealthRegen(ply)
        end)
        
        hook.Add("PlayerDisconnected", "BaseWars:Prestige:HealthRegeneration:Cleanup", function(ply)
            local steamID = ply:SteamID()
            playerHealthRegenData[steamID] = nil
        end)
        
        hook.Add("PlayerSpawn", "BaseWars:Prestige:HealthRegeneration:Reset", function(ply)
            InitializePlayerHealthRegen(ply)
        end)
        
        timer.Create("BaseWars:Prestige:HealthRegeneration", 1, 0, function()
            for _, ply in ipairs(player.GetAll()) do
                if not ValidatePlayer(ply) then continue end
                
                local level = GetValidatedHealthRegenLevel(ply)
                if level <= 0 then continue end
                
                local steamID = ply:SteamID()
                local regenData = playerHealthRegenData[steamID]
                
                if not regenData then
                    InitializePlayerHealthRegen(ply)
                    continue
                end
                
                local currentTime = CurTime()
                
                if currentTime - regenData.lastDamageTime >= 10 then
                    if currentTime - regenData.lastRegenTime >= 1 then
                        local healthRegen = level * 1
                        
                        local currentHealth = ply:Health()
                        local maxHealth = ply:GetMaxHealth()
                        
                        if currentHealth < maxHealth then
                            local newHealth = math.min(currentHealth + healthRegen, maxHealth)
                            ply:SetHealth(newHealth)
                        end
                        
                        regenData.lastRegenTime = currentTime
                        regenData.isRegenerating = true
                    end
                else
                    regenData.isRegenerating = false
                end
            end
        end)
        
        hook.Add("BaseWars:Prestige:RestorePlayerData", "BaseWars:Prestige:HealthRegeneration:Restore", function(ply)
            InitializePlayerHealthRegen(ply)
        end)
    end)

    BaseWars:AddPrestigPerk("armorRegeneration", 5, 1, function()
        if not SERVER then return end

        local playerArmorRegenData = {}
        
        local function ValidatePlayer(ply)
            if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then
                return false
            end
            return true
        end
        
        local function GetValidatedArmorRegenLevel(ply)
            if not ValidatePlayer(ply) then return 0 end
            
            local level = ply:GetPrestigePerk("armorRegeneration") or 0
            if level < 0 or level > 5 then
                BaseWars:Log("Invalid armor regeneration level detected for player " .. ply:Nick() .. ": " .. level, "warning")
                return 0
            end
            return level
        end
        
        local function InitializePlayerArmorRegen(ply)
            if not ValidatePlayer(ply) then return end
            
            local steamID = ply:SteamID()
            playerArmorRegenData[steamID] = {
                lastDamageTime = 0,
                isRegenerating = false,
                lastRegenTime = 0
            }
        end
        
        hook.Add("EntityTakeDamage", "BaseWars:Prestige:ArmorRegeneration:TrackDamage", function(ent, dmg)
            if not ent:IsPlayer() then return end
            
            local ply = ent
            if not ValidatePlayer(ply) then return end
            
            local level = GetValidatedArmorRegenLevel(ply)
            if level <= 0 then return end
            
            local steamID = ply:SteamID()
            if not playerArmorRegenData[steamID] then
                InitializePlayerArmorRegen(ply)
            end
            
            playerArmorRegenData[steamID].lastDamageTime = CurTime()
            playerArmorRegenData[steamID].isRegenerating = false
        end)
        
        hook.Add("PlayerInitialSpawn", "BaseWars:Prestige:ArmorRegeneration:Initialize", function(ply)
            InitializePlayerArmorRegen(ply)
        end)
        
        hook.Add("PlayerDisconnected", "BaseWars:Prestige:ArmorRegeneration:Cleanup", function(ply)
            local steamID = ply:SteamID()
            playerArmorRegenData[steamID] = nil
        end)
        
        hook.Add("PlayerSpawn", "BaseWars:Prestige:ArmorRegeneration:Reset", function(ply)
            InitializePlayerArmorRegen(ply)
        end)
        
        timer.Create("BaseWars:Prestige:ArmorRegeneration", 1, 0, function()
            for _, ply in ipairs(player.GetAll()) do
                if not ValidatePlayer(ply) then continue end
                
                local level = GetValidatedArmorRegenLevel(ply)
                if level <= 0 then continue end
                
                local steamID = ply:SteamID()
                local regenData = playerArmorRegenData[steamID]
                
                if not regenData then
                    InitializePlayerArmorRegen(ply)
                    continue
                end
                
                local currentTime = CurTime()
                
                if currentTime - regenData.lastDamageTime >= 10 then
                    if currentTime - regenData.lastRegenTime >= 1 then
                        local armorRegen = level * 1
                        
                        local currentArmor = ply:Armor()
                        local maxArmor = ply:GetMaxArmor()
                        
                        if currentArmor < maxArmor then
                            local newArmor = math.min(currentArmor + armorRegen, maxArmor)
                            ply:SetArmor(newArmor)
                        end
                        
                        regenData.lastRegenTime = currentTime
                        regenData.isRegenerating = true
                    end
                else
                    regenData.isRegenerating = false
                end
            end
        end)
        
        hook.Add("BaseWars:Prestige:RestorePlayerData", "BaseWars:Prestige:ArmorRegeneration:Restore", function(ply)
            InitializePlayerArmorRegen(ply)
        end)
    end)

    BaseWars:AddPrestigPerk("hemorrhage", 2, 2, function()
        if not SERVER then return end

        local playerHemorrhageData = {}
        
        local function ValidatePlayer(ply)
            if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then
                return false
            end
            return true
        end
        
        local function GetValidatedHemorrhageLevel(ply)
            if not ValidatePlayer(ply) then return 0 end
            
            local level = ply:GetPrestigePerk("hemorrhage") or 0
            if level < 0 or level > 2 then
                BaseWars:Log("Invalid hemorrhage level detected for player " .. ply:Nick() .. ": " .. level, "warning")
                return 0
            end
            return level
        end
        
        local function ApplyHemorrhage(target, attacker)
            if not ValidatePlayer(target) or not ValidatePlayer(attacker) then return end
            
            local level = GetValidatedHemorrhageLevel(attacker)
            local steamID = target:SteamID()
            local currentTime = CurTime()
            
            local damagePerSecond = level
            
            playerHemorrhageData[steamID] = {
                startTime = currentTime,
                duration = 5,
                damage = damagePerSecond,
                attacker = attacker,
                lastDamageTime = 0,
                lastSoundTime = 0
            }
            
            target:EmitSound("player/pl_pain5.wav", 50, 100, 0.5)
            
            attacker:EmitSound("weapons/crossbow/bolt_fly4.wav", 40, 150, 0.3)
        end
        
        hook.Add("EntityTakeDamage", "BaseWars:Prestige:Hemorrhage:Apply", function(ent, dmg)
            if not ent:IsPlayer() then return end
            
            local target = ent
            local attacker = dmg:GetAttacker()
            
            if not attacker:IsPlayer() or not ValidatePlayer(attacker) then return end
            
            if target == attacker then return end
            
            local level = GetValidatedHemorrhageLevel(attacker)
            if level <= 0 then return end
            
            local hemorrhageChance = 0.25
            
            if math.random() <= hemorrhageChance then
                ApplyHemorrhage(target, attacker)
            end
        end)
        
        hook.Add("PlayerDisconnected", "BaseWars:Prestige:Hemorrhage:Cleanup", function(ply)
            local steamID = ply:SteamID()
            playerHemorrhageData[steamID] = nil
        end)
        
        hook.Add("PlayerSpawn", "BaseWars:Prestige:Hemorrhage:Reset", function(ply)
            local steamID = ply:SteamID()
            playerHemorrhageData[steamID] = nil
        end)
        
        timer.Create("BaseWars:Prestige:Hemorrhage", 1, 0, function()
            local currentTime = CurTime()
            
            for steamID, hemorrhageData in pairs(playerHemorrhageData) do
                local target = player.GetBySteamID(steamID)
                if not ValidatePlayer(target) then
                    playerHemorrhageData[steamID] = nil
                    continue
                end
                
                if currentTime - hemorrhageData.startTime >= hemorrhageData.duration then
                    playerHemorrhageData[steamID] = nil
                    continue
                end
                
                if currentTime - hemorrhageData.lastDamageTime >= 1 then
                    local damage = hemorrhageData.damage
                    
                    if target:Health() > 0 and damage > 0 then
                        local dmgInfo = DamageInfo()
                        dmgInfo:SetDamage(damage)
                        dmgInfo:SetAttacker(hemorrhageData.attacker)
                        dmgInfo:SetDamageType(DMG_SLASH)
                        dmgInfo:SetDamageForce(Vector(0, 0, 0))
                        
                        target:TakeDamageInfo(dmgInfo)
                        
                        target:EmitSound("ambient/water/drip1.wav", 30, 80, 0.2)
                    end
                    
                    hemorrhageData.lastDamageTime = currentTime
                end
            end
        end)
        
        hook.Add("BaseWars:Prestige:RestorePlayerData", "BaseWars:Prestige:Hemorrhage:Restore", function(ply)
            local steamID = ply:SteamID()
            playerHemorrhageData[steamID] = nil
        end)
    end)

    BaseWars:AddPrestigPerk("slowDown", 4, 2, function()
        if not SERVER then return end

        local playerSlowDownData = {}
        local attackerCooldownData = {}
        
        local function ValidatePlayer(ply)
            if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then
                return false
            end
            return true
        end
        
        local function GetValidatedSlowDownLevel(ply)
            if not ValidatePlayer(ply) then return 0 end
            
            local level = ply:GetPrestigePerk("slowDown") or 0
            if level < 0 or level > 4 then
                BaseWars:Log("Invalid slow down level detected for player " .. ply:Nick() .. ": " .. level, "warning")
                return 0
            end
            return level
        end
        
        local function ApplySlowDown(victim, attacker)
            if not ValidatePlayer(victim) or not ValidatePlayer(attacker) then return end
            
            local level = GetValidatedSlowDownLevel(attacker)
            if level <= 0 then return end
            
            local steamID = victim:SteamID()
            local attackerSteamID = attacker:SteamID()
            local currentTime = CurTime()
            
            -- Vérifier le cooldown pour l'attaquant
            if attackerCooldownData[attackerSteamID] and currentTime - attackerCooldownData[attackerSteamID] < 5 then
                return
            end
            
            -- Calculer le pourcentage de chance (base 25% + 5% par niveau)
            local procChance = 0.25 + (level * 0.05)
            if math.random() > procChance then
                return
            end
            
            -- Sauvegarder les vitesses originales si ce n'est pas déjà fait
            if not playerSlowDownData[steamID] then
                playerSlowDownData[steamID] = {
                    originalWalkSpeed = victim:GetWalkSpeed(),
                    originalRunSpeed = victim:GetRunSpeed()
                }
            end
            
            local slowPercent = level * 0.10  -- Augmenté de 5% à 10% par niveau
            local slowMultiplier = 1 - slowPercent
            
            -- Mettre à jour les données de ralentissement
            playerSlowDownData[steamID].startTime = currentTime
            playerSlowDownData[steamID].duration = 4  -- Augmenté de 3 à 4 secondes
            playerSlowDownData[steamID].multiplier = slowMultiplier
            playerSlowDownData[steamID].attacker = attacker
            
            -- Appliquer le ralentissement
            victim:SetWalkSpeed(playerSlowDownData[steamID].originalWalkSpeed * slowMultiplier)
            victim:SetRunSpeed(playerSlowDownData[steamID].originalRunSpeed * slowMultiplier)
            
            -- Mettre le cooldown pour l'attaquant
            attackerCooldownData[attackerSteamID] = currentTime
            
            -- Sons améliorés pour la victime (son de glace/froid)
            victim:EmitSound("ambient/levels/canals/windchime2.wav", 45, 90, 0.4)
            victim:EmitSound("physics/glass/glass_impact_bullet1.wav", 35, 85, 0.3)
            
            -- Son pour l'attaquant (son de succès)
            attacker:EmitSound("weapons/crossbow/bolt_fly2.wav", 40, 130, 0.3)
            attacker:EmitSound("ambient/energy/spark2.wav", 30, 120, 0.2)
        end
        
        hook.Add("EntityTakeDamage", "BaseWars:Prestige:SlowDown:Apply", function(ent, dmg)
            if not ent:IsPlayer() then return end
            
            local victim = ent
            local attacker = dmg:GetAttacker()
            
            if not attacker:IsPlayer() or not ValidatePlayer(attacker) then return end
            
            if victim == attacker then return end
            
            local level = GetValidatedSlowDownLevel(attacker)
            if level <= 0 then return end
            
            ApplySlowDown(victim, attacker)
        end)
        
        hook.Add("PlayerDisconnected", "BaseWars:Prestige:SlowDown:Cleanup", function(ply)
            local steamID = ply:SteamID()
            
            -- Nettoyer les données de ralentissement si le joueur était une victime
            if playerSlowDownData[steamID] then
                local slowData = playerSlowDownData[steamID]
                if IsValid(ply) then
                    ply:SetWalkSpeed(slowData.originalWalkSpeed)
                    ply:SetRunSpeed(slowData.originalRunSpeed)
                end
                playerSlowDownData[steamID] = nil
            end
            
            -- Nettoyer les données de cooldown si le joueur était un attaquant
            attackerCooldownData[steamID] = nil
        end)
        
        hook.Add("PlayerSpawn", "BaseWars:Prestige:SlowDown:Reset", function(ply)
            local steamID = ply:SteamID()
            
            -- Restaurer la vitesse si le joueur était ralenti
            if playerSlowDownData[steamID] then
                local slowData = playerSlowDownData[steamID]
                ply:SetWalkSpeed(slowData.originalWalkSpeed)
                ply:SetRunSpeed(slowData.originalRunSpeed)
                playerSlowDownData[steamID] = nil
            end
            
            -- Nettoyer le cooldown au respawn
            attackerCooldownData[steamID] = nil
        end)
        
        timer.Create("BaseWars:Prestige:SlowDown", 1, 0, function()
            local currentTime = CurTime()
            
            for steamID, slowData in pairs(playerSlowDownData) do
                local victim = player.GetBySteamID(steamID)
                
                if currentTime - slowData.startTime >= slowData.duration then
                    if ValidatePlayer(victim) then
                        victim:SetWalkSpeed(slowData.originalWalkSpeed)
                        victim:SetRunSpeed(slowData.originalRunSpeed)
                        
                        victim:EmitSound("physics/concrete/concrete_block_impact_hard2.wav", 30, 100, 0.2)
                    end
                    
                    playerSlowDownData[steamID] = nil
                    continue
                end
                
                if not ValidatePlayer(victim) then
                    playerSlowDownData[steamID] = nil
                end
            end
        end)
        
        hook.Add("BaseWars:Prestige:RestorePlayerData", "BaseWars:Prestige:SlowDown:Restore", function(ply)
            local steamID = ply:SteamID()
            
            if playerSlowDownData[steamID] then
                local slowData = playerSlowDownData[steamID]
                if ValidatePlayer(ply) then
                    ply:SetWalkSpeed(slowData.originalWalkSpeed)
                    ply:SetRunSpeed(slowData.originalRunSpeed)
                end
                playerSlowDownData[steamID] = nil
            end
        end)
    end)

    -- BaseWars:AddPrestigPerk("bombDefuse", 5, 2, function()
    --     -- Hook pour modifier la vitesse de désamorçage des bombes (côté serveur et client)
    --     hook.Add("BaseWars:GetDefuseSpeed", "BaseWars:Prestige:BombDefuse", function(ply)
    --         if not IsValid(ply) or not ply:IsPlayer() then return 1 end
            
    --         local level = ply:GetPrestigePerk("bombDefuse") or 0
    --         if level <= 0 then return 1 end
            
    --         -- Réduction de 8% par niveau (0.92, 0.84, 0.76, 0.68, 0.60)
    --         local speedMultiplier = 1 - (level * 0.08)
    --         return math.max(speedMultiplier, 0.6) -- Minimum 60% du temps original
    --     end)
        
    --     if SERVER then
    --         -- Hook pour jouer des sons quand un joueur avec la compétence désamorce (côté serveur uniquement)
    --         hook.Add("BaseWars:OnBombDefuseStart", "BaseWars:Prestige:BombDefuse", function(ply, bomb)
    --             if not IsValid(ply) or not IsValid(bomb) then return end
                
    --             local level = ply:GetPrestigePerk("bombDefuse") or 0
    --             if level <= 0 then return end
                
    --             -- Son de démarrage de désamorçage amélioré
    --             ply:EmitSound("buttons/button14.wav", 40, 120 + (level * 10), 0.3)
    --         end)
            
    --         hook.Add("BaseWars:OnBombDefuseProgress", "BaseWars:Prestige:BombDefuse", function(ply, bomb, progress)
    --             if not IsValid(ply) or not IsValid(bomb) then return end
                
    --             local level = ply:GetPrestigePerk("bombDefuse") or 0
    --             if level <= 0 then return end
                
    --             -- Son de progression tous les 25%
    --             if progress % 25 == 0 then
    --                 ply:EmitSound("buttons/button9.wav", 35, 100 + (level * 5), 0.2)
    --             end
    --         end)
            
    --         hook.Add("BaseWars:OnBombDefused", "BaseWars:Prestige:BombDefuse", function(ply, bomb)
    --             if not IsValid(ply) or not IsValid(bomb) then return end
                
    --             local level = ply:GetPrestigePerk("bombDefuse") or 0
    --             if level <= 0 then return end
                
    --             -- Son de succès amélioré selon le niveau
    --             ply:EmitSound("items/ammo_pickup.wav", 50, 100 + (level * 10), 0.4)
    --             ply:EmitSound("ambient/energy/zap1.wav", 30, 150, 0.3)
                
    --             -- Notification visuelle
    --             BaseWars:Notify(ply, "#prestige_bombDefuseSuccess", NOTIFICATION_GENERIC, 3, level)
    --         end)
    --     end
    -- end)

    -- BaseWars:AddPrestigPerk("bombHardening", 5, 2, function()
    --     -- Hook pour augmenter le temps de désamorçage des bombes posées par le joueur (côté serveur et client)
    --     hook.Add("BaseWars:GetBombDefuseTime", "BaseWars:Prestige:BombHardening", function(bomb, ply)
    --         if not IsValid(bomb) then return end
            
    --         local bombOwner = bomb:CPPIGetOwner()
    --         if not IsValid(bombOwner) then return end
            
    --         local level = bombOwner:GetPrestigePerk("bombHardening") or 0
    --         if level <= 0 then return end
            
    --         -- Augmentation de 15% par niveau (1.15, 1.30, 1.45, 1.60, 1.75)
    --         local hardeningMultiplier = 1 + (level * 0.15)
    --         local baseDefuseTime = bomb.Defuse or 20
    --         local newDefuseTime = baseDefuseTime * math.min(hardeningMultiplier, 1.75)
            
    --         return newDefuseTime -- Retourner le temps de désamorçage modifié
    --     end)
        
    --     if SERVER then
    --         -- Hook pour modifier le DefuseTime de la bombe au moment de la pose (côté serveur uniquement)
    --         hook.Add("BaseWars:OnBombPlanted", "BaseWars:Prestige:BombHardening", function(bomb, owner)
    --             if not IsValid(bomb) or not IsValid(owner) then return end
                
    --             local level = owner:GetPrestigePerk("bombHardening") or 0
    --             if level <= 0 then return end
                
    --             -- Augmenter le temps de désamorçage de la bombe
    --             local originalDefuseTime = bomb.Defuse or 20
    --             local hardeningMultiplier = 1 + (level * 0.15)
    --             local newDefuseTime = originalDefuseTime * math.min(hardeningMultiplier, 1.75)
                
    --             bomb.Defuse = newDefuseTime
                
    --             -- Son spécial quand une bombe renforcée est posée
    --             owner:EmitSound("ambient/energy/spark3.wav", 45, 80, 0.4)
    --             owner:EmitSound("buttons/button24.wav", 40, 90, 0.3)
                
    --             -- Notification visuelle pour le propriétaire
    --             BaseWars:Notify(owner, "#prestige_bombHardeningApplied", NOTIFICATION_GENERIC, 3, level)
    --         end)
    --     end
    -- end)

    BaseWars:AddPrestigPerk("bankInterest", 1, 5, function() end)

    if BaseWars.Config.Prestige.Enable then
        BaseWars:ExecutePrestigePerkFunc()
    end
end)
