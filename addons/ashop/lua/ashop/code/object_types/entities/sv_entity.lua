local OBJECT_TYPE = {}

OBJECT_TYPE.Name = "Entities"
OBJECT_TYPE.UniqueIdentifier = "Entities"

// Credit: 
// https://github.com/FPtje/DarkRP/blob/master/gamemode/modules/base/sv_util.lua#L128C1-L142C4
local function placeEntity(ent, tr, ply)
    local trace = {}
    trace.start = ply:EyePos()
    trace.endpos = trace.start + ply:GetAimVector() * 85
    trace.filter = ply

    local tr = util.TraceLine(trace)

    if IsValid(ply) then
        local ang = ply:EyeAngles()
        ang.pitch = 0
        ang.yaw = ang.yaw + 180
        ang.roll = 0
        ent:SetAngles(ang)
    end

    local vFlushPoint = tr.HitPos - (tr.HitNormal * 512)
    vFlushPoint = ent:NearestPoint(vFlushPoint)
    vFlushPoint = ent:GetPos() - vFlushPoint
    vFlushPoint = tr.HitPos + vFlushPoint
    ent:SetPos(vFlushPoint)
end

function OBJECT_TYPE.OnUse(ply, plyItem, item)
    // Pick a item
    local entClass = item.metadata[1]
    if !entClass then return end

    local ent = ents.Create(entClass)
    if !IsValid(ent) then return end

    if ent.CPPISetOwner then ent:CPPISetOwner(ply) end
    if ent.Setowning_ent then ent:Setowning_ent(ply) end
    placeEntity(ent, tr, ply)
    ent:Spawn()
    ent:Activate()
end

ashop.RegisterObjectType(OBJECT_TYPE)