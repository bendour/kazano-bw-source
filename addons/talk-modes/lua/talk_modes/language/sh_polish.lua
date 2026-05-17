--[[-------------------------------------------

    Talk Modes - whisper/talk/yell 

    Licensed to 00000000000000000
	Version: 1.1.1

	By: SaturdaysHeroes & Djuk
	Special thanks to CupCakeR

--]]-------------------------------------------
local LANGUAGE = {}
LANGUAGE["General"] = "Ogólne"
LANGUAGE["Theme"] = "Motyw"
LANGUAGE["Modes"] = "Tryby"
LANGUAGE["Whisper"] = "Szept"
LANGUAGE["Whisper_Desc"] = "Jaki zasięg powinien mieć szept?"
LANGUAGE["Yell"] = "Krzyk"
LANGUAGE["Yell_Desc"] = "Jaki zasięg powinien mieć krzyk?"
LANGUAGE["Talk"] = "Rozmowa" 
LANGUAGE["Talk_Desc"] = "Jaki zasięg powinna mieć rozmowa?"
LANGUAGE["3D Voice"] = "Dzwięk 3D"
LANGUAGE["3D Voice_Desc"] = "Czy dźwięk 3D powinien być aktywny?"
LANGUAGE["Language"] = "Język"
LANGUAGE["Language_Desc"] = "Który język powinien być aktywny?"
LANGUAGE["Selection Key"] = "Klawisz Wyboru"
LANGUAGE["Selection Key_Desc"] = "Który klawisz powinien otwierać panel?"
LANGUAGE["Talking Dead"] = "Gadające Trupy"
LANGUAGE["Talking Dead_Desc"] = "Czy nieżywi gracze powinni móc mówić?"
LANGUAGE["Selection Menu Position"] = "Pozycja Menu"
LANGUAGE["Selection Menu Position_Desc"] = "Gdzie powinno się znajdować menu wyboru?"
LANGUAGE["Save"] = "Zapisz"
LANGUAGE["Reset"] = "Zresetuj"
LANGUAGE["Preview"] = "Podgląd"
LANGUAGE["PreviewHeader"] = "PRZYCIŚNIJ [%s] ABY ZAKOŃCZYĆ PODGLĄD"
LANGUAGE["PreviewText"] = "OBECNIE POKAZYWANY JEST ZASIĘG: %s JEDNOSTEK"
LANGUAGE["Background"] = "Kolor Tła"
LANGUAGE["Background_Desc"] = "Który kolor powinien być używany jako kolor tła?"
LANGUAGE["Foreground"] = "Kolor Pierwszoplanowy"
LANGUAGE["Foreground_Desc"] = "Który kolor powinien być używany jako kolor pierwszoplanowy?"
LANGUAGE["Hover"] = "Akcent"
LANGUAGE["Hover_Desc"] = "Który kolor powinien być używany jako kolor akcentu?"
LANGUAGE["White"] = "Biały"
LANGUAGE["White_Desc"] = "Który kolor powinien być używany jako kolor biały?"
LANGUAGE["Gray"] = "Szary"
LANGUAGE["Gray_Desc"] = "Który kolor powinien być używany jako kolor szary?"
LANGUAGE["WelcomeMessage"] = "Ten serwer korzysta ze skryptu Talk Modes, przytrzymaj %s aby wybrać swój tryb mówienia!"
LANGUAGE["Turn Off"] = "Wyłącz"
LANGUAGE["Using Mode"] = "Aktywny tryb"
LANGUAGE["Auto-Hide"] = "Automatyczne Ukrywanie"
LANGUAGE["Auto-Hide_Desc"] = "Czy menu wyboru powinno samo się chować, jeżeli jest nieużywane?"
LANGUAGE["Mode Change Message"] = "Powiadomienie o zmianie"
LANGUAGE["Mode Change Message_Desc"] = "Czy gracz powinien otrzymywać powiadomienie o zmianie trybu?"

TalkModes.Languages:Register("Polski", LANGUAGE)