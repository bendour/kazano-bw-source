local waitingCallbacks = {}
local ranEntityCreate = {}

function ashop.ExecIfValidData(num, callback)
    local ply = Player(num)

    if IsValid(ply) then
        callback(ply)
    else
        waitingCallbacks[num] = waitingCallbacks[num] or {}
        table.insert(waitingCallbacks[num], callback)
    end
end

hook.Add("NetworkEntityCreated", "ashop_ExecCallbacks", function(ent)
    if ent:IsPlayer() and waitingCallbacks[ent:UserID()] then
        print("[AShop] Load callbacks for " .. ent:Nick())
        for k, v in ipairs(waitingCallbacks[ent:UserID()]) do
            v(ent)
        end

        waitingCallbacks[ent:UserID()] = nil
    end
end)

net.Receive('ashop_PrePlayerSyncFull', function()
    ashop.pac3 = ashop.pac3 or {}
    while(net.ReadBool()) do
        local id = net.ReadUInt(16)
        ashop.pac3[id] = ashop.Network.R_Pac3()
    end
end)

net.Receive('ashop_PlayerSyncFull', function()
    ashop.itemCounter = net.ReadUInt(32)
    ashop.BitsItem = math.ceil(math.log(ashop.itemCounter, 2))

    ashop.pac3 = ashop.pac3 or {}
    local lp = LocalPlayer()
    local unloaded = ashop.GetUnloadedTypes()

    local newObjectType = {}

    for i = 1, net.ReadUInt(ashop.Config.BitsObjectType) do
        local loopIndex, renderIDBy, slotSize, sqlIndex = net.ReadUInt(8), net.ReadUInt(ashop.Config.BitsRender), net.ReadUInt(6), net.ReadUInt(ashop.Config.BitsObjectType)
        local ot = unloaded[loopIndex]
        ot.renderIDBy = renderIDBy
        ot.slotSize = slotSize
        ot.id = sqlIndex
        newObjectType[sqlIndex] = ot
    end

    ashop.object_types = newObjectType

    local sub_cats = ashop.Network.R_Bulk(ashop.Network.R_SubCategory, 1, 12, 12)

    for k, v in pairs(sub_cats) do
        ashop.object_types[v.object_typeid].sub_cat = ashop.object_types[v.object_typeid].sub_cat or {}
        ashop.object_types[v.object_typeid].sub_cat[k] = v
    end

    ashop.refreshAShopIDTable()
    hook.Run('ashop_PostLoadObjectTypes')

    local ashop_data = {
        money_normal = net.ReadUInt(32),
        money_premium = net.ReadUInt(32),
        items = {}
        //items = ashop.Network.R_Bulk(ashop.Network.R_PlyItem, 1, 32, 12)
    }

    lp.ashop_data = ashop_data or {}

    ashop.rarity = ashop.Network.R_Bulk(ashop.Network.R_Rarity, 1, 8, 8)

    ashop.render = ashop.Network.R_Bulk(ashop.Network.R_Render, 1, 8, 6)

    ashop.weaponmaterials = ashop.Network.R_Bulk(ashop.Network.R_WeaponMaterials, 2, 10, 10)

    ashop.carmaterials = ashop.Network.R_Bulk(ashop.Network.R_CarMaterials, 2, 10, 10)

    ashop.currencies.trades = ashop.Network.R_Bulk(
        ashop.Network.R_CurrencyTrade,
        1, 10, 10
    )

    ashop.rankpromo = ashop.Network.R_Bulk(
        function() return net.ReadUInt(7) end,
        2, 10, 10
    )

    ashop.groupranks = {}
    for i = 1, net.ReadUInt(ashop.Config.BitsGroupRank) do
        local gp = ashop.Network.R_GroupRank()
        ashop.groupranks[gp.id] = gp
    end

    ashop.items = ashop.Network.R_Bulk(ashop.Network.R_ItemData, 1, 20, 20)

    for i = 1, net.ReadUInt(8) do
        local plyID = net.ReadUInt(13)
        local d = {
            items = {},
            equipped = {}
        }

        while(net.ReadBool()) do
            local slot_id = net.ReadUInt(4)
            local plyItem = ashop.Network.R_PlyItem()

            d.items[plyItem.id] = plyItem

            local item = ashop.items[plyItem.item_id]

            d.equipped[item.object_types] = d.equipped[item.object_types] or {}
            d.equipped[item.object_types][item.sub_types or 0] = d.equipped[item.object_types][item.sub_types or 0] or {}
            d.equipped[item.object_types][item.sub_types or 0][slot_id] = plyItem.id
        end

        ashop.ExecIfValidData(plyID, function(e)
            if e.ashop_data then
                table.Merge(e.ashop_data, d)
            else
                e.ashop_data = d
            end

            for _, objectTypes in pairs(d.equipped) do
                for objectTypesID, subCats in pairs(objectTypes) do
                    for slotID, slotItem in pairs(subCats) do
                        local plyItem = d.items[slotItem]
                        local item = ashop.items[plyItem.item_id]
                        local object_type = ashop.object_types[item.object_types]
    
                        hook.Run('ashop_equip', e, slotID, item, plyItem)
                        if object_type.OnEquip then
                            object_type.OnEquip(e, plyItem, item)
                        end
                    end
                end
            end
        end)
    end

    hook.Run('ashop_playersync')
end)

net.Receive('ashop_PlayerSyncMoney', function()
    local lp = LocalPlayer()
    local is_premium = net.ReadBool()
    local id = is_premium and "money_premium" or "money_normal"
    local amt = net.ReadUInt(32)
    lp.ashop_data[id] = amt

    lp.PS2_Wallet = lp.PS2_Wallet or {}
    if is_premium then
        lp.PS2_Wallet.premiumPoints = amt
    else
        lp.PS2_Wallet.points = amt
    end

    hook.Run('ashop_moneyChanged', id, amt)
end)

net.Receive('ashop_PlayerReceivedItem', function()
    local lp = LocalPlayer()
    assert(lp.ashop_data, "No player data")
    // He received a item
    local item = ashop.Network.R_PlyItem()
    lp.ashop_data.items[item.id] = item

    hook.Run('Ashop_PlayerNewItem', item.id, item, ashop.items[item.item_id])
end)

net.Receive('ashop_Item_New', function()
    while(net.ReadBool()) do
        local item = ashop.Network.R_ItemData()
        ashop.items[item.id] = item

        hook.Run('ashop_itemnew', item.id, item)
        ashop.NewItemBitsCounter(item.id)
    end
end)

net.Receive('ashop_PlayerEquippedItem', function()
    local e = net.ReadEntity()
    local plyItemID = net.ReadUInt(20)

    local itemTable = ashop.items[e.ashop_data.items[plyItemID].item_id]
    local objectType = ashop.object_types[itemTable.object_types]

    local slotNum = itemTable.sub_types and objectType.sub_cat[itemTable.sub_types].slotSize or objectType.slotSize
    local slot = net.ReadUInt(math.ceil(math.log(slotNum, 2)))

    ashop.EquipChange(e, plyItemID, slot, net.ReadBool())
end)

net.Receive('ashop_PlayerItem_MetaDataUpdate', function()
    local uid = net.ReadUInt(13)
    local id = net.ReadUInt(ashop.Config.BitsPlyItemID)

    for i = 1, net.ReadUInt(6) do
        local metaKey = net.ReadUInt(6)
        local isNotEmpty = net.ReadBool()
        local item_id = net.ReadUInt(ashop.Config.BitsPlyItemID)
        local itemTable = ashop.items[item_id]
        local o = ashop.object_types[itemTable.object_types]
        local new
        
        if isNotEmpty then
            local param = o.ItemParameters[metaKey]
            new = ashop.Network.GetReadFunction(param.type)
        end

        ashop.ExecIfValidData(uid, function(ply)
            local old = ply.ashop_data.items[id].metadata[metaKey]
            ply.ashop_data.items[id].metadata[metaKey] = new

            if o.OnMetadataUpdate then
                o.OnMetadataUpdate(ply, ply.ashop_data.items[id], itemTable, metaKey, old, new)
            end
        end)
    end
end)

net.Receive('ashop_Pac3_New', function()
    local id = net.ReadUInt(ashop.Config.BitsPac3)
    local data = ashop.Network.R_Pac3()
    ashop.pac3[id] = data
    hook.Run('ashop_refreshSettingsUI', 'Pac3')
end)

local luadata
net.Receive('ashop_Pac3_Edit', function()
    // Pac3 Edit
    if !luadata and file.Exists('pac3/libraries/luadata.lua', 'LUA') then
        luadata = include('pac3/libraries/luadata.lua')
    end

    assert(luadata, "There is pac3 data without pac3 installed")
    local entry = net.ReadUInt(2)
    local pac3ID = net.ReadUInt(ashop.Config.BitsPac3)

    if entry == 0 then
        value = ashop.Network.R_Compress()
        entry = "outfit_text"
        ashop.pac3[pac3ID]["outfit_text"] = value
        ashop.pac3[pac3ID]["outfit"] = luadata.Decode(ashop.pac3[pac3ID]["outfit_text"])
    elseif entry == 1 then
        value = net.ReadString()
        entry = "name"
        ashop.pac3[pac3ID]["name"] = value
    elseif entry == 2 then
        value = net.ReadBool()
        entry = "model_attach"
        ashop.pac3[pac3ID]["model_attach"] = value
    end

    hook.Run("ashop_pac3Edit", pac3ID, entry)

    hook.Run('ashop_refreshSettingsUI', 'Pac3')
end)

net.Receive('ashop_Render_Edit', function()
    // Render edit
    local b = net.ReadBool()
    local renderID = net.ReadUInt(ashop.Config.BitsRender)

    if !b then
        local objectTypeID = net.ReadUInt(ashop.Config.BitsObjectType)

        for k, v in pairs(ashop.render) do
            if v.cat[objectTypeID] then
                v.cat[objectTypeID] = nil
                break
            end
        end
        ashop.render[renderID].cat[objectTypeID] = true
        hook.Run("ashop_renderEdit", false, renderID, objectTypeID)
    else
        ashop.render[renderID].name = net.ReadString()
        hook.Run("ashop_renderEdit", true, renderID, ashop.render[renderID].name)
    end

    hook.Run('ashop_refreshSettingsUI', ashop.L('Renders'))
end)

net.Receive('ashop_Render_New', function()
    local id = net.ReadUInt(ashop.Config.BitsRender)

    ashop.render[id] = ashop.Network.R_Render()
    if table.IsEmpty(ashop.render[id].cat or {}) then return end

    for k, v in pairs(ashop.render) do
        if k == id then continue end

        for objectTypeID, _ in pairs(v.cat or {}) do
            if ashop.render[id].cat[objectTypeID] then
                ashop.render[k].cat[objectTypeID] = nil
            end
        end
    end

    hook.Run('ashop_refreshSettingsUI', ashop.L('Renders'))
end)

net.Receive('ashop_SubCat_New', function()
    // Create object_type
    local r = ashop.Network.R_SubCategory()

    ashop.object_types[r.object_typeid].sub_cat = ashop.object_types[r.object_typeid].sub_cat or {}
    ashop.object_types[r.object_typeid].sub_cat[r.id] = r

    hook.Run("ashop_createdobjecttype")
    hook.Run('ashop_refreshSettingsUI', ashop.L('ObjectType'))
end)

net.Receive('ashop_Item_Edit', function()
    // Edit a item
    if !ashop.items then return end

    local inputID = net.ReadUInt(7)
    local item = net.ReadUInt(ashop.Config.BitsItemID)
    local itemTable = ashop.items[item]

    if inputID <= 11 then
        if inputID == 1 then
            itemTable['name'] = net.ReadString()
        elseif inputID == 2 then
            itemTable['rarity'] = net.ReadUInt(ashop.Config.BitsRarity)
        elseif inputID == 3 or inputID == 4 then
            itemTable[inputID == 4 and 'premium_price' or 'price'] = net.ReadBool() and net.ReadUInt(32) or nil
        elseif inputID == 5 then
            itemTable['delete_death'] = net.ReadBool()
        elseif inputID == 6 or inputID == 7 then
            itemTable[inputID == 7 and 'promotion_end' or 'promotion_start'] = (net.ReadBool() and net.ReadUInt(32) or nil)
        elseif inputID == 8 then
            itemTable['promotion_amount'] = (net.ReadBool() and net.ReadUInt(7) or nil)
        elseif inputID == 9 then
            itemTable['picture_link'] = (net.ReadBool() and net.ReadString() or nil)
        elseif inputID == 10 then
            itemTable['group_restrained'] = (net.ReadBool() and net.ReadUInt(10) or nil)
        elseif inputID == 11 then
            itemTable['expireTime'] = (net.ReadBool() and net.ReadUInt(32) or nil)
        else
            error('No valid inputID')
        end
    else
        local realID = inputID - 11
        local param = ashop.object_types[itemTable.object_types].ItemParameters[realID]
        itemTable.metadata[realID] = ashop.Network.GetReadFunction(param.type, param.options)
    end

    hook.Run('ashop_itemedit', item, itemTable)
end)

net.Receive('ashop_PlayerLostItem', function()
    // RemoveOwned
    local itemID = net.ReadUInt(ashop.Config.BitsPlyItemID)
    local item = LocalPlayer().ashop_data.items[itemID]

    hook.Run('Ashop_PlayerRemoveItem', item.id, item, ashop.items[item.item_id])
    LocalPlayer().ashop_data.items[itemID] = nil
end)

net.Receive("ashop_PlayerDeleteItemBulk", function()
    local lply = LocalPlayer()
    
    for i = 1, net.ReadUInt(9) do
        local id = net.ReadUInt(ashop.Config.BitsPlyItemID)
        lply.ashop_data.items[id] = nil
    end
end)

net.Receive('ashop_Item_Delete', function()
    local id = net.ReadUInt(ashop.Config.BitsItemID)
    ashop.items[id] = nil
    hook.Run('ashop_itemdelete', id)
end)

net.Receive('ashop_Rarity_New', function()
    local rarity = ashop.Network.R_Rarity()
    ashop.rarity[rarity.id] = rarity

    hook.Run('ashop_refreshSettingsUI', ashop.L('Rarity'))
end)

net.Receive('ashop_Rarity_Edit', function()
    local uid = net.ReadUInt(3)
    local rarityID = net.ReadUInt(ashop.Config.BitsRarity)

    if uid == 0 then
        ashop.rarity[rarityID]['name'] = net.ReadString()
    elseif uid == 1 then
        local clr = net.ReadColor()
        ashop.rarity[rarityID].clr = clr
        ashop.rarity[rarityID].r = clr.r
        ashop.rarity[rarityID].g = clr.g
        ashop.rarity[rarityID].b = clr.b
    elseif uid == 2 then
        ashop.rarity[rarityID].style = net.ReadUInt(8)
    elseif uid == 3 then
        ashop.rarity[rarityID].notif_unbox = net.ReadBool()
    elseif uid == 4 then
        ashop.rarity[rarityID].notif_unboxsound = nil
        if net.ReadBool() then
            ashop.rarity[rarityID].notif_unboxsound = net.ReadString()
        end
    end

    hook.Run('ashop_refreshSettingsUI', ashop.L('Rarity'), rarityID)
end)

net.Receive('ashop_WeaponMaterial_Edit', function()
    local wep = net.ReadString()
    local b = net.ReadBool()
    local wm = net.ReadBool()
    local id = net.ReadUInt(8)

    local key2 = wm and "wm" or "vm"
    ashop.weaponmaterials[wep] = ashop.weaponmaterials[wep] or {}
    ashop.weaponmaterials[wep][key2] = ashop.weaponmaterials[wep][key2] or {}
    ashop.weaponmaterials[wep][key2][id] = b and true or nil
end)

net.Receive('ashop_WeaponMaterial_EditBulk', function()
    while(net.ReadBool()) do
        local s = net.ReadString()
        local vm, wm = {}, {}

        for i = 1, net.ReadUInt(8) do
            vm[net.ReadUInt(8)] = true
        end

        for i = 1, net.ReadUInt(8) do
            wm[net.ReadUInt(8)] = true
        end

        ashop.weaponmaterials[s] = {
            wm = wm,
            vm = vm
        }
    end

    hook.Run('ashop_refreshSettingsUI', ashop.L('WeaponSkins'))
end)

net.Receive('ashop_WeaponMaterial_Create', function()
    ashop.weaponmaterials[net.ReadString()] = ashop.Network.R_WeaponMaterials()
    hook.Run('ashop_refreshSettingsUI', ashop.L('WeaponSkins'))
end)

net.Receive('ashop_CarMaterial_Create', function()
    ashop.carmaterials[net.ReadString()] = ashop.Network.R_CarMaterials()
    hook.Run('ashop_refreshSettingsUI', ashop.L('CarSkins'))
end)

net.Receive('ashop_CarMaterial_Delete', function()
    ashop.carmaterials[net.ReadString()] = nil
    hook.Run('ashop_refreshSettingsUI', ashop.L('CarSkins'))
end)

net.Receive('ashop_CarMaterial_Edit', function()
    local car = net.ReadString()
    local b = net.ReadBool()
    local id = net.ReadUInt(8)

    ashop.carmaterials[car] = ashop.carmaterials[car] or {}
    ashop.carmaterials[car][id] = b and true or nil
end)

net.Receive('ashop_Rarity_Delete', function()
    ashop.rarity[net.ReadUInt(ashop.Config.BitsRarity)] = nil
    hook.Run('ashop_refreshSettingsUI', ashop.L('Rarity'))
end)

net.Receive('ashop_PlayerEquippedItem_Bulk', function()
    local plyID = net.ReadUInt(13)
    local loopData = {}

    for i = 1, net.ReadUInt(7) do
        local item_id = net.ReadUInt(ashop.Config.BitsPlyItemID)
        local slot_id = net.ReadUInt(6)
        loopData[i] = {item_id, slot_id}
    end

    ashop.ExecIfValidData(plyID, function(e)
        for _, v in ipairs(loopData) do
            local itemID = v[1]
            local slot_id = v[2]

            e.ashop_data = e.ashop_data or {}
            e.ashop_data.equipped = e.ashop_data.equipped or {}
            e.ashop_data.items = e.ashop_data.items or {}

            local plyItem = e.ashop_data.items[itemID]

            if !plyItem then
                print('[AShop] Unknown plyItem, infos you can report: ')
                print('ItemID: ', itemID, ". Is known: ", ashop.items[itemID] != nil)
                print('How much items are known related to this player: ', table.Count(e.ashop_data.items))
                return
            end

            local item = ashop.items[plyItem.item_id]
            local object_type = ashop.object_types[item.object_types]

            e.ashop_data.equipped = e.ashop_data.equipped or {}
    
            e.ashop_data.equipped[item.object_types] = e.ashop_data.equipped[item.object_types] or {}
            e.ashop_data.equipped[item.object_types][item.sub_types or 0] = e.ashop_data.equipped[item.object_types][item.sub_types or 0] or {}
            e.ashop_data.equipped[item.object_types][item.sub_types or 0][slot_id] = itemID
    
            hook.Run('ashop_equip', e, slot_id, item, plyItem)
    
            if object_type.OnEquip then
                object_type.OnEquip(e, plyItem, item)
            end
        end
    end)
end)

net.Receive('ashop_ObjectType_Edit', function()
    local isMain = net.ReadBool()
    local object_typeID = net.ReadUInt(ashop.Config.BitsObjectType)
    local subID = !isMain and net.ReadUInt(ashop.Config.BitsObjectType) or nil

    local b = net.ReadBool()
    local value, sqlColumn

    if !b then
        value = ashop.Network.GetReadFunction(TYPE_STRING)
        sqlColumn = "name"
    else
        value = ashop.Network.GetReadFunction("UInt8")
        sqlColumn = "slotSize"
    end

    if isMain then
        // I should have fixed this right after noticing it
        ashop.object_types[object_typeID][!b and 'Name' or sqlColumn] = value
    else
        assert(ashop.object_types[object_typeID].sub_cat, "No SubCat while editing a sub category")
        ashop.object_types[object_typeID].sub_cat[subID][sqlColumn] = value
    end

    hook.Run('ashop_refreshSettingsUI', ashop.L('ObjectType'))
end)

net.Receive('ashop_SubObjectType_Edit', function()
    local objectTypeID = net.ReadUInt(ashop.Config.BitsObjectType)
    local subID = net.ReadUInt(ashop.Config.BitsObjectType)
    local paramID = net.ReadUInt(7)

    local objectTypeTable = ashop.object_types[objectTypeID]
    local param = objectTypeTable.SubCategoriesParameters[paramID]

    objectTypeTable.sub_cat[subID].metadata[paramID] = ashop.Network.GetReadFunction(param[2], {
        required = true
    })

    hook.Run('ashop_refreshSettingsUI', ashop.L('ObjectType'))
end)

net.Receive('ashop_PlyItem_New', function()
    local ply = net.ReadUInt(13)
    local items = {}

    while(net.ReadBool()) do
        local plyItem = ashop.Network.R_PlyItem()
        items[plyItem.id] = plyItem
    end

    ashop.ExecIfValidData(ply, function(e)
        e.ashop_data = e.ashop_data or {}
        e.ashop_data.items = e.ashop_data.items or {}
        table.Merge(e.ashop_data.items, items)
    end)
end)

net.Receive('ashop_Currency_New', function()
    local trade = ashop.Network.R_CurrencyTrade()
    ashop.currencies.trades[trade.id] = trade

    hook.Run('ashop_refreshSettingsUI', ashop.L('Currencies'))
end)

net.Receive('ashop_Currency_Edit', function()
    local id = net.ReadUInt(10)
    local act = net.ReadUInt(3)
    local trade = ashop.currencies.trades[id]
    
    if act == 1 or act == 3 then
        trade[act == 1 and 'toCoins' or 'toPremium'] = net.ReadBool()
    elseif act == 2 then
        //trade.convertRate = net.ReadFloat()
        trade.convertRate = tonumber(net.ReadString())
    else
        trade.currencyName = net.ReadString()
    end

    hook.Run('ashop_refreshSettingsUI', ashop.L('Currencies'))
end)

net.Receive('ashop_Admin_ReceiveInventory', function()
    local premiumMoney = net.ReadUInt(32)
    local classicMoney = net.ReadUInt(32)
    
    local ply = net.ReadString()
    while(net.ReadBool()) do
        local item = ashop.Network.R_ItemData()
        ashop.items[item.id] = item
    end
    
    local plyItems = ashop.Network.R_Bulk(ashop.Network.R_PlyItemFull, 1, 32, 12)
    
    hook.Run('ashop_receivedPlayerInventory', ply, plyItems, premiumMoney, classicMoney)
end)

net.Receive('ashop_Admin_ReceiveInventoryMoney', function()
    hook.Run('ashop_receivedPlayerInventoryMoney', net.ReadUInt(32), net.ReadBool())
end)

net.Receive('ashop_Admin_ReceiveInventoryItemData', function()
    local itemID = net.ReadUInt(ashop.Config.BitsPlyItemID)
    local id = net.ReadUInt(3)
    hook.Run('ashop_receivedPlayerInventoryItemData', id, itemID, id != 1 and net.ReadUInt(ashop.Config.BitsPlyItemID) or nil)
end)

net.Receive('ashop_PlayerReceivedItemBulk', function()
    local lp = LocalPlayer()
    assert(lp.ashop_data, "No player data")
    
    for j = 1, net.ReadUInt(9) do
        local item = ashop.Network.R_ItemData()
        ashop.items[item.id] = item
    end
    
    for i = 1, net.ReadUInt(9) do
        local item = ashop.Network.R_PlyItem()
        lp.ashop_data.items[item.id] = item
        hook.Run('Ashop_PlayerNewItem', item.id, item, ashop.items[item.item_id])
    end
end)

net.Receive('ashop_GroupRanks_New', function()
    ashop.groupranks = ashop.groupranks or {}
    
    while(net.ReadBool()) do
        local r = ashop.Network.R_GroupRank()
        ashop.groupranks[r.id] = r
    end

    hook.Run('ashop_refreshSettingsUI', ashop.L('RankGroups'))
end)

net.Receive('ashop_GroupRanks_Edit', function()
    local id = net.ReadUInt(ashop.Config.BitsGroupRank)
    if !ashop.groupranks[id] then return end
    local actID = net.ReadUInt(3)

    if actID == 0 then
        ashop.groupranks[id]['name'] = net.ReadString()
    elseif actID == 1 or actID == 2 then
        ashop.groupranks[id][actID == 2 and 'messageOnFail' or 'desc'] = net.ReadBool() and net.ReadString() or nil
    elseif actID == 3 or actID == 4 then
        ashop.groupranks[id][actID == 3 and 'freePerTime' or 'premiumPerTime'] = net.ReadBool() and net.ReadUInt(16) or nil
    else
        local t = {}

        while(net.ReadBool()) do
            t[net.ReadString()] = true
        end
        ashop.groupranks[id]['ranks'] = t
    end

    hook.Run('ashop_refreshSettingsUI', ashop.L('RankGroups'))
end)

net.Receive('ashop_Pac3_Delete', function()
    ashop.pac3[net.ReadUInt(ashop.Config.BitsPac3)] = nil

    hook.Run('ashop_refreshSettingsUI', 'Pac3')
end)

net.Receive('ashop_Currency_Delete', function()
    ashop.pac3[net.ReadUInt(8)] = nil
    hook.Run('ashop_refreshSettingsUI', ashop.L('Currencies'))
end)

net.Receive('ashop_WeaponMaterial_Delete', function()
    ashop.weaponmaterials[net.ReadString()] = nil
    hook.Run('ashop_refreshSettingsUI', ashop.L('WeaponSkins'))
end)

net.Receive('ashop_GroupRanks_Delete', function()
    ashop.groupranks[net.ReadUInt(ashop.Config.BitsGroupRank)] = nil
    hook.Run('ashop_refreshSettingsUI', ashop.L('RankGroups'))
end)

net.Receive('ashop_Render_Delete', function()
    ashop.render[net.ReadUInt(ashop.Config.BitsRender)] = nil
    hook.Run('ashop_refreshSettingsUI', ashop.L('Renders'))
end)

net.Receive('ashop_ObjectType_Delete', function()
    local objType = net.ReadUInt(ashop.Config.BitsObjectType)
    ashop.object_types[objType].sub_cat[net.ReadUInt(ashop.Config.BitsObjectType)] = nil
    hook.Run('ashop_refreshSettingsUI', ashop.L('ObjectType'))
end)

net.Receive('ashop_RankPromotion_Create', function()
    ashop.rankpromo[net.ReadString()] = net.ReadUInt(ashop.Config.BitsRankPromotion)
    hook.Run('ashop_refreshSettingsUI', ashop.L('RankPromo'))
end)

net.Receive('ashop_RankPromotion_Edit', function()
    local old = net.ReadString()
    local new = net.ReadString()

    ashop.rankpromo[new] = ashop.rankpromo[old]
    ashop.rankpromo[old] = nil

    hook.Run('ashop_refreshSettingsUI', ashop.L('RankPromo'))
end)

net.Receive('ashop_RankPromotion_Delete', function()
    ashop.rankpromo[net.ReadString()] = nil

    hook.Run('ashop_refreshSettingsUI', ashop.L('RankPromo'))
end)