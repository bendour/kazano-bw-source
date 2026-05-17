local Task = {}

Task.Name = "SellWeed"

Task.Description = "Desc_SellWeed"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {10, 25, 50}

Task.AddHook = function()
	hook.Add( "zwf_OnWeedSold", "ADR_TaskSellWeed", function( ply, npc, earning, weedBlockCount )
		if !ADRewards.SeasonNow then return end
		if !IsValid(ply) then return end
		if !ply.TasksADR or !ply.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(ply, Task.Name, weedBlockCount or 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Sell Weed"
ADRLang.fr[Task.Name] = "Vendre du Cannabis"

ADRLang.en[Task.Description] = "Sell the required amount of weed blocks"
ADRLang.fr[Task.Description] = "Vendez la quantité requise de blocs de cannabis"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return zwf ~= nil
end

ADRewards.CreateTask(Task)
