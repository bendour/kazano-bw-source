local UPGRADE = VoidFactions.Upgrades:NewUpgrade()

UPGRADE:Name("upgr_jumpboost")
UPGRADE:Icon("iYg63Tc")

UPGRADE:Numeric()

UPGRADE:Description("upgr_desc_jumpboost")
UPGRADE:ValueDescription("upgr_descval_jumpboost")

UPGRADE:FormatValue(function (val)
    return "+" .. val .. "%"
end)

UPGRADE:OnReset(function (ply)
    if (!SERVER) then return end

    ply:SetJumpPower(ply.origJumpPower)
end)

UPGRADE:OnRespawn(function (ply, val)
    if (!SERVER) then return end

    timer.Simple(1, function ()
        ply.origJumpPower = ply:GetJumpPower()

        local percentage = val / 100
        local multiplier = percentage + 1

        ply:SetJumpPower(ply:GetJumpPower() * multiplier)
    end)
end)

VoidFactions.Upgrades:AddUpgrade(UPGRADE)