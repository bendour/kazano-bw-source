VoidFactions.DepositItem = VoidFactions.DepositItem or {}

-- Class

local DEPOSITITEM_CLASS = {}
DEPOSITITEM_CLASS.__index = DEPOSITITEM_CLASS

function DEPOSITITEM_CLASS:New(id, faction, class, dropEnt, model, data, isExternal)
	local newObject = setmetatable({}, DEPOSITITEM_CLASS)
		newObject.id = id
        newObject.faction = faction

        newObject.dropEnt = dropEnt
        newObject.class = class
        newObject.model = model
        newObject.data = data
        newObject.isExternal = isExternal
	return newObject
end

-- Functions

function VoidFactions.DepositItem:New(...)
    return DEPOSITITEM_CLASS:New(...)
end