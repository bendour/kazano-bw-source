AddCSLuaFile()

SWEP.PrintName = "Blowtorch VIP"
SWEP.Author = "JL"
SWEP.Spawnable = true
SWEP.ViewModelFOV = 65
SWEP.ViewModel = "models/weapons/v_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.Slot = 5
SWEP.SlotPos = 2
SWEP.Weight = 20
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = false
SWEP.Base = "weapon_base"
SWEP.Category = "BaseWars"
SWEP.FiresUnderwater = true

-- Configuration Blowtorch VIP (améliorée)
SWEP.Range = 120 -- Distance max (+20% vs standard)
SWEP.AOERadius = 80 -- Rayon de zone d'effet (+33% vs standard)
SWEP.Damage = 22 -- Dégâts de base par hit (+47% vs standard)
SWEP.FireRate = 0.12 -- Taux de tir (+20% plus rapide)
SWEP.DamageFalloff = 0.08 -- Réduction de 8% par prop (moins de perte)

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
				if entityOwner ~= ply and entityOwner:Enemy(ply) then
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
				-- Dégâts dégressifs: 100% pour le 1er, 92% pour le 2ème, 84% pour le 3ème, etc.
				local damageMultiplier = math.max(0.1, 1 - (self.DamageFalloff * (i - 1)))
				local damage = self.Damage * damageMultiplier
				
				-- Appliquer les dégâts
				ent:SetHealth(ent:Health() - damage)
				
				-- Effet visuel VIP (plus intense)
				local effectData = EffectData()
				effectData:SetOrigin(ent:GetPos())
				effectData:SetScale(1.5)
				util.Effect("sparks", effectData)
				
				hitCount = hitCount + 1
				
				if ent:Health() <= 0 then
					local explodeEffect = EffectData()
					explodeEffect:SetOrigin(ent:GetPos())
					explodeEffect:SetScale(2.5)
					util.Effect("Explosion", explodeEffect)
					
					ent:Remove()
				end
			end
		end
		
		if hitCount > 0 then
			ply:EmitSound(table.Random(self.Sounds), 75)
		end
	end

	self:SetNextPrimaryFire(CurTime() + self.FireRate)
end

function SWEP:SecondaryAttack()
end
