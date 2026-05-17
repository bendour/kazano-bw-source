--[[-------------------------------------------

    Talk Modes - whisper/talk/yell 

    Licensed to 00000000000000000
	Version: 1.1.1

	By: SaturdaysHeroes & Djuk
	Special thanks to CupCakeR

--]]-------------------------------------------
TalkModes = TalkModes || {}
TalkModes.Languages = TalkModes.Languages || {}
TalkModes.Languages.Available = TalkModes.Languages.Available || {}
TalkModes.Languages.Active = TalkModes.Languages.Active || "English" -- Don't touch this line, change language using the in-game admin menu

function TalkModes.Languages:Register(strLanguage, tblPhrases)
    self.Available[strLanguage] = tblPhrases
end

function TalkModes.Languages:GetPhrase(strPhrase)
    return self.Available[TalkModes.Config:GetSetting("General", "Language")][strPhrase] || "phrase_not_found"
end