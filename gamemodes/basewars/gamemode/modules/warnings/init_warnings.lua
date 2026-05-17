-- FR
BaseWars:AddTranslation("bwm_warnings", "fr", "Warnings")
BaseWars:AddTranslation("warnings_playerWarned", "fr", "Vous avez été warn")
BaseWars:AddTranslation("warnings_adminWarnPlayer", "fr", "Vous avez warn %s")
BaseWars:AddTranslation("warnings_adminRemoveWarn", "fr", "Vous avez supprimé un warn de %s, raison » %s")
BaseWars:AddTranslation("warnings_invalidWarnID", "fr", "Warn ID %s n'est pas valide")
BaseWars:AddTranslation("warnings_adminEditWarn", "fr", "Vous avez modifié un warn de %s")
BaseWars:AddTranslation("warnings_noWarns", "fr", "Vous avez aucun warnings")
BaseWars:AddTranslation("warnings_sameWarningReason", "fr", "Vous ne pouvez pas changer la même raison")
BaseWars:AddTranslation("warnings_adminDeleteAllWarn", "fr", "Vous avez supprimé tout les warnings de %s")
BaseWars:AddTranslation("warnings_admin_allPlayers", "fr", "Joueurs En Ligne")
BaseWars:AddTranslation("warnings_admin_warningsOf", "fr", "Warnings de %s (%s warnings)")
BaseWars:AddTranslation("warnings_search", "fr", "Recherche avec SteamID/SteamID64")
BaseWars:AddTranslation("warnings_admin_deleteAllWarnings", "fr", "Supprimer Tout Les Warnings")
BaseWars:AddTranslation("warnings_admin_deleteAllWarningsFrom", "fr", "Supprimer %s warnings de %s")
BaseWars:AddTranslation("warnings_admin_deleteAllButton", "fr", "Supprimer")
BaseWars:AddTranslation("warnings_admin_addWarningTitle", "fr", "Ajouter un warning - %s")
BaseWars:AddTranslation("warnings_admin_addWarningButton", "fr", "Ajouter Warning")
BaseWars:AddTranslation("warnings_reasonPlaceholder", "fr", "Raison du warning")
BaseWars:AddTranslation("warnings_admin_editWarningTitle", "fr", "Éditer un warning - %s")
BaseWars:AddTranslation("warnings_admin_editWarningButton", "fr", "Éditer Warning")
BaseWars:AddTranslation("warnings_warnInfos", "fr", {
    warnID = "Warn ID:",
    warnedBy = "Warning Par:",
    warnDate = "Date Du Warning:",
    warnReason = "Raison:"
})
BaseWars:AddTranslation("warnings_playerWarnedChatNotify", "fr", {
    "{COLOR_WARN}",
    "{NAME}",
    "{COLOR_WARN2}",
    " a été warn pour » ",
    "{COLOR_WARN}",
    "{REASON}"
})

-- EN
BaseWars:AddTranslation("bwm_warnings", "en", "Warnings")
BaseWars:AddTranslation("warnings_playerWarned", "en", "You have been warned")
BaseWars:AddTranslation("warnings_adminWarnPlayer", "en", "You have warned %s")
BaseWars:AddTranslation("warnings_adminRemoveWarn", "en", "You removed a warn from %s, reason » %s")
BaseWars:AddTranslation("warnings_invalidWarnID", "en", "Warn ID %s is not valid")
BaseWars:AddTranslation("warnings_adminEditWarn", "en", "You modified a warn of %s")
BaseWars:AddTranslation("warnings_noWarns", "en", "You have no warnings")
BaseWars:AddTranslation("warnings_sameWarningReason", "en", "You can't change for the same reason")
BaseWars:AddTranslation("warnings_adminDeleteAllWarn", "en", "You have deleted all warnings of %s")
BaseWars:AddTranslation("warnings_admin_allPlayers", "en", "Online Players")
BaseWars:AddTranslation("warnings_admin_warningsOf", "en", "Warnings of %s (%s warnings)")
BaseWars:AddTranslation("warnings_search", "en", "Search with SteamID/SteamID64")
BaseWars:AddTranslation("warnings_admin_deleteAllWarnings", "en", "Delete All Warnings")
BaseWars:AddTranslation("warnings_admin_deleteAllWarningsFrom", "en", "Delete %s warnings from %s")
BaseWars:AddTranslation("warnings_admin_deleteAllButton", "en", "Delete")
BaseWars:AddTranslation("warnings_admin_addWarningTitle", "en", "Add a warning - %s")
BaseWars:AddTranslation("warnings_admin_addWarningButton", "en", "Add Warning")
BaseWars:AddTranslation("warnings_reasonPlaceholder", "en", "Reason of the warning")
BaseWars:AddTranslation("warnings_admin_editWarningTitle", "en", "Edit un warning - %s")
BaseWars:AddTranslation("warnings_admin_editWarningButton", "en", "Edit Warning")
BaseWars:AddTranslation("warnings_warnInfos", "en", {
    warnID = "Warn ID:",
    warnedBy = "Warned By:",
    warnDate = "Warn Date:",
    warnReason = "Reason:"
})
BaseWars:AddTranslation("warnings_playerWarnedChatNotify", "en", {
    "{COLOR_WARN}",
    "{NAME}",
    "{COLOR_WARN2}",
    " has been warned for » ",
    "{COLOR_WARN}",
    "{REASON}"
})

if CLIENT then
    hook.Add("BaseWars:Initialize", "BaseWars:Warnings", function()
        BaseWars:AddBaseWarsMenuTab("#bwm_warnings", "basewars_materials/f3/warnings.png", "BaseWars.F3Menu.Warnings", 7)
        BaseWars:AddAdminMenuTab("#bwm_warnings", "basewars_materials/f3/warnings.png", "BaseWars.AdminMenu.Warnings", 5)
    end)
end