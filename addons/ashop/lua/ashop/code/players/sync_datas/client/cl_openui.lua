net.Receive('ashop_readMissingItemsUI', function()
    while(net.ReadBool()) do
        local itemData = ashop.Network.R_ItemData()
        ashop.items[itemData.id] = itemData
    end
end)

net.Receive('ashop_openUI', function()
    local plyItems = LocalPlayer().ashop_data.items

    while(net.ReadBool()) do
        local itemData = ashop.Network.R_PlyItem()
        plyItems[itemData.id] = itemData
    end

    ashop.menu = vgui.Create("AShop_Main")
end)

hook.Add( "PlayerButtonUp", "ashop_openMenu", function( ply, button )
    if ashop.Config.OpenTauntMenuKey and button == ashop.Config.OpenTauntMenuKey and IsFirstTimePredicted() then
        RunConsoleCommand('ashop_opentauntmenu')
    end
end)