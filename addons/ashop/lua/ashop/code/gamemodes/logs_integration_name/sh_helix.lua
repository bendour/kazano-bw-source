hook.Add("PostGamemodeLoaded", "AShop_Name_Helix", function()
    if ix then
        hook.Add("CharacterVarChanged", "AShop_Name_Helix", function(char, key, _, val)
            if ix and key == "Name" then
                ashop.Logs.RefreshName(char:GetPlayer(), val)
            end
        end)

        hook.Remove("PostGamemodeLoaded", "AShop_Name_Helix")
        hook.Remove("player_changename", "ashop_Name")
    end
end)