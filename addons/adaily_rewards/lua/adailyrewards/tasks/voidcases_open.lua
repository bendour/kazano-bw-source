local Task = {}

Task.Name = "OpenCases"

Task.Description = "Desc_OpenCases"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {1, 3, 5}

Task.AddHook = function()
	hook.Add( "VoidCases.CaseUnboxed", "ADR_TaskOpenCases", function( ply, unboxedItem, unboxedID, case )
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
ADRLang.en[Task.Name] = "Case Opener"
ADRLang.fr[Task.Name] = "Ouvreur de Caisses"

ADRLang.en[Task.Description] = "Open the required number of cases"
ADRLang.fr[Task.Description] = "Ouvrez le nombre requis de caisses"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return VoidCases ~= nil
end

ADRewards.CreateTask(Task)
