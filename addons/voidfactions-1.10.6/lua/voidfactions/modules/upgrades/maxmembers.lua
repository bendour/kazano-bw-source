local UPGRADE = VoidFactions.Upgrades:NewUpgrade()

UPGRADE:Name("upgr_maxmembers")
UPGRADE:Icon("rDFcEq6")

UPGRADE:Description("upgr_desc_maxmembers")
UPGRADE:ValueDescription("upgr_descval_maxmembers")

UPGRADE:FormatValue(function (val)
    return "+ " .. val
end)

VoidFactions.Upgrades:AddUpgrade(UPGRADE)