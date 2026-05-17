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
INVENTORY:Name("IDInventory")

INVENTORY:IsInstalledFunc(function ()
    return IDInv and true or false
end)

INVENTORY:GetItemsFunc(function (ply)
    local inventory = SERVER and ply:FetchInventory() or IDInv.Handlers.Inventory
    local tbl = {}
    for k, v in pairs(inventory) do
        local class = v.class
        if (class) then
            tbl[class] = true
        end
    end

    return tbl
end)

INVENTORY:GetItemDataFunc(function (ply, itemClass)
    local inventory = SERVER and ply:FetchInventory() or IDInv.Handlers.Inventory
    local itemData = nil
    for k, v in pairs(inventory) do
        if (v.class == itemClass) then
            itemData = v
        end
    end

    if (!itemData) then return end

    return createItemStruct(itemData.model, itemClass, itemClass, {amount = itemData.amt})
end)

INVENTORY:TakeItemFunc(function (ply, itemClass)
    local inventory = ply:FetchInventory()
    local itemData = nil
    local itemId = nil
    for k, v in pairs(inventory) do
        if (v.class == itemClass) then
            itemData = v
            itemId = k
        end
    end

    if (!itemData) then return end

    inventory[itemId].amt = inventory[itemId].amt - 1
    ply:UpdateInventory(inventory)
end)

INVENTORY:GiveItemFunc(function (ply, class, dropClass, model, data)
    ply:GiveItem(class, model, data.amount)
end)

VoidFactions.Inventories:AddInventory(INVENTORY)