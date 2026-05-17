include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local plypos = LocalPlayer():GetPos()
    if self:GetPos():Distance(plypos) > 1000 then return end
    local leancup = Material("lean_prod/lean.png")
    local pos = self:GetPos()
    local ang = self:GetAngles()
    
    -- Front of the box
    ang:RotateAroundAxis(ang:Up(),90)
    ang:RotateAroundAxis(ang:Forward(),90)
    cam.Start3D2D(pos + ang:Up()*16.15,ang,0.1)
        --draw.RoundedBox(0,-195,-120,390,240,Color(100,100,100))
        --draw.RoundedBox(0,-195,-50,390,105,Color(0,0,0))
        surface.SetDrawColor(Color(255,255,255))
        surface.SetMaterial(leancup)
        surface.DrawTexturedRect(-(195*0.25), -(120*0.5), 75,125)
    cam.End3D2D()

    -- Left side of the box
    /*ang:RotateAroundAxis(ang:Right(),90)
    cam.Start3D2D(pos + ang:Up()*19.5,ang,0.1)
        draw.RoundedBox(0,-162,-120,322,240,Color(100,100,100))
        draw.RoundedBox(0,-162,-50,322,105,Color(0,0,0))
    cam.End3D2D()

    -- Right side of the box
    ang:RotateAroundAxis(ang:Right(),180)
    cam.Start3D2D(pos + ang:Up()*19.5,ang,0.1)
        draw.RoundedBox(0,-162,-120,322,240,Color(100,100,100))
        draw.RoundedBox(0,-162,-50,322,105,Color(0,0,0))
    cam.End3D2D()

    -- Back of the box
    ang:RotateAroundAxis(ang:Right(),-90)
    cam.Start3D2D(pos + ang:Up()*16.15,ang,0.1)
        draw.RoundedBox(0,-195,-120,390,240,Color(100,100,100))
        draw.RoundedBox(0,-195,-50,390,105,Color(0,0,0))
    cam.End3D2D()*/

    local offset = Vector(0, 0, 25)
	local pos2 = self:GetPos() + offset
	local ang2 = (LocalPlayer():EyePos() - pos2):Angle()
	ang2.p = 0
	ang2:RotateAroundAxis(ang2:Right(), 90)
	ang2:RotateAroundAxis(ang2:Up(), 90)
	ang2:RotateAroundAxis(ang2:Forward(), 180)
	cam.Start3D2D(pos2,ang2,0.04)
		draw.RoundedBoxEx(2^5,-300,0,600,200,Color(0,0,0,150),true,true,false,false)
		draw.RoundedBoxEx(2^5,-300,0,600,100,Color(0,0,0,200),true,true,false,false)
		draw.SimpleText("Small Box Of Lean","lean_top",0,50,Color(255,255,255),1,1)
		draw.SimpleText(self:Getholding() .. " / " .. lean_updated.smallhold.val,"lean_ingredients",0,150,Color(255,255,255),1,1)
	cam.End3D2D()
end