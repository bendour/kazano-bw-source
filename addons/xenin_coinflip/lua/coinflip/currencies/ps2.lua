local CURRENCY = {}
CURRENCY.Name = "Points"

function CURRENCY:Add(ply, amt)
	ply:PS2_AddStandardPoints(amt)
end
function CURRENCY:CanAfford(ply, amt)
	return ply.PS2_Wallet.points >= amt
end
function CURRENCY:Format(amt)
	return string.Comma(amt) .. " points"
end

Coinflip:CreateCurrency("Pointshop 2", CURRENCY)