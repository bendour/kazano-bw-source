-- Initialisation du jeu Blackjack

Casino.RegisterGame("blackjack", {
	name = "Blackjack",
	displayName = "Blackjack",
	description = "Le classique du casino. Battez le croupier et obtenez 21 !",
	icon = "🃏",
	minBet = 1,
	maxBet = 10000,
	htmlFile = "blackjack/blackjack.html",
	
	-- Setup des fonctions JavaScript/Lua
	setupFunctions = function(html)
		if not IsValid(html) then return end
		
		-- Obtenir les informations du joueur
		html:AddFunction("blackjack", "getPlayerInfo", function()
			if LocalPlayer() and LocalPlayer():IsValid() then
				local balance = Casino.Currency.GetMoney(LocalPlayer())
				html:Call(string.format("updatePlayerInfo(%d)", balance))
			end
		end)
		
		-- Envoyer le solde immédiatement au chargement
		timer.Simple(0.1, function()
			if IsValid(html) and LocalPlayer() and LocalPlayer():IsValid() then
				-- Demander le solde au serveur pour être sûr d'avoir la bonne valeur
				net.Start("Casino_Blackjack_RequestBalance")
				net.SendToServer()
				
				-- Backup: utiliser le solde local aussi
				local balance = Casino.Currency.GetMoney(LocalPlayer())
				html:Call(string.format("updatePlayerInfo(%d)", balance))
			end
		end)
		
		-- Placer une mise
		html:AddFunction("blackjack", "placeBet", function(amount)
			if LocalPlayer() and LocalPlayer():IsValid() then
				net.Start("Casino_Blackjack_PlaceBet")
				net.WriteInt(amount, 32)
				net.SendToServer()
			end
		end)
		
		-- Tirer une carte (Hit)
		html:AddFunction("blackjack", "hit", function()
			if LocalPlayer() and LocalPlayer():IsValid() then
				net.Start("Casino_Blackjack_Hit")
				net.SendToServer()
			end
		end)
		
		-- Rester (Stand)
		html:AddFunction("blackjack", "stand", function()
			if LocalPlayer() and LocalPlayer():IsValid() then
				net.Start("Casino_Blackjack_Stand")
				net.SendToServer()
			end
		end)
		
		-- Doubler (Double Down)
		html:AddFunction("blackjack", "double", function()
			if LocalPlayer() and LocalPlayer():IsValid() then
				net.Start("Casino_Blackjack_Double")
				net.SendToServer()
			end
		end)
		
		-- Envoyer le résultat de la partie au serveur (OBSOLÈTE - le serveur gère tout maintenant)
		html:AddFunction("blackjack", "gameResult", function(result)
			-- Cette fonction n'est plus utilisée mais gardée pour compatibilité
			print("[Casino Blackjack] WARNING: gameResult appelé côté client - ignoré")
		end)
		
		-- Retourner au menu
		html:AddFunction("blackjack", "returnToMenu", function()
			if Casino.UI then
				Casino.UI:ReturnToMenu()
			end
		end)
	end
})

print("[Casino] Blackjack initialisé")
