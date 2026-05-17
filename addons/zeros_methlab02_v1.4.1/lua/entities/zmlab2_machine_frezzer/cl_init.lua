/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2

function ENT:Initialize()
	zmlab2.Frezzer.Initialize(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2

function ENT:DrawTranslucent()
	self:Draw()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2

function ENT:Draw()
	self:DrawModel()
	zmlab2.Frezzer.Draw(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:Think()
    zmlab2.Frezzer.Think(self)
	self:SetNextClientThink(CurTime())
	return true
end

function ENT:OnRemove()
    zmlab2.Frezzer.OnRemove(self)
end
