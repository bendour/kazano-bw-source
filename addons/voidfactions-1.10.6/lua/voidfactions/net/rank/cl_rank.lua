local L = VoidFactions.Lang.GetPhrase

VoidFactions.Rank = VoidFactions.Rank or {}
VoidFactions.RankTemplates = VoidFactions.RankTemplates or nil


function VoidFactions.Rank:CreateRank(faction, name, weight, tag, maxMembers, canInvite, canPromote, canDemote, canPurchasePerks, kickMembers, manageFaction, minLevel, jobs, canWithdrawMoney, canDepositMoney, canWithdrawItems, canDepositItems, autoPromoteLevel, promoteDefault)
    local validation, msg = VoidFactions.Rank:ValidateRank(name, maxMembers, jobs)
    if (!validation) then
        VoidLib.Notify(L"error", L(msg), VoidUI.Colors.Red, 5)
        return false
    end
    
    net.Start("VoidFactions.Rank.CreateRank")
        net.WriteUInt(istable(faction) and faction.id or faction, 20)
        net.WriteString(name)
        net.WriteString(tag or "")
        net.WriteUInt(maxMembers or 0, 16)

        net.WriteBool(canInvite)
        net.WriteUInt(canPromote, 2)
        net.WriteUInt(canDemote, 2)
        net.WriteBool(canPurchasePerks)
        net.WriteUInt(kickMembers, 2)
        net.WriteBool(manageFaction)
        net.WriteUInt(minLevel or 0, 12)
        net.WriteTable(jobs or {})
        
        if (VoidFactions.Settings:IsStaticFactions()) then
            net.WriteUInt(autoPromoteLevel, 12)
            net.WriteTable(promoteDefault or {})
        end

        if (VoidFactions.Settings:IsDynamicFactions()) then
            net.WriteBool(canWithdrawMoney)
            net.WriteBool(canDepositMoney)
            net.WriteBool(canWithdrawItems)
            net.WriteBool(canDepositItems)
        end
    net.SendToServer()

    return true
end

function VoidFactions.Rank:DeleteRank(rank)
    net.Start("VoidFactions.Rank.DeleteRank")
        net.WriteUInt(istable(rank.faction) and rank.faction.id or 0, 20)
        net.WriteUInt(rank.id, 20)
    net.SendToServer()
end

function VoidFactions.Rank:UpdateRankWeight(rank, weight)
    net.Start("VoidFactions.Rank.UpdateRankWeight")
        net.WriteUInt(istable(rank.faction) and rank.faction.id or 0, 20)
        net.WriteUInt(rank.id, 20)
        net.WriteUInt(weight, 16)
    net.SendToServer()
end

function VoidFactions.Rank:UpdateRank(rank, name, weight, tag, maxMembers, canInvite, canPromote, canDemote, canPurchasePerks, kickMembers, manageFaction, minLevel, jobs, canWithdrawMoney, canDepositMoney, canWithdrawItems, canDepositItems, autoPromoteLevel, promoteDefault)
    local validation, msg = VoidFactions.Rank:ValidateRank(name, maxMembers, jobs)
    if (!validation) then
        VoidLib.Notify(L"error", L(msg), VoidUI.Colors.Red, 5)
        return false
    end

    local faction = rank.faction or 0

    net.Start("VoidFactions.Rank.UpdateRank")
        net.WriteUInt(rank.id, 20)
        net.WriteUInt(istable(faction) and faction.id or faction, 20)
        net.WriteString(name)
        net.WriteString(tag or "")
        net.WriteUInt(maxMembers or 0, 16)


        net.WriteBool(canInvite)
        net.WriteUInt(canPromote, 2)
        net.WriteUInt(canDemote or 1, 2)
        net.WriteBool(canPurchasePerks or false)
        net.WriteUInt(kickMembers, 2)
        net.WriteBool(manageFaction)
        net.WriteUInt(minLevel or 0, 12)
        net.WriteTable(jobs)

        if (VoidFactions.Settings:IsStaticFactions()) then
            net.WriteUInt(autoPromoteLevel, 12)
            net.WriteTable(promoteDefault or {})
        end

        if (VoidFactions.Settings:IsDynamicFactions() or VoidFactions.Config.DepositEnabled) then
            net.WriteBool(canWithdrawMoney)
            net.WriteBool(canDepositMoney)
            net.WriteBool(canWithdrawItems)
            net.WriteBool(canDepositItems)
        end

    net.SendToServer()

    return true
end

-- Net handlers

net.Receive("VoidFactions.Rank.SendRankTemplates", function (len, ply)
    local length = net.ReadUInt(7)
    local ranks = {}
    for i = 1, length do
        local rank = VoidFactions.Rank:ReadRank(nil, true)
        ranks[rank.id] = rank
    end

    VoidFactions.PrintDebug("Received " .. length .. " rank templates")
    VoidFactions.RankTemplates = ranks

    hook.Run("VoidFactions.Rank.RankTemplatesReceived", ranks)
end)