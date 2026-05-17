util.AddNetworkString('ashop_openUI')
util.AddNetworkString('ashop_readMissingItemsUI')

local methodSwap = 0

local function calculateItemsSize()
    local sum = 0

    for k, v in pairs(ashop.items) do
        sum = sum + ashop.Config.BitsItemID + ashop.Config.BitsObjectType
            + 2 // 12 / 8

        if v.sub_types then
            sum = sum + math.ceil(ashop.Config.BitsSubObjectType/8)
        end

        // Size of name
        sum = sum + 1 + string.len(v.name)

        if v.price then
            sum = sum + 4
        end

        if v.premium_price then
            sum = sum + 4
        end

        if v.promotion_start then
            sum = sum + 4
        end

        if v.promotion_end then
            sum = sum + 4
        end

        if v.promotion_amount then
            sum = sum + 1
        end

        if v.rarity then
            sum = sum + math.ceil(ashop.Config.BitsRarity / 8)
        end

        if v.group_restrained then
            sum = sum + math.ceil(ashop.Config.BitsGroupRank / 8) // 16 / 8
        end

        if v.picture_link then
            // Text
            sum = sum + 1 + string.len(v.picture_link)
        end

        if v.expireTime then
            sum = sum + 4
        end

        sum = sum + math.ceil(table.Count(ashop.object_types[v.object_types].ItemParameters) / 8)
        for k, data in SortedPairs(ashop.object_types[v.object_types].ItemParameters) do
            if v.metadata[k] != nil then
                sum = sum + ashop.Network.GetNetSizeData(data.type, v.metadata[k], data.options)
            end
        end

        if sum > 60000 then
            methodSwap = 1
            return
        end
    end

    methodSwap = 1
end

hook.Add("ashop_load", "ashop_ScanItems", function(id)
    if id == ashop.LoadState.EverythingLoaded then
        calculateItemsSize()
    end
end)

function ashop.openMenu(ply)
    assert(ashop.Loaded, '[AShop] Trying to open menu, but AShop is not fully loaded. This is caused by a lua error somewhere.')
    
    if methodSwap == 0 then
        calculateItemsSize()
    end

    ashop.knownItems.plys[ply] = ashop.knownItems.plys[ply] or {
        plyitem = {},
        items = {},
    }

    local t = ashop.knownItems.plys[ply]

    if methodSwap == 2 then
        net.Start('ashop_readMissingItemsUI')

        for k, v in pairs(ashop.items) do
            if !t.items[k] then
                net.WriteBool(true)
                ashop.Network.W_ItemData(v)
                t.items[k] = true
            end
        end

        net.WriteBool(false)
        net.Send(ply)

        net.Start('ashop_openUI')
            for k, v in pairs(ply.ashop_data.items) do
                if !t.plyitem[k] then
                    net.WriteBool(true)
                    ashop.Network.W_PlyItem(v)
                    t.plyitem[k] = true
                end
            end
            net.WriteBool(false)
        net.Send(ply)
    else
        // HF with the code below
        local key, value = next(ashop.items)
        local s64 = ply:SteamID64()

        local function loopSending()
            if !IsValid(ply) then
                timer.Remove("ashop_sendItems_" .. s64)
                return
            elseif ply:IsTimingOut() then
                // Don't send data if he didn't received the previous one, to avoid the hard limit of 255kb
                return
            end

            local remainingSize = 63000
            net.Start('ashop_readMissingItemsUI')
                while(key && remainingSize > 1000) do
                    remainingSize = (net.BytesLeft() or 63000)
                    // Send Data
                    if !t.items[key] then
                        net.WriteBool(true)
                        ashop.Network.W_ItemData(value)
                        t.items[key] = true
                    end

                    // Refresh key, value
                    key, value = next(ashop.items, key)
                end

                net.WriteBool(false)
            net.Send(ply)

            if key then return end

            // Open the menu now, we put a big limit, just in case
            local function openMenu()
                if !IsValid(ply) then return end

                net.Start('ashop_openUI')
                    for k, v in pairs(ply.ashop_data.items or {}) do
                        if t.plyitem[k] then continue end

                        net.WriteBool(true)
                        ashop.Network.W_PlyItem(v)
                        t.plyitem[k] = true
                    end
                    net.WriteBool(false)
                net.Send(ply)
            end

            if remainingSize < 10000 then
                timer.Simple(0.25, openMenu)
            else
                openMenu()
            end

            timer.Remove("ashop_sendItems_" .. s64)
            return true
        end

        if !loopSending() then
            timer.Create("ashop_sendItems_" .. s64, ashop.Config.SendItemsChunkSeconds or 0.2, 0, loopSending)
        end
    end

    ashop.knownItems.inMenus[ply] = true
end

concommand.Add('ashop_menu', ashop.openMenu)

ashop.SafeNet("openUI", function(ply)
    ashop.knownItems.inMenus[ply] = nil
end, 0.1, true)

hook.Add( "PlayerButtonUp", "ashop_openMenu", function( ply, button )
    if ashop.Config.OpenKey and button == ashop.Config.OpenKey then
        ashop.openMenu(ply)
    end
end)