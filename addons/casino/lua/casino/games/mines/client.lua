-- Côté client du jeu Mines

if CLIENT then
	-- Recevoir l'état du jeu
	net.Receive("Casino_Mines_GameState", function()
		local state = net.ReadTable()
		
		if Casino.UI and Casino.UI.IsOpen and Casino.UI.HTML and IsValid(Casino.UI.HTML) then
			Casino.UI.HTML:Call(string.format("receiveGameState(%s)", util.TableToJSON(state)))
		end
	end)
	
	-- Recevoir le résultat final
	net.Receive("Casino_Mines_GameResult", function()
		local result = net.ReadString()
		local message = net.ReadString()
		local winAmount = net.ReadInt(32)
		
		if Casino.UI and Casino.UI.IsOpen and Casino.UI.HTML and IsValid(Casino.UI.HTML) then
			Casino.UI.HTML:Call(string.format("showGameResult('%s', '%s', %d)", 
				result, message:gsub("'", "\\'"), winAmount))
		end
	end)
	
	-- Mettre à jour le solde
	net.Receive("Casino_Mines_UpdateBalance", function()
		local balance = net.ReadInt(32)
		
		if Casino.UI and Casino.UI.IsOpen and Casino.UI.HTML and IsValid(Casino.UI.HTML) then
			Casino.UI.HTML:Call(string.format("updatePlayerInfo(%d)", balance))
		end
	end)
end
