if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

function zwf.f.Lamp_Logic()
    for k, v in pairs(zwf.EntList) do
        if IsValid(v) and v:GetClass() == "zwf_lamp" then

            local _power = v:GetPower()
            local _isrunning = v:GetIsRunning()

            if _isrunning and _power > 0 then
                local lampData = zwf.config.Lamps[v:GetLampID()]
                v:SetPower(math.Clamp(_power - lampData.Power_usage, 0, 999))
                zwf.f.Lamp_LightPlants(v, lampData)
            end
        end
    end
end


function zwf.f.Lamp_LightPlants(lamp,lampData)

    local lightPos = lamp:GetPos() + lamp:GetUp() * -60

    for k, v in pairs(zwf.Flowerpots) do
        if IsValid(v) and zwf.f.InDistance(lightPos, v:GetPos(), 100) then
            local plantLight = v:GetLight()
            if plantLight < 3 then
                v:SetLight(plantLight + 2)

                //if v:GetSeed() > 0 and v:GetProgress() < v.PlantData.Grow.Duration then

                    local heatVal = lampData.Heat

                    v:SetTemperatur(math.Clamp(v:GetTemperatur() + heatVal,0,30))
                //end
            end
        end
    end
end
