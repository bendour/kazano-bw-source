hook.Add("PostGamemodeLoaded", "AShop_Name_Nut", function()
    if nut then
        hook.Add("OnCharVarChanged", "AShop_Name_Nut", function(char, key, _, val)
            if nut and key == "Name" then
                ashop.Logs.RefreshName(char:getPlayer(), val)
            end
        end)

        hook.Remove("PostGamemodeLoaded", "AShop_Name_Nut")
        hook.Remove("player_changename", "ashop_Name")
    end
end)