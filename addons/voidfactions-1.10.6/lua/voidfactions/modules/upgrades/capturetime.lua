local UPGRADE = VoidFactions.Upgrades:NewUpgrade()

UPGRADE:Name("upgr_capturetime")
UPGRADE:Icon("VnRF6PL")

UPGRADE:Description("upgr_desc_capturetime")
UPGRADE:ValueDescription("upgr_descval_capturetime")

UPGRADE:FormatValue(function (val)
    return "-" .. val .. "s"
end)

VoidFactions.Upgrades:AddUpgrade(UPGRADE)