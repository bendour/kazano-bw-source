-- Utility function

local function getItemByClass(inv, class)
    local items = inv:GetInventory()

    for k, item in pairs(items or {}) do
        if (item.ent == class) then
            return item
        end
    end
end

local function createItemStruct(item, itemClass, dropClass, data)
    return {
        class = itemClass,
        model = item:GetModel(itemClass),
        dropClass = dropClass,
        data = data or {}
    }
end

-- Class
local INVENTORY = VoidFactions.Inventories:NewInventory()
INVENTORY:Name("Xenin Inventory")

INVENTORY:IsInstalledFunc(function ()
    return XeninInventory and true or false
end)

INVENTORY:GetItemsFunc(function (ply)
    local inventory = ply:XeninInventory()
    local items = inventory:GetInventory()
		
    local itemsTbl = {}
    for k, item in pairs(items or {}) do
        for i = 1, item.amount do
            itemsTbl[item.ent] = true
        end
    end

    return itemsTbl
end)

INVENTORY:GetItemDataFunc(function (ply, itemClass)
    local inventory = ply:XeninInventory()
    local itemStruct = getItemByClass(inventory, itemClass)
    if (!itemStruct) then return end

    local item = XeninInventory:GetItem(itemStruct.dropEnt)
    if (!item) then return end

    return createItemStruct(item, itemClass, itemStruct.dropEnt, itemStruct.data)
end)

INVENTORY:TakeItemFunc(function (ply, itemClass)
    local inventory = ply:XeninInventory()
    local item = getItemByClass(inventory, itemClass)
    if (!item) then return end

    inventory:ReduceAmount(item.id, 1)
end)

INVENTORY:GiveItemFunc(function (ply, class, dropClass, model, data)
    local inventory = ply:XeninInventory()
    inventory:Add(class, dropClass, model, 1, data or {})
end)

INVENTORY:GetRarityColorFunc(function (dropEnt)
    local rarity = XeninInventory:GetRarity(dropEnt)
    local cat = XeninInventory.Config.Categories[rarity]
    local color = cat and cat.color or XeninInventory.Config.Categories[1].color

    return color
end)

VoidFactions.Inventories:AddInventory(INVENTORY)