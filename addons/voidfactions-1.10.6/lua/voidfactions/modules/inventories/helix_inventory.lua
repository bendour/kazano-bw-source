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
INVENTORY:Name("Helix Inventory")

INVENTORY:IsInstalledFunc(function()
    return tobool(ix)
end)

INVENTORY:GetItemsFunc(function (ply)

end)

INVENTORY:GetItemDataFunc(function (ply, itemClass)

end)

INVENTORY:TakeItemFunc(function (ply, itemClass)

end)

INVENTORY:GiveItemFunc(function (ply, class, dropClass, model, data)

end)

-- Dont add inventory until this code is done
--VoidFactions.Inventories:AddInventory(INVENTORY)