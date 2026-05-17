if CLIENT then return end
zrush = zrush or {}
zrush.OilSpotZone = zrush.OilSpotZone or {}
zrush.OilSpotZone.List = zrush.OilSpotZone.List or {}

zrush.OilSpotZone.Oilspots = zrush.OilSpotZone.Oilspots or {}

/*
    zrush.OilSpotZone.List = {
        [1] = {
            pos = Vector(x,y,z),
            size = Vector(x,y,100),
            oilspots = {}
        }
    }
*/

file.CreateDir("zrush")

concommand.Add("zrush_OilSpotZone_remove", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then

        for k, v in pairs(zrush.OilSpotZone.Oilspots) do
            if v then
                for _, oilspot in pairs(v) do
                    if IsValid(oilspot) then
                        SafeRemoveEntity(oilspot)
                    end
                end
            end
        end

        zclib.Zone.Remove("zrush_oilspot_zone")
    end
end)


///////////////////// AUTO SPAWN

// Here we check if the pos is far enough away from the other oilspots
function zrush.OilSpotZone.AreaClear(pos)
    zclib.Debug("zrush.OilSpotZone.AreaClear")
    local FoundValidPos = true
    for k, v in pairs(ents.FindInSphere(pos, 200)) do
        if ((v:GetClass() == "zrush_oilspot" or v:GetClass() == "zrush_drillhole") and zclib.util.InDistance(v:GetPos(), pos, zrush.config.Machine["Drill"].NewDrillRadius)) then
            FoundValidPos = false
            break
        end
    end
    return FoundValidPos
end

function zrush.OilSpotZone.GetOilspotCount(zone_id)
    local count = 0
    for k,v in pairs(zrush.OilSpotZone.Oilspots[zone_id]) do
        if IsValid(v) then
            count = count + 1
        end
    end
    //zclib.Debug("zrush.OilSpotZone.GetOilspotCount " .. tostring(count))
    return count
end

local vec01 = Vector(0,0,200)
local vec02 = Vector(0,0,400)
function zrush.OilSpotZone.AutoSpawn(zone_id)
    //zclib.Debug("zrush.OilSpotZone.AutoSpawn")

    local zone_data = zrush.OilSpotZone.List[zone_id]

    if zrush.OilSpotZone.Oilspots[zone_id] == nil then zrush.OilSpotZone.Oilspots[zone_id] = {} end

    // Remove any oilspot which time has run out
    for _,oilspot in pairs(zrush.OilSpotZone.Oilspots[zone_id]) do
        if IsValid(oilspot) and oilspot.Created_TimeStamp and CurTime() > oilspot.Created_TimeStamp and oilspot.InUse == false then
            zrush.OilSpot.Remove(oilspot)
        end
    end

    // Can we spawn more oilspots?
    if zrush.OilSpotZone.GetOilspotCount(zone_id) >= zrush.config.OilSpot_Zone.MaxOilSpots then return end

    local pos = zone_data.pos + (zone_data.size * Vector(math.Rand(0,1),math.Rand(0,1),0.5) )

    // Check if the area is clear
    if zrush.OilSpotZone.AreaClear(pos) == false then return end

    local t_start = pos + vec01
    local t_end = t_start - vec02

    local c_trace = zclib.util.TraceLine({
        start = t_start,
        endpos = t_end,
        mask = MASK_SOLID_BRUSHONLY,
    }, "zrush_oilspot_zoner")

    debugoverlay.Line( t_start, t_end,3,Color( 0, 0, 255 ),true)

    if c_trace == nil then return end
    if c_trace.Hit ~= true then return end
    if c_trace.HitPos == nil then return end
    if c_trace.HitNonWorld then return end
    if IsValid(c_trace.Entity) then return end

    // Is the position in the world?
    if util.IsInWorld( c_trace.HitPos ) == false then return end

    local ang = c_trace.HitNormal
    ang = ang:Angle()
    ang:RotateAroundAxis(ang:Right(),-90)

    local oilspot = zrush.OilSpotZone.SpawnOilSpot(c_trace.HitPos, ang)

    table.insert(zrush.OilSpotZone.Oilspots[zone_id],oilspot)
end

function zrush.OilSpotZone.SpawnOilSpot(pos, ang)
    zclib.Debug("zrush.OilSpotZone.SpawnOilSpot")
    local ent = ents.Create("zrush_oilspot")
    if not IsValid(ent) then return end
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:Spawn()
    ent:Activate()
    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    end
    return ent
end

local function SetupAutospawnTimer()
    local timerid = "zrush_OilSpotZone_autospawn"
    zclib.Timer.Remove(timerid)

    zclib.Timer.Create(timerid, zrush.config.OilSpot_Zone.Rate, 0, function()
        for k, v in pairs(zrush.OilSpotZone.List) do
            if v == nil then continue end
            zrush.OilSpotZone.AutoSpawn(k)
        end
    end)
end


timer.Simple(4, function()
    SetupAutospawnTimer()
end)
