local function DrawInterior(editor, key, value, parent)
    local scroll = vgui.Create("DScrollPanel", editor)
    scroll:Dock(FILL)

    ashop.ui.SkinScrollPanel(scroll)

    local nameContainer = vgui.Create('AShop_Entry', scroll)
    nameContainer:Dock(TOP)
    nameContainer:SetTall(0)
    nameContainer:IsRequired(true)
    nameContainer:SetInput(ashop.L('Name'), TYPE_STRING, value.name, {
        required = true,
        maxLength = 24,
        minLength = 4
    })
    nameContainer.boxcolor = ashop.GetColor('Grad2_0')
    nameContainer:AddSeparator()

    function nameContainer:OnSave(value)
        parent:SetText(value)

        net.Start('ashop_Render_Edit')
            net.WriteBool(true)
            net.WriteUInt(key, ashop.Config.BitsRender)
            net.WriteString(value)
        net.SendToServer()
    end

    for k, v in pairs(ashop.object_types) do
        if value.cat[k] then continue end

        local objectType = vgui.Create('AShop_Entry', scroll)
        objectType:Dock(TOP)
        objectType:AddSeparator()

        objectType:SetInput(ashop.L('DrawObjectTypeInShopCategory', v.Name), TYPE_BOOL, value.cat[k])

        function objectType:OnSave(value)
            net.Start('ashop_Render_Edit')
                net.WriteBool(false)
                net.WriteUInt(key, ashop.Config.BitsRender)
                net.WriteUInt(k, ashop.Config.BitsObjectType)
            net.SendToServer()

            if value then
                objectType:Remove()
                scroll:InvalidateLayout()
            end
        end
        objectType.boxcolor = ashop.GetColor('Grad2_0')
    end
end

ashop.registerParameter(ashop.L('Renders'), DrawInterior, function()
    local o = {}

    for k, v in pairs(ashop.render) do
        table.insert(o, {v.name, k, v})
    end

    return o
end, function()
    local a = vgui.Create('AShop_Form', ashop.menu)
    a:SetTitle(ashop.L('CreateARender'))
    a:CreateEntry(true, ashop.L('Name'), TYPE_STRING, {
        maxLength = 24,
        minLength = 4
    })

    for k, v in pairs(ashop.object_types) do
        a:CreateEntry(true, ashop.L('DrawObjectTypeInShopCategory', v.Name), TYPE_BOOL)
    end

    function a:OnSend(name, ...)
        local t = {...}

        net.Start('ashop_Render_New')
            net.WriteString(name)
            ashop.Network.W_Bulk(
                t,
                function(t)
                    net.WriteBool(t)
                end,
                0, ashop.Config.BitsObjectType, ashop.Config.BitsObjectType
            )
        net.SendToServer()
    end
    a:Center()
end, function(but, settingButton, objectTarget, fullObject)
    function but:DoRightClick()
        if table.Count(ashop.render) <= 1 then return end

        CloseDermaMenus()
        local menu = vgui.Create( "AShop_DMenu", but )

        menu:AddOption(ashop.L('Remove'), function()
            if objectTarget.cat and !table.IsEmpty(objectTarget.cat) then
                local id = next(objectTarget.cat)
                ashop.DermaNotify(ashop.L('CantDeleteNotEmptyRender') .. ". The object type you need to move is : " .. ashop.object_types[id].Name, NOTIFY_ERROR, 3)
                return
            end

            // Check if only one

            ashop.ui.popAskbox(ashop.L('DeleteRender', objectTarget.name), ashop.L('CantUndoOperation'), function()
                net.Start('ashop_Render_Delete')
                    net.WriteUInt(fullObject[2], ashop.Config.BitsRender)
                net.SendToServer()
            end)
        end)

        menu:Open()
    end
end)