/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

zmlab2 = zmlab2 or {}
zmlab2.Mixer = zmlab2.Mixer or {}

// Checks if the player is allowed to create this methtype
function zmlab2.Mixer.MethTypeCheck(ply,methtype)
    local MethData = zmlab2.config.MethTypes[methtype]
    if MethData == nil then return false end
    if MethData.rank and istable(MethData.rank) and table.Count(MethData.rank) > 0 and zclib.Player.RankCheck(ply,MethData.rank) == false then return false end
    if MethData.job and istable(MethData.job) and table.Count(MethData.job) > 0 and MethData.job[zclib.Player.GetJob(ply)] == nil then return false end
    if MethData.customcheck and MethData.customcheck(ply) == false then return false end

    return true
end

function zmlab2.Mixer.GetLiquidColor(Mixer)
    local col
    local state = Mixer:GetProcessState()
    local MethType = Mixer:GetMethType()
    /*
        < 2 = Yellow
        2 = Acid Yellow
        2 - 3 > Acid Yellow to meth color half way
        8 > 9 half color to final color
    */

    if state < 2 then
        col = zmlab2.colors["mixer_liquid01"]
    elseif state == 2 then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b

        col = zmlab2.colors["mixer_liquid02"]

    elseif state == 3 then

        local mix_start = Mixer:GetProcessStart()
        local time_fract = (1 / zmlab2.Meth.GetMixTime(MethType)) * (CurTime() - mix_start)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2

        local midColor = zclib.util.LerpColor(0.5, zmlab2.colors["mixer_liquid02"], zmlab2.Meth.GetColor(MethType))

        col = zclib.util.LerpColor(time_fract, zmlab2.colors["mixer_liquid02"], midColor)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2

    elseif state > 3 and state < 8 then

        col = zclib.util.LerpColor(0.5, zmlab2.colors["mixer_liquid02"], zmlab2.Meth.GetColor(MethType))
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2

    else
        local midColor = zclib.util.LerpColor(0.5, zmlab2.colors["mixer_liquid02"], zmlab2.Meth.GetColor(MethType))

        local vent_start = Mixer:GetProcessStart()
        local time_fract = (1 / zmlab2.Meth.GetVentTime(MethType)) * (CurTime() - vent_start)
        col = zclib.util.LerpColor(time_fract, midColor, zmlab2.Meth.GetColor(MethType))
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2

        local qual_fact = (1 / 100) * Mixer:GetMethQuality()
        local h, s, v = ColorToHSV(col)
        col = HSVToColor(h, s * qual_fact, v)

        local fract = (1 / 4) * (state - 3)
        col = zclib.util.LerpColor(fract, midColor, col)
    end

    return col
end
