local Task = {}

Task.Name = "StartRaid"

Task.Description = "Desc_StartRaid"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {1, 2, 3}

Task.AddHook = function()
	hook.Add( "BaseWars:RaidStarted", "ADR_TaskStartRaid", function( ply, raidType, attackerData, defenderData )
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
ADRLang.en[Task.Name] = "Raider"
ADRLang.fr[Task.Name] = "Raideur"

ADRLang.en[Task.Description] = "Start the required number of raids on enemy bases"
ADRLang.fr[Task.Description] = "Lancez le nombre requis de raids sur des bases ennemies"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return BaseWars ~= nil
end

ADRewards.CreateTask(Task)
