local CURRENCY = {}
CURRENCY.Name = "Money"

function CURRENCY:Add(ply, amt)
	ply:addMoney(amt)
end
function CURRENCY:CanAfford(ply, amt)
	return ply:canAfford(amt)
end
function CURRENCY:Format(amt)
	return DarkRP.formatMoney(amt)
end

Coinflip:CreateCurrency("DarkRP", CURRENCY)