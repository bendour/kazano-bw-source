local Task = {}

Task.Name = "ProduceMeth"

Task.Description = "Desc_ProduceMeth"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {5, 10, 25}

Task.AddHook = function()
	hook.Add( "zmlab_OnMethMade", "ADR_TaskProduceMeth", function( ply, freezingTray, meth )
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
ADRLang.en[Task.Name] = "Meth Cook"
ADRLang.fr[Task.Name] = "Cuisinier de Méth"

ADRLang.en[Task.Description] = "Produce the required amount of meth crystals"
ADRLang.fr[Task.Description] = "Produisez la quantité requise de cristaux de méthamphétamine"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return zmlab ~= nil
end

ADRewards.CreateTask(Task)
