local Task = {}

Task.Name = "Prestige"

Task.Description = "Desc_Prestige"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = 1

Task.AddHook = function()
	hook.Add( "BaseWars:Prestige:OnPlayerPrestige", "ADR_TaskPrestige", function( ply, oldPrestige, newPrestige )
		if !ADRewards.SeasonNow then return end
		if !IsValid(ply) then return end
		if !ply.TasksADR or !ply.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(ply, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Prestige"
ADRLang.fr[Task.Name] = "Prestige"

ADRLang.en[Task.Description] = "Prestige your character to the next level"
ADRLang.fr[Task.Description] = "Passez au prestige suivant avec votre personnage"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return BaseWars ~= nil
end

ADRewards.CreateTask(Task)
