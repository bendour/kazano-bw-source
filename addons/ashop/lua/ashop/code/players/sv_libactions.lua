util.AddNetworkString('ashop_Item_Edit')
util.AddNetworkString('ashop_Render_New')
util.AddNetworkString('ashop_Render_Edit')

function ashop.ChangeItemValue(item, inputID, value)
    local itemTable = ashop.items[item]
    if !itemTable then return end

    // All these items have these params
    if inputID == 0 then return end

    // I know, this code is a mess
    // TODO: Rewrite it ? This is a bit ugly but this is working well
    if inputID <= 11 then
        local sqlvalue = value
        local sqlcolumn, netWrite
        if inputID == 1 then
            sqlvalue = ashop.SQL.escape(value)
            sqlcolumn = 'name'
            netWrite = net.WriteString

            assert(string.len(value) <= 24, "Name is too long")
        elseif inputID == 2 then
            sqlcolumn = 'rarity'
            assert(ashop.rarity[value], 'Rarity does not exist')
            netWrite = function(d) net.WriteUInt(d, ashop.Config.BitsRarity) end
        elseif inputID == 3 or inputID == 4 then
            sqlcolumn = inputID == 4 and 'premium_price' or 'price'
            netWrite = function(d)
                net.WriteBool(d)
                if d then
                    net.WriteUInt(d, 32)
                end
            end
        elseif inputID == 6 or inputID == 7 then
            sqlcolumn = inputID == 7 and 'promotion_end' or 'promotion_start'
            netWrite = function(d)
                net.WriteBool(d)
                if d then
                    net.WriteUInt(d, 32)
                end
            end
        elseif inputID == 8 then
            value = value and math.min(value, 100) or nil
            sqlvalue = value
            sqlcolumn = 'promotion_amount'
            netWrite = function(d)
                net.WriteBool(d)
                if d then
                    net.WriteUInt(d, 7) 
                end
            end
        elseif inputID == 9 then
            sqlcolumn = 'picture_link'
            sqlvalue = ashop.SQL.escape(value)
            netWrite = function(d)
                net.WriteBool(d)

                if d then
                    net.WriteString(d)
                end
            end
        elseif inputID == 10 then
            if value and !ashop.groupranks[value] then return end
            sqlcolumn = 'group_restrained'
            netWrite = function(d)
                net.WriteBool(d)
                if d then net.WriteUInt(d, 10) end
            end
        elseif inputID == 5 then
            sqlvalue = value and 1 or 0
            sqlcolumn = 'delete_death'
            netWrite = net.WriteBool
        elseif inputID == 11 then
            sqlvalue = value
            sqlcolumn = 'expireTime'
            netWrite = function(d)
                net.WriteBool(d)

                if d then
                    net.WriteUInt(d, 32)
                end
            end
        end

        ashop.SQL.query('UPDATE ashop_items SET ' .. sqlcolumn .. ' = ' .. (sqlvalue or 'NULL') .. ' WHERE id = ' .. item)
        ashop.items[item][sqlcolumn] = value

        net.Start('ashop_Item_Edit')
            net.WriteUInt(inputID, 7)
            net.WriteUInt(item, ashop.Config.BitsItemID)
            netWrite(value)
        net.Send(ashop.doesPlayersKnow(item, 'items'))
    else
        local realID = inputID - 11
        local param = ashop.object_types[itemTable.object_types].ItemParameters[realID]
        if !param then return end

        assert(ashop.VerifyInput(value, param.type, param.options), "Value does not respect options: " .. param.name)

        itemTable.metadata[realID] = value
        param.options = param.options or {}

        net.Start('ashop_Item_Edit')
            net.WriteUInt(inputID, 7)
            net.WriteUInt(item, ashop.Config.BitsItemID)
            ashop.Network.GetWriteFunction(param.type, value, param.options)
        net.Send(ashop.doesPlayersKnow(item, 'items'))

        local metadataCopy = itemTable.metadata
        if isstring(value) and string.find(value, "\n") then
            metadataCopy = table.Copy(metadataCopy)
            metadataCopy[realID] = string.gsub(value, "\n", "\\n")
        end

        local md = util.TableToJSON(metadataCopy)
        md = string.gsub(md, "'", "\\'")
        md = string.gsub(md, "\\", "\\\\")

        ashop.SQL.query("UPDATE ashop_items SET metadata = " .. ashop.SQL.escape(md) .. " WHERE id = " .. item)
    end
end

function ashop.CreateRender(name, c)
    assert(name, "Missing name for CreateRender")
    assert(c, "Missing object types to switch in the new render")

    local cleanTbl = {}
    local index = 1
    local queryStr
    local cat = {}

    for k, v in pairs(ashop.object_types) do
        cleanTbl[k] = c[index]
        index = index + 1
    end

    for k, v in pairs(ashop.render) do
        for objectTypeIndex, _ in pairs(v.cat or {}) do
            if cleanTbl[objectTypeIndex] then
                ashop.render[k].cat[objectTypeIndex] = nil

                if queryStr then
                    queryStr = queryStr .. "," .. objectTypeIndex
                else
                    queryStr = "" .. objectTypeIndex
                end
                cat[objectTypeIndex] = true
            end
        end
    end

    ashop.SQL.query("INSERT INTO ashop_render(name) VALUES(" .. ashop.SQL.escape(name) .. ")", function(_, qO)
        ashop.render[qO:lastInsert()] = {
            name = name,
            id = qO:lastInsert(),
            cat = cat
        }

        net.Start('ashop_Render_New')
            net.WriteUInt(qO:lastInsert(), ashop.Config.BitsRender)
            ashop.Network.W_Render(ashop.render[qO:lastInsert()])
        net.Broadcast()

        if queryStr then
            ashop.SQL.query("UPDATE ashop_object_types SET renderBy = '" .. qO:lastInsert() .. "' WHERE id IN (" .. queryStr .. ")")
        end
    end)
end

function ashop.EditRender(renderID, nameEdit, info)
    assert(ashop.render[renderID], "Render object does not exist ( A superadmin sent a renderID that doesn't exist anymore ?)")
    assert(info, "Missing info")

    if nameEdit then
        assert(isstring(info), "Info is not a string")
        assert(string.len(info) <= 24, "Too long name")
        ashop.SQL.query("UPDATE ashop_render SET name = " .. ashop.SQL.escape(info) .. " WHERE id = " .. renderID)

        net.Start('ashop_Render_Edit')
            net.WriteBool(true)
            net.WriteUInt(renderID, ashop.Config.BitsRender)
            net.WriteString(info)
        net.Broadcast()
        ashop.render[renderID].name = info
    else
        assert(ashop.object_types[info], "ObjectType ID object does not exist ( A superadmin sent a info that doesn't exist anymore ?)")

        // Clean old value
        for k, v in pairs(ashop.render) do
            if v.cat and v.cat[info] then
                v.cat[info] = nil
                break
            end
        end

        ashop.render[renderID].cat = ashop.render[renderID].cat or {}
        ashop.render[renderID].cat[info] = true

        ashop.SQL.query("UPDATE ashop_object_types SET renderBy = " .. renderID .. " WHERE id = " .. info)

        net.Start('ashop_Render_Edit')
            net.WriteBool(false)
            net.WriteUInt(renderID, ashop.Config.BitsRender)
            net.WriteUInt(info, ashop.Config.BitsObjectType)
        net.Broadcast()
    end
end

function ashop.CreateObjectType(name, index, slotDefault)
    assert(name, "Missing name for CreateObjectType")
    assert(index, "Missing index for object type")

    local metadatas = {}

    for k, v in pairs(ashop.object_types[index].SubCategoriesParameters) do
        metadatas[k] = ashop.Network.GetReadFunction(v[2])
    end

    ashop.SQL.query("INSERT INTO ashop_sub_types(name, metadata, object_typeid, slotSize) VALUES(" .. ashop.SQL.escape(name) .. ", " .. ashop.SQL.escape(util.TableToJSON(metadatas)) .. ", " .. index .. "," .. slotDefault .. ")", function(_, q0)
        ashop.object_types[index].sub_cat = ashop.object_types[index].sub_cat or {}
        ashop.object_types[index].sub_cat[q0:lastInsert()] = {
            id = q0:lastInsert(),
            metadata = metadatas,
            name = name,
            object_typeid = index,
            slotSize = slotDefault
        }

        net.Start('ashop_SubCat_New')
            ashop.Network.W_SubCategory(ashop.object_types[index].sub_cat[q0:lastInsert()])
        net.Broadcast()
    end)
end

ashop.SafeNet('RankPromotion_Create', function(ply)
    local rank = net.ReadString()
    local amt = net.ReadUInt(7)

    if ashop.rankpromo[rank] then return end

    ashop.rankpromo[rank] = amt
    ashop.SQL.query("INSERT INTO ashop_rankpromotions(rank, promo) VALUES(" .. ashop.SQL.escape(rank) .. ", " .. amt .. ")")

    net.Start('ashop_RankPromotion_Create')
        net.WriteString(rank)
        net.WriteUInt(math.min(amt, 100), ashop.Config.BitsRankPromotion)
    net.Broadcast()

    ashop.Logs.PushLog(ashop.Logs.IDs.RankPromotion_Create, ply, rank)
end, 1, true)

ashop.SafeNet('RankPromotion_Edit', function(ply)
    local curRank = net.ReadString()
    if !ashop.rankpromo[curRank] then return end

    if net.ReadBool() then
        local rank = net.ReadString()
        local p = ashop.rankpromo[curRank]

        if ashop.rankpromo[rank] then return end
        ashop.rankpromo[rank] = p
        ashop.rankpromo[curRank] = nil

        net.Start('ashop_RankPromotion_Edit')
            net.WriteString(curRank)
            net.WriteString(rank)
        net.Broadcast()

        ashop.SQL.query("UPDATE ashop_rankpromotions SET `rank` = " .. ashop.SQL.escape(rank) .. " WHERE `rank` = " .. curRank)
    else
        local value = math.min(net.ReadUInt(7), 100)
        ashop.rankpromo[curRank] = value

        net.Start('ashop_RankPromotion_Create')
            net.WriteString(curRank)
            net.WriteUInt(value, ashop.Config.BitsRankPromotion)
        net.Broadcast()

        ashop.SQL.query("UPDATE ashop_rankpromotions SET promo = " .. value .. " WHERE rank = " .. ashop.SQL.escape(rank))
    end

    ashop.Logs.PushLog(ashop.Logs.IDs.RankPromotion_Update, ply, curRank)
end, 1, true)

ashop.SafeNet('RankPromotion_Delete', function(ply)
    local rank = net.ReadString()
    if !ashop.rankpromo[rank] then return end

    ashop.SQL.query("DELETE FROM ashop_rankpromotions WHERE rank = " .. ashop.SQL.escape(rank))
    ashop.rankpromo[rank] = nil

    net.Start('ashop_RankPromotion_Delete')
        net.WriteString(rank)
    net.Broadcast()

    ashop.Logs.PushLog(ashop.Logs.IDs.RankPromotion_Delete, ply, rank)
end, 1, true)

ashop.SafeNet('SellOwnItem', function(ply)
    local plyItemID = net.ReadUInt(ashop.Config.BitsPlyItemID)

    if !ply.ashop_data or !ply.ashop_data.items or !ply.ashop_data.items[plyItemID] then return end
    ashop.actions.Refund(ply, plyItemID, ashop.Config.SellPrice)
end, 1)

ashop.SafeNet('ObjectType_Delete', function(ply)
    local objectTypeID = net.ReadUInt(ashop.Config.BitsObjectType)
    local subCat = net.ReadUInt(ashop.Config.BitsObjectType)

    if !ashop.object_types[objectTypeID] or 
        !ashop.object_types[objectTypeID].sub_cat or
        !ashop.object_types[objectTypeID].sub_cat[subCat] then return end

    for k, v in pairs(ashop.items) do
        if v.object_types == objectTypeID and v.sub_types == subCat then
            return
        end
    end

    ashop.Logs.PushLog(ashop.Logs.IDs.ObjectType_Delete, ashop.object_types[objectTypeID].sub_cat[subCat].name, ply)
    ashop.SQL.query('DELETE FROM ashop_sub_types WHERE id = ' .. subCat)
    ashop.object_types[objectTypeID].sub_cat[subCat] = nil

    net.Start('ashop_ObjectType_Delete')
        net.WriteUInt(objectTypeID, ashop.Config.BitsObjectType)
        net.WriteUInt(subCat, ashop.Config.BitsObjectType)
    net.Broadcast()
end, 1, true)

function ashop.CheckItemIDUsage(itemID)
    local objectTypesList = {}

    for k, v in pairs(ashop.object_types) do
        for a, b in pairs(v.ItemParameters) do
            if b.type == "ITEMID" then
                if !objectTypesList[k] then
                    objectTypesList[k] = {}
                end
    
                table.insert(objectTypesList[k], {false, a})
            elseif b.type == "LIST" then
                for i, j in pairs(b.options.listObjects) do
                    if j[1] == "ITEMID" then
                        if !objectTypesList[k] then
                            objectTypesList[k] = {}
                        end
    
                        table.insert(objectTypesList[k], {true, a, i})
                    end
                end
            end
        end
    end

    for k, v in pairs(ashop.items) do
        if objectTypesList[v.object_types] then
            for i, j in pairs(objectTypesList[v.object_types]) do
                if !j[1] then
                    if v.metadata[j[2] + 11] == itemID then
                        return k
                    end
                else
                    for _, listRow in pairs(v.metadata[j[2]]) do
                        if listRow[j[3]] and listRow[j[3]] == itemID then
                            return k
                        end
                    end
                end
            end
        end
    end
end

function ashop.DeleteItem(item, refund, ply)
    if !ashop.items[item] then return end

    // Check if any others items is using this item
    local usingItem = ashop.CheckItemIDUsage(item)

    if usingItem then
        local objtbl = ashop.items[item]
        if ply then
            ply:ChatPrint("Can't delete the item " .. objtbl.name .. ". Because this is used by the item: " .. ashop.items[usingItem].name)
        else
            print("Can't delete the item " .. objtbl.name .. ". Because this is used by the item: ", ashop.items[usingItem].name)
        end
    end

    for k, v in ipairs(player.GetHumans()) do
        if !v.ashop_data or !v.ashop_data.items then continue end
        for i, j in pairs(v.ashop_data.items) do
            if j.item_id == item then
                if refund then
                    ashop.actions.Refund(v, i)
                else
                    ashop.actions.DeletePlayerItem(v, i)
                end
            end
        end
    end

    // Now, SQL
    if refund then
        ashop.SQL.query('UPDATE ashop_players SET money_normal = money_normal + COALESCE((SELECT SUM(price_buy) FROM ashop_bought WHERE ashop_players.id = ashop_bought.owner_id AND item_id = ' .. item .. '), 0)')
    end

    ashop.SQL.query('DELETE FROM ashop_bought WHERE item_id = ' .. item, function()
        ashop.SQL.query('DELETE FROM ashop_items WHERE id = ' .. item)
    end)

    ashop.items[item] = nil
    net.Start('ashop_Item_Delete')
        net.WriteUInt(item, ashop.Config.BitsItemID)
    net.Broadcast()
end

util.AddNetworkString('ashop_Rarity_New')
function ashop.CreateRarity(name, clr, style, notif_unbox, notif_unboxsound)
    assert(string.len(name) <= 24, "Too long name")

    if notif_unbox == nil then
        notif_unbox = 0
    end

    // What a long query
    ashop.SQL.query('INSERT INTO ashop_rarity(name, r, g, b' .. (style and ", style" or "") .. ", notif_unbox" .. (notif_unboxsound and ", notif_unboxsound" or "") .. ") VALUES(" .. ashop.SQL.escape(name) .. ", " .. clr.r .. ", " .. clr.g .. ", " .. clr.b .. (style and "," .. style or "") .. "," .. (notif_unbox and 1 or 0) .. (notif_unboxsound and "," .. ashop.SQL.escape(notif_unboxsound) or "") .. ")", function(_, qO)
        local t = {
            id = qO:lastInsert(),
            r = clr.r,
            g = clr.g,
            b = clr.b,
            name = name,
            style = style,
            notif_unbox = notif_unbox,
            notif_unboxsound = notif_unboxsound
        }
        ashop.rarity[qO:lastInsert()] = t

        net.Start('ashop_Rarity_New')
            ashop.Network.W_Rarity(t)
        net.Broadcast()

        ashop.Logs.PushLog(ashop.Logs.IDs.Rarity_Create, name, ply)
    end)
end

function ashop.DeleteRarity(rarity)
    if !ashop.rarity[rarity] then return end

    local firstRarity
    for k, v in pairs(ashop.rarity) do
        if k != rarity then
            firstRarity = k
            break
        end
    end

    if !firstRarity then return end

    // Urgh, switch every items, let's hope they won't do that every day
    for k, v in pairs(ashop.items) do
        if v.rarity == rarity then
            ashop.ChangeItemValue(k, 2, firstRarity)
        end
    end

    // Delete rarity
    ashop.rarity[rarity] = nil
    ashop.SQL.query('DELETE FROM ashop_rarity WHERE id = ' .. rarity)

    // Send player
    net.Start('ashop_Rarity_Delete')
        net.WriteUInt(rarity, ashop.Config.BitsRarity)
    net.Broadcast()

    return true
end

function ashop.currencies.ExecuteTrade(ply, key, amt)
    local t = ashop.currencies.trades[key]

    if !t then return end

    local currency = ashop.currencies.list[t.currencyName]
    assert(currency, 'A trade is available, without the currency available. Currency: ', t.currencyName)

    local amtRate = math.floor(amt * t.convertRate)
    local isPremium = t.toPremium

    if t.toCoins then
        // Check with the currency function
        if currency.getMoney(ply) < amt then return end
        currency.addMoney(ply, -amt)
        ply:ashopMoneyChange(amtRate, isPremium)
    else
        // Check ourself
        if !ply:ashopMoneyAfford(amt, isPremium) then return end
        ply:ashopMoneyChange(-amt, isPremium)
        currency.addMoney(ply, amtRate)
    end
end

util.AddNetworkString('ashop_ExecuteTrade')
ashop.SafeNet('ExecuteTrade', function(ply)
    local id = net.ReadUInt(10)
    local amt = net.ReadUInt(32)

    local t = ashop.currencies.trades[id]

    if !t then return end

    ashop.currencies.ExecuteTrade(ply, id, amt)
    ashop.Logs.PushLog(ashop.Logs.IDs.Currency_Used, ply, t.currencyName, amt)
end, 0.5)

ashop.SafeNet('Currency_Delete', function(ply)
    local currencyTrade = net.ReadUInt(8)

    if !ashop.currencies.trades[currencyTrade] then return end
    local n = ashop.currencies.trades[currencyTrade].currencyName
    ashop.currencies.trades[currencyTrade] = nil

    ashop.SQL.query('DELETE FROM ashop_currenciesTrades WHERE id = ' .. currencyTrade)
    net.Start('ashop_Currency_Delete')
        net.WriteUInt(currencyTrade, 8)
    net.Broadcast()

    ashop.Logs.PushLog(ashop.Logs.IDs.Currency_Delete, ply, n)
end, 0.5, true)

ashop.SafeNet('Currency_New', function(ply)
    local t = {
        currencyName = net.ReadString(),
        toCoins = net.ReadBool(),
        //convertRate = net.ReadFloat(),
        convertRate = tonumber(net.ReadString()),
        toPremium = net.ReadBool()
    }

    if !ashop.currencies.list[t.currencyName] then return end
    ashop.SQL.query("INSERT INTO ashop_currenciesTrades(currencyName, toCoins, convertRate, toPremium) VALUES(" .. ashop.SQL.escape(t.currencyName) .. ", " .. (t.toCoins and 1 or 0) .. "," .. t.convertRate .. "," .. (t.toPremium and 1 or 0) .. ")", function(_, q0)
        t.id = q0:lastInsert()
        ashop.currencies.trades[q0:lastInsert()] = t

        net.Start('ashop_Currency_New')
            ashop.Network.W_CurrencyTrade(t)
        net.Broadcast()
    end)

    ashop.Logs.PushLog(ashop.Logs.IDs.Currency_New, ply, t.currencyName)
end, 0.5, true)

util.AddNetworkString('ashop_EditObjectType')
ashop.SafeNet('EditObjectType', function(ply)
    local isMain = net.ReadBool()
    local object_typeID = net.ReadUInt(ashop.Config.BitsObjectType)
    local subID = !isMain and net.ReadUInt(ashop.Config.BitsSubObjectType) or nil
    local typeValue, sqlColumn

    assert(ashop.object_types[object_typeID], "Object_type does not exist")
    if !net.ReadBool() then
        typeValue = TYPE_STRING
        sqlColumn = "name"
    else
        typeValue = "UInt8"
        sqlColumn = "slotSize"
    end
    
    local value = ashop.Network.GetReadFunction(typeValue, {
        required = true
    })

    assert(value, "Missing value")
    assert(act != 0 or string.len(value) <= 24, "Too long name")
    
    if isMain then
        // I should have fixed this right after noticing it
        ashop.object_types[object_typeID][act == 0 and 'Name' or sqlColumn] = value
    else
        assert(ashop.object_types[object_typeID].sub_cat, "No SubCat while editing a sub category")
        ashop.object_types[object_typeID].sub_cat[subID][sqlColumn] = value
    end
    
    ashop.SQL.query('UPDATE ashop_' .. (isMain and "object_types" or "sub_types") .. " SET " .. sqlColumn .. " = " .. ashop.SQL.escape(value) .. " WHERE id = " .. (subID or object_typeID))
    
    net.Start('ashop_ObjectType_Edit')
        net.WriteBool(isMain)
        net.WriteUInt(object_typeID, ashop.Config.BitsObjectType)
    
        if !isMain then
            net.WriteUInt(subID, ashop.Config.BitsObjectType)
        end
    
        net.WriteBool(typeValue == "UInt8")
        ashop.Network.GetWriteFunction(typeValue, value)
    net.Broadcast()
end, 0.5, true)

ashop.SafeNet('SubObjectType_Edit', function(ply)
    local objectTypeID = net.ReadUInt(ashop.Config.BitsObjectType)
    local subID = net.ReadUInt(ashop.Config.BitsObjectType)
    local paramID = net.ReadUInt(7)
    local objectTypeTable = ashop.object_types[objectTypeID]
        
    if !subID or !objectTypeTable or !objectTypeTable.sub_cat[subID] then return end
    if !objectTypeTable.SubCategoriesParameters or !objectTypeTable.SubCategoriesParameters[paramID] then return end

    local param = objectTypeTable.SubCategoriesParameters[paramID]
    local value = ashop.Network.GetReadFunction(param[2], {
        required = true
    })

    assert(ashop.VerifyInput(value, param[2], {isRequired = true}), "Value does not respect options: " .. param[1])
    local metadataTable = objectTypeTable.sub_cat[subID].metadata
    metadataTable[paramID] = value

    local md = util.TableToJSON(metadataTable)
    md = string.gsub(md, "'", "\\'")
    md = string.gsub(md, "\\", "\\\\")

    ashop.SQL.query("UPDATE ashop_sub_types SET metadata = " .. ashop.SQL.escape(md) .. " WHERE id = " .. subID)

    net.Start('ashop_SubObjectType_Edit')
        net.WriteUInt(objectTypeID, ashop.Config.BitsObjectType)
        net.WriteUInt(subID, ashop.Config.BitsObjectType)
        net.WriteUInt(paramID, 7)
        ashop.Network.GetWriteFunction(param[2], value, {
            required = true
        })
    net.Broadcast()

    ashop.Logs.PushLog(ashop.Logs.IDs.ObjectType_Update, objectTypeTable.sub_cat[subID].name, ply)
end, 0.5, true)

function ashop.AdminInventoryRead(ply, str)
    // Invalid steamid
    if !isnumber(tonumber(str)) then return end

    ashop.Logs.PushLog(ashop.Logs.IDs.AdminInventory_Read, ply, str)

    local e = player.GetBySteamID64(str)
    if IsValid(e) and e:IsPlayer() then
        // TODO: send notification
        if !e.ashop_data or !e.ashop_data.items then return end

        // Send things he does not know
        local playerTable = ashop.knownItems.plys[ply]

        net.Start('ashop_Admin_ReceiveInventory')
            net.WriteUInt(e:ashopMoneyGet(true), 32)
            net.WriteUInt(e:ashopMoneyGet(false), 32)
            net.WriteString(str)

            // Write items the admin is missing
            for k, v in pairs(e.ashop_data.items) do
                if !playerTable['items'][v.item_id] then
                    ashop.knownSetState(ply, 'items', true, v.item_id)
                    net.WriteBool(true)
                    ashop.Network.W_ItemData(ashop.items[v.item_id])
                end
            end

            net.WriteBool(false)

            // Now, write the real inventory
            // Since, he does not know every items the player have
            // We need to send him
            // We don't set any state, because the item was never sent to 
            // others people. Set known on him would make him know every
            // update, and this is bad

            // Also, we could optimise and don't send items admin already know
            // BUT this is a bad idea, since user may have edited them.
            ashop.Network.W_Bulk(
                e.ashop_data.items, 
                ashop.Network.W_PlyItemFull,
                1, 32, 12)
        net.Send(ply)
    else
        // Get this SQL
        if !isnumber(tonumber(str)) then return end

        ashop.SQL.query("SELECT * FROM ashop_bought WHERE owner_id IN (SELECT id FROM ashop_players WHERE steamid = '" .. str .. "')", function(q)
            if !q then
                // TODO: Notify
                return
            end

            local toDict = {}
            for k, v in ipairs(q) do
                toDict[tonumber(v.id)] = v
            end

            local playerTable = ashop.knownItems.plys[ply]

            net.Start('ashop_Admin_ReceiveInventory')
                // TODO: real money
                net.WriteUInt(0, 32)
                net.WriteUInt(0, 32)
                net.WriteString(str)
                for k, v in pairs(toDict) do
                    if !playerTable['items'][tonumber(v.item_id)] then
                        ashop.knownSetState(ply, 'items', true, tonumber(v.item_id))
                        net.WriteBool(true)
                        ashop.Network.W_ItemData(ashop.items[tonumber(v.item_id)])
                    end
                end
                net.WriteBool(false)

                ashop.Network.W_Bulk(
                    playerTable,
                    ashop.Network.W_PlyItemFull,
                    1, 32, 12)
            net.Send(ply)
        end)
    end
end

ashop.SafeNet('Admin_ReceiveInventory', function(ply)
    ashop.AdminInventoryRead(ply, net.ReadString())
end, 0.5, true)

util.AddNetworkString('ashop_Admin_ReceiveInventoryMoney')
function ashop.AdminInventoryMoneyEdit(ply, steamID64, amt, b)
    if !isnumber(tonumber(steamID64)) then return end

    local e = player.GetBySteamID64(steamID64)

    if IsValid(e) and e.ashop_data then
        e:ashopMoneySet(amt, b)

        net.Start('ashop_Admin_ReceiveInventoryMoney')
            net.WriteUInt(amt, 32)
            net.WriteBool(b)
        net.Send(ply)
    else
        ashop.SQL.query('UPDATE ashop_players SET ' .. (b and "money_premium" or "money_normal") .. " = " .. amt .. " WHERE steamid = '" .. steamID64 .. "'")
    end
    
    ashop.Logs.PushLog(ashop.Logs.IDs[b and 'AdminInventory_EditMoneyPremium' or 'AdminInventory_EditMoney'], ply, amt, steamID64)
end

ashop.SafeNet('Admin_ReceiveInventoryMoney', function(ply)
    ashop.AdminInventoryMoneyEdit(ply, net.ReadString(), net.ReadUInt(32), net.ReadBool())
end, 0.5, true)

ashop.SafeNet('Admin_ReceiveInventoryItemData', function(adminPly)
    local s64 = net.ReadString()

    if !isnumber(tonumber(s64)) then return end

    local ply = player.GetBySteamID64(s64)
    local itemid = net.ReadUInt(ashop.Config.BitsPlyItemID)
    local act2 = net.ReadUInt(3)

    if IsValid(ply) then
        if act2 == 0 then
            if !ply.ashop_data or !ply.ashop_data.items[itemid] then return end
            local plyItem = ply.ashop_data.items[itemid]
            ashop.actions.Give(ply, plyItem.item_id, util.TableToJSON(plyItem.metadata), 0, false, function(id)
                net.Start('ashop_Admin_ReceiveInventoryItemData')
                    net.WriteUInt(itemid, ashop.Config.BitsPlyItemID)
                    net.WriteUInt(0, 3)
                    net.WriteUInt(id, ashop.Config.BitsPlyItemID)
                net.Send(adminPly)
            end)

            ashop.Logs.PushLog(ashop.Logs.IDs.AdminInventory_AddItem, adminPly, ashop.items[ply.ashop_data.items[itemid].item_id].name, s64)
        elseif act2 == 1 then
            if !ply.ashop_data or !ply.ashop_data.items[itemid] then return end
            ashop.actions.DeletePlayerItem(ply, itemid)
            net.Start('ashop_Admin_ReceiveInventoryItemData')
                net.WriteUInt(itemid, ashop.Config.BitsPlyItemID)
                net.WriteUInt(1, 3)
            net.Send(adminPly)

            ashop.Logs.PushLog(ashop.Logs.IDs.AdminInventory_RemoveItem, adminPly, ashop.items[ply.ashop_data.items[itemid].item_id].name, s64)
        elseif act2 == 2 then
            if !ashop.items[itemid] then return end
            ashop.actions.Give(ply, itemid, nil, 0, false, function(id)
                net.Start('ashop_Admin_ReceiveInventoryItemData')
                    net.WriteUInt(itemid, ashop.Config.BitsPlyItemID)
                    net.WriteUInt(2, 3)
                    net.WriteUInt(id, ashop.Config.BitsPlyItemID)
                net.Send(adminPly)
            end)

            ashop.Logs.PushLog(ashop.Logs.IDs.AdminInventory_AddItem, adminPly, ashop.items[itemid].name, s64)
        end
    else
        if act2 == 0 then
            ashop.SQL.query("SELECT ashop_bought.* FROM ashop_bought, ashop_players WHERE steamid = '" .. s64 .. "' AND ashop_bought.id = " .. itemid .. " LIMIT 1", function(d)
                if !d then return end

                d = d[1]

                ashop.actions.GiveOffline(s64, tonumber(d.item_id), (d.metadata and d.metadata != "NULL") and d.metadata or nil, 0, nil, false, function(id)
                    net.Start('ashop_Admin_ReceiveInventoryItemData')
                        net.WriteUInt(itemid, ashop.Config.BitsItemID)
                        net.WriteUInt(0, 3)
                        net.WriteUInt(id, ashop.Config.BitsPlyItemID)
                    net.Send(adminPly)
                end)

                ashop.Logs.PushLog(ashop.Logs.IDs.AdminInventory_AddItem, adminPly, ashop.items[tonumber(d.item_id)].name, s64)
            end )
        elseif act2 == 1 then
            DeletePlayerItemRaw(itemid)
            net.Start('ashop_Admin_ReceiveInventoryItemData')
                net.WriteUInt(itemid, ashop.Config.BitsItemID)
                net.WriteUInt(1, 3)
            net.Send(adminPly)

            ashop.Logs.PushLog(ashop.Logs.IDs.AdminInventory_RemoveItemOffline, adminPly, s64)
        else
            ashop.actions.GiveOffline(s64, itemid, nil, 0, nil, false, function(id)
                net.Start('ashop_Admin_ReceiveInventoryItemData')
                    net.WriteUInt(itemid, ashop.Config.BitsPlyItemID)
                    net.WriteUInt(2, 3)
                    net.WriteUInt(id, ashop.Config.BitsPlyItemID)
                net.Send(adminPly)
            end)

            ashop.Logs.PushLog(ashop.Logs.IDs.AdminInventory_AddItem, adminPly, ashop.items[itemid].name, s64)
        end
    end
end, 0.5, true)

util.AddNetworkString('ashop_GroupRanks_New')
function ashop.RankGroupCreate(n)
    assert(string.len(n) <= 24, "Name too long")
    ashop.SQL.query("INSERT INTO ashop_groupranks(name, ranks, freePerTime, premiumPerTime) VALUES(" .. ashop.SQL.escape(n) .. ", '{}', 0, 0)", function(_, q0)
        ashop.groupranks[q0:lastInsert()] = {
            id = q0:lastInsert(),
            name = n,
            ranks = {}
        }

        net.Start('ashop_GroupRanks_New')
            net.WriteBool(true)
            ashop.Network.W_GroupRank(ashop.groupranks[q0:lastInsert()])
            net.WriteBool(false)
        net.Broadcast()
    end)
end

ashop.SafeNet('GroupRanks_New', function(ply)
    local n = net.ReadString()
    ashop.RankGroupCreate(n)
    ashop.Logs.PushLog(ashop.Logs.IDs.RankGroupCreateBy, n, ply)
end, 1, true)

ashop.SafeNet('GroupRanks_Delete', function(ply)
    local id = net.ReadUInt(ashop.Config.BitsGroupRank)

    if !ashop.groupranks[id] then return end

    // Urgh, switch every items, let's hope they won't do that every day
    for k, v in pairs(ashop.items) do
        if v.group_restrained == id then
            ashop.ChangeItemValue(k, 10, nil)
        end
    end

    ashop.Logs.PushLog(ashop.Logs.IDs.RankGroupDelete, ashop.groupranks[id].name, ply)
    ashop.SQL.query('DELETE FROM ashop_groupranks WHERE id = ' .. id)

    ashop.groupranks[id] = nil

    net.Start('ashop_GroupRanks_Delete')
        net.WriteUInt(id, ashop.Config.BitsGroupRank)
    net.Broadcast()
end, 1, true)

ashop.SafeNet('Render_Delete', function(ply)
    local id = net.ReadUInt(ashop.Config.BitsRender)
    if !ashop.render[id] or
        (ashop.render[id].cat and !table.IsEmpty(ashop.render[id].cat)) or
        table.Count(ashop.render) <= 1 then return end

    local n = ashop.render[id].name
    ashop.render[id] = nil
    ashop.SQL.query('DELETE FROM ashop_render WHERE id = ' .. id)

    net.Start('ashop_Render_Delete')
        net.WriteUInt(id, ashop.Config.BitsRender)
    net.Broadcast()

    ashop.Logs.PushLog(ashop.Logs.IDs.Render_Delete, n, ply)
end, 1, true)

util.AddNetworkString('ashop_Pac3_Delete')
function ashop.DeletePac3(pac3)
    if !ashop.pac3[pac3] then return end
    ashop.pac3[pac3] = nil

    ashop.SQL.query('DELETE FROM ashop_pac3 WHERE id = ' .. pac3)
    net.Start('ashop_Pac3_Delete')
        net.WriteUInt(pac3, ashop.Config.BitsPac3)
    net.Broadcast()
end

util.AddNetworkString('ashop_GroupRanks_Edit')
function ashop.RankGroupUpdate(id, actID, value)
    if !ashop.groupranks[id] then return end
    if !actID or actID > 5 then return end

    if actID != 5 then
        local sqlColumn

        if actID == 0 then
            sqlColumn = 'name'
            assert(string.len(value) <= 24, "Too long name")
        elseif actID == 1 then
            sqlColumn = 'desc'
        elseif actID == 2 then
            sqlColumn = 'messageOnFail'
        elseif actID == 3 then
            sqlColumn = 'freePerTime'
        elseif actID == 4 then
            sqlColumn = 'premiumPerTime'
        end

        if actID == 3 or actID == 4 then
            ashop.SQL.query("UPDATE ashop_groupranks SET " .. sqlColumn .. " = " .. (value or "NULL") .. " WHERE id = " .. id)
        else
            ashop.SQL.query("UPDATE ashop_groupranks SET " .. sqlColumn .. " = \"" .. (value and ashop.SQL.escape(value) or "NULL") .. "\" WHERE id = " .. id)
        end

        ashop.groupranks[id][sqlColumn] = value

        net.Start('ashop_GroupRanks_Edit')
            net.WriteUInt(id, ashop.Config.BitsGroupRank)
            net.WriteUInt(actID, 3)

            if actID == 0 then
                net.WriteString(value)
            else
                net.WriteBool(value)
                if value then
                    if actID == 1 or actID == 2 then
                        net.WriteString(value)
                    else
                        net.WriteUInt(value, 16)
                    end
                end
            end
        net.Broadcast()
    else
        ashop.groupranks[id]['ranks'] = value
        ashop.SQL.query("UPDATE ashop_groupranks SET ranks = " .. ashop.SQL.escape(util.TableToJSON(value)) .. " WHERE id = " .. id)

        net.Start('ashop_GroupRanks_Edit')
            net.WriteUInt(id, ashop.Config.BitsGroupRank)
            net.WriteUInt(actID, 3)

            for k, v in pairs(value) do
                net.WriteBool(true)
                net.WriteString(k)
            end
            net.WriteBool(false)
        net.Broadcast()
    end
end

ashop.SafeNet('GroupRanks_Edit', function(ply)
    local id = net.ReadUInt(ashop.Config.BitsGroupRank)
    local actID = net.ReadUInt(3)
    local value

    if actID > 5 then return end

    if actID == 0 then
        value = net.ReadString()
    elseif actID == 1 or actID == 2 then
        value = net.ReadBool() and net.ReadString() or nil
    elseif actID == 3 or actID == 4 then
        value = net.ReadBool() and net.ReadUInt(16) or nil
    else
        value = {}

        while(net.ReadBool()) do
            value[net.ReadString()] = true
        end
    end

    ashop.RankGroupUpdate(id, actID, value)
    ashop.Logs.PushLog(ashop.Logs.IDs.RankGroupEditBy, ashop.groupranks[id].name, ply)
end, 1, true)