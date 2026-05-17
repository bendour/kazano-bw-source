local function DrawInterior(editor, key, value, parent)
    local scroll = vgui.Create("DScrollPanel", editor)
    scroll:Dock(FILL)
    scroll:SetWide(editor:GetWide())

    local nameContainer = vgui.Create('AShop_Entry', scroll)
    nameContainer:Dock(TOP)
    nameContainer:SetTall(0)
    nameContainer:IsRequired(true)
    nameContainer:SetInput(ashop.L('Name'), TYPE_STRING, value.name, {
        maxLength = 18,
        minLength = 4,
        required = true
    })
    nameContainer.boxcolor = ashop.GetColor('Grad2_0')
    nameContainer:AddSeparator()

    function nameContainer:OnSave(value)
        parent:SetText(value)

        net.Start('ashop_Rarity_Edit')
            net.WriteUInt(0, 3)
            net.WriteUInt(key, ashop.Config.BitsRarity)
            net.WriteString(value)
        net.SendToServer()
    end

    local clr = vgui.Create('AShop_Entry', scroll)
    clr:Dock(TOP)
    clr:SetTall(0)
    clr:IsRequired(true)
    clr:SetInput(ashop.L('Color'), TYPE_COLOR, value.clr, {
        required = true
    })
    clr.boxcolor = ashop.GetColor('Grad2_0')
    clr:AddSeparator()

    function clr:OnSave(value)
        net.Start('ashop_Rarity_Edit')
            net.WriteUInt(1, 3)
            net.WriteUInt(key, ashop.Config.BitsRarity)
            net.WriteColor(value)
        net.SendToServer()
    end

    local style = vgui.Create('AShop_Entry', scroll)
    style:Dock(TOP)
    style:SetTall(0)
    style:SetInput(ashop.L('Style'), "UInt8", value.style, {
        required = true
    })
    style.boxcolor = ashop.GetColor('Grad2_0')
    style:AddSeparator()

    function style:OnSave(value)
        net.Start('ashop_Rarity_Edit')
            net.WriteUInt(2, 3)
            net.WriteUInt(key, ashop.Config.BitsRarity)
            net.WriteUInt(value, 8)
        net.SendToServer()
    end

    local notif = vgui.Create('AShop_Entry', scroll)
    notif:Dock(TOP)
    notif:SetTall(0)
    notif:SetInput("Notification on unbox", TYPE_BOOL, value.notif_unbox)
    notif.boxcolor = ashop.GetColor('Grad2_0')
    notif:AddSeparator()

    function notif:OnSave(value)
        net.Start('ashop_Rarity_Edit')
            net.WriteUInt(3, 3)
            net.WriteUInt(key, ashop.Config.BitsRarity)
            net.WriteBool(value)
        net.SendToServer()
    end

    local notifSound = vgui.Create('AShop_Entry', scroll)
    notifSound:Dock(TOP)
    notifSound:SetTall(0)
    notifSound:SetInput("Notification sound on unbox ( URL or audio path )", TYPE_STRING, value.notif_unboxsound, {
        minLength = 0,
        maxLength = 256
    })
    notifSound.boxcolor = ashop.GetColor('Grad2_0')
    notifSound:AddSeparator()

    function notifSound:OnSave(value)
        net.Start('ashop_Rarity_Edit')
            net.WriteUInt(4, 3)
            net.WriteUInt(key, ashop.Config.BitsRarity)
            net.WriteString(value)
        net.SendToServer()
    end
end

ashop.registerParameter(ashop.L('Rarity'), DrawInterior, function()
    local o = {}

    for k, v in pairs(ashop.rarity) do
        table.insert(o, {v.name, k, v})
    end

    return o
end, function()
    local a = vgui.Create('AShop_Form', ashop.menu)
    a:SetTitle(ashop.L('CreateARarity'))
    a:CreateEntry(true, ashop.L('Name'), TYPE_STRING, {
        maxLength = 18,
        minLength = 4
    })
    a:CreateEntry(true, ashop.L('Color'), TYPE_COLOR)
    a:CreateEntry(false, ashop.L('Style'), "UInt8")
    a:CreateEntry(false, "Notification on unbox", TYPE_BOOL)
    a:CreateEntry(false, "Notification sound on unbox", TYPE_STRING, {
        minLength = 0,
        maxLength = 256
    })

    function a:OnSend(name, ...)
        local t = {...}

        net.Start('ashop_Rarity_New')
            net.WriteString(name or "")
            net.WriteColor(t[1])

            net.WriteBool(t[2])
            
            if t[2] then
                net.WriteUInt(t[2], 8)
            end

            if t[3] then
                net.WriteBool(t[3])
            end

            if t[4] then
                net.WriteBool(t[4])
            end
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
                if v.rarity == objectTarget.id then
                    f = f + 1
                end
            end

            if f > 0 then
                ashop.ui.popAskbox(ashop.L('WarningDeleteRankGroup', objectTarget.name, f), ashop.L('CantUndoOperation'), function()
                    net.Start('ashop_Rarity_Delete')
                        net.WriteUInt(objectTarget.id, ashop.Config.BitsRarity)
                    net.SendToServer()
                end)
            else
                ashop.ui.popAskbox(ashop.L('DeleteTheRarity', objectTarget.name), ashop.L('CantUndoOperation'), function()
                    net.Start('ashop_Rarity_Delete')
                        net.WriteUInt(objectTarget.id, ashop.Config.BitsRarity)
                    net.SendToServer()
                end)
            end
        end)

        menu:Open()
    end
end)