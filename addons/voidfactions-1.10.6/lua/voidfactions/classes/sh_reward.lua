VoidFactions.Rewards = VoidFactions.Rewards or {}
VoidFactions.Rewards.List = SERVER and {} or nil

-- Class

local REWARD_CLASS = {}
REWARD_CLASS.__index = REWARD_CLASS

function REWARD_CLASS:New(id, name, module, requiredValue, money, xp, icon)
	local newObject = setmetatable({}, REWARD_CLASS)
		newObject.id = id
        newObject.name = name
        newObject.module = module

        newObject.requiredValue = requiredValue

        newObject.money = money
        newObject.xp = xp

        newObject.icon = icon
	return newObject
end

-- Setter functions

function REWARD_CLASS:SetName(name)
    self.name = name
end

function REWARD_CLASS:SetModule(module)
    self.module = module
end

function REWARD_CLASS:SetRequiredValue(val)
    self.requiredValue = val
end

function REWARD_CLASS:SetMoneyReward(money)
    self.money = money
end

function REWARD_CLASS:SetXPReward(xp)
    self.xp = xp
end

function REWARD_CLASS:SetIcon(icon)
    self.icon = icon
end


-- Functions

function VoidFactions.Rewards:New(...)
    return REWARD_CLASS:New(...)
end