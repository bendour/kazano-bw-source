local function afterPrepare(winTable)
    local wC = ashop.TTT_Credits_WinningTeam
    local lC = ashop.TTT_Credits_LosingTeam

    for k, v in ipairs(winTable) do
        local tC = v[2] and wC or lC

        if !tC then continue end

        if tC.normal and tC.normal > 0 then
            v[1]:ashopMoneyChange(tC.normal, false)
        end

        if tC.premium and tC.premium > 0 then
            v[1]:ashopMoneyChange(tC.normal, true)
        end
    end
end

hook.Add("DeathrunRoundWin", "ashop_givecoins", function(winningTeam)
    if !ashop.TTT_Credits_WinningTeam or
        !ashop.TTT_Credits_LosingTeam then return end

    for k, v in ipairs(player.GetHumans()) do
        if !v.ashop_data or !v.ashop_data.ready then continue end
        table.insert(winTable, {v, v:Team() == winningTeam})
    end

    afterPrepare(winTable)
end)