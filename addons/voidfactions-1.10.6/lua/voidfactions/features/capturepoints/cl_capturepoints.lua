VoidFactions.PointsTable = VoidFactions.PointsTable or {}
VoidFactions.CapturePoints = VoidFactions.CapturePoints or {}
VoidFactions.CapturePoints.ActivePoint = VoidFactions.CapturePoints.ActivePoint or nil

local L = VoidFactions.Lang.GetPhrase
local sc = VoidUI.Scale

local localPlayer = localPlayer or nil
local localPlayerValid = localPlayerValid or false

local cachedDistances = cachedDistances or {}


-- Functions

function VoidFactions.CapturePoints:DrawLogo(capLogo, capColor, rectX, rectY, rectSize, iconX, iconY, iconSize, captureInProgress, capturingFaction, arcAngle)
    VoidLib.FetchImage(capLogo or "", function (mat)
        draw.RoundedBox(8, rectX, rectY, rectSize, rectSize, capColor)

        if (mat) then
            surface.SetDrawColor(color_white)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)
        end

        if (captureInProgress) then
            VoidLib.FetchImage(capturingFaction.logo or "", function (mat2)
                if (!mat2) then return end

                VoidUI.StencilMaskStart()
                    draw.NoTexture()
                    VoidUI.DrawArc(rectX+rectSize/2, rectY+rectSize/2, 50, 0, math.Clamp(arcAngle, 0, 360), 1)
                VoidUI.StencilMaskApply()
                    draw.RoundedBox(8, rectX, rectY, rectSize, rectSize, capturingFaction.color or VoidUI.Colors.Black)

                    surface.SetDrawColor(VoidUI.Colors.White)
                    surface.SetMaterial(mat2)
                    surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)
                VoidUI.StencilMaskEnd()
                
            end, true)
        end
    end, true)
end

hook.Add("InitPostEntity", "VoidFactions.CapturePoints.LocalPlayerInit", function ()
    localPlayerValid = true
end)

-- Timers

timer.Create("VoidFactions.CapturePoints.PrecacheDistances", 0.2, 0, function ()
    if (!VoidFactions.Config.ShowPointDistances) then return end
    if (!localPlayerValid) then return end

    if (!localPlayer) then
        localPlayer = LocalPlayer()
    end

    for id, point in pairs(VoidFactions.PointsTable) do
        local sqrDist = VoidFactions.Config.CapturePointRenderDistance * VoidFactions.Config.CapturePointRenderDistance
        if (localPlayer:GetPos():DistToSqr(point.pos) > sqrDist) then continue end

        local dist = localPlayer:GetPos():Distance(point.pos)
        cachedDistances[point.id] = math.Round(dist)
    end
end)

timer.Create("VoidFactions.CapturePoints.UIActivator", 0.5, 0, function ()
    if (!localPlayerValid) then return end
    if (!localPlayer) then
        localPlayer = LocalPlayer()
    end

    local activePoint = nil
    for id, point in pairs(VoidFactions.PointsTable) do
        local sqrDist = point.radius * point.radius
        if (localPlayer:GetPos():DistToSqr(point.pos) > sqrDist) then continue end

        activePoint = point
    end

    VoidFactions.CapturePoints.ActivePoint = activePoint
end)

-- Hooks

hook.Add("HUDPaint", "VoidFactions.CapturePoints.HUDOverlay", function ()
    if (!localPlayerValid) then return end

    local point = VoidFactions.CapturePoints.ActivePoint
    if (!point) then return end

    local isCaptured = point.captureFaction and true or false
    local captureInProgress = point.captureInProgress

    local capturingFaction = point.capturingBy

    local capName = isCaptured and point.captureFaction.name or L"notClaimed"
    local capLogo = isCaptured and point.captureFaction.logo or "MIZ89WN"
    local capColor = isCaptured and point.captureFaction.color or VoidUI.Colors.White

    local captureStart = point.captureStart or 0
    local captureEnd = point.captureEnd or 0

    local iconSize = sc(60)
    local iconPadding = 4

    local center = ScrW() / 2

    local iconX = center + -iconSize/2
    local iconY = sc(30)

    local rectX = iconX - iconPadding
    local rectY = iconY - iconPadding

    local rectSize = iconSize + iconPadding*2

    local isContested = point.isContested

    local curTime = ((isPaused or isContested) and point.pauseTime) or CurTime()

    local capturePercentage = math.min(captureInProgress and (curTime - captureStart) / (captureEnd - captureStart) or 0, 1)
    local arcAngle = capturePercentage * 360

    local totalTime = captureEnd - captureStart
    local elapsedTime = capturePercentage * totalTime
    local timeLeft = math.floor(totalTime - elapsedTime)
    timeLeft = math.max(timeLeft, 0)

    VoidFactions.CapturePoints:DrawLogo(capLogo, capColor, rectX, rectY, rectSize, iconX, iconY, iconSize, captureInProgress, capturingFaction, arcAngle)

    surface.SetFont("VoidUI.R26")

    local capY = sc(100)
    local boxWidth, boxHeight = surface.GetTextSize(capName)
    boxWidth = boxWidth * 1.2
    boxHeight = boxHeight * 1.2

    local padding = 2

    if (captureInProgress) then
        draw.RoundedBox(6, center - boxWidth / 2, capY, boxWidth, boxHeight, VoidUI.Colors.Primary)
        draw.RoundedBox(6, center - boxWidth / 2, capY, boxWidth * capturePercentage, boxHeight, VoidUI.Colors.Red)

        draw.SimpleText(L"capturing", "VoidUI.R26", center, capY + boxHeight/2-1, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        draw.RoundedBox(6, center - boxWidth / 2, capY, boxWidth, boxHeight, capColor)
        draw.RoundedBox(6, center - boxWidth / 2 + padding, capY + padding, boxWidth - padding*2, boxHeight - padding*2, VoidUI.Colors.Primary)
        
        draw.SimpleText(capName, "VoidUI.R26", center, capY + boxHeight/2-1, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)

hook.Add("PostDrawTranslucentRenderables", "VoidFactions.Territories.Draw", function ()
    
    if (!localPlayerValid) then return end
    if (!localPlayer) then
        localPlayer = LocalPlayer()
    end

    local member = VoidFactions.PlayerMember
    if (!member) then return end

    local plyFaction = member.faction
    local rootFaction = plyFaction and plyFaction:GetRootFaction()

    -- Draw it seperately because we need different colors
    for id, point in pairs(VoidFactions.PointsTable) do
        local opponentCapturing = point.captureFaction == rootFaction and point.captureInProgress
        cam.IgnoreZ(opponentCapturing)

        local sqrDist = VoidFactions.Config.CapturePointRenderDistance * VoidFactions.Config.CapturePointRenderDistance
        if (!opponentCapturing and localPlayer:GetPos():DistToSqr(point.pos) > sqrDist) then continue end

        local textPos = Vector(point.pos.x, point.pos.y, point.pos.z + 250)

        local angle = Angle(0, EyeAngles().y, 0)
        angle:RotateAroundAxis(angle:Up(), -90)
        angle:RotateAroundAxis(angle:Forward(), 90)

        local isCaptured = point.captureFaction and true or false
        local captureInProgress = point.captureInProgress

        local capturingFaction = point.capturingBy

        local isContested = point.isContested

        local capName = isCaptured and point.captureFaction.name or L"notClaimed"
        local capLogo = isCaptured and point.captureFaction.logo or "MIZ89WN"
        local capColor = isCaptured and point.captureFaction.color or VoidUI.Colors.White

        local isPaused = point.isPaused

        local iconSize = 60
        local iconPadding = 2

        local iconX = -iconSize/2
        local iconY = 40

        
        local captureStart = point.captureStart or 0
        local captureEnd = point.captureEnd or 0

        local curTime = ( (isPaused or isContested) and point.pauseTime) or CurTime()

        local capturePercentage = math.min(captureInProgress and (curTime - captureStart) / (captureEnd - captureStart) or 0, 1)
        local arcAngle = capturePercentage * 360

        local unitsDist = nil
        local metersDist = nil

        if (VoidFactions.Config.ShowPointDistances) then
            unitsDist = cachedDistances[point.id] or localPlayer:GetPos():Distance(point.pos)
            metersDist = unitsDist * 1.905 / 100
            metersDist = math.floor(metersDist)
        end

        cam.Start3D2D(textPos, angle, 0.4)
            surface.SetFont("VoidUI.R38")

        
            if (VoidFactions.Config.ShowPointDistances) then
                capName = capName .. " (" .. metersDist .. "m)"
            end

            local rectX = iconX - iconPadding
            local rectY = iconY - iconPadding

            local rectSize = iconSize + iconPadding*2

            VoidFactions.CapturePoints:DrawLogo(capLogo, capColor, rectX, rectY, rectSize, iconX, iconY, iconSize, captureInProgress, capturingFaction, arcAngle)
            
            local capY = iconSize + 50
            local boxWidth, boxHeight = surface.GetTextSize(capName)
            boxWidth = boxWidth * 1.2
            boxHeight = boxHeight * 1.2

            local padding = 2

            draw.RoundedBox(6, -(boxWidth / 2), capY, boxWidth, boxHeight, capColor)
            draw.RoundedBox(6, -(boxWidth / 2) + padding, capY + padding, boxWidth - padding*2, boxHeight - padding*2, VoidUI.Colors.Primary)
                
            draw.SimpleText(capName, "VoidUI.R38", center, capY + boxHeight/2-1, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            capY = capY + 50

            if (captureInProgress) then

                local captureColor = (isPaused or isContested) and VoidUI.Colors.Orange or VoidUI.Colors.Red

                draw.RoundedBox(6, -(boxWidth / 2), capY, boxWidth, boxHeight, VoidUI.Colors.Primary)
                draw.RoundedBox(6, -(boxWidth / 2), capY, boxWidth * capturePercentage, boxHeight, captureColor)

                local text = isPaused and L"paused" or L"capturing"
                if (isContested) then
                    text = L"capturePointContested"
                end
                draw.SimpleText(text, "VoidUI.R38", center, capY + boxHeight/2-1, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

        cam.End3D2D()

        local color = point.isSelected and VoidUI.Colors.Blue or VoidUI.Colors.Red

        if (plyFaction and rootFaction) then
            if (point.captureFaction and point.captureFaction.id == rootFaction.id) then
                color = VoidUI.Colors.Green
            end 
        end

        if (plyFaction and captureInProgress and point.captureFaction and point.captureFaction.id == rootFaction.id) then
            color = VoidUI.Colors.Orange
        end

        VoidLib.StartWorldRings()
            VoidLib.AddWorldRing(point.pos, point.radius, 6, 40)
        VoidLib.FinishWorldRings(color)

        

    end
end)
