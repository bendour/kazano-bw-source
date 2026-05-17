ashop.knownItems = ashop.knownItems or {
    allKnown = {
        plyitem = {},
        items = {},
        itemsCount = {}
    },
    plys = {},
    inMenus = {}
}

hook.Add("PlayerInitialSpawn", "ashop_initKnownItems", function(ply)
    ashop.knownItems.plys[ply] = {
        plyitem = {},
        items = {},
    }
end)

hook.Add("PlayerDisconnected", "ashop_clearVisibility", function(ply)
    ashop.knownItems.plys[ply] = nil

    ashop.knownItems.inMenus[ply] = nil

    if !ply.ashop_data then return end

    for k, v in pairs(ashop.knownItems.plys) do
        if !v.plyitem then continue end
        for i, j in pairs(ply.ashop_data.items or {}) do
            v.plyitem[i] = nil
        end
    end
end)

function ashop.doesPlayersKnow(dataID, key, setTrueOnPass, invert)
    local plys = {}

    for k, v in ipairs(player.GetHumans()) do
        // We assert it
        assert(ashop.knownItems.plys[v] and ashop.knownItems.plys[v][key], "Missing key ? Why ?")
        ashop.knownItems.plys[v][key] = ashop.knownItems.plys[v][key] or {}

        local b = ashop.knownItems.plys[v][key][dataID]

        if invert then b = !b end
        if b then
            table.insert(plys, v)
        end

        if setKnown then
            ashop.knownItems.plys[v][key][dataID] = true
        end
    end

    return plys
end

function ashop.playersInMenu()
    local plys = {}
    for k, v in pairs(ashop.knownItems.inMenus) do
        table.insert(plys, k)
    end
    return plys
end

function ashop.knownSetState(ply, key, state, dataKey)
    ashop.knownItems.plys[ply][key] = ashop.knownItems.plys[ply][key] or {}
    ashop.knownItems.plys[ply][key][dataKey] = state
end



/*
    dataTable: HashMap<dataID, dataData>
*/

util.AddNetworkString('ashop_Item_New')
util.AddNetworkString('ashop_PlyItem_New')
function ashop.sendDataToIgnorants(dataTable, key, ...)
    local extradata = {...}
    local t = {}

    for k, v in ipairs(player.GetHumans()) do
        if !v.ashop_data or !v.ashop_data.ready then continue end

        ashop.knownItems.plys[v][key] = ashop.knownItems.plys[v][key] or {}

        for dataID in pairs(dataTable) do
            if !ashop.knownItems.plys[v][key][dataID] then
                t[dataID] = t[dataID] or {}
                table.insert(t[dataID], v)
                ashop.knownItems.plys[v][key][dataID] = true
            end
        end
    end

    for k, v in pairs(t) do
        if table.IsEmpty(v) then return end

        if key == 'items' then
            net.Start('ashop_Item_New')
                net.WriteBool(true)
                ashop.Network.W_ItemData(dataTable[k])
        else
            net.Start('ashop_PlyItem_New')
                net.WriteUInt(extradata[1]:UserID(), 13)
                net.WriteBool(true)
                ashop.Network.W_PlyItem(dataTable[k])
        end
        net.WriteBool(false)
        net.Send(v)
    end

    return t
end

function ashop.getAllKnownItems(key)
    return ashop.knownItems.allKnown[key]
end

hook.Add('ashop_equip', 'trackVisibility', function(_, slot, item, plyItem)
    local allKnown = ashop.knownItems.allKnown

    if !allKnown.itemsCount[item.id] then
        ashop.knownItems.allKnown.items[item.id] = item
        allKnown.itemsCount[item.id] = 1
    else
        allKnown.itemsCount[item.id] = allKnown.itemsCount[item.id] + 1
    end
end)

hook.Add('ashop_unequip', 'trackVisibility', function(_, slot, item, plyItem)
    if !item then return end
    local allKnown = ashop.knownItems.allKnown.itemsCount

    assert(allKnown[item.id], "This item should be known, since this was equipped")
    allKnown[item.id] = allKnown[item.id] - 1

    if allKnown[item.id] <= 0 then
        allKnown[item.id] = nil
        ashop.knownItems.allKnown.items[item.id] = nil
    end
end)