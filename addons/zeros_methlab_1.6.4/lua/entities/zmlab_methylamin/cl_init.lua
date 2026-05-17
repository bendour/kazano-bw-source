include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:OnRemove()
	self:StopSound("Methylamin_filling")
end
