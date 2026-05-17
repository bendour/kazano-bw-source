hook.Add("PostGamemodeLoaded", "AShop_GR_Nut", function()
    if nut then
        ashop.currencies.RegisterCurrency("Nutscript", function(ply, amt)
            local c = ply:getChar()
            c:SetMoney(c:getMoney() + amt)
        end, function(ply)
            return ply:getChar():getMoney()
        end, function(amt)
            return nut.currency.get(amt)
        end)
    end
end)
