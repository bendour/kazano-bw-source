/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 20
	local ent = ents.Create(self.ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	self:SetModel(zpn.Theme.Bomb.model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)

	self:SetCustomCollisionCheck(true)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then

		//phys:SetMass(5)
		phys:EnableMotion(true)
		phys:EnableDrag(true)
		phys:Wake()
		if self.FlyDirection then
			phys:ApplyForceCenter(phys:GetMass() * (self.FlyDirection * 2))
			phys:ApplyTorqueCenter(phys:GetMass() * self.FlyDirection)
		end
	end

	self.Destroyd = false

	self:PrecacheGibs()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

	// Give it some random orange color
	self:SetColor(zpn.Theme.Destructibles.getcolor())


	timer.Simple(zpn.config.Boss.Bombs.ExploDelay, function()
		if IsValid(self) and self.Destroyd == false then
			self:ExplodePumpkin()
		end
	end)
end

function ENT:DestroyPumpkin()
	if self.Destroyd then return end

	zclib.Debug("DestroyPumpkin")

	self.Destroyd = true

	zclib.NetEvent.Create("zpn_destructable_destroy", {self})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

	self:SetNoDraw(true)

	zclib.NetEvent.Create("zpn_bomb_removefuse", {self})

	// Freeze Entity
	timer.Simple(0, function()
		if IsValid(self) then
			local phys = self:GetPhysicsObject()

			if IsValid(phys) then
				phys:Wake()
				phys:EnableMotion(false)
			end

			self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		end
	end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

	SafeRemoveEntityDelayed(self,1)
end

function ENT:ExplodePumpkin()
	if self.Destroyd then return end

	self:DestroyPumpkin()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

	zclib.Debug("ExplodePumpkin")
	self.Destroyd = true

	zclib.NetEvent.Create("zpn_bomb_explode", {self})

	// Make Damage for players in distance
	local exPos = self:GetPos()
	for k, v in pairs(zclib.Player.List) do
		if IsValid(v) and v:Alive() and zclib.util.InDistance(exPos, v:GetPos(), 150) then
			local d = DamageInfo()
			d:SetDamage(zpn.config.Boss.Bombs.Damage)
			if IsValid(self.BombShooter) then
				d:SetAttacker(self.BombShooter)
			elseif IsValid(self) then
				d:SetAttacker(self)
			end
			d:SetDamageType(DMG_GENERIC)
			v:TakeDamageInfo(d)
		end
	end
end

function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetDamage() > 5 and IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() then
		self:DestroyPumpkin()
	end
end
