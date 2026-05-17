/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

zpn = zpn or {}
zpn.Loot = zpn.Loot or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

function zpn.Loot.Initialize(Loot)
    zclib.Debug("zpn.Loot.Initialize")

	Loot:SetModel(zpn.Theme.Destructibles.models[math.random(#zpn.Theme.Destructibles.models)])

    // Give it some random orange color
    Loot:SetColor(zpn.Theme.Destructibles.getcolor())

    Loot:PhysicsInit(SOLID_VPHYSICS)
    Loot:SetSolid(SOLID_VPHYSICS)
    Loot:SetMoveType(MOVETYPE_VPHYSICS)
    Loot:SetUseType(SIMPLE_USE)
    Loot:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	Loot:SetCustomCollisionCheck(true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

    local phys = Loot:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    Loot.Smashed = false

    local health = math.random(zpn.config.Destructable.Health.min, zpn.config.Destructable.Health.max)
    Loot:SetMaxHealth( health )
    Loot:SetHealth( health )

    zclib.EntityTracker.Add(Loot)

    // Precache gibs
    Loot:PrecacheGibs()

	Loot.DeSpawnTime = CurTime() + zpn.config.Destructable.DespawnTime
end

function zpn.Loot.OnTakeDamage(Loot,dmginfo)
    zclib.Debug("zpn.Loot.OnTakeDamage")

	if not IsValid(Loot) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

    if Loot.Smashed then return end

    // Make sure we're not already applying damage a second time
    // This prevents infinite loops
    if (not Loot.m_bApplyingDamage) then
        Loot.m_bApplyingDamage = true

        Loot:TakeDamageInfo(dmginfo)
        Loot:SetHealth(math.Clamp(Loot:Health() - dmginfo:GetDamage(),0,25))

        if Loot:Health() <= 0 then
            zpn.Loot.Smash(Loot,dmginfo:GetAttacker())
        end

        Loot.m_bApplyingDamage = false
    end
end

function zpn.Loot.OnUse(Loot, ply)
	if Loot.Smashed then return end
	zpn.Loot.Smash(Loot,ply)
end

function zpn.Loot.OnRemove(Loot)
    zclib.Debug("zpn.Loot.OnRemove")
end

/*
	Returns a random loot prize id according to all their chances
*/
function zpn.Loot.GetPrize()

    //Loop over items and create the chances
    local totalChance = 0
    for _ ,PrizeData in pairs(zpn.config.Loot) do
        totalChance = totalChance + PrizeData.dropchance
    end

    local num = math.random(1 , totalChance)
    local prevCheck = 0
    local PrizeID = nil

    for id ,PrizeData in pairs(zpn.config.Loot) do
        if num >= prevCheck and num <= prevCheck + PrizeData.dropchance then
            PrizeID = id
        end
        prevCheck = prevCheck + PrizeData.dropchance
    end

    return PrizeID
end

function zpn.Loot.Smash(Loot,ply)
    zclib.Debug("zpn.Loot.Smash")

    if IsValid(ply) and ply:IsPlayer() and ply:Alive() then
        zpn.Score.AddPoints(ply, 1)
    end

	Loot.Smashed = true

    Loot:SetNoDraw(true)

	zclib.NetEvent.Create("zpn_loot_collect", {Loot})

	SafeRemoveEntityDelayed(Loot,2)

    timer.Simple(0,function()
        if IsValid(Loot) and IsValid(ply) then

			// Give the player who smashed the loot a random thing

			local PrizeID = zpn.Loot.GetPrize()
			local PrizeData = zpn.config.Loot[PrizeID]
			if not PrizeData then return end

			if zpn.PurchaseType[PrizeData.type](ply, PrizeData) then
				if PrizeData.notify then zclib.Notify(ply, PrizeData.notify, 0) end
			end
        end
    end)
end
