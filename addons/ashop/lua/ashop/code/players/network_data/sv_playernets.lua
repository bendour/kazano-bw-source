ashop.Network = ashop.Network or {}

function ashop.Network.W_Render(t)
    net.WriteString(t.name)

    ashop.Network.W_Bulk(
        table.GetKeys(t.cat or {}),
        function(t)
            net.WriteUInt(t, ashop.Config.BitsObjectType)
        end,
        0, 8, 6
    )
end

function ashop.Network.W_GroupRank(t)
    net.WriteString(t.name)

    net.WriteBool(t.desc)
    if t.desc then
        net.WriteString(t.desc)
    end

    net.WriteBool(t.messageOnFail)
    if t.messageOnFail then
        net.WriteString(t.messageOnFail)
    end

    net.WriteUInt(t.id, ashop.Config.BitsGroupRank)

    net.WriteBool(t.freePerTime != nil)
    if t.freePerTime != nil then
        net.WriteUInt(t.freePerTime, 16)
    end

    net.WriteBool(t.premiumPerTime != nil)
    if t.premiumPerTime != nil then
        net.WriteUInt(t.premiumPerTime, 16)
    end

    ashop.Network.W_Bulk(
        table.GetKeys(t.ranks),
        function(t)
            net.WriteString(t)
        end,
        0, 8, 6
    )
end

function ashop.Network.W_WeaponMaterials(t)
    net.WriteUInt(table.Count(t.vm), 8)

    for k, v in pairs(t.vm) do
        net.WriteUInt(k, 8)
    end

    net.WriteUInt(table.Count(t.wm), 8)

    for k, v in pairs(t.wm) do
        net.WriteUInt(k, 8)
    end
end

function ashop.Network.W_CarMaterials(t)
    net.WriteUInt(table.Count(t), 8)

    for k, v in pairs(t) do
        net.WriteUInt(k, 8)
    end
end

function ashop.Network.W_CurrencyTrade(t)
    net.WriteString(t.currencyName)
    net.WriteBool(t.toCoins)
    net.WriteString(t.convertRate)
    net.WriteBool(t.toPremium)
    net.WriteUInt(t.id, 10)
end

function ashop.Network.W_Pac3(t)
    ashop.Network.W_Compress(t.outfit)
    net.WriteString(t.name)
    net.WriteBool(t.model_attach or 0)
end

function ashop.Network.W_Rarity(t)
    net.WriteUInt(t.id, 8)
    net.WriteString(t.name)
    net.WriteUInt(t.r, 8)
    net.WriteUInt(t.g, 8)
    net.WriteUInt(t.b, 8)

    net.WriteBool(t.style != nil)
    if t.style then
        net.WriteUInt(t.style, 8)
    end

    net.WriteBool(t.notif_unbox)

    net.WriteBool(t.notif_unboxsound)
    if t.notif_unboxsound then
        net.WriteString(t.notif_unboxsound)
    end
end

function ashop.Network.W_ItemData(t)
    assert(t, "No item to send")

    net.WriteUInt(t.id, ashop.Config.BitsItemID)
    net.WriteUInt(t.object_types, ashop.Config.BitsObjectType)

    net.WriteBool(isnumber(t.sub_types))
    if isnumber(t.sub_types) then
        net.WriteUInt(t.sub_types, ashop.Config.BitsSubObjectType)
    end

    net.WriteString(t.name)

    net.WriteBool(isnumber(t.price))
    if isnumber(t.price) then
        net.WriteUInt(t.price, 32)
    end

    net.WriteBool(isnumber(t.premium_price))
    if isnumber(t.premium_price) then
        net.WriteUInt(t.premium_price, 32)
    end

    net.WriteBool(isnumber(t.promotion_start))
    if isnumber(t.promotion_start) then
        net.WriteUInt(t.promotion_start, 32)
    end

    net.WriteBool(isnumber(t.promotion_end))
    if isnumber(t.promotion_end) then
        net.WriteUInt(t.promotion_end, 32)
    end

    net.WriteBool(isnumber(t.promotion_amount))
    if isnumber(t.promotion_amount) then
        net.WriteUInt(t.promotion_amount, 7)
    end

    net.WriteBool(isnumber(t.rarity))
    if isnumber(t.rarity) then
        net.WriteUInt(t.rarity, ashop.Config.BitsRarity)
    end

    net.WriteBool(t.delete_death and (t.delete_death == "1" or t.delete_death == 1))

    net.WriteBool(t.group_restrained)
    if t.group_restrained then
        net.WriteUInt(t.group_restrained, ashop.Config.BitsGroupRank)
    end

    net.WriteBool(t.picture_link)
    if t.picture_link then
        net.WriteString(t.picture_link)
    end

    net.WriteBool(t.expireTime != nil and t.expireTime > 0)
    if t.expireTime != nil and t.expireTime > 0 then
        net.WriteUInt(t.expireTime, 32)
    end

    net.WriteBool(t.metadata)
    for k, v in SortedPairs(ashop.object_types[t.object_types].ItemParameters) do
        net.WriteBool(t.metadata[k] != nil)
        if t.metadata[k] != nil then
            ashop.Network.GetWriteFunction(v.type, t.metadata[k], v.options)
        end
    end
end

function ashop.Network.W_PlyItem(t)
    net.WriteUInt(t.id, ashop.Config.BitsPlyItemID)
    net.WriteUInt(t.item_id, ashop.Config.BitsItemID)

    local item = ashop.items[t.item_id]

    if item.expireTime then
        net.WriteUInt(t.when, 32)
    end

    net.WriteBool(t.premium_buy)
    net.WriteUInt(t.price_buy, 32)

    net.WriteBool(t.metadata)
    if t.metadata then
        for k, v in SortedPairs(ashop.object_types[item.object_types].ItemParameters) do
            net.WriteBool(t.metadata[k] != nil)
            if t.metadata[k] != nil then
                ashop.Network.GetWriteFunction(v.type, t.metadata[k], v.options)
            end
        end
    end
end

function ashop.Network.W_PlyItemFull(t)
    net.WriteUInt(t.id, ashop.Config.BitsPlyItemID)
    net.WriteUInt(t.item_id, ashop.Config.BitsItemID)

    net.WriteBool(isstring(t.metadata))
    if isstring(t.metadata) then
        net.WriteString(t.metadata)
    end

    net.WriteUInt(t.when, 32)
    net.WriteUInt(t.price_buy, 32)
    net.WriteBool(t.premium_buy)
end

function ashop.Network.W_SubCategory(t)
    local object_type = t.object_typeid

    assert(ashop.object_types[object_type], "Can't write object_type")
    
    local s = util.TableToJSON(t.metadata)
    net.WriteUInt(t.object_typeid, ashop.Config.BitsObjectType)
    net.WriteUInt(t.id, 12)
    net.WriteString(t.name)
    net.WriteUInt(t.slotSize, 6)
    ashop.Network.W_Compress(s)
end