Coinflip.Currencies = Coinflip.Currencies or {}

function Coinflip:CreateCurrency(id, tbl)
	self.Currencies[id] = tbl
end

function Coinflip:GetCurrency(input)
	if (input == nil) then 
		if (istable(Coinflip.Config.Currency)) then
			input = Coinflip.Config.Currency[1]
		else
			input = Coinflip.Config.Currency 
		end
	end
	
	return self.Currencies[input]
end

function Coinflip:GetCurrencies()
	if (isstring(Coinflip.Config.Currency)) then
		return { Coinflip.Config.Currency }
	end

	return Coinflip.Config.Currency
end

function Coinflip:GetCurrencyIfNil()
	if (Coinflip.Config.OldCurrency) then
		return Coinflip.Config.OldCurrency
	end
	if (istable(Coinflip.Config.Currency)) then
		return Coinflip.Config.Currency[1]
	end

	return Coinflip.Config.Currency
end