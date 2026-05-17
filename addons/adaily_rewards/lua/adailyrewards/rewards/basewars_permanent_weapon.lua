local Reward = {}

Reward.Name = "BaseWars Permanent Weapon"

Reward.MaxAmount = 1

Reward.CanTaskReward = false

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Reward.GiveReward = function(ply, amount, key)
	-- key contient le nom de classe de l'arme (ex: "m9k_ak47")
	if BaseWars and BaseWars.PW then
		local steamID = ply:SteamID64()
		BaseWars.PW:AddWeapon(steamID, "0", key)
	end
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
Reward.DrawType = 2 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;

Reward.DrawFunc = function(key)
	local model = key
	local weptbl = weapons.Get(key)
	if weptbl then
		model = weptbl.WorldModel
	end
	return model
end

Reward.DrawKey = "Weapon Class"

Reward.GetKey = function(name)
	local key = false
	local weptbl = weapons.Get(name)
	if weptbl then key = name end
	return key
end

Reward.LangPhrase = "BWPermanentWeapon_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use the weapon class. You can get it from the Q Menu."
ADRLang.fr[Reward.LangPhrase] = "Utilisez la classe d'arme. Vous pouvez l'obtenir dans le menu Q."
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if BaseWars and BaseWars.PW then return true end
	return false
end

ADRewards.CreateReward(Reward)
