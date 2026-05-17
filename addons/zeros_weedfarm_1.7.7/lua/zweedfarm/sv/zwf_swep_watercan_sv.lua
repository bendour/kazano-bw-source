if not SERVER then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

function zwf.f.SWEP_Watering(Swep)
	if Swep:GetWater() < zwf.config.WateringCan.Transfer_Amount then return end

	local tr = Swep:GetOwner():GetEyeTrace()
	local trEnt = tr.Entity
	if tr.Hit and IsValid(trEnt) then
		local pot

		if string.sub( trEnt:GetClass(), 1, 7 )  == "zwf_pot" then
			pot = trEnt
		elseif trEnt:GetClass() == "zwf_plant" and IsValid(trEnt:GetParent()) and string.sub( trEnt:GetParent():GetClass(), 1, 7 )  == "zwf_pot" then
			pot = trEnt:GetParent()
		end


		if zwf.config.Sharing.Plants == false and zwf.f.IsOwner(ply, pot) == false then return end

		if IsValid(pot) and zwf.f.Flowerpot_CanWaterPlant(pot) then
			zwf.f.Flowerpot_Watering(pot, zwf.config.WateringCan.Transfer_Amount)
			Swep:SetWater(Swep:GetWater() - zwf.config.WateringCan.Transfer_Amount)
		end
	end
end

function zwf.f.SWEP_GetWater(Swep)

	local swep_Water = Swep:GetWater()

	if swep_Water < zwf.config.WateringCan.Capacity then

		local tr = Swep:GetOwner():GetEyeTrace()

		if  tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zwf_watertank" then
			local waterTank = tr.Entity

			if zwf.config.Sharing.WaterTank == false and zwf.f.IsOwner(Swep:GetOwner(), waterTank) == false then return end


			if waterTank:GetWater() <= 0 then return end

			waterTank:SetWater(math.Clamp(waterTank:GetWater() - 25,0,zwf.config.WaterTank.Capacity))
			Swep:SetWater(math.Clamp(swep_Water + 25,0,zwf.config.WateringCan.Capacity))

			zwf.f.CreateNetEffect("zwf_water_refill",tr.Entity)
		end
	end
end
