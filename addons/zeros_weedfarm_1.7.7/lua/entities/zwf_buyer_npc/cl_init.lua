include("shared.lua")

function ENT:Initialize()
	zwf.f.EntList_Add(self)

	self.HasEffect = false
end

function ENT:Draw()
	self:DrawModel()

	if GetConVar("zwf_cl_vfx_drawui"):GetInt() == 1 and zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 500) then
		self:DrawInfo()
	end
end

function ENT:DrawInfo()
	local Pos = self:GetPos() + self:GetUp() * 80
	Pos = Pos + self:GetUp() * math.abs(math.sin(CurTime()) * 1)
	local Ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

	cam.Start3D2D(Pos, Ang, 0.1)


		if zwf.config.NPC.DynamicBuyRate == true and zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 200) then

			local profit = self:GetPrice() - 100

			if profit > 0 then
				profit = "+" .. profit
			else
				profit = profit
			end

			local sellInfo = zwf.language.NPC["profit"] .. ": " .. profit .. "%"

			local aSize = 23 * string.len(sellInfo)
			draw.RoundedBox(25, -aSize / 2, 25, aSize, 50, zwf.default_colors["black01"])
			draw.SimpleText(sellInfo, zwf.f.GetFont("zwf_npc_font02"), 0, 40, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end

		draw.SimpleTextOutlined(zwf.language.NPC["title"], zwf.f.GetFont("zwf_npc_font01"), 0, -35, zwf.default_colors["green01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, zwf.default_colors["black02"])
	cam.End3D2D()
end

function ENT:Think()
	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 500) then
		if self.HasEffect == false then
			zwf.f.ParticleEffectAttach("zwf_joint_fire", PATTACH_POINT_FOLLOW, self, 10)
			self.HasEffect = true
		end
	else
		if self.HasEffect == true then
			self.HasEffect = false
			self:StopParticles()
		end
	end
end
