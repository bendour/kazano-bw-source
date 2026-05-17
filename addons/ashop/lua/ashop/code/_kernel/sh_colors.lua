function ashop.GetColor(name, alpha)
    local clr = ashop.Config.colors[name]
    return alpha and ColorAlpha(clr, alpha) or clr
end