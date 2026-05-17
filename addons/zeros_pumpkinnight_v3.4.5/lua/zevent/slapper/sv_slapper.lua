/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if CLIENT then return end
zpn = zpn or {}
zpn.Slapper = zpn.Slapper or {}

function zpn.Slapper.Initialize(Slapper)
    zclib.Debug("zpn.Slapper.Initialize")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    Slapper:SetModel(Slapper.Model)
    Slapper:PhysicsInit(SOLID_VPHYSICS)
    Slapper:SetSolid(SOLID_VPHYSICS)
    Slapper:SetMoveType(MOVETYPE_VPHYSICS)
    Slapper:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local phys = Slapper:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(true)
    end

    Slapper:UseClientSideAnimation()
    Slapper:DrawShadow(false)
    Slapper:SetSkin(Slapper.SkinValue)

    zclib.EntityTracker.Add(Slapper)
end

function zpn.Slapper.OnRemove(Slapper)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

end

function zpn.Slapper.OnUse(Slapper,ply)
    zpn.Slapper.Place(Slapper)
end

// Place the slapper mine and make sure its oriented correctly
function zpn.Slapper.Place(Slapper)
    if Slapper.GotPlaced then return end
    Slapper.GotPlaced = true

    Slapper.PhysgunDisabled = true
    Slapper:SetTrigger(true)
    local phys = Slapper:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    end

    zclib.Animation.Play(Slapper,"open", 1)
    zclib.NetEvent.Create("zpn_slapper_open", {Slapper})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

    timer.Simple(0.6,function()
        if IsValid(Slapper) then
            Slapper.IsActivated = true
        end
    end)
end

function zpn.Slapper.Touch(Slapper,other)
    zclib.Debug("zpn.Slapper.Touch")
    if not IsValid(Slapper) then return end

    if IsValid(other) and other:IsPlayer() and other:Alive() then
        zpn.Slapper.Trigger(Slapper,other)
    end
end

function zpn.Slapper.Trigger(Slapper,ply)
    if Slapper.IsActivated == nil then return end
    if Slapper.GotTriggerd then return end
    Slapper.GotTriggerd = true

    local points = zpn.Candy.ReturnPoints(ply)
    if Slapper.StealCandy and points and points > 0 then

        // How much candy will we steal
        local takeAmount = math.random(Slapper.StealCandy.min,Slapper.StealCandy.max)
        if points < takeAmount then
            takeAmount = points
        end

        zpn.Candy.TakePoints(ply,takeAmount)
        zpn.Candy.Notify(ply,-takeAmount)

        local pos = ply:GetPos()

        local delay = 0.25
        while takeAmount > 0 do
            local randomAngle = math.random(360)
            local InnerCircleRadius = math.random(100,150)
            local offset = Vector(math.cos(randomAngle) * InnerCircleRadius, math.sin(randomAngle) * InnerCircleRadius, 25)
            local spawnPos = pos + offset

            local am = 25
            if takeAmount < 25 then am = takeAmount end

            timer.Simple(delay,function() zpn.Slapper.SpawnCandy(spawnPos,am) end)
            takeAmount = takeAmount - am
            delay = delay + 0.1
        end
    end

    if Slapper.OnTrigger then Slapper:OnTrigger(ply) end

    zclib.NetEvent.Create("zpn_slapper_trigger", {Slapper})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

    Slapper:SetModelScale(0,0.25)
	// 1235078258
    if Slapper.MakeBounch then
        timer.Simple(0.1,function()
            if IsValid(ply) and IsValid(Slapper) then
                ply.zpn_SlapDir = Slapper:GetUp() * 500
                ply.zpn_SlapTime = CurTime() + 1
            end
        end)
    end

    SafeRemoveEntityDelayed(Slapper,0.5)
end

function zpn.Slapper.SpawnCandy(pos,Amount)
    local ent = ents.Create("zpn_candy")
    ent:SetPos(pos)
    ent:Spawn()
    ent:Activate()
    ent:SetCandy(Amount)
    ent:SetDisplayCandy(true)
    ent:SetModel("models/zerochain/props_pumpkinnight/zpn_candydrop.mdl")

    // Give it some random orange color
    ent:SetColor(HSVToColor(math.random(28,42),0.7,1))

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(true)
        phys:EnableDrag(true)
        phys:SetAngleDragCoefficient(1000000)
        phys:ApplyForceCenter(VectorRand(-100, 100))
    end
end

zclib.Hook.Add("Move", "zpn_Slapper", function(ply, mv)
    if IsValid(ply) and ply:Alive() and ply.zpn_SlapDir and ply.zpn_SlapTime and ply.zpn_SlapTime > CurTime() then
        local vel = mv:GetVelocity()
        mv:SetVelocity(Vector(vel.x,vel.y,0) + ply.zpn_SlapDir)
        ply.zpn_SlapDir = nil
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8
