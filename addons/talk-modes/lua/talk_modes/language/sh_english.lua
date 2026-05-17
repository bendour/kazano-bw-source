--[[-------------------------------------------

    Talk Modes - whisper/talk/yell 

    Licensed to 00000000000000000
	Version: 1.1.1

	By: SaturdaysHeroes & Djuk
	Special thanks to CupCakeR

--]]-------------------------------------------
local LANGUAGE = {}
LANGUAGE["General"] = "General"
LANGUAGE["Theme"] = "Theme"
LANGUAGE["Modes"] = "Modes"
LANGUAGE["Whisper"] = "Whisper"
LANGUAGE["Whisper_Desc"] = "What distance should Whisper reach?"
LANGUAGE["Yell"] = "Yell"
LANGUAGE["Yell_Desc"] = "What distance should Yell reach?"
LANGUAGE["Talk"] = "Talk" 
LANGUAGE["Talk_Desc"] = "What distance should Talk reach?"
LANGUAGE["3D Voice"] = "3D Voice"
LANGUAGE["3D Voice_Desc"] = "Should 3D Voice be turned on?"
LANGUAGE["Language"] = "Language"
LANGUAGE["Language_Desc"] = "Which language should be used?"
LANGUAGE["Selection Key"] = "Selection Key"
LANGUAGE["Selection Key_Desc"] = "Which key should open the selection menu?"
LANGUAGE["Talking Dead"] = "Talking Dead"
LANGUAGE["Talking Dead_Desc"] = "Should dead people be able to talk?"
LANGUAGE["Selection Menu Position"] = "Selection Menu Position"
LANGUAGE["Selection Menu Position_Desc"] = "Where should the menu be located?"
LANGUAGE["Save"] = "Save"
LANGUAGE["Reset"] = "Reset"
LANGUAGE["Preview"] = "Preview"
LANGUAGE["PreviewHeader"] = "PRESS [%s] TO EXIT PREVIEW"
LANGUAGE["PreviewText"] = "CURRENTLY PREVIEWING RANGE: %s UNITS"
LANGUAGE["Background"] = "Background"
LANGUAGE["Background_Desc"] = "Which color should be used for the background?"
LANGUAGE["Foreground"] = "Foreground"
LANGUAGE["Foreground_Desc"] = "Which color should be used for the foreground?"
LANGUAGE["Hover"] = "Accent"
LANGUAGE["Hover_Desc"] = "Which color should be used for the accent?"
LANGUAGE["White"] = "White"
LANGUAGE["White_Desc"] = "Which color should be used as white?"
LANGUAGE["Gray"] = "Gray"
LANGUAGE["Gray_Desc"] = "Which color should be used as gray?"
LANGUAGE["WelcomeMessage"] = "This server is using the Talk Modes script, hold %s to select your talk mode!"
LANGUAGE["Turn Off"] = "Turn OFF"
LANGUAGE["Using Mode"] = "Using Mode"
LANGUAGE["Auto-Hide"] = "Auto Hide"
LANGUAGE["Auto-Hide_Desc"] = "Should selection menu automatically hide when unused?"
LANGUAGE["Mode Change Message"] = "Mode Notification"
LANGUAGE["Mode Change Message_Desc"] = "Should players be notified when their talk mode is changed?"

TalkModes.Languages:Register("English", LANGUAGE)