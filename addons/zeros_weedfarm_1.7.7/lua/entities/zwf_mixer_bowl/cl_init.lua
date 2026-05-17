include("shared.lua")

function ENT:Initialize()
	zwf.f.EntList_Add(self)
end

function ENT:Draw()
	self:DrawModel()
end
