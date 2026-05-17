local CURRENCY = {}
CURRENCY.Name = "Points"

function CURRENCY:Add(ply, amt)
	ply:PS_GivePoints(amt)
end
function CURRENCY:CanAfford(ply, amt)
	return ply:PS_HasPoints(amt)
end
function CURRENCY:Format(amt)
	return string.Comma(amt) .. " points"
end

Coinflip:CreateCurrency("Pointshop", CURRENCY)