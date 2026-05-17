local Task = {}

Task.Name = "ClaimBounty"

Task.Description = "Desc_ClaimBounty"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {1, 2, 3}

Task.AddHook = function()
	hook.Add( "BaseWars:Bounty:ClaimBounty", "ADR_TaskClaimBounty", function( victim, attacker, bountyAmount )
		if !ADRewards.SeasonNow then return end
		if !IsValid(attacker) or !attacker:IsPlayer() then return end
		if !attacker.TasksADR or !attacker.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(attacker, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Bounty Hunter"
ADRLang.fr[Task.Name] = "Chasseur de Primes"

ADRLang.en[Task.Description] = "Claim the required number of bounties on players"
ADRLang.fr[Task.Description] = "Réclamez le nombre de primes requis sur des joueurs"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return BaseWars ~= nil
end

ADRewards.CreateTask(Task)
