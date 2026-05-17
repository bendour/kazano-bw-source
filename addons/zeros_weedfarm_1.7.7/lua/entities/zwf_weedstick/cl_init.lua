include("shared.lua")

function ENT:Initialize()
	zwf.f.EntList_Add(self)
	self:DrawShadow(false)
	self:SetBodygroup(0, math.random(0,3))

	self.LastProcess = -1
	self.NextSound = CurTime() + 2
	self.HSize = 200
end

function ENT:Draw()
	self:DrawModel()

	if GetConVar("zwf_cl_vfx_drawui"):GetInt() == 1 and zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) then
		self:DrawInfo()
	end
end

function ENT:DrawInfo()

	local _dryStartTime = self:GetStartDryTime()

	if _dryStartTime ~= -1 then
		cam.Start3D2D(self:LocalToWorld(Vector(0, -5, 0)), Angle(0, EyeAngles().y - 90, -EyeAngles().x + 90), 0.05)

			local _dryTime = math.Clamp(CurTime() - _dryStartTime,0,zwf.config.DryStation.Duration)

			_dryTime = zwf.config.DryStation.Duration - _dryTime

			if _dryTime == 0 then

				local _progress = self:GetProgress()
				local _size = 200 - (200 / (zwf.config.DryStation.Harvest_Time * 4)) * _progress

				// Removal Sound
				if self.LastProcess ~= _progress and CurTime() > self.NextSound then
					self.LastProcess = _progress
					zwf.f.EmitSoundENT("zwf_cut_plant", self)
					self.NextSound = CurTime() + math.Rand(0.3,0.6)
				end


				self.HSize = math.Clamp(self.HSize + (200 / zwf.config.DryStation.Harvest_Time) * FrameTime(), 0, _size)

				draw.RoundedBox(90, -self.HSize / 2, -self.HSize / 2, self.HSize, self.HSize, zwf.default_colors["power"])
				draw.SimpleText("[E]", zwf.f.GetFont("zwf_seed_font01"), 0, -50, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			elseif _dryTime > 0 then


				local progress = (1 / zwf.config.DryStation.Duration) * _dryTime

				surface.SetDrawColor(zwf.default_colors["white01"])
				surface.SetMaterial(zwf.default_materials["clock_base"])
				surface.DrawTexturedRect(-90, -90, 180, 180)

				surface.SetDrawColor(zwf.default_colors["white01"])
				surface.SetMaterial(zwf.default_materials["clock_pointer"])
				surface.DrawTexturedRectRotated(0, 0, 180, 180, Lerp(progress, 0, 360))
			end
		cam.End3D2D()
	end
end
