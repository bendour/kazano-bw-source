-- FR
BaseWars:AddTranslation("bwm_permaWeapon", "fr", "Armes Perma")
BaseWars:AddTranslation("permanentWeapon_addedByAndDate", "fr", "Ajouté par %s le %s")
BaseWars:AddTranslation("permanentWeapons_invalidWeaponClass", "fr", "L'arme «%s» n'existe pas")
BaseWars:AddTranslation("permanentWeapons_playerAlreadyHasWeapon", "fr", "%s a déjâ l'arme «%s»")
BaseWars:AddTranslation("permanentWeapons_playerDontHaveWeapon", "fr", "%s n'a pas l'arme «%s»")
BaseWars:AddTranslation("permanentWeapon_toggleWeapon_on", "fr", "Vous avez activé l'arme «%s»")
BaseWars:AddTranslation("permanentWeapon_toggleWeapon_off", "fr", "Vous avez désactivé l'arme «%s»")
BaseWars:AddTranslation("permanentWeapon_playerNoWeapons", "fr", "Vous n'avez aucune armes")

-- EN
BaseWars:AddTranslation("bwm_permaWeapon", "en", "Perma Weapons")
BaseWars:AddTranslation("permanentWeapon_addedByAndDate", "en", "Added by %s the %s")
BaseWars:AddTranslation("permanentWeapons_invalidWeaponClass", "en", "The weapon \"%s\" doesn't exists")
BaseWars:AddTranslation("permanentWeapons_playerAlreadyHasWeapon", "en", "%s already has the weapon \"%s\"")
BaseWars:AddTranslation("permanentWeapons_playerDontHaveWeapon", "en", "%s doesn't have the weapon \"%s\"")
BaseWars:AddTranslation("permanentWeapon_toggleWeapon_on", "en", "You enabled the weapon \"%s\"")
BaseWars:AddTranslation("permanentWeapon_toggleWeapon_off", "en", "You disabled the weapon \"%s\"")
BaseWars:AddTranslation("permanentWeapon_playerNoWeapons", "en", "You have no weapons")

if CLIENT then
    hook.Add("BaseWars:Initialize", "BaseWars:PermanentWeapons", function()
        BaseWars:AddBaseWarsMenuTab("#bwm_permaWeapon", "basewars_materials/f3/weapons.png", "BaseWars.F3Menu.PermanentWeapons", 8)
    end)
end