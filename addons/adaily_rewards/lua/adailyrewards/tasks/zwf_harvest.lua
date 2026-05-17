local Task = {}

Task.Name = "HarvestWeed"

Task.Description = "Desc_HarvestWeed"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {5, 10, 20}

Task.AddHook = function()
	hook.Add( "zwf_OnPlantHarvest", "ADR_TaskHarvestWeed", function( flowerpot, ply )
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
ADRLang.en[Task.Name] = "Harvest Weed"
ADRLang.fr[Task.Name] = "Récolter du Cannabis"

ADRLang.en[Task.Description] = "Harvest the required number of weed plants"
ADRLang.fr[Task.Description] = "Récoltez le nombre requis de plants de cannabis"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return zwf ~= nil
end

ADRewards.CreateTask(Task)
