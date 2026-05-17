local L = VoidFactions.Lang.GetPhrase

VoidFactions.Jobs = VoidFactions.Jobs or {}

hook.Add("VoidFactions.SQL.MemberLoaded", "VoidFactions.Jobs.PersistJobs", function (ply)
    if (!VoidFactions.Settings:IsStaticFactions()) then return end
    if (VoidChar) then return end

    local member = ply:GetVFMember()
    if (!member or !member.faction or !member.rank) then return end

    if (!member.job) then
        member:SetJob( member.rank.jobs[1] )
        member:SaveStatic()
    end
    
    ply:changeTeam(member.job, true)
    VoidFactions.PrintDebug("Switched " .. ply:Name() .. "'s job to '" .. team.GetName(member.job))
end)

hook.Add("playerCanChangeTeam", "VoidFactions.Jobs.CanChangeJob", function (ply, t, force)
    if (!VoidFactions.Settings:IsStaticFactions()) then return end
    if (force) then return end

    if (CAMI.PlayerHasAccess(ply, "VoidFactions_AccessAllJobs")) then return end

    local member = ply:GetVFMember()
    if (!member or !member.faction or !member.rank) then return false, L"changingJobRestricted" end

    local hasJob = table.HasValue(member.rank.jobs, t)
    if (!hasJob) then
        return false, L"changingJobRestricted"
    end
end)