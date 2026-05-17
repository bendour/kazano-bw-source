include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	-- Position de départ du laser
	local startPos = self:GetPos() + self:GetUp() * 58
	-- Position de la cible
	local endPos = self:GetNWVector("LaserTarget")
	-- Vérifie si le laser est actif
	local laserActive = self:GetNWBool("LaserActive")

	if laserActive and endPos then
		-- Dessiner le laser
		cam.Start3D()
			render.SetMaterial(Material("cable/redlaser"))
			render.DrawBeam(startPos, endPos, 2, 0, 12.5, Color(255, 0, 0))
		cam.End3D()
	end
	
	-- Afficher la ligne de visée si activée avec USE
	if self:GetShowAimLine() then
		local aimDir = self:GetAimDirection()
		if aimDir and aimDir:Length() > 0 then
			local eyePos = self:GetPos() + (self:GetUp() * 58 + self:GetForward() * 7 + self:GetRight() * 2)
			local aimEndPos = eyePos + aimDir * self.Range
			
			-- Tracer pour trouver où la ligne s'arrête
			local tr = util.TraceLine({
				start = eyePos,
				endpos = aimEndPos,
				filter = self
			})
			
			-- Affichage simple : juste quelques lignes statiques avec traces
			local up = self:GetUp()
			local right = self:GetRight()
			local forward = aimDir
			local color = Color(255, 255, 255, 200)
			
			render.SetMaterial(Material("cable/rope"))
			
			-- Ligne centrale pour montrer la portée
			local centerEnd = eyePos + forward * self.Range
			local centerTrace = util.TraceLine({
				start = eyePos,
				endpos = centerEnd,
				filter = self
			})
			render.DrawBeam(eyePos, centerTrace.HitPos, 2, 0, 1, Color(255, 255, 0, 255))
			
			-- Dessiner 8 lignes radiales pour montrer le cône
			for i = 0, 7 do
				local angle = (i / 8) * math.pi * 2
				local offset = (math.cos(angle) * right + math.sin(angle) * up) * self.Range * 0.5
				local endPos = eyePos + forward * self.Range + offset
				
				-- Tracer pour trouver les obstacles
				local trace = util.TraceLine({
					start = eyePos,
					endpos = endPos,
					filter = self
				})
				
				-- Dessiner jusqu'à l'obstacle ou la fin
				render.DrawBeam(eyePos, trace.HitPos, 1, 0, 1, color)
			end			-- Afficher le temps restant
			local timeLeft = math.max(0, math.ceil(self:GetAimLineEndTime() - CurTime()))
			local ang = LocalPlayer():EyeAngles()
			ang:RotateAroundAxis(ang:Forward(), 90)
			ang:RotateAroundAxis(ang:Right(), 90)
			
			cam.Start3D2D(self:GetPos() + Vector(0, 0, 80), ang, 0.1)
				draw.SimpleTextOutlined("Ligne de visée: " .. timeLeft .. "s", "DermaLarge", 0, 0, Color(0, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0))
			cam.End3D2D()
		end
	end
end
