function ashop.CreateItem(object_type, sub_type, name, 
    price, premium_price, metadata, rarity, promotion_start, promotion_end, 
    promotion_amount, picture_link, delete_death, 
    group_restrained, expireTime)

    assert(!expireTime or expireTime >= 0, "ExpireTime shouldn't be negative, set it as nil or positive integer")

    // metadata respect object_type
    if !name then
        return "Unspecified name"
    elseif string.len(name) > 32 then
        return "Too long name"
    elseif !object_type then
        return "Missing object_type"
    elseif !ashop.object_types[object_type] then
        return "Object_type id is not existing"
    elseif !rarity then
        return "Unspecified rarity"
    elseif !ashop.rarity[rarity] then
        return "Rarity does not exist"
    end

    local obj_type = ashop.object_types[object_type]

    if sub_type then
        // Wrong arg
        if table.IsEmpty(obj_type.sub_cat or {}) then
            return "SubCategory specified for a object_type without subcategories"
        end

        // Not existing arg
        if !obj_type.sub_cat[sub_type] then
            return "Specified sub_type does not exist"
        end
    else
        if obj_type.sub_cat then
            return "No sub_types specified for a object_type with subcategories"
        end
    end

    for k, v in pairs(obj_type.ItemParameters or {}) do
        // TODO: Also check type
        if v.options and v.options.required and (metadata or {})[k] == nil then
            return "Missing a required ItemParameters: " .. v.name
        end

        // Check values
        if v.options and !ashop.VerifyInput((metadata or {})[k], v.type, v.options) then
            return "ItemParameters does not respect options: " .. v.name
        end
    end

    local nameValue = ""
    local values = ""

    // The trick is that lua will not create nil values in table
    // Doing this filter all nil values
    local item = {
        ["object_types"] = object_type,
        ["sub_types"] = sub_type, 
        ["name"] = name,
        ["price"] = price,
        ["premium_price"] = premium_price,
        ["promotion_end"] = promotion_end,
        ["promotion_amount"] = promotion_amount,
        ["promotion_start"] = promotion_start,
        ["rarity"] = rarity,
        ["delete_death"] = delete_death,
        ["metadata"] = metadata,
        ['picture_link'] = picture_link,
        ['group_restrained'] = group_restrained,
        ['expireTime'] = expireTime
    }

    local first = false
    for k, v in pairs(item) do
        if !first then
            nameValue = k
            values = isnumber(v) and v or "'" .. v .. "'"
            first = true
        else
            nameValue = nameValue .. "," .. k
            if isnumber(v) then
                values = values .. ", " .. v
            elseif isbool(v) then
                values = values .. ", " .. (v and "1" or "0")
            else
                // First, parse \n, then we parse \
                local t = v
                if istable(v) then
                    local md = util.TableToJSON(v)
                    md = string.gsub(md, "'", "\\'")
                    md = string.gsub(md, "\\", "\\\\")

                    t = md
                end

                values = values .. ", " .. ashop.SQL.escape(t)
            end
        end
    end

    local str = "INSERT INTO ashop_items(%s) VALUES(%s)"
    str = string.format(str, nameValue, values)

    ashop.SQL.query(str, function(data, qO)
        item.id = qO:lastInsert()
        ashop.items[qO:lastInsert()] = item

        // Send to player
        local plys = ashop.playersInMenu()
        net.Start('ashop_Item_New')
            net.WriteBool(true)
            ashop.Network.W_ItemData(item)
            net.WriteBool(false)
        net.Send(plys)

        // Nobody, except players in menus, need to know about the update
        // Since, nobody have the item equipped yet
        for k, v in ipairs(plys) do
            if !IsValid(v) then
                print("[AShop] Player is not valid ? We handle this bug, but please report it in ticket")
                continue
            end

            ashop.knownSetState(v, 'items', true, qO:lastInsert())
        end

        ashop.NewItemBitsCounter(qO:lastInsert())
    end)
end

hook.Add("PostPlayerDeath", "AShop_RemoveItem", function(ply)
    if !ply.ashop_data or !ply.ashop_data.equipped then return end

    for objectTypeID, subTypes in pairs(ply.ashop_data.equipped) do
        for subTypeID, slots in pairs(subTypes) do
            for slotID, plyItemID in pairs(slots) do
                local plyItem = ply.ashop_data.items[plyItemID]
                assert(plyItem, "Missing plyItem, while being equipped")

                local item = ashop.items[plyItem.item_id]

                if item.delete_death then
                    //ashop.actions.DeletePlayerItem(ply, plyItemID)
                end
            end
        end
    end
end)