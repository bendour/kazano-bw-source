local UPGRADE = VoidFactions.Upgrades:NewUpgrade()

UPGRADE:Name("upgr_maxitems")
UPGRADE:Icon("2QtUrlI")

UPGRADE:Description("upgr_desc_maxitems")
UPGRADE:ValueDescription("upgr_descval_maxitems")

UPGRADE:FormatValue(function (val)
    return "+ " .. val
end)

VoidFactions.Upgrades:AddUpgrade(UPGRADE)