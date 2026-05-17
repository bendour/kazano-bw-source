-- Do not confuse with upgrade modules.
VoidFactions.CustomUpgrades = VoidFactions.CustomUpgrades or {}

-- Class

local CUSTOMUPGRADE_CLASS = {}
CUSTOMUPGRADE_CLASS.__index = CUSTOMUPGRADE_CLASS

function CUSTOMUPGRADE_CLASS:New(id, name, module, value, currency, cost, icon)
	local newObject = setmetatable({}, CUSTOMUPGRADE_CLASS)
		newObject.id = id
        newObject.name = name

        newObject.module = module

        newObject.value = value

        newObject.currency = currency
        newObject.cost = cost

        newObject.icon = icon
	return newObject
end

-- Setter functions

function CUSTOMUPGRADE_CLASS:SetName(name)
    self.name = name
end

function CUSTOMUPGRADE_CLASS:SetIcon(icon)
    self.icon = icon
end

function CUSTOMUPGRADE_CLASS:SetModule(module)
    self.module = module
end

function CUSTOMUPGRADE_CLASS:SetValue(value)
    self.value = value
end

function CUSTOMUPGRADE_CLASS:SetCurrency(currency)
    self.currency = currency
end

function CUSTOMUPGRADE_CLASS:SetCost(cost)
    self.cost = cost
end


-- Functions

function VoidFactions.CustomUpgrades:New(...)
    return CUSTOMUPGRADE_CLASS:New(...)
end