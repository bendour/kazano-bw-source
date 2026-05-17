/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

if not CLIENT then return end
zmlab2 = zmlab2 or {}
zmlab2.Equipment = zmlab2.Equipment or {}

net.Receive("zmlab2_Equipment_OpenInterface", function(len)
    zclib.Debug_Net("zmlab2_Equipment_OpenInterface",len)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae

    LocalPlayer().zmlab2_Equipment = net.ReadEntity()

    // If we currently removing / placing something then stop
    zclib.PointerSystem.Stop()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2

    zmlab2.Equipment.OpenInterface()
end)

function zmlab2.Equipment.OpenInterface()
    zmlab2.Interface.Create(600,365,zmlab2.language["Equipment"],function(pnl)
        function pnl:Think()
            if input.IsMouseDown(MOUSE_RIGHT) == true then
                LocalPlayer().zmlab2_Equipment = nil
                pnl:Close()
            end
        end

        zmlab2.Interface.AddModelList(pnl,zmlab2.config.Equipment.List,function(id)
            // IsLocked
            return false
        end,
        function(id)
            // IsSelected
            return false
        end,
        function(id)
            // OnClick
            zmlab2.Equipment.Place(LocalPlayer().zmlab2_Equipment,id)
            pnl:Close()
        end,
        function(raw_data)
            return {model = raw_data.model,render = {FOV = 35}} , raw_data.name , zclib.Money.Display(raw_data.price)
        end)
    end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2
