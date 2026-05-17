local L = VoidFactions.Lang.GetPhrase

VoidFactions.Upgrades = VoidFactions.Upgrades or {}
VoidFactions.Upgrades.Modules = VoidFactions.Upgrades.Modules or {}
VoidFactions.Upgrades.Custom = SERVER and {} or nil

-- Class for creating new upgrades

local UPGRADE_CLASS = {}
UPGRADE_CLASS.__index = UPGRADE_CLASS

function UPGRADE_CLASS:New()
	local object = setmetatable({}, UPGRADE_CLASS)
		object.name = nil
        object.icon = nil
        object.description = nil
        object.valueDescription = nil

        object.onEquip = nil
        object.onRespawn = nil
        object.onReset = nil
        object.onLoadFunc = nil

        object.formatVal = nil
        object.onlyOneInstance = false
        
        object.isNumeric = false

        object.isInstalledFunc = nil
	return object
end


-- Setters

-- If name starts with upgr_, then it's a translation phrase.
function UPGRADE_CLASS:Name(name)
    self.name = name
end

-- Sets the upgrade imgur icon.
function UPGRADE_CLASS:Icon(icon)
    self.icon = icon
end

function UPGRADE_CLASS:Numeric()
    self.isNumeric = true
end

function UPGRADE_CLASS:OneInstance()
    self.onlyOneInstance = true
end

-- If any translation starts with upgr_desc_, it's a translation phrase
-- Sets the upgrade description.
function UPGRADE_CLASS:Description(description)
    self.description = description
end

-- Sets the upgrade value description. (when creating a new upgrade)
function UPGRADE_CLASS:ValueDescription(description)
    self.valueDescription = description
end


-- Function setters

-- This gets called on purchase and join.
function UPGRADE_CLASS:OnEquip(func)
    self.onEquip = func
end

function UPGRADE_CLASS:OnReset(func)
    self.onReset = func
end

function UPGRADE_CLASS:IsInstalledFunc(func)
    self.isInstalledFunc = func
end

-- This gets called on respawn.
function UPGRADE_CLASS:OnRespawn(func)
    self.onRespawn = func
end

function UPGRADE_CLASS:FormatValue(func)
    self.formatVal = func
end

function UPGRADE_CLASS:OnLoad(func)
    self.onLoadFunc = func
end

-- Utility functions

function UPGRADE_CLASS:PrintValue(val)
    return self.formatVal(val)
end

function UPGRADE_CLASS:PrintName()
    if (string.StartWith(self.name, "upgr_")) then
        return L(self.name)
    end

    return self.name
end

function UPGRADE_CLASS:PrintDescription()
    if (string.StartWith(self.description, "upgr_desc_")) then
        return L(self.description)
    end

    return self.description
end

function UPGRADE_CLASS:PrintValueDescription()
    if (string.StartWith(self.valueDescription, "upgr_descval_")) then
        return L(self.valueDescription)
    end

    return self.valueDescription
end

function UPGRADE_CLASS:Reset(ply, prev)
    self.onReset(ply, prev)
end

function UPGRADE_CLASS:IsInstalled()
    local isInstalled = self.isInstalledFunc and self.isInstalledFunc()
    if (!self.isInstalledFunc) then
        isInstalled = true
    end
    return isInstalled
end

local function equipUpgrade(upgrade, ply, value)
    if (!IsValid(ply)) then return end
    if (upgrade.onlyOneInstance) then
        local faction = ply:GetVFFaction()
        local pts = faction:GetUpgradePointsByName("upgr_weapon")
        local point = nil
        for k, v in ipairs(pts) do
            if (!point) then
                point = v
            end

            if (v.posY > point.posY) then
                point = v
            end

            if (v.posY == point.posY and v.posX > point.posX) then
                point = v
            end
        end

        if (!point) then return end
        if (point.upgrade.value != value) then return end
    end

    upgrade.onEquip(ply, value)
end

local function equipSpawnUpgrade(upgrade, ply, value)
    if (!IsValid(ply)) then return end
    if (upgrade.onlyOneInstance) then
        local faction = ply:GetVFFaction()
        local pts = faction:GetUpgradePointsByName("upgr_weapon")
        local point = nil
        for k, v in ipairs(pts) do
            if (!point) then
                point = v
            end

            if (v.posY > point.posY) then
                point = v
            end

            if (v.posY == point.posY and v.posX > point.posX) then
                point = v
            end
        end

        if (!point) then return end
        if (point.upgrade.value != value) then return end
    end

    upgrade.onRespawn(ply, value)
end

function UPGRADE_CLASS:Load(val, id)
    if (!self.onLoadFunc) then return end
    self.onLoadFunc(val, id)
end

function UPGRADE_CLASS:Equip(receiver, value)
    if (!self.onEquip) then return end

    if (receiver.id) then
        -- Faction
        for k, member in ipairs(receiver.members) do
            if (IsValid(member.ply)) then
                equipUpgrade(self, member.ply, value)
            end
        end
    else
        -- Member
        equipUpgrade(self, receiver.ply, value)
    end
end

function UPGRADE_CLASS:Respawn(receiver, value)
    if (!self.onRespawn) then return end

    if (receiver.id) then
        -- Faction
        for k, member in ipairs(receiver.members) do
            if (IsValid(member.ply)) then
                equipSpawnUpgrade(self, member.ply, value)
            end
        end
    else
        -- Member
        equipSpawnUpgrade(self, receiver.ply, value)
    end
end


-- Static functions

function VoidFactions.Upgrades:NewUpgrade()
	return UPGRADE_CLASS:New()
end

function VoidFactions.Upgrades:AddUpgrade(upgrade)
    if (!istable(upgrade)) then return end

    if (!upgrade.name) then
        VoidFactions.PrintError("An upgrade module does not have a name! Stack trace:")
        print(debug.traceback())
        return
    end

    if (!upgrade.onReset and upgrade.onlyOneInstance) then
        VoidFactions.PrintError("Upgrade module " .. upgrade.name .. " doesn't have a OnReset handler, and only one instance is allowed!")
        return
    end

    VoidFactions.Upgrades.Modules[upgrade.name] = upgrade
    VoidFactions.PrintDebug("Registered upgrade module " .. upgrade.name .. "!")
end

-- Other

hook.Add("VoidFactions.Upgrade.UpgradesReceived", "VoidFactions.Upgrades.OnReceived", function ()
    if (SERVER) then return end

    for k, point in pairs(VoidFactions.UpgradePoints.List) do
        point.upgrade.module:Load(point.upgrade.value, point.id)
    end

    hook.Remove("VoidFactions.Upgrade.UpgradesReceived", "VoidFactions.Upgrades.OnReceived")
end)
