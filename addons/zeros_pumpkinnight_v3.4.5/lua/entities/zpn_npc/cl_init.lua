/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

function ENT:Initialize()
	zclib.EntityTracker.Add(self)
end

function ENT:Draw()
	self:DrawModel()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

	if zclib.Convar.Get("zclib_cl_drawui") == 1 and zclib.util.InDistance(LocalPlayer():GetPos(), self:GetPos(), 500) then
		self:DrawInfo()
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function ENT:DrawInfo()
	cam.Start3D2D(self:LocalToWorld(Vector(0,0,90 + (3 * math.abs(math.sin(CurTime()) * 1)))), zclib.HUD.GetLookAngles(), 0.1)
		draw.SimpleText(zpn.Theme.NPC.name, zclib.GetFont("zpn_npc_title"), 2, -78, zpn.Theme.Design.color02, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(zpn.Theme.NPC.name, zclib.GetFont("zpn_npc_title"), 0, -80, zpn.Theme.Design.color01, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
