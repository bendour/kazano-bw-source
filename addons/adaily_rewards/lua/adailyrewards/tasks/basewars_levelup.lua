local Task = {}

Task.Name = "GainLevel"

Task.Description = "Desc_GainLevel"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {1, 2, 3}

Task.AddHook = function()
	hook.Add( "PlayerGainLevel", "ADR_TaskGainLevel", function( ply, oldLevel, newLevel, gotLevel )
		if !ADRewards.SeasonNow then return end
		if !IsValid(ply) then return end
		if !ply.TasksADR or !ply.TasksADR[Task.Name] then return end

		local levelsGained = gotLevel or 1
		ADRewards.GiveTaskVal(ply, Task.Name, levelsGained)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Level Up"
ADRLang.fr[Task.Name] = "Monter de Niveau"

ADRLang.en[Task.Description] = "Gain the required number of levels"
ADRLang.fr[Task.Description] = "Gagnez le nombre de niveaux requis"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return BaseWars ~= nil
end

ADRewards.CreateTask(Task)
