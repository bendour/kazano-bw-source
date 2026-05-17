-- Helper functions

VoidFactions.RewardModules = VoidFactions.RewardModules or {}
VoidFactions.RewardModules.List = {}

VoidFactions.FactionRewards = VoidFactions.FactionRewards or {}

local L = VoidFactions.Lang.GetPhrase

-- Class for creating new reward modules

local REWARD_CLASS = {}
REWARD_CLASS.__index = REWARD_CLASS

function REWARD_CLASS:New()
	local object = setmetatable({}, REWARD_CLASS)
		object.name = nil
        object.defaultIcon = nil

        object.setupFunc = nil
	return object
end

function REWARD_CLASS:Name(name)
    self.name = name
end

function REWARD_CLASS:Description(desc)
    self.desc = desc
end

function REWARD_CLASS:DefaultIcon(icon)
    self.defaultIcon = icon
end

-- Function setters

function REWARD_CLASS:Setup(func)
    self.setupFunc = func
end

-- Functions

function REWARD_CLASS:SetValue(faction, val)
    VoidFactions.SQL:UpdateRewardValues(self, faction, val)
end

function REWARD_CLASS:Increment(faction, val)
    local incrVal = (val or 1)

    VoidFactions.SQL:IncrementReward(self, faction, incrVal)
end

function REWARD_CLASS:Decrement(faction, val)
    local decrVal = (val or 1)

    VoidFactions.SQL:IncrementReward(self, faction, -decrVal)
end

-- Function getters

function REWARD_CLASS:PrintName()
    if (string.StartWith(self.name, "reward_")) then
        return L(self.name)
    end

    return self.name
end

function REWARD_CLASS:PrintValueDescription()
    if (string.StartWith(self.desc, "reward_desc_")) then
        return L(self.desc)
    end

    return self.desc
end

-- Public functions

function VoidFactions.RewardModules:NewReward()
	return REWARD_CLASS:New()
end

function VoidFactions.RewardModules:AddReward(reward)
    if (!istable(reward)) then return end

    if (!reward.name) then
        VoidFactions.PrintError("A reward module does not have a name! Stack trace:")
        print(debug.traceback())
        return
    end

    if (VoidFactions.RewardModules.List[reward.name]) then
        VoidFactions.PrintError("A reward module with the name " .. reward.name .. " was already registered!")
        return
    end

    VoidFactions.RewardModules.List[reward.name] = reward
    VoidFactions.PrintDebug("Registered reward module " .. reward.name .. "!")

    if (SERVER) then
        hook.Add("VoidFactions.Settings.Loaded", "VoidFactions.RewardModules.WaitForSettings" .. reward.name, function ()
            if (VoidFactions.Settings:IsStaticFactions()) then return end
            reward.setupFunc()
        end)
    end
end

-- Class for faction rewards

local FACTIONREWARD_CLASS = {}
FACTIONREWARD_CLASS.__index = FACTIONREWARD_CLASS

function FACTIONREWARD_CLASS:New(module, value)
	local object = setmetatable({}, FACTIONREWARD_CLASS)
		object.module = module
        object.value = value
	return object
end

function FACTIONREWARD_CLASS:SetValue(val)
    self.value = val
end

function VoidFactions.FactionRewards:New(...)
	return FACTIONREWARD_CLASS:New(...)
end