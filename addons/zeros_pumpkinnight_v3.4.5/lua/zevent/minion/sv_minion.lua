/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if CLIENT then return end
zpn = zpn or {}
zpn.Minion = zpn.Minion or {}

function zpn.Minion.Initialize(Minion)
    zclib.Debug("zpn.Minion.Initialize")

    Minion:SetModel(zpn.Theme.Minions.models[math.random(#zpn.Theme.Minions.models)])

    // Give it some random orange color
    local col = zpn.Theme.Minions.getcolor()
    if col then
        Minion:SetColor(col)
    end

    // PrecacheGibs
    Minion:PrecacheGibs()

    Minion:PhysicsInit(SOLID_VPHYSICS)
    Minion:SetSolid(SOLID_VPHYSICS)
    Minion:SetMoveType(MOVETYPE_VPHYSICS)

    // If we want the minions to circle the boss then we need to setup a diffrent physic
    if zpn.config.Boss.Minions.CircleBoss then
        local phys = Minion:GetPhysicsObject()

        if IsValid(phys) then
            phys:SetMass(25)
            phys:EnableGravity(false)
            phys:EnableDrag(false)
            phys:Wake()
        else
            Minion:Remove()

            return
        end

        Minion.ShadowParams = {}
        Minion.PosOffset = math.random(0,360)

        Minion:StartMotionController()
        Minion:SetCustomCollisionCheck(true)
    else
        local phys = Minion:GetPhysicsObject()

        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(false)
        end
    end

    zclib.EntityTracker.Add(Minion)

    Minion:SetMonsterHealth(zpn.config.Boss.Minions.Health)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

    // This makes sure we dont search for a close target all the time
    Minion.NextEnemySearch = -1

    zpn.Minion.StartLogic(Minion)

    Minion.PhysgunDisabled = true
end

function zpn.Minion.OnTakeDamage(Minion, dmginfo)
    zclib.Debug("zpn.Minion.OnTakeDamage")
    if Minion:GetMonsterHealth() <= 0 then return end

    if (not Minion.m_bApplyingDamage) then
        Minion.m_bApplyingDamage = true
        Minion:TakeDamageInfo(dmginfo)

        Minion:SetMonsterHealth(math.Clamp(Minion:GetMonsterHealth() - dmginfo:GetDamage(), 0, zpn.config.Boss.Minions.Health))

        if Minion:GetMonsterHealth() <= 0 then

            hook.Run("zpn_OnMinionKilled", Minion, dmginfo:GetAttacker())

            zpn.Minion.Death(Minion)
        end

        Minion.m_bApplyingDamage = false
    end
end

function zpn.Minion.OnRemove(Minion)
    zpn.Minion.StopLogic(Minion)

    // Remove yourself from the Boss Minion list if you have a boss
    if IsValid(Minion.Boss) then
        table.RemoveByValue(Minion.Boss.Minions, Minion)
    end

    table.RemoveByValue(zpn.SpawnedMinions,Minion)
end

// Handels the movement of the Minion
function zpn.Minion.PhysicsSimulate(Minion, phys, dt)
    if zpn.config.Boss.Minions.CircleBoss == false then return end
    if not IsValid(Minion.Boss) then return end

    phys:Wake()

    local pos = Minion.Boss:GetForward() * 350 + Vector(0, 0, 200)
    pos:Rotate(Angle(0, Minion.PosOffset + (45 * RealTime()), 0))
    pos = Minion.Boss:GetPos() + pos

    Minion.ShadowParams.secondstoarrive = 0.01 // How long it takes to move to pos and rotate accordingly - only if it could move as fast as it want - damping and max speed/angular will make this invalid ( Cannot be 0! Will give errors if you do )
    Minion.ShadowParams.pos = pos // Where you want to move to
    Minion.ShadowParams.angle = Angle(0, 0, 0) // Angle you want to move to
    Minion.ShadowParams.maxangular = 5000 //What should be the maximal angular force applied
    Minion.ShadowParams.maxangulardamp = 10000 // At which force/speed should it start damping the rotation
    Minion.ShadowParams.maxspeed = 1000000 // Maximal linear force applied
    Minion.ShadowParams.maxspeeddamp = 10000 // Maximal linear force/speed before damping
    Minion.ShadowParams.dampfactor = 0.8 // The percentage it should damp the linear/angular force if it reaches it's max amount
    Minion.ShadowParams.teleportdistance = 200 // If it's further away than this it'll teleport ( Set to 0 to not teleport )
    Minion.ShadowParams.deltatime = dt // The deltatime it should use - just use the PhysicsSimulate one

    phys:ComputeShadowControl(Minion.ShadowParams)
end


function zpn.Minion.StartLogic(Minion)
    zclib.Debug("zpn.Minion.StartLogic")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    local timerid = "MonsterEnemy_" .. Minion:EntIndex() .. "_logictimer"
    zclib.Timer.Create(timerid,zpn.config.Boss.Minions.Shoot.Interval,0,function()
        if IsValid(Minion) then
            zpn.Minion.MainLogic(Minion)
        end
    end)
end

function zpn.Minion.StopLogic(Minion)
    zclib.Debug("zpn.Minion.StopLogic")

    local timerid = "MonsterEnemy_" .. Minion:EntIndex() .. "_logictimer"
    zclib.Timer.Remove(timerid)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000


function zpn.Minion.MainLogic(Minion)
    zclib.Debug("zpn.Minion.MainLogic")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

    local target = Minion:GetPlayerTarget()

    // This just researches for a close target every 20 seconds if there is a target closer then the current one
    if Minion.NextEnemySearch < CurTime() then
        Minion.NextEnemySearch = CurTime() + 20

        // Search for new Close Target
        zpn.Minion.SearchForCloseTarget(Minion)
    end

    if IsValid(target) and zclib.util.InDistance(Minion:GetPos(), target:GetPos(), 800) then
        zclib.Debug("Minion Attack!")

        // Attack
        local targetPos = target:GetPos() + Vector(0,0,55)
        local dir = targetPos - Minion:GetPos()
        local fireball = ents.Create("zpn_fireball")
        fireball:SetPos(Minion:GetPos() + dir:Angle():Forward() * 25)
		fireball.FireballShooter = Minion
        fireball.FlyDir = dir
        fireball.dmg = zpn.config.Boss.Minions.Shoot.Damage
        fireball:Spawn()
        fireball:Activate()
    else
		// 1235078258
        // Search for new Close Target
        zpn.Minion.SearchForCloseTarget(Minion)
    end
end

function zpn.Minion.SearchForCloseTarget(Minion)
    local CloseTarget = zpn.Minion.FindNearestTarget(Minion)

    if IsValid(CloseTarget) then

        // Check if the player is not behind some wall
        local tr = util.TraceLine( {
        	start = Minion:GetPos(),
            endpos = CloseTarget:GetPos(),
            mask = MASK_SOLID_BRUSHONLY,
        	//filter = function( ent ) if ( ent:GetClass() == "prop_physics" ) then return true end end
        } )

        // Checks if there is no world brush between the Monster and Player
        if tr.Hit == false then

            Minion:SetPlayerTarget(CloseTarget)
        else
            Minion:SetPlayerTarget(nil)
        end
    else
        Minion:SetPlayerTarget(nil)
    end
end

// Gets the closest valid Player
function zpn.Minion.FindNearestTarget(Minion)
    zclib.Debug("zpn.Minion.FindNearestTarget")

    local nearestEnt
    local lastDist = 999999

    for i, entity in pairs(zclib.Player.List) do

		if not IsValid(entity) then continue end
		if not entity:IsPlayer() then continue end
		if not entity:Alive() then continue end
		if not zclib.util.InDistance(Minion:GetPos(), entity:GetPos(), 800) then continue end

		// We dont attack the player if he wears the friendlymode mask
		if zpn.Mask.GetMonsterFriend(entity) then continue end

		local dist = entity:GetPos():Distance(Minion:GetPos())
		if dist < lastDist then
			nearestEnt = entity
			lastDist = dist
		end
    end

    return nearestEnt
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function zpn.Minion.Death(PumpkinMonster)
    zclib.Debug("zpn.Minion.Death")

    // Stop the MainLogic
    zpn.Minion.StopLogic(PumpkinMonster)

    // Set invisible
    PumpkinMonster:SetNoDraw(true)

    // Death Effect, Effect + Gibs * sound
    zclib.NetEvent.Create("zpn_destructable_destroy", {PumpkinMonster})


    // Drop Candy
    local amount = math.random(zpn.config.Boss.Minions.CandyDropOnDeath.min,zpn.config.Boss.Minions.CandyDropOnDeath.max)
    local pos = PumpkinMonster:GetPos()
    local randomAngle = math.random(1000)
    local InnerCircleRadius = math.random(50,100)
    local offset = Vector(math.cos(randomAngle) * InnerCircleRadius, math.sin(randomAngle) * InnerCircleRadius, 15)

    for i = 1, amount do

        pos = PumpkinMonster:GetPos()
        randomAngle = math.random(1000)
        InnerCircleRadius = math.random(25, 60)
        offset = Vector(math.cos(randomAngle) * InnerCircleRadius, math.sin(randomAngle) * InnerCircleRadius, 15)


        local candy = ents.Create("zpn_candy")
        candy:SetPos(pos + offset)
        candy:Spawn()
        candy:Activate()
    end

    // Remove Enemy
    SafeRemoveEntityDelayed(PumpkinMonster,1)
end
