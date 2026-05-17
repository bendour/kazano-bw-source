if CLIENT then return end
zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

local zmlab_dropents = {
	["zmlab_meth"] = true,
	["zmlab_meth_baggy"] = true,
	["zmlab_collectcrate"] = true,
	["zmlab_palette"] = true
}

-- function zmlab.f.Entity_OnTakeDamage(ent,dmg,DestructionEffect)
-- 	ent:TakePhysicsDamage(dmg)
-- 	local damage = dmg:GetDamage()
-- 	local entHealth = zmlab.config.Damageable[ent:GetClass()]

-- 	if (entHealth > 0) then

-- 		ent.CurrentHealth = (ent.CurrentHealth or entHealth) - damage
-- 		zmlab.f.Debug("zmlab.f.Entity_OnTakeDamage: " .. ent.CurrentHealth)

-- 		if (ent.CurrentHealth <= 0) then
-- 			if zmlab_dropents[ent:GetClass()] then
-- 				hook.Run("zmlab_OnMethObjectDestroyed", ent,dmg)
-- 			end
-- 			zmlab.f.Destruct(ent,DestructionEffect)
-- 			ent:Remove()
-- 		end
-- 	end
-- end
