local CURRENCY = VoidFactions.Currencies:NewCurrency() -- Create a new currency object
CURRENCY:Name("Helix") -- Set the currency name

-- The functions that checks if the dependent addon/gamemode is installed
-- This is not required. The currency will not be selectable if this function returns false or nil
CURRENCY:IsInstalledFunc(function ()
    return ix
end)

-- The function that will return the amount of player's money
CURRENCY:GetMoneyFunc(function (ply)
    return ply:GetCharacter():GetMoney()
end)

-- The function that will give money to the player
CURRENCY:GiveMoneyFunc(function (ply, money)
    local char = ply:GetCharacter()
    local currentMoney = char:GetMoney()
    char:SetMoney(currentMoney + money)
end)

-- The function that will take money from the player
-- (NOT NEEDED IF GiveMoneyFunc can remove money)
-- CURRENCY:TakeMoneyFunc(function (ply)
    -- function for taking the money
-- end)

-- The function that will format the money
-- If not supplied, then a $ will be prepended
CURRENCY:FormatMoneyFunc(function (money)
    return ix.currency.Get(money)
end)

-- Register the currency (this is required!)
VoidFactions.Currencies:AddCurrency(CURRENCY)