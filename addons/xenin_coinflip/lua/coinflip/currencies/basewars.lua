local CURRENCY = {}
CURRENCY.Name = "Credits"

function CURRENCY:Add(ply, amt)
	ply:AddCredit(amt)
end
function CURRENCY:CanAfford(ply, amt)
    if (ply:GetCredit() < amt) then
        return false
    end
	return true
end
function CURRENCY:Format(amt)
	return BaseWars:FormatCredit(amt, true)
end

Coinflip:CreateCurrency("Credits", CURRENCY)