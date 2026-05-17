if CLIENT then
    hook.Add("BaseWars:Initialize", "BaseWars:Raid", function()
        BaseWars:AddBaseWarsMenuTab("#bwm_raid", "basewars_materials/f3/raid.png", "BaseWars.F3Menu.Raid", 4)
    end)
end