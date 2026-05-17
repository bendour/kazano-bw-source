if (not SERVER) then return end
zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

function zmlab.f.FreezingTray_Initialize(FreezingTray)
    zmlab.f.Debug("zmlab.f.FreezingTray_Initialize")
    zmlab.f.EntList_Add(FreezingTray)
    FreezingTray.STATE = "EMPTY"
    FreezingTray.InFrezzer = false
    FreezingTray.BreakState = 0
end

function zmlab.f.FreezingTray_USE(FreezingTray, ply)
    zmlab.f.Debug("zmlab.f.FreezingTray_USE")
    if FreezingTray.InFrezzer then return end
    if not zmlab.f.IsOwner(ply, FreezingTray) then return end

    if FreezingTray.STATE == "METH" then
        FreezingTray.BreakState = FreezingTray.BreakState + 1

        local tr = ply:GetEyeTrace()
        if tr and tr.Hit and tr.HitPos then
            zmlab.f.CreateNetEffect("zmlab_breakice",tr.HitPos)
        end


        if FreezingTray.BreakState == 3 then
            zmlab.f.FreezingTray_EmptyTray(FreezingTray,ply)
        elseif FreezingTray.BreakState == 2 then
            FreezingTray:SetSkin(3)
        elseif FreezingTray.BreakState == 1 then
            FreezingTray:SetSkin(2)
        end
    end
end


/////////////// MAIN LOGIC ///////////////
function zmlab.f.FreezingTray_AddSludge(FreezingTray, amount)
    if FreezingTray.STATE ~= "SLUDGE" then
        FreezingTray:SetBodygroup(0, 1)
        FreezingTray.STATE = "SLUDGE"
    end

    FreezingTray:SetInBucket(FreezingTray:GetInBucket() + amount)
end

function zmlab.f.FreezingTray_ConvertSludge(FreezingTray)
    FreezingTray:SetBodygroup(0, 2)
    FreezingTray:SetSkin(1)
    FreezingTray.STATE = "METH"
    FreezingTray:SetInBucket(FreezingTray:GetInBucket() * (1 - zmlab.config.Freezer.MethFreezeLoss))

    zmlab.f.CreateNetEffect("zmlab_tray_convert",FreezingTray)
end

function zmlab.f.FreezingTray_EmptyTray(FreezingTray, ply)
    local meth = ents.Create("zmlab_meth")
    meth:SetPos(FreezingTray:GetPos() + Vector(1, 1, 15))
    meth:SetAngles(FreezingTray:GetAngles())
    meth:Spawn()
    meth:Activate()

    zmlab.f.SetOwner(meth, zmlab.f.GetOwner(FreezingTray))

    local methAmount = FreezingTray:GetInBucket() * (1 - zmlab.config.FreezingTray.MethBreakLoss)
    meth:SetMethAmount(math.Round(methAmount))

    constraint.NoCollide(meth, FreezingTray, 0, 0)

    FreezingTray:SetBodygroup(0, 0)
    FreezingTray:SetSkin(0)
    FreezingTray.STATE = "EMPTY"
    FreezingTray:SetInBucket(0)
    FreezingTray:SetFrezzingProgress(0)
    FreezingTray.BreakState = 0

    hook.Run("zmlab_OnMethMade", ply, FreezingTray, meth)
end
//////////////////////////////////////////
