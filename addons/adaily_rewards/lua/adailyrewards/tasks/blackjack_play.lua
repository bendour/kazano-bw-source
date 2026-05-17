local Task = {}

Task.Name = "PlayBlackjack"

Task.Description = "Desc_PlayBlackjack"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {3, 5, 10}

Task.AddHook = function()
	hook.Add( "Blackjack.GameEnded", "ADR_TaskPlayBlackjack", function( ply, result, bet, winnings )
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
ADRLang.en[Task.Name] = "Card Shark"
ADRLang.fr[Task.Name] = "Joueur de Cartes"

ADRLang.en[Task.Description] = "Play the required number of blackjack games"
ADRLang.fr[Task.Description] = "Jouez le nombre requis de parties de blackjack"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	return Blackjack ~= nil or Casino ~= nil
end

ADRewards.CreateTask(Task)
