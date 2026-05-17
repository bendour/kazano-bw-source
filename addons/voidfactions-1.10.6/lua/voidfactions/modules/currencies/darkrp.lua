local CURRENCY = VoidFactions.Currencies:NewCurrency() -- Create a new currency object
CURRENCY:Name("DarkRP") -- Set the currency name

-- The functions that checks if the dependent addon/gamemode is installed
-- This is not required. The currency will not be selectable if this function returns false or nil
CURRENCY:IsInstalledFunc(function ()
    return DarkRP
end)

-- The function that will return the amount of player's money
CURRENCY:GetMoneyFunc(function (ply)
    return ply:getDarkRPVar("money")
end)

-- The function that will give money to the player
CURRENCY:GiveMoneyFunc(function (ply, money)
    ply:addMoney(money)
end)

-- The function that will take money from the player
-- (NOT NEEDED IF GiveMoneyFunc can remove money)
-- CURRENCY:TakeMoneyFunc(function (ply)
    -- function for taking the money
-- end)

-- The function that will format the money
-- If not supplied, then a $ will be prepended
CURRENCY:FormatMoneyFunc(function (money)
    return DarkRP.formatMoney(money)
end)

-- Register the currency (this is required!)
VoidFactions.Currencies:AddCurrency(CURRENCY)