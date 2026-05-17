if (not SERVER) then return end
zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

function zmlab.f.Methbaggy_Initialize(Methbaggy)
    zmlab.f.Debug("zmlab.f.Methbaggy_Initialize")
    zmlab.f.EntList_Add(Methbaggy)
    Methbaggy.Enabled = false

    timer.Simple(2, function()
        if IsValid(Methbaggy) then
            Methbaggy.Enabled = true
        end
    end)
end

function zmlab.f.Methbaggy_USE(Methbaggy, ply)
    zmlab.f.Debug("zmlab.f.Methbaggy_USE")
    if not IsValid(Methbaggy) then return end
    if not zmlab.config.Meth.Consumable then return end

    --Increase Meth Screeneffect
    zmlab.f.CreateScreenEffectTable(ply)

    --Play random tuco sounds
    ply:StopSound("sfx_meth_consum")

    ply:EmitSound("sfx_meth_consum")
    local newHealth = ply:Health() - zmlab.config.Meth.Damage

    if (newHealth <= 0) then
        ply:Kill()
    else
        ply:SetHealth(newHealth)
    end


    local playertimer = "zmlab_PlayerOnMethTimer" .. ply:SteamID64()

    if (timer.Exists(playertimer)) then
        timer.Remove(playertimer)
    end

    timer.Create(playertimer, zmlab.config.Meth.EffectDuration, 1, function()
        if (IsValid(ply)) then
            ply.zmlab_OnMeth = false
        end
    end)

    ply.zmlab_OnMeth = true
    Methbaggy:Remove()
end

hook.Add( "Move", "a_zmlab_Move_PlayerOnMeth", function( ply, mv, usrcmd )
    if ply.zmlab_OnMeth then
        local speed = mv:GetMaxSpeed() * zmlab.config.Meth.SpeedMul
        mv:SetMaxSpeed( speed )
        mv:SetMaxClientSpeed( speed )
    end

end )
