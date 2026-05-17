--[[-------------------------------------------

    Talk Modes - whisper/talk/yell 

    Licensed to 00000000000000000
	Version: 1.1.1

	By: SaturdaysHeroes & Djuk
	Special thanks to CupCakeR

--]]-------------------------------------------
local LANGUAGE = {}
LANGUAGE["General"] = "Основные"
LANGUAGE["Theme"] = "Тема"
LANGUAGE["Modes"] = "Режимы"
LANGUAGE["Whisper"] = "Шепот"
LANGUAGE["Whisper_Desc"] = "На какой дистанции работает Шепот?"
LANGUAGE["Yell"] = "Крик"
LANGUAGE["Yell_Desc"] = "На какой дистанции работает Крик?"
LANGUAGE["Talk"] = "Говор" 
LANGUAGE["Talk_Desc"] = "На какой дистанции работает Говор?"
LANGUAGE["3D Voice"] = "3D Голос"
LANGUAGE["3D Voice_Desc"] = "Должен ли 3D Голос быть включен?"
LANGUAGE["Language"] = "Язык"
LANGUAGE["Language_Desc"] = "Какой язык следует использовать?"
LANGUAGE["Selection Key"] = "Кнопка выбора"
LANGUAGE["Selection Key_Desc"] = "Какая кнопка должна открыть меню выбора?"
LANGUAGE["Talking Dead"] = "Говорящие мертвецы"
LANGUAGE["Talking Dead_Desc"] = "Должны ли мертвые люди говорить?"
LANGUAGE["Selection Menu Position"] = "Позиция меню выбора"
LANGUAGE["Selection Menu Position_Desc"] = "Где должно находиться меню на экране?"
LANGUAGE["Save"] = "Сохранить"
LANGUAGE["Reset"] = "Сбросить"
LANGUAGE["Preview"] = "Предпросмотр"
LANGUAGE["PreviewHeader"] = "НАЖМИТЕ [%f] ЧТОБЫ ЗАКРЫТЬ ПРЕДПРОСМОТР"
LANGUAGE["PreviewText"] = "ТЕКУЩАЯ ДИСТАНЦИЯ ПРЕДПРОСМОТРА: %s ЮНИТОВ"
LANGUAGE["Background"] = "Фон"
LANGUAGE["Background_Desc"] = "Выберете цвет фона"
LANGUAGE["Foreground"] = "Передний план"
LANGUAGE["Foreground_Desc"] = "Выберете цвет переднего плана"
LANGUAGE["Hover"] = "Акцент"
LANGUAGE["Hover_Desc"] = "Выберете цвет выделенного текста"
LANGUAGE["White"] = "Белый"
LANGUAGE["White_Desc"] = "Выберете цвет вместо белого"
LANGUAGE["Gray"] = "Серый"
LANGUAGE["Gray_Desc"] = "Выберете цвет вместо серого"
LANGUAGE["WelcomeMessage"] = "Этот сервер использует скрипт Talk Modes, удерживайте %s, чтобы сменить режим разговора!"
LANGUAGE["Turn Off"] = "Отключить"
LANGUAGE["Using Mode"] = "Режим использования"
LANGUAGE["Auto-Hide"] = "Скрывать автоматически"
LANGUAGE["Auto-Hide_Desc"] = "Скрывать меню выбора автоматически если не используется?"
LANGUAGE["Mode Change Message"] = "Mode Notification"
LANGUAGE["Mode Change Message_Desc"] = "Should players be notified when their talk mode is changed?"

TalkModes.Languages:Register("Русский", LANGUAGE)