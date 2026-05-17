local Task = {}

Task.Name = "SellLean"

Task.Description = "Desc_SellLean"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {5, 10, 20}

Task.AddHook = function()
	hook.Add( "lean_soldLean", "ADR_TaskSellLean", function( ply, count, sellprice )
		if !ADRewards.SeasonNow then return end
		if !IsValid(ply) then return end
		if !ply.TasksADR or !ply.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(ply, Task.Name, count or 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Lean Dealer"
ADRLang.fr[Task.Name] = "Dealer de Lean"

ADRLang.en[Task.Description] = "Sell the required amount of lean cups"
ADRLang.fr[Task.Description] = "Vendez le nombre requis de gobelets de lean"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return Lean ~= nil
end

ADRewards.CreateTask(Task)
