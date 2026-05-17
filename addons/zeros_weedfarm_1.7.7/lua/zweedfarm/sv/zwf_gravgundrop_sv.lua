if not SERVER then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

hook.Add("GravGunOnDropped", "a_zwf_EntAligment_GravGunOnDropped", function(ply, ent)
	if IsValid(ent) then
		if ent:GetClass() == "zwf_jar" then
			local ang = ply:GetAngles()
			ang:RotateAroundAxis(ply:GetUp(), 90)
			ent:SetAngles(Angle(ang.p, ang.y, 0))
		elseif ent:GetClass() == "zwf_weedblock"then
			local ang = ply:GetAngles()
			ang:RotateAroundAxis(ply:GetUp(), 90)
			ent:SetAngles(Angle(ang.p, ang.y, 0))
		elseif ent:GetClass() == "zwf_pot"then
			local ang = ply:GetAngles()
			ang:RotateAroundAxis(ply:GetUp(), 90)
			ent:SetAngles(Angle(ang.p, ang.y, 0))
		elseif ent:GetClass() == "zwf_pot_hydro"then
			local ang = ply:GetAngles()
			ang:RotateAroundAxis(ply:GetUp(), 90)
			ent:SetAngles(Angle(ang.p, ang.y, 0))
		elseif ent:GetClass() == "zwf_seed" then
			local ang = ply:GetAngles()
			ang:RotateAroundAxis(ply:GetUp(), 90)
			ent:SetAngles(Angle(ang.p, ang.y, 0))
		elseif ent:GetClass() == "zwf_nutrition" then
			local ang = ply:GetAngles()
			ang:RotateAroundAxis(ply:GetUp(), 180)
			ent:SetAngles(Angle(ang.p, ang.y, 0))
		elseif ent:GetClass() == "zwf_mixer_bowl" then
			local ang = ply:GetAngles()
			ang:RotateAroundAxis(ply:GetUp(), 180)
			ent:SetAngles(Angle(ang.p, ang.y, 0))
		elseif ent:GetClass() == "zwf_mixer" then
			local ang = ply:GetAngles()
			ang:RotateAroundAxis(ply:GetUp(), 90)
			ent:SetAngles(Angle(ang.p, ang.y, 0))
		elseif ent:GetClass() == "zwf_oven" then
			local ang = ply:GetAngles()
			ang:RotateAroundAxis(ply:GetUp(), 90)
			ent:SetAngles(Angle(ang.p, ang.y, 0))
		end

	end
end)
