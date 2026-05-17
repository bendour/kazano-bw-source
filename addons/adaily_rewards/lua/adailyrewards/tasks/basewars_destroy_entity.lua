local Task = {}

Task.Name = "DestroyEntity"

Task.Description = "Desc_DestroyEntity"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {3, 5, 10}

Task.AddHook = function()
	hook.Add( "BaseWars:PlayerDestroyEntity", "ADR_TaskDestroyEntity", function( entity, owner, attacker, inflictor, value )
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
ADRLang.en[Task.Name] = "Destroyer"
ADRLang.fr[Task.Name] = "Destructeur"

ADRLang.en[Task.Description] = "Destroy the required number of enemy entities during raids"
ADRLang.fr[Task.Description] = "Détruisez le nombre requis d'entités ennemies pendant les raids"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return BaseWars ~= nil
end

ADRewards.CreateTask(Task)
