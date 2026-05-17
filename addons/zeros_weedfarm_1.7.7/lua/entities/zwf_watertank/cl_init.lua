include("shared.lua")

function ENT:Initialize()
	zwf.f.EntList_Add(self)
	self.Cached_Rope = false
	self.RopeRefresh = true
	self.LastWater = -1
end

function ENT:Draw()
	self:DrawModel()

	if GetConVar("zwf_cl_vfx_drawui"):GetInt() == 1 and zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 700) then
		self:DrawUI()
	end
end


function ENT:DrawUI()
	local Pos = self:GetPos() + self:GetRight() * -33 + self:GetUp() * 33

	local Ang = self:GetAngles()
	Ang:RotateAroundAxis(self:GetRight(),-180)
	Ang:RotateAroundAxis(self:GetForward(),-90)
	Ang:RotateAroundAxis(self:GetForward(),180)


	local _water = self:GetWater()

	cam.Start3D2D(Pos, Ang, 0.1)

		//BG
		draw.RoundedBox(5, -140 , -25, 280, 50,  zwf.default_colors["gray02"])

		//Water Bar
		if _water > 0 then

			local newWaterLvl = (280 / zwf.config.WaterTank.Capacity) * _water
			if self.LastWater ~= newWaterLvl then
				self.LastWater = self.LastWater + 100 * FrameTime()
				self.LastWater = math.Clamp(self.LastWater, 0, newWaterLvl)
			end

			draw.RoundedBox(5, -140 , -25,  self.LastWater, 50, zwf.default_colors["water"])
		end

		draw.SimpleText( _water .. zwf.config.UoL,zwf.f.GetFont("zwf_watertank_font01"), 0, 0, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)


		if self:RefillButton(LocalPlayer()) then
			draw.RoundedBox(15, -280 / 2 , -90, 280, 50,  zwf.default_colors["orange03"])

			local cost =  (zwf.config.WaterTank.Capacity - _water) * zwf.config.WaterTank.RefillCostPerUnit

			draw.SimpleText( zwf.config.Currency .. cost, zwf.f.GetFont("zwf_watertank_font01"), 0, -65, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else

			draw.RoundedBox(15,  -280 / 2 , -90, 280, 50,  zwf.default_colors["gray01"])
			draw.SimpleText(zwf.language.General["watertank_refill"],zwf.f.GetFont("zwf_watertank_font01"), 0, -65, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		end

		draw.SimpleTextOutlined( zwf.language.General["watertank_title"], zwf.f.GetFont("zwf_watertank_font01"), 0, -125,zwf.default_colors["white01"], TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 2,zwf.default_colors["water"] )
	cam.End3D2D()

end
