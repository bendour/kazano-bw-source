include("shared.lua")

--[[-------------------------------------------------------------------------
Displaying the lean count in the crate
---------------------------------------------------------------------------]]
function ENT:Draw()
	self:DrawModel()
	local mypos = self:GetPos()
	if (LocalPlayer():GetPos():Distance(mypos) >= 1000) then return end
	local offset = Vector(0, 0, 35)
	local pos = mypos + offset
	local ang = (LocalPlayer():EyePos() - pos):Angle()
	ang.p = 0
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 180)
	cam.Start3D2D(pos,ang,0.04)
		draw.RoundedBoxEx(2^5,-300,0,600,200,Color(0,0,0,150),true,true,false,false)
		draw.RoundedBoxEx(2^5,-300,0,600,100,Color(0,0,0,200),true,true,false,false)
		draw.SimpleText("Crate Of Lean","lean_top",0,50,Color(255,255,255),1,1)
		draw.SimpleText(self:Getholding() .. " / " .. lean_updated.cratehold.val,"lean_ingredients",0,150,Color(255,255,255),1,1)
	cam.End3D2D()
end