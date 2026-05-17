AddCSLuaFile()

SWEP.PrintName = "Blowtorch"
SWEP.Author = "JL"
SWEP.Spawnable = true
SWEP.ViewModelFOV = 65
SWEP.ViewModel = "models/weapons/v_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.Weight = 20
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = false
SWEP.Base = "weapon_base"
SWEP.Category = "BaseWars"
SWEP.FiresUnderwater = true

-- Configuration Blowtorch Standard
SWEP.Range = 100 -- Distance max
SWEP.AOERadius = 60 -- Rayon de zone d'effet
SWEP.Damage = 15 -- Dégâts de base par hit
SWEP.FireRate = 0.15 -- Taux de tir
SWEP.DamageFalloff = 0.10 -- Réduction de 10% par prop supplémentaire

SWEP.Sounds = {
	"ambient/energy/spark1.wav",
	"ambient/energy/spark2.wav",
	"ambient/energy/spark3.wav",
	"ambient/energy/spark4.wav",
	"ambient/energy/spark5.wav",
	"ambient/energy/spark6.wav"
}

SWEP.Primary.Damage = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Spread = 0.25
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0.01
SWEP.Primary.Force = 1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	self:SetHoldType("smg")
end

-- Trouver tous les props ennemis dans la zone
function SWEP:FindTargetProps(ply, hitPos)
	local props = {}
	
	for _, ent in ipairs(ents.FindInSphere(hitPos, self.AOERadius)) do
		if IsValid(ent) and ent:GetClass() == "prop_physics" then
			local entityOwner = ent:CPPIGetOwner()
			
			if IsValid(entityOwner) and entityOwner:IsPlayer() then
				-- Vérifier que c'est un prop ennemi
				if entityOwner ~= ply and entityOwner:Enemy(ply) then
					-- Vérifier la ligne de vue
					local tr = util.TraceLine({
						start = ply:GetShootPos(),
						endpos = ent:GetPos(),
						filter = ply
					})
					
					if tr.Entity == ent or not tr.Hit then
						table.insert(props, ent)
					end
				end
			end
		end
	end
	
	return props
end

function SWEP:PrimaryAttack()
	if not BaseWars then return false end
	if not BaseWars:RaidGoingOn() then return false end

	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	
	-- Trace pour trouver le point d'impact
	local tr = util.TraceLine({
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + ply:GetAimVector() * self.Range,
		filter = ply
	})

	self:ShootEffects()
	
	if SERVER and IsFirstTimePredicted() then
		local hitPos = tr.HitPos
		local props = self:FindTargetProps(ply, hitPos)
		
		-- Trier les props par distance (le plus proche en premier)
		table.sort(props, function(a, b)
			return ply:GetPos():DistToSqr(a:GetPos()) < ply:GetPos():DistToSqr(b:GetPos())
		end)
		
		local hitCount = 0
		for i, ent in ipairs(props) do
			if IsValid(ent) then
				-- Dégâts dégressifs: 100% pour le 1er, 90% pour le 2ème, 80% pour le 3ème, etc.
				local damageMultiplier = math.max(0.1, 1 - (self.DamageFalloff * (i - 1)))
				local damage = self.Damage * damageMultiplier
				
				-- Appliquer les dégâts
				ent:SetHealth(ent:Health() - damage)
				
				-- Effet visuel sur chaque prop touché
				local effectData = EffectData()
				effectData:SetOrigin(ent:GetPos())
				effectData:SetScale(1)
				util.Effect("sparks", effectData)
				
				hitCount = hitCount + 1
				
				-- Détruire si HP <= 0
				if ent:Health() <= 0 then
					-- Petit effet d'explosion
					local explodeEffect = EffectData()
					explodeEffect:SetOrigin(ent:GetPos())
					explodeEffect:SetScale(2)
					util.Effect("Explosion", explodeEffect)
					
					ent:Remove()
				end
			end
		end
		
		-- Son seulement si on a touché quelque chose
		if hitCount > 0 then
			ply:EmitSound(table.Random(self.Sounds), 70)
		end
	end

	self:SetNextPrimaryFire(CurTime() + self.FireRate)
end

function SWEP:SecondaryAttack()
	-- Pas d'attaque secondaire
end