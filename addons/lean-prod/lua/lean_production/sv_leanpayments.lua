hook.Add("PostGamemodeLoaded", "lean_waitForCFG", function()
	function lean_config.addMoney(ply, amt)
		local gmd = string.lower(engine.ActiveGamemode())
		if gmd == "tg" || gmd == "policerp" || DarkRP then
			ply:addMoney(amt)
            local xp = math.floor(BaseWars:CalculatePlayerXP(ply, BaseWars:CalculateXPFromMultiplier(amt) * .02))
			ply:AddXP(xp)
		elseif gmd == "darkrp" then
			ply:GiveMoney(amt)
            local xp = math.floor(BaseWars:CalculatePlayerXP(ply, BaseWars:CalculateXPFromMultiplier(amt) * .02))
			ply:AddXP(xp)
		elseif gmd == "sandbox" && PS && PS.Config then
			ply:PS_GivePoints(amt)
		end
	end
	function lean_config.payMoney(ply, amt)
		local gmd = string.lower(engine.ActiveGamemode())
		if gmd == "ntm" || gmd == "policerp" || DarkRP then
			if ply:canAfford(amt) then
				ply:addMoney(-amt)
				return true
			else
				return false
			end
		elseif gmd == "basewars" then
			if ply:GetMoney() >= amt then
				ply:TakeMoney(amt)
				return true
			else
				return false
			end
		elseif gmd == "sandbox" && PS && PS.Config then
			if ply:PS_HasPoints(amt) then
				ply:PS_TakePoints(amt)
				return true
			else
				return false
			end
		end
	end
end)
local function NewIngredient(ply, name, success, info)
	if !name || success == nil then return end
	hook.Run("lean_ingredient", unpack({ply, name, success, info}))
end
net.Receive("lean_buyingredient", function(_,ply)
	if ply.leancooldown ~= nil then
		if CurTime() < ply.leancooldown + lean_updated.ingredientscooldown.val then
			-- Message supprimé: "Please wait the cooldown."
			return
		end
	end
	local item = net.ReadString()
	local mixer = net.ReadEntity()
	if ply:GetPos():Distance(mixer:GetPos()) > 500 then return end
	if item == "sprite"then
		if mixer:Getsprite_num() >= lean_updated.requiredsprite.val then
			-- Message supprimé: "Sprite is full."
			NewIngredient(mixer:Getowning_ent(), item, false, "Sprite is full")
			return
		end
		if lean_config.payMoney(ply, lean_updated.sprite_price.val) then
			mixer:Setsprite_num(mixer:Getsprite_num()+1)
			-- Message supprimé: "Purchased 1 Sprite"
			NewIngredient(mixer:Getowning_ent(), item, true)
		else
			-- Message supprimé: "You can't afford this."
			NewIngredient(mixer:Getowning_ent(), item, false, "You can't afford this")
		end
	elseif item == "codeine"then
		if mixer:Getcodeine_num() >= lean_updated.requiredcodeine.val then
			-- Message supprimé: "Codeine is full."
			NewIngredient(mixer:Getowning_ent(), item, false, "Codeine is full")
			return
		end
		if lean_config.payMoney(ply, lean_updated.codeine_price.val) then
			mixer:Setcodeine_num(mixer:Getcodeine_num()+1)
			-- Message supprimé: "Purchased 1 Codeine"
			NewIngredient(mixer:Getowning_ent(), item, true)
		else
			-- Message supprimé: "You can't afford this."
			NewIngredient(mixer:Getowning_ent(), item, false, "You can't afford this")
		end
	elseif item == "ranchers"then
		if mixer:Getranchers_num() >= lean_updated.requiredranchers.val then
			-- Message supprimé: "Jolly-Ranchers are full."
			NewIngredient(mixer:Getowning_ent(), item, false, "Jolly-Ranchers are full")
			return
		end
		if lean_config.payMoney(ply, lean_updated.ranchers_price.val) then
			mixer:Setranchers_num(mixer:Getranchers_num()+1)
			-- Message supprimé: "Purchased 1 Jolly-Rancher"
			NewIngredient(mixer:Getowning_ent(), item, true)
		else
			-- Message supprimé: "You can't afford this."
			NewIngredient(mixer:Getowning_ent(), item, false, "You can't afford this")
		end
	elseif item == "ice"then
		if mixer:Getice_num() >= lean_updated.requiredice.val then
			-- Message supprimé: "Ice Cubes are full."
			NewIngredient(mixer:Getowning_ent(), item, false, "Ice Cubes are full")
			return
		end
		if lean_config.payMoney(ply, lean_updated.ice_price.val) then
			mixer:Setice_num(mixer:Getice_num()+1)
			-- Message supprimé: "Purchased 1 Ice Cube"
			NewIngredient(mixer:Getowning_ent(), item, true)
		else
			-- Message supprimé: "You can't afford this."
			NewIngredient(mixer:Getowning_ent(), item, false, "You can't afford this")
		end
	end
	ply.leancooldown = CurTime()
end)