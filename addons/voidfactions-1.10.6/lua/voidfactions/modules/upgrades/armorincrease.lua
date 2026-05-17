local UPGRADE = VoidFactions.Upgrades:NewUpgrade()

UPGRADE:Name("upgr_morearmor")
UPGRADE:Icon("ihR4cHk")

UPGRADE:Description("upgr_desc_morearmor")
UPGRADE:ValueDescription("upgr_descval_morearmor")

UPGRADE:FormatValue(function (val)
    return "+" .. val
end)

UPGRADE:OnReset(function (ply)
    if (!SERVER) then return end
end)

UPGRADE:OnRespawn(function (ply, val)
    if (!SERVER) then return end

    timer.Simple(1, function ()
        ply:SetArmor(ply:Armor() + val)
    end)
end)

VoidFactions.Upgrades:AddUpgrade(UPGRADE)