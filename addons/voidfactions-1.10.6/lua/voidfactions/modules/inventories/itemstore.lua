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
INVENTORY:Name("ItemStore")

INVENTORY:IsInstalledFunc(function ()
    return itemstore and true or false
end)

INVENTORY:GetItemsFunc(function (ply)
    local inventory = ply.Inventory
    local tbl = {}
    for k, v in pairs(SERVER and inventory:GetItems() or itemstore.containers.Get(ply.InventoryID):GetItems()) do
        local class = v.Data.Class or v.Class
        if (class) then
            tbl[class] = true
        end
    end

    return tbl
end)

INVENTORY:GetItemDataFunc(function (ply, itemClass)
    local items = ply.Inventory:GetItems()
    local itemData = nil
    for k, v in pairs(items) do
        if ( (v.Data and v.Data.Class == itemClass) or v.Class == itemClass) then
            itemData = v
        end
    end

    if (!itemData) then return end

    local data = table.Copy(itemData.Data)
    local isShipment = itemData.Class == "spawned_shipment"
    if (itemData.Stackable and !isShipment) then
        data.Amount = 1
    end

    return createItemStruct(itemData:GetModel(), itemData.Data.Class, itemData.Class, data)
end)

INVENTORY:TakeItemFunc(function (ply, itemClass)
    local inventory = ply.Inventory

    local item = nil
    for k, v in pairs(inventory:GetItems()) do
        if ( (v.Data and v.Data.Class == itemClass) or v.Class == itemClass) then
            item = v

            -- Why....
			local isShipment = v.Class == "spawned_shipment"

            if (isShipment) then
                inventory:SetItem(k, nil)
            else
                local amount = v:GetAmount()
                v:SetAmount(amount - 1)

                if (v:GetAmount() <= 0) then
                    inventory:SetItem(k, nil)
                end
            end
        end
    end

    if (!item) then return end

    inventory:QueueSync()
end)

INVENTORY:GiveItemFunc(function (ply, class, dropClass, model, data)

    local isEmpty = !data or table.IsEmpty(data)
    local tbl = isEmpty and { Model = model, Class = class } or data

	local item = itemstore.Item(dropClass, tbl)
	if (!item) then return end

    ply.Inventory:AddItem(item)
end)

VoidFactions.Inventories:AddInventory(INVENTORY)