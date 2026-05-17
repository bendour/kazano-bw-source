hook.Add("EndRound", "ashop_givecoins", function(result)
    if !ashop.ZC_Credits_AlivePlayers then return end

    local t = ashop.ZC_Credits_AlivePlayers

    for k, v in ipairs(player.GetHumans()) do
        if v:Team() == TEAM_SURVIVORS or v:Team() == TEAM_HUMAN then
            if t.normal and t.normal > 0 then
                v:ashopMoneyChange(t.normal, false)
            end

            if t.premium and t.premium > 0 then
                v:ashopMoneyChange(t.premium, true)
            end
        end
    end
end)