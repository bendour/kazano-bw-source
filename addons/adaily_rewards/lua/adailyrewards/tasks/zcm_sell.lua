local Task = {}

Task.Name = "SellFireworks"

Task.Description = "Desc_SellFireworks"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {10, 25, 50}

Task.AddHook = function()
	hook.Add( "zcm_OnFireworkSold", "ADR_TaskSellFireworks", function( ply, earning, fireworkCount )
		if !ADRewards.SeasonNow then return end
		if !IsValid(ply) then return end
		if !ply.TasksADR or !ply.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(ply, Task.Name, fireworkCount or 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Pyrotechnician"
ADRLang.fr[Task.Name] = "Artificier"

ADRLang.en[Task.Description] = "Sell the required number of fireworks"
ADRLang.fr[Task.Description] = "Vendez le nombre requis de feux d'artifice"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return zcm ~= nil
end

ADRewards.CreateTask(Task)
