if (not SERVER) then return end
zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

function zmlab.f.Palette_Initialize(Palette)
    zmlab.f.Debug("zmlab.f.Palette_Initialize")
    zmlab.f.EntList_Add(Palette)
end

function zmlab.f.Palette_StartTouch(Palette, other)
    if not IsValid(Palette) then return end
    if not IsValid(other) then return end
    if other:GetClass() ~= "zmlab_collectcrate" then return end
    if zmlab.f.CollisionCooldown(other) then return end
    zmlab.f.Debug("zmlab.f.Palette_StartTouch")

    zmlab.f.Palette_AddCrate(Palette, other)
end

function zmlab.f.Palette_AddCrate(Palette, crate)
    if (crate:GetMethAmount() >= zmlab.config.TransportCrate.Capacity and Palette:GetCrateCount() < zmlab.config.Palette.Limit) then
        Palette:SetCrateCount(Palette:GetCrateCount() + 1)
        Palette:SetMethAmount(Palette:GetMethAmount() + crate:GetMethAmount())

        SafeRemoveEntity(crate)
    end
end
