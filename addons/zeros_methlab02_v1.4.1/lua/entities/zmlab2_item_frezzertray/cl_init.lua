/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:Initialize()
	zmlab2.FrezzerTray.Initialize(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:DrawTranslucent()
	self:Draw()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:Draw()
	self:DrawModel()
	zmlab2.FrezzerTray.Draw(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
