if CLIENT then return end
zcm = zcm or {}
zcm.f = zcm.f or {}

local zcm_dropents = {
	["zcm_transport_pallet"] = true,
	["zcm_transport_box"] = true,
	["zcm_firecracker"] = true
}

function zcm.f.Entity_OnTakeDamage(ent, dmg, DestructionEffect)
	if (not ent.m_bApplyingDamage) then
		ent.m_bApplyingDamage = true
		ent:TakePhysicsDamage(dmg)
		local damage = dmg:GetDamage()
		local entHealth = zcm.config.Damageable[ent:GetClass()]

		if (entHealth > 0) then
			ent.CurrentHealth = (ent.CurrentHealth or entHealth) - damage
			zcm.f.Debug("zcm.f.Entity_OnTakeDamage: " .. ent.CurrentHealth)

			if (ent.CurrentHealth <= 0) then
				if zcm_dropents[ent:GetClass()] then
					hook.Run("zcm_OnFireworkDestroyed", ent, dmg)
				end

				if DestructionEffect then
					zcm.f.Destruct(ent, DestructionEffect)
				end

				return true
			end
		end

		ent.m_bApplyingDamage = false
	end
end
