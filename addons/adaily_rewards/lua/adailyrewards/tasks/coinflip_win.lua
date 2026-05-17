local Task = {}

Task.Name = "WinCoinflip"

Task.Description = "Desc_WinCoinflip"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {1, 2, 3}

Task.AddHook = function()
	hook.Add( "Coinflip.Played", "ADR_TaskWinCoinflip", function( author, player, totalMoney, winner, currency )
		if !ADRewards.SeasonNow then return end
		if !IsValid(winner) then return end
		if !winner.TasksADR or !winner.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(winner, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Lucky Flipper"
ADRLang.fr[Task.Name] = "Chanceux au Pile ou Face"

ADRLang.en[Task.Description] = "Win the required number of coinflips"
ADRLang.fr[Task.Description] = "Gagnez le nombre requis de pile ou face"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return Coinflip ~= nil
end

ADRewards.CreateTask(Task)
