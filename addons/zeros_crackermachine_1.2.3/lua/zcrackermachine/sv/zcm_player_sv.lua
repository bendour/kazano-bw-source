if (not SERVER) then return end
zcm = zcm or {}
zcm.f = zcm.f or {}

////////////////////////////////////////////
//////////////// NW Timeout ////////////////
////////////////////////////////////////////
// How often are clients allowed to send net messages to the server
ZCM_NW_TIMEOUT = 0.1

function zcm.f.Player_Timeout(ply)
    local Timeout = false

    if ply.zcm_NWTimeout and ply.zcm_NWTimeout > CurTime() then
        zcm.f.Debug("Player_Timeout!")

        Timeout = true
    end

    ply.zcm_NWTimeout = CurTime() + zcm_NW_TIMEOUT

    return Timeout
end
////////////////////////////////////////////
////////////////////////////////////////////




////////////////////////////////////////////
///////////// Player Initialize ////////////
////////////////////////////////////////////
if zcm_PlayerList == nil then
    zcm_PlayerList = {}
end

function zcm.f.Player_Add(ply)
    zcm_PlayerList[zcm.f.Player_GetID(ply)] = ply
end

function zcm.f.Player_Remove(steamid)
    zcm_PlayerList[steamid] = nil
end

util.AddNetworkString("zcm_Player_Initialize")
net.Receive("zcm_Player_Initialize", function(len, ply)

    if not IsValid(ply) then return end

    if ply.zcm_HasInitialized then
        return
    else
        ply.zcm_HasInitialized = true
    end

    zcm.f.Debug("zcm_Player_Initialize Netlen: " .. len)

    zcm.f.Player_Add(ply)
end)
////////////////////////////////////////////
////////////////////////////////////////////







local zcm_DeleteEnts = {
	["zcm_crackermachine"] = true,
	["zcm_box"] = true,
	["zcm_blackpowder"] = true,
	["zcm_firecracker"] = true,
	["zcm_paperroll"] = true,
	["zcm_palette"] = true
}

function zcm.f.Player_CleanUpEnts(steamID)
    for k, v in pairs(zcm.EntList) do
        if IsValid(v) and zcm_DeleteEnts[v:GetClass()] and zcm.f.GetOwnerID(v) == steamID then
            SafeRemoveEntity(v)
        end
    end
end

function zcm.f.Player_Disconnect(steamid)

    // Remove the player entities
    zcm.f.Player_CleanUpEnts(steamid)
end

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "a_zcm_player_disconnect", function(data)
    local steamid

    if data.bot == 1 then
        steamid = data.userid
    else
        steamid = data.networkid
    end

    zcm.f.Player_Disconnect(steamid)
end)




hook.Add("GravGunOnDropped", "a_zcm_EntityAligment", function(ply, ent)
	if IsValid(ent) and ent:GetClass() == "zcm_firecracker" then
		local ang = ply:GetAngles()
		ang:RotateAroundAxis(ply:GetUp(), 180)
		ent:SetAngles(Angle(0, ang.y, 0))
	end
end)



hook.Add("PlayerChangedTeam", "a_zcm_PlayerChangedTeam", function(ply, before, after)
	-- if zcm.f.IsCrackerMakerJobID(before) then
	-- 	zcm.f.Player_CleanUpEnts(zcm.f.Player_GetID(ply))
	-- end
end)

hook.Add("PlayerDeath", "a_zcm_PlayerDeath", function(victim, inflictor, attacker)
	if IsValid(victim) then
		local fCount = victim:GetNWInt("zcm_firework", 0)

		if fCount and fCount > 0 and zcm.config.Player.ResetFirework_OnDeath then
			victim:SetNWInt("zcm_firework", 0)
		end
	end
end)
