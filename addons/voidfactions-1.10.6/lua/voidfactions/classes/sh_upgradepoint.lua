VoidFactions.UpgradePoints = VoidFactions.UpgradePoints or {}
VoidFactions.UpgradePoints.List = SERVER and {} or nil

-- Class

local UPGRADEPOINT_CLASS = {}
UPGRADEPOINT_CLASS.__index = UPGRADEPOINT_CLASS

function UPGRADEPOINT_CLASS:New(id, upgrade, posX, posY, to)
	local newObject = setmetatable({}, UPGRADEPOINT_CLASS)
		newObject.id = id
        newObject.upgrade = upgrade

        newObject.posX = posX
        newObject.posY = posY

        -- to is a table with all the points that this point is pointing to
        newObject.to = {}
	return newObject
end

-- Setter functions

function UPGRADEPOINT_CLASS:SetTo(to)
    self.to = to
end

function UPGRADEPOINT_CLASS:AddTo(to)
    self.to[#self.to + 1] = to
end

function UPGRADEPOINT_CLASS:SetPos(posX, posY)
    self.posX = posX
    self.posY = posY
end

-- Helper functions

function UPGRADEPOINT_CLASS:CanPurchase(faction)
    -- Check if any of the purchased upgrades has a to for this one
    -- Or if it's a starting point
    
    local hasTo = false
    local isStarting = true 
    for k, v in pairs(VoidFactions.UpgradePoints.List or {}) do
        if (table.HasValue(v.to, self)) then
            isStarting = false
            if (faction.upgrades[v.id]) then
                hasTo = true
            end
        end
    end

    return hasTo or isStarting
end

-- Functions

function VoidFactions.UpgradePoints:New(...)
    return UPGRADEPOINT_CLASS:New(...)
end