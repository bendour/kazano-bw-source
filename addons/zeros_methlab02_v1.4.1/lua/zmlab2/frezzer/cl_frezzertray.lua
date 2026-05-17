/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

if not CLIENT then return end
zmlab2 = zmlab2 or {}
zmlab2.FrezzerTray = zmlab2.FrezzerTray or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 99958388d5b8bc21e4d7af1df39fd75077f0660617b3c526ce40ea9691a5fd3b

/*
    ProcessState
    0 = Empty
    1 = Liquid
    2 = Frozen
*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae


function zmlab2.FrezzerTray.Initialize(FrezzerTray)
    // Fixes the tray follwing the frezzer attachments correctly
	//FrezzerTray:SetPredictable(true) BUG Causes the entity while being moved to look like its lagging
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b

function zmlab2.FrezzerTray.Draw(FrezzerTray)
    if zmlab2.config.Frezzer.Tray_DisplayState and zclib.util.InDistance(LocalPlayer():GetPos(),FrezzerTray:GetPos(), 1000) and zclib.Convar.Get("zmlab2_cl_drawui") == 1 then

        cam.Start3D2D(FrezzerTray:LocalToWorld(Vector(0, 0, 0.5)), FrezzerTray:LocalToWorldAngles(Angle(0, 180, 0)), 0.5)
            local state = FrezzerTray:GetProcessState()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 99958388d5b8bc21e4d7af1df39fd75077f0660617b3c526ce40ea9691a5fd3b
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

            if state == 1 then
                surface.SetDrawColor(color_white)
                surface.SetMaterial(zclib.Materials.Get("icon_box01"))
                surface.DrawTexturedRectRotated(0, 0, 20, 20, 0)

                surface.SetDrawColor(color_white)
                surface.SetMaterial(zclib.Materials.Get("icon_cold"))
                surface.DrawTexturedRectRotated(0, 0, 15, 15, 0)
            elseif state == 2 then
                surface.SetDrawColor(color_white)
                surface.SetMaterial(zclib.Materials.Get("icon_box01"))
                surface.DrawTexturedRectRotated(0, 0, 20, 20, 0)

                surface.SetDrawColor(color_white)
                surface.SetMaterial(zclib.Materials.Get("icon_breaking"))
                surface.DrawTexturedRectRotated(0, 0, 15, 15, 0)
            end
        cam.End3D2D()
    end
end
