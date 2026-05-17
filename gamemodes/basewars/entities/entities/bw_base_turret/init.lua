AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Use(activator, caller)
	if not IsValid(caller) or not caller:IsPlayer() then return end
	
	-- Activer l'affichage de la ligne de visée pendant 30 secondes
	self:SetShowAimLine(true)
	self:SetAimLineEndTime(CurTime() + 30)
	
	-- Calculer la direction de visée
	local Forward = self:GetForward()
	self:SetAimDirection(Forward)
	
	if caller == self:CPPIGetOwner() then
		caller:ChatPrint("Ligne de visée de la tourelle activée pendant 30 secondes.")
	end
end

function ENT:ThinkFunc()
	local owner = self:CPPIGetOwner()
	
	-- Vérifier si la ligne de visée doit être désactivée
	if self:GetShowAimLine() and CurTime() > self:GetAimLineEndTime() then
		self:SetShowAimLine(false)
	end
	
	-- Mettre à jour la direction de visée en temps réel
	if self:GetShowAimLine() then
		local Forward = self:GetForward()
		self:SetAimDirection(Forward)
	end

	if self.NextShot + self.ShootingDelay < CurTime() then
		self.NextShot = CurTime()

		local Forward = self:GetForward()
		local Pos = self:GetPos()

		self.EyePosOffset = Pos + (self:GetUp() * 58 + Forward * 7 + self:GetRight() * 2)

		local plys = {}
		for k, ply in pairs(ents.FindInCone(self.EyePosOffset, Forward, self.Range, math.rad(45))) do
			if not ply:IsPlayer() then continue end
			if ply:HasGodMode() or not ply:Enemy(owner) or not ply:Alive() then continue end

			local Data = {
				ply = ply,
				dist = Pos:Distance(ply:GetPos()),
			}

			plys[#plys + 1] = Data
		end

		if #plys <= 0 then return end

		table.SortByMember(plys, "dist", true)
		self:FirePlayer(plys[1].ply)
	end
end

function ENT:FirePlayer(target)
	if not IsValid(target) or not target:IsPlayer() then return end
	if target:HasGodMode() then return end

	local Pos = target:LocalToWorld(target:OBBCenter()) + Vector(0, 0, 10)

	local tr = {
		start = self.EyePosOffset,
		endpos = Pos,
		filter = function(ent)
			if ent:IsPlayer() then return true end
		end
	}

	tr = util.TraceLine(tr)
	if tr.Entity == target then

		self:SetNWVector("LaserTarget", Pos)


		self:SetNWBool("LaserActive", true)


		timer.Simple(0.5, function()
			if IsValid(self) then
				self:SetNWBool("LaserActive", false)
			end
		end)

		local Bullet = self:GetBulletInfo(target, Pos)
		self:FireBullets(Bullet)
		self:EmitSound(self.Sounds)
	end
end


function ENT:GetBulletInfo(target, pos)
	return {
		Attacker = self:CPPIGetOwner(),
		Num = 1,
		Damage = self.Damage,
		Force = 1,
		TracerName = "AR2Tracer",
		Spread = Vector(self.Spread, self.Spread, 0),
		Src = self.EyePosOffset,
		Dir = pos - self.EyePosOffset
	}
end