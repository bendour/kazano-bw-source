util.AddNetworkString('ashop_giveaway')

function ashop.StartGiveaway(itemID, restrictGroup, playerCountLoop, secExec)
    playerCountLoop = playerCountLoop or math.random(100, 250)
    secExec = secExec or math.random(15, 20)

    assert(itemID, "Item ID does not exist")
    assert(!restrictGroup or ashop.groupranks[restrictGroup], "Specified group does not exist")
    assert(secExec < 63 and secExec >= 0, "secExec can't be more than 63, or less than 0")
    assert(playerCountLoop < 500 and playerCountLoop >= 0, "secExec can't be more than 500, or less than 0")

    local plys = {}
    for k, v in ipairs(player.GetHumans()) do
        if restrictGroup and ashop.groupranks[restrictGroup] and ashop.groupranks[restrictGroup].ranks[v:GetUserGroup()] then continue end
        table.insert(plys, v)
    end

    if table.IsEmpty(plys) then
        return false, "Not enough players, the restricted group ID: " .. restrictGroup
    end

    local winnerPly = table.Random(plys)

    timer.Simple(secExec, function()
        if !IsValid(winnerPly) then return end
        ashop.actions.Give(winnerPly, itemID, nil, 0, false)
    end)

    net.Start('ashop_giveaway')
        net.WriteEntity(winnerPly)
        net.WriteString(ashop.items[itemID].name)
        net.WriteBool(restrictGroup != nil)

        if restrictGroup != nil then
            net.WriteUInt(restrictGroup, 8)
        end
        net.WriteUInt(playerCountLoop, 9)
        net.WriteUInt(secExec, 6)
    net.Broadcast()
end

ashop.SafeNet('giveaway', function(ply)
    print(ashop.StartGiveaway(
        net.ReadUInt(ashop.Config.BitsItemID),
        net.ReadBool() and net.ReadUInt(ashop.Config.BitsGroupRank) or nil))
end, 1, true)