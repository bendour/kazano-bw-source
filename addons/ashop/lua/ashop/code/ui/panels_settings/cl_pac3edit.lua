local function DrawInterior(editor, key, value, parent)
    local scroll = vgui.Create("DScrollPanel", editor)
    scroll:Dock(FILL)

    local nameContainer = vgui.Create('AShop_Entry', scroll)
    nameContainer:Dock(TOP)
    nameContainer:SetTall(0)
    nameContainer:IsRequired(true)
    nameContainer:SetInput(ashop.L('Name'), TYPE_STRING, value.name, {
        required = true,
        maxLength = 32,
        minLength = 4
    })
    nameContainer.boxcolor = ashop.GetColor('Grad2_0')
    nameContainer:AddSeparator()

    function nameContainer:OnSave(value)
        parent:SetText(value)
        net.Start('ashop_Pac3_Edit')
            net.WriteUInt(1, 3)
            net.WriteUInt(key, ashop.Config.BitsPac3)
            net.WriteString(value)
        net.SendToServer()
    end

    local idContainer = vgui.Create('AShop_Entry', scroll)
    idContainer:Dock(TOP)
    idContainer:SetTall(0)
    idContainer:IsRequired(true)
    idContainer:AddSeparator()

    idContainer:SetInput(ashop.L('ID'), "UInt8", key, {
        locked = true,
        required = true
    })
    idContainer.boxcolor = ashop.GetColor('Grad2_0')

    local modelAttachContainer = vgui.Create('AShop_Entry', scroll)
    modelAttachContainer:Dock(TOP)
    modelAttachContainer:IsRequired(false)
    modelAttachContainer:SetInput(ashop.L('ModelAttached'), TYPE_BOOL, value.model_attach, {
        required = true
    })
    modelAttachContainer.boxcolor = ashop.GetColor('Grad2_0')
    modelAttachContainer:AddSeparator()

    function modelAttachContainer:OnSave(value)
        net.Start('ashop_Pac3_Edit')
            net.WriteUInt(2, 3)
            net.WriteUInt(key, ashop.Config.BitsPac3)
            net.WriteBool(value)
        net.SendToServer()
    end

    local pac3Container = vgui.Create('AShop_Entry', scroll)
    pac3Container:Dock(TOP)
    pac3Container:SetInput(ashop.L('Pac3Code'), TYPE_STRING, value.outfit_text, {
        lineMultiplySize = 20,
        required = true
    })
    pac3Container:AddSeparator()

    function pac3Container:OnSave(value)
        net.Start('ashop_Pac3_Edit')
            net.WriteUInt(0, 3)
            net.WriteUInt(key, ashop.Config.BitsPac3)
            ashop.Network.W_Compress(value)
        net.SendToServer()
    end

    pac3Container.boxcolor = ashop.GetColor('Grad2_0')
end

ashop.registerParameter('Pac3', DrawInterior, function()
    local o = {}

    for k, v in pairs(ashop.pac3) do
        table.insert(o, {v.name, k, v})
    end

    return o
end, function()
    local a = vgui.Create('AShop_Form', ashop.menu)
    a:SetTitle(ashop.L('CreateAPac3'))
    a:CreateEntry(true, ashop.L('Name'), TYPE_STRING, {
        maxLength = 32,
        minLength = 4,
        required = true
    })
    a:CreateEntry(false, ashop.L('ModelAttached'), TYPE_BOOL)
    a:CreateEntry(true, ashop.L('Pac3Code'), TYPE_STRING, {
        lineMultiplySize = 20
    })

    function a:OnSend(name, modelAttach, pac3Code)
        net.Start('ashop_Pac3_New')
            net.WriteString(name)
            net.WriteBool(modelAttach)
            ashop.Network.W_Compress(pac3Code)
        net.SendToServer()
    end
    a:Center()
end, function(but, settingButton, objectTarget, completeObject)
    function but:DoRightClick()
        CloseDermaMenus()
        local menu = vgui.Create( "AShop_DMenu", but )
        menu:AddOption(ashop.L("Remove"), function()
            ashop.ui.popAskbox(ashop.L('AreYouSureToDeleteThis'), ashop.L('CantUndoOperation'), function()
                net.Start('ashop_Pac3_Delete')
                    net.WriteUInt(completeObject[2], ashop.Config.BitsPac3)
                net.SendToServer()
            end)
        end)

        menu:Open()
    end
end)