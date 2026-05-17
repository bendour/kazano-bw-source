Config = Config or {}
Config.Panels = Config.Panels or {}
Config.MaxDrawDistance = 1450 -- Distance max d'affichage des panneaux

-- Polices modernes
surface.CreateFont("LB_Title", {
    font = "Montserrat",
    size = 55,
    weight = 800,
    antialias = true
})

surface.CreateFont("LB_Rank", {
    font = "Montserrat",
    size = 38,
    weight = 700,
    antialias = true
})

surface.CreateFont("LB_Name", {
    font = "Roboto",
    size = 32,
    weight = 500,
    antialias = true
})

surface.CreateFont("LB_Value", {
    font = "Roboto Mono",
    size = 30,
    weight = 600,
    antialias = true
})

local panelData = {}

-- Couleurs modernes
local colors = {
    bg = Color(15, 15, 25, 240),
    bgAlt = Color(25, 25, 40, 240),
    border = Color(60, 60, 80, 255),
    gold = Color(255, 215, 0),
    silver = Color(192, 192, 192),
    bronze = Color(205, 127, 50),
    text = Color(240, 240, 250),
    textDim = Color(150, 150, 170),
    accent = Color(100, 120, 255)
}

-- Fonction pour dessiner une médaille (cercle parfait)
local function DrawMedal(x, y, radius, rank)
    local medalColors = {
        [1] = {outer = Color(255, 215, 0), inner = Color(255, 235, 100)},
        [2] = {outer = Color(192, 192, 192), inner = Color(230, 230, 230)},
        [3] = {outer = Color(205, 127, 50), inner = Color(235, 170, 100)}
    }
    
    if medalColors[rank] then
        local c = medalColors[rank]
        local segments = 32
        
        -- Cercle extérieur
        draw.NoTexture()
        surface.SetDrawColor(c.outer)
        local outerPoly = {}
        for i = 0, segments do
            local ang = math.rad((i / segments) * 360)
            table.insert(outerPoly, {x = x + math.cos(ang) * radius, y = y + math.sin(ang) * radius})
        end
        surface.DrawPoly(outerPoly)
        
        -- Cercle intérieur
        surface.SetDrawColor(c.inner)
        local innerRadius = radius * 0.7
        local innerPoly = {}
        for i = 0, segments do
            local ang = math.rad((i / segments) * 360)
            table.insert(innerPoly, {x = x + math.cos(ang) * innerRadius, y = y + math.sin(ang) * innerRadius})
        end
        surface.DrawPoly(innerPoly)
        
        -- Numéro
        draw.SimpleText(tostring(rank), "LB_Rank", x, y, Color(50, 50, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

net.Receive("Update3D2DPanels", function()
    panelData = net.ReadTable()
end)

local titleMapping = {
    ["Top Kills"] = "KILLS",
    ["Top Prestige"] = "PRESTIGE",
    ["Top Time Played"] = "PLAYTIME",
    ["Top Votes"] = "VOTES"
}

hook.Add("PostDrawOpaqueRenderables", "Draw3D2DPanels", function()
    if not panelData or table.IsEmpty(panelData) then return end
    if not Config.Panels or #Config.Panels == 0 then return end

    local plyPos = LocalPlayer():GetPos()
    local maxDist = Config.MaxDrawDistance or 1450

    for _, panel in ipairs(Config.Panels) do
        if plyPos:DistToSqr(panel.pos) > (maxDist ^ 2) then
            continue
        end

        cam.Start3D2D(panel.pos, panel.ang, 0.2)
            local panelWidth = 850
            local panelHeight = 520
            local headerHeight = 70
            local rowHeight = 42
            local padding = 25
            
            local startX = -panelWidth / 2
            local startY = -80

            -- Fond principal avec effet glass
            draw.RoundedBox(16, startX, startY, panelWidth, panelHeight, colors.bg)

            -- Header avec accent coloré
            local accentColor = panel.titleColor or colors.accent
            draw.RoundedBoxEx(16, startX, startY, panelWidth, headerHeight, accentColor, true, true, false, false)
            
            -- Ligne de séparation sous le header
            surface.SetDrawColor(ColorAlpha(color_white, 30))
            surface.DrawRect(startX + padding, startY + headerHeight - 1, panelWidth - padding * 2, 1)

            -- Titre
            local displayTitle = titleMapping[panel.title] or panel.title
            draw.SimpleText(displayTitle, "LB_Title", 0, startY + headerHeight / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            -- Contenu
            local key = panel.title:match("Top (.+)"):lower():gsub(" ", "_")
            if panelData[key] then
                for i, v in ipairs(panelData[key]) do
                    local value = v.kills or v.prestige or v.monthly_votes or (v.time_played and BaseWars:FormatTime2(v.time_played, true)) or "N/A"
                    BaseWars:RequestSteamName(v.player_id64)
                    local playername = BaseWars:GetSteamName(v.player_id64) or "Unknown"
                    
                    local rowY = startY + headerHeight + padding + (i - 1) * rowHeight
                    
                    -- Fond alterné pour les lignes
                    if i % 2 == 0 then
                        draw.RoundedBox(8, startX + padding / 2, rowY - 5, panelWidth - padding, rowHeight - 2, colors.bgAlt)
                    end
                    
                    -- Couleur du rang selon la position
                    local rankColor = colors.text
                    if i == 1 then rankColor = colors.gold
                    elseif i == 2 then rankColor = colors.silver
                    elseif i == 3 then rankColor = colors.bronze
                    end
                    
                    -- Rang avec médaille pour top 3, sinon numéro
                    if i <= 3 then
                        DrawMedal(startX + padding + 30, rowY + rowHeight / 2 - 8, 18, i)
                    else
                        draw.SimpleText("#" .. i, "LB_Rank", startX + padding + 30, rowY + rowHeight / 2 - 8, colors.textDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                    
                    -- Nom du joueur
                    draw.SimpleText(playername, "LB_Name", startX + padding + 80, rowY + rowHeight / 2 - 8, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    
                    -- Valeur avec style
                    draw.SimpleText(tostring(value), "LB_Value", startX + panelWidth - padding - 20, rowY + rowHeight / 2 - 8, accentColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end
            end
            
            -- Footer décoratif
            surface.SetDrawColor(ColorAlpha(accentColor, 100))
            surface.DrawRect(startX + padding, startY + panelHeight - 25, panelWidth - padding * 2, 2)
            
        cam.End3D2D()
    end
end)
