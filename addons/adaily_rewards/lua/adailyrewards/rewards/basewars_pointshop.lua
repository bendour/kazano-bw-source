local Reward = {}

Reward.Name = "BaseWars Pointshop Points"

Reward.MaxAmount = 50000

Reward.CanTaskReward = true

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Reward.GiveReward = function(ply, amount, key)
	if ply.PS_GivePoints then
		ply:PS_GivePoints(amount)
	end
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
Reward.DrawType = 1 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;

local mat = Material( "adailyrewards/rewards/diamonds.png", "mips smooth" )
Reward.DrawFunc = function(key)
	return mat
end
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if BaseWars then return true end
	return false
end

ADRewards.CreateReward(Reward)
