-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local translationFiles = file.Find("z_hadez/languages/*.lua", "LUA")
local translations = {}
local languages = {}
local langConvarName = "gmod_language"

-- Intialize languages  
for _,translation in pairs(translationFiles) do
	local f = "z_hadez/languages/"..translation

	if SERVER then
		AddCSLuaFile(f) 
	end
	
	-- Get the lang code from file name 
	local langCode = string.match(translation,"(%a+).lua")
	langCode = langCode:upper()
	
	-- Add the code to the range of languages
	table.insert(languages,langCode)
	
	-- Store the translations in the table
	translations[langCode] = include( f )
	
end

function SH_HADEZ:GetLanguages()
	return languages
end

function SH_HADEZ:GetLanguage()

	if SERVER then
		return self.SETTINGS.SYSLANG
	end
	
	langConvar = GetConVar( langConvarName )
	return langConvar:GetString():upper()
	
end

function SH_HADEZ:Translate(str)

	local playerLang = self:GetLanguage()
	local translatedStr = (translations[playerLang] and translations[playerLang][str]) or translations["EN"][str]
	
	return translatedStr or str

end