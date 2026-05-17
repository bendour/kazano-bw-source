if CLIENT then
    hook.Add("BaseWars:Initialize", "BaseWars:F3Menu", function()
        BaseWars:AddBaseWarsMenuTab("#bwm_dashboard", "basewars_materials/f3/dashboard.png", "BaseWars.F3Menu.Dashboard", 1)
        BaseWars:AddBaseWarsMenuTab("#bwm_leaderboard", "basewars_materials/f3/leaderboard.png", "BaseWars.F3Menu.Leaderboard", 2)
        BaseWars:AddBaseWarsMenuTab("#bwm_sellmenu", "basewars_materials/f3/sell.png", "BaseWars.F3Menu.SellMenu", 5)
        BaseWars:AddBaseWarsMenuTab("#bwm_notificationsHistory", "basewars_materials/f3/notif_history.png", "BaseWars.F3Menu.NotificationsHistory", 15)
        -- BaseWars:AddBaseWarsMenuTab("Cookie Clicker", "basewars_materials/f3/cookie.png", "BaseWars.F3Menu.CookieClicker", 50)
        BaseWars:AddBaseWarsMenuTab("Calculator", "basewars_materials/f4/printer.png", "BaseWars.F3Menu.Calculator", 25)
        BaseWars:AddBaseWarsMenuTab("#bwm_config", "basewars_materials/f3/settings.png", "BaseWars.F3Menu.Config", 9999)
    end)
end