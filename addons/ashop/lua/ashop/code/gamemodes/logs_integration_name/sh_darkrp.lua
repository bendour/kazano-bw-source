hook.Add("DarkRPFinishedLoading", "AShop_Name_DRP", function()
    hook.Add("onPlayerChangedName", "AShop_Name_DRP", function(ply, oldName, newName)
        ashop.Logs.RefreshName(ply, newName)
    end)

    hook.Remove("DarkRPFinishedLoading", "AShop_Name_DRP")
    hook.Remove("player_changename", "ashop_Name")
end)