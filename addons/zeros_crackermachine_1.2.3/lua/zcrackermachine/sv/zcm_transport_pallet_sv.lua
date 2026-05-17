if CLIENT then return end
zcm = zcm or {}
zcm.f = zcm.f or {}

function zcm.f.Palette_Initialize(Palette)
    zcm.f.Debug("zcm.f.Palette_Initialize")
    zcm.f.EntList_Add(Palette)
end

function zcm.f.Palette_StartTouch(Palette, other)
    if not IsValid(Palette) then return end
    if not IsValid(other) then return end
    if other:GetClass() ~= "zcm_firecracker" then return end
    if zcm.f.CollisionCooldown(other) then return end
    zcm.f.Debug("zcm.f.Palette_StartTouch")
    zcm.f.Palette_AddCrate(Palette, other)
end

function zcm.f.Palette_AddCrate(Palette, firework)
    if Palette:GetFireworkCount() < zcm.config.Pallet.Count then
        Palette:SetFireworkCount(Palette:GetFireworkCount() + 1)
        SafeRemoveEntity(firework)
    end
end

function zcm.f.Palette_OnDamage(Palette, dmg)
    if zcm.f.Entity_OnTakeDamage(Palette, dmg, "WheelDust") then
        if Palette:GetFireworkCount() > 0 then
            zcm.f.CreateNetEffect("crackerpack_explosion", Palette:GetPos())
            zcm.f.CreateNetEffect("zcm_blackpowder_explode", Palette:GetPos())
        end

        SafeRemoveEntity(Palette)
    end
end
