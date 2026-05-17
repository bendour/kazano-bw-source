ashop.registerParameter(ashop.L('Giveaway'), function()
    local a = vgui.Create('AShop_Form', ashop.menu)
    a:SetTitle(ashop.L('CreateGiveaway'))

    local l = {}

    for k, v in pairs(ashop.items) do
        table.insert(l, {v.name, k})
    end

    local o = {}

    for k, v in pairs(ashop.groupranks) do
        table.insert(o, {v.name, k})
    end

    a:CreateEntry(true, ashop.L('ItemToGive'), "SELECT", {
        required = true,
        selects = l
    })

    a:CreateEntry(false, ashop.L('GroupRestrained'), "SELECT", {
        selects = o,
        required = false
    })

    function a:OnSend(itemToGive, groupRestrained)
        net.Start('ashop_giveaway')
            net.WriteUInt(itemToGive, ashop.Config.BitsItemID)
            net.WriteBool(groupRestrained and groupRestrained != 0)

            if groupRestrained and groupRestrained != 0 then
                net.WriteUInt(groupRestrained, ashop.Config.BitsGroupRank)
            end
        net.SendToServer()
    end
    a:Center()
end)