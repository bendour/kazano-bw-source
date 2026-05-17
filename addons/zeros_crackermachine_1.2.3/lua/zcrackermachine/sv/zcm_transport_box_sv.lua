if CLIENT then return end
zcm = zcm or {}
zcm.f = zcm.f or {}

function zcm.f.TransportBox_Initialize(box)
    zcm.f.Debug("zcm.f.TransportBox_Initialize")
    zcm.f.EntList_Add(box)
end

function zcm.f.TransportBox_StartTouch(box, other)
    if not IsValid(box) then return end
    if not IsValid(other) then return end
    if other:GetClass() ~= "zcm_firecracker" then return end
    if zcm.f.CollisionCooldown(other) then return end
    if other.Ignited == true then return end
    if box:GetFireworkCount() >= 8 then return end

    local fireworkOwner = other:CPPIGetOwner()
    if box:CPPIGetOwner() != fireworkOwner then
        if IsValid(fireworkOwner) then
            BaseWars:Notify(fireworkOwner, "#notYours", NOTIFICATION_ERROR, 8)
        end

        return
    end

    zcm.f.Debug("zcm.f.TransportBox_StartTouch")
    zcm.f.TransportBox_AddCrate(box, other)
end

function zcm.f.TransportBox_AddCrate(box, other)
    box:SetFireworkCount(box:GetFireworkCount() + 1)
    SafeRemoveEntity(other)

    if box:GetFireworkCount() >= 8 then
        box:SetIsOpen(false)
    end
end

function zcm.f.TransportBox_Use(ply, box)
    if box:GetIsOpen() == false and box:OnSellButton(ply) then
        zcm.f.TransportBox_PickUp(ply, box)
    end
end

function zcm.f.TransportBox_PickUp(ply, box)
    if box:CPPIGetOwner() != ply then
        BaseWars:Notify(ply, "#notYours", NOTIFICATION_ERROR, 5)
        return
    end

    local fireworkCount = box:GetFireworkCount()
    ply:SetNWInt("zcm_firework", ply:GetNWInt("zcm_firework", 0) + fireworkCount)
    box:Remove()
    zcm.f.Notify(ply, "+" .. fireworkCount .. " " .. zcm.language.General["Firework"], 0)
end


function zcm.f.TransportBox_OnDamage(box, dmg)
    if zcm.f.Entity_OnTakeDamage(box, dmg, "WheelDust") then
        if box:GetFireworkCount() > 0 then
            zcm.f.CreateNetEffect("crackerpack_explosion", box:GetPos())
            zcm.f.CreateNetEffect("zcm_blackpowder_explode", box:GetPos())
        end

        SafeRemoveEntity(box)
    end
end
