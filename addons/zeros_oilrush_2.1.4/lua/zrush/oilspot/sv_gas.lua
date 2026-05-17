if not SERVER then return end

local function ButanGas_DamagePlayers()

    for k, v in pairs(zrush.DrillHole.List) do

        local dmgInfo = DamageInfo()
        dmgInfo:SetDamage( zrush.config.Machine["DrillHole"].ButanGas_Damage )
        dmgInfo:SetAttacker( v )
        dmgInfo:SetDamageType( DMG_NERVEGAS )

        if (IsValid(v) and v:GetState() == ZRUSH_STATE_NEEDBURNER and v:GetGas() > 0) then

            for s, w in pairs(zclib.Player.List) do
                if (IsValid(w) and w:IsPlayer() and w:Alive() and zclib.util.InDistance(w:GetPos(),v:GetPos(),zrush.config.Machine["DrillHole"].ButanGas_DamageRadius)) then
                    w:TakeDamageInfo( dmgInfo )
                end
            end
        end
    end
end

timer.Simple(1,function()
    local timerid = "zrush_butangas_damagetimer_id"
    zclib.Timer.Remove(timerid)
    zclib.Timer.Create(timerid, zrush.config.Machine["DrillHole"].ButanGas_Speed, 0, ButanGas_DamagePlayers)
end)
