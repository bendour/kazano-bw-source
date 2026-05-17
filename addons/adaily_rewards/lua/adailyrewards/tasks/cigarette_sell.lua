local Task = {}

Task.Name = "SellCigarettes"

Task.Description = "Desc_SellCigarettes"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {25, 50, 100}

Task.AddHook = function()
	hook.Add( "CigaretteFactory:PlayerSellCigarettes", "ADR_TaskSellCigarettes", function( ply, van, cigAmount, payOut )
		if !ADRewards.SeasonNow then return end
		if !IsValid(ply) then return end
		if !ply.TasksADR or !ply.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(ply, Task.Name, cigAmount or 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Tobacco Magnate"
ADRLang.fr[Task.Name] = "Magnat du Tabac"

ADRLang.en[Task.Description] = "Sell the required number of cigarettes"
ADRLang.fr[Task.Description] = "Vendez le nombre requis de cigarettes"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return CigaretteFactory ~= nil
end

ADRewards.CreateTask(Task)
