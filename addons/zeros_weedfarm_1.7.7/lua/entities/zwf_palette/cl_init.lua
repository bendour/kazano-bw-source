include("shared.lua")

function ENT:Initialize()
	zwf.f.EntList_Add(self)
	self.Count_Y = 0
	self.Count_X = 0
	self.Count_Z = 0
	self.LastBlockCount = -1
	self.WeedList = {}
end

function ENT:Draw()
	self:DrawModel()

	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 600) then
		self:DrawInfo()
	end
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:DrawInfo()
	if self.LastBlockCount > 0 then
		local Pos = self:GetPos() + Vector(0, 0, 60 + (1 * math.Clamp(self.LastBlockCount, 1, 10000)))
		local money = math.Round(self:GetMoney())
		cam.Start3D2D(Pos, Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.15)
		draw.DrawText(zwf.config.Currency .. money, zwf.f.GetFont("zwf_palette_font02"), 0, 5, zwf.default_colors["black02"], TEXT_ALIGN_CENTER)
		draw.DrawText(zwf.config.Currency .. money, zwf.f.GetFont("zwf_palette_font01"), 0, 5, zwf.default_colors["green05"], TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
end

function ENT:BlockChangeUpdater()
	local blockCount = self:GetBlockCount()

	if self.LastBlockCount ~= blockCount then
		self.LastBlockCount = blockCount
		self:UpdateClientProps()
	end
end

function ENT:Think()
	--Here we create or remove the client models
	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then
		self:BlockChangeUpdater()
	else
		self:RemoveClientModels()
		self.ClientProps = {}
		self.LastBlockCount = -1
	end
end

function ENT:UpdateClientProps()
	self:RemoveClientModels()
	local weedblocks = {}

	for k, v in pairs(self.WeedList) do
		table.insert(weedblocks, v.id)
	end

	self.ClientProps = {}

	for i = 1, table.Count(weedblocks) do
		self:CreateClientBlock(i, weedblocks[i])
	end
end

function ENT:OnRemove()
	self:RemoveClientModels()
end

function ENT:CreateClientBlock(blockid, weedID)
	local pos = self:GetPos() - self:GetRight() * 25 - self:GetForward() * 33 + self:GetUp() * 9
	local ang = self:GetAngles()

	if self.Count_X >= 3 then
		self.Count_X = 1
		self.Count_Y = self.Count_Y + 1
	else
		self.Count_X = self.Count_X + 1
	end

	if self.Count_Y >= 3 then
		self.Count_Y = 0
		self.Count_Z = self.Count_Z + 1
	end

	pos = pos + self:GetForward() * 17 * self.Count_X
	pos = pos + self:GetRight() * 25 * self.Count_Y
	pos = pos + self:GetUp() * 10 * self.Count_Z

	local crate = ents.CreateClientProp()
	if not IsValid(crate) then return end
	crate:SetModel("models/zerochain/props_weedfarm/zwf_weedblock.mdl")
	crate:SetAngles(ang)
	crate:SetPos(pos)
	crate:Spawn()
	crate:Activate()
	local skin = zwf.config.Plants[weedID].skin
	crate:SetSkin(skin)
	crate:SetParent(self)
	self.ClientProps["Block" .. blockid] = crate
end

function ENT:RemoveClientModels()
	self.Count_Y = 0
	self.Count_X = 0
	self.Count_Z = 0

	if (self.ClientProps and table.Count(self.ClientProps) > 0) then
		for k, v in pairs(self.ClientProps) do
			if IsValid(v) then
				v:Remove()
			end
		end
	end
end
