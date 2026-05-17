if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

function zwf.f.SpliceLab_Initialize(lab)
    zwf.f.EntList_Add(lab)
    lab.JarCount = 0
    lab.Jars = { entA = nil, entB = nil}
end

function zwf.f.SpliceLab_Touch(lab, other)
    if not IsValid(lab) then return end
    if lab.JarCount >= 2 then return end
    if IsValid(other) and other:GetClass() == "zwf_jar" and other:GetWeedAmount() > 0 then
        if zwf.f.CollisionCooldown(other) then return end
        if zwf.config.Sharing.SeedLab == false and zwf.f.OwnerID_Check(other,lab) == false then return end

        zwf.f.SpliceLab_AddWeed(lab, other)
    end
end

function zwf.f.SpliceLab_USE(lab, ply)
	if zwf.f.IsWeedSeller(ply) == false then return end
    if zwf.config.Sharing.SeedLab == false and zwf.f.IsOwner(ply, lab) == false then return end

    if lab:GetSpliceStartTime() ~= -1 then return end

    if lab:Remove_WeedA(ply) then

        zwf.f.SpliceLab_RemoveWeed(lab, 1)

    elseif lab:Remove_WeedB(ply) then

        zwf.f.SpliceLab_RemoveWeed(lab, 2)

    elseif lab:SpliceWeed(ply) then
         zwf.f.OpenSpliceLab(ply, lab)
    end
end

function zwf.f.SpliceLab_AddWeed(lab, weedJar)

    if IsValid(lab.Jars.entA) and IsValid(lab.Jars.entB) then return end

    DropEntityIfHeld(weedJar)

    if not IsValid(lab.Jars.entA) then
        lab:SetWeedA(weedJar)
        lab.Jars.entA = weedJar
    elseif not IsValid(lab.Jars.entB) then
        lab:SetWeedB(weedJar)
        lab.Jars.entB = weedJar
    end

    zwf.f.CreateNetEffect("zwf_place_jar",lab)

    weedJar.IsInSeedLab = true
    weedJar:SetPos(lab:GetPos() + lab:GetUp() * 40 + lab:GetForward() * -15)
    weedJar:SetParent(lab)
    weedJar:SetNoDraw(true)
end

function zwf.f.SpliceLab_RemoveWeed(lab, JarNum)

    local weedJar
    local dist = 0
    if JarNum == 1 then
        weedJar = lab:GetWeedA()
        lab:SetWeedA(NULL)
        lab.Jars.entA = nil
        dist = 1
    elseif JarNum == 2 then
        weedJar = lab:GetWeedB()
        lab:SetWeedB(NULL)
        lab.Jars.entB = nil
        dist = 25
    end

    if IsValid(weedJar) then

        zwf.f.CreateNetEffect("zwf_place_jar",lab)

        weedJar.IsInSeedLab = false
        weedJar:SetParent(nil)
        weedJar:SetPos(lab:GetPos() + lab:GetUp() * 25 + lab:GetForward() * (45 + dist))
        weedJar:SetParent(nil)
        weedJar:SetNoDraw(false)

    	local phys = weedJar:GetPhysicsObject()

    	if phys:IsValid() then
    		phys:Wake()
    		phys:EnableMotion(true)
    	end
    end
end

util.AddNetworkString("zwf_OpenSpliceLab")
util.AddNetworkString("zwf_CloseSpliceLab")
util.AddNetworkString("zwf_SpliceWeed")

function zwf.f.OpenSpliceLab(ply, SpliceLab)
    local weedA = SpliceLab:GetWeedA()
    local weedB = SpliceLab:GetWeedB()
    if not IsValid(weedA) then return end
    if not IsValid(weedB) then return end

    net.Start("zwf_OpenSpliceLab")
    net.WriteEntity(SpliceLab)
    net.Send(ply)
end

net.Receive("zwf_SpliceWeed", function(len, ply)

    if zwf.f.NW_Player_Timeout(ply) then return end

    local SpliceLab = net.ReadEntity()
    local seedName = net.ReadString()

    if seedName == nil then return end
    if not IsValid(SpliceLab) then return end
    if SpliceLab:GetClass() ~= "zwf_splice_lab" then return end
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    if not ply:Alive() then return end
    if not zwf.f.InDistance(ply:GetPos(), SpliceLab:GetPos(), 200) then return end

    if SpliceLab:GetSpliceStartTime() ~= -1 then return end

    if zwf.f.String_ValidCharacter(seedName) == false then
        return
    end

    if zwf.f.String_TooShort(seedName,4) then
        return
    end

    if zwf.f.String_TooLong(seedName,12) then
        return
    end

    zwf.f.SpliceLab_StartSplice(SpliceLab,seedName)
end)


function zwf.f.SpliceLab_StartSplice(lab,name)
    lab:SetSeedName(name)
    lab:SetSpliceStartTime(CurTime())

    local timerName = "seedlab_timer_" .. lab:EntIndex()
    timer.Create(timerName, zwf.config.SeedLab.SpliceTime, 1, function()

        if IsValid(lab) then

            if timer.Exists(timerName) then
                timer.Remove(timerName)
            end

            zwf.f.SpliceLab_Splice(lab)

            lab:SetSpliceStartTime(-1)
            lab:SetSeedName("nil")
        else

            if timer.Exists(timerName) then
                timer.Remove(timerName)
            end
        end
    end)
end

function zwf.f.SpliceLab_Splice(lab)
    local weedA = lab:GetWeedA()
    local weedB = lab:GetWeedB()
    if not IsValid(weedA) then return end
    if not IsValid(weedB) then return end

    local PerfData = {
        WeedA_ID = weedA:GetPlantID(),
        WeedA_Amount = weedA:GetWeedAmount(),
        PerfA_Time = weedA:GetPerf_Time(),
        PerfA_Amount = weedA:GetPerf_Amount(),
        PerfA_THC = weedA:GetPerf_THC(),

        WeedB_ID = weedB:GetPlantID(),
        WeedB_Amount = weedB:GetWeedAmount(),
        PerfB_Time = weedB:GetPerf_Time(),
        PerfB_Amount = weedB:GetPerf_Amount(),
        PerfB_THC = weedB:GetPerf_THC()
    }

    local SpliceData = zwf.f.SpliceLab_CalculateSpliceData(PerfData)

    weedA:Remove()
    weedB:Remove()

    lab:SetWeedA(NULL)
    lab:SetWeedB(NULL)

    local ent = ents.Create("zwf_seed")
    ent:SetPos(lab:GetPos() + lab:GetUp() * 70 + lab:GetForward() * 15)
    ent:SetAngles(lab:GetAngles())
    ent:Spawn()
    ent:Activate()

    ent:SetSkin(zwf.config.Plants[SpliceData.Weed_ID].skin)

    zwf.f.SetOwnerByID(ent, lab:GetNWString("zwf_Owner", "nil"))

    ent:SetSeedID(SpliceData.Weed_ID)
    ent:SetPerf_Time(SpliceData.Perf_Time)
    ent:SetPerf_Amount(SpliceData.Perf_Amount)
    ent:SetPerf_THC(SpliceData.Perf_THC)
    ent:SetSeedCount(zwf.config.Seeds.Count)

    ent:SetSeedName(lab:GetSeedName())
end
