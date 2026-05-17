--[[
	Create scaled fonts
--]]
local CH_Advent_FontSizes = { "10", "12", "14", "18", "25", "35", "45" }
local CH_Advent_OutfitFontSizes = { "6", "7", "10", "12", "25" }

local function CH_Advent_CreateFonts()
	for k, font in ipairs( CH_Advent_FontSizes ) do

		-- Fonts
		surface.CreateFont( "CH_Advent_Font_Caveat_Size".. font, {
			font = "Caveat Brush", 
			size = ScreenScale( font ), 
			weight = 600,
		} )
	end
	
	for k, font in ipairs( CH_Advent_OutfitFontSizes ) do

		-- Fonts
		surface.CreateFont( "CH_Advent_Font_Outfit_Size".. font, {
			font = "Outfit", 
			size = ScreenScale( font ), 
			weight = 400,
		} )
	end
end

CH_Advent_CreateFonts()

--[[
	Update when screen sizes changes
--]]
local function CH_Advent_OnScreenSizeChanged()
	CH_Advent.ScrW = ScrW()
	CH_Advent.ScrH = ScrH()
	
	-- Recreate fonts
    CH_Advent_CreateFonts()
end
hook.Add( "OnScreenSizeChanged", "CH_Advent_OnScreenSizeChanged", CH_Advent_OnScreenSizeChanged )

--[[
	Non-scaled fonts
--]]
surface.CreateFont( "CH_Advent_Font_NPC", {
	font = "Outfit",
	size = 55,
	weight = 600,
} )

surface.CreateFont( "CH_Advent_Font_NPC_Small", {
	font = "Outfit",
	size = 38,
	weight = 600,
} )

surface.CreateFont( "CH_Advent_Font_NPC_Smaller", {
	font = "Outfit",
	size = 30,
	weight = 600,
} )