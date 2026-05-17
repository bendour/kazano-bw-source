if SERVER then
    -- Send HTML files to client
    AddCSLuaFile("darkrp/gamemode/modules/admin_menu/html_loader.lua")
    AddCSLuaFile("darkrp/gamemode/modules/admin_menu/html/admin_menu.html.lua")
    AddCSLuaFile("darkrp/gamemode/modules/admin_menu/html/admin_menu.css.lua")
    AddCSLuaFile("darkrp/gamemode/modules/admin_menu/html/admin_menu.js.lua")
    AddCSLuaFile("darkrp/gamemode/modules/admin_menu/cl_admin_menu_html.lua")
end

if CLIENT then
    hook.Add("BaseWars:Initialize", "BaseWars:AdminMenu", function()
        BaseWars:AddAdminMenuTab("#bwm_faction", "basewars_materials/f3/faction.png", "BaseWars.AdminMenu.Factions", 1)
        BaseWars:AddAdminMenuTab("#bwm_raid", "basewars_materials/f3/raid.png", "BaseWars.AdminMenu.Raids", 2)
        BaseWars:AddAdminMenuTab("#adminmenu_playerLookup", "basewars_materials/user.png", "BaseWars.AdminMenu.PlayerLookUp", 3)
    end)
end