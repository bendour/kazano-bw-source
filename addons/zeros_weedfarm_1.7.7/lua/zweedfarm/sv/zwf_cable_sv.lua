if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

if zwf.PowerEntList == nil then
    zwf.PowerEntList = {}
end

function zwf.f.PowerEntList_Add(ent)
    table.insert(zwf.PowerEntList, ent)
end

function zwf.f.PowerWater_Logic()
    for k, v in pairs(zwf.PowerEntList) do
        if IsValid(v) and (v:GetClass() == "zwf_generator" or v:GetClass() == "zwf_lamp" or v:GetClass() == "zwf_ventilator" or v:GetClass() == "zwf_outlet") then
            if v:GetClass() == "zwf_outlet" then
                local _output01 = v:GetOutput01()
                local _output02 = v:GetOutput02()
                local _output03 = v:GetOutput03()
                zwf.f.Cable_DistanceCheck(v, _output01)
                zwf.f.Cable_DistanceCheck(v, _output02)
                zwf.f.Cable_DistanceCheck(v, _output03)
            else
                local _output = v:GetOutput()
                zwf.f.Cable_DistanceCheck(v, _output)
            end
        elseif IsValid(v) and (v:GetClass() == "zwf_watertank" or v:GetClass() == "zwf_pot_hydro") then

            local _output = v:GetOutput()

            if IsValid(_output) then
                if zwf.f.InDistance(v:GetPos(), _output:GetPos(), zwf.config.Cable.distance) then
                    zwf.f.Power_TransferWater(v, _output)
                else
                    zwf.f.CableSWEP_Deconnect(v)
                end
            end

        end
    end
end

// Checks if the power_reciever is to far aways from its power_source and deconnects it
function zwf.f.Cable_DistanceCheck(power_source,power_reciever)
    if IsValid(power_source) and IsValid(power_reciever) then
        if zwf.f.InDistance(power_source:GetPos(), power_reciever:GetPos(), zwf.config.Cable.distance) then
            zwf.f.Power_TransferEnergy(power_source, power_reciever)
        else
            zwf.f.CableSWEP_Deconnect(power_source)
        end
    end
end


function zwf.f.Power_TransferEnergy(entA, entB)

    local maxClamp = 99999999999

    local genPower = entA:GetPower()
    local tAmount = genPower

    // Transfer Power
    if genPower > 0 and IsValid(entB) and entB:GetClass() == "zwf_lamp" and entB:GetPower() < zwf.config.Lamps[entB:GetLampID()].Power_storage then
        tAmount = math.Clamp(tAmount,0,zwf.config.Lamps[entB:GetLampID()].Power_storage - entB:GetPower())

        entA:SetPower(math.Clamp(entA:GetPower() - tAmount, 0, maxClamp))
        entB:SetPower(math.Clamp(entB:GetPower() + tAmount, 0, maxClamp))
    elseif genPower > 0 and IsValid(entB) and entB:GetClass() == "zwf_ventilator" and entB:GetPower() < zwf.config.Ventilator.Power_storage then
        tAmount = math.Clamp(tAmount,0,zwf.config.Ventilator.Power_storage - entB:GetPower())

        entA:SetPower(math.Clamp(entA:GetPower() - tAmount, 0, maxClamp))
        entB:SetPower(math.Clamp(entB:GetPower() + tAmount, 0, maxClamp))
    elseif genPower > 0 and IsValid(entB) and entB:GetClass() == "zwf_outlet" and entB:GetPower() < zwf.config.Outlet.Power_storage then
        tAmount = math.Clamp(tAmount,0,zwf.config.Outlet.Power_storage - entB:GetPower())

        entA:SetPower(math.Clamp(entA:GetPower() - tAmount, 0, maxClamp))
        entB:SetPower(math.Clamp(entB:GetPower() + tAmount, 0, maxClamp))
    end
end

function zwf.f.Power_TransferWater(entA, entB)
    local maxClamp = 99999999999

    local tankWater = entA:GetWater()
    local tAmount = tankWater

    // Transfer Water
    if tankWater > 0 and IsValid(entB) and entB:GetClass() == "zwf_pot_hydro" and entB:GetWater() < zwf.config.Flowerpot.Water_Capacity / 2 then
        tAmount = math.Clamp(tAmount,0,(zwf.config.Flowerpot.Water_Capacity / 2) - entB:GetWater())

        entA:SetWater(math.Clamp(entA:GetWater() - tAmount, 0, maxClamp))
        entB:SetWater(math.Clamp(entB:GetWater() + tAmount, 0, maxClamp))
    end
end
