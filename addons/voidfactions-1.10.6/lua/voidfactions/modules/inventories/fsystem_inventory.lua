-- Functions

local function createItemStruct(itemModel, itemClass, dropClass, data)
    return {
        class = itemClass,
        model = itemModel,
        dropClass = dropClass,
        data = data or {}
    }
end

-- Class

local INVENTORY = VoidFactions.Inventories:NewInventory()
INVENTORY:Name("Inventory System")

INVENTORY:IsInstalledFunc(function ()
    return FS_INVENTORY and true or false
end)

INVENTORY:GetItemsFunc(function (ply)
    local inventory = ply:FS_GetInventoryItems()
    local tbl = {}
    for k, v in pairs(inventory) do
        if (!v.class) then continue end -- wtf??
        tbl[v.class] = true
    end

    return tbl
end)

INVENTORY:GetItemDataFunc(function (ply, itemClass)
    local inventory = ply:FS_GetInventoryItems()
    local itemData = nil
    for k, v in pairs(inventory) do
        if (v.class == itemClass) then
            itemData = v
        end
    end

    if (!itemData) then return end

    return createItemStruct(itemData.model, itemClass, itemClass, {amount = itemData.amount})
end)

INVENTORY:TakeItemFunc(function (ply, itemClass)
    local inventory = ply:FS_GetInventoryItems()
    local itemData = nil
    local itemId = nil
    for k, v in pairs(inventory) do
        if (v.class == itemClass) then
            itemData = v
            itemId = k
        end
    end

    if (!itemData) then return end

    ply:FS_RemoveItem(itemId)
end)

INVENTORY:GiveItemFunc(function (ply, class, dropClass, model, data)
    ply:FS_GiveItem(class, data.amount)
end)

VoidFactions.Inventories:AddInventory(INVENTORY)