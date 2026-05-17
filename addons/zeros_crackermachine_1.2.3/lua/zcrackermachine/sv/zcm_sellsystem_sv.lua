if not SERVER then return end
zcm = zcm or {}
zcm.f = zcm.f or {}

function zcm.f.Sell_CrackerPack(ply, npc)

	// This checks if the player has the correct job to sell firework
	-- if zcm.f.IsCrackerMaker(ply) == false then
	-- 	zcm.f.Notify(ply, zcm.language.General["Wrong Job"], 1)

	-- 	return
	-- end

	local fireworkCount = 0

	// Get Fireworkcount from player var
	if ply:GetNWInt("zcm_firework", 0) > 0 then
		fireworkCount = fireworkCount + ply:GetNWInt("zcm_firework", 0)
		ply:SetNWInt("zcm_firework", 0)

		zcm.f.CreateNetEffect("sell_effect",ply:GetPos())
	end

	// GetFireworkcount from box entities arround npc
	// Getfireworkcount from palette entities arround npc
	for k, v in pairs(ents.FindInSphere(npc:GetPos(), 200)) do
		if IsValid(v) then
			if (v:GetClass() == "zcm_box" or v:GetClass() == "zcm_palette") and v:GetFireworkCount() > 0 and v:CPPIGetOwner() == ply then
				fireworkCount = fireworkCount + v:GetFireworkCount()
				SafeRemoveEntity(v)
				zcm.f.CreateNetEffect("sell_effect", v:GetPos())
			elseif v:GetClass() == "zcm_firecracker" and v:CPPIGetOwner() == ply then
				fireworkCount = fireworkCount + 1
				SafeRemoveEntity(v)
				zcm.f.CreateNetEffect("sell_effect", v:GetPos())
			end
		end
	end

	if fireworkCount <= 0 then
		zcm.f.Notify(ply,"No firework found!", 1)
		return
	end


	// This calculates the earning amount according to the player rank
	local earning = zcm.config.NPC.SellPrice[zcm.f.GetPlayerRank(ply)]
	if earning == nil then
		earning = zcm.config.NPC.SellPrice["Default"]
	end
	earning = earning * fireworkCount

	// If the firework gets sold by a npc then we multiply the earning times the price modifier
	if IsValid(npc) then
		earning = earning * ((1 / 100) * npc:GetPriceModifier())
	end

	// Custom Hook
	hook.Run("zcm_OnFireworkSold" ,ply,earning,fireworkCount)

	// Here we give the player the money
	local xp = math.floor(BaseWars:CalculatePlayerXP(ply, BaseWars:CalculateXPFromMultiplier(earning) * .01))
	zcm.f.GiveMoney(ply, earning)
	ply:AddXP(xp)

	zcm.f.Notify(ply, "+ " .. BaseWars:FormatMoney(earning), 0)
	zcm.f.Notify(ply, "+ " .. BaseWars:FormatNumber(xp) .. " XP!", 0)
end

hook.Add( "EntityTakeDamage", "zcm_EntityTakeDamage_NPCFix", function( target, dmginfo )
	if IsValid(target) and target:GetClass() == "zcm_buyer_npc" then
		return true
	end
end )
