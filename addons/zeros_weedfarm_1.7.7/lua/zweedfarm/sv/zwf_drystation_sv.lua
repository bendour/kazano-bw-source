if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

function zwf.f.DryStation_Initialize(DryStation)
    zwf.f.EntList_Add(DryStation)

    DryStation.DrySlots = {
        [1] = {
            ent = nil,
            pos = Vector(-50, 0, 70)
        },
        [2] = {
            ent = nil,
            pos = Vector(-40, 0, 69)
        },
        [3] = {
            ent = nil,
            pos = Vector(-30, 0, 69)
        },
        [4] = {
            ent = nil,
            pos = Vector(-20, 0, 68)
        },
        [5] = {
            ent = nil,
            pos = Vector(-10, 0, 67)
        },
        [6] = {
            ent = nil,
            pos = Vector(-0, 0, 66)
        },
        [7] = {
            ent = nil,
            pos = Vector(10, 0, 67)
        },
        [8] = {
            ent = nil,
            pos = Vector(20, 0, 68)
        },
        [9] = {
            ent = nil,
            pos = Vector(30, 0, 69)
        },
        [10] = {
            ent = nil,
            pos = Vector(40, 0, 69)
        },
        [11] = {
            ent = nil,
            pos = Vector(50, 0, 70)
        },


        [12] = {
            ent = nil,
            pos = Vector(-50, 0, 25)
        },
        [13] = {
            ent = nil,
            pos = Vector(-40, 0, 24)
        },
        [14] = {
            ent = nil,
            pos = Vector(-30, 0, 24)
        },
        [15] = {
            ent = nil,
            pos = Vector(-20, 0, 23)
        },
        [16] = {
            ent = nil,
            pos = Vector(-10, 0, 22)
        },
        [17] = {
            ent = nil,
            pos = Vector(-0, 0, 21)
        },
        [18] = {
            ent = nil,
            pos = Vector(10, 0, 22)
        },
        [19] = {
            ent = nil,
            pos = Vector(20, 0, 23)
        },
        [20] = {
            ent = nil,
            pos = Vector(30, 0, 24)
        },
        [21] = {
            ent = nil,
            pos = Vector(40, 0, 24)
        },
        [22] = {
            ent = nil,
            pos = Vector(50, 0, 25)
        }
    }

    /*
    for k, v in pairs(DryStation.DrySlots) do

        if not IsValid(v.ent) then

            local ent = ents.Create("zwf_weedstick")
            ent:SetPos(DryStation:GetPos())
            ent:Spawn()
            ent:Activate()

            zwf.f.DryStation_AddWeedStick(DryStation, ent, k)
        end
    end
    */
end

function zwf.f.DryStation_ReturnFreeSpot(DryStation)
    if not IsValid(DryStation) then return end
    local freeSpot

    for k, v in pairs(DryStation.DrySlots) do
        if not IsValid(v.ent) then
            freeSpot = k
            break
        end
    end

    return freeSpot
end

function zwf.f.DryStation_HasWeed(DryStation)
    if not IsValid(DryStation) then return end
    local hasweed = false

    for k, v in pairs(DryStation.DrySlots) do
        if IsValid(v.ent) then
            hasweed = true
            break
        end
    end

    return hasweed
end


function zwf.f.DryStation_Touch(DryStation, other)
    if not IsValid(DryStation) then return end
    if not IsValid(other) then return end
    if zwf.f.CollisionCooldown(other) then return end

    if other:GetClass() == "zwf_weedstick" then
        local freeSpot = zwf.f.DryStation_ReturnFreeSpot(DryStation)

        if freeSpot ~= nil then
            zwf.f.DryStation_AddWeedStick(DryStation, other, freeSpot)
        end
    end
end

function zwf.f.DryStation_AddWeedStick(DryStation, weedstick, pos)

    DropEntityIfHeld(weedstick)
    local slot = DryStation.DrySlots[pos]
    weedstick:SetParent(DryStation)
    weedstick:SetLocalPos(slot.pos)
    weedstick:SetLocalAngles(Angle(0, 0, 180))
    slot.ent = weedstick
    weedstick:SetStartDryTime(CurTime())

    // This will later be used to add some loading bar for the removal process
    weedstick:SetProgress(zwf.config.DryStation.Harvest_Time * 4) // Since we remove 1 value every half second we multiply this value times 2
end

function zwf.f.DryStation_RemoveWeedStick(weedstick,DryStation,ply)
    if zwf.f.IsWeedSeller(ply) == false then return end
    if zwf.config.Sharing.DryStation == false and zwf.f.IsOwner(ply, weedstick) == false then return end


    local ent = ents.Create("zwf_jar")
    ent:SetPos(DryStation:GetPos() + DryStation:GetUp() * 25 + DryStation:GetRight() * -25 + DryStation:GetForward() * math.Rand(-65,65))
    ent:Spawn()
    ent:Activate()

    ent:SetPlantID(weedstick.PlantID)
    ent:SetTHC(math.Round(weedstick.THC,2))
    ent:SetWeedName(weedstick.PlantName)

    ent:SetPerf_Time(math.Round(weedstick.perf_time))
    ent:SetPerf_Amount(math.Round(weedstick.perf_amount))
    ent:SetPerf_THC(math.Round(weedstick.perf_thc))

    ent:SetSkin(zwf.config.Plants[weedstick.PlantID].skin)

    weedstick:SetWeedAmount(weedstick:GetWeedAmount() * ((1 / 100) * (100 - zwf.config.DryStation.Loss)))

    local weedStickOwnerID = zwf.f.GetOwnerID(weedstick)
    zwf.f.SetOwnerByID(ent, weedStickOwnerID)

    zwf.f.Jar_AddWeed(ent,weedstick:GetWeedAmount())

    weedstick:Remove()
end
