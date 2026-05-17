// I don't know if i'm dumb, but I didn't found any hooks post load
hook.Add("PostGamemodeLoaded", "AShop_GR_Helix", function()
    if ix then
        ashop.currencies.RegisterCurrency("Helix", function(ply, amt)
            local c = ply:GetCharacter()
            c:SetMoney(c:GetMoney() + amt)
        end, function(ply)
            return ply:GetCharacter():GetMoney()
        end, function(amt)
            return ix.currency.Get(amt)
        end)
    end
end)
