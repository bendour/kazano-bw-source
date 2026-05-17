if (not SERVER) then return end
zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

function zmlab.f.Frezzer_Initialize(Frezzer)
    zmlab.f.Debug("zmlab.f.Frezzer_Initialize")

    zmlab.f.EntList_Add(Frezzer)

    Frezzer:SetUsedPositions(0)

    Frezzer.LastAction = -1

    Frezzer.TrayTable = {}
    Frezzer.TrayTable[1] = "empty"
    Frezzer.TrayTable[2] = "empty"
    Frezzer.TrayTable[3] = "empty"
    Frezzer.TrayTable[4] = "empty"
    Frezzer.TrayTable[5] = "empty"

    timer.Simple(0.1, function()
        if IsValid(Frezzer) then
            for i = 1, 5 do
                local tray = zmlab.f.Frezzer_CreateProp(Frezzer, "zmlab_frezzingtray", Frezzer:GetPos(), Frezzer:GetAngles())
                zmlab.f.Frezzer_AddTray(Frezzer, tray, i)
            end
        end
    end)
end

function zmlab.f.Frezzer_USE(Frezzer, ply)
    zmlab.f.Debug("zmlab.f.Frezzer_USE")

    if Frezzer.LastAction > CurTime() then return end
    if not zmlab.f.IsOwner(ply, Frezzer) then return end

    if not zmlab.f.Frezzer_RemoveMethTray(Frezzer) then
        Frezzer.LastAction = CurTime() + 0.25
        zmlab.f.Frezzer_RemoveEmptyTray(Frezzer)
    end
end

function zmlab.f.Frezzer_StartTouch(Frezzer, other)
    if not IsValid(Frezzer) then return end
    if Frezzer.LastAction > CurTime() then return end

    if Frezzer:GetUsedPositions() >= 5 then return end
    if not IsValid(other) then return end
    if other:GetClass() ~= "zmlab_frezzingtray" then return end
    if zmlab.f.CollisionCooldown(other) then return end
    zmlab.f.Debug("zmlab.f.Frezzer_StartTouch")
    Frezzer.LastAction = CurTime() + 0.25

    if other.STATE == "SLUDGE" or other.STATE == "EMPTY" then
        local traypos = zmlab.f.Frezzer_FindEmptyTrayPos(Frezzer)

        if traypos then
            timer.Simple(0, function()
                if IsValid(Frezzer) then
                    zmlab.f.Frezzer_AddTray(Frezzer, other, traypos)
                end
            end)
        end
    end
end

function zmlab.f.Frezzer_OnRemove(Frezzer)
    zmlab.f.Debug("zmlab.f.Frezzer_OnRemove")
end


///////////////// Setup /////////////////
function zmlab.f.Frezzer_CreateProp(Frezzer, class, pos, ang)
    local ent = ents.Create(class)
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:Spawn()
    ent:Activate()
    Frezzer:DeleteOnRemove(ent)
    zmlab.f.SetOwner(ent, zmlab.f.GetOwner(Frezzer))

    return ent
end
/////////////////////////////////////////




/////////////// MAIN LOGIC ///////////////
function zmlab.f.Frezzer_AddTray(Frezzer, tray, Pos)
    zmlab.f.Debug("zmlab.f.Frezzer_AddTray")
    Frezzer:SetUsedPositions(Frezzer:GetUsedPositions() + 1)
    DropEntityIfHeld(tray)

    local attach = Frezzer:GetAttachment(Frezzer:LookupAttachment("row0" .. Pos))
    tray:SetPos(attach.Pos + Frezzer:GetUp() * -2 + Frezzer:GetRight() * 9)
    tray:SetAngles(Frezzer:GetAngles())
    tray:SetParent(Frezzer, attach)

    Frezzer.TrayTable[Pos] = tray

    tray.PhysgunDisable = true
    tray.InFrezzer = true

    if tray.STATE == "SLUDGE" and Frezzer:GetIsFreezing() == false then
        zmlab.f.Frezzer_StartFrezzingTimer(Frezzer)
    end
end

function zmlab.f.Frezzer_FindEmptyTrayPos(Frezzer)
    local freeTrail

    for i = 1, table.Count(Frezzer.TrayTable) do
        if Frezzer.TrayTable[i] == "empty" then
            freeTrail = i
            break
        end
    end

    if freeTrail then
        return freeTrail
    else
        return false
    end
end

function zmlab.f.Frezzer_RemoveTray(Frezzer, tray, trPos)

    Frezzer.TrayTable[trPos] = "empty"
    Frezzer:SetUsedPositions(Frezzer:GetUsedPositions() - 1)

    tray.PhysgunDisable = false
    tray.InFrezzer = false

    tray:SetParent(nil)
    tray:SetPos(Frezzer:GetPos() + Frezzer:GetUp() * 15 + Frezzer:GetRight() * 45 + Frezzer:GetUp() * (5 * trPos))
    tray:SetAngles(Frezzer:GetAngles())

    local phys = tray:GetPhysicsObject()
    if IsValid(tray) then
        phys:Wake()
        phys:EnableMotion(true)
        phys:SetAngleDragCoefficient(2)
    end

end

function zmlab.f.Frezzer_RemoveMethTray(Frezzer)
    for k, v in pairs(Frezzer.TrayTable) do
        if (v ~= "empty" and IsValid(v) and v.STATE == "METH") then
            zmlab.f.Frezzer_RemoveTray(Frezzer, v, k)

            return true
        end
    end
end

function zmlab.f.Frezzer_RemoveEmptyTray(Frezzer)
    for k, v in pairs(Frezzer.TrayTable) do
        if (v ~= "empty" and IsValid(v) and v.STATE == "EMPTY") then
            zmlab.f.Frezzer_RemoveTray(Frezzer, v, k)

            return true
        end
    end
end


function zmlab.f.Frezzer_StartFrezzingTimer(Frezzer)
    zmlab.f.Debug("zmlab.f.Frezzer_StartFrezzingTimer")

    Frezzer:SetIsFreezing(true)

    local timerID = "zmlab_frezzer_FrezzeTray_" .. Frezzer:EntIndex() .. "_timer"

    zmlab.f.Timer_Create(timerID, zmlab.config.Freezer.Freeze_Inerval, 0, function()
        if IsValid(Frezzer) then
            zmlab.f.Frezzer_FrezzingProcessor(Frezzer)
        else
            zmlab.f.Timer_Remove(timerID)
        end
    end)
end

function zmlab.f.Frezzer_FrezzingProcessor(Frezzer)
    local IsFreezing = false
    for k, v in pairs(Frezzer.TrayTable) do
        if v ~= "empty" and IsValid(v) and v.STATE == "SLUDGE" then
            if (v:GetFrezzingProgress() < zmlab.config.Freezer.Freeze_Time) then
                IsFreezing = true
                v:SetFrezzingProgress(v:GetFrezzingProgress() + 1)
            else
                zmlab.f.FreezingTray_ConvertSludge(v)
            end
        end
    end

    if IsFreezing == false then
        zmlab.f.Frezzer_StopFrezzingTimer(Frezzer)
    end
end

function zmlab.f.Frezzer_StopFrezzingTimer(Frezzer)
    zmlab.f.Debug("zmlab.f.Frezzer_StopFrezzingTimer")
    local timerID = "zmlab_frezzer_FrezzeTray_" .. Frezzer:EntIndex() .. "_timer"
    zmlab.f.Timer_Remove(timerID)

    Frezzer:SetIsFreezing(false)
end


//////////////////////////////////////////
