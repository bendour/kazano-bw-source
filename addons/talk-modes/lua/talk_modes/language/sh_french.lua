--[[-------------------------------------------

    Talk Modes - whisper/talk/yell 

    Licensed to 00000000000000000
	Version: 1.1.1

	By: SaturdaysHeroes & Djuk
	Special thanks to CupCakeR

--]]-------------------------------------------

local LANGUAGE = {}
LANGUAGE["General"] = "Général"
LANGUAGE["Theme"] = "Thème"
LANGUAGE["Modes"] = "Modes"
LANGUAGE["Whisper"] = "Chuchotement"
LANGUAGE["Whisper_Desc"] = "Quelle distance le chuchotement doit-il atteindre ?"
LANGUAGE["Yell"] = "Hurler"
LANGUAGE["Yell_Desc"] = "Quelle distance le hurlement doit-il atteindre ?"
LANGUAGE["Talk"] = "Parler" 
LANGUAGE["Talk_Desc"] = "Quelle distance le parler doit-il atteindre ?"
LANGUAGE["3D Voice"] = "Voix 3D"
LANGUAGE["3D Voice_Desc"] = "La voix 3D doit-elle être activée ?"
LANGUAGE["Language"] = "Langue"
LANGUAGE["Language_Desc"] = "Quelle langue doit être utilisée ?"
LANGUAGE["Selection Key"] = "Touche de sélection"
LANGUAGE["Selection Key_Desc"] = "Quelle touche doit ouvrir le menu de sélection ?"
LANGUAGE["Talking Dead"] = "Parler en étant mort"
LANGUAGE["Talking Dead_Desc"] = "Les morts devraient-ils pouvoir parler ?"
LANGUAGE["Selection Menu Position"] = "Position du menu de sélection"
LANGUAGE["Selection Menu Position_Desc"] = "Où doit se trouver le menu ?"
LANGUAGE["Save"] = "Sauvegarder"
LANGUAGE["Reset"] = "Réinitialiser"
LANGUAGE["Preview"] = "Aperçu"
LANGUAGE["PreviewHeader"] = "APPUYER SUR [%s] POUR QUITTER L'APERÇU"
LANGUAGE["PreviewText"] = "APERÇU EN DIRECT D'UNE PORTÉE DE: %s UNITS"
LANGUAGE["Background"] = "Arrière-plan"
LANGUAGE["Background_Desc"] = "Quelle couleur doit être utilisée pour l'arrière-plan ?"
LANGUAGE["Foreground"] = "Premier plan"
LANGUAGE["Foreground_Desc"] = "Quelle couleur doit être utilisée pour le premier plan ?"
LANGUAGE["Hover"] = "Accentuée"
LANGUAGE["Hover_Desc"] = "Quelle couleur doit être utilisée pour l'accentuation ?"
LANGUAGE["White"] = "Blanc"
LANGUAGE["White_Desc"] = "Quelle couleur doit être utilisée comme blanc ?"
LANGUAGE["Gray"] = "Gris"
LANGUAGE["Gray_Desc"] = "Quelle couleur doit être utilisée comme gris ?"
LANGUAGE["WelcomeMessage"] = "Ce serveur utilise le script Talk Modes, maintenez %s pour sélectionner votre mode de conversation !"
LANGUAGE["Turn Off"] = "Éteindre"
LANGUAGE["Using Mode"] = "Façon de parler"
LANGUAGE["Auto-Hide"] = "Masquer automatiquement"
LANGUAGE["Auto-Hide_Desc"] = "Le menu de sélection doit-il se masquer automatiquement lorsqu'il n'est pas utilisé ?"
LANGUAGE["Mode Change Message"] = "Mode Notification"
LANGUAGE["Mode Change Message_Desc"] = "Should players be notified when their talk mode is changed?"

TalkModes.Languages:Register("Français", LANGUAGE)