local Task = {}

Task.Name = "CollectPrinter"

Task.Description = "Desc_CollectPrinter"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {5000, 10000, 25000, 50000}

Task.AddHook = function()
	hook.Add( "BaseWars:PlayerTakeMoneyInPrinter", "ADR_TaskCollectPrinter", function( ply, printer, money, xp )
		if !ADRewards.SeasonNow then return end
		if !IsValid(ply) then return end
		if !ply.TasksADR or !ply.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(ply, Task.Name, math.floor(money))
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Money Collector"
ADRLang.fr[Task.Name] = "Collecteur d'Argent"

ADRLang.en[Task.Description] = "Collect the required amount of money from your printers"
ADRLang.fr[Task.Description] = "Collectez le montant requis depuis vos imprimantes"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return BaseWars ~= nil
end

ADRewards.CreateTask(Task)
