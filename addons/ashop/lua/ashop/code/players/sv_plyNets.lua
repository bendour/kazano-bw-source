ashop.SafeNet('Pac3_Edit', function(ply)
    local id = net.ReadUInt(3)
    local pac3 = net.ReadUInt(ashop.Config.BitsPac3)

    if !ashop.pac3[pac3] or id > 2 then return end
    local n = ashop.pac3[pac3].name

    local val
    if id == 0 then
        val = ashop.Network.R_Compress()
    elseif id == 1 then
        val = net.ReadString()
    elseif id == 2 then
        val = net.ReadBool()
    else
        error('Invalid arg')
    end
    ashop.Pac3Update(pac3, id, val)

    ashop.Logs.PushLog(ashop.Logs.IDs.Pac3_Update, n, ply)
end, nil, true)

ashop.SafeNet('Pac3_New', function(ply)
    local name = net.ReadString()
    local model_attach = net.ReadBool()
    local pac3 = ashop.Network.R_Compress()

    ashop.Pac3Create(name, pac3, model_attach)

    ashop.Logs.PushLog(ashop.Logs.IDs.Pac3_Create, name, ply)
end, nil, true)

ashop.SafeNet('Rarity_New', function(ply)
    local name = net.ReadString()
    local clr = net.ReadColor()
    local style = net.ReadBool() and net.ReadUInt(8) or nil
    local notifs_unbox = net.ReadBool()

    ashop.CreateRarity(name, clr, style, notifs_unbox)
end, nil, true)

ashop.SafeNet('Rarity_Edit', function(ply)
    local uid = net.ReadUInt(3)
    local rarityID = net.ReadUInt(ashop.Config.BitsRarity)

    if !ashop.rarity[rarityID] then return end

    local value, sqlvalue, sqlcolumn, netWrite

    if uid == 0 then
        value = net.ReadString()
        sqlcolumn = "name"
        sqlvalue = value
        netWrite = net.WriteString
        assert(string.len(value) <= 24, "Too long name")
        ashop.rarity[rarityID]['name'] = value
    elseif uid == 1 then
        value = net.ReadColor()
        sqlcolumn = "r, g, b"
        sqlvalue = value.r .. "," .. value.g .. "," .. value.b
        netWrite = net.WriteColor
        ashop.rarity[rarityID].r = value.r
        ashop.rarity[rarityID].g = value.g
        ashop.rarity[rarityID].b = value.b
    elseif uid == 2 then
        value = net.ReadUInt(8)
        sqlcolumn = "style"
        sqlvalue = value
        netWrite = function(d) net.WriteUInt(d, 8) end
        ashop.rarity[rarityID]['style'] = value
    elseif uid == 3 then
        value = net.ReadBool()
        sqlcolumn = "notif_unbox"
        sqlvalue = value and 1 or 0
        netWrite = net.WriteBool
        ashop.rarity[rarityID]['notif_unbox'] = value
    elseif uid == 4 then
        value = net.ReadString()
        sqlcolumn = "notif_unboxsound"
        sqlvalue = value or "NULL"
        netWrite = function(d) net.WriteBool(value) net.WriteString(value) end
        ashop.rarity[rarityID]['notif_unboxsound'] = value
    end

    if uid == 1 then
        ashop.SQL.query('UPDATE ashop_rarity SET r = ' .. value.r .. ', g=' .. value.g .. ',b=' .. value.b .. ' WHERE id = ' .. rarityID)
    else
        ashop.SQL.query('UPDATE ashop_rarity SET ' .. sqlcolumn .. ' = ' .. ashop.SQL.escape(sqlvalue) .. ' WHERE id = ' .. rarityID)
    end

    net.Start('ashop_Rarity_Edit')
        net.WriteUInt(uid, 3)
        net.WriteUInt(rarityID, ashop.Config.BitsRarity)
        netWrite(value)
    net.Broadcast()
end, nil, true)

ashop.SafeNet('Rarity_Delete', function()
    local r = net.ReadUInt(ashop.Config.BitsRarity)
    local rarity = ashop.rarity[r]
    if !rarity then return end

    local rarityName = rarity.name

    ashop.DeleteRarity(r)
    ashop.Logs.PushLog(ashop.Logs.IDs.Rarity_Delete, rarityName, ply)
end, nil, true)

util.AddNetworkString('ashop_buy')
ashop.SafeNet('buy', function(ply)
    local itemID = net.ReadUInt(ashop.Config.BitsItemID)
    local isPremium = net.ReadBool()
    
    local r = ashop.actions.Buy(ply, itemID, isPremium)
    if r then
        print(r)
    end
end)

ashop.SafeNet('Item_Delete', function(ply)
    local id = net.ReadUInt(ashop.Config.BitsItemID)
    local item = ashop.items[id]

    if !item then return end

    local itemName = item.name
    ashop.Logs.PushLog(ashop.Logs.IDs.Item_Delete, itemName, ply)
    ashop.DeleteItem(id, net.ReadBool(), ply)
end, nil, true)

ashop.SafeNet('Item_Edit', function(ply)
    local inputID = net.ReadUInt(7)
    local item = net.ReadUInt(ashop.Config.BitsItemID)
    
    local itemTable = ashop.items[item]
    if !itemTable then return end

    if inputID == 1 then
        ashop.ChangeItemValue(item, inputID, net.ReadString())
    elseif inputID == 9 then
        local s = net.ReadBool() and net.ReadString() or nil
        ashop.ChangeItemValue(item, inputID, s)
    elseif inputID == 2 then
        local d = net.ReadUInt(ashop.Config.BitsRarity)
        ashop.ChangeItemValue(item, inputID, d)
    elseif inputID == 3 or inputID == 4 or inputID == 8 then
        local value = net.ReadBool() and net.ReadUInt(inputID == 8 and 7 or 32) or nil
        ashop.ChangeItemValue(item, inputID, value)
    elseif inputID == 5 then
        ashop.ChangeItemValue(item, inputID, net.ReadBool())
    elseif inputID == 6 or inputID == 7 or inputID == 11 then
        ashop.ChangeItemValue(item, inputID, net.ReadBool() and net.ReadUInt(32) or nil)
    elseif inputID == 10 then
        local data = ashop.Network.GetReadFunction('SELECT', {selects = ashop.GetGroupRestrictsAsSelect() or {}, outputType = 'UInt10', hideSave = false, itemNameParam = "group_restrained"})
        ashop.ChangeItemValue(item, inputID, data)
    elseif inputID > 11 then
        local realID = inputID - 11
        local param = ashop.object_types[itemTable.object_types].ItemParameters[realID]

        if !param then return end

        local value = ashop.Network.GetReadFunction(param.type, param.options)

        assert(ashop.VerifyInput(value, param.type, param.options), "Value does not respect options: " .. param.name)
        ashop.ChangeItemValue(item, inputID, value)
    end

    ashop.Logs.PushLog(ashop.Logs.IDs.Item_Update, itemTable.name, ply)
end, nil, true)

ashop.SafeNet('Item_New', function(ply)
    local object_type = net.ReadUInt(ashop.Config.BitsObjectType)

    if !ashop.object_types[object_type] then
        print("[AShop] Object type sent in Item_New does not exist")
        return
    end
    local sub_type

    if net.ReadBool() then
        sub_type = net.ReadUInt(ashop.Config.BitsObjectType)
    end

    local name = net.ReadString()
    local rarity = net.ReadUInt(ashop.Config.BitsRarity)
    local price = net.ReadBool() and net.ReadUInt(32) or nil
    local premium_price = net.ReadBool() and net.ReadUInt(32) or nil
    local deleteOnDeath = net.ReadBool()
    local promotion_start = net.ReadBool() and net.ReadUInt(32) or nil
    local promotion_end = net.ReadBool() and net.ReadUInt(32) or nil
    local promotion_amount = net.ReadBool() and net.ReadUInt(7) or nil
    local picture_link = net.ReadBool() and net.ReadString() or nil
    local group_restrained = net.ReadBool() and net.ReadUInt(ashop.Config.BitsGroupRank) or nil
    local expireTime = net.ReadBool() and net.ReadUInt(32) or nil

    local itemParams = {}
    for k, v in SortedPairs(ashop.object_types[object_type].ItemParameters) do
        if v.userEditable then continue end

        if net.ReadBool() then
            itemParams[k] = ashop.Network.GetReadFunction(v.type, v.options)
        end
    end

    local res = ashop.CreateItem(object_type, sub_type, name,
    price, premium_price, itemParams, rarity, promotion_start, promotion_end, promotion_amount, picture_link, deleteOnDeath, group_restrained, expireTime)

    if !res then
        ashop.Logs.PushLog(ashop.Logs.IDs.Item_Create, ply, name)
    else
        print('[Error when creating object]: ', res)
    end
end, nil, true)

ashop.SafeNet('Render_New', function(ply)
    local name = net.ReadString()
    local c = ashop.Network.R_Bulk(function()
        return net.ReadBool()
    end, 0, ashop.Config.BitsObjectType, ashop.Config.BitsObjectType)

    ashop.CreateRender(name, c)

    ashop.Logs.PushLog(ashop.Logs.IDs.Render_Create, name, ply)
end, nil, true)

ashop.SafeNet('Render_Edit', function(ply)
    local nameEdit = net.ReadBool()
    local renderID = net.ReadUInt(ashop.Config.BitsRender)
    local name = ashop.render[renderID].name
    ashop.EditRender(renderID, nameEdit, nameEdit and net.ReadString() or net.ReadUInt(ashop.Config.BitsObjectType))
    ashop.Logs.PushLog(ashop.Logs.IDs.Render_Edit, name, ply)
end, nil, true)

ashop.SafeNet('SubCat_New', function(ply)
    local name = net.ReadString()
    local index = net.ReadUInt(ashop.Config.BitsObjectType)

    if !ashop.object_types[index] then return end

    local slotDefault
    if ashop.object_types[index].SlotDefault then
        if !ashop.object_types[index].BlockSlotEdit then
            slotDefault = net.ReadUInt(6)
        else
            slotDefault = ashop.object_types[index].SlotDefault
        end
    end

    ashop.CreateObjectType(name, index, slotDefault)

    ashop.Logs.PushLog(ashop.Logs.IDs.ObjectType_Create, name, ply)
end, 1, true)