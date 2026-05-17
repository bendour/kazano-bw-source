/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

include("shared.lua")

function ENT:DrawTranslucent()
	self:Draw()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

function ENT:Draw()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	self:DrawModel()

	if zclib.Convar.Get("zpn_cl_draw_antighost") == 1 and zclib.util.InDistance(LocalPlayer():GetPos(), self:GetPos(), 3000) then
		render.SetColorMaterial()
		render.DrawSphere( self:GetPos(), zpn.config.AntiGhostSign.Distance, 30, 30, zpn.default_colors["violett01"] )
		render.DrawWireframeSphere( self:GetPos(), zpn.config.AntiGhostSign.Distance, 30, 30, zpn.default_colors["violett03"],true)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

end
