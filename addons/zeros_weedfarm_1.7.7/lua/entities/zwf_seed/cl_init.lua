include("shared.lua")

function ENT:Initialize()
	self.SeedData = nil
end

function ENT:Draw()
	self:DrawModel()

	if GetConVar("zwf_cl_vfx_drawui"):GetInt() == 1 and zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) then
		self:DrawInfo()
	end
end

function ENT:GetColorFromBoostValue(boost)
	if (boost - 100) < 0 then
		return zwf.default_colors["red03"]
	else
		return zwf.default_colors["green06"]
	end
end

function ENT:DrawInfo()

	if self.SeedData == nil then
		self.SeedData = zwf.config.Plants[self:GetSeedID()]
	else

		local Perf_Time = self:GetPerf_Time()
		local Perf_Amount = self:GetPerf_Amount()
		local Perf_THC = self:GetPerf_THC()


		local c_time = self:GetColorFromBoostValue(Perf_Time)
		local c_amount = self:GetColorFromBoostValue(Perf_Amount)
		local c_thc = self:GetColorFromBoostValue(Perf_THC)


		Perf_Time = 100 - (Perf_Time - 100)
		Perf_Time = Perf_Time * 0.01
		local def_time = self.SeedData.Grow.Duration
		Perf_Time = def_time * Perf_Time
		Perf_Time = math.Round(Perf_Time) .. "s"

		Perf_Amount = Perf_Amount * 0.01
		local def_amount = self.SeedData.Grow.MaxYieldAmount
		Perf_Amount = def_amount * Perf_Amount
		Perf_Amount = math.Round(Perf_Amount) .. zwf.config.UoW

		Perf_THC = Perf_THC * 0.01
		local def_thc = self.SeedData.thc_level
		Perf_THC = def_thc * Perf_THC
		Perf_THC = math.Round(Perf_THC) .. "%"



		cam.Start3D2D(self:LocalToWorld(Vector(0, 0, 15)), Angle(0, EyeAngles().y - 90, -EyeAngles().x + 90), 0.05)

			if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 100) then
				draw.RoundedBox(15, -250 , -150, 500, 225,  zwf.default_colors["black03"])

				draw.SimpleText(self:GetSeedName() .. " x" .. self:GetSeedCount(), zwf.f.GetFont("zwf_seed_font01"), 0, -250, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

				surface.SetDrawColor(zwf.default_colors["white01"])
				surface.SetMaterial(zwf.default_materials["icon_growtime"])
				surface.DrawTexturedRect(-230, -125, 100, 100)

				surface.SetDrawColor(zwf.default_colors["white01"])
				surface.SetMaterial(zwf.default_materials["icon_mass"])
				surface.DrawTexturedRect(-50, -125, 100, 100)

				surface.SetDrawColor(zwf.default_colors["white01"])
				surface.SetMaterial(zwf.default_materials["icon_thc"])
				surface.DrawTexturedRect(120, -125, 100, 100)

				draw.SimpleText(Perf_Time, zwf.f.GetFont("zwf_seed_font02"), -175, 30, c_time, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(Perf_Amount, zwf.f.GetFont("zwf_seed_font02"), 0, 30, c_amount, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(Perf_THC, zwf.f.GetFont("zwf_seed_font02"), 175, 30, c_thc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(self:GetSeedName() .. " x" .. self:GetSeedCount(), zwf.f.GetFont("zwf_seed_font01"), 0, 0, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end

		cam.End3D2D()
	end
end
