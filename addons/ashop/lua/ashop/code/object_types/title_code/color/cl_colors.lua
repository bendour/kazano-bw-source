// Optimisation
// We cache curtime every frame
// IT CAN be useless if nobody have a title
// But on some title, there can be 20 curtime calls
// And there can be multiples players
// For a micro, slight, 0.00001 fps lost, I prefer to do this optimisation
local cachedCurTime = CurTime()

hook.Add('PreRender', "ashop_cacheCurTimeTitle", function()
    cachedCurTime = CurTime()
end)

ashop.titles.colors[1] = {
    name = "Country - USA",
    draw = function(i, textSize)
        local rat = 1 / textSize * i

        if rat < 0.30 then
            return 10, 49, 97
        elseif i % 2 == 0 then
            return 179, 25, 66
        else
            return 255, 255, 255
        end
    end
}

ashop.titles.colors[2] = {
    name = "Rainbow2",
    draw = function(i, textSize)
        local r = ((20 * ((i / textSize) * i)) + cachedCurTime * 120) % 360
        local col = HSVToColor( r, 0.5, 1 )
        return col.r, col.g, col.b
    end
}

ashop.titles.colors[3] = {
    name = "Rainbow",
    draw = function(i, textSize)
        local col = HSVToColor( (cachedCurTime*50 + i * 4) % 360, 1, 1 )
        return col.r, col.g, col.b
    end
}

ashop.titles.colors[4] = {
    name = "Gradient - Violet",
    draw = function(i, textSize)
        local timing = math.abs((cachedCurTime*50 + i * 4) % 180 - 90)
        local col = HSVToColor( timing + 270, 1, 1 )
        return col.r, col.g, col.b
    end
}

ashop.titles.colors[5] = {
    name = "Cutted - Violet",
    draw = function(i, textSize)
        local timing = math.abs((cachedCurTime*50 + i * 25) % 180 - 90)
        local col = HSVToColor( timing + 270, 1, 1 )
        return col.r, col.g, col.b
    end
}

ashop.titles.colors[6] = {
    name = "Cutted - Green",
    draw = function(i, textSize)
        local timing = math.abs((cachedCurTime*50 + i * 25) % 180 - 90)
        local col = HSVToColor( timing + 90, 1, 1 )
        return col.r, col.g, col.b
    end
}

ashop.titles.colors[7] = {
    name = "Cutted - Blue",
    draw = function(i, textSize)
        local timing = math.abs((cachedCurTime*50 + i * 25) % 180 - 90)
        local col = HSVToColor( timing + 180, 1, 1 )
        return col.r, col.g, col.b
    end
}

ashop.titles.colors[8] = {
    name = "Cutted - Orange",
    draw = function(i, textSize)
        local timing = math.abs((cachedCurTime*50 + i * 25) % 180 - 90)
        local col = HSVToColor( timing + 330, 1, 1 )
        return col.r, col.g, col.b
    end
}

ashop.titles.colors[9] = {
    name = "Cutted - Rose",
    draw = function(i, textSize)
        local timing = math.abs((cachedCurTime*50 + i * 4) % 180 - 90)
        local col = HSVToColor( timing + 270, 0.5, 1 )
        return col.r, col.g, col.b
    end
}

ashop.titles.colors[10] = {
    name = "Sequins",
    draw = function(i, textSize)
        local c = cachedCurTime

        local timing = math.abs((c * 50 + i * 25) % 180 - 90)
        local col = HSVToColor( timing + 270, 1, math.abs(c%2 - 1) + i/4 )
        return col.r, col.g, col.b
    end
}

ashop.titles.colors[11] = {
    name = "Sequins - Red",
    draw = function(i, textSize)
        local c = cachedCurTime
        local timing = math.abs((c*50 + i * 25) % 180 - 90)
        local col = HSVToColor( timing + 270, 1, math.abs(c%2 - 1) + i/4 )
        return col.r, 0, 0
    end
}

ashop.titles.colors[12] = {
    name = "Sequins - Blue",
    draw = function(i, textSize)
        local c = cachedCurTime
        local timing = math.abs((c*50 + i * 25) % 180 - 90)
        local col = HSVToColor( timing + 180, 1, math.abs(c%2 - 1) + i/4 )
        return 0, 0, col.b
    end
}

ashop.titles.colors[13] = {
    name = "Sequins - Green",
    draw = function(i, textSize)
        local c = cachedCurTime
        local timing = math.abs((c*50 + i * 25) % 180 - 90)
        local col = HSVToColor( timing + 90, 1, math.abs(c%2 - 1) + i/4 )
        return 0, col.g, 0
    end
}

ashop.titles.colors[14] = {
    name = "Country - Spanish",
    draw = function(i, textSize)
        local rat = 1 / textSize * i

        if rat > 0.33 and rat < 0.66 then
            return 241, 191, 0
        else
            return 170, 21, 27
        end
    end
}

ashop.titles.colors[15] = {
    name = "Country - France",
    draw = function(i, textSize)
        local rat = 1 / textSize * i

        if rat < 0.33 then
            return 50, 50, 255
        elseif rat < 0.66 then
            return 255, 255, 255
        else
            return 255, 50, 50
        end
    end
}

ashop.titles.colors[16] = {
    name = "Country - Morocco",
    draw = function(i, textSize)
        local rat = 1 / textSize * i

        if rat > 0.3 and rat < 0.70 then
            return 0, 150, 0
        else
            return 255, 50, 50
        end
    end
}

ashop.titles.colors[17] = {
    name = "Country - Belgium",
    draw = function(i, textSize)
        local rat = 1 / textSize * i

        if rat < 0.33 then
            return 0, 0, 0
        elseif rat < 0.66 then
            return 253, 218, 36
        else
            return 239, 51, 64
        end
    end
}

ashop.titles.colors[18] = {
    name = "Country - Algeria",
    draw = function(i, textSize)
        local rat = 1 / textSize * i

        if rat < 0.4 then
            return 0, 150, 0
        elseif rat < 0.6 then
            return 255, 50, 50
        else
            return 255, 255, 255
        end
    end
}

ashop.titles.colors[19] = {
    name = "Country - Quebec",
    draw = function(i, textSize)
        local rat = 1 / textSize * i

        if rat > 0.35 and rat < 0.65 then
            return 250, 250, 250
        else
            return 0, 31, 151
        end
    end
}

local gradOP1 = Color(232, 67, 147)
local gradOP2 = Color(253, 203, 110)
ashop.titles.colors[20] = {
    name = "Gradient - Orange-Pink",
    draw = function(i, textSize)
        local rat = 1 / textSize
        return ashop.ui.FastColorTo(gradOP1, gradOP2, rat * i)
    end
}

ashop.titles.colors[21] = {
    name = "Crimson",
    draw = function(i, textSize)
        local rand = math.random(0, 2)

        if rand == 0 then
            return 192, 57, 43
        elseif rand == 1 then
            return 92, 39, 33
        else
            return 30, 30, 30
        end
    end
}

ashop.titles.colors[22] = {
    name = "Summer",
    draw = function(i, textSize)
        if i%3 == 0 then
            return 135, 206, 235
        elseif i%3 == 1 then
            return 220, 192, 139
        else
            return 255, 255, 255
        end
    end
}

local Hacking1 = Color(231, 240, 241)
local Hacking2 = Color(46, 204, 113)

ashop.titles.colors[23] = {
    name = "Hacking",
    draw = function(i, textSize)
        local odd = (i % 2 == 0) and 0x0000001 or 0x0000000
        local b = (cachedCurTime*20) % 10 < 5 and 0x0000001 or 0x0000000
        local cond = (bit.bxor(b, odd) == 0x0000001) and Hacking1 or Hacking2
    
        return cond.r, cond.g, cond.b
    end
}

ashop.titles.colors[24] = {
    name = "Uranium",
    draw = function(i, textSize)
        return 0, 147, 255
    end
}

// New
ashop.titles.colors[25] = {
    name = "Country - India",
    draw = function(i, textSize)
        local rat = 1 / textSize * i
        if rat < 0.33 then
            return 255,143,28
        elseif rat < 0.45 then
            return 255,255,255
        elseif rat < 0.55 then
            return 37,14,98
        elseif rat < 0.8 then
            return 255,255,255
        else
            return 80,158,47
        end
    end
}

ashop.titles.colors[26] = {
    name = "Country - China",
    draw = function(i, textSize)
        local rat = 1 / textSize * i
        if rat < 0.1 or rat > 0.4 then
            return 252, 227, 0
        else
            return 200, 16, 46
        end
    end
}

ashop.titles.colors[27] = {
    name = "Country - Japan",
    draw = function(i, textSize)
        local rat = 1 / textSize * i
        if rat < 0.33 or rat > 0.66 then
            return 255, 255, 255
        else
            return 239,51,64
        end
    end
}

ashop.titles.colors[28] = {
    name = "Country - Russian",
    draw = function(i, textSize)
        local rat = 1 / textSize * i
        if rat < 0.33 then
            return 255, 255, 255
        elseif rat < 0.66 then
            return 0, 114, 206
        else
            return 239, 51, 64
        end
    end
}