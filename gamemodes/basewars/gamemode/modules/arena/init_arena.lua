if CLIENT then
    hook.Add("BaseWars:Initialize", "BaseWars:Module/arena", function()
        BaseWars:AddBaseWarsMenuTab("Duel", "basewars_materials/f3/arenaa.png", "BaseWars.F3Menu.Duel", 10)
    end)
end