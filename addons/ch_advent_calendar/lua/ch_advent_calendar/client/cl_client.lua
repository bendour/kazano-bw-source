CH_Advent.Colors = CH_Advent.Colors or {}
CH_Advent.Materials = CH_Advent.Materials or {}

CH_Advent.ScrW = ScrW()
CH_Advent.ScrH = ScrH()

--[[
	Cache materials
--]]
CH_Advent.Materials.CloseIcon = Material( "craphead_scripts/ch_advent_calendar/close.png" )
CH_Advent.Materials.Background = Material( "craphead_scripts/ch_advent_calendar/calendar_background.png" )

CH_Advent.Materials.SparksWhite = Material( "craphead_scripts/ch_advent_calendar/white_sparks.png" )
CH_Advent.Materials.SparksRed = Material( "craphead_scripts/ch_advent_calendar/red_sparks.png" )
CH_Advent.Materials.SparksWhiteBig = Material( "craphead_scripts/ch_advent_calendar/white_sparks_big.png" )
CH_Advent.Materials.SparksRedBig = Material( "craphead_scripts/ch_advent_calendar/red_sparks_big.png" )

CH_Advent.Materials.RewardIcons = {
	["Square"] = Material( "craphead_scripts/ch_advent_calendar/calendar_gift_flat.png" ),
	["Tall"] = Material( "craphead_scripts/ch_advent_calendar/calendar_gift_tall.png" ),
	["Wide"] = Material( "craphead_scripts/ch_advent_calendar/calendar_gift_wide.png" ),
}

CH_Advent.Materials.CoalIcons = {
	["Square"] = Material( "craphead_scripts/ch_advent_calendar/calendar_coal_flat.png" ),
	["Tall"] = Material( "craphead_scripts/ch_advent_calendar/calendar_coal_tall.png" ),
	["Wide"] = Material( "craphead_scripts/ch_advent_calendar/calendar_coal_wide.png" ),
}

CH_Advent.Materials.LinkIcons = {
	["YouTube"] = Material( "craphead_scripts/ch_advent_calendar/youtube.png", "smooth" ),
	["Discord"] = Material( "craphead_scripts/ch_advent_calendar/discord.png", "smooth" ),
	["Steam"] = Material( "craphead_scripts/ch_advent_calendar/steam.png", "smooth" ),
	["Website"] = Material( "craphead_scripts/ch_advent_calendar/website.png", "smooth" ),
}

CH_Advent.Materials.SquareIcons = {
	[1] = Material( "craphead_scripts/ch_advent_calendar/calendar_1.png" ),
	[2] = Material( "craphead_scripts/ch_advent_calendar/calendar_2.png" ),
	[3] = Material( "craphead_scripts/ch_advent_calendar/calendar_3.png" ),
	[4] = Material( "craphead_scripts/ch_advent_calendar/calendar_4.png" ),
	[5] = Material( "craphead_scripts/ch_advent_calendar/calendar_5.png" ),
	[6] = Material( "craphead_scripts/ch_advent_calendar/calendar_6.png" ),
	[7] = Material( "craphead_scripts/ch_advent_calendar/calendar_7.png" ),
	[8] = Material( "craphead_scripts/ch_advent_calendar/calendar_8.png" ),
	[9] = Material( "craphead_scripts/ch_advent_calendar/calendar_9.png" ),
	[10] = Material( "craphead_scripts/ch_advent_calendar/calendar_10.png" ),
	[11] = Material( "craphead_scripts/ch_advent_calendar/calendar_11.png" ),
	[12] = Material( "craphead_scripts/ch_advent_calendar/calendar_12.png" ),
	[13] = Material( "craphead_scripts/ch_advent_calendar/calendar_13.png" ),
	[14] = Material( "craphead_scripts/ch_advent_calendar/calendar_14.png" ),
	[15] = Material( "craphead_scripts/ch_advent_calendar/calendar_15.png" ),
	[16] = Material( "craphead_scripts/ch_advent_calendar/calendar_16.png" ),
	[17] = Material( "craphead_scripts/ch_advent_calendar/calendar_17.png" ),
	[18] = Material( "craphead_scripts/ch_advent_calendar/calendar_18.png" ),
	[19] = Material( "craphead_scripts/ch_advent_calendar/calendar_19.png" ),
	[20] = Material( "craphead_scripts/ch_advent_calendar/calendar_20.png" ),
	[21] = Material( "craphead_scripts/ch_advent_calendar/calendar_21.png" ),
	[22] = Material( "craphead_scripts/ch_advent_calendar/calendar_22.png" ),
	[23] = Material( "craphead_scripts/ch_advent_calendar/calendar_23.png" ),
	[24] = Material( "craphead_scripts/ch_advent_calendar/calendar_24.png" ),
}

--[[
	Cache colors
--]]
CH_Advent.Colors.BG = Color( 27, 27, 27, 255 )
CH_Advent.Colors.DarkGray = Color( 18, 18, 18, 255 )
CH_Advent.Colors.LightGray = Color( 38, 38, 38, 255 )

CH_Advent.Colors.Lime = Color( 182, 198, 175, 255 )
CH_Advent.Colors.Green = Color( 42, 150, 42, 255 )
CH_Advent.Colors.Red = Color( 181, 58, 58, 255 )
CH_Advent.Colors.DarkRed = Color( 156, 45, 43, 255 )
CH_Advent.Colors.Beige = Color( 245, 238, 215, 255 )

CH_Advent.Colors.WhiteAlpha = Color( 255, 255, 255, 100 )

CH_Advent.Colors.Gold = Color( 255, 215, 0, 255 )

--[[
	Net message to show menu
	-- 00000000000000000
--]]
net.Receive( "CH_Advent_Net_OpenDashboard", function( len, ply )
	local timeleft = net.ReadUInt( 32 )
	local day = net.ReadUInt( 5 )

	CH_Advent.DashboardMenu( timeleft, day )
end )

--[[
	Con command to show menu
--]]
local function CH_Advent_ConCommandOpenMenu()
	net.Start( "CH_Advent_Net_RequestSquareMenu" )
	net.SendToServer()
end
concommand.Add( "ch_advent_showmenu", CH_Advent_ConCommandOpenMenu )

local function charWrap(text, remainingWidth, maxWidth)
    local totalWidth = 0

    text = text:gsub(".", function(char)
        totalWidth = totalWidth + surface.GetTextSize(char)

        -- Wrap around when the max width is reached
        if totalWidth >= remainingWidth then
            -- totalWidth needs to include the character width because it's inserted in a new line
            totalWidth = surface.GetTextSize(char)
            remainingWidth = maxWidth
            return "\n" .. char
        end

        return char
    end)

    return text, totalWidth
end

function CH_Advent.TextWrap(text, font, maxWidth)
    local totalWidth = 0

    surface.SetFont(font)

    local spaceWidth = surface.GetTextSize(' ')
    text = text:gsub("(%s?[%S]+)", function(word)
            local char = string.sub(word, 1, 1)
            if char == "\n" or char == "\t" then
                totalWidth = 0
            end

            local wordlen = surface.GetTextSize(word)
            totalWidth = totalWidth + wordlen

            -- Wrap around when the max width is reached
            if wordlen >= maxWidth then -- Split the word if the word is too big
                local splitWord, splitPoint = charWrap(word, maxWidth - (totalWidth - wordlen), maxWidth)
                totalWidth = splitPoint
                return splitWord
            elseif totalWidth < maxWidth then
                return word
            end

            -- Split before the word
            if char == ' ' then
                totalWidth = wordlen - spaceWidth
                return '\n' .. string.sub(word, 2)
            end

            totalWidth = wordlen
            return '\n' .. word
        end)

    return text
end