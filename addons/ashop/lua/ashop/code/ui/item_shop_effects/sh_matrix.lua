ashop.itemShopEffects = ashop.itemShopEffects or {}
ashop.itemShopEffects[2] = ashop.itemShopEffects[2] or {}

// ty to https://wiki.facepunch.com/gmod/string.char
local function randStr( length )
	local length = tonumber( length )
    if length < 1 then return end

    local result = {}

    for i = 1, length do
        result[i] = string.char( math.random(32, 126) )
    end
    return table.concat(result)
end

ashop.itemShopEffects[2].preDraw = function(pnl, w, h, equipped, clr)
    pnl.rarity_clr10 = pnl.rarity_clr10 or ColorAlpha(clr, 10)
    surface.SetDrawColor(pnl.rarity_clr10)
    surface.DrawRect(0, 0, w, h)

    local split = math.ceil(w/16)
    if !pnl.unpackedClrR then
        local c = Color(clr.r, clr.g, clr.b)
        local h, s, v = ColorToHSV(c)
        s = s + 0.1
        v = v + 0.1

        c = HSVToColor(h, s, v)

        pnl.unpackedClrR, pnl.unpackedClrG, pnl.unpackedClrB = c.r, c.g, c.b
        pnl.textList = {}
        pnl.lastTick = 0
    end

    local frameTime = UnPredictedCurTime()*10
    local c = math.floor(frameTime, 2)

    if pnl.lastTick < c then
        pnl.lastTick = c+1

        // spawn a text
        // We don't want to try a lot, if there no free slots, np
        for i=1, 5 do
            local r = math.random(1, split)

            if !pnl.textList[r] then
                local rT = math.random(6, 20)
                pnl.textList[r] = {randStr(rT), 255 / (rT - 4), frameTime}
                break
            end
        end
    end

    for k, v in pairs(pnl.textList) do
        surface.SetFont("ashop_16")
        for i=1, #v[1] do
            local hY = (frameTime - v[3])*16 - i*16
            surface.SetTextPos(k * split, hY)

            if i == 1 then
                surface.SetTextColor(255, 255, 255)
            else
                surface.SetTextColor(pnl.unpackedClrR, pnl.unpackedClrG, pnl.unpackedClrB, 255 - (i * v[2]))
            end

            surface.DrawText(v[1][i])
        end

        local _, hT = surface.GetTextPos()
        if hT > h then
            pnl.textList[k] = nil
        end
    end
end