if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

if timer.Exists("zwf_plague_timer") then
    timer.Remove("zwf_plague_timer")
end

function zwf.f.Plague_Logic()

    for k, v in pairs(zwf.Flowerpots) do

        if IsValid(v) then


            local HasNoPlant = v:GetSeed() == -1
            local IsHarvestReady = v:GetHarvestReady() and zwf.config.Growing.PostGrow.Enabled == false
            local HasPlague = v:GetHasPlague()
            local IsTooSmall = v:GetProgress() < v.Grow_Duration * 0.2
            local HasInfectionCooldown = (v.LastInfection + zwf.config.Plague.infect_cooldown) > CurTime()

            local boosts = zwf.f.Flowerpot_GetNutritionBoost(v)
            local IsProtected = zwf.f.RandomChance(boosts.b_plague)


            if v.UtraForm then
                continue
            end

            if HasNoPlant then
                //zwf.f.Debug("[Plague System]: Pot has no Plant!")
                continue
            end

            if IsHarvestReady then
                zwf.f.Debug("[Plague System]: Plant is HarvestReady!")
                continue
            end

            if HasPlague then
                zwf.f.Debug("[Plague System]: Plant is allready infected!")
                continue
            end

            if IsTooSmall then
                zwf.f.Debug("[Plague System]: Plant is not grown enough!")
                continue
            end

            if HasInfectionCooldown then
                zwf.f.Debug("[Plague System]: Plant has still infection cooldown!")
                continue
            end

            if IsProtected then
                zwf.f.Debug("[Plague System]: Plant has Plague Protection")
                continue
            end


            if zwf.f.RandomChance(zwf.config.Plague.infect_chance) then
                zwf.f.Plague_InfectPlant(v)
            else
                zwf.f.Debug("[Plague System]: Plant is save!")
            end
        end
    end
end

function zwf.f.Plague_InfectPlant(flowerpot)
    zwf.f.Debug("[Plague System]: Plant got infected!")
    flowerpot:SetHasPlague(true)

    hook.Run("zwf_OnPlantInfect" ,flowerpot)

    flowerpot.LastInfection = CurTime()
end

function zwf.f.Plague_HealPlant(flowerpot,ply)
    zwf.f.Debug("[Plague System]: Plant got healed!")

    zwf.f.CreateNetEffect("zwf_plant_heal",flowerpot.Plant)

    hook.Run("zwf_OnPlantHeal" ,flowerpot,ply)


    flowerpot:SetHasPlague(false)
end

if zwf.config.Plague.Enabled then
    timer.Create("zwf_plague_timer", zwf.config.Plague.infect_interval, 0, zwf.f.Plague_Logic)
end
