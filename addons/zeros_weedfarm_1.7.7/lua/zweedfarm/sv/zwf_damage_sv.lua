if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}


function zwf.f.Entity_OnTakeDamage(ent,dmg)
	ent:TakePhysicsDamage(dmg)
	local damage = dmg:GetDamage()
	local entHealth = zwf.config.Damageable[ent:GetClass()]

	if (entHealth > 0) then
		ent.CurrentHealth = (ent.CurrentHealth or entHealth) - damage

		if (ent.CurrentHealth <= 0) then

			if ent:GetClass() == "zwf_plant" and IsValid(ent:GetParent()) then

				local Earning = zwf.config.Police.Reward["plant"]
				zwf.f.Police_Reward(dmg:GetAttacker(),Earning)

				local Flowerpot = ent:GetParent()
				local _seed = Flowerpot:GetSeed()

				// Kill plant
				if _seed ~= -1 then
					zwf.f.CreateEffectTable(zwf.config.Plants[_seed].death_effect, "zwf_cut_plant", Flowerpot, Flowerpot:GetAngles(), Flowerpot:GetPos() + Flowerpot:GetUp() * 35, nil)
				end

				zwf.f.Flowerpot_Reset(Flowerpot)

			elseif ent:GetClass() == "zwf_weedblock"  then
				local Earning = zwf.config.Police.Reward["weedblock"]
				zwf.f.Police_Reward(dmg:GetAttacker(),Earning)


			elseif ent:GetClass() == "zwf_weedstick"  then
				local Earning = zwf.config.Police.Reward["weedjunk"]
				zwf.f.Police_Reward(dmg:GetAttacker(),Earning)


			elseif ent:GetClass() == "zwf_palette"  then
				local Earning = zwf.config.Police.Reward["palette"] * ent:GetBlockCount()
				zwf.f.Police_Reward(dmg:GetAttacker(),Earning)

			elseif ent:GetClass() == "zwf_jar"  then
				local Earning = zwf.config.Police.Reward["weedjar"]
				zwf.f.Police_Reward(dmg:GetAttacker(),Earning)
			end

			ent:Remove()
		end
	end
end

// If the attacker is a player with a police job then we reward that player
function zwf.f.Police_Reward(ply, Earning)
	-- if IsValid(ply) and ply:IsPlayer() and ply:Alive() and zwf.config.Police.Jobs[zwf.f.GetPlayerJob(ply)] and Earning > 0 then
	-- 	zwf.f.GiveMoney(ply, Earning)
	-- 	zwf.f.Notify(ply, "+" .. zwf.config.Currency .. math.Round(Earning), 0)
	-- end
end
