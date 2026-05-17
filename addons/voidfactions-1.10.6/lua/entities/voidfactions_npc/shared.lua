ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.AutomaticFrameAdvance = true 
ENT.PrintName = "VoidFactions NPC"
ENT.Category = "VoidFactions"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.AdminSpawnable = true

surface.CreateFont("NPCHeader", {
    font = "Roboto",
    size = 40,
    weight = 650,
    antialias = true
})

--[[---------------------------------------------------------
	Name: Entity
-----------------------------------------------------------]]
function ENT:Draw()
	if not (VoidFactions.UI and VoidFactions.UI.Accent) then return end
	
	self:DrawModel()
	
	-- Vérification de distance pour les performances
	local myPos = LocalPlayer():GetPos()
	if myPos:DistToSqr(self:GetPos()) > 800 * 800 then return end
	
	-- Position et angle pour l'affichage au-dessus de la tête
	local pos = self:GetPos() + Vector(0, 0, 80)
	local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)
	
	-- Texte à afficher
	local text = "Système de clan"
	
	-- Calcul de la taille du texte pour adapter le cadre
	surface.SetFont("NPCHeader")
	local width, height = surface.GetTextSize(text)
	local padding = 10 -- Espace supplémentaire autour du texte
	
	-- Affichage du cadre et du texte
	cam.Start3D2D(pos, ang, 0.2)
		local boxColor = Color(100, 0, 0) -- Couleur de la box
		local shadowColor = Color(8, 12, 30) -- Ombre plus foncée
		
		-- Box qui s'adapte à la taille du texte
		draw.RoundedBox(8, -width/2 - padding, -height/2 - padding, width + padding*2, height + padding*2, boxColor)
		
		-- Texte avec ombre
		draw.SimpleText(text, "NPCHeader", 0 + 2, 0 + 2, shadowColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- Ombre
		draw.SimpleText(text, "NPCHeader", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- Texte principal
	cam.End3D2D()
end