/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

if not CLIENT then return end
zmlab2 = zmlab2 or {}
zmlab2.Crate = zmlab2.Crate or {}

function zmlab2.Crate.Initialize(Crate)
    timer.Simple(0.1,function()
        if not IsValid(Crate) then return end
        Crate.Initialized = true
    end)
end

function zmlab2.Crate.Draw(Crate)

    if Crate.Initialized and zclib.util.InDistance(Crate:GetPos(), LocalPlayer():GetPos(), 500) then

        if zclib.Convar.Get("zmlab2_cl_drawui") == 1 then zmlab2.Meth.DrawHUD(Crate:GetPos() + Vector(0,0,25),0.1,Crate:GetMethType(),Crate:GetMethAmount(),Crate:GetMethQuality()) end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

        if Crate:GetMethAmount() ~= Crate.CurMethAmount then
            Crate.CurMethAmount = Crate:GetMethAmount()
            zmlab2.Crate.UpdateMethMaterial(Crate)
        end

        // Update the material once it gets drawn
        if Crate.LastDraw and CurTime() > (Crate.LastDraw + 0.1) then
            zmlab2.Crate.UpdateMethMaterial(Crate)
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae

        Crate.LastDraw = CurTime()
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 99958388d5b8bc21e4d7af1df39fd75077f0660617b3c526ce40ea9691a5fd3b

function zmlab2.Crate.UpdateMethMaterial(Crate)
    //zclib.Debug("zmlab2.Crate.UpdateMethMaterial")

    if Crate:GetMethAmount() <= 0 then return end
    if Crate:GetMethType() <= 0 then return end
    local MethMat = zmlab2.Meth.GetMaterial(Crate:GetMethType(),Crate:GetMethQuality())
    Crate:SetSubMaterial(0, "!" .. MethMat)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b
