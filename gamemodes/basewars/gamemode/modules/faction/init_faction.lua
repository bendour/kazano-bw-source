if CLIENT then
    hook.Add("BaseWars:Initialize", "BaseWars:Factions", function()
        BaseWars:AddBaseWarsMenuTab("#bwm_faction", "basewars_materials/f3/faction.png", "BaseWars.F3Menu.Faction", 3)
    end)
end