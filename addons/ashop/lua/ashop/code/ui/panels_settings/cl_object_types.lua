local r = ashop.Config.round
local c2 = ashop.GetColor('Grad1_1')
local grad = Material('akulla/gradient-d')

local function getFormatted(tabNum, t)
    local str = ""

    for k, v in pairs(t) do
        local s = nil
        if isvector(v) then
            s = string.format("Vector(%s, %s, %s)", v:Unpack())
        elseif isangle(v) then
            s = string.format("Angle(%s, %s, %s)", v:Unpack())
        elseif IsColor(v) then
            s = string.format("Color(%s, %s, %s)", v:Unpack())
        elseif isstring(v) then
            s = "'" .. v .. "'"
        elseif isnumber(v) then
            s = v
        elseif istable(v) then
            s = ""
            s = s .. "{" .. getFormatted(tabNum + 1, v) .. "\n" .. string.rep("    ", tabNum) .. "}"
        elseif isbool(v) then
            s = v and "true" or "false"
        end

        assert(s, 's is not initialized for "export as premade", type of v: ' .. type(v))

        if isstring(k) then
            str = str .. '\n' .. string.rep("    ", tabNum) .. k .. ' = ' .. s .. ","
        else
            str = str .. '\n' .. string.rep("    ", tabNum) .. '[' .. k .. '] = ' .. s .. ","
        end
    end

    return str
end

local function DrawInterior(editor, key, value, parent)
    local scroll = vgui.Create("DScrollPanel", editor)
    scroll:Dock(FILL)

    local stateOff = ashop.GetColor('StateOff')
    local vbar = scroll:GetVBar()
    vbar:SetWide(1)
    function vbar.btnUp:Paint() end
    function vbar.btnDown:Paint() end
    function vbar:Paint(w, h) end

    function vbar.btnGrip:Paint(w, h)
        DisableClipping(true)
        draw.RoundedBox(2, w + 4, 0, 2, h, stateOff)
        DisableClipping(false )
    end

    local nameContainer = vgui.Create('AShop_Entry', scroll)
    nameContainer:Dock(TOP)
    nameContainer:SetTall(0)
    nameContainer:IsRequired(true)
    nameContainer:SetInput(ashop.L('Name'), TYPE_STRING, parent:GetText(), {
        required = true,
        maxLength = 24
    })
    nameContainer:AddSeparator()

    function nameContainer:OnSave(value)
        if !self:ValidInput() then return end
        parent:SetText(value)

        net.Start('ashop_EditObjectType')
            net.WriteBool(value[1])
            net.WriteUInt(key, ashop.Config.BitsObjectType)

            if !value[1] then
                net.WriteUInt(value[4], ashop.Config.BitsSubObjectType)
            end

            net.WriteBool(false)
            net.WriteString(value)
        net.SendToServer()
    end

    local parentClass = vgui.Create('AShop_Entry', scroll)
    parentClass:Dock(TOP)
    parentClass:SetTall(0)
    //parentClass:DockMargin(0, ashop.GetSize(20), 0, 0)
    parentClass:IsRequired(true)
    parentClass:SetInput(ashop.L('ParentContainer'), TYPE_STRING, !value[1] and value[2].Name or "", {
        locked = true,
        required = true
    })
    parentClass.boxcolor = ashop.GetColor('Grad2_0')
    parentClass:AddSeparator()

    local parentClass = vgui.Create('AShop_Entry', scroll)
    parentClass:Dock(TOP)
    parentClass:SetTall(0)
    //parentClass:DockMargin(0, ashop.GetSize(20), 0, 0)
    parentClass:IsRequired(true)
    parentClass:SetInput(ashop.L('HowMuchItemAreEquipable'), "UInt8", !value[1] and value[3].slotSize or value[2].slotSize, {
        locked = !(value[2].SlotDefault and !value[2].BlockSlotEdit),
        required = true
    })
    parentClass.boxcolor = ashop.GetColor('Grad2_0')
    parentClass:AddSeparator()

    function parentClass:OnSave(val)
        local _, msg = self:ValidInput()
        if msg then
            ashop.DermaNotify(msg, 1, 5)
            return
        end

        net.Start('ashop_EditObjectType')
            net.WriteBool(value[1])
            net.WriteUInt(key, ashop.Config.BitsObjectType)

            if !value[1] then
                net.WriteUInt(value[4], ashop.Config.BitsSubObjectType)
            end

            net.WriteBool(true)
            net.WriteUInt(val, 8)
        net.SendToServer()
    end

    if value[2] and value[2].SubCategoriesParameters then
        for k, v in pairs(value[2].SubCategoriesParameters) do
            // get metadata from this sub_cat
            local objectType = vgui.Create('AShop_Entry', scroll)
            objectType:Dock(TOP)
            //objectType:DockMargin(0, ashop.GetSize(20), 0, 0)
            objectType:SetInput(v[1], v[2], value[3].metadata[k], {required = true})
            objectType:AddSeparator()
    
            function objectType:OnSave(valueSave)
                if !self:ValidInput() then return end
                net.Start('ashop_SubObjectType_Edit')
                    net.WriteUInt(key, ashop.Config.BitsObjectType)
                    net.WriteUInt(value[4], ashop.Config.BitsObjectType)
                    net.WriteUInt(k, 7)
        
                    ashop.Network.GetWriteFunction(v[2], valueSave, {
                        required = true
                    })
                net.SendToServer()
            end
            objectType.boxcolor = ashop.GetColor('Grad2_0')
        end
    end

    local marginVertical = ashop.GetSize(20)
    local bonusPanelName = vgui.Create("DLabel", scroll)
    local m = ashop.GetSize(16)
    bonusPanelName:Dock(TOP)
    bonusPanelName:DockMargin(m, m, m, m/2)
    bonusPanelName:SetText(ashop.L('ItemList'))
    bonusPanelName:SetFont("ashop_14_600")
    bonusPanelName:SetMouseInputEnabled(true)
    bonusPanelName:SetKeyboardInputEnabled(true)
    bonusPanelName:SetTextColor(color_white)

    local createItem = vgui.Create('DButton', bonusPanelName)
    createItem:Dock(RIGHT)
    createItem:SetContentAlignment(6)
    createItem:SetText(ashop.L('Create'))
    createItem:SetTextColor(ashop.GetColor('White'))
    createItem:SetFont('ashop_14')
    createItem:SetPaintBackground(false)
    createItem:SetWide(createItem:GetContentSize())

    function createItem:DoClick()
        local selects = {}

        for k, v in pairs(ashop.rarity) do
            table.insert(selects, {v.name, v.id})
        end

        local a = vgui.Create('AShop_Form', ashop.menu)
        a:SetTitle('Create a Item')
        a:CreateEntry(true, ashop.L('Name'), TYPE_STRING, {
            required = true,
            maxLength = 24
        })
        a:CreateEntry(true, ashop.L('Rarity'), 'SELECT', {
            selects = selects,
            required = true
        })
        a:CreateEntry(false, ashop.L('Price'), 'UInt32')
        a:CreateEntry(false, ashop.L('PremiumPrice'), 'UInt32')
        a:CreateEntry(false, ashop.L('DeleteOnDeathWhenEquipped'), TYPE_BOOL)
        a:CreateEntry(false, ashop.L('PromotionStart'), 'DATE')
        a:CreateEntry(false, ashop.L('PromotionEnd'), 'DATE')
        a:CreateEntry(false, ashop.L('PromotionAmount'), 'UInt7')
        a:CreateEntry(false, ashop.L('PictureLink'), TYPE_STRING)
        a:CreateEntry(false, ashop.L('GroupRestrained'), 'SELECT', {
            selects = ashop.GetGroupRestrictsAsSelect(),
            default = ""
        })

        for k, v in SortedPairs(value[2].ItemParameters or {}) do
            if v.userEditable then continue end
            local p = a:CreateEntry(v.options and v.options.required, v.name, v.type, v.options, v.defaultValue)
            p.itemParam = k
        end

        // Loop ItemParameters
        function a:OnSend(name, rarity, price, premium_price, deleteOnDeath, promotion_start, promotion_end, promotion_amount, picture_link, group_restrained, ...)
            local t = {...}

            net.Start('ashop_Item_New')
                net.WriteUInt(key, ashop.Config.BitsObjectType)

                net.WriteBool(!value[1])

                if !value[1] then
                    net.WriteUInt(value[4], ashop.Config.BitsObjectType)
                end

                net.WriteString(name)
                net.WriteUInt(rarity, ashop.Config.BitsRarity)

                net.WriteBool(price)
                if price then
                    net.WriteUInt(price, 32)
                end

                net.WriteBool(premium_price)
                if premium_price then
                    net.WriteUInt(premium_price, 32)
                end

                net.WriteBool(deleteOnDeath)

                net.WriteBool(promotion_start)
                if promotion_start then
                    net.WriteUInt(promotion_start, 32)
                end

                net.WriteBool(promotion_end)
                if promotion_end then
                    net.WriteUInt(promotion_end, 32)
                end

                net.WriteBool(promotion_amount)
                if promotion_amount then
                    net.WriteUInt(promotion_amount, 7)
                end

                net.WriteBool(picture_link)
                if picture_link then
                    net.WriteString(picture_link)
                end

                net.WriteBool(group_restrained != nil and group_restrained != "")
                if group_restrained != nil and group_restrained != "" then
                    net.WriteUInt(group_restrained, ashop.Config.BitsGroupRank)
                end

                net.WriteBool(expireTime != nil)
                if expireTime != nil then
                    net.WriteUInt(expireTime, 32)
                end

                local incr = 0
                for k, v in SortedPairs(ashop.object_types[key].ItemParameters) do
                    if v.userEditable then continue end
                    incr = incr + 1

                    if t[incr] == nil then
                        net.WriteBool(false)
                    else
                        net.WriteBool(true)
                        ashop.Network.GetWriteFunction(v.type, t[incr], v.options)
                    end
                end
            net.SendToServer()
        end
        a:Center()
    end

    local items = vgui.Create('DIconLayout', scroll)
    items:Dock(TOP)
    items:SetSpaceY(marginVertical)
    items:SetSpaceX(marginVertical)
    items:DockMargin(0, 0, 0, 0)

    local itemWidth = math.floor((editor:GetWide() - marginVertical * 6) / 7) - 1
    local itemsByIDs = {}

    local function createUIItem(k, v)
        if key != v.object_types or !((v.sub_types and v.sub_types == value[3].id) or (!v.sub_types and !value[3])) then return end

        // Derma
        local p = vgui.Create("AShop_ShopItem", items)
        p:SetSize(itemWidth, ashop.GetSize(189))
        itemsByIDs[k] = p

        function p:Paint()
            p:SetItem(nil, k, true)
        end

        function p:DoClick()
            local itemCopy = table.Copy(v)
            // Hack
            itemCopy.id = -itemCopy.id
            ashop.items[itemCopy.id] = itemCopy

            local selects = {}
        
            for k, v in pairs(ashop.rarity) do
                table.insert(selects, {v.name, v.id})
            end
        
            local a = vgui.Create('AShop_Form', ashop.menu)
            a:SetTitle(ashop.L('ModifyAItem'))
            a:CenterVertical(0.5)
            a:CrossClose()

            local displayEdit = vgui.Create('EditablePanel', ashop.menu)
            displayEdit:SetPaintedManually(true)
            displayEdit:SetSize(ScrW()*0.1, ScrH()/2)
            displayEdit:SetZPos(12)

            local itemDisplay = vgui.Create('AShop_ShopItem', displayEdit)
            itemDisplay:Dock(TOP)
            itemDisplay:SetTall(displayEdit:GetWide())
            itemDisplay:DockMargin(0, 0, 0, marginVertical)

            // Hack
            // SetItem will override this paint, so we use SetItem only 1 time
            function itemDisplay:Paint()
                self:SetItem(nil, itemCopy, true)
            end

            local modelPanel = vgui.Create('AShop_DModelPanel', displayEdit)
            modelPanel:Dock(FILL)
            modelPanel:SetLookAt( Vector( 0, 0, 0 ) )
            modelPanel:SetModel(LocalPlayer():GetModel())
            modelPanel:EquipWeapon()
            modelPanel:DoClick()
            modelPanel:SetFOV( 45 )
            modelPanel.Entity:SetSequence("idle_passive")
            function modelPanel:LayoutEntity( ent ) end
            modelPanel:BoneFocus('ValveBiped.Bip01_Spine2')
            local plyItemTemp = modelPanel:EquipItem(nil, nil, itemCopy.id)

            function modelPanel:OnRemove()
                ashop.items[itemCopy.id] = nil
            end

            local realCenterX = (ashop.menu:GetWide() - displayEdit:GetWide() - a:GetWide() - marginVertical) /2
            a:SetPos(realCenterX, a:GetY())
            displayEdit:SetPos(a:GetWide() + a:GetX() + marginVertical, a:GetY())

            local oldPaint = a.Paint

            function a:Paint(w, h)
                oldPaint(self, w, h)
                DisableClipping(true)
                displayEdit:PaintManual()
                DisableClipping(false)
            end

            local oldRemoveA = a.OnRemove

            function a:OnRemove()
                if oldRemoveA then
                    oldRemoveA(a)
                end

                displayEdit:Remove()
            end

            local entries = {}
            table.insert(entries, a:CreateEntry(true, ashop.L('Name'), TYPE_STRING, {
                required = true,
                hideSave = false,
                itemNameParam = "name",
                maxLength = 24
            }, v.name))
            table.insert(entries, a:CreateEntry(true, ashop.L('Rarity'), 'SELECT', {
                selects = selects,
                hideSave = false,
                itemNameParam = "rarity",
                required = true
            },  v.rarity))
            table.insert(entries, a:CreateEntry(false, ashop.L('Price'), 'UInt32', {hideSave = false, itemNameParam = "price"}, v.price or 0))
            table.insert(entries, a:CreateEntry(false, ashop.L('PremiumPrice'), 'UInt32', {hideSave = false, itemNameParam = "premium_price"}, v.premium_price or 0))
            table.insert(entries, a:CreateEntry(false, ashop.L('DeleteOnDeathWhenEquipped'), TYPE_BOOL, {hideSave = false, itemNameParam = "delete_death"}, v.delete_death))
            table.insert(entries, a:CreateEntry(false, ashop.L('PromotionStart'), 'DATE', {hideSave = false, itemNameParam = "promotion_start"}, v.promotion_start))
            table.insert(entries, a:CreateEntry(false, ashop.L('PromotionEnd'), 'DATE', {hideSave = false, itemNameParam = "promotion_end"}, v.promotion_end))
            table.insert(entries, a:CreateEntry(false, ashop.L('PromotionAmount'), 'UInt7', {hideSave = false, itemNameParam = "promotion_amount"}, v.promotion_amount))
            table.insert(entries, a:CreateEntry(false, ashop.L('PictureLink'), TYPE_STRING, {hideSave = false, itemNameParam = "picture_link"}, v.picture_link))
            table.insert(entries, a:CreateEntry(false, ashop.L('GroupRestrained'), 'SELECT', {selects = ashop.GetGroupRestrictsAsSelect() or {}, outputType = 'UInt10', hideSave = false, itemNameParam = "group_restrained"}, v.group_restrained))
            table.insert(entries, a:CreateEntry(false, ashop.L('ExpireTime'), 'UInt32', {hideSave = false, itemNameParam = "expireTime"}, v.expireTime))

            for inputID, entryPanel in ipairs(entries) do
                function entryPanel:OnValueChanged(value)
                    if !self:ValidInput() then return end
                    itemCopy[self.options.itemNameParam] = value
                    itemDisplay:SetItem(nil, itemCopy, true)
                end
    
                function entryPanel:OnSave(value)
                    if !self:ValidInput() then return end

                    net.Start('ashop_Item_Edit')
                        net.WriteUInt(inputID, 7)
                        net.WriteUInt(k, ashop.Config.BitsItemID)

                        if inputID == 2 then
                            net.WriteUInt(value, ashop.Config.BitsRarity)
                        elseif inputID == 5 then
                            net.WriteBool(value)
                        else
                            ashop.Network.GetWriteFunction(entryPanel.type, value, self.options)
                        end

                    net.SendToServer()
                end
            end
        
            for itemParamID, itemParam in SortedPairs(value[2].ItemParameters or {}) do
                if itemParam.userEditable then continue end
                local o = table.Copy(itemParam.options or {})
                o.hideSave = false

                local defaultValue = (v.metadata or {})[itemParamID]

                if itemParam.type == TYPE_COLOR and defaultValue and !IsColor(defaultValue) then
                    defaultValue = Color(defaultValue.r, defaultValue.g, defaultValue.b, defaultValue.a)
                end

                local pEntry = a:CreateEntry(itemParam.options and itemParam.options.required, itemParam.name, itemParam.type, o, defaultValue)
                pEntry.itemParam = itemParamID

                function pEntry:OnValueChanged(saveValue)
                    if !self:ValidInput() then return end
                    local old = itemCopy.metadata[itemParamID]
                    itemCopy.metadata[itemParamID] = saveValue
                    itemDisplay:SetItem(nil, itemCopy, true)

                    if value[2].OnMetadataUpdate then
                        value[2].OnMetadataUpdate(modelPanel.Entity, modelPanel.Entity.ashop_data.items[plyItemTemp], itemCopy, itemParamID, old, saveValue)
                    end

                    //ashop.EquipChange(modelPanel.Entity, plyItemTemp, nil, true)
                    //ashop.EquipChange(modelPanel.Entity, plyItemTemp, nil, false)
                end

                function pEntry:OnSave(value)
                    if !self:ValidInput() then return end

                    net.Start('ashop_Item_Edit')
                        net.WriteUInt(itemParamID+11, 7)
                        net.WriteUInt(k, ashop.Config.BitsItemID)
                        ashop.Network.GetWriteFunction(self.type, value, itemParam.options)
                    net.SendToServer()
                end
            end
        end

        function p:DoRightClick()
            // Menus
            CloseDermaMenus()
            local menu = vgui.Create( "AShop_DMenu", p )

            for refundID, txt in ipairs({{
                ashop.L('WarningDeleteItem'),
                ashop.L('WarningDeleteItem'),
                ashop.L('WarningDeleteItem2')
            }, {
                ashop.L('WarningDeleteItemRefund'),
                ashop.L('WarningDeleteItemRefund'),
                ashop.L('WarningDeleteItemRefund2')
            }}) do
                menu:AddOption(txt[1], function()
                    ashop.ui.popAskbox(txt[2], txt[3], function()
                        net.Start('ashop_Item_Delete')
                            net.WriteUInt(k, ashop.Config.BitsItemID)
                            net.WriteBool(refundID == 1)
                        net.SendToServer()
                    end)
                end)
            end

            menu:AddOption(ashop.L('Duplicate'), function()
                net.Start('ashop_Item_New')
                    net.WriteUInt(key, ashop.Config.BitsObjectType)
        
                    net.WriteBool(v.sub_types)
        
                    if v.sub_types then
                        net.WriteUInt(v.sub_types, ashop.Config.BitsObjectType)
                    end
        
                    net.WriteString(v.name)
                    net.WriteUInt(v.rarity, ashop.Config.BitsRarity)
        
                    net.WriteBool(v.price)
                    if v.price then
                        net.WriteUInt(v.price, 32)
                    end
        
                    net.WriteBool(v.premium_price)
                    if v.premium_price then
                        net.WriteUInt(v.premium_price, 32)
                    end

                    net.WriteBool(v.deleteOnDeath)

                    net.WriteBool(v.promotion_start)
                    if v.promotion_start then
                        net.WriteUInt(v.promotion_start, 32)
                    end

                    net.WriteBool(v.promotion_end)
                    if v.promotion_end then
                        net.WriteUInt(v.promotion_end, 32)
                    end

                    net.WriteBool(v.promotion_amount != nil)
                    if v.promotion_amount != nil then
                        net.WriteUInt(v.promotion_amount, 7)
                    end

                    net.WriteBool(v.picture_link)
                    if v.picture_link then
                        net.WriteString(v.picture_link)
                    end

                    net.WriteBool(v.group_restrained)
                    if v.group_restrained then
                        net.WriteUInt(v.group_restrained, ashop.Config.BitsGroupRank)
                    end

                    net.WriteBool(v.expireTime)
                    if v.expireTime then
                        net.WriteUInt(v.expireTime, 32)
                    end
    
                    for k, itemParam in SortedPairs(ashop.object_types[key].ItemParameters) do
                        if itemParam.userEditable then continue end

                        if v.metadata[k] == nil then
                            net.WriteBool(false)
                        else
                            net.WriteBool(true)
                            ashop.Network.GetWriteFunction(itemParam.type, v.metadata[k], itemParam.options)
                        end
                    end
                net.SendToServer()
            end)

            menu:AddOption(ashop.L('ExportAsPremade'), function()
                local str = "        {"
                str = str .. '\n            name = "' .. v.name .. '",'
                str = str .. '\n            rendering = INSERT,'

                if !v.metadata then
                    str = str .. '\n            metadata = {}'
                else
                    str = str .. getFormatted(3, {metadata = v.metadata})
                end
                str = str .. "\n        },"

                print(str)
                SetClipboardText(str)
            end)

            menu:Open()
        end
    end

    for k, v in pairs(ashop.items) do
        createUIItem(k, v)
    end
    items:SizeToChildren(false, true)

    hook.Add('ashop_itemedit', 'refreshUI', function(item)
        if !IsValid(itemsByIDs[item]) then return end
        itemsByIDs[item]:SetItem(nil, item, true)
    end)

    hook.Add('ashop_itemnew', 'refreshUI', function(itemID, item)
        createUIItem(itemID, item)
    end)

    hook.Add('ashop_itemdelete', 'refreshUI', function(item)
        if !IsValid(itemsByIDs[item]) then return end
        itemsByIDs[item]:Remove()

        items:InvalidateLayout()
    end)
end

ashop.registerParameter(ashop.L('ObjectType'), DrawInterior, function()
    local o = {}

    for k, v in pairs(ashop.object_types) do
        if v.sub_cat then 
            for sub_cat, j in pairs(v.sub_cat) do
                table.insert(o, {j.name, k, {false, v, j, sub_cat}})
            end
        else
            if v.SubCategoriesParameters then continue end
            table.insert(o, {v.Name, k, {true, v}})
        end
    end

    return o
end, function()
    local selects = {}

    for k, v in pairs(ashop.object_types) do
        if v.NoChild or !v.DefaultSubCategories then continue end
        table.insert(selects, {v.Name, k})
    end

    local a = vgui.Create('AShop_Form', ashop.menu)
    a:SetTitle(ashop.L('CreateAObjectCategory'))
    a:CreateEntry(true, 'Name', TYPE_STRING, {
        maxLength = 24
    }).avoid = true
    
    local parent = a:CreateEntry(true, ashop.L('Parent'), 'SELECT', {
        selects = selects,
        default = ashop.L('SelectAParentType')
    })

    parent.avoid = true

    parent.OnValueChanged = function(s, index, name)
        for k, v in pairs(a.entries) do
            if !v.avoid then
                v:Remove()
            end
        end

        s:InvalidateLayout()

        if ashop.object_types[index].SlotDefault and !ashop.object_types[index].BlockSlotEdit then
            a:CreateEntry(true, ashop.L('HowMuchItemsAreEquipable'), "UInt5")
        end

        for k, v in pairs(ashop.object_types[index].SubCategoriesParameters or {}) do
            a:CreateEntry(true, v[1], v[2])
        end
    end

    function a:OnSend(name, index, ...)
        local t = {...}

        net.Start('ashop_SubCat_New')
            net.WriteString(name)
            net.WriteUInt(index, ashop.Config.BitsObjectType)

            if ashop.object_types[index].SlotDefault and !ashop.object_types[index].BlockSlotEdit then
                net.WriteUInt(t[1] or ashop.object_types[index].SlotDefault, 6)

                // Remove the first value of t, so w_bulk works correctly
                table.remove(t, 1)
            end

            local incr = 1
            for k, v in pairs(ashop.object_types[index].SubCategoriesParameters) do
                ashop.Network.GetWriteFunction(v[2], t[incr])
                incr = incr + 1
            end
        net.SendToServer()
    end
    a:Center()
end, function(but, settingButton, objectTarget)
    function but:DoRightClick()
        if !objectTarget[2].sub_cat then return end
        CloseDermaMenus()
        local menu = vgui.Create( "AShop_DMenu", but )

        menu:AddOption(ashop.L('Remove'), function()
            for k, v in pairs(ashop.items) do
                if v.object_types == objectTarget[2].id and v.sub_types == objectTarget[3].id then
                    ashop.DermaNotify(ashop.L('NeedToBeEmpty'), NOTIFY_ERROR, 3)
                    return
                end
            end

            ashop.ui.popAskbox(ashop.L('DeleteThisSubCategory', objectTarget[3].name), "", function()
                net.Start('ashop_ObjectType_Delete')
                    net.WriteUInt(objectTarget[2].id, ashop.Config.BitsObjectType)
                    net.WriteUInt(objectTarget[3].id, ashop.Config.BitsObjectType)
                net.SendToServer()
            end)
        end)

        menu:Open()
    end
end)