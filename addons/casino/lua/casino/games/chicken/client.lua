-- Chicken Road Client-Side

if CLIENT then
	-- Recevoir le résultat d'une case
	net.Receive("Casino_Chicken_TileResult", function()
		local result = net.ReadTable()
		
		if ChickenJS then
			ChickenJS.updateGameState(result)
		end
	end)
	
	-- Recevoir le résultat de la partie
	net.Receive("Casino_Chicken_GameResult", function()
		local status = net.ReadString()
		local message = net.ReadString()
		local amount = net.ReadInt(32)
		
		if ChickenJS then
			ChickenJS.gameResult(status, message, amount)
		end
	end)
	
	-- Recevoir la mise à jour du solde
	net.Receive("Casino_Chicken_UpdateBalance", function()
		local balance = net.ReadInt(32)
		
		if ChickenJS then
			ChickenJS.updateBalance(balance)
		end
	end)
end
