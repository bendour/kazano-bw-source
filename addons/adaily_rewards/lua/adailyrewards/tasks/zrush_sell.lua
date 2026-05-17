local Task = {}

Task.Name = "SellFuel"

Task.Description = "Desc_SellFuel"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {50, 100, 200}

Task.AddHook = function()
	hook.Add( "zrush_OnFuelSold", "ADR_TaskSellFuel", function( ply, sellAmount, fuelID, earning, npc )
		if !ADRewards.SeasonNow then return end
		if !IsValid(ply) then return end
		if !ply.TasksADR or !ply.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(ply, Task.Name, sellAmount or 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Oil Baron"
ADRLang.fr[Task.Name] = "Baron du Pétrole"

ADRLang.en[Task.Description] = "Sell the required amount of fuel"
ADRLang.fr[Task.Description] = "Vendez la quantité de carburant requise"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return zrush ~= nil
end

ADRewards.CreateTask(Task)
