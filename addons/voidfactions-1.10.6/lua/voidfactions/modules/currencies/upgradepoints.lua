local CURRENCY = VoidFactions.Currencies:NewCurrency() -- Create a new currency object
CURRENCY:Name("Upgrade Points") -- Set the currency name
CURRENCY:SetInternal(true)

-- The functions that checks if the dependent addon/gamemode is installed
-- This is not required. The currency will not be selectable if this function returns false or nil
CURRENCY:IsInstalledFunc(function ()
    return VoidFactions.Settings:IsDynamicFactions()
end)

-- The function that will return the amount of player's money
CURRENCY:GetMoneyFunc(function (ply)
    local member = ply:GetVFMember()
    local faction = member.faction

    return faction and faction:GetUpgradePoints() or 0
end)

-- The function that will give money to the player
CURRENCY:GiveMoneyFunc(function (ply, money)
    -- Do nothing - it's only an internal currency
end)

-- The function that will format the money
-- If not supplied, then a $ will be prepended
CURRENCY:FormatMoneyFunc(function (money)
    return money .. "x Points"
end)

-- Register the currency (this is required!)
VoidFactions.Currencies:AddCurrency(CURRENCY)