local function DrawInterior(editor, key, value, parent)
    // Oh no
    if !CAMI then
        ashop.DermaNotify("You need CAMI to use this option", 1, 5)
        return
    end

    local scroll = vgui.Create("DScrollPanel", editor)
    scroll:Dock(FILL)

    local nameContainer = vgui.Create('AShop_Entry', scroll)
    nameContainer:Dock(TOP)
    nameContainer:SetTall(0)
    nameContainer:IsRequired(true)
    nameContainer:SetInput(ashop.L('GroupName'), TYPE_STRING, value.name, {
        required = true,
        maxLength = 24,
        minLength = 4
    })
    nameContainer.boxcolor = ashop.GetColor('Grad2_0')
    nameContainer:AddSeparator()

    function nameContainer:OnSave(n)
        net.Start('ashop_GroupRanks_Edit')
            net.WriteUInt(key, ashop.Config.BitsGroupRank)
            net.WriteUInt(0, 3)
            net.WriteString(n)
        net.SendToServer()
    end

    local descContainer = vgui.Create('AShop_Entry', scroll)
    descContainer:Dock(TOP)
    descContainer:SetTall(0)
    descContainer:SetInput(ashop.L('Description'), TYPE_STRING, value.desc, {
        required = true
    })
    descContainer:IsRequired(true)
    descContainer.boxcolor = ashop.GetColor('Grad2_0')
    descContainer:AddSeparator()

    function descContainer:OnSave(n)
        net.Start('ashop_GroupRanks_Edit')
            net.WriteUInt(key, ashop.Config.BitsGroupRank)
            net.WriteUInt(1, 3)
            
            net.WriteBool(n)
            if n then
                net.WriteString(n)
            end
        net.SendToServer()
    end

    local msgContainer = vgui.Create('AShop_Entry', scroll)
    msgContainer:Dock(TOP)
    msgContainer:SetTall(0)
    msgContainer:SetInput(ashop.L('MissingRankFailMsg'), TYPE_STRING, value.messageOnFail)
    msgContainer.boxcolor = ashop.GetColor('Grad2_0')
    msgContainer:AddSeparator()

    function msgContainer:OnSave(n)
        net.Start('ashop_GroupRanks_Edit')
            net.WriteUInt(key, ashop.Config.BitsGroupRank)
            net.WriteUInt(2, 3)
            
            net.WriteBool(n)
            if n then
                net.WriteString(n)
            end
        net.SendToServer()
    end

    local freeCoins = vgui.Create('AShop_Entry', scroll)
    freeCoins:Dock(TOP)
    freeCoins:SetTall(0)
    freeCoins:SetInput(ashop.L('FreeCoinsEvery5Min'), "UInt16", value.freePerTime or 0)
    freeCoins.boxcolor = ashop.GetColor('Grad2_0')
    freeCoins:AddSeparator()

    function freeCoins:OnSave(n)
        net.Start('ashop_GroupRanks_Edit')
            net.WriteUInt(key, ashop.Config.BitsGroupRank)
            net.WriteUInt(3, 3)
            
            net.WriteBool(n)
            if n then
                net.WriteUInt(tonumber(n) or 0, 16)
            end
        net.SendToServer()
    end

    local premiumCoins = vgui.Create('AShop_Entry', scroll)
    premiumCoins:Dock(TOP)
    premiumCoins:SetTall(0)
    premiumCoins:SetInput(ashop.L('PremiumCoinsEvery5Min'), "UInt16", value.premiumPerTime or 0)
    premiumCoins.boxcolor = ashop.GetColor('Grad2_0')
    premiumCoins:AddSeparator()

    function premiumCoins:OnSave(n)
        net.Start('ashop_GroupRanks_Edit')
            net.WriteUInt(key, ashop.Config.BitsGroupRank)
            net.WriteUInt(4, 3)
            
            net.WriteBool(n)
            if n then
                net.WriteUInt(tonumber(n) or 0, 16)
            end
        net.SendToServer()
    end

    local ranks = {}

    for k, v in pairs(CAMI.GetUsergroups()) do
        table.insert(ranks, {k, k})
    end

    local actualRanks = {}

    for k, v in pairs(ashop.groupranks[key].ranks) do
        table.insert(actualRanks, {k, k})
    end

    local groupContainer = vgui.Create('AShop_Entry', scroll)
    groupContainer:Dock(TOP) 
    groupContainer:SetTall(0)
    groupContainer:IsRequired(true)
    // value.ranks
    groupContainer:SetInput(ashop.L('AllowedRanks'), 'LIST', actualRanks, {
        listObjects = {
            {'SELECT', ashop.L('RankName'), true, {
                selects = ranks,
                outputType = TYPE_STRING,
                required = true
            }}
        },
        required = true
    })
    groupContainer.boxcolor = ashop.GetColor('Grad2_0')
    groupContainer:AddSeparator()

    function groupContainer:OnSave(n)
        net.Start('ashop_GroupRanks_Edit')
            net.WriteUInt(key, ashop.Config.BitsGroupRank)
            net.WriteUInt(5, 3)

            for k, v in ipairs(n) do
                net.WriteBool(true)
                net.WriteString(v[1])
            end
            net.WriteBool(false)
        net.SendToServer()
    end
end

ashop.registerParameter(ashop.L('RankGroups'), DrawInterior, function()
    local o = {}

    for k, v in pairs(ashop.groupranks) do
        table.insert(o, {v.name, k, v})
    end

    return o
end, function()
    local a = vgui.Create('AShop_Form', ashop.menu)
    a:SetTitle(ashop.L('CreateRankGroup'))
    a:CreateEntry(true, ashop.L('GroupName'), TYPE_STRING, {
        maxLength = 24,
        minLength = 4
    })

    function a:OnSend(n)
        net.Start('ashop_GroupRanks_New')
            net.WriteString(n)
        net.SendToServer()
    end
    a:Center()
end, function(but, settingButton, objectTarget)
    function but:DoRightClick()
        CloseDermaMenus()
        local menu = vgui.Create( "AShop_DMenu", but )
        menu:AddOption(ashop.L('Remove'), function()
            // Check if this rarity is applied to items
            local f = 0

            for _, v in pairs(ashop.items) do
                if v.group_restrained == objectTarget.id then
                    f = f + 1
                end
            end

            if f > 0 then
                ashop.ui.popAskbox(ashop.L('WarningDeleteRankGroup', objectTarget.name, f), ashop.L('CantUndoOperation'), function()
                    net.Start('ashop_GroupRanks_Delete')
                        net.WriteUInt(objectTarget.id, ashop.Config.BitsGroupRank)
                    net.SendToServer()
                end)
            else
                ashop.ui.popAskbox(ashop.L("Delete the rank ", objectTarget.name), ashop.L('CantUndoOperation'), function()
                    net.Start('ashop_GroupRanks_Delete')
                        net.WriteUInt(objectTarget.id, ashop.Config.BitsGroupRank)
                    net.SendToServer()
                end)
            end
        end)

        menu:Open()
    end
end)