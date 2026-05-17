/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

if not CLIENT then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

net.Receive("zmlab2_Mixer_OpenInterface", function(len)
    zclib.Debug_Net("zmlab2_Mixer_OpenInterface", len)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    LocalPlayer().zmlab2_Mixer = net.ReadEntity()

    zmlab2.Interface.Create(600,365,zmlab2.language["SelectMethType"],function(pnl)

        zmlab2.Interface.AddModelList(pnl,zmlab2.config.MethTypes,function(id)
            // IsLocked
            return zmlab2.Mixer.MethTypeCheck(LocalPlayer(),id) == false
        end,
        function(id)
            // IsSelected
            return IsValid(LocalPlayer().zmlab2_Mixer) and LocalPlayer().zmlab2_Mixer:GetMethType() == id
        end,
        function(id)
            // OnClick
            net.Start("zmlab2_Mixer_SetMethType")
            net.WriteEntity(LocalPlayer().zmlab2_Mixer)
            net.WriteUInt(id, 16)
            net.SendToServer()
        end,
        function(raw_data)
            return {model = raw_data.crystal_mdl,render = {FOV = 35},color = raw_data.color} , raw_data.name , zclib.Money.Display(raw_data.price * ( zmlab2.config.NPC.SellRanks[zclib.Player.GetRank(LocalPlayer())] or zmlab2.config.NPC.SellRanks["default"]))
        end)
    end)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3b23fe5de9dfb761758a006a7271ce1817b0b3d31fddc5f22fc8264734156bf
