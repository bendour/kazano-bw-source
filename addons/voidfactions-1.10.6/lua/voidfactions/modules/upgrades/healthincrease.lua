local UPGRADE = VoidFactions.Upgrades:NewUpgrade()

UPGRADE:Name("upgr_morehp")
UPGRADE:Icon("4ZcMBl5")

UPGRADE:Description("upgr_desc_morehp")
UPGRADE:ValueDescription("upgr_descval_morehp")

UPGRADE:FormatValue(function (val)
    return "+" .. val .. "%"
end)

UPGRADE:OnReset(function (ply)
    if (!SERVER) then return end
end)

UPGRADE:OnRespawn(function (ply, val)
    if (!SERVER) then return end

    timer.Simple(1, function ()
        local percentage = val / 100
        ply:SetHealth(ply:Health() + ply:GetMaxHealth() * percentage)
    end)
end)

VoidFactions.Upgrades:AddUpgrade(UPGRADE)
