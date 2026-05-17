ashop.titles.styles = ashop.titles.styles or {}

ashop.titles.styles[1] = {
    name = "Glitch",
    draw = function(text, colorIndex, txtw, txth, textOriginal, topAlign, font)
        local randNumber = math.floor(((CurTime() * 50) % #text)) + 1
        local old = text[randNumber]
        if !old then return end

        text[randNumber] = string.char(math.Round(math.Rand(33,125)))
        ashop.titles.styles[0](text, colorIndex, txtw, txth, textOriginal, topAlign, font)
        text[randNumber] = old
    end,
}

ashop.titles.styles[2] = {
    name = "Shiny",
    draw = function(text, color, xOffset, yOffset, textOriginal, topAlign, font)
        local textSize = #text
        surface.SetFont(font or "ashop_18")
        local w, h = surface.GetTextSize(textOriginal)
        local xOffset = xOffset or 0
        local yOffset = yOffset or 0

        xOffset = xOffset - w/2
        yOffset = yOffset - (topAlign == TEXT_ALIGN_CENTER and h/2 or 0)

        local r, g, b, isFunc

        if istable(color) then
            r = color.r
            g = color.g
            b = color.b
            isFunc = false
        else
            isFunc = true
        end

        for i = 1, textSize do
            local c = text[i]

            local outlinewidth = 3
            local steps = 1

            if isFunc then
                r, g, b = ashop.titles.colors[color].draw(i, textSize)
            end

            surface.SetTextColor(r - 40, g - 40, b - 40, 10)

            for _x = -outlinewidth, outlinewidth, steps do
                for _y = -outlinewidth, outlinewidth, steps do
                    surface.SetTextPos(xOffset + _x, yOffset + _y)
                    surface.DrawText(c)
                end
            end

            surface.SetTextPos(xOffset, yOffset)
            surface.SetTextColor(r, g, b)
            surface.DrawText(c)

            xOffset = xOffset + select(1, surface.GetTextSize(c))
        end
    end,
}

ashop.titles.styles[3] = {
    name = "Waves",
    draw = function(text, color, xOffset, yOffset, textOriginal, topAlign, font)
        local textSize = #text
        surface.SetFont(font or "ashop_18")
        local w, h = surface.GetTextSize(textOriginal)
        xOffset = xOffset or 0
        yOffset = yOffset or 0
        local cT = CurTime()

        xOffset = xOffset - w/2
        yOffset = yOffset - (topAlign == TEXT_ALIGN_CENTER and h/2 or 0)

        local r, g, b, isFunc

        if istable(color) then
            r = color.r
            g = color.g
            b = color.b
            isFunc = false
        else
            isFunc = true
        end

        for i = 1, textSize do
            if isFunc then
                r, g, b  = ashop.titles.colors[color].draw(i, textSize)
            end

            local c = text[i]

            surface.SetTextColor( r, g, b )
            surface.SetTextPos(xOffset, yOffset + math.sin(cT*2 + i/10)*10)
            surface.DrawText( c )

            xOffset = xOffset + surface.GetTextSize(c)
        end
    end,
}

ashop.titles.styles[4] = {
    name = "Reverse",
    draw = function(text, color, xOffset, yOffset, textOriginal, topAlign, font)
        local textSize = #text
        surface.SetFont(font or "ashop_18")
        local w, h = surface.GetTextSize(textOriginal)

        surface.SetTextPos((xOffset or 0) - w/2, 
            (yOffset or 0) - (topAlign == TEXT_ALIGN_CENTER and h/2 or 0))

        local r, g, b, isFunc

        if istable(color) then
            r = color.r
            g = color.g
            b = color.b
            isFunc = false
        else
            isFunc = true
        end

        for i = 1, textSize do
            if isFunc then
                r, g, b  = ashop.titles.colors[color].draw(i, textSize)
            end

            surface.SetTextColor( r, g, b )
            surface.DrawText( text[textSize - (i - 1)] )
        end
    end,
}

ashop.titles.styles[5] = {
    name = "Pixel Wave",
    draw = function(text, color, xOffset, yOffset, textOriginal, topAlign, font)
        local textSize = #text
        surface.SetFont(font or "ashop_18")
        local w, h = surface.GetTextSize(textOriginal)
        local xOffset = xOffset or 0
        local yOffset = yOffset or 0
        local cT = CurTime()

        xOffset = xOffset - w/2
        yOffset = yOffset - (topAlign == TEXT_ALIGN_CENTER and h/2 or 0)

        local r, g, b, isFunc

        if istable(color) then
            r = color.r
            g = color.g
            b = color.b
            isFunc = false
        else
            isFunc = true
        end

        for i = 1, textSize do
            if isFunc then
                r, g, b = ashop.titles.colors[color].draw(i, textSize)
            end

            local c = text[i]
            local htxt = math.floor(math.sin(cT*2 + i/10)*5)*2

            surface.SetTextColor( r, g, b )
            surface.SetTextPos(xOffset, yOffset + htxt)
            surface.DrawText( c )

            xOffset = xOffset + surface.GetTextSize(c)
        end
    end,
}

local clrHypnotique = {
    Color(253, 121, 168),
    Color(225, 112, 85),
    Color(253, 203, 110),
    Color(85, 239, 196),
    Color(116, 185, 255),
}
local clrAmt = #clrHypnotique
local rat = 1 / clrAmt

ashop.titles.styles[6] = {
    name = "Psychodelic",
    draw = function(text, color, xOffset, yOffset, textOriginal, topAlign, font)
        surface.SetFont(font or "ashop_18")
        local w, h = surface.GetTextSize(textOriginal)

        local c = CurTime()
        local cT = c % 1 // Get the current anim, on 1sec
        local cL = c % rat
        local index = math.floor(clrAmt * cT) + 1 // Get current color

        local radius = (w + h*4) / 2

        local xOffset = (xOffset or 0) - w/2
        local yOffset = (yOffset or 0) - (topAlign == TEXT_ALIGN_CENTER and h/2 or 0)

        draw.NoTexture()
        for i=clrAmt, 0, -1 do
            local id = (index + i) % #clrHypnotique + 1
            local clr = clrHypnotique[id]

            local irad = (i*rat) - cL

            if irad < 0 then continue end

            ashop.StartStencil()
                surface.SetDrawColor(1, 1, 1, 1)
                ashop.ui.DrawCircle(xOffset + w/2, yOffset + h/2, radius * irad, 5)

            ashop.ReplaceStencil(1)
                draw.SimpleText(textOriginal, font or "ashop_18", xOffset, yOffset, clr, 0, 0)
            ashop.EndStencil()
        end
    end,
}

ashop.titles.styles[7] = {
    name = "Psychodelic 2",
    draw = function(text, color, xOffset, yOffset, textOriginal, topAlign, font)
        local clrAmt = 4
        local rat = 1 / clrAmt
        surface.SetFont(font or "ashop_18")
        local w, h = surface.GetTextSize(textOriginal)

        local c = CurTime()
        local cT = c % 1 // Get the current anim, on 1sec
        local cL = c % rat
        local index = math.floor(clrAmt * cT) + 1 // Get current color

        local radius = (w + h*4) / 2

        local xOffset = (xOffset or 0) - w/2
        local yOffset = (yOffset or 0) - (topAlign == TEXT_ALIGN_CENTER and h/2 or 0)

        draw.NoTexture()
        local r, g, b, isFunc

        if istable(color) then
            r = color.r
            g = color.g
            b = color.b
            isFunc = false
        else
            isFunc = true
        end

        for i=clrAmt, 0, -1 do
            local id = (index + i) % clrAmt + 1
            local clr = clrHypnotique[id]

            local irad = (i*rat) - cL

            if isFunc then
                r, g, b = ashop.titles.colors[color].draw(id, clrAmt)
            end

            r = r + id * 4 - id * 2
            g = g + id * 4 - id * 2
            b = b + id * 4 - id * 2

            if irad < 0 then continue end

            ashop.StartStencil()
                surface.SetDrawColor(1, 1, 1, 1)
                ashop.ui.DrawCircle(xOffset + w/2, yOffset + h/2, radius * irad, 5)

            ashop.ReplaceStencil(1)
                draw.SimpleText(textOriginal, font or "ashop_18", xOffset, yOffset, Color(r, g, b), 0, 0)
            ashop.EndStencil()
        end
    end,
}