local l = {}
local c = CurTime

function ashop.NetCD(name, ply, cd)
    local t = c()
    if l[ply] and l[ply][name] and l[ply][name] + cd > t then
        return false
    end

    l[ply] = l[ply] or {}
    l[ply][name] = t

    return true
end

hook.Add("PlayerDisconnected", "ashop_clearnets", function(ply)
    l[ply] = nil
end)

function ashop.SafeNet(netname, code, cooldown, superadminOnly)
    util.AddNetworkString("ashop_" .. netname)
    net.Receive("ashop_" .. netname, function(_, ply)
        if !ashop.NetCD(netname, ply, cooldown or 0.15) and !((ashop.Config.fullEdit and ashop.Config.fullEdit[ply:GetUserGroup()]) or ply:IsSuperAdmin()) then return end
        if superadminOnly and !((ashop.Config.fullEdit and ashop.Config.fullEdit[ply:GetUserGroup()]) or ply:IsSuperAdmin()) then return end

        code(ply)
    end)
end

timer.Create("ashop_givecoins", 300, 0, function()
    ashop.groupranks = ashop.groupranks or {}
    if table.IsEmpty(ashop.groupranks) then return end

    for k, v in ipairs(player.GetHumans()) do
        if !v.ashop_data then continue end
        local freeAcc, premiumAcc = 0, 0
        local plyRank = v:GetUserGroup()

        for _, rank in pairs(ashop.groupranks) do
            if !rank.ranks[plyRank] then continue end

            if rank.premiumPerTime then
                if ashop.maxOrAccumulation then
                    premiumAcc = premiumAcc + rank.premiumPerTime
                elseif premiumAcc < rank.premiumPerTime then
                    premiumAcc = rank.premiumPerTime
                end
            end

            if rank.freePerTime then
                if ashop.maxOrAccumulation then
                    freeAcc = freeAcc + rank.freePerTime
                elseif freeAcc < rank.freePerTime then
                    freeAcc = rank.freePerTime
                end
            end
        end

        if freeAcc > 0 then
            v:ashopMoneyChange(freeAcc, false)
        end

        if premiumAcc > 0 then
            v:ashopMoneyChange(premiumAcc, true)
        end
    end
end)