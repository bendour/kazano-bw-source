util.AddNetworkString('ashop_PlayerEquippedItem_Bulk')
util.AddNetworkString('ashop_SubCat_New')
util.AddNetworkString('ashop_PlayerEquippedItem')
util.AddNetworkString('ashop_PlayerReceivedItem')
util.AddNetworkString('ashop_PlayerSyncFull')

ashop.tempItemPool = ashop.tempItemPool or {}

function ashop.MarkItemForTempPool(ply, itemid)
    assert(ply.ashop_data, "Invalid player: ashop_data not loaded")
    local plyItem = ply.ashop_data.items[itemid]
    assert(plyItem, "Player does not have a item with this itemid")

    local item = ashop.items[plyItem.item_id]
    assert(item.expireTime and item.expireTime > 0, "Calling MarkItemForTempPool on a not temporary item")

    ashop.tempItemPool[ply] = ashop.tempItemPool[ply] or {}

    table.insert(ashop.tempItemPool[ply], {
        expireAt = ((plyItem.when + item.expireTime) - os.time()) + CurTime(),
        itemID = itemid
    })

    local t = 'ashop_checkForTempItems_' .. ply:SteamID64()

    if timer.Exists(t) then return end

    timer.Create(t, 15, 0, function()
        if !IsValid(ply) then
            timer.Remove(t)
            return
        end

        local c = CurTime()
        for k, v in ipairs(ashop.tempItemPool[ply]) do
            if ashop.items[v.itemID] and v.expireAt >= c then continue end

            table.remove(ashop.tempItemPool[ply], k)
            local plyItem = ply.ashop_data.items[v.itemID]
            local item = ashop.items[plyItem.item_id]

            if ashop.object_types[item.object_types].OnExpire then
                ashop.object_types[item.object_types].OnExpire(ply, plyItem, item)
            end

            if v.expireAt < c then
                ashop.actions.DeletePlayerItem(ply, v.itemID)
            end

            if table.IsEmpty(ashop.tempItemPool[ply]) then
                ashop.tempItemPool[ply] = nil
                timer.Remove(t)
            end
        end
    end)
end

hook.Add("ashop_playerbuy", "HookForTemp", function(ply, plyItemID)
    if ply.ashop_data.items[plyItemID] and ashop.items[ply.ashop_data.items[plyItemID].item_id].expireTime 
        and ashop.items[ply.ashop_data.items[plyItemID].item_id].expireTime > 0 then
        ashop.MarkItemForTempPool(ply, plyItemID)
    end
end)

hook.Add('ashop_rankUpdate', "ItemRankVerify", function(ply, new)
    if !ashop.Config.UnequipOnMissingRanks or !ply.ashop_data then return end

    timer.Simple(10, function()
        if !IsValid(ply) then return end
        local equipped = ply.ashop_data.equipped
        local ug = ply:GetUserGroup()
    
        for object_typeID, v in pairs(equipped or {}) do
            if object_typeID == objectTypeID then continue end
            for sub_type, j in pairs(v) do
                for slot, plyItemID in pairs(j) do
                    local plyItem = ply.ashop_data.items[plyItemID]
                    local item = ashop.items[plyItem.item_id]
    
                    if item.group_restrained and ashop.groupranks[item.group_restrained] and !ashop.groupranks[item.group_restrained].ranks[ug] then
                        ply:AShop_ItemEquip(plyItemID, nil, true)
                    end
                end
            end
        end
    end)
end)

util.AddNetworkString('ashop_PrePlayerSyncFull')
local function init(ply)
    if !IsValid(ply) then return end

    ashop.SQL.query("SELECT id, money_premium, money_normal FROM ashop_players WHERE steamid = '" .. ply:SteamID64() .. "'", function(q)
        if !q then
            // Create user
            ashop.SQL.query('INSERT INTO ashop_players(steamid, money_normal, money_premium, oldname, `rank`) VALUES("' .. ply:SteamID64() .. '", ' .. ashop.Config.create_money .. ',' .. ashop.Config.create_premiummoney .. ',' .. "''" .. ',' .. "''" .. ')', function()
                init(ply)
            end)
            return
        end

        q = q[1]
        q.money_premium = tonumber(q.money_premium)
        q.money_normal = tonumber(q.money_normal)
        q.id = tonumber(q.id)

        ply.ashop_data = q

        ashop.SQL.query('SELECT * FROM ashop_bought WHERE owner_id = ' .. q.id, function(q2)
            local ostime = os.time()
            local deleteOld = {}
            local t = {}

            for k, v in ipairs(q2 or {}) do
                if v.metadata and v.metadata != "NULL" then
                    v.metadata = util.JSONToTable(v.metadata)
                else
                    v.metadata = {}
                end

                v.owner_id = tonumber(v.owner_id)
                v.item_id = tonumber(v.item_id)
                v.when = tonumber(v.when)
                v.price_buy = tonumber(v.price_buy)
                v.premium_buy = tonumber(v.premium_buy)
                v.id = tonumber(v.id)

                local item = ashop.items[v.item_id]
                if item.expireTime and v.when + item.expireTime < ostime then
                    table.insert(deleteOld, v.id)

                    if ashop.object_types[item.object_types].OnExpire then
                        ashop.object_types[item.object_types].OnExpire(ply, v, item)
                    end
                    continue
                end

                t[v.id] = v
            end

            if !table.IsEmpty(deleteOld) then
                ashop.SQL.query('DELETE FROM ashop_bought WHERE owner_id = ' .. q.id .. ' AND id IN (' .. table.concat(deleteOld, ",") .. ')')
            end

            ply.ashop_data.items = t

            for k, v in ipairs(ply.ashop_data.items) do
                local item = ashop.items[v.item_id]

                if item.expireTime then
                    ashop.MarkItemForTempPool(ply, k)
                end
            end

            local size = 0

            if !table.IsEmpty(ashop.pac3) then
                net.Start('ashop_PrePlayerSyncFull')
                for k, v in pairs(ashop.pac3) do
                    local s = util.Compress(v.outfit)

                    if #s > 63000 then
                        print("[AShop] A pac3 is more than 63ko when compressed, this is a lot, we skip this pac3 since we can't send it")
                        continue
                    end

                    if #s + size > 60000 then
                        net.WriteBool(false)
                        net.Send(ply)
                        net.Start('ashop_PrePlayerSyncFull')
                        size = 0
                    end

                    net.WriteBool(true)
                    net.WriteUInt(k, 16)
                    ashop.Network.W_Pac3(v)
                    size = #s + size
                end
                net.Send(ply)
            end

            net.Start('ashop_PlayerSyncFull')
                net.WriteUInt(ashop.itemCounter, 32)
                net.WriteUInt(table.Count(ashop.object_types), ashop.Config.BitsObjectType)
                for k, v in pairs(ashop.object_types) do
                    net.WriteUInt(v.loop_index, 8)
                    net.WriteUInt(v.renderIDBy, ashop.Config.BitsRender)
                    net.WriteUInt(v.slotSize or 0, 6)
                    net.WriteUInt(k, ashop.Config.BitsObjectType)
                end

                local ts = {}

                for k, v in pairs(ashop.object_types) do
                    if !v.sub_cat then continue end

                    for i, j in pairs(v.sub_cat) do
                        ts[i] = j
                    end
                end

                // write categories sqlID
                ashop.Network.W_Bulk(
                    ts,
                    ashop.Network.W_SubCategory,
                    1, 12, 12
                )

                // write player inventory
                net.WriteUInt(q.money_normal, 32)
                net.WriteUInt(q.money_premium, 32)

                //ashop.Network.W_Bulk(
                //    ply.ashop_data.items, 
                //    ashop.Network.W_PlyItem,
                //    1, 32, 12)

                // write rarity
                ashop.Network.W_Bulk(
                    ashop.rarity,
                    ashop.Network.W_Rarity,
                    1, 8, 8)

                // write render
                ashop.Network.W_Bulk(
                    ashop.render,
                    ashop.Network.W_Render,
                    1, 8, 6
                )

                // ashop_weaponmaterials
                ashop.Network.W_Bulk(
                    ashop.weaponmaterials,
                    ashop.Network.W_WeaponMaterials,
                    2, 10, 10
                )

                ashop.Network.W_Bulk(
                    ashop.carmaterials,
                    ashop.Network.W_CarMaterials,
                    2, 10, 10
                )

                // write currencies
                ashop.Network.W_Bulk(
                    ashop.currencies.trades,
                    ashop.Network.W_CurrencyTrade,
                    1, 10, 10
                )

                // write group promotions
                ashop.Network.W_Bulk(
                    ashop.rankpromo,
                    function(n) net.WriteUInt(n, 7) end,
                    2, 10, 10
                )

                // Write ranks
                net.WriteUInt(table.Count(ashop.groupranks), ashop.Config.BitsGroupRank)
                for k, v in pairs(ashop.groupranks) do
                    ashop.Network.W_GroupRank(v)
                end

                // write others players items
                ashop.Network.W_Bulk(
                    ashop.getAllKnownItems('items'),
                    ashop.Network.W_ItemData,
                    1, 20, 20
                )

                // Set known object in SetState

                local valid = 0
                for k, v in ipairs(player.GetAll()) do
                    if !v.ashop_data then continue end
                    valid = valid + 1
                end

                net.WriteUInt(valid - 1, 8)
                for k, v in ipairs(player.GetAll()) do
                    if v == ply or !v.ashop_data then continue end

                    net.WriteUInt(v:UserID(), 13)

                    for object_typeID, equippedObjectType in pairs(v.ashop_data.equipped or {}) do
                        for sub_type, j in pairs(equippedObjectType or {}) do
                            for slot, plyItemID in pairs(j or {}) do
                                if !ashop.knownItems.plys[ply]['plyitem'][plyItemID] then
                                    ashop.knownSetState(ply, plyItemID, true, 'plyitem')
                                    net.WriteBool(true)
                                    net.WriteUInt(slot, 4)
                                    ashop.Network.W_PlyItem(v.ashop_data.items[plyItemID])
                                end
                            end
                        end
                    end

                    net.WriteBool(false)
                end
            net.Send(ply)

            ply.ashop_data.ready = true

            ashop.SQL.query('SELECT ashop_equip.item_id, ashop_equip.slot_id FROM ashop_equip, ashop_bought WHERE ashop_equip.item_id = ashop_bought.id AND ashop_bought.owner_id = ' .. q.id, function(d)
                ply.ashop_data.equipped = ply.ashop_data.equipped or {}
                
                if d then
                    local cleanItems, cleanPlyItems = {}, {}
    
                    for k, v in ipairs(d) do
                        // Item
                        local itemID = ply.ashop_data.items[tonumber(v.item_id)].item_id
                        cleanItems[itemID] = ashop.items[itemID]
    
                        // PlyItem
                        cleanPlyItems[tonumber(v.item_id)] = ply.ashop_data.items[tonumber(v.item_id)]
                        ashop.knownItems.allKnown.plyitem[tonumber(v.item_id)] = true
                    end
                    
                    ashop.sendDataToIgnorants(cleanItems, 'items')
                    ashop.sendDataToIgnorants(cleanPlyItems, 'plyitem', ply)

                    local playersReady = {}

                    for k, v in ipairs(player.GetAll()) do
                        if v.ashop_data and v.ashop_data.ready then
                            table.insert(playersReady, v)
                        end
                    end
    
                    net.Start('ashop_PlayerEquippedItem_Bulk')
                        net.WriteUInt(ply:UserID(), 13)
                        net.WriteUInt(#d, 7)
    
                        for k, v in ipairs(d) do
                            local itemID = tonumber(v.item_id)
                            local slot_id = tonumber(v.slot_id)
                            local plyItem = ply.ashop_data.items[itemID]
    
                            local item = ashop.items[plyItem.item_id]
                            ply.ashop_data.equipped[item.object_types] = ply.ashop_data.equipped[item.object_types] or {}
                            ply.ashop_data.equipped[item.object_types][item.sub_types or 0] = ply.ashop_data.equipped[item.object_types][item.sub_types or 0] or {}
                            ply.ashop_data.equipped[item.object_types][item.sub_types or 0][slot_id] = itemID

                            net.WriteUInt(itemID, ashop.Config.BitsPlyItemID)
                            net.WriteUInt(slot_id, 6)
                        end
                    net.Send(playersReady)
    
                    // We need to make 2 loops
                    // The reason behind that is to avoid any others hooks to start a net, during my net
                    for k, v in ipairs(d) do
                        local itemID = tonumber(v.item_id)
                        local plyItem = ply.ashop_data.items[itemID]
                        local item = ashop.items[plyItem.item_id]
                        local object_type = ashop.object_types[item.object_types]
    
                        if object_type.OnEquip then
                            object_type.OnEquip(ply, plyItem, item)
                        end
                        hook.Run('ashop_equip', ply, slot_id, item, plyItem)
                    end
                end

                hook.Run('ashop_playerInit', ply)
                ply.ashop_ready = true

                timer.Simple(60, function()
                    if !IsValid(ply) then return end
                    hook.Run('ashop_rankUpdate', ply, ply:GetUserGroup())
                end)
            end)
        end)
    end)
end

local load_queue = {"azezaeeza"}
hook.Add("PlayerInitialSpawn", "ashop_load", function(ply)
    load_queue[ply] = true
end)

hook.Add("SetupMove", "ashop_load", function(ply, _, cmd)
	if load_queue[ply] and !cmd:IsForced() then
		load_queue[ply] = nil
        init(ply)
	end
end)

hook.Add('PlayerDisconnected', 'ashop_disconnectClearLoad', function(ply)
    load_queue[ply] = nil
end)

local PLAYER = FindMetaTable("Player")
function PLAYER:ashop_addCoinsSafe(amt, is_premium)
    if !self.ashop_ready then
        local s = self:SteamID64()
        local nameHooks = "AShopAddCoins_" .. s .. "_" .. amt

        hook.Add("ashop_playerInit", nameHooks, function(ply)
            hook.Remove("PlayerDisconnected", nameHooks)
            hook.Remove("ashop_playerInit", nameHooks)
            ply:ashopMoneyChange(amt, is_premium)
        end)

        hook.Add("PlayerDisconnected", nameHooks, function(ply)
            hook.Remove("PlayerDisconnected", nameHooks)
            hook.Remove("ashop_playerInit", nameHooks)

            if is_premium then
                ashop.SQL.query('UPDATE ashop_players SET money_premium = money_premium + ' .. amt .. " WHERE steamid = " .. ply:SteamID64())
            else
                ashop.SQL.query('UPDATE ashop_players SET money_normal = money_normal + ' .. amt .. " WHERE steamid = " .. ply:SteamID64())
            end

            ashop.Logs.PushLog(ashop.Logs.IDs.ChangeMoney_Offline, s, amt)
        end)
    else
        self:ashopMoneyChange(amt, is_premium)
    end
end

function PLAYER:ashop_addItemSafe(item_name)
    local itemTbl

    for k, v in pairs(ashop.items) do
        if v.name == item_name then
            itemTbl = v
            break
        end
    end

    assert(itemTbl, "Invalid item name, doesn't exist")

    if self.ashop_ready then
        ashop.actions.Give(self, itemTbl.id, nil, 0, false)
    else
        local s = self:SteamID64()
        local nameHooks = "AShopAddCoins_" .. s .. "_" .. amt

        hook.Add("ashop_playerInit", nameHooks, function(ply)
            hook.Remove("PlayerDisconnected", nameHooks)
            hook.Remove("ashop_playerInit", nameHooks)
            ashop.actions.Give(self, itemTbl.id, nil, 0, false)
        end)

        hook.Add("PlayerDisconnected", nameHooks, function(ply)
            hook.Remove("PlayerDisconnected", nameHooks)
            hook.Remove("ashop_playerInit", nameHooks)

            ashop.actions.GiveOffline(self:ashopGetID(), itemTbl.id, nil, 0)
        end)
    end
end

function PLAYER:PS2_AddStandardPoints(pts)
    self:ashop_addCoinsSafe(pts, false)
end

function PLAYER:PS2_AddPremiumPoints(pts)
    self:ashop_addCoinsSafe(pts, true)
end

function PLAYER:PS2_EasyAddItem(item_name)
    self:ashop_addItemSafe(item_name)
end

// Command to give points to a steamid
concommand.Add("ashop_givepoints", function(ply, _, args)
    if IsValid(ply) then return end
    local s64 = player.GetBySteamID64(args[1])

    local amt = tonumber(args[2])
    assert(amt, "[AShop] Invalid amount")

    if !IsValid(s64) then
        ashop.SQL.query('UPDATE ashop_players SET money_normal = money_normal + ' .. amt .. " WHERE steamid = " .. args[1])
    else
        s64:ashop_addCoinsSafe(amt, false)
    end
end)

concommand.Add("ashop_givepremiumpoints", function(ply, _, args)
    if IsValid(ply) then return end
    local s64 = player.GetBySteamID64(args[1])

    local amt = tonumber(args[2])
    assert(amt, "[AShop] Invalid amount")

    if !IsValid(s64) then
        ashop.SQL.query('UPDATE ashop_players SET money_premium = money_premium + ' .. amt .. " WHERE steamid = " .. args[1])
    else
        s64:ashop_addCoinsSafe(amt, true)
    end
end)

concommand.Add("ashop_giveitem", function(ply, _, args)
    if IsValid(ply) then return end
    local s64 = player.GetBySteamID64(args[1])
    assert(IsValid(s64), "[AShop] Trying to give item to an unconnected steamid")

    s64:ashop_addItemSafe(args[2])
end)