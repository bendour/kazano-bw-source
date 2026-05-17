/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if CLIENT then return end
zpn = zpn or {}
zpn.Ghost = zpn.Ghost or {}
zpn.Ghost.List = zpn.Ghost.List or {}
zpn.PumpkinsTargets = zpn.PumpkinsTargets or {}

/*
	Ghost Spawns to IDLE
	Ghost Spawns to Smash Pumpkin
	Ghost Spawns to Steal Candy from Player
*/

/*
	Initializes the Ghost entity
*/
function zpn.Ghost.Initialize(Ghost)
    zclib.Debug("zpn.Ghost.Initialize")
    Ghost:SetModel(zpn.Theme.Ghost.model)
    Ghost:PhysicsInit(SOLID_VPHYSICS)
    Ghost:SetSolid(SOLID_VPHYSICS)
    Ghost:SetMoveType(MOVETYPE_NONE)
    Ghost:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local phys = Ghost:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    end

    Ghost:UseClientSideAnimation()

    // Ghost.PhysgunDisabled = true

    zclib.EntityTracker.Add(Ghost)

    // The Health
    Ghost:SetMonsterHealth(zpn.config.Ghost.Health)

    // Disables the entity recieving any damage
    zpn.Ghost.DisableDamage(Ghost)

    // How much candy does he have collected?
    Ghost.Candy = 0

    zpn.Animation.Play(Ghost, zpn.Theme.Ghost.anim["spawn"], 1)

    // Go Hide
    timer.Simple(zpn.config.Ghost.IdleTime or 3,function()
        if IsValid(Ghost) and not zpn.Ghost.IsHunting(Ghost) then
            zpn.Ghost.HIDE(Ghost)
        end
    end)

    table.insert(zpn.Ghost.List,Ghost)
end

/*
	Gets called when the ghost getting removed
*/
function zpn.Ghost.OnRemove(Ghost)
    zpn.Ghost.StopSearch(Ghost)
    table.RemoveByValue(zpn.Ghost.List,Ghost)
end

/*
    STATES:
        0 = Hidden
        1 = Spawning
        2 = Stealing
        3 = Paralised
        4 = IDLE
		5 = Hunting Player
*/
function zpn.Ghost.SetState(Ghost,state)
    Ghost:SetActionState(state)
end

/*
	Starts the search Timer
*/
function zpn.Ghost.SearchTarget(Ghost)
    // Stop the timer if he allready exists
    zpn.Ghost.StopSearch(Ghost)

    // Check every x seconds if we can find a valid target
    local timerid = "Ghost_" .. Ghost:EntIndex() .. "_logictimer"
    zclib.Timer.Create(timerid,zpn.config.Ghost.Action_Interval,0,function()

        if IsValid(Ghost) then

            if zpn.config.Ghost.Targets.Players == true and zpn.config.Ghost.Targets.Destructables == true then

                if zclib.util.RandomChance(60) then
                    zpn.Ghost.FindPumpkinToSteal(Ghost)
                else
                    zpn.Ghost.FindPlayerToStealCandy(Ghost)
                end
            else

                if zpn.config.Ghost.Targets.Players then
                    zpn.Ghost.FindPlayerToStealCandy(Ghost)
                elseif zpn.config.Ghost.Targets.Destructables then
                    zpn.Ghost.FindPumpkinToSteal(Ghost)
                end
            end
        end
    end)
end

/*
	Stops the search Timer
*/
function zpn.Ghost.StopSearch(Ghost)
    //zclib.Debug("zpn.Ghost.StopSearch")

    local logic_timerid = "Ghost_" .. Ghost:EntIndex() .. "_logictimer"
    zclib.Timer.Remove(logic_timerid)
end

/*
	Unhides the Ghost in a buff of pink smoke
*/
function zpn.Ghost.SPAWN(Ghost,lookEnt)

    // Disable Damage receiving while spawning
    zpn.Ghost.DisableDamage(Ghost)

    // Set pos of ghost near entity
    local pos = lookEnt:GetPos() + lookEnt:GetForward() * 50 + Vector(0,0,10)

    // Give us a accurate position for the Ghost to spawn on
    local tr = util.TraceLine({
        start = pos + Vector(0,0,10),
        endpos = pos - Vector(0, 0, 100000),
        filter = function(ent)
            if (ent:IsWorld()) then return true end
        end
    })
    if tr.Hit and tr.HitPos then
        pos = Vector(tr.HitPos)
    end

    Ghost:SetPos(pos)

    Ghost:EmitSound("zpn_ghost_puff")

    // Tell Ghost where to look at
    Ghost:SetTargetPos(lookEnt:GetPos())
    local dir = lookEnt:GetPos() - Ghost:GetPos()
    local newAngle = dir:Angle()
    Ghost:SetAngles(Angle(0,newAngle.y,0))

    // Change state to spawning
    zpn.Ghost.SetState(Ghost,1)

    // Make ghost visible
    Ghost:SetNoDraw(false)

    timer.Simple(0.1,function()
        if IsValid(Ghost) then

            // Play spawn animation
            zpn.Animation.Play(Ghost, zpn.Theme.Ghost.anim["spawn"], 1)
        end
    end)
end

/*
	Hides the ghost and restarts his target finder
*/
function zpn.Ghost.HIDE(Ghost)
    zclib.Debug("Ghost_HIDE")

    zpn.Ghost.DisableDamage(Ghost)

    zpn.Ghost.SetState(Ghost,0)

    zpn.Animation.Play(Ghost, zpn.Theme.Ghost.anim["hide"], 2)

    timer.Simple(0.5,function()
        if IsValid(Ghost) then

            Ghost:EmitSound("zpn_ghost_hide")
            Ghost:SetNoDraw(true)
        end
    end)

    timer.Simple(0.75,function()
        if IsValid(Ghost) then
            Ghost:SetPos(zpn.config.Ghost.HidingPos)
        end
    end)

    zpn.Ghost.SearchTarget(Ghost)
end

/*
	Makes the ghost be idle after some time he will go hiding again
*/
function zpn.Ghost.IDLE(Ghost,time)
    zclib.Debug("Ghost_IDLE")

    zpn.Ghost.EnableDamage(Ghost)
    zpn.Ghost.SetState(Ghost,4)

    zpn.Animation.Play(Ghost, zpn.Theme.Ghost.anim["idle"], 2)

    timer.Simple(time,function()
        if IsValid(Ghost) then
            if zpn.Ghost.IsParalized(Ghost) then return end
			if zpn.Ghost.IsHunting(Ghost) then return end
            zpn.Ghost.HIDE(Ghost)
        end
    end)
end

/*
	Despawns the ghost
*/
function zpn.Ghost.Death(Ghost)
    zclib.Debug("zpn.Ghost.Death")

    // Set state to hidden
    zpn.Ghost.SetState(Ghost,0)

    // Disable damage receive
    zpn.Ghost.DisableDamage(Ghost)

    // Stop the MainLogic
    zpn.Ghost.StopSearch(Ghost)

    // Play death animation
    zpn.Animation.Play(Ghost, zpn.Theme.Ghost.anim["death"], 1)

    if Ghost.Candy > 0 then
        // Spawn the candy
        local count = 3
        local candyPerEnt = math.Round(Ghost.Candy / 3)
        for i = 1, count do

            local randomAngle = math.random(1000)

            local CandyPos = Ghost:GetPos()
            local CircleRadius = math.random(50,100)
            CandyPos = CandyPos + Vector(math.cos(randomAngle) * CircleRadius, math.sin(randomAngle) * CircleRadius, math.random(50,100))

            local ent = ents.Create("zpn_candy")
            ent:SetPos(CandyPos)
            ent:SetModel("models/zerochain/props_pumpkinnight/zpn_candydrop.mdl")
            ent:Spawn()
            ent:Activate()
            ent:SetCandy(candyPerEnt)
            ent:SetDisplayCandy(true)
            ent:SetModel("models/zerochain/props_pumpkinnight/zpn_candydrop.mdl")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

            // Give it some random orange color
            ent:SetColor(HSVToColor(math.random(28,42),0.7,1))
        end
    end

    // Remove Enemy
    SafeRemoveEntityDelayed(Ghost,2)

    if zpn.config.Ghost.Rebirth then
        timer.Simple(5,function()
            zpn.Ghost.Rebirth()
        end)
    end
end

/*
	Spawns the ghost
*/
function zpn.Ghost.Rebirth()
    zclib.Debug("Ghost: A new Ghost has spawned!")
    local ent = ents.Create("zpn_ghost")
    ent:SetPos(zpn.config.Ghost.HidingPos)
    ent:Spawn()
    ent:Activate()
end

/*
	Spawn a ghost on mapload
*/
timer.Simple(2,function()
    if zpn.config.Ghost.SpawnOnMapLoad then
        zpn.Ghost.Rebirth()
    end
end)

/*
	Spawn a ghost PostCleanup
*/
zclib.Hook.Add("PostCleanupMap", "zpn_SpawnGhosts", function()
    if zpn.config.Ghost.SpawnOnMapLoad then
        zpn.Ghost.Rebirth()
    end
end)



////////////////////////////////////////////
//////// Steal Candy from Player ///////////
////////////////////////////////////////////
/*
	Checks if the player is valid to steal candy from
*/
function zpn.Ghost.IsValidPlayer(ply,stealAmount,cooldowncheck,ongroundcheck)
    // Is the Player Entity Valid?
    if not IsValid(ply) then
        return false
    end

    // Is the Player alive?
    if not ply:Alive() then
        return false
    end

	// We dont attack the player if he wears the friendlymode mask
	if zpn.Mask.GetMonsterFriend(ply) then return false end

    // Is the Players rank not blacklisted?
    if zpn.config.Ghost.BlackList[zclib.Player.GetRank(ply)] then
        return false
    end

    // Is the Player not in a vehicle?
    if ply:InVehicle() then
        return false
    end

    // Is the Player on the ground?
    if ongroundcheck and ply:OnGround() == false then
        return false
    end

    // Does the Player have enough candy to steal?
    if zpn.Candy.ReturnPoints(ply) < stealAmount then
        return false
    end

    // Does this player have a cooldown?
    if cooldowncheck and ply.zpn_GhostAttackCooldown and CurTime() < ply.zpn_GhostAttackCooldown then
        zclib.Debug("Ghost_IsValidPlayer: Player has AttackCooldown!")
        return false
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

    // Does the Player allready get robbed by a ghost?
    if IsValid(ply.zpn_Ghost) then
        zclib.Debug("Ghost_IsValidPlayer: Player allready gets robbed by other Ghost!")
        return false
    end

    // Is the PLayer currently interacting with the shop npc?
    if ply.zpn_InShop and ply.zpn_InShop == true then
        return false
    end

    // Is the player near a Anti Ghost sign?
    if zpn.Sign.EntityInDistance(ply) then
        zclib.Debug("Ghost_IsValidPlayer: Player is near a Anti Ghost Sign!")

        return false
    end

    // Is the player near a Boss enemy?
    if zpn.Boss.EntityInDistance(ply) then
        zclib.Debug("Ghost_IsValidPlayer: Player is near a Boss Enemy!")

        return false
    else

        return true
    end
end

/*
	Gets all players which can be stolen candy from
*/
function zpn.Ghost.GetValidPlayers(Ghost, stealAmount)
    local tbl = {}

    for k, v in pairs(zclib.Player.List) do
        if zpn.Ghost.IsValidPlayer(v, stealAmount,true,true) then
            table.insert(tbl, v)
        end
    end

    return tbl
end

/*
	Checks if the player is near the ghosts arms
*/
function zpn.Ghost.IsTargetInRange(Ghost,Target)
	local result = Ghost:LocalToWorld(Vector(70,0,5)):Distance(Target:GetPos()) < 70
	debugoverlay.Sphere( Ghost:LocalToWorld(Vector(70,0,5)), 70, 3,  result and Color( 0, 255, 0 ,25) or Color( 255, 0, 0 ,25), false )
	return result
end

/*
	Finds a valid Player to steal candy from
*/
function zpn.Ghost.FindPlayerToStealCandy(Ghost)

    local stealAmount = math.random(zpn.config.Ghost.Steal.min,zpn.config.Ghost.Steal.max)
    local validplayers = zpn.Ghost.GetValidPlayers(Ghost,stealAmount)
    local ply = validplayers[math.random(#validplayers)]

    if zpn.Ghost.IsValidPlayer(ply,stealAmount,true,true) then

        zpn.Ghost.StopSearch(Ghost)

        zpn.Ghost.StartStealCandy(Ghost,ply,stealAmount)
    end
end

/*
	Starts the Candy steal action
*/
function zpn.Ghost.StartStealCandy(Ghost,ply,candy)
    zclib.Debug("Ghost_StartStealCandy")

    // Warn the Player
    ply:EmitSound("zpn_ghost_warn")

    // Writes down when the ghost is allowed to attack this player again
    ply.zpn_GhostAttackCooldown = CurTime() + zpn.config.Ghost.PlayerAttack_Cooldown

    // Steal Candy from Player
    timer.Simple(1, function()
        if not IsValid(Ghost) then
			return
		end
        if zpn.Ghost.IsValidPlayer(ply,candy,false,false) then

            // Spawn
            zpn.Ghost.SPAWN(Ghost,ply)

            // Steal Candy from Player
            timer.Simple(0.6, function()
                if not IsValid(Ghost) then return end

				if zpn.Ghost.IsHunting(Ghost) then return end

                if zpn.Ghost.IsParalized(Ghost) then return end

                zpn.Ghost.StealCandy(Ghost,ply,candy)
            end)
        else
            zpn.Ghost.SearchTarget(Ghost)
        end
    end)
end

/*
	Steal the Candy from the Player
*/
function zpn.Ghost.StealCandy(Ghost,ply,candy)

	// Is the player still in range?
	if not zpn.Ghost.IsTargetInRange(Ghost,ply) then
		// Go IDLE for a bit
        zpn.Ghost.IDLE(Ghost,math.random(zpn.config.Ghost.IdleTime or 3))
		return
	end

    // Is the player still valid and alive?
    if not zpn.Ghost.IsValidPlayer(ply,candy,false,false) then

        // Go IDLE for a bit
        zpn.Ghost.IDLE(Ghost,math.random(zpn.config.Ghost.IdleTime or 3))
        return
    end

    zclib.Debug("zpn.Ghost.StealCandy")

    zpn.Ghost.EnableDamage(Ghost)

    zpn.Ghost.SetState(Ghost,2)

	// If the player had the ghost protection then the ghost wont attack
	if zpn.Mask.HasGhostProtection(ply) then

		zpn.Mask.ReduceUses(ply, 1)
		zpn.Ghost.IDLE(Ghost,math.random(zpn.config.Ghost.IdleTime or 3))
		return
	end

	zpn.Animation.Play(Ghost, zpn.Theme.Ghost.anim["steal"], 1.5)

    timer.Simple(0.43, function()

        if not IsValid(Ghost) then return end
        if Ghost:GetMonsterHealth() <= 0 then return end
        if zpn.Ghost.IsParalized(Ghost) then return end

        // Does the Player still exist?
        if IsValid(ply) and ply:Alive() and zclib.util.InDistance(Ghost:GetPos(), ply:GetPos(), 175) then

            // Add candy to ghost
            Ghost.Candy = Ghost.Candy + candy

            // Take candy from player and notify him
            zpn.Candy.TakePoints(ply,candy)
            zpn.Candy.Notify(ply,-candy)
			Ghost:EmitSound("zpn_candy_collect")

            // Recover some health
            Ghost:SetMonsterHealth(math.Clamp(Ghost:GetMonsterHealth() + (zpn.config.Ghost.Health * zpn.config.Ghost.Health_OnSuccess), 0, zpn.config.Ghost.Health))

            // Push player
            ply.zpn_ImpactHit_Strenght = 5
            ply.zpn_ImpactHit_Dir = ply:GetPos() - Ghost:GetPos()
            ply.zpn_ImpactHit = true

            timer.Simple(0.4, function()
                if not IsValid(Ghost) then return end
                if Ghost:GetMonsterHealth() <= 0 then return end
                if zpn.Ghost.IsParalized(Ghost) then return end

                zpn.Ghost.HIDE(Ghost)
            end)
        else

            // Go IDLE for a bit
            zpn.Ghost.IDLE(Ghost,math.random(zpn.config.Ghost.IdleTime or 3))
        end
    end)
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
/////////// Steal Pumpkin //////////////////
////////////////////////////////////////////
function zpn.Ghost.GetRandomPumpkinTarget()
	local list = {}

	for k, v in pairs(zpn.PumpkinsTargets) do
		if not IsValid(v) then continue end
		if zpn.Sign.EntityInDistance(v) then continue end
		if v.zpn_GhostAttackCooldown and v.zpn_GhostAttackCooldown > CurTime() then continue end
		table.insert(list, v)
	end

	return list[ math.random(#list) ]
end

// Finds a valid pumpkin to steal
function zpn.Ghost.FindPumpkinToSteal(Ghost)
    local pumpkin = zpn.Ghost.GetRandomPumpkinTarget()
    if IsValid(pumpkin) then

        // Remove from target list
        table.RemoveByValue(zpn.PumpkinsTargets, pumpkin)

        // If the pumpkin is still alive after attack then we reAdd it to the target list
        timer.Simple(4,function()
            if IsValid(pumpkin) then
                table.insert(zpn.PumpkinsTargets, pumpkin)
            end
        end)

        zpn.Ghost.StopSearch(Ghost)

        zpn.Ghost.StartStealPumpkin(Ghost,pumpkin)
    end
end

// Starts the Pumpkin steal action
function zpn.Ghost.StartStealPumpkin(Ghost,Pumpkin)
    zclib.Debug("Ghost_StartStealPumpkin")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    // Spawn
    zpn.Ghost.SPAWN(Ghost,Pumpkin)

    // Steal Pumpkin
    timer.Simple(0.6, function()
        if not IsValid(Ghost) then return end
		if zpn.Ghost.IsHunting(Ghost) then return end
        if zpn.Ghost.IsParalized(Ghost) then return end
        zpn.Ghost.StealPumpkin(Ghost,Pumpkin)
    end)
end

// Steal the Pumpkin
function zpn.Ghost.StealPumpkin(Ghost,Pumpkin)

	if zpn.Ghost.IsHunting(Ghost) then return end

    // Does the Pumpkin still exist?
    if not IsValid(Pumpkin) or (IsValid(Pumpkin) and Pumpkin.Smashed ) then
        // Go IDLE for a bit
        zpn.Ghost.IDLE(Ghost,math.random(zpn.config.Ghost.IdleTime or 3))
        return
    end

    zclib.Debug("zpn.Ghost.StealPumpkin")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	// The pumpkins will be ignored for the next 5 seconds
	Pumpkin.zpn_GhostAttackCooldown = CurTime() + 5

    zpn.Ghost.EnableDamage(Ghost)

    zpn.Ghost.SetState(Ghost,2)

    Ghost:SetTargetPos(Pumpkin:GetPos())

    zpn.Animation.Play(Ghost, zpn.Theme.Ghost.anim["steal"], 1.5)

    timer.Simple(0.43, function()

        if not IsValid(Ghost) then return end
        if Ghost:GetMonsterHealth() <= 0 then return end
        if zpn.Ghost.IsParalized(Ghost) then return end
		if zpn.Ghost.IsHunting(Ghost) then return end

        // Does the Pumpkin still exist?
        if IsValid(Pumpkin) and Pumpkin.Smashed == false then

            // Smash it!
            zpn.Destructable.Destroy(Pumpkin)
            zclib.Debug("zpn.Destructable.Destroy")

            // Give him the candy
            Ghost.Candy = Ghost.Candy + math.random(5,10)
            Ghost:EmitSound("zpn_candy_collect")

            // Recover some health
            Ghost:SetMonsterHealth(math.Clamp(Ghost:GetMonsterHealth() + (zpn.config.Ghost.Health * zpn.config.Ghost.Health_OnSuccess), 0, zpn.config.Ghost.Health))

            timer.Simple(0.4, function()
                if not IsValid(Ghost) then return end
                if Ghost:GetMonsterHealth() <= 0 then return end
                if zpn.Ghost.IsParalized(Ghost) then return end
				if zpn.Ghost.IsHunting(Ghost) then return end

                zpn.Ghost.IDLE(Ghost,math.random(zpn.config.Ghost.IdleTime or 3))
            end)
        else

            // Go IDLE for a bit
            zpn.Ghost.IDLE(Ghost,math.random(zpn.config.Ghost.IdleTime or 3))
        end
    end)
end
////////////////////////////////////////////
////////////////////////////////////////////


////////////////////////////////////////////
////////////////// Damage //////////////////
////////////////////////////////////////////
// Makes the entity receive damage
function zpn.Ghost.EnableDamage(Ghost)
    zclib.Debug("Ghost_EnableDamage")
    Ghost.Immortal = false
end

// Makes the entity not receive any damage
function zpn.Ghost.DisableDamage(Ghost)
    zclib.Debug("Ghost_DisableDamage")
    Ghost.Immortal = true
end

// Cancels the current Action and makes the Ghost paralized for a bit and then despawn
function zpn.Ghost.Paralize(Ghost)
    zclib.Debug("zpn.Ghost.Paralize")

    // Play Damage Animation
    zpn.Animation.Play(Ghost, zpn.Theme.Ghost.anim["hit"], 1)

    //Ghost:EmitSound("zpn_ghost_woow")

    zpn.Ghost.SetState(Ghost,3)

    timer.Simple(zpn.config.Ghost.ParalizeTime,function()
        if IsValid(Ghost) then
            if Ghost:GetActionState() == 0 then return end
            zpn.Ghost.HIDE(Ghost)
        end
    end)
end

function zpn.Ghost.IsParalized(Ghost)
    zclib.Debug("Ghost_IsParalized: " .. tostring(Ghost:GetActionState() == 3))
    return Ghost:GetActionState() == 3
end

function zpn.Ghost.OnTakeDamage(Ghost, dmginfo)
	if not dmginfo then return end
    //zclib.Debug("zpn.Ghost.OnTakeDamage")


    if Ghost:GetMonsterHealth() <= 0 then return end
    if Ghost:GetActionState() == 0 then return end

	/*
	// Can we make it such the if the ghost gets attacked while spawning then we hunt the person who did it
	local Attacker = dmginfo:GetAttacker()
	local state = Ghost:GetActionState()
	if (state == 1 or state == 2 or state == 4) and IsValid(Attacker) and Attacker:IsPlayer() then
		zpn.Ghost.HuntPlayer(Ghost, Attacker)
		return
	end
	*/

	if Ghost.Immortal == true then
		return
	end

    if not Ghost.m_bApplyingDamage then
        Ghost.m_bApplyingDamage = true

            Ghost:TakeDamageInfo(dmginfo)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

            Ghost:SetMonsterHealth(math.Clamp(Ghost:GetMonsterHealth() - dmginfo:GetDamage(), 0, zpn.config.Ghost.Health))

            if Ghost:GetMonsterHealth() <= 0 then

                hook.Run("zpn_OnGhostKilled", Ghost, dmginfo:GetAttacker())

                zpn.Ghost.Death(Ghost)
            else
                if not zpn.Ghost.IsParalized(Ghost) then
                    zpn.Ghost.Paralize(Ghost)
                end
            end
        Ghost.m_bApplyingDamage = false
    end
end
////////////////////////////////////////////
////////////////////////////////////////////


////////////////////////////////////////////
////////////////// Hunting /////////////////
////////////////////////////////////////////
function zpn.Ghost.HuntPlayer(Ghost, ply)

	Ghost.zpn_HuntTarget = ply

	zpn.Ghost.SetState(Ghost,5)

	zpn.Animation.Play(Ghost, zpn.Theme.Ghost.anim["chase"], 1.5)

	Ghost:StartMotionController()
	Ghost:SetMoveType(MOVETYPE_VPHYSICS)
	local phys = Ghost:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
		phys:EnableGravity(false)
		phys:SetDragCoefficient(100)
		phys:SetAngleDragCoefficient(1000)
	end


	local SuccessHits = math.random(4)
	local RealHits = 0
	local FailedHits = 0

	local timerID = "zpn_ghost_chase_" .. Ghost:EntIndex()
	zclib.Timer.Remove(timerID)
	zclib.Timer.Create(timerID,1,0,function()

		if not IsValid(ply) or not ply:Alive() or RealHits >= SuccessHits or FailedHits > 10 then
			zpn.Ghost.StopHunting(Ghost)
			zpn.Ghost.HIDE(Ghost)
			zclib.Timer.Remove(timerID)
			return
		end

		if not IsValid(Ghost) then
			zclib.Timer.Remove(timerID)
			return
		end

		// Is the ghost near the player?
		if zpn.Ghost.IsTargetInRange(Ghost,ply) then

			// Attack the player
			zpn.Animation.Play(Ghost, zpn.Theme.Ghost.anim[ "steal" ], 1.5, true)
			Ghost:EmitSound("zpn_ghost_woow")
			ply:TakeDamage( 15, Ghost, Ghost )
			RealHits = RealHits + 1

			// Push player
			ply.zpn_ImpactHit_Strenght = 5
			ply.zpn_ImpactHit_Dir = ply:GetPos() - Ghost:GetPos()
			ply.zpn_ImpactHit = true

			timer.Simple(1,function()
				if IsValid(Ghost) and zpn.Ghost.IsHunting(Ghost) then
					zpn.Animation.Play(Ghost, zpn.Theme.Ghost.anim["chase"], 1.5)
				end
			end)
		else
			FailedHits = FailedHits + 1
		end
	end)
end

function zpn.Ghost.IsHunting(Ghost)
	return Ghost:GetActionState() == 5
end

function zpn.Ghost.StopHunting(Ghost)
	Ghost:StopMotionController()
	Ghost.zpn_HuntTarget = nil
	Ghost:SetMoveType(MOVETYPE_NONE)
	Ghost:SetCollisionGroup(COLLISION_GROUP_NONE)
	local phys = Ghost:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(false)
		phys:SetDragCoefficient(0)
		phys:SetAngleDragCoefficient(0)
	end
end

function zpn.Ghost.PhysicsSimulate(Ghost, phys, deltatime)
	if not IsValid(Ghost) then return end
	if not IsValid(phys) then return end

	local Target = Ghost.zpn_HuntTarget

	if IsValid(Ghost) and IsValid(phys) and IsValid(Target) then

		if Ghost.ShadowParams == nil then Ghost.ShadowParams = {} end

		phys:Wake()

		local dir = Ghost:GetPos() - Target:GetPos()
		dir = dir:Angle()
		dir:RotateAroundAxis(dir:Up(),180)

		Ghost.ShadowParams.secondstoarrive = 0.5 // How long it takes to move to pos and rotate accordingly - only if it could move as fast as it want - damping and max speed/angular will make this invalid (Cannot be 0! Will give errors if you do)
		Ghost.ShadowParams.pos = Target:GetPos() //+ Target:EyeAngles():Forward() * 100
		Ghost.ShadowParams.angle = dir
		Ghost.ShadowParams.maxangular = 10000  //What should be the maximal angular force applied
		Ghost.ShadowParams.maxangulardamp = 100000  // At which force/speed should it start damping the rotation
		Ghost.ShadowParams.maxspeed = 600   // Maximal linear force applied
		Ghost.ShadowParams.maxspeeddamp = 10000 // Maximal linear force/speed before  damping
		Ghost.ShadowParams.dampfactor = 0.8  // The percentage it should damp the linear/angular force if it reaches it's max amount
		Ghost.ShadowParams.teleportdistance = 2000 // If it's further away than this it'll teleport (Set to 0 to not teleport)
		Ghost.ShadowParams.deltatime = deltatime // The deltatime it should use - just use the PhysicsSimulate one
		phys:ComputeShadowControl(Ghost.ShadowParams)
	end
end
////////////////////////////////////////////
////////////////////////////////////////////
