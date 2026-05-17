/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if CLIENT then return end
zpn = zpn or {}
zpn.Boss = zpn.Boss or {}



zpn.SpawnedBoss = zpn.SpawnedBoss or {}

// Function to spawn a lamp
local function MakeLamp()
    local lamp = ents.Create("gmod_lamp")
    if (not IsValid(lamp)) then return end
    lamp:SetModel("models/maxofs2d/lamp_projector.mdl")
    lamp:SetNoDraw(true)
    lamp:SetFlashlightTexture("effects/flashlight001")
    lamp:SetLightFOV(90)

    lamp:SetColor(zpn.Theme.Boss.spotlight_color)

    lamp:SetDistance(2048)
    lamp:SetBrightness(5)
    lamp:Switch(true)
    lamp:SetToggle(true)
    lamp:Spawn()
    lamp.Texture = "effects/flashlight001"
    lamp.fov = 90
    lamp.distance = 2048
    lamp.r = 255
    lamp.g = 42
    lamp.b = 0
    lamp.brightness = 2

    return lamp
end

////////////////////////////////////////////
///////////// INITZIALIZE //////////////////
////////////////////////////////////////////
function zpn.Boss.Initialize(Boss)
    zclib.Debug("zpn.Boss.Initialize")

    Boss:SetModel(zpn.Theme.Boss.model_main)
    Boss:PhysicsInit(SOLID_VPHYSICS)
    Boss:SetSolid(SOLID_VPHYSICS)
    Boss:SetMoveType(MOVETYPE_NONE)

    local phys = Boss:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
        phys:IsMoveable(false)
    end

    Boss:UseClientSideAnimation()

    zclib.EntityTracker.Add(Boss)

    table.insert(zpn.SpawnedBoss,Boss)

	Boss._LastDamage = CurTime()

    // Spawn Ground
    Boss.Ground = ents.Create("prop_dynamic")
    Boss.Ground:SetModel(zpn.Theme.Boss.model_ground)
    Boss.Ground:SetPos(Boss:GetPos())
    Boss.Ground:SetAngles(Boss:GetAngles())
    Boss.Ground:SetModelScale(3, 0)
    Boss.Ground:Spawn()
    Boss.Ground:Activate()
    Boss.Ground:PhysicsInit(SOLID_VPHYSICS)
    Boss.Ground:SetSolid(SOLID_VPHYSICS)
    Boss.Ground:SetMoveType(MOVETYPE_NONE)

    Boss.Ground.PhysgunDisabled = true

    local aphys = Boss.Ground:GetPhysicsObject()
    if IsValid(aphys) then
        aphys:Wake()
        aphys:EnableMotion(false)
        aphys:IsMoveable(false)
    end



    // A spotlight for better lightning
    if zpn.config.Boss.Spotlight and gmod.GetGamemode().ThisClass ~= "gamemode_terrortown" then
        Boss.Lamp = MakeLamp()
        Boss.Lamp:SetPos(Boss:GetPos() + Boss:GetUp() * 600 + Boss:GetForward() * -400)
        Boss.Lamp:SetAngles(Boss:LocalToWorldAngles(Angle(45,0,45)))
        Boss.Lamp:Activate()
        Boss.Lamp:SetParent(Boss)
        Boss:DeleteOnRemove(Boss.Lamp )
    end

    Boss.PhysgunDisabled = true

    Boss.NextMinionSpawn = -1
    Boss.NextCloseRangeAttack = -1
    Boss.NextFarRangeAttack = -1

    timer.Simple(1, function()
        if IsValid(Boss) then
            zpn.Boss.Spawn(Boss)
        end
    end)
end
////////////////////////////////////////////
////////////////////////////////////////////

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851




////////////////////////////////////////////
//////////////// MAIN /////////////////////
////////////////////////////////////////////
// Core Logic of the Boss
function zpn.Boss.MainLogic(Boss)
    zclib.Debug("zpn.Boss.MainLogic")

    if Boss:GetMonsterHealth() <= 0 then return end

	// If the boss has not been attacked for a certain amount of time then despawn
	if zpn.config.Boss.IdleDespawn and zpn.config.Boss.IdleDespawn > 0 and Boss._LastDamage and CurTime() > (Boss._LastDamage + zpn.config.Boss.IdleDespawn) then
		zpn.Boss.Despawn(Boss)
		return
	end

    // Do we have less then 40% health and is the heal cooldown reset?
    if Boss:GetMonsterHealth() < zpn.config.Boss.Health and CurTime() > (Boss.LastHeal + zpn.config.Boss.HealCooldown) then
        zpn.Boss.StartHeal(Boss)
        return
    end

    // Get Targets
    local targets = zpn.Boss.GetTargets(Boss)

    if targets and table.Count(targets) > 0 then

        // Can we make a close range attack again?
        if Boss.NextCloseRangeAttack < CurTime() then
            Boss.NextCloseRangeAttack = CurTime() + zpn.config.Boss.CloseRangeAttack.Cooldown

            // Is there a target close by?
            local closeTarget = zpn.Boss.GetCloseTarget(Boss)
            if IsValid(closeTarget) then
                if zclib.util.RandomChance(75) then
                    zpn.Boss.Attack_Smash(Boss)
                else
                    zpn.Boss.Attack_CircularSmash(Boss)
                end

                return
            end
        end

        // Can we spawn more minions?
        if Boss.NextMinionSpawn < CurTime() and table.Count(Boss.Minions) < zpn.config.Boss.Minions.Count then
            Boss.NextMinionSpawn = CurTime() + zpn.config.Boss.Minions.Interval
            zpn.Boss.Attack_SpawnMinions(Boss)
            return
        end

        if Boss.NextFarRangeAttack < CurTime() then
            // Lets make it rain fire!
            if zclib.util.RandomChance(50) then
                zpn.Boss.Attack_PumpkinBombs(Boss)
            else
                zpn.Boss.Attack_FireDance(Boss)
            end

            Boss.NextFarRangeAttack = CurTime() + zpn.config.Boss.FarRangeAttack.Cooldown
        else
            zclib.Debug("Boss_AttackCooldown")
            zpn.Boss.NextAction(Boss,5,true)
        end
    else

        // Play idle/search animation
        zpn.Boss.IDLE(Boss)
    end
end

// Stops the Logice Timer
function zpn.Boss.StopLogic(Boss)
    if not IsValid(Boss) then return end
    //zclib.Debug("zpn.Boss.StopLogic")

    local logic_timerid = "BossEnemy_" .. Boss:EntIndex() .. "_logictimer"
    zclib.Timer.Remove(logic_timerid)

    local heal_timerid = "BossEnemy_" .. Boss:EntIndex() .. "_healtimer"
    zclib.Timer.Remove(heal_timerid)
end

// Call the next action after this amount of time
function zpn.Boss.NextAction(Boss,delay,attack)
    //zclib.Debug("zpn.Boss.NextAction")

    // Stop the timer if he allready exists
    zpn.Boss.StopLogic(Boss)

    local timerid = "BossEnemy_" .. Boss:EntIndex() .. "_logictimer"
    zclib.Timer.Create(timerid,delay,1,function()
        zclib.Timer.Remove(timerid)
        zpn.Boss.StopLogic(Boss)
        if not IsValid(Boss) then return end
        if attack then
            zpn.Boss.MainLogic(Boss)
        else
            zpn.Boss.NoAttack(Boss)
        end
    end)
end

function zpn.Boss.OnTakeDamage(Boss, dmginfo)
    zclib.Debug("zpn.Boss.OnTakeDamage")

    // Is the boss spawning right now?
    if Boss:GetActionState() == -1 or Boss:GetActionState() == 4 then return end

    // Is the boss dead allready?
    if Boss:GetMonsterHealth() <= 0 then return end

    if dmginfo:GetDamage() <= 0 then return end

    if not Boss.m_bApplyingDamage then
        Boss.m_bApplyingDamage = true

		Boss._LastDamage = CurTime()

        local attacker = dmginfo:GetAttacker()
        local dmg = dmginfo:GetDamage()
        
        -- Calcul de distance uniquement si l'attaquant est valide et a une position
        if IsValid(attacker) and attacker.GetPos then
            local distance = attacker:GetPos():Distance(Boss:GetPos())
            -- Réduction progressive des dégâts en fonction de la distance
            -- 100% à courte distance, minimum 10% à longue distance
            local maxDist = zpn.config.Boss.AttackDistance or 4500
            local distanceFactor = math.Clamp(1 - (distance / maxDist), 0.1, 1)
            dmg = dmg * distanceFactor
        end
        
        dmg = math.Clamp(dmg, 0, 9999999999999)

        if IsValid(attacker) then
            if attacker:IsPlayer() then
                local swep = attacker:GetActiveWeapon()

                if IsValid(swep) and zpn.config.DamageClamp[swep:GetClass()] then
                    dmg = math.Clamp(dmg, 0, zpn.config.DamageClamp[swep:GetClass()])
                end
            elseif attacker:GetClass() == "entityflame" then
                dmg = 1
            end
        end

        // If the Boss is healing then we damage his HealShield
        if Boss:GetActionState() == 3 then
            Boss:SetShield(math.Clamp(Boss:GetShield() - dmg,0,zpn.config.Boss.HealShield))
        else

            Boss:TakeDamageInfo(dmginfo)

            Boss:SetMonsterHealth(math.Clamp(Boss:GetMonsterHealth() - dmg, 0, zpn.config.Boss.Health))

            // Lets keep on track what player inflicts how much damage
            if IsValid(attacker) and attacker:IsPlayer() then

                if Boss.DamageReport == nil then
                    Boss.DamageReport = {}
                end

                local id = attacker:SteamID64()
                Boss.DamageReport[id] = math.Round((Boss.DamageReport[id] or 0) + dmg)
            end

            if Boss:GetMonsterHealth() <= 0 then
                zpn.Boss.Death(Boss)
            end
        end


        Boss.m_bApplyingDamage = false
    end
end

function zpn.Boss.OnRemove(Boss)
    zpn.Boss.StopLogic(Boss)

    // Despawn Minions
    zpn.Boss.RemoveMinions(Boss)

    if IsValid(Boss.Ground) then
        Boss.Ground:Remove()
    end

    if IsValid(Boss.Lamp) then
        Boss.Lamp:Remove()
    end

    table.RemoveByValue(zpn.SpawnedBoss,Boss)
end
////////////////////////////////////////////
////////////////////////////////////////////






////////////////////////////////////////////
///////////////// Boss States //////////////
////////////////////////////////////////////

/*
    -1 = Spawn
    0 = Idle
    1 = Attack
    2 = Close Attack
    3 = Healling
    4 = DIE
*/

// Changes the current State of the Boss
function zpn.Boss.SetState(Boss,newState)

    Boss:SetActionState(newState)
end

////////////////////////////////////////////
////////////////////////////////////////////





////////////////////////////////////////////
///////////// Default Actions //////////////
////////////////////////////////////////////
// Spawns the Boss
function zpn.Boss.Spawn(Boss)
    zclib.Debug("Boss_Spawn")

    // If enabled then we notify all the Players
    if zpn.config.Boss.Notify.Enabled then
        for k, v in pairs(zclib.Player.List) do
            if IsValid(v) and v:Alive() then

                zclib.Notify(v, zpn.config.Boss.Notify.notify_spawn, 0)

				if zpn.config.Boss.Notify.chatprint then
					v:ChatPrint(zpn.config.Boss.Notify.notify_spawn)
				end
            end
        end
    end

    // The Player Targets, This will also be used by the Pumpkin Minions
    Boss.Targets = {}

    // All the minions spawned by the Boss
    Boss.Minions = {}

    // Sets the Health of the Boss
    Boss:SetMonsterHealth(zpn.config.Boss.Health)

    // This defines the amount of Damage that needs to be inflicted in order to stop him from Healing
    Boss:SetShield(zpn.config.Boss.HealShield)

    // When did the Boss last heal himself
    Boss.LastHeal = 0

    zpn.Animation.Play(Boss, zpn.Theme.Boss.anim["action_spawn"], 1)

	Boss:EmitSound("zpn_boss_spawn")

    // Sets the state to spawning
    zpn.Boss.SetState(Boss,-1)

    zpn.Boss.NextAction(Boss,3.3,false)

	hook.Run("zpn_OnBossSpawned",Boss)
end

// Frezzes his state to despawned
function zpn.Boss.DeSpawned(Boss)
    zclib.Debug("Boss_DeSpawned")

    zpn.Animation.Play(Boss, zpn.Theme.Boss.anim["action_despawned"], 1)

    zpn.Boss.SetState(Boss,-1)
end

// This is same as idle but with diffrent animation
function zpn.Boss.NoAttack(Boss)
    zclib.Debug("Boss_NoAttack")
    zpn.Boss.SetState(Boss,0)

    zpn.Animation.Play(Boss,zpn.Theme.Boss.anim["action_search"] , 2)

    local time = math.Rand(zpn.config.Boss.NoAttack.time_min,zpn.config.Boss.NoAttack.time_max)
    zclib.Debug("Boss_NextAttack in " .. time .. " seconds!")
    zpn.Boss.NextAction(Boss,time,true)
end

// Called when no player is arround
function zpn.Boss.IDLE(Boss)
    zclib.Debug("Boss_IDLE")
    zpn.Boss.SetState(Boss,0)

    zpn.Animation.Play(Boss, zpn.Theme.Boss.anim["action_idle"], 1)

    zpn.Boss.NextAction(Boss,math.random(2,3),true)
end

// Starts the Healing Action of the Boss
util.AddNetworkString("zpn_Boss_StartHeal_net")
function zpn.Boss.StartHeal(Boss)
    zclib.Debug("Boss_StartHeal")

    zpn.Boss.SetState(Boss,3)

    // This is the amount of damage that needs to be inflicted in order to stop the Boss to stop healing
    Boss:SetShield(zpn.config.Boss.HealShield)

    Boss.LastHeal = CurTime()

    local timerid = "BossEnemy_" .. Boss:EntIndex() .. "_healtimer"
    zclib.Timer.Remove(timerid)

    // The health value we try to get
    local _TargetHealth = math.Clamp(Boss:GetMonsterHealth() + zpn.config.Boss.Health * 0.25,0,zpn.config.Boss.Health)

    zclib.Timer.Create(timerid,1,0,function()
        if IsValid(Boss) then
            if Boss:GetMonsterHealth() >= _TargetHealth or Boss:GetShield() <= 0 then
                // Stop Healing
                zpn.Boss.StopHeal(Boss)
            else
                zpn.Boss.Heal(Boss)
            end
        end
    end)

    // Creates all of the visuals on client
    net.Start("zpn_Boss_StartHeal_net")
    net.WriteEntity(Boss)
    net.Broadcast()
end

// Stops the Healing Action of the Boss
util.AddNetworkString("zpn_Boss_StopHeal_net")
function zpn.Boss.StopHeal(Boss)
    zclib.Debug("Boss_StopHeal")

    local timerid = "BossEnemy_" .. Boss:EntIndex() .. "_healtimer"
    zclib.Timer.Remove(timerid)

    net.Start("zpn_Boss_StopHeal_net")
    net.WriteEntity(Boss)
    net.Broadcast()

    Boss:EmitSound("zpn_boss_shieldbroken")

    zpn.Boss.NextAction(Boss,0.6,false)
end

// Heals the Boss
function zpn.Boss.Heal(Boss)
    local NewHealth = zpn.config.Boss.Health * 0.025
    NewHealth = Boss:GetMonsterHealth() + NewHealth
    NewHealth = math.Clamp(NewHealth,0,zpn.config.Boss.Health)
    Boss:SetMonsterHealth(NewHealth)

    Boss:EmitSound("zpn_boss_heal")


    zclib.Debug("Boss_Heal: " .. Boss:GetMonsterHealth())
end

//Spawn the loot
function zpn.Boss.SpawnLoot(LootTable,Boss)

    // Spawns the loot
    local randomAngle = math.random(1000)
    local PumpkinPos = Boss:GetPos()
    local InnerCircleRadius = math.random(50,100)
    local LootPos
    local delay = 0.3
    for k, v in pairs(LootTable) do
        timer.Simple(delay, function()
            LootPos = PumpkinPos
            randomAngle = math.random(1000)
            InnerCircleRadius = math.random(50, 300)
            LootPos = LootPos + Vector(math.cos(randomAngle) * InnerCircleRadius, math.sin(randomAngle) * InnerCircleRadius, 100)
            local ent = ents.Create(v)
            ent:SetPos(LootPos)
            ent:Spawn()
            ent:Activate()

            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                phys:EnableMotion(true)
            end

        end)

        delay = delay + 0.3
    end
end

// Firework
function zpn.Boss.SpawnFirework(LootCount,Boss)

    // Spawns the loot
    local randomAngle
    local BossPos = Boss:GetPos()
    local InnerCircleRadius
    local PyroPos
    local delay = 0.1
    local count = LootCount

    for i = 1, count do
        timer.Simple(delay, function()
            PyroPos = BossPos
            randomAngle = (360 / count) * i
            InnerCircleRadius = math.Clamp(100 + (15 * i),100,600)
            PyroPos = PyroPos + Vector(math.cos(randomAngle) * InnerCircleRadius, math.sin(randomAngle) * InnerCircleRadius, 150)
            local ent = ents.Create("zpn_partypopper_projectile")
            ent:SetPos(PyroPos)
            ent.KillTime = 0.5
            ent:Spawn()
            ent:Activate()
        end)

        delay = delay + 0.3
    end
end
// 1235078258
// Despawns the Boss
function zpn.Boss.Death(Boss)
    zclib.Debug("zpn.Boss.Death")

    zpn.Boss.SetState(Boss,4)

    // Despawn Minions
    zpn.Boss.RemoveMinions(Boss)

    // Stop the MainLogic
    zpn.Boss.StopLogic(Boss)

    // Play death animation
    zpn.Animation.Play(Boss,zpn.Theme.Boss.anim["action_death"], 1)

    Boss:EmitSound("zpn_boss_death")

    // Kill the physics
    local phys = Boss:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end

    // Creates a random table with all the loot
    local LootTable = {}
    for k, v in pairs(zpn.config.Boss.Loot) do
        for i = 1, v do
            table.insert(LootTable,k)
        end
    end
    LootTable = zclib.table.randomize( LootTable )

    // Spawn the loot
    zpn.Boss.SpawnLoot(LootTable,Boss)

    // Spawn Firework
    if zpn.config.Boss.FireworkOnDeath then

        zpn.Boss.SpawnFirework(table.Count(LootTable),Boss)
    end

    // If enabled then we notify all the Players that the boss got defeated
    if zpn.config.Boss.Notify.Enabled then
        for k, v in pairs(zclib.Player.List) do
            if IsValid(v) and v:Alive() then
                zclib.Notify(v, zpn.config.Boss.Notify.notify_death, 0)

				if zpn.config.Boss.Notify.chatprint then
					v:ChatPrint(zpn.config.Boss.Notify.notify_death)
				end
            end
        end
    end

    hook.Run("zpn_OnBossKilled", Boss, Boss.DamageReport)

    // Remove Enemy
    SafeRemoveEntityDelayed(Boss,3.3)
end
////////////////////////////////////////////
////////////////////////////////////////////






////////////////////////////////////////////
///////////////// ATTACK //////////////////
////////////////////////////////////////////

// Throws exploding bombkins at players
function zpn.Boss.Attack_PumpkinBombs(Boss)
    zclib.Debug("Boss_Attack_PumpkinBombs")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

    zpn.Boss.SetState(Boss,1)

    zpn.Animation.Play(Boss,zpn.Theme.Boss.anim["attack_spell"], 2)

    Boss:EmitSound("zpn_boss_spell")


    local delay = 0.1

    for i = 1, zpn.config.Boss.Bombs.Count do
        timer.Simple(delay, function()
            if IsValid(Boss) then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

                local randomAngle = math.random(1000)

                local BombPos = Boss:GetPos()
                local InnerCircleRadius = math.random(50,100)
                BombPos = BombPos + Vector(math.cos(randomAngle) * InnerCircleRadius, math.sin(randomAngle) * InnerCircleRadius, math.random(300,400))

                local rndPlayer = Boss.Targets[math.random(#Boss.Targets)]
                if IsValid(rndPlayer) and rndPlayer:Alive() and zclib.util.InDistance(Boss:GetPos(), rndPlayer:GetPos(), 1000) then
                    local ent = ents.Create("zpn_bomb")
                    ent:SetPos(BombPos)
					ent.BombShooter = Boss
                    ent.FlyDirection = (rndPlayer:GetPos() + Vector(0,0,120)) - BombPos
                    ent:Spawn()
                    ent:Activate()
                end
            end
        end)
        delay = delay + 0.25
    end



    zpn.Boss.NextAction(Boss,1.6,false)
end

// Spawns PumpkinMonsters arround the boss
function zpn.Boss.Attack_SpawnMinions(Boss)
    zclib.Debug("Boss_Attack_SpawnMinions")

    zpn.Boss.SetState(Boss,1)

    zpn.Animation.Play(Boss, zpn.Theme.Boss.anim["attack_spell"], 2)

    Boss:EmitSound("zpn_boss_spell")

    timer.Simple(1, function()
        if not IsValid(Boss) then return end
        local delay = 0.1

        for i = 1, zpn.config.Boss.Minions.Count do
            timer.Simple(delay, function()
                if not IsValid(Boss) then return end
                zpn.Boss.SpawnMinion(Boss)
            end)

            delay = delay + 0.5
        end
    end)

    zpn.Boss.NextAction(Boss,1.6,false)
end

// Plays a dance animation with fire shooting from the sky
function zpn.Boss.Attack_FireDance(Boss)
    zclib.Debug("Boss_Attack_FireDance")

    zpn.Animation.Play(Boss, zpn.Theme.Boss.anim["attack_spell"], 2)

    Boss:EmitSound("zpn_boss_spell")


    local delay = 0.1
    for i = 1, zpn.config.Boss.FireRain.Count do
        timer.Simple(delay, function()
            if IsValid(Boss) then

                local rndPos = Boss:GetPos()
                local randomAngle = math.random(1000)
                local circleRadius = math.random(150,900)
                rndPos = rndPos + Vector(math.cos(randomAngle) * circleRadius, math.sin(randomAngle) * circleRadius, math.random(700, 800))
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

                zpn.Boss.SpawnFireball(Boss,rndPos,Vector(0,0,-1),true)
            end
        end)
        delay = delay + 0.25
    end

    if zpn.config.Boss.FireRain.AimedMeteors then
        for k, v in pairs(Boss.Targets) do
            if IsValid(v) and v:Alive() and zclib.util.InDistance(Boss:GetPos(), v:GetPos(), 1000) then
                local randomAngle = math.random(1000)

                local MeteorPos = Boss:GetPos()
                local InnerCircleRadius = math.random(50,100)
                MeteorPos = MeteorPos + Vector(math.cos(randomAngle) * InnerCircleRadius, math.sin(randomAngle) * InnerCircleRadius, 500)

                zpn.Boss.SpawnFireball(Boss,MeteorPos, (v:GetPos() + Vector(0, 0, 55)) - MeteorPos)
            end
        end
    end
    zpn.Boss.NextAction(Boss,1.6,false)
end

// Plays a smash ground animation
function zpn.Boss.Attack_Smash(Boss)
    zclib.Debug("Boss_Attack_Smash")

    local impactPos = Boss:GetPos()

    local target = zpn.Boss.GetCloseTarget(Boss)
    if IsValid(target) then
        // Get the Direction of the Target
        impactPos = target:GetPos() - Boss:GetPos()
        impactPos = impactPos:Angle()

        // Restrict the Impact pos to the maximal distance the Boss can hit
        impactPos = Boss:GetPos() + impactPos:Forward() * 250
    else

        // Get Random Impact Position
        impactPos = Boss:GetPos()
        local randomAngle = math.random(1000)
        local circleRadius = 175
        impactPos = impactPos + Vector(math.cos(randomAngle) * circleRadius, math.sin(randomAngle) * circleRadius, 0)
    end

    Boss:SetTargetPos(impactPos)

    zpn.Boss.SetState(Boss,2)

    zpn.Animation.Play(Boss,zpn.Theme.Boss.anim["attack_smash"], 1)

    Boss:EmitSound("zpn_boss_smash")

    timer.Simple(0.8,function()
        if IsValid(Boss) then

            zpn.Boss.SmashImpact(Boss,1.25,impactPos)
        end
    end)

    zpn.Boss.NextAction(Boss,1.6)
end

// Plays a circlar smash ground animation
function zpn.Boss.Attack_CircularSmash(Boss)
    zclib.Debug("Boss_Attack_CircularSmash")

    zpn.Boss.SetState(Boss,1)

    zpn.Animation.Play(Boss, zpn.Theme.Boss.anim["attack_circlesmash"], 1)

    Boss:EmitSound("zpn_boss_howl_slow")

    timer.Simple(1.6,function()
        if IsValid(Boss) then

            local delay = 0.1

            for i = 1, 6 do
                timer.Simple(delay, function()
                    if IsValid(Boss) then

                        local rndPos = Boss:GetPos()
                        local randomAngle = 30 * i
                        local circleRadius = 300
                        rndPos = rndPos + Vector(math.cos(randomAngle) * circleRadius, math.sin(randomAngle) * circleRadius, 1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

                        zpn.Boss.SmashImpact(Boss,1.4,rndPos)
                    end
                end)

                delay = delay + 0.25
            end
        end
    end)

    zpn.Boss.NextAction(Boss,4.3)
end
////////////////////////////////////////////
////////////////////////////////////////////




////////////////////////////////////////////
///////////////// MINIONS //////////////////
////////////////////////////////////////////
// Spawns a Minion
function zpn.Boss.SpawnMinion(Boss)

    // Check here to see if we reached our max minion count
    if table.Count(Boss.Minions) >= zpn.config.Boss.Minions.Count then return end

    local rndPos = Boss:GetPos() + Vector(0, 0, math.random(100,200))
    local randomAngle = math.random(0,360)
    local circleRadius = math.random(300,400)
    rndPos = rndPos + Vector(math.cos(randomAngle) * circleRadius, math.sin(randomAngle) * circleRadius, 1)


    // Check if a minion is in distance
    local InDistance = false
    for k,v in pairs(ents.FindInSphere(rndPos,100)) do
        if IsValid(v) and v:GetClass() == "zpn_minion" then
            InDistance = true
            break
        end
    end

    if InDistance == true then return end

    local ent = ents.Create("zpn_minion")
    ent:SetPos(rndPos)
    ent:Spawn()
    ent:Activate()
    table.insert(Boss.Minions,ent)

    // Makes sure the minion knows his boss so it can remove itself from the Boss.Minions Table
    ent.Boss = Boss
end

// Removes all the Minions
function zpn.Boss.RemoveMinions(Boss)
    if Boss.Minions then
        for k, v in pairs(Boss.Minions) do
            if IsValid(v) then
                v:Remove()
            end
        end
    end
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
///////////////// Utility //////////////////
////////////////////////////////////////////
// Spawns a fireball
function zpn.Boss.SpawnFireball(Boss,pos,dir,createfire)
    local ent = ents.Create("zpn_fireball")
    ent:SetPos(pos)
	ent.FireballShooter = Boss
    ent.FlyDir = dir

    // If its allowed by the config then we allow the creation of firepits if defined by the function
    if zpn.config.Boss.FireRain.FirepitOnDeath then
        ent.CreateFire = createfire
    end

    ent:Spawn()
    ent:Activate()
end

util.AddNetworkString("zpn_Boss_SmashImpact_net")
function zpn.Boss.SmashImpact(Boss,scale,pos)

    // Creates all of the visuals on client
    net.Start("zpn_Boss_SmashImpact_net")
    net.WriteEntity(Boss)
    net.WriteVector(pos)
    net.WriteFloat(scale)
    net.Broadcast()

    // Screenshake
    // Needs to be on SERVER to work probably with fading distance?
    util.ScreenShake(pos, 500 * scale, 0.1, 0.9, 1000 * scale)

    // Damage
    local d = DamageInfo()
    d:SetDamage( zpn.config.Boss.CloseRangeAttack.Damage )
    d:SetAttacker( Boss )
    d:SetDamageType( DMG_CRUSH )

    for k, v in pairs(Boss.Targets) do
        if IsValid(v) and v:Alive() and zclib.util.InDistance(pos, v:GetPos(), 150 * scale) then

            v.zpn_ImpactHit_Strenght = 25
            v.zpn_ImpactHit_Dir = v:GetPos() - pos
            v.zpn_ImpactHit = true
            v:TakeDamageInfo( d )
        end
    end
end

// Gets the closed targets to the Boss
function zpn.Boss.GetCloseTarget(Boss)

    local nearestEnt
    local lastDist = 999999

    for i, entity in pairs(Boss.Targets) do
        if IsValid(entity) and entity:IsPlayer() and entity:Alive() and zclib.util.InDistance(Boss:GetPos(), entity:GetPos(), 600) then
            local dist = entity:GetPos():Distance(Boss:GetPos())

            if dist < lastDist then

                nearestEnt = entity
                lastDist = dist
            end
        end
    end

    return nearestEnt
end

// Returns a table of all currently targets in distance
function zpn.Boss.GetTargets(Boss)
    zclib.Debug("zpn.Boss.GetTargets")
    local targets = {}
    local m_pos = Boss:GetPos()

    for k, v in pairs(zclib.Player.List) do
		if not IsValid(v) then continue end
		if not v:Alive() then continue end
		if not zclib.util.InDistance(m_pos, v:GetPos(), 1000) then continue end
		if zpn.config.Boss.AttackBlackList[zclib.Player.GetRank(v)] then continue end

		// We dont attack the player if he wears the friendlymode mask
		if zpn.Mask.GetMonsterFriend(v) then continue end

        table.insert(targets, v)
    end

    Boss.Targets = targets

    return targets
end

// Checks if the player is near a Boss enemy
function zpn.Boss.EntityInDistance(ent)
    local InDistance = false
    local entPos = ent:GetPos()
    for k,v in pairs(zpn.SpawnedBoss) do
        if IsValid(v) and zclib.util.InDistance(entPos, v:GetPos(), 1500) then
            InDistance = true
            break
        end
    end
    return InDistance
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
///////////////// SAVE /////////////////////
////////////////////////////////////////////

zpn.BossPositions = zpn.BossPositions or {}

concommand.Add("zpn_boss_showspawns", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zpn.Boss.ShowSpawnHints(ply)
    end
end)

concommand.Add("zpn_boss_save", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) and zclib.STM.Save("zpn_boss") then
        zclib.Notify(ply, "All boss positions got saved for " .. string.lower(game.GetMap()), 0)
        zclib.Notify(ply, "Changes will take effect after map restart.", 0)
    end
end)

concommand.Add( "zpn_boss_remove", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        //zpn.Boss.Remove()
        zclib.STM.Remove("zpn_boss")
    end
end )

concommand.Add( "zpn_boss_kill", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        for k, v in pairs(ents.FindByClass("zpn_boss")) do
            if IsValid(v) then
                zpn.Boss.Death(v)
            end
        end
    end
end )

concommand.Add("zpn_boss_spawn", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        local tr = util.TraceLine({
            start = ply:EyePos() + ply:EyeAngles():Forward() * 100,
            endpos = ply:EyePos() + ply:EyeAngles():Forward() * 1000
        })

        if tr.Hit and tr.HitPos then
            local ent = ents.Create("zpn_boss")
            local angle = ply:GetAimVector():Angle()
            angle = Angle(0, angle.yaw, 0)
            ent:SetAngles(angle)
            ent:SetPos(tr.HitPos)
            ent:Spawn()
            ent:Activate()
        end
    end
end)

concommand.Add("zpn_boss_respawn", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zpn.Boss.ReSpawn()
    end
end)

// Setsup the saving / loading and removing of the entity for the map
zclib.STM.Setup("zpn_boss","zpn/" .. string.lower(game.GetMap()) .. "_bossspawns" .. ".txt",function()
    local data = {}

    // Lets load in the existing positions
    for k,v in pairs(zpn.BossPositions) do
        if v then
            table.insert(data, {
                pos = v.pos,
                ang = v.ang
            })
        end
    end

    for u, j in pairs(ents.FindByClass("zpn_boss")) do
        if IsValid(j) then
            local InDistance = false
            for k,v in pairs(zpn.BossPositions) do
                if v and zclib.util.InDistance(v.pos, j:GetPos(), 200) then
                    InDistance = true
                    break
                end
            end
            if InDistance == true then continue end

            table.insert(data, {
                pos = j:GetPos(),
                ang = j:GetAngles()
            })
        end
    end

    return data
end,function(data)
    zpn.BossPositions = {}
    zpn.BossPositions = table.Copy(data)
    zpn.Print("Finished loading Boss Positions.")
end,function()
    for k, v in pairs(ents.FindByClass("zpn_boss")) do
        if IsValid(v) then
            v:Remove()
        end
    end
    zpn.BossPositions = {}
end)




////////////////////////////////////////////
//////////////// AUTOSPAWN /////////////////
////////////////////////////////////////////

timer.Simple(1,function()
    zpn.Boss.StartAutoSpawn()
end)

function zpn.Boss.StartAutoSpawn()
    zclib.Timer.Remove("zpn_Boss_AutoSpawner")
    zclib.Timer.Create("zpn_Boss_AutoSpawner",zpn.config.Boss.AutoSpawn.Interval,0,function()
		zpn.Boss.ReSpawn()
    end)
end

function zpn.Boss.ReSpawn()
	if table.Count(zpn.SpawnedBoss) >= zpn.config.Boss.AutoSpawn.Limit then return end

	local ValidPositions = {}
	for k,v in pairs(zpn.BossPositions) do
		if v == nil or v.pos == nil or v.ang == nil then continue end
		if IsValid(v.ent) then continue end
		table.insert(ValidPositions,k)
	end

	local Used = {}
	for k,v in pairs(ValidPositions) do

		// If the boss limit is reached then stop and wait till some boss did die
		if table.Count(zpn.SpawnedBoss) >= zpn.config.Boss.AutoSpawn.Limit then
			break
		end

		if Used[v] then continue end

		if math.random(0,100) < zpn.config.Boss.AutoSpawn.Chance then

			local SpawnData = zpn.BossPositions[v]
			if not SpawnData then continue end

			Used[v] = true

			local ent = ents.Create("zpn_boss")
			ent:SetPos(SpawnData.pos)
			ent:SetAngles(SpawnData.ang)
			ent:Spawn()
			ent:Activate()

			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:Wake()
				phys:EnableMotion(false)
			end

			SpawnData.ent = ent
		end
	end
end
////////////////////////////////////////////
////////////////////////////////////////////

////////////////////////////////////////////
///////////////// DESPAWN //////////////////
////////////////////////////////////////////

function zpn.Boss.Despawn(Boss)
    zclib.Debug("zpn.Boss.Despawn")
	if Boss:GetActionState() == 4 then return end
    zpn.Boss.SetState(Boss,4)

    // Despawn Minions
    zpn.Boss.RemoveMinions(Boss)

    // Stop the MainLogic
    zpn.Boss.StopLogic(Boss)

    // Play death animation
    zpn.Animation.Play(Boss,zpn.Theme.Boss.anim["action_death"], 1)

    Boss:EmitSound("zpn_boss_death")

    // Kill the physics
	Boss:PhysicsDestroy()

    // Remove Enemy
    SafeRemoveEntityDelayed(Boss,3.3)
end
////////////////////////////////////////////
////////////////////////////////////////////
