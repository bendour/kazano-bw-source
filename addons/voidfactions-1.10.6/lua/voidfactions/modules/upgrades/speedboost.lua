local UPGRADE = VoidFactions.Upgrades:NewUpgrade()

UPGRADE:Name("upgr_speedboost")
UPGRADE:Icon("Kphnmej")

UPGRADE:Numeric()

UPGRADE:Description("upgr_desc_speedboost")
UPGRADE:ValueDescription("upgr_descval_speedboost")

UPGRADE:FormatValue(function (val)
    return "+" .. val .. "%"
end)

UPGRADE:OnReset(function (ply)
    if (!SERVER) then return end

    ply:SetRunSpeed(ply.origWalkSpeed)
    ply:SetWalkSpeed(ply.origRunSpeed)
    ply:SetMaxSpeed(ply.origRunSpeed)
end)

UPGRADE:OnRespawn(function (ply, val)
    if (!SERVER) then return end

    timer.Simple(1, function ()
        if (!IsValid(ply)) then return end
        
        ply.origWalkSpeed = ply:GetWalkSpeed()
        ply.origRunSpeed = ply:GetRunSpeed()

        local percentage = val / 100
        local multiplier = percentage + 1

        ply:SetRunSpeed(ply:GetRunSpeed() * multiplier)
        ply:SetWalkSpeed(ply:GetWalkSpeed() * multiplier)
        ply:SetMaxSpeed(ply:GetRunSpeed() * multiplier)
    end)
end)

VoidFactions.Upgrades:AddUpgrade(UPGRADE)