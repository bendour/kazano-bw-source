-- Helper functions

VoidFactions.Inventories = VoidFactions.Inventories or {}
VoidFactions.Inventories.List = {}

-- Class for creating new inventories

local INVENTORY_CLASS = {}
INVENTORY_CLASS.__index = INVENTORY_CLASS

function INVENTORY_CLASS:New()
	local object = setmetatable({}, INVENTORY_CLASS)
		object.name = nil

        object.getItemsFunc = nil
        object.takeItemFunc = nil
        object.giveItemFunc = nil
        object.getItemDataFunc = nil
        object.getRarityColor = nil
        object.isInstalledFunc = nil
	return object
end

function INVENTORY_CLASS:Name(name)
    self.name = name
end


-- Function setters

function INVENTORY_CLASS:GetItemsFunc(func)
    self.getItemsFunc = func
end

function INVENTORY_CLASS:TakeItemFunc(func)
    self.takeItemFunc = func
end

function INVENTORY_CLASS:GiveItemFunc(func)
    self.giveItemFunc = func
end

function INVENTORY_CLASS:GetItemDataFunc(func)
    self.getItemDataFunc = func
end

function INVENTORY_CLASS:GetRarityColorFunc(func)
    self.getRarityColor = func
end

function INVENTORY_CLASS:IsInstalledFunc(func)
    self.isInstalledFunc = func
end

-- Functions

function INVENTORY_CLASS:GetItems(ply)
    return self.getItemsFunc(ply)
end

function INVENTORY_CLASS:GetItemData(ply, itemClass)
    return self.getItemDataFunc(ply, itemClass)
end

function INVENTORY_CLASS:TakeItem(ply, item)
    return self.takeItemFunc(ply, item)
end

function INVENTORY_CLASS:GiveItem(ply, class, dropClass, model, data)
    return self.giveItemFunc(ply, class, dropClass, model, data)
end

function INVENTORY_CLASS:GetRarityColor(itemClass)
    if (!self.getRarityColor) then
        return VoidUI.Colors.Background
    end

    return self.getRarityColor(itemClass)
end

function INVENTORY_CLASS:IsInstalled()
    local isInstalled = self.isInstalledFunc and self.isInstalledFunc()
    if (!self.isInstalledFunc) then
        isInstalled = true
    end
    return isInstalled
end

-- Helper functions

function INVENTORY_CLASS:HasItem(ply, itemClass)
    local items = self:GetItems(ply)
    return items[itemClass] or false
end

function INVENTORY_CLASS:GetPrintName(itemClass)
    local printName = nil
    local ent = scripted_ents.Get(itemClass)
    local wep = weapons.Get(itemClass)
    if (ent) then
        printName = ent.PrintName
    end
    if (wep) then
        printName = wep.PrintName
    end

    return printName or itemClass
end

-- Public functions

function VoidFactions.Inventories:NewInventory()
	return INVENTORY_CLASS:New()
end

function VoidFactions.Inventories:AddInventory(inv)
    if (!istable(inv)) then return end

    if (!inv.name) then
        VoidFactions.PrintError("An inventory does not have a name! Stack trace:")
        print(debug.traceback())
        return
    end

    if (VoidFactions.Inventories.List[inv.name]) then
        VoidFactions.PrintError("An inventory with the name " .. inv.name .. " was already registered!")
        return
    end

    VoidFactions.Inventories.List[inv.name] = inv
    VoidFactions.PrintDebug("Registered inventory " .. inv.name .. "!")
end