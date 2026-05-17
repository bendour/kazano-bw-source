if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

function zwf.f.Ventilator_USE(Ventilator,ply)
	if zwf.f.IsWeedSeller(ply) == false then return end
    if zwf.config.Sharing.Fans == false and zwf.f.IsOwner(ply, Ventilator) == false then return end

    if Ventilator:EnableButton(ply) then
        Ventilator:SetIsRunning(not Ventilator:GetIsRunning())
    end
end

function zwf.f.Ventilator_Logic()
	for k, v in pairs(zwf.EntList) do
		if IsValid(v) and v:GetClass() == "zwf_ventilator" then
			local _power = v:GetPower()
			local _isrunning = v:GetIsRunning()

			if _isrunning and _power > 0 then
				v:SetPower(math.Clamp(_power - zwf.config.Ventilator.Power_usage, 0, 19999))
				zwf.f.Ventilator_BlowPlants(v)
			end
		end
	end
end

function zwf.f.Ventilator_BlowPlants(Ventilator)
    local Pos = Ventilator:GetPos() + Ventilator:GetUp() * 60 + Ventilator:GetRight() * -100

    for k, v in pairs(zwf.Flowerpots) do
        if IsValid(v) and zwf.f.InDistance(Pos, v:GetPos(), 175) then

            local plantTemp = v:GetTemperatur()
            if plantTemp > 0 then

                local coolVal = zwf.config.Ventilator.Cooling
                v:SetTemperatur(math.Clamp(plantTemp - coolVal,0,999))
            end

        end
    end
end
