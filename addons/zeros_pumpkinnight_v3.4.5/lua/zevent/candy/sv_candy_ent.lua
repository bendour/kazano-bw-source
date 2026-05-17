/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if CLIENT then return end
zpn = zpn or {}
zpn.Candy = zpn.Candy or {}

zpn.SpawnedCandy = zpn.SpawnedCandy or {}

if zpn.config.Candy.DespawnTime ~= -1 then
    local timerid = "zpn_candy_despawner"
    zclib.Timer.Remove(timerid)

    zclib.Timer.Create(timerid, zpn.config.Candy.DespawnTime, 0, function()
        if zpn.SpawnedCandy and table.Count(zpn.SpawnedCandy) > 0 then
            for k, v in pairs(zpn.SpawnedCandy) do
                if IsValid(v) then
                    if v.DeSpawnTime < CurTime() then
                        v:Remove()
                    end
                else
                    zpn.SpawnedCandy[k] = nil
                end
            end
        end
    end)
end


function zpn.Candy.Initialize(Candy)
    zclib.Debug("zpn.Candy.Initialize")

    local val,key = table.Random(zpn.Theme.Candytypes)

    Candy:SetModel(key)
    Candy:SetCandy(val)
    Candy:SetModelScale(0.75)

    Candy:SetColor(HSVToColor(math.random(0,360),0.7,1))

    local size = 50

    //Vectors
    local min = Vector(0 - (size / 2), 0 - (size / 2), 0 - (size / 2))
    local max = Vector(size / 2, size / 2, size / 2)


    //Set physics box
    Candy:PhysicsInitBox(min,max)

    //Set bounding box - this will be used for triggers and
    //determining if rendering is necessary clientside)
    Candy:SetCollisionBounds(min,max)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

    Candy:SetUseType(SIMPLE_USE)
    Candy:SetTrigger(true)

    Candy:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    Candy:SetCustomCollisionCheck(true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    local phys = Candy:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(true)

        phys:EnableDrag( true )
        phys:SetAngleDragCoefficient(1000000)
        phys:SetDragCoefficient(1000000)
    end

    zclib.EntityTracker.Add(Candy)

    Candy.DeSpawnTime = CurTime() + zpn.config.Candy.DespawnTime
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

    table.insert(zpn.SpawnedCandy,Candy)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function zpn.Candy.Collect(Candy,ply)
    zclib.Debug("zpn.Candy.Collect")
    ply:EmitSound("zpn_candy_collect")

	local points = Candy:GetCandy()

	if Candy.CandyDropper && not Candy.CandyWasDropped then
		points = points * zpn.Mask.GetCandyMul(ply)
	end

    zpn.Candy.AddPoints(ply, points)
    Candy:Remove()
end

function zpn.Candy.StartTouch(Candy, ply)
    if zclib.util.CollisionCooldown(Candy) then return end
    zpn.Candy.Collect(Candy, ply)
end
