local UPGRADE = VoidFactions.Upgrades:NewUpgrade()

UPGRADE:Name("upgr_weapon")
UPGRADE:Icon("1LZX6Q6")

UPGRADE:OneInstance()

UPGRADE:Description("upgr_desc_weapon")
UPGRADE:ValueDescription("upgr_descval_weapon")

UPGRADE:FormatValue(function (val)
    local weapon = weapons.Get(val)
    return weapon.PrintName
end)

UPGRADE:OnLoad(function (val, id)
    hook.Add("canDropWeapon", "VoidFactions.Weapon.CanDropWeapon" .. id, function (ply, wep)
        local member = ply:GetVFMember()
        if (!member) then return end
        local faction = member.faction
        if (!faction) then return end
        
        if (faction:HasUpgrade("upgr_weapon")) then
            val = faction:GetUpgradeValue(id)

            if (wep:GetClass() == val) then return false end
        end
    end)
end)

UPGRADE:OnReset(function (ply, prevVal)
    if (!SERVER) then return end

    ply:StripWeapon(prevVal)
end)

UPGRADE:OnRespawn(function (ply, val)
    if (!SERVER) then return end

    ply:Give(val)
end)

VoidFactions.Upgrades:AddUpgrade(UPGRADE)