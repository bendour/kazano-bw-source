surface.CreateFont("CustomHUD", {
    font = "Arial", 
    size = 20, 
    weight = 800,
    antialias = true
})

hook.Add("HUDPaint", "DrawDateTimeTopLeft", function()
    local time = os.date("%H:%M") -- Format de l'heure (heures:minutes)
    local date = os.date("%d/%m/%Y") -- Format de la date (jour/mois/année)
    local text = time .. " - " .. date -- Format final
    
    draw.SimpleText(text, "CustomHUD", 10, 5, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end)