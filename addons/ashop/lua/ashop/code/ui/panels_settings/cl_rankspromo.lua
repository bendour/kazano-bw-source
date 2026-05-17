local function DrawInterior(editor, key, value, parent)
    local ranks = {}
    for k, v in pairs(CAMI.GetUsergroups()) do
        table.insert(ranks, {k, k})
    end

    local scroll = vgui.Create("DScrollPanel", editor)
    scroll:Dock(FILL)

    local nameContainer = vgui.Create('AShop_Entry', scroll)
    nameContainer:Dock(TOP)
    nameContainer:SetTall(0)
    nameContainer:IsRequired(true)
    nameContainer:SetInput(ashop.L('RankName'), 'SELECT', key, {
        selects = ranks,
        outputType = TYPE_STRING,
        required = true,
        maxLength = 18,
        minLength = 4
    })
    nameContainer.boxcolor = ashop.GetColor('Grad2_0')
    nameContainer:AddSeparator()

    function nameContainer:OnSave(value)
        if ashop.rankpromo[value] then
            ashop.DermaNotify(ashop.L('RankAlreadyExistWithThatName'), NOTIFY_ERROR, 4)
            return
        end
        parent:SetText(value)
        net.Start('ashop_RankPromotion_Edit')
            net.WriteString(key)

            net.WriteBool(true)
            net.WriteString(value)
        net.SendToServer()

        key = value
    end

    local idContainer = vgui.Create('AShop_Entry', scroll)
    idContainer:Dock(TOP)
    idContainer:SetTall(0)
    idContainer:IsRequired(true)
    idContainer:AddSeparator()

    idContainer:SetInput(ashop.L('PromotionAmount'), 'UInt7', value, {
        required = true
    })
    idContainer.boxcolor = ashop.GetColor('Grad2_0')

    function idContainer:OnSave(value)
        net.Start('ashop_RankPromotion_Edit')
            net.WriteString(key)

            net.WriteBool(false)
            net.WriteUInt(value, 7)
        net.SendToServer()
    end
end

ashop.registerParameter(ashop.L('RankPromo'), DrawInterior, function()
    local o = {}

    for k, v in pairs(ashop.rankpromo) do
        table.insert(o, {k, k, v})
    end

    return o
end, function()
    local ranks = {}
    for k, v in pairs(CAMI.GetUsergroups()) do
        table.insert(ranks, {k, k})
    end

    local a = vgui.Create('AShop_Form', ashop.menu)
    a:SetTitle(ashop.L('CreatePromoBasedOnRank'))
    a:CreateEntry(true, ashop.L('Rank'), 'SELECT', {
        selects = ranks,
        outputType = TYPE_STRING
    })
    a:CreateEntry(true, ashop.L('PromotionAmount'), "UInt7")

    function a:OnSend(rank, amt)
        if ashop.rankpromo[rank] then
            ashop.DermaNotify(ashop.L('RankAlreadyExistWithThatName'), NOTIFY_ERROR, 4)
            return
        end

        net.Start('ashop_RankPromotion_Create')
            net.WriteString(rank)
            net.WriteUInt(amt, 7)
        net.SendToServer()
    end
    a:Center()
end, function(but, settingButton, objectTarget, fullObject)
    function but:DoRightClick()
        CloseDermaMenus()
        local menu = vgui.Create( "AShop_DMenu", but )
        menu:AddOption(ashop.L('Remove'), function()
            ashop.ui.popAskbox(ashop.L('SureToDeletePromotionRank'), "", function()
                net.Start('ashop_RankPromotion_Delete')
                    net.WriteString(fullObject[1])
                net.SendToServer()
            end)
        end)

        menu:Open()
    end
end)