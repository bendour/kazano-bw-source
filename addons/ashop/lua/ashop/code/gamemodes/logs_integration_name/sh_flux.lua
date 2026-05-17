hook.Add("Flux_LoadedGamemode", "AShop_Name_Flux", function()
    hook.Add("Flux:ChangeName", "AShop_Name_Flux", function(ply, n)
        ashop.Logs.RefreshName(ply, n)
    end)

    hook.Remove("Flux_LoadedGamemode", "AShop_Name_Flux")
    hook.Remove("player_changename", "ashop_Name")
end)