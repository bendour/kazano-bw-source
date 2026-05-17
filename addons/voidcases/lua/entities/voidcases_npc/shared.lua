ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.AutomaticFrameAdvance = true
ENT.PrintName = "VoidCases NPC"
ENT.Category = "VoidCases"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.AdminSpawnable = true

--[[---------------------------------------------------------
	Name: Entity
-----------------------------------------------------------]]

function ENT:RenderOverride()
    self:DrawModel()
    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 500 * 500 then return end
    local ang = LocalPlayer():EyeAngles()
    local pos = self:GetPos()
    local targethead = self:LookupBone("ValveBiped.Bip01_Head1")
    if targethead then
        local targetheadpos = self:GetBonePosition(targethead)
        pos = targetheadpos + Vector(0, 0, 15)
    else
        pos = self.ViewOffset
    end
    ang:RotateAroundAxis( ang:Forward(), 90 )
    ang:RotateAroundAxis( ang:Right(), 90 )
    cam.Start3D2D(pos, ang, 0.08)
        draw.SimpleTextOutlined(ashop.Config.NPCName or self.PrintName, "ashop_100_600", 0, -30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, color_black)
    cam.End3D2D()
    
    -- Ajout du texte "Menu d'aide" au-dessus
    pos = self:GetPos() + Vector(0, 0, 80)
    ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)
    
    cam.Start3D2D(pos, ang, 0.2)
        local boxColor = Color(100, 0, 0) -- Couleur de la box
        local shadowColor = Color(8, 12, 30) -- Ombre plus foncée
    
        draw.RoundedBox(8, -110, -25, 220, 50, boxColor) -- Box principale
        draw.SimpleText("Menu Unbox", "NPCHeader", 0 + 2, 0 + 2, shadowColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- Ombre
        draw.SimpleText("Menu Unbox", "NPCHeader", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- Texte principal
    cam.End3D2D()
end

