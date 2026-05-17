/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 99958388d5b8bc21e4d7af1df39fd75077f0660617b3c526ce40ea9691a5fd3b
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:Initialize()
	zmlab2.TentDoor.Initialize(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:DrawTranslucent()
	self:Draw()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:Draw()
	self:DrawModel()
	zmlab2.TentDoor.Draw(self)
end

function ENT:Think()
	self:SetNextClientThink(CurTime())
	zmlab2.TentDoor.Think(self)

	return true
end
