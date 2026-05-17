VoidCases.Print("Loaded VoidCases built-in currencies!")

-- BaseWars
if (BaseWars or Basewars or basewars) then
    VoidCases.Print("BaseWars Loaded !")
    VoidCases.AddCurrency("Basewars", function (ply)
        return ply:GetCredit()
    end, function (ply, money)
           		ply:AddCredit(money)
    end)
end
