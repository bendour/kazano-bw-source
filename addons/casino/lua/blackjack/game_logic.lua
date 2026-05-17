-- Logique de jeu du Blackjack côté serveur
-- Contient les fonctions avancées de jeu et de validation

if SERVER then
	Blackjack.GameLogic = Blackjack.GameLogic or {}
	
	-- Fonctions avancées de validation de jeu
	function Blackjack.GameLogic.ValidateGame(game)
		if not game then return false, "Jeu invalide" end
		
		-- Vérifier que le jeu a un joueur valide
		if not IsValid(game.player) then
			return false, "Joueur invalide"
		end
		
		-- Vérifier que le deck est valide
		if not game.deck or #game.deck == 0 then
			return false, "Deck invalide"
		end
		
		-- Vérifier que les mains sont valides
		if not game.playerHand or not game.dealerHand then
			return false, "Mains invalides"
		end
		
		-- Vérifier que la mise est valide
		if game.bet < 0 then
			return false, "Mise invalide"
		end
		
		return true, "Jeu valide"
	end
	
	-- Fonction pour créer un deck multiple (pour plus de réalisme)
	function Blackjack.GameLogic.CreateMultipleDeck(decks)
		decks = decks or 6 -- Standard: 6 decks
		local fullDeck = {}
		
		for d = 1, decks do
			local singleDeck = Blackjack.CreateDeck()
			for _, card in ipairs(singleDeck) do
				table.insert(fullDeck, card)
			end
		end
		
		-- Mélanger le deck multiple
		for i = #fullDeck, 2, -1 do
			local j = math.random(i)
			fullDeck[i], fullDeck[j] = fullDeck[j], fullDeck[i]
		end
		
		return fullDeck
	end
	
	-- Fonction pour vérifier si le deck doit être reshufflé
	function Blackjack.GameLogic.ShouldReshuffle(deck)
		if not deck then return true end
		
		-- Reshuffler si moins de 25% des cartes restent
		local originalSize = 52 * 6 -- 6 decks standard
		local currentSize = #deck
		
		return currentSize < (originalSize * 0.25)
	end
	
	-- Fonction pour obtenir la probabilité de bust
	function Blackjack.GameLogic.GetBustProbability(handValue)
		if handValue >= 21 then return 1.0 end
		if handValue <= 11 then return 0.0 end
		
		-- Calcul simple basé sur la valeur actuelle
		local riskLevels = {
			[12] = 0.08, [13] = 0.12, [14] = 0.16, [15] = 0.20,
			[16] = 0.24, [17] = 0.28, [18] = 0.32, [19] = 0.36, [20] = 0.40
		}
		
		return riskLevels[handValue] or 0.5
	end
	
	-- Fonction pour calculer les statistiques du joueur
	function Blackjack.GameLogic.GetPlayerStats(ply)
		if not IsValid(ply) then return nil end
		
		local steamid = ply:SteamID()
		local stats = ply._blackjackStats or {
			gamesPlayed = 0,
			gamesWon = 0,
			gamesLost = 0,
			gamesPush = 0,
			blackjacks = 0,
			busts = 0,
			totalBet = 0,
			totalWon = 0,
			biggestWin = 0,
			biggestLoss = 0
		}
		
		return stats
	end
	
	-- Mettre à jour les statistiques du joueur
	function Blackjack.GameLogic.UpdatePlayerStats(ply, result, bet, winnings)
		if not IsValid(ply) then return end
		
		local stats = Blackjack.GameLogic.GetPlayerStats(ply)
		
		stats.gamesPlayed = stats.gamesPlayed + 1
		stats.totalBet = stats.totalBet + bet
		
		if result == "win" or result == "blackjack" then
			stats.gamesWon = stats.gamesWon + 1
			stats.totalWon = stats.totalWon + winnings
			if winnings > stats.biggestWin then
				stats.biggestWin = winnings
			end
		elseif result == "lose" or result == "bust" then
			stats.gamesLost = stats.gamesLost + 1
			if bet > stats.biggestLoss then
				stats.biggestLoss = bet
			end
		elseif result == "push" then
			stats.gamesPush = stats.gamesPush + 1
		end
		
		if result == "blackjack" then
			stats.blackjacks = stats.blackjacks + 1
		elseif result == "bust" then
			stats.busts = stats.busts + 1
		end
		
		ply._blackjackStats = stats
		
		-- Sauvegarder les statistiques (optionnel)
		if Blackjack:GetConfig("Security.LogTransactions") then
			print(string.format("[Blackjack] Stats %s - Parties: %d, Victoires: %d, Taux: %.1f%%", ply:Nick(), stats.gamesPlayed, stats.gamesWon, stats.gamesPlayed > 0 and (stats.gamesWon / stats.gamesPlayed * 100) or 0))
		end
	end
	
	-- Fonction pour obtenir les cartes recommandées (IA simple)
	function Blackjack.GameLogic.GetRecommendedAction(playerHand, dealerUpCard)
		local playerValue = Blackjack.CalculateHandValue(playerHand)
		local dealerValue = dealerUpCard.value
		
		-- Stratégie de base simplifiée
		if playerValue <= 11 then
			return "hit" -- Toujours tirer
		elseif playerValue >= 17 then
			return "stand" -- Toujours rester
		elseif playerValue == 12 and dealerValue >= 4 and dealerValue <= 6 then
			return "stand" -- Rester contre 4-6
		elseif playerValue >= 13 and playerValue <= 16 and dealerValue >= 2 and dealerValue <= 6 then
			return "stand" -- Rester contre 2-6
		else
			return "hit" -- Sinon tirer
		end
	end
	
	-- Fonction pour calculer l'avantage de la maison
	function Blackjack.GameLogic.CalculateHouseEdge()
		-- Avantage de base du blackjack avec règles standard
		local baseEdge = 0.005 -- 0.5%
		
		-- Ajustements basés sur la configuration
		local config = Blackjack:GetConfig("Game")
		
		if config.BlackjackPayout > 2.5 then
			baseEdge = baseEdge - 0.02 -- Meilleur paiement réduit l'avantage
		elseif config.BlackjackPayout < 2.5 then
			baseEdge = baseEdge + 0.02 -- Moins bon paiement augmente l'avantage
		end
		
		if config.DealerStandOn == 17 then
			-- Standard, pas de changement
		elseif config.DealerStandOn == 16 then
			baseEdge = baseEdge + 0.01 -- Avantage joueur
		end
		
		if not config.AllowDoubleDown then
			baseEdge = baseEdge + 0.01 -- Avantage maison
		end
		
		if not config.AllowSplit then
			baseEdge = baseEdge + 0.005 -- Avantage maison
		end
		
		return baseEdge
	end
	
	-- Fonction pour détecter les comportements suspects
	function Blackjack.GameLogic.DetectSuspiciousActivity(ply)
		if not IsValid(ply) then return false end
		
		local stats = Blackjack.GameLogic.GetPlayerStats(ply)
		
		-- Taux de victoire anormalement élevé
		if stats.gamesPlayed >= 20 then
			local winRate = stats.gamesWon / stats.gamesPlayed
			if winRate > 0.7 then -- 70%+ est suspect
				print(string.format("[Blackjack] ATTENTION: %s a un taux de victoire suspect: %.1f%%", ply:Nick(), winRate * 100))
				return true
			end
		end
		
		-- Montants de paris inhabituels
		if stats.biggestWin > 50000 then -- Gains très élevés
			print(string.format("[Blackjack] ATTENTION: %s a un gain très élevé: %d", ply:Nick(), stats.biggestWin))
			return true
		end
		
		return false
	end
	
	-- Fonction pour générer un rapport de jeu
	function Blackjack.GameLogic.GenerateGameReport(ply, game, result)
		if not IsValid(ply) or not game then return nil end
		
		local report = {
			player = ply:Nick(),
			steamid = ply:SteamID(),
			timestamp = os.time(),
			bet = game.bet,
			result = result,
			playerHand = game.playerHand,
			dealerHand = game.dealerHand,
			playerScore = Blackjack.CalculateHandValue(game.playerHand),
			dealerScore = Blackjack.CalculateHandValue(game.dealerHand),
			gameDuration = game.endTime and (game.endTime - game.startTime) or 0
		}
		
		return report
	end
	
	-- Hook pour mettre à jour les statistiques à la fin de partie
	hook.Add("Blackjack.GameEnded", "UpdateStats", function(ply, result, bet, winnings)
		Blackjack.GameLogic.UpdatePlayerStats(ply, result, bet, winnings)
		
		-- EXPLOIT FIX: Libérer le flag de pari en cours
		if IsValid(ply) then
			ply.blackjackBetInProgress = false
			ply.blackjackCurrentBet = nil
		end
		
		-- Détecter les activités suspectes
		if Blackjack.GameLogic.DetectSuspiciousActivity(ply) then
			-- Envoyer une alerte aux administrateurs (optionnel)
			for _, admin in ipairs(player.GetAll()) do
				if admin:IsAdmin() then
					admin:Chatprint("[Blackjack] Activité suspecte détectée: " .. ply:Nick())
				end
			end
		end
	end)
	
	-- Commande admin pour voir les statistiques d'un joueur
	concommand.Add("blackjack_stats", function(ply, cmd, args)
		if ply and not ply:IsAdmin() then
			ply:Chatprint("Cette commande est réservée aux administrateurs.")
			return
		end
		
		local targetName = args[1]
		if not targetName then
			if ply then
				ply:Chatprint("Usage: blackjack_stats <nom_du_joueur>")
			else
				print("Usage: blackjack_stats <nom_du_joueur>")
			end
			return
		end
		
		local target = nil
		for _, p in ipairs(player.GetAll()) do
			if string.find(string.lower(p:Nick()), string.lower(targetName)) then
				target = p
				break
			end
		end
		
		if not target then
			local msg = "Joueur non trouvé: " .. targetName
			if ply then
				ply:Chatprint(msg)
			else
				print(msg)
			end
			return
		end
		
		local stats = Blackjack.GameLogic.GetPlayerStats(target)
		local msg = string.format("Stats de %s: Parties: %d, Victoires: %d, Défaites: %d, Nuls: %d, Taux: %.1f%%", 
			target:Nick(), stats.gamesPlayed, stats.gamesWon, stats.gamesLost, 
			stats.gamesPush, stats.gamesPlayed > 0 and (stats.gamesWon / stats.gamesPlayed * 100) or 0)
		
		if ply then
			ply:Chatprint(msg)
		else
			print(msg)
		end
	end)
	
	print("[Blackjack] Logique de jeu chargée avec succès")
end
