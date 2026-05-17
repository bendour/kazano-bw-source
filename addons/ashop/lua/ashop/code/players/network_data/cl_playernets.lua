local luadata

ashop.Network = ashop.Network or {}

function ashop.Network.R_Render()
    local t = {
        name = net.ReadString(),
        cat = {}
    }

    local a = ashop.Network.R_Bulk(function(t)
        return net.ReadUInt(ashop.Config.BitsObjectType)
    end, 0, 8, 6)

    for k, v in ipairs(a) do
        t.cat[v] = true
    end

    return t
end

function ashop.Network.R_GroupRank()
    local t = {}
    t.name = net.ReadString()
    t.desc = net.ReadBool() and net.ReadString() or nil
    t.messageOnFail = net.ReadBool() and net.ReadString() or nil
    t.id = net.ReadUInt(ashop.Config.BitsGroupRank)
    t.freePerTime = net.ReadBool() and net.ReadUInt(16) or nil
    t.premiumPerTime = net.ReadBool() and net.ReadUInt(16) or nil
    t.ranks = {}

    local a = ashop.Network.R_Bulk(function(t)
        return net.ReadString()
    end, 0, 8, 6)

    for k, v in ipairs(a) do
        t.ranks[v] = true
    end

    return t
end

function ashop.Network.R_CurrencyTrade()
    return {
        currencyName = net.ReadString(),
        toCoins = net.ReadBool(),
        //convertRate = net.ReadFloat(),
        convertRate = tonumber(net.ReadString()),
        toPremium = net.ReadBool(),
        id = net.ReadUInt(10)
    }
end

function ashop.Network.R_Pac3()
    local t = ashop.Network.R_Compress()

    if !luadata and file.Exists('pac3/libraries/luadata.lua', 'LUA') then
        luadata = include('pac3/libraries/luadata.lua')
    end

    assert(luadata, "There is pac3 data without pac3 installed")

    return {
        outfit_text = t,
        outfit = luadata.Decode(t),
        name = net.ReadString(),
        model_attach = net.ReadBool()
    }
end

function ashop.Network.R_Rarity()
    local t = {
        id = net.ReadUInt(8),
        name = net.ReadString(),
        r = net.ReadUInt(8),
        g = net.ReadUInt(8),
        b = net.ReadUInt(8),
    }

    if net.ReadBool() then
        t.style = net.ReadUInt(8)
    end

    t.notif_unbox = net.ReadBool()

    if net.ReadBool() then
        t.notif_unboxsound = net.ReadString()
    end

    t.clr = Color(t.r, t.g, t.b)
    return t
end

function ashop.Network.R_ItemData()
    local t = {
        id = net.ReadUInt(ashop.Config.BitsItemID),
        object_types = net.ReadUInt(ashop.Config.BitsObjectType),
        sub_types = net.ReadBool() and net.ReadUInt(ashop.Config.BitsSubObjectType) or nil,
        name = net.ReadString(),
        price = net.ReadBool() and net.ReadUInt(32) or nil,
        premium_price = net.ReadBool() and net.ReadUInt(32) or nil,
        promotion_start = net.ReadBool() and net.ReadUInt(32) or nil,
        promotion_end = net.ReadBool() and net.ReadUInt(32) or nil,
        promotion_amount = net.ReadBool() and net.ReadUInt(7) or nil,
        rarity = net.ReadBool() and net.ReadUInt(ashop.Config.BitsRarity) or nil,
        delete_death = net.ReadBool(),
        group_restrained = net.ReadBool() and net.ReadUInt(ashop.Config.BitsGroupRank) or nil,
        picture_link = net.ReadBool() and net.ReadString() or nil,
        expireTime = net.ReadBool() and net.ReadUInt(32) or nil,
        metadata = {}
    }

    if net.ReadBool() then
        for k, v in SortedPairs(ashop.object_types[t.object_types].ItemParameters) do
            local b = net.ReadBool()
            if b then
                t.metadata[k] = ashop.Network.GetReadFunction(v.type, v.options)
            end
        end
    end

    return t
end

function ashop.Network.R_PlyItem()
    local t = {}
    t.id = net.ReadUInt(ashop.Config.BitsPlyItemID)
    t.item_id = net.ReadUInt(ashop.Config.BitsItemID)

    local item = ashop.items[t.item_id]
    if item.expireTime then
        t.when = net.ReadUInt(32)
    end

    t.premium_buy = net.ReadBool()
    t.price_buy = net.ReadUInt(32)

    t.metadata = {}

    if net.ReadBool() then
        assert(item, "Missing item, when sending R_PlyItem. Item: " .. t.item_id .. ". PlyItem ID: " .. t.id)

        for k, v in SortedPairs(ashop.object_types[item.object_types].ItemParameters) do
            if net.ReadBool() then
                t.metadata[k] = ashop.Network.GetReadFunction(v.type, v.options)
            end
        end
    end

    return t
end

function ashop.Network.R_PlyItemFull()
    return {
        id = net.ReadUInt(ashop.Config.BitsPlyItemID),
        item_id = net.ReadUInt(ashop.Config.BitsItemID),
        metadata = net.ReadBool() and util.JSONToTable(net.ReadString()) or {},
        when = net.ReadUInt(32),
        price_buy = net.ReadUInt(32),
        premium_buy = net.ReadBool()
    }
end

function ashop.Network.R_SubCategory()
    return {
        object_typeid = net.ReadUInt(ashop.Config.BitsObjectType),
        id = net.ReadUInt(12),
        name = net.ReadString(),
        slotSize = net.ReadUInt(6),
        metadata = util.JSONToTable(ashop.Network.R_Compress())
    }
end

function ashop.Network.R_WeaponMaterials()
    local t = {vm = {}, wm = {}}

    for i = 1, net.ReadUInt(8) do
        t.vm[net.ReadUInt(8)] = true
    end

    for i = 1, net.ReadUInt(8) do
        t.wm[net.ReadUInt(8)] = true
    end

    return t
end

function ashop.Network.R_CarMaterials()
    local t = {}

    for i = 1, net.ReadUInt(8) do
        t[net.ReadUInt(8)] = true
    end

    return t
end