--[[
	Language functions
--]]
function CH_Advent.LangString( text )
	local translation = text .." (Translation missing)"
	local lang = CH_Advent.Config.Language or "en"
	
	if CH_Advent.Config.Lang[ text ] then
		translation = CH_Advent.Config.Lang[ text ][ lang ]
	end
	
	return translation
end