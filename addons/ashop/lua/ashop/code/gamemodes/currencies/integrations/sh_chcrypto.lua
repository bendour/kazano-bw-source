hook.Add("InitPostEntity", "AShop_Crypto", function()
    if CH_CryptoCurrencies then
        for index, crypto in ipairs( CH_CryptoCurrencies.Config.Currencies ) do
            ashop.currencies.RegisterCurrency("Crypto - " .. crypto.Name, function(ply, amt)
                CH_CryptoCurrencies.GiveCrypto( ply, crypto.Currency, amt )
            end, function(ply)
                return ply.CH_CryptoCurrencies_Wallet[ index ]
            end, function(amt)
                return string.format( "%f", amt ) .. " ".. crypto.Currency
            end)
        end
    end
end)
