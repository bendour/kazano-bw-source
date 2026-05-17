BaseWars:AddTranslation("adverts_collection", "fr", "Nos addons: <link:https://kazano.fr/addons>")
BaseWars:AddTranslation("adverts_rules", "fr", "Règlement: <link:https://kazano.fr/regles>")
BaseWars:AddTranslation("adverts_discord", "fr", "Discord: <link:https://discord.gg/kazano>")
BaseWars:AddTranslation("adverts_boutique", "fr", "Boutique: <link:https://kazano.fr>")

BaseWars:AddTranslation("adverts_collection", "en", "Addons: <link:https://kazano.fr/addons>")
BaseWars:AddTranslation("adverts_rules", "en", "Server rules: <link:https://kazano.fr/rules>")
BaseWars:AddTranslation("adverts_discord", "en", "Discord: <link:https://discord.gg/kazano>")
BaseWars:AddTranslation("adverts_boutique", "en", "Shop: <link:https://kazano.fr>")

if SERVER then
    hook.Add("BaseWars:Initialize", "BaseWars:Adverts", function()
        BaseWars:AddAdvert(600, "#adverts_collection")
        BaseWars:AddAdvert(600, "#adverts_rules")
        BaseWars:AddAdvert(600, "#adverts_discord")
        BaseWars:AddAdvert(600, "#adverts_boutique")
    end)
end