if (not SERVER) then return end
zmlab = zmlab or {}
zmlab.f = zmlab.f or {}


function zmlab.f.Combiner_Initialize(Combiner)
    zmlab.f.Debug("zmlab.f.Combiner_Initialize")

    zmlab.f.EntList_Add(Combiner)

    Combiner.LastAction = -1

    // How dirty is the machine
    Combiner.DirtLevel = 0

    // The Last Position the player cleaned
    Combiner.LastCleanPos = Vector(0, 0, 0)

    // Is the machine busy currently, this disables the player input and touch functions
    Combiner:SetIsBusy(false)

    // This will be the Filter Entity
    Combiner.InputModule = nil

    // This will be the tray entity
    Combiner.OutputModule = nil

    // Resets the Combiner and sets the new need Methly and Alum Values
    zmlab.f.Combiner_Reset(Combiner)
end

function zmlab.f.Combiner_SetBusy(Combiner,time)
    zmlab.f.Debug("zmlab.f.Combiner_SetBusy: " .. time)

    Combiner:SetIsBusy(true)

    timer.Simple(time,function()
        if IsValid(Combiner) then
            Combiner:SetIsBusy(false)
        end
    end)
end

function zmlab.f.Combiner_USE(Combiner, ply)
    if Combiner.LastAction > CurTime() then return end
    Combiner.LastAction = CurTime() + 0.25

    if Combiner:GetIsBusy() then return end
    zmlab.f.Debug("zmlab.f.Combiner_USE")

    if (Combiner:GetStage() == 8 and Combiner.DirtLevel > 0) then
        local HitPos_distance = ply:GetEyeTrace().HitPos:Distance(Combiner.LastCleanPos)

        if HitPos_distance > 15 then
            Combiner.LastCleanPos = ply:GetEyeTrace().HitPos
            zmlab.f.Combiner_CleanMachine(Combiner, ply)
        end
    end
end

function zmlab.f.Combiner_StartTouch(Combiner,other)
    if not IsValid(Combiner) then return end
    if Combiner:GetIsBusy() then return end
    if not IsValid(other) then return end
    if zmlab.f.CollisionCooldown(other) then return end
    zmlab.f.Debug("zmlab.f.Combiner_StartTouch")

    if Combiner.LastAction > CurTime() then return end
    Combiner.LastAction = CurTime() + 0.25

    local currentStage = Combiner:GetStage()


    if not IsValid(Combiner.InputModule) then

        if other:GetClass() == "zmlab_filter" and Combiner:GetHasFilter() == false then

            timer.Simple(0, function()
                if IsValid(Combiner) and IsValid(other) then
                    zmlab.f.Combiner_AttachFilter(Combiner, other)
                end
            end)

        elseif other:GetClass() == "zmlab_methylamin" and currentStage == 1 and Combiner:GetMethylamin() < Combiner:GetNeedMethylamin() then
            timer.Simple(0, function()
                if IsValid(Combiner) and IsValid(other) then
                    zmlab.f.Combiner_MethylaminLoader(Combiner, other)
                end
            end)

        elseif other:GetClass() == "zmlab_aluminium" and currentStage == 3 and Combiner:GetAluminium() < Combiner:GetNeedAluminium() then
            timer.Simple(0, function()
                if IsValid(Combiner) and IsValid(other) then
                    zmlab.f.Combiner_AluminiumLoader(Combiner, other)
                end
            end)
        end

    end


    if not IsValid(Combiner.OutputModule) and other:GetClass() == "zmlab_frezzingtray" and currentStage == 7 and other.STATE == "EMPTY" then
        timer.Simple(0, function()
            if IsValid(Combiner) and IsValid(other) then
                zmlab.f.Combiner_AddTray(Combiner,other)
            end
        end)
    end
end

function zmlab.f.Combiner_OnRemove(Combiner)
    zmlab.f.Debug("zmlab.f.Combiner_OnRemove")
    Combiner:StopParticles()
end





/////////////// MAIN LOGIC ///////////////
// Starts the Meth Prepare Timer
function zmlab.f.Combiner_PrepMethsludgeTimer_Start(Combiner)
    zmlab.f.Debug("zmlab.f.Combiner_PrepMethsludgeTimer_Start")

    zmlab.f.Combiner_PrepMethsludgeTimer_Stop(Combiner)

    local timerID = "zmlab_combiner_PrepMeth_" .. Combiner:EntIndex() .. "_timer"
    zmlab.f.Timer_Create(timerID, 1, 0, function()
        if not IsValid(Combiner) then return end
        // This calculates our MaxMethSludge depending on how long the filter is attached
        if zmlab.f.Combiner_FilterLogic(Combiner) then

            local MethPerFilter = zmlab.config.Combiner.MethperBatch / zmlab.config.Combiner.FilterProcessingTime

            if Combiner:GetMaxMethSludge() ~= zmlab.config.Combiner.MethperBatch then
                local maxMeth = math.Clamp(Combiner:GetMaxMethSludge() + MethPerFilter, 1, zmlab.config.Combiner.MethperBatch)
                Combiner:SetMaxMethSludge(maxMeth)
            end

            zmlab.f.Debug("Calculate MaxMethsludge: " .. Combiner:GetMaxMethSludge())
        end
    end)
end
// Stops the Meth Prepare Timer
function zmlab.f.Combiner_PrepMethsludgeTimer_Stop(Combiner)
    zmlab.f.Debug("zmlab.f.Combiner_PrepMethsludgeTimer_Stop")
    local timerID = "zmlab_combiner_PrepMeth_" .. Combiner:EntIndex() .. "_timer"
    zmlab.f.Timer_Remove(timerID)
end

// Starts the Finish Meth Timer
function zmlab.f.Combiner_FinishMethsludgeTimer_Start(Combiner)
    zmlab.f.Debug("zmlab.f.Combiner_FinishMethsludgeTimer_Start")

    zmlab.f.Combiner_FinishMethsludgeTimer_Stop(Combiner)

    local timerID = "zmlab_combiner_FinishMeth_" .. Combiner:EntIndex() .. "_timer"
    zmlab.f.Timer_Create(timerID, 1, 0, function()
        if not IsValid(Combiner) then return end
        // This creates our final Meth Sludge depending on MaxMethSludge
        if Combiner:GetMaxMethSludge() <= 0 then
            Combiner:SetMaxMethSludge(zmlab.config.Combiner.MethperBatch * zmlab.config.Filter.NoFilterPenalty)
        end

        if Combiner:GetMethSludge() < Combiner:GetMaxMethSludge() then
            zmlab.f.Debug("Calculate MethSludge: " .. Combiner:GetMethSludge())
            Combiner:SetMethSludge(math.Clamp(Combiner:GetMethSludge() + zmlab.config.Combiner.MethperBatch / zmlab.config.Combiner.FinishProcessingTime, 0, Combiner:GetMaxMethSludge()))
        else

            zmlab.f.Combiner_FinishMethsludgeTimer_Stop(Combiner)

            //This only gets called after we reach our MaxMethSludge
            zmlab.f.Combiner_NextStage(Combiner)
        end
    end)
end
// Stops the Finish Meth Timer
function zmlab.f.Combiner_FinishMethsludgeTimer_Stop(Combiner)
    zmlab.f.Debug("zmlab.f.Combiner_FinishMethsludgeTimer_Stop")
    local timerID = "zmlab_combiner_FinishMeth_" .. Combiner:EntIndex() .. "_timer"
    zmlab.f.Timer_Remove(timerID)
end


// Starts the Processing Timer
function zmlab.f.Combiner_StartTimer(Combiner,time)
    zmlab.f.Debug("zmlab.f.Combiner_StartTimer: " .. time)

    zmlab.f.Combiner_StopTimer(Combiner)

    zmlab.f.Timer_Create("zmlab_combiner_processing_" .. Combiner:EntIndex() .. "_timer",time,1,function()
        if not IsValid(Combiner) then return end
        zmlab.f.Combiner_StopTimer(Combiner)
        zmlab.f.Combiner_NextStage(Combiner)
    end)
end
// Stops the Processing Timer
function zmlab.f.Combiner_StopTimer(Combiner)
    zmlab.f.Debug("zmlab.f.Combiner_StopTimer")
    local timerID = "zmlab_combiner_processing_" .. Combiner:EntIndex() .. "_timer"
    zmlab.f.Timer_Remove(timerID)
end

function zmlab.f.Combiner_NextStage(Combiner)
    Combiner:SetStage(math.Clamp(Combiner:GetStage() + 1,1,8))
    local currentStage = Combiner:GetStage()

    zmlab.f.Debug("zmlab.f.Combiner_NextStage: " .. currentStage)

    if currentStage == 2 then
        // Sets the Start Prossesing Time for the UI
        Combiner:SetStartProcessingTime(CurTime())

        // Starts processign Timer
        zmlab.f.Combiner_StartTimer(Combiner,zmlab.config.Combiner.MixProcessingTime)

    elseif currentStage == 3 then

        Combiner:SetStartProcessingTime(0)

    elseif currentStage == 4 then
        // Sets the Start Prossesing Time for the UI
        Combiner:SetStartProcessingTime(CurTime())

        // Starts processign Timer
        zmlab.f.Combiner_StartTimer(Combiner,zmlab.config.Combiner.MixProcessingTime)

    elseif currentStage == 5 then

        // Sets the Start Prossesing Time for the UI
        Combiner:SetStartProcessingTime(CurTime())

        // Sets the length of the Processing Time for the UI
        Combiner:SetMaxProcessingTime(zmlab.config.Combiner.FilterProcessingTime)

        // Starts generating MaxMethsludge endless timer
        zmlab.f.Combiner_PrepMethsludgeTimer_Start(Combiner)

        // Starts processing timer with FilterTime, this triggers the NextStage
        zmlab.f.Combiner_StartTimer(Combiner,zmlab.config.Combiner.FilterProcessingTime + 1)

    elseif currentStage == 6 then
        // Stop MaxMethSludge Timer
        zmlab.f.Combiner_PrepMethsludgeTimer_Stop(Combiner)

        // Start Finish Methsludge Timer
        zmlab.f.Combiner_FinishMethsludgeTimer_Start(Combiner)

        // Resets SetStartProcessingTime to disable ui
        Combiner:SetStartProcessingTime(0)

    elseif currentStage == 8 and zmlab.config.Combiner.DirtAmount > 0 then

        zmlab.f.Combiner_DirtyMachine(Combiner)
    end
end

function zmlab.f.Combiner_Reset(Combiner)
    zmlab.f.Debug("zmlab.f.Combiner_Reset")
    Combiner:SetCleaningProgress(0)

    Combiner:SetAluminium(0)
    if zmlab.config.Aluminium.Random then
        Combiner:SetNeedAluminium(math.random(1, zmlab.config.Aluminium.Max))
    else
        Combiner:SetNeedAluminium(zmlab.config.Aluminium.Max)
    end

    Combiner:SetMethylamin(0)
    if zmlab.config.Methylamin.Random then
        Combiner:SetNeedMethylamin(math.random(1, zmlab.config.Methylamin.Max))
    else
        Combiner:SetNeedMethylamin(zmlab.config.Methylamin.Max)
    end

    Combiner:SetStage(1)
    Combiner:SetStartProcessingTime(0)
    Combiner:SetMaxProcessingTime(zmlab.config.Combiner.MixProcessingTime)
    Combiner:SetMethSludge(0)
    Combiner:SetMaxMethSludge(-1)
    Combiner:SetIsBusy(false)
end
//////////////////////////////////////////



/////////////// Loading Resources ////////

function zmlab.f.Combiner_MethylaminLoader(Combiner, ent)
    zmlab.f.Debug("zmlab.f.Combiner_MethylaminLoader")

    zmlab.f.Combiner_SetBusy(Combiner, 3.5)

    ent.PhysgunDisable = true
    Combiner.InputModule = ent
    DropEntityIfHeld(Combiner.InputModule)

    Combiner.InputModule:SetPos(Combiner:LocalToWorld(Vector(35,0,135)))
    Combiner.InputModule:SetParent(Combiner)
    Combiner.InputModule:SetAngles(Combiner:LocalToWorldAngles(Angle(0,0,180)))

    zmlab.f.CreateNetEffect("zmlab_combiner_load_liquid",Combiner.InputModule)

    timer.Simple(3, function()
        if IsValid(Combiner) then
            if IsValid(Combiner.InputModule) then
                Combiner.InputModule:Remove()
                Combiner.InputModule = nil
            end

            Combiner:SetMethylamin(Combiner:GetMethylamin() + 1)
            Combiner.InputModule = nil

            if Combiner:GetMethylamin() == Combiner:GetNeedMethylamin() then
                zmlab.f.Combiner_NextStage(Combiner)
            end
        end
    end)
end

function zmlab.f.Combiner_AluminiumLoader(Combiner, ent)
    zmlab.f.Debug("zmlab.f.Combiner_MethylaminLoader")

    zmlab.f.Combiner_SetBusy(Combiner, 3.5)

    ent.PhysgunDisable = true
    Combiner.InputModule = ent
    DropEntityIfHeld(Combiner.InputModule)

    Combiner.InputModule:SetPos(Combiner:LocalToWorld(Vector(44,0,110)))
    Combiner.InputModule:SetParent(Combiner)
    Combiner.InputModule:SetAngles(Combiner:LocalToWorldAngles(Angle(0,0,180)))

    zmlab.f.CreateNetEffect("zmlab_combiner_load_alum",Combiner.InputModule)

    timer.Simple(3, function()
        if IsValid(Combiner) then

            if IsValid(Combiner.InputModule) then
                Combiner.InputModule:Remove()
                Combiner.InputModule = nil
            end

            Combiner:SetAluminium(Combiner:GetAluminium() + 1)
            Combiner.InputModule = nil

            if Combiner:GetAluminium() == Combiner:GetNeedAluminium() then
                zmlab.f.Combiner_NextStage(Combiner)
            end
        end
    end)
end
//////////////////////////////////////////





/////////////// Filter Logic /////////////
function zmlab.f.Combiner_AttachFilter(Combiner, Filter)
    zmlab.f.Debug("zmlab.f.Combiner_AttachFilter")

    zmlab.f.Combiner_SetBusy(Combiner, 1)

    Combiner.InputModule = Filter

    DropEntityIfHeld(Filter)
    Filter.PhysgunDisable = true
    Filter:SetCombinerEnt(Combiner)

    local phys = Filter:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    end

    Filter:SetPos(Combiner:GetAttachment(Combiner:LookupAttachment("input")).Pos + Combiner:GetUp() * 7)
    Filter:SetAngles(Combiner:GetAngles())
    Filter:SetParent(Combiner)

    Combiner:SetHasFilter(true)
end

function zmlab.f.Combiner_DeattachFilter(Combiner, Filter, ply)
    zmlab.f.Debug("zmlab.f.Combiner_DeattachFilter")

    if IsValid(Filter) then
        Filter:SetParent(nil)
        Filter.PhysgunDisable = false

        if IsValid(ply) then
            Filter:SetPos(ply:GetPos() + ply:GetUp() * 10)
        end

        Filter:SetAngles(Combiner:GetAngles())

        local phys = Filter:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(true)
        end

        Filter:SetCombinerEnt(NULL)
    end
    Combiner.InputModule = nil
    Combiner:SetHasFilter(false)
end

function zmlab.f.Combiner_FilterLogic(Combiner)
    if Combiner:GetHasFilter() then

        zmlab.f.Filter_CheckHealth(Combiner.InputModule)
        return true
    else
        zmlab.f.Combiner_PoisenDamage(Combiner)

        return false
    end
end

function zmlab.f.Combiner_PoisenDamage(Combiner)
    if (zmlab.config.Filter.PoisenDamage <= 0) then return end
    zmlab.f.Debug("zmlab.f.Combiner_PoisenDamage")
    local pos = Combiner:GetPos()

    for k, v in pairs(zmlab_PlayerList) do
        if IsValid(v) and v:IsPlayer() and v:Alive() and zmlab.f.InDistance(v:GetPos(), pos, 150) then
            v:TakeDamage(zmlab.config.Filter.PoisenDamage, Combiner, Combiner)
        end
    end
end

//////////////////////////////////////////





/////////////// Tray Logic ///////////////
function zmlab.f.Combiner_AddTray(Combiner, tray)
    zmlab.f.Debug("zmlab.f.Combiner_AddTray")

    Combiner.OutputModule = tray
    DropEntityIfHeld(tray)

    local attachID = Combiner:LookupAttachment("effect03")
    local attach = Combiner:GetAttachment(attachID)

    Combiner:EmitSound("progress_fillingcrate")

    local pos = attach.Pos + attach.Ang:Up() * 13
    tray:SetPos(pos)

    local ang = Combiner:GetAngles()
    ang:RotateAroundAxis(Combiner:GetUp(), 180)
    tray:SetAngles(ang)

    tray:SetParent(Combiner)
    Combiner:SetHasTray(true)

    zmlab.f.Combiner_StartFillingTimer(Combiner)
end

function zmlab.f.Combiner_StartFillingTimer(Combiner)
    zmlab.f.Debug("zmlab.f.Combiner_StartFillingTimer")

    local timerID = "zmlab_combiner_FillTray_" .. Combiner:EntIndex() .. "_timer"

    zmlab.f.Timer_Create(timerID, zmlab.config.Combiner.Pump_Interval, 0, function()
        if not IsValid(Combiner) then
            zmlab.f.Combiner_StopFillingTimer(Combiner)
            return
        end

        if not IsValid(Combiner.OutputModule) then
            zmlab.f.Combiner_StopFillingTimer(Combiner)
            return
        end


        zmlab.f.Combiner_FillLogic(Combiner)
    end)
end

function zmlab.f.Combiner_StopFillingTimer(Combiner)
    zmlab.f.Debug("zmlab.f.Combiner_StopFillingTimer")
    local timerID = "zmlab_combiner_FillTray_" .. Combiner:EntIndex() .. "_timer"
    zmlab.f.Timer_Remove(timerID)
end

function zmlab.f.Combiner_FillLogic(Combiner)

    zmlab.f.Debug("zmlab.f.Combiner_FillLogic")
    // 206725927
    local tray = Combiner.OutputModule

    if Combiner:GetMethSludge() > 0 then

        // Does the Tray have more room for MethSludge?
        if tray:GetInBucket() < zmlab.config.FreezingTray.Capacity then

            // Fill Tray
            zmlab.f.FreezingTray_AddSludge(tray, zmlab.config.Combiner.Pump_Amount)
            Combiner:SetMethSludge(math.Clamp(Combiner:GetMethSludge() - zmlab.config.Combiner.Pump_Amount,0,zmlab.config.Combiner.MethperBatch))
        else
            // Tray is full

            // Stop Fill Timer
            zmlab.f.Combiner_StopFillingTimer(Combiner)

            // Drop Tray
            zmlab.f.Combiner_DropTray(Combiner, tray)
        end
    else
        // No MethSludge in Machine anymore

        // Stop Fill Timer
        zmlab.f.Combiner_StopFillingTimer(Combiner)

        // Drop Tray
        zmlab.f.Combiner_DropTray(Combiner, tray)

        // Can machine get dirty?
        if zmlab.config.Combiner.DirtAmount > 0 then
            // Make it dirty
            zmlab.f.Combiner_NextStage(Combiner)
        else
            // Reset Machine
            zmlab.f.Combiner_Reset(Combiner)
        end
    end
end

function zmlab.f.Combiner_DropTray(Combiner, tray)
    zmlab.f.Debug("zmlab.f.Combiner_DropTray")

    tray:SetParent(nil)
    tray:SetPos(Combiner:GetAttachment(Combiner:LookupAttachment("effect03")).Pos + Combiner:GetForward() * -50)

    tray:PhysicsInit(SOLID_VPHYSICS)
    tray:SetSolid(SOLID_VPHYSICS)
    tray:SetMoveType(MOVETYPE_VPHYSICS)
    local phys = tray:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(true)
    end

    Combiner.OutputModule = nil
    Combiner:SetHasTray(false)
end
//////////////////////////////////////////







/////////////// Dirt Logic ///////////////
function zmlab.f.Combiner_DirtyMachine(Combiner)
    Combiner.DirtLevel = zmlab.config.Combiner.DirtAmount
    zmlab.f.Debug("zmlab.f.Combiner_DirtyMachine: " .. Combiner.DirtLevel)
    zmlab.f.Combiner_CheckDirtLevel(Combiner)
    Combiner:SetCleaningProgress(Combiner.DirtLevel)
end

function zmlab.f.Combiner_CheckDirtLevel(Combiner)
    zmlab.f.Debug("zmlab.f.Combiner_CheckDirtLevel")

    if (Combiner.DirtLevel <= 0) then
        zmlab.f.Combiner_Reset(Combiner)
        Combiner:SetSkin(0)
    elseif (Combiner.DirtLevel <= zmlab.config.Combiner.DirtAmount * 0.3) then
        Combiner:SetSkin(1)
    elseif (Combiner.DirtLevel <= zmlab.config.Combiner.DirtAmount * 0.7) then
        Combiner:SetSkin(2)
    elseif (Combiner.DirtLevel == zmlab.config.Combiner.DirtAmount) then
        Combiner:SetSkin(3)
    end
end

function zmlab.f.Combiner_CleanMachine(Combiner, ply)
    zmlab.f.Debug("zmlab.f.Combiner_CleanMachine")

    local tr = ply:GetEyeTrace()
    if tr and tr.Hit and tr.HitPos then
        zmlab.f.CreateNetEffect("zmlab_combiner_clean",tr.HitPos)
    end

    Combiner.DirtLevel = Combiner.DirtLevel - zmlab.config.Combiner.CleanAmount
    Combiner:SetCleaningProgress(Combiner.DirtLevel)
    zmlab.f.Combiner_CheckDirtLevel(Combiner)
end
//////////////////////////////////////////
