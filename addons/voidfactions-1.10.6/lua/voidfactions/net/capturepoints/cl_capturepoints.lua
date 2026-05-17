
-- Functions

function VoidFactions.CapturePoints:CreatePoint(pos, radius)
    net.Start("VoidFactions.CapturePoints.CreateCapturePoint")
        net.WriteUInt(radius, 16)
        net.WriteVector(pos)
    net.SendToServer()
end

function VoidFactions.CapturePoints:DeletePoint(point)
    net.Start("VoidFactions.CapturePoints.DeleteCapturePoint")
        net.WriteUInt(point.id, 6)
    net.SendToServer()
end

-- Net handlers

net.Receive("VoidFactions.CapturePoints.UpdateCapturePoint", function (len, ply)
    local enum = net.ReadUInt(3)
    local pointId = net.ReadUInt(6)

    local point = VoidFactions.PointsTable[pointId]
    if (!point) then
        VoidFactions.PrintError("Received capture point update, but point not found!")
        return
    end

    if (enum == VoidFactions.CapturePoints.UpdateEnums.CAPTURE_FACTIONCHANGE) then
        local factionId = net.ReadUInt(20)
        local captureStart = net.ReadFloat()
        local captureEnd = net.ReadFloat()

        local faction = VoidFactions.LoadedFactions[factionId]
        if (!faction and factionId != 0) then
            VoidFactions.PrintError("Received capture point faction change, but faction not found!")
            return
        end


        point.capturingBy = faction
        point.captureStart = captureStart
        point.captureEnd = captureEnd
        if (!faction) then
            point.captureInProgress = false
        end
    end

    if (enum == VoidFactions.CapturePoints.UpdateEnums.POINT_CONTESTED) then
        local isContested = net.ReadBool()
        point.isContested = isContested

        if (isContested) then
            point.pauseTime = CurTime()
        else
            local secsFromStart = point.pauseTime - point.captureStart
            local totalDuration = point.captureEnd - point.captureStart
            point.captureEnd = CurTime() + totalDuration - secsFromStart
        end
    end

    if (enum == VoidFactions.CapturePoints.UpdateEnums.POINT_PAUSED) then
        local isPaused = net.ReadBool()

        local endTime = nil
        local pauseTime = nil

        if (!isPaused) then
            -- We need to change the end time
            local endTime = net.ReadFloat()
            point.captureEnd = endTime
        else
            point.pauseTime = CurTime()
        end

        point.isPaused = isPaused
    end

    if (enum == VoidFactions.CapturePoints.UpdateEnums.CAPTURE_CHANGE) then
        
		local captureStart = net.ReadBool()

        -- We need to receive the time from the server, because the net message arrives later.
        local startTime = nil
        local endTime = nil
        local factionId = nil
        if (captureStart) then
            startTime = net.ReadFloat()
            endTime = net.ReadFloat()
            factionId = net.ReadUInt(20)
        end

        local faction = VoidFactions.LoadedFactions[factionId]
        if (captureStart and !faction) then
            VoidFactions.PrintError("Received capture point start, but faction not found!")
            return
        end

        point.captureInProgress = captureStart
        point.capturingBy = faction

        point.captureStart = startTime
        point.captureEnd = endTime
        point.isPaused = false
        point.isContested = false
    end

    if (enum == VoidFactions.CapturePoints.UpdateEnums.CAPTURE_RESULT) then
        local factionId = net.ReadUInt(20)

        local faction = VoidFactions.LoadedFactions[factionId]
        if (!faction and factionId != 0) then
            VoidFactions.PrintError("Received capture point result, but faction not found!")
            return
        end

        point.captureInProgress = false 
        point.captureStart = nil
        point.capturingBy = nil
        point.captureFaction = faction
        point.isPaused = false
        point.isContested = false
    end
end)

net.Receive("VoidFactions.CapturePoints.SyncCapturePoints", function (len, ply)
    local count = net.ReadUInt(6)

    local updatedPoints = {}
    for i = 1, count do
        local point = VoidFactions.CapturePoints:ReadCapturePoint()
        updatedPoints[point.id] = true
    end

    for k, v in pairs(VoidFactions.PointsTable) do
        if (!updatedPoints[k]) then
            VoidFactions.PointsTable[k] = nil
        end
    end

end)