local white = ashop.GetColor('White')

ashop.premades = ashop.premades or {}

function ashop.RegisterPremade(name, t)
    ashop.premades[name] = t
end

local function callback1(IDtoObjectTypesData, missingObjectTypes, selectItems, value, items, unloadableItems, itemWidth, editor)
    local function callback()
        local selected = {}

        local saveMe = vgui.Create('DButton', selectItems)
        saveMe:Dock(RIGHT)
        saveMe:SetFont('ashop_14_600')
        saveMe:SetTextColor(white)
        saveMe:SetText(ashop.L('ClickHereToSaveSelection'))
        saveMe:SetWide(saveMe:GetContentSize())
        saveMe:SetPaintBackground(false)

        saveMe.DoClick = function()
            for k, v in pairs(selected) do
                net.Start('ashop_Item_New')
                    net.WriteUInt(v.object_types, ashop.Config.BitsObjectType)
        
                    net.WriteBool(v.sub_cat != nil)
        
                    if v.sub_cat != nil then
                        net.WriteUInt(v.sub_cat, ashop.Config.BitsObjectType)
                    end
        
                    net.WriteString(v.name)
                    net.WriteUInt(v.rarity, ashop.Config.BitsRarity)

                    net.WriteBool(false)
                    net.WriteBool(false)
                    net.WriteBool(false)
                    net.WriteBool(false)
                    net.WriteBool(false)
                    net.WriteBool(false)
                    net.WriteBool(false)
                    net.WriteBool(false)
                    net.WriteBool(false)

                    for k, itemParam in SortedPairs(ashop.object_types[v.object_types].ItemParameters) do
                        if itemParam.userEditable then continue end

                        if v.metadata[k] == nil then
                            net.WriteBool(false)
                        else
                            net.WriteBool(true)
                            ashop.Network.GetWriteFunction(itemParam.type, v.metadata[k], itemParam.options)
                        end
                    end
                net.SendToServer()
            end
            editor:Clear()
        end

        for k, v in pairs(value.items) do
            if !IDtoObjectTypesData[v.rendering] then
                unloadableItems = unloadableItems + 1
                continue
            end

            // Derma
            local itemTbl = {
                rarity = ashop.FindFirstRarity(),
                name = v.name,
                object_types = IDtoObjectTypesData[v.rendering][1],
                sub_cat = IDtoObjectTypesData[v.rendering][2],
                metadata = v.metadata
            }

            local p = vgui.Create("AShop_ShopItem", items)
            p:SetSize(itemWidth, ashop.GetSize(189))
            
            function p:Paint()
                p:SetItem(nil, itemTbl, true)
            end

            function p:DoClick()
                if selected[k] then
                    selected[k] = nil
                    self.isEquipped = nil
                else
                    selected[k] = itemTbl
                    self.isEquipped = true
                end
            end
        end
    end

    if table.Count(IDtoObjectTypesData) == table.Count(missingObjectTypes) then
        callback()
    else
        ashop.ui.popAskbox(ashop.L('CreateMissingSubCat'), ashop.L('NeededToCreateProperly'), function()
            local count = 0
            // Il ne créer pas ici
            hook.Add("ashop_createdobjecttype", "checkPremade", function()
                count = count - 1

                if count <= 0 then
                    callback()
                end
            end)
        end, callback)
    end
end

local function callback2(editor, wepKey, value, parent)
    local marginVertical = ashop.GetSize(20)
    local selectItems = vgui.Create('DLabel', editor)
    selectItems:Dock(TOP)
    selectItems:SetFont('ashop_14_600')
    selectItems:SetTextColor(white)
    selectItems:SetTall(select(2, selectItems:GetContentSize()))
    selectItems:SetText(ashop.L('SelectItemsToImport'))
    selectItems:SetMouseInputEnabled(true)

    local scroll = vgui.Create("DScrollPanel", editor)
    scroll:Dock(FILL)
    local vbar = scroll:GetVBar()
    vbar:SetWide(1)
    function vbar.btnUp:Paint() end
    function vbar.btnDown:Paint() end
    function vbar:Paint(w, h) end

    local stateOff = ashop.GetColor('StateOff')
    function vbar.btnGrip:Paint(w, h)
        DisableClipping(true)
        draw.RoundedBox(2, w + 4, 0, 2, h, stateOff)
        DisableClipping(false)
    end

    local items = vgui.Create('DIconLayout', scroll)
    items:Dock(TOP)
    items:SetSpaceY(marginVertical)
    items:SetSpaceX(marginVertical)
    items:DockMargin(0, 0, 0, 0)

    local itemWidth = math.floor((editor:GetWide() - marginVertical * 6) / 7) - 1

    // Missing object_types
    local IDtoObjectTypesData = {}
    local missingObjectTypes = table.Copy(value.objectTypes)
    local unloadableItems = 0
    local selectCategories = {}

    for k, v in ipairs(missingObjectTypes) do
        local good, objectTypeID, objectType = pcall(ashop.GetObjectTypeIDByUID, v[1])

        if !good then
            ashop.DermaNotify(ashop.L('ObjectTypeXIsMissing', v[1]), NOTIFY_ERROR, 6)
            missingObjectTypes[k] = nil
        end

        // Great, no sub_type, the best thing to happens
        if !v[2] then
            IDtoObjectTypesData[k] = {objectTypeID}
            continue
        end

        // Search if we can find any matching sub_type with same data
        for subCatID, subCatValues in pairs(objectType.sub_cat) do
            local cont = false

            for k, v in pairs(v[2]) do
                if v != subCatValues.metadata[k] then
                    cont = true
                    break
                end
            end

            if cont then continue end

            //IDtoObjectTypesData[k] = {objectTypeID, subCatID}
            selectCategories[k] = selectCategories[k] or {}
            table.insert(selectCategories[k], {objectTypeID, subCatID, subCatValues.name})
            //break
        end
    end

    if unloadableItems > 0 then
        ashop.DermaNotify(ashop.L('XItemsCouldntBeLoaded', unloadableItems), NOTIFY_HINT, 4)
    end

    if !table.IsEmpty(selectCategories) then
        local a = vgui.Create('AShop_Form', ashop.menu)
        a:SetTitle(ashop.L('WhichExistingCat'))

        for k, v in pairs(selectCategories) do
            local createList = {}

            for _, selectCat in pairs(v) do
                table.insert(createList, {selectCat[3], selectCat})
            end

            // Input list
            a:CreateEntry(true, ashop.L('UsedCatForX', missingObjectTypes[k][3]), 'SELECT', {selects = createList, required = true})
        end

        function a:OnSend(...)
            local t = {...}

            for k, v in pairs(selectCategories) do
                IDtoObjectTypesData[k] = {t[k][1], t[k][2]}
            end

            callback1(IDtoObjectTypesData, missingObjectTypes, selectItems, value, items, unloadableItems, itemWidth, editor)
        end

        a:Center()
    else
        callback1(IDtoObjectTypesData, missingObjectTypes, selectItems, value, items, unloadableItems, itemWidth, editor)
    end

    function editor:OnRemove()
        hook.Remove("ashop_createdobjecttype", "checkPremade")
    end
end

local function DrawInterior(editor, wepKey, value, parent)
    if value.requireWorkshop and value.requireWorkshop != "" then
        ashop.ui.popAskbox(ashop.L('RequireWorkshop'), ashop.L('AcceptToOpenPopup'), function()
            gui.OpenURL("https://steamcommunity.com/workshop/filedetails/?id=" .. value.requireWorkshop)
            callback2(editor, wepKey, value, parent)
        end, function()
            callback2(editor, wepKey, value, parent)
        end)
    else
        callback2(editor, wepKey, value, parent)
    end
end

ashop.registerParameter('Premades', DrawInterior, function()
    local o = {}

    for k, v in pairs(ashop.premades) do
        table.insert(o, {k, k, v})
    end

    return o
end)