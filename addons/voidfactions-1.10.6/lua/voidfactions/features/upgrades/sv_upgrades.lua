VoidFactions.Upgrades = VoidFactions.Upgrades or {}

-- Hooks
hook.Add("VoidFactions.SQL.MemberLoaded", "VoidFactions.Upgrades.InititalUpgradeEquip", function (ply)
    local member = ply:GetVFMember()
    if (!member) then return end
    if (!member.faction) then return end
    if (VoidFactions.Settings:IsStaticFactions() and !VoidFactions.Config.UpgradesEnabled) then return end

    local upgrades = {}
    for id, _ in pairs(member.faction.upgrades or {}) do
        local point = VoidFactions.UpgradePoints.List[id]
        if (!point) then continue end
        if (!point.upgrade) then return end

        upgrades[#upgrades + 1] = point.upgrade
    end

    for k, upgrade in SortedPairsByMemberValue(upgrades, "value", true) do
        upgrade.module:Equip(member, upgrade.value)
    end
end)


hook.Add("VoidFactions.Upgrades.Loaded", "VoidFactions.Upgrades.OnLoad", function ()
    for k, point in pairs(VoidFactions.UpgradePoints.List) do
        point.upgrade.module:Load(point.upgrade.value, point.id)
    end
end)

if (VoidFactions.SQL.UpgradesLoaded) then
    for k, point in pairs(VoidFactions.UpgradePoints.List) do
        point.upgrade.module:Load(point.upgrade.value, point.id)
    end
end

local function applyRespawnUpgrades(ply)
    local member = ply:GetVFMember()
    if (!member) then return end
    if (!member.faction) then return end
    if (VoidFactions.Settings:IsStaticFactions() and !VoidFactions.Config.UpgradesEnabled) then return end

    local upgrades = {}
    for id, _ in pairs(member.faction.upgrades) do
        local point = VoidFactions.UpgradePoints.List[id]
        if (!point) then continue end
        if (!point.upgrade) then return end

        upgrades[#upgrades + 1] = point.upgrade
    end

    ply.vfEquippedSpawnUpgrades = {}
    member.ply = ply
    for k, upgrade in SortedPairsByMemberValue(upgrades, "value", true) do
        upgrade.module:Respawn(member, upgrade.value)
    end
    
    ply.bUpgradesApplied = true
end

hook.Add("VoidChar.CharacterSelected", "VoidFactions.Upgrades.VoidCharSupport", function (ply)
    applyRespawnUpgrades(ply)
end)

hook.Add("VoidChar.CharacterCreated", "VoidFactions.Upgrades.VoidCharSupport", function (ply)
    applyRespawnUpgrades(ply)
end)

hook.Add("PlayerSpawn", "VoidFactions.Upgrades.PlayerSpawn", function (ply)
    timer.Simple(1, function ()
        if (!IsValid(ply)) then return end
        applyRespawnUpgrades(ply)
    end)
end)

hook.Add("PlayerInitialSpawn", "VoidFactions.Upgrades.PlayerInitialSpawn", function (ply)
    timer.Simple(6, function ()
        if (!IsValid(ply)) then return end
        if (ply.bUpgradesApplied) then return end
        applyRespawnUpgrades(ply)
    end)
end)
