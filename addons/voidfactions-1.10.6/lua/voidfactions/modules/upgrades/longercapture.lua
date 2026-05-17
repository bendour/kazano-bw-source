local UPGRADE = VoidFactions.Upgrades:NewUpgrade()

UPGRADE:Name("upgr_longercapture")
UPGRADE:Icon("3T5idNh")

UPGRADE:Description("upgr_desc_longercapture")
UPGRADE:ValueDescription("upgr_descval_longercapture")

UPGRADE:FormatValue(function (val)
    return "+" .. val .. "s"
end)

VoidFactions.Upgrades:AddUpgrade(UPGRADE)