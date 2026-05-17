/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

zmlab2 = zmlab2 or {}
zmlab2.PollutionSystem = zmlab2.PollutionSystem or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

zmlab2.PollutionSystem.PolutedAreas = zmlab2.PollutionSystem.PolutedAreas or {}

function zmlab2.PollutionSystem.GetSize()
    return 100
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

// Returns the Pump Duration
function zmlab2.PollutionSystem.GetPosition(raw_pos)
    local size = zmlab2.PollutionSystem.GetSize()
    return Vector(math.Round(zclib.util.SnapValue(size,raw_pos.x)),math.Round(zclib.util.SnapValue(size,raw_pos.y)),math.Round(zclib.util.SnapValue(size,raw_pos.z)))
end

function zmlab2.PollutionSystem.FindNearest(pos,dist)
    local id
    if zmlab2.PollutionSystem.PolutedAreas and #zmlab2.PollutionSystem.PolutedAreas > 0 then
        for k,v in pairs(zmlab2.PollutionSystem.PolutedAreas) do
            if v == nil then continue end
            if v.pos == nil then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3b23fe5de9dfb761758a006a7271ce1817b0b3d31fddc5f22fc8264734156bf

            //debugoverlay.Sphere(v.pos,10,1,Color( 255, 255, 255 ,50),true)

            if zclib.util.InDistance(v.pos, pos, dist) then
                //debugoverlay.Sphere(v.pos,25,1,Color( 0, 255, 0 ,50),true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2

                id = k
                break
            end
        end
    end
    return id
end
