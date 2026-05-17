if (not SERVER) then return end
zmlab = zmlab or {}
zmlab.f = zmlab.f or {}


////////////////////////////////////////////
///////////// Player Initialize ////////////
////////////////////////////////////////////
if zmlab_PlayerList == nil then
    zmlab_PlayerList = {}
end

function zmlab.f.Player_Add(ply)
    zmlab_PlayerList[zmlab.f.Player_GetID(ply)] = ply
end

function zmlab.f.Player_Remove(steamid)
    zmlab_PlayerList[steamid] = nil
end

util.AddNetworkString("zmlab_Player_Initialize")
net.Receive("zmlab_Player_Initialize", function(len, ply)

    if not IsValid(ply) then return end

    if ply.zmlab_HasInitialized then
        return
    else
        ply.zmlab_HasInitialized = true
    end

    zmlab.f.Debug("zmlab_Player_Initialize Netlen: " .. len)

    zmlab.f.Player_Add(ply)
end)
////////////////////////////////////////////
////////////////////////////////////////////





hook.Add("PlayerDeath", "a_zmlab_PlayerDeath", function(victim, inflictor, attacker)
    zmlab.f.StopScreenEffect(victim)

    if zmlab.config.Meth.DropMeth_OnDeath then
        zmlab.f.PlayerDeath(victim, inflictor, attacker)
    end
end)

local function spawnMethBox(pos)
    local ent = ents.Create("zmlab_collectcrate")
    ent:SetAngles(Angle(0, 0, 0))
    ent:SetPos(pos)
    ent:Spawn()
    ent:Activate()

    return ent
end

function zmlab.f.PlayerDeath(victim, inflictor, attacker)
    if (IsValid(victim) and victim.zmlab_meth ~= nil and victim.zmlab_meth > 0) then
        local meth = spawnMethBox(victim:GetPos() + Vector(0, 0, 10))
        meth:SetMethAmount(victim.zmlab_meth)

        timer.Simple(0.25, function()
            if IsValid(meth) then
                zmlab.f.TransportCrate_UpdateVisuals(meth)
            end
        end)

        victim.zmlab_meth = 0
        victim.zmlab_OnMeth = false

        if (victim.zmlab_old_RunSpeed) then
            victim:SetRunSpeed(victim.zmlab_old_RunSpeed or 500)
        end

        if (victim.zmlab_old_WalkSpeed) then
            victim:SetWalkSpeed(victim.zmlab_old_WalkSpeed or 200)
        end
    end
end

hook.Add("EntityTakeDamage", "a_zmlab_PlayerOnMeth_EntityTakeDamage", function(target, dmginf)
    if IsValid(target) and target:IsPlayer() and target:Alive() and target.zmlab_OnMeth then
        dmginf:ScaleDamage(0.5)
    end
end)


local zmlab_DeleteEnts = {
    ["zmlab_aluminium"] = true,
    ["zmlab_collectcrate"] = true,
    ["zmlab_combiner"] = true,
    ["zmlab_filter"] = true,
    ["zmlab_frezzer"] = true,
    ["zmlab_frezzingtray"] = true,
    ["zmlab_methylamin"] = true,
    ["zmlab_palette"] = true
}
function zmlab.f.PlayerCleanUp(ply)

    if IsValid(ply.DropOffPoint) then
        zmlab.f.Dropoffpoint_Close(ply.DropOffPoint)
    end

    for k, v in pairs(zmlab.EntList) do
        if IsValid(v) and zmlab_DeleteEnts[v:GetClass()] and zmlab.f.GetOwnerID(v) == zmlab.f.Player_GetID(ply) then
            v:Remove()
        end
    end
end


-- hook.Add("PlayerChangedTeam", "a_zmlab_PlayerChangedTeam", function(ply, before, after)
--     if table.Count(zmlab.config.Jobs) > 0 then
--         if zmlab.config.Jobs[after] == nil then
--             zmlab.f.PlayerCleanUp(ply)
--         end
--     else
--         zmlab.f.PlayerCleanUp(ply)
--     end
-- end)

hook.Add("PostPlayerDeath", "a_zmlab_PostPlayerDeath", function(ply, text)
    if IsValid(ply.DropOffPoint) then
        zmlab.f.Dropoffpoint_Close(ply.DropOffPoint)
    end
end)

hook.Add("PlayerSilentDeath", "a_zmlab_PlayerSilentDeath", function(ply, text)
    if IsValid(ply.DropOffPoint) then
        zmlab.f.Dropoffpoint_Close(ply.DropOffPoint)
    end
end)

hook.Add("PlayerSay", "a_zmlab_PlayerSay_StripMeth", function(ply, text)
    if string.sub(string.lower(text), 1, string.len(zmlab.config.Police.cmd_strip)) == zmlab.config.Police.cmd_strip and IsValid(ply) and ply:IsPlayer() and ply:Alive() and zmlab.config.Police.Jobs[team.GetName(ply:Team())] then
        local tr = ply:GetEyeTrace()
        local target = tr.Entity
        if tr.Hit and IsValid(target) and target:IsPlayer() and target:Alive() and zmlab.f.InDistance(ply:GetPos(), target:GetPos(), 200) then

            if target.zmlab_meth and target.zmlab_meth > 0 then
                local meth = spawnMethBox(target:GetPos() + Vector(25, 0, 10))
                meth:SetMethAmount(target.zmlab_meth)

                timer.Simple(0.25, function()
                    if IsValid(meth) then
                        zmlab.f.TransportCrate_UpdateVisuals(meth)
                    end
                end)

                target.zmlab_meth = 0
            else
                local _string = string.Replace(zmlab.language.player_strip_nometh, "$PlayerName", target:Nick())
                zmlab.f.Notify(ply, _string, 3)
            end
        end
    end
end)

hook.Add("PlayerSay", "a_zmlab_PlayerSay_Save", function(ply, text)
    if string.sub(string.lower(text), 1, 10) == "!savezmlab" then
        if zmlab.f.IsAdmin(ply) then
            zmlab.f.PublicEnts_Save(ply)
        else
            zmlab.f.Notify(ply, "You do not have permission to perform this action, please contact an admin.", 1)
        end
    end
end)
