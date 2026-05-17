local Task = {}

Task.Name = "BuyEntities"

Task.Description = "Desc_BuyEntities"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {5, 10, 20}

Task.AddHook = function()
	hook.Add( "BaseWars:BuyEntity", "ADR_TaskBuyEntities", function( ply, entity, entityID )
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
ADRLang.en[Task.Name] = "Big Spender"
ADRLang.fr[Task.Name] = "Grand Dépensier"

ADRLang.en[Task.Description] = "Purchase the required number of entities from the shop"
ADRLang.fr[Task.Description] = "Achetez le nombre requis d'entités dans la boutique"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return BaseWars ~= nil
end

ADRewards.CreateTask(Task)
