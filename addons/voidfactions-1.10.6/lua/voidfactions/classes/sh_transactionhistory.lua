VoidFactions.TransactionHistory = VoidFactions.TransactionHistory or {}

-- Class

local TRANSACTION_CLASS = {}
TRANSACTION_CLASS.__index = TRANSACTION_CLASS

function TRANSACTION_CLASS:New(time, faction, sid, diff, item)
	local newObject = setmetatable({}, TRANSACTION_CLASS)
        newObject.time = time
        newObject.faction = faction

        newObject.sid = sid
        newObject.difference = diff

        newObject.itemClass = item
        newObject.isMoney = false

	return newObject
end

-- Setters

function TRANSACTION_CLASS:SetIsMoney()
    self.isMoney = true
end

-- Functions

function VoidFactions.TransactionHistory:New(...)
    return TRANSACTION_CLASS:New(...)
end