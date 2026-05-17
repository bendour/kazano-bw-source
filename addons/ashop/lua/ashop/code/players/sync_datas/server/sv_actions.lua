util.AddNetworkString('ashop_SubObjectType_Edit')
util.AddNetworkString('ashop_Admin_ReceiveInventoryItemData')
util.AddNetworkString('ashop_PlayerDeleteItemBulk')
util.AddNetworkString('ashop_PlayerReceivedItemBulk')
util.AddNetworkString('ashop_RankPromotion_Delete')
util.AddNetworkString('ashop_RankPromotion_Edit')
util.AddNetworkString('ashop_RankPromotion_Create')
util.AddNetworkString('ashop_ObjectType_Delete')
util.AddNetworkString('ashop_Render_Delete')
util.AddNetworkString('ashop_GroupRanks_Delete')
util.AddNetworkString('ashop_WeaponMaterial_Delete')
util.AddNetworkString('ashop_Currency_Delete')
util.AddNetworkString('ashop_Admin_ReceiveInventory')
util.AddNetworkString('ashop_Currency_Edit')
util.AddNetworkString('ashop_Currency_New')
util.AddNetworkString('ashop_ObjectType_Edit')
util.AddNetworkString('ashop_PlayerLostItem')
util.AddNetworkString('ashop_Rarity_Delete')
util.AddNetworkString('ashop_Rarity_Edit')
util.AddNetworkString('ashop_Item_Delete')
util.AddNetworkString('ashop_WeaponMaterial_Create')
util.AddNetworkString('ashop_WeaponMaterial_Edit')
util.AddNetworkString('ashop_Render_Edit')
util.AddNetworkString('ashop_PlayerItem_MetaDataUpdate')

ashop.actions = ashop.actions or {}

function ashop.actions.ChangeUserMetadata(ply, plyItemID, newParams, ignoreUserCheck)
    assert(ply.ashop_data and ply.ashop_data.items, "Can't change item metadata, data is not loaded")

    if !ply.ashop_data.items[plyItemID] then
        return "Player does not own this item"
    end

    local item = ply.ashop_data.items[plyItemID].item_id
    local o = ashop.object_types[ashop.items[item].object_types]
    ply.ashop_data.items[plyItemID].metadata = ply.ashop_data.items[plyItemID].metadata or {}
    local mt = ply.ashop_data.items[plyItemID].metadata

    for k, v in pairs(newParams) do
        local param = o.ItemParameters[v.id]
        if !param or (!param.userEditable and !ignoreUserCheck) then
            continue
        end

        local value = v.value

        if !value then
            mt[v.id] = nil
            continue
        end

        if param.type == TYPE_ANGLE or param.type == TYPE_VECTOR then
            if param.options and param.options.maxVar then
                for _, objectKey in pairs(param.type == TYPE_ANGLE and {"p","y","r"} or {"x", "y", "z"}) do
                    value[objectKey] = math.Clamp(value[objectKey], -param.options.maxVar, param.options.maxVar)
                end
            end
        end

        if !ashop.VerifyInput(value, param.type, param.options) then
            return "The parameter " .. param.name .. " does not respect the parameter options"
        end

        mt[v.id] = value
    end

    // We sanitized values, we send it and save them
    net.Start('ashop_PlayerItem_MetaDataUpdate')
        net.WriteUInt(ply:UserID(), 13)
        net.WriteUInt(plyItemID, ashop.Config.BitsPlyItemID)
        ashop.Network.W_Bulk(
            newParams,
            function(t)
                local param = o.ItemParameters[t.id]
                local newValue = mt[t.id]
                net.WriteUInt(t.id, 6)
                net.WriteBool(newValue != nil)
                net.WriteUInt(ply.ashop_data.items[plyItemID].item_id, ashop.Config.BitsPlyItemID)

                if newValue != nil then
                    ashop.Network.GetWriteFunction(param.type, newValue)
                end
            end, 1, 6, 6)
    net.Send(ashop.doesPlayersKnow(plyItemID, 'plyitem'))

    for k, v in pairs(newParams) do
        ashop.Logs.PushLog(ashop.Logs.IDs.ChangeUserMetadata, o.ItemParameters[v.id].name, ashop.items[item].name)
    end

    ashop.SQL.query("UPDATE ashop_bought SET metadata = " .. ashop.SQL.escape(util.TableToJSON(mt)) .. " WHERE id = " .. plyItemID)
end

ashop.SafeNet('PlayerItem_MetaDataUpdate', function(ply)
    local plyItemID = net.ReadUInt(ashop.Config.BitsPlyItemID)
    local itemParam = net.ReadUInt(8)

    if !ply.ashop_data or !ply.ashop_data.items or
        !ply.ashop_data.items[plyItemID] then return end

    local item = ashop.items[ply.ashop_data.items[plyItemID].item_id]
    
    if !item then
        assert('The player have a non-existing item')
    end

    local object_type = ashop.object_types[item.object_types]

    if !object_type or !object_type.ItemParameters or
        !object_type.ItemParameters[itemParam] or
        !object_type.ItemParameters[itemParam].userEditable then return end

    ashop.actions.ChangeUserMetadata(ply, plyItemID, {
        {id = itemParam, value = ashop.Network.GetReadFunction(object_type.ItemParameters[itemParam].type)}
    }, true)
end, 1)

function ashop.actions.GiveOffline(id, itemID, metadata, price_buy, t, premium_buy, callback, alreadyLogged)
    t = t or os.time()
    local str = 'INSERT INTO ashop_bought(owner_id, item_id, price_buy, `when`, premium_buy) VALUES(' .. id .. ',' .. itemID .. "," .. (price_buy or 0) .. ',' .. t .. ',' .. (premium_buy and 1 or 0) .. ')'
    if metadata then
        str = 'INSERT INTO ashop_bought(owner_id, item_id, metadata, price_buy, `when`, premium_buy) VALUES(' .. id .. ',' .. itemID .. ",'" .. metadata .. "'," .. (price_buy or 0) .. ',' .. t .. ',' .. (premium_buy and 1 or 0) .. ')'
    end

    ashop.SQL.query(str, function(data, qO)
        if callback then
            callback(qO:lastInsert())
        end
    end)

    if !alreadyLogged then
        ashop.Logs.PushLog(ashop.Logs.IDs.BuyItemOffline, {id, true}, itemID)
    end
end

function ashop.actions.Give(ply, item_id, metadata, price_buy, premium_buy, c)
    assert(ply.ashop_data and ply.ashop_data.items, "Can't give item to player, data is not loaded")

    local t = os.time()

    ashop.actions.GiveOffline(ply:ashopGetID(), item_id, metadata, price_buy, t, premium_buy, function(ins)
        if !IsValid(ply) then return end

        ply.ashop_data.items[ins] = {
            owner_id = ply:ashopGetID(),
            item_id = item_id,
            metadata = metadata and util.JSONToTable(metadata) or {},
            price_buy = price_buy,
            premium_buy = premium_buy,
            id = ins,
            when = t
        }

        // Share to player now
        if ashop.knownItems.inMenus[ply] then
            net.Start('ashop_PlayerReceivedItem')
                ashop.Network.W_PlyItem(ply.ashop_data.items[ins])
            net.Send(ply)
        end

        if c then
            c(ins)
        end

        hook.Run('ashop_playerbuy', ply, ins, item_id)
    end, true)
end

/*
    data: Array of item_id
*/

function ashop.actions.BulkRemove(ply, data)
    assert((IsValid(ply) and ply:IsPlayer()) or isnumber(ply), "Ply is an invalid argument")

    if IsValid(ply) and ply:IsPlayer() then
        assert(ply.ashop_data, "Player data not loaded")
        for k, v in ipairs(data) do
            ply:AShop_ItemEquip(v, nil, true)
            ply.ashop_data.items[v] = nil
        end

        net.Start('ashop_PlayerDeleteItemBulk')
            net.WriteUInt(#data, 9)
            
            for k, v in ipairs(data) do
                net.WriteUInt(v, ashop.Config.BitsPlyItemID)
            end
        net.Send(ply)
    end

    local str = "("
    local max = #data
    for k, v in ipairs(data) do
        if max == k then
            str = str .. v .. ")"
        else
            str = str .. v .. ", "
        end
    end

    ashop.SQL.query('DELETE FROM ashop_bought WHERE id IN ' .. str)
end

/*
    data: Array of:
        item_id, 
        metadata: string, 
        price_buy, 
        premium_buy, 
        c
*/
function ashop.actions.GiveBulk(ply, data)
    assert(isnumber(ply) or (IsValid(ply) and ply:IsPlayer()), "[AShop-GiveBulk] Invalid ply parameter, should be a player or a number")
    assert(#data <= 2^9, "[AShop-GiveBulk] Too much items to send")
    local query = 'INSERT INTO ashop_bought(owner_id, item_id, metadata, price_buy, premium_buy, `when`) VALUES'

    local pID = IsValid(ply) and ply:ashopGetID() or ply
    for k, v in ipairs(data) do
        query = query .. '(' .. pID .. ',' .. v.item_id .. ',' .. (v.metadata and ashop.SQL.escape(v.metadata) or 'NULL') .. ',' .. (v.price_buy or 0) .. ',' .. (v.premium_buy and 1 or 0) .. ',' .. os.time() .. '),'

        if IsValid(ply) then
            ashop.Logs.PushLog(ashop.Logs.IDs.BuyItem, ply, v.item_id)
        else
            ashop.Logs.PushLog(ashop.Logs.IDs.BuyItemOffline, {pID, true}, v.item_id)
        end
    end

    query = string.sub(query, 1, -2)

    ashop.SQL.query(query, function(_, qO)
        if !IsValid(ply) then return end
        local firstInsert = qO:lastInsert()
        local t = os.time()

        for k, v in ipairs(data) do
            ply.ashop_data.items[firstInsert + k - 1] = {
                owner_id = pID,
                item_id = v.item_id,
                metadata = v.metadata and util.JSONToTable(v.metadata) or {},
                price_buy = v.price_buy,
                premium_buy = v.premium_buy,
                id = firstInsert + k - 1,
                when = t
            }
        end

        if IsValid(ply) and ashop.knownItems.inMenus[ply] then
            local t = ashop.knownItems.plys[ply]

            net.Start('ashop_PlayerReceivedItemBulk')
                local unknownItems = {}
                for i = firstInsert, #ply.ashop_data.items do
                    local item_id = ply.ashop_data.items[i].item_id
                    if !t.items[item_id] then
                        table.insert(unknownItems, ashop.items[item_id])
                        t.items[item_id] = true
                    end
                end

                net.WriteUInt(#unknownItems, 9)
                for k, v in ipairs(unknownItems) do
                    ashop.Network.W_ItemData(v)
                end

                net.WriteUInt(#data, 9)
                for i = firstInsert, #ply.ashop_data.items do
                    ashop.Network.W_PlyItem(ply.ashop_data.items[i])
                end
            net.Send(ply)
        end
    end)
end

function ashop.actions.Buy(ply, itemID, premium_buy)
    local item = ashop.items[itemID]

    if !item then
        return "This item does not exist: " .. itemID
    end

    local price = math.floor(item[premium_buy and "premium_price" or "price"] * (100 - (ashop.rankpromo[ply:GetUserGroup()] or 0))/100)

    if (item.promotion_start and item.promotion_end and item.promotion_amount and
        item.promotion_start < os.time() and os.time() - 20 < item.promotion_end and item.promotion_amount > 0) then
        price = math.floor(price * (1 - item.promotion_amount/100))
    end

    if !price then
        return "This item does not have price"
    end

    if item.group_restrained and ashop.groupranks[item.group_restrained] and !ashop.groupranks[item.group_restrained].ranks[ply:GetUserGroup()] then
        return "Player don't have the right rank"
    end

    if !ply:ashopMoneyAfford(price, premium_buy) then
        return "Player does not have enough money"
    end

    ply:ashopMoneyChange(-price, premium_buy)
    local r = ashop.actions.Give(ply, itemID, nil, price, premium_buy)

    ashop.Logs.PushLog(ashop.Logs.IDs.BuyItem, ply, itemID)
    if r then return r end
end

// Delete
function ashop.actions.DeletePlayerItem(ply, plyItemID)
    assert(ply.ashop_data and ply.ashop_data.items and ply.ashop_data.items[plyItemID], "Player does not have this item loaded or does not own it")
    ply:AShop_ItemEquip(plyItemID, nil, true)
    ply.ashop_data.items[plyItemID] = nil

    net.Start('ashop_PlayerLostItem')
        net.WriteUInt(plyItemID, ashop.Config.BitsPlyItemID)
    net.Send(ply)

    ashop.SQL.query('DELETE FROM ashop_bought WHERE id = ' .. plyItemID)
end

function ashop.actions.DeletePlayerItemRaw(itemid)
    ashop.SQL.query('DELETE FROM ashop_equip WHERE item_id = ' .. itemid)
    ashop.SQL.query('DELETE FROM ashop_bought WHERE id = ' .. itemid)
end

function ashop.actions.Refund(ply, plyItemID, ratio)
    assert(ply.ashop_data and ply.ashop_data.items and ply.ashop_data.items[plyItemID], "Player does not have this item loaded or does not own it")

    local plyItem = ply.ashop_data.items[plyItemID]
    local item = ashop.items[plyItem.item_id]

    assert(item, "Player own a item that does not exist: " .. plyItemID )

    ply:ashopMoneyChange(plyItem.price_buy * (ratio or 1), plyItem.premium_buy == 1 and true or false)
    ashop.actions.DeletePlayerItem(ply, plyItemID)
end