if CLIENT then return end
zrush = zrush or {}
zrush.Damage = zrush.Damage or {}

function zrush.Damage.Take(ent, dmginfo)
    local class = ent:GetClass()
    if class == "zrush_burner" or class == "zrush_drilltower" or class == "zrush_pump" or class == "zrush_refinery" then
        if class == "zrush_pump" then
            local sBarrel = ent:GetBarrel()
            if IsValid(sBarrel) then
                zrush.Pump.DetachBarrel(ent)
            end
        end

        if class == "zrush_refinery" then
            zrush.Refinery.DetachBarrel(ent,1, ent:GetInputBarrel())
            zrush.Refinery.DetachBarrel(ent,2, ent:GetOutputBarrel())
        else
            local hole = ent:GetHole()
            if IsValid(hole) and IsValid(hole.OilSpot) then
                zrush.OilSpot.Remove(hole.OilSpot)
            end
        end
    end

    if class == "zrush_palette" then
        local vPoint = ent:GetPos()
        local effectdata = EffectData()
        effectdata:SetStart(vPoint)
        effectdata:SetOrigin(vPoint)
        effectdata:SetScale(1)
        util.Effect("WheelDust", effectdata)
        SafeRemoveEntity(ent)
    else
        zrush.Damage.EntityExplosion(ent, class, true)
    end
end

// This creates a explosion for a entity
function zrush.Damage.EntityExplosion(ent, EntityID, DoesDamage)

    if EntityID ~= "zrush_barrel" then
        // Close the interface for any player who has it open
        zrush.Machine.CloseUI(ent)
    end

    ent.IsDeconstructing = true

    zclib.Timer.Remove("zrush_working_" .. ent:EntIndex())
    zclib.Timer.Remove("zrush_explosiontimer_" .. ent:EntIndex())

    if (DoesDamage) then
        for k, v in pairs(zclib.Player.List) do
            if (IsValid(v) and v:IsPlayer() and v:Alive() and zclib.util.InDistance(v:GetPos(), ent:GetPos(), 200)) and zrush.config.Machine[EntityID] and zrush.config.Machine[EntityID].OverHeat_Damage then
                v:TakeDamage(zrush.config.Machine[EntityID].OverHeat_Damage or 10, ent, ent)
            end
        end
    end

    local effectdata = EffectData()
    effectdata:SetStart(ent:GetPos())
    effectdata:SetOrigin(ent:GetPos())
    effectdata:SetScale((1 / 200) * 200)
    util.Effect("Explosion", effectdata)

    SafeRemoveEntityDelayed(ent,0.1)
end
