-- Interface utilisateur côté client pour le Blackjack DHTML
-- Gère les mises à jour réseau et l'affichage

if CLIENT then
	-- Réseau: Mise à jour de l'état du jeu
	net.Receive("Blackjack_UpdateGame", function()
		local playerHand = net.ReadTable()
		local dealerHand = net.ReadTable()
		local playerScore = net.ReadInt(32)
		local dealerScore = net.ReadInt(32)
		local playerTurn = net.ReadBool()
		local bet = net.ReadInt(32)
		
		if Blackjack.UI.HTML and Blackjack.UI.IsOpen then
			local playerHandJson = util.TableToJSON(playerHand)
			local dealerHandJson = util.TableToJSON(dealerHand)
			
			Blackjack.UI.HTML:Call(string.format("updateGameState('%s', '%s', %d, %d, %s, %d)", 
				playerHandJson, dealerHandJson, playerScore, dealerScore, 
				playerTurn and "true" or "false", bet))
		end
	end)
	
	-- Réseau: Afficher un message
	net.Receive("Blackjack_ShowMessage", function()
		local message = net.ReadString()
		local messageType = net.ReadString()
		
		if Blackjack.UI.HTML and Blackjack.UI.IsOpen then
			Blackjack.UI.HTML:Call(string.format("showMessage('%s', '%s')", message, messageType))
		end
	end)
	
	-- Réseau: Fin de partie
	net.Receive("Blackjack_GameOver", function()
		local result = net.ReadString()
		local message = net.ReadString()
		local messageType = net.ReadString()
		local winnings = net.ReadInt(32)
		local newBalance = net.ReadInt(32)
		
		if Blackjack.UI.HTML and Blackjack.UI.IsOpen then
			Blackjack.UI.HTML:Call(string.format("gameOver('%s', '%s', '%s', %d, %d)", 
				result, message, messageType, winnings, newBalance))
		end
	end)
	
	-- Extensions des fonctions UI pour la communication réseau
	function Blackjack.UI:UpdateGameState(playerHand, dealerHand, playerScore, dealerScore, playerTurn, bet)
		if not self.HTML or not self.IsOpen then return end
		
		local playerHandJson = util.TableToJSON(playerHand or {})
		local dealerHandJson = util.TableToJSON(dealerHand or {})
		
		self.HTML:Call(string.format("updateGameState('%s', '%s', %d, %d, %s, %d)", 
			playerHandJson, dealerHandJson, playerScore or 0, dealerScore or 0, 
			playerTurn and "true" or "false", bet or 0))
	end
	
	function Blackjack.UI:ShowNetworkMessage(message, messageType)
		if not self.HTML or not self.IsOpen then return end
		
		self.HTML:Call(string.format("showMessage('%s', '%s')", message or "", messageType or "info"))
	end
	
	function Blackjack.UI:GameOver(result, message, messageType, winnings, newBalance)
		if not self.HTML or not self.IsOpen then return end
		
		self.HTML:Call(string.format("gameOver('%s', '%s', '%s', %d, %d)", 
			result or "", message or "", messageType or "info", winnings or 0, newBalance or 0))
	end
	
	print("[Blackjack] UI client chargé avec succès")
end
