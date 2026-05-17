local Task = {}

Task.Name = "KillPlayers"

Task.Description = "Desc_KillPlayers"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {3, 5, 10}

Task.AddHook = function()
	hook.Add( "PlayerDeath", "ADR_TaskKillPlayers", function( victim, inflictor, attacker )
		if !ADRewards.SeasonNow then return end
		if !IsValid(attacker) or !attacker:IsPlayer() then return end
		if attacker == victim then return end -- No suicide
		if !attacker.TasksADR or !attacker.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(attacker, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Eliminator"
ADRLang.fr[Task.Name] = "Éliminateur"

ADRLang.en[Task.Description] = "Eliminate the required number of players"
ADRLang.fr[Task.Description] = "Éliminez le nombre requis de joueurs"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return true
end

ADRewards.CreateTask(Task)
