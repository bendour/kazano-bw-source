local Task = {}

Task.Name = "RefineFuel"

Task.Description = "Desc_RefineFuel"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {25, 50, 100}

Task.AddHook = function()
	hook.Add( "zrush_OnFuelRefined", "ADR_TaskRefineFuel", function( refinery, outputAmount, fuelTypeID )
		if !ADRewards.SeasonNow then return end
		if !IsValid(refinery) then return end
		
		local ply = refinery:GetNWEntity("ownerent") or refinery:CPPIGetOwner()
		if !IsValid(ply) or !ply:IsPlayer() then return end
		if !ply.TasksADR or !ply.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(ply, Task.Name, outputAmount or 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Refiner"
ADRLang.fr[Task.Name] = "Raffineur"

ADRLang.en[Task.Description] = "Refine the required amount of fuel at your refinery"
ADRLang.fr[Task.Description] = "Raffinez la quantité requise de carburant"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return zrush ~= nil
end

ADRewards.CreateTask(Task)
