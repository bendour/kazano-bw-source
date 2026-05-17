local OBJECT_TYPE = {}

util.AddNetworkString("ashop_killcards")
OBJECT_TYPE.Name = "Kill Cards"
OBJECT_TYPE.UniqueIdentifier = "KillCards"

local dmgCache = {}

hook.Add("PostEntityTakeDamage", "ashop_killcard", function(ent, dmg, took)
    if !took or dmg:GetDamage() <= 0 then return end
    local ply = dmg:GetAttacker()
    
    if !IsValid(ply) or !ply:IsPlayer() then return end

    dmgCache[ent] = dmgCache[ent] or {}

    if !dmgCache[ent][ply] then
        dmgCache[ent][ply] = {0, 0}
    end

    dmgCache[ent][ply][2] = dmgCache[ent][ply][2] + 1
    dmgCache[ent][ply][1] = dmgCache[ent][ply][1] + dmg:GetDamage()
end)

hook.Add("PlayerSpawn", "ashop_killcard", function(ply)
    dmgCache[ply] = nil
end)

function OBJECT_TYPE.OnEquip(ply, plyItem, item)
    if !item.metadata[1] then return end
    ply.ashop_killcard = item.metadata[1]
end

function OBJECT_TYPE.OnRemove(ply, plyItem, item)
    ply.ashop_killcard = nil
end

function OBJECT_TYPE.OnKill(ply, plyItem, item, _, __, victim, inflictor)
    local t = ashop.knownItems.plys[victim].items

    local know = t[item.id]
    net.Start('ashop_killcards')
        net.WriteUInt(item.id, ashop.Config.BitsItemID)
        net.WriteBool(false)
        net.WriteEntity(ply)

        if dmgCache[ply] and dmgCache[ply][victim] then
            net.WriteUInt(dmgCache[ply][victim][1], 16)
            net.WriteUInt(dmgCache[ply][victim][2], 16)
        else
            net.WriteUInt(0, 16)
            net.WriteUInt(0, 16)
        end

        if dmgCache[victim] and dmgCache[victim][ply] then
            net.WriteUInt(dmgCache[victim][ply][1], 16)
            net.WriteUInt(dmgCache[victim][ply][2], 16)
        else
            net.WriteUInt(0, 16)
            net.WriteUInt(0, 16)
        end

        if !know then
            ashop.Network.W_ItemData(item)
            t[item.id] = true
        end
    net.Send(victim)
end

function OBJECT_TYPE.OnKilled(ply, plyItem, item, _, __, killer, inflictor)
    local t = ashop.knownItems.plys[killer].items

    local know = t[item.id]
    net.Start('ashop_killcards')
        net.WriteUInt(item.id, ashop.Config.BitsItemID)
        net.WriteBool(true)
        net.WriteEntity(ply)

        if dmgCache[ply] and dmgCache[ply][killer] then
            net.WriteUInt(dmgCache[ply][killer][1], 16)
            net.WriteUInt(dmgCache[ply][killer][2], 16)
        else
            net.WriteUInt(0, 16)
            net.WriteUInt(0, 16)
        end

        if dmgCache[killer] and dmgCache[killer][ply] then
            net.WriteUInt(dmgCache[killer][ply][1], 16)
            net.WriteUInt(dmgCache[killer][ply][2], 16)
        else
            net.WriteUInt(0, 16)
            net.WriteUInt(0, 16)
        end

        net.WriteBool(know)

        if !know then
            ashop.Network.W_ItemData(item)
            t[item.id] = true
        end
    net.Send(killer)
end

ashop.RegisterObjectType(OBJECT_TYPE)