ashop.titles = ashop.titles or {
    styles = {},
    colors = {}
}

local function defaultEffect(text, color, xOffset, yOffset, textOriginal, topAlign, font)
    local textSize = #text
    surface.SetFont(font or "ashop_18")
    local w, h = surface.GetTextSize(textOriginal)
    local xOffset = xOffset or 0
    local yOffset = yOffset or 0

    surface.SetTextPos(xOffset - w/2, yOffset - (topAlign == TEXT_ALIGN_CENTER and h/2 or 0))

    for i = 1, textSize do
        if istable(color) then
            surface.SetTextColor(color)
        else
            local r, g, b, a = ashop.titles.colors[color].draw(i, textSize)
            surface.SetTextColor( r, g, b, a )
        end
        surface.DrawText( text[i] )
    end
end
ashop.titles.styles[0] = defaultEffect

local t = {}
local str = "A Cool Title"

for i = 1, string.len(str) do
    t[i] = utf8.sub(str, i, i )
end

// TODO: Custom fonts ?. Maybe in a update
function ashop.DrawTitle(text, color, effect, x, y, textOriginal, topAlign, font)
    effect = effect or defaultEffect
    effect(text or t, color or color_white, x, y, textOriginal or str, topAlign, font)
end