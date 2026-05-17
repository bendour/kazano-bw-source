include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	if zmlab.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 200) then
		self:DrawInfo()
	end
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:DrawInfo()
	local mAmount = self:GetMethAmount()

	if mAmount > 0 then
		local Ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)
		cam.Start3D2D(self:LocalToWorld(Vector(0, 0, 10 + 3 * self.LastCrateCount)), Ang, 0.1)
		draw.DrawText(math.Round(mAmount) .. zmlab.config.UoW, "zmlab_font4", 0, 5, zmlab.default_colors["white01"], TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
end

function ENT:Initialize()
	self.Count_Y = 0
	self.Count_X = 0
	self.Count_Z = 0

	self.LastCrateCount = 0
end

function ENT:CrateChangeUpdater()
	local crateCount = self:GetCrateCount()

	if self.LastCrateCount ~= crateCount then
		self.LastCrateCount = crateCount

		self:UpdateClientProps()
	end
end


function ENT:Think()
	if zmlab.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then
		self:CrateChangeUpdater()
	else
		self:RemoveClientModels()
		self.ClientProps = {}
		self.LastCrateCount = -1
	end
end

function ENT:UpdateClientProps()
	self:RemoveClientModels()

	self.ClientProps = {}

	if self.LastCrateCount > 0 then
		for i = 1, self.LastCrateCount do
			self:CreateClientCrate(i)
		end
	end
end

function ENT:OnRemove()
	self:RemoveClientModels()
end

function ENT:CreateClientCrate(cratecount)

	local pos = self:GetPos() - self:GetRight() * 25 - self:GetForward() * 50 + self:GetUp() * 3
	local ang = self:GetAngles()

	if self.Count_X >= 2 then
		self.Count_X = 1
		self.Count_Y = self.Count_Y + 1
	else
		self.Count_X = self.Count_X + 1
	end

	if self.Count_Y >= 3 then
		self.Count_Y = 0
		self.Count_Z = self.Count_Z + 1
	end

	pos = pos + self:GetForward() * 33 * self.Count_X
	pos = pos + self:GetRight() * 25 * self.Count_Y
	pos = pos + self:GetUp() * 13.5 * self.Count_Z


	local crate = ents.CreateClientProp()
	if not IsValid(crate) then return end
	crate:SetAngles(ang)
	crate:SetModel("models/zerochain/zmlab/zmlab_transportcrate_full.mdl")
	crate:SetPos(pos)

	crate:Spawn()
	crate:Activate()

	crate:SetRenderMode(RENDERMODE_NORMAL)
	crate:SetParent(self)

	table.insert(self.ClientProps, crate)
end

function ENT:RemoveClientModels()
	self.Count_Y = 0
	self.Count_X = 0
	self.Count_Z = 0

	if self.ClientProps and table.Count(self.ClientProps) > 0 then
		for k, v in pairs(self.ClientProps) do
			if IsValid(v) then
				v:Remove()
			end
		end
	end
end
