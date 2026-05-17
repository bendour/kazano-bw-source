if CLIENT then return end
zrush = zrush or {}
zrush.DrillpipeHolder = zrush.DrillpipeHolder or {}

function zrush.DrillpipeHolder.Initialize(DrillpipeHolder)
    zclib.EntityTracker.Add(DrillpipeHolder)
end

function zrush.DrillpipeHolder.OnRemove(DrillpipeHolder)
    zclib.EntityTracker.Remove(DrillpipeHolder)
end

function zrush.DrillpipeHolder.OnTouch(DrillpipeHolder, other)
    zclib.Debug("zrush.DrillpipeHolder.OnTouch")
    if not IsValid(DrillpipeHolder) then return end
    if not IsValid(other) then return end
    if other:GetClass() ~= "zrush_drillpipe_holder" then return end
    if zclib.util.CollisionCooldown(other) then return end

	if zclib.Entity.GettingRemoved(other) then return end

    if DrillpipeHolder.NextMerge and CurTime() < DrillpipeHolder.NextMerge then return end
    DrillpipeHolder.NextMerge = CurTime() + 1
	other.NextMerge = CurTime() + 1

    local countA = DrillpipeHolder:GetPipeCount()
    local countB = other:GetPipeCount()

    local FreeSpace = 10 - countA
    if FreeSpace <= 0 then return end

    local MoveAmount = math.Clamp(countB, 0, FreeSpace)

    other:SetPipeCount(countB - MoveAmount)
    if other:GetPipeCount() <= 0 then
        DropEntityIfHeld(other)
        zclib.Entity.SafeRemove(other)
    end

    DrillpipeHolder:SetPipeCount(countA + MoveAmount)
end
