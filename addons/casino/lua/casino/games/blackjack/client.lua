-- Côté client du Blackjack
-- Ce fichier n'est chargé que côté client

-- Recevoir les résultats de transaction
net.Receive("Casino_Blackjack_Result", function()
	local success = net.ReadBool()
	local newBalance = net.ReadInt(32)
	local message = net.ReadString()
	
	if Casino.UI and Casino.UI.IsOpen and Casino.UI.HTML and IsValid(Casino.UI.HTML) then
		Casino.UI.HTML:Call(string.format("luaTransactionComplete(%s, %d, '%s')", 
			tostring(success), newBalance, message:gsub("'", "\\'")))
	end
end)

-- Recevoir les mises à jour de solde
net.Receive("Casino_Blackjack_UpdateBalance", function()
	local newBalance = net.ReadInt(32)
	
	if Casino.UI and Casino.UI.IsOpen and Casino.UI.HTML and IsValid(Casino.UI.HTML) then
		Casino.UI.HTML:Call(string.format("updatePlayerInfo(%d)", newBalance))
	end
end)

-- Recevoir l'état du jeu depuis le serveur
net.Receive("Casino_Blackjack_GameState", function()
	local state = net.ReadTable()
	
	if Casino.UI and Casino.UI.IsOpen and Casino.UI.HTML and IsValid(Casino.UI.HTML) then
		Casino.UI.HTML:Call(string.format("receiveGameState(%s)", util.TableToJSON(state)))
	end
end)

-- Recevoir le résultat final de la partie
net.Receive("Casino_Blackjack_GameResult", function()
	local result = net.ReadString()
	local winAmount = net.ReadInt(32)
	
	if Casino.UI and Casino.UI.IsOpen and Casino.UI.HTML and IsValid(Casino.UI.HTML) then
		Casino.UI.HTML:Call(string.format("showGameResult('%s', %d)", result, winAmount))
	end
end)

print("[Casino Blackjack] Module client chargé")
