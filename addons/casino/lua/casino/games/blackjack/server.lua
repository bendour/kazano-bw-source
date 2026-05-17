-- Côté serveur du Blackjack
-- Gère les transactions financières et la sécurité

if SERVER then
	util.AddNetworkString("Casino_Blackjack_PlaceBet")
	util.AddNetworkString("Casino_Blackjack_Result")
	util.AddNetworkString("Casino_Blackjack_GameResult")
	util.AddNetworkString("Casino_Blackjack_UpdateBalance")
	util.AddNetworkString("Casino_Blackjack_RequestBalance")
	util.AddNetworkString("Casino_Blackjack_Hit")
	util.AddNetworkString("Casino_Blackjack_Stand")
	util.AddNetworkString("Casino_Blackjack_Double")
	util.AddNetworkString("Casino_Blackjack_GameState")
	
	Casino.Blackjack = Casino.Blackjack or {}
	Casino.Blackjack.PlayerStats = {}
	Casino.Blackjack.ActiveBets = {} -- Stocker les mises actives
	Casino.Blackjack.ActiveGames = {} -- Stocker les parties en cours
	
	-- Anti-spam pour les actions
	local PlayerLastAction = {} -- {steamID = lastActionTime}
	local MIN_ACTION_DELAY = 0.5 -- 0.5 seconde entre chaque action
	
	-- Fonctions de gestion du deck
	local function CreateDeck()
		local deck = {}
		local suits = {"♠", "♥", "♦", "♣"}
		local ranks = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
		
		for _, suit in ipairs(suits) do
			for _, rank in ipairs(ranks) do
				local value = 0
				if rank == "A" then
					value = 11
				elseif rank == "J" or rank == "Q" or rank == "K" then
					value = 10
				else
					value = tonumber(rank)
				end
				
				table.insert(deck, {
					rank = rank,
					suit = suit,
					value = value
				})
			end
		end
		
		return deck
	end
	
	local function ShuffleDeck(deck)
		for i = #deck, 2, -1 do
			local j = math.random(i)
			deck[i], deck[j] = deck[j], deck[i]
		end
	end
	
	local function CalculateHandValue(hand)
		local value = 0
		local aces = 0
		
		for _, card in ipairs(hand) do
			value = value + card.value
			if card.rank == "A" then
				aces = aces + 1
			end
		end
		
		while value > 21 and aces > 0 do
			value = value - 10
			aces = aces - 1
		end
		
		return value
	end
	
	local function IsBlackjack(hand)
		return #hand == 2 and CalculateHandValue(hand) == 21
	end
	
	local function SendGameState(ply, game, hideDealer)
		if not IsValid(ply) or not game then return end
		
		net.Start("Casino_Blackjack_GameState")
		net.WriteTable({
			playerHand = game.playerHand,
			dealerHand = hideDealer and {game.dealerHand[1]} or game.dealerHand,
			playerScore = CalculateHandValue(game.playerHand),
			dealerScore = hideDealer and CalculateHandValue({game.dealerHand[1]}) or CalculateHandValue(game.dealerHand),
			bet = game.bet,
			canDouble = #game.playerHand == 2,
			hideDealer = hideDealer
		})
		net.Send(ply)
	end
	
	-- Vérifier la sécurité (anti-spam)
	local function CheckSecurity(ply)
		if not IsValid(ply) then return false end
		
		local steamid = ply:SteamID()
		local stats = Casino.Blackjack.PlayerStats[steamid] or {
			lastBet = 0,
			lastBetTime = 0,
			totalBets = 0
		}
		
		-- Anti-spam: 1 seconde entre les mises
		if CurTime() - stats.lastBetTime < 1 then
			return false, "Veuillez attendre avant de miser à nouveau."
		end
		
		stats.lastBetTime = CurTime()
		Casino.Blackjack.PlayerStats[steamid] = stats
		
		return true
	end
	
	-- Envoyer le résultat au client
	local function SendResult(ply, success, newBalance, message)
		if not IsValid(ply) then return end
		
		net.Start("Casino_Blackjack_Result")
		net.WriteBool(success)
		net.WriteInt(newBalance, 32)
		net.WriteString(message or "")
		net.Send(ply)
	end
	
	-- Gérer les mises
	net.Receive("Casino_Blackjack_PlaceBet", function(len, ply)
		-- Vérifier que le système de currency est initialisé
		if not Casino.Currency.Initialized then
			SendResult(ply, false, 0, "Le système de monnaie n'est pas encore initialisé. Veuillez réessayer dans quelques secondes.")
			return
		end
		
		local canBet, errorMsg = CheckSecurity(ply)
		if not canBet then
			SendResult(ply, false, Casino.Currency.GetMoney(ply), errorMsg)
			return
		end
		
		local bet = net.ReadInt(32)
		local minBet = Casino.Games.blackjack.minBet
		local maxBet = Casino.Games.blackjack.maxBet
		
		-- Valider la mise
		if bet < minBet or bet > maxBet then
			SendResult(ply, false, Casino.Currency.GetMoney(ply), 
				string.format("Mise invalide! Min: %d💎, Max: %d💎", minBet, maxBet))
			return
		end
		
		-- Vérifier les fonds
		if not Casino.Currency.CanAfford(ply, bet) then
			SendResult(ply, false, Casino.Currency.GetMoney(ply), "Solde insuffisant!")
			return
		end
		
		-- Retirer l'argent
		if not Casino.Currency.TakeMoney(ply, bet) then
			SendResult(ply, false, Casino.Currency.GetMoney(ply), "Erreur de transaction.")
			return
		end
		
		-- Mettre à jour les stats
		local steamid = ply:SteamID()
		local stats = Casino.Blackjack.PlayerStats[steamid]
		stats.totalBets = stats.totalBets + 1
		stats.lastBet = bet
		
		-- Stocker la mise active
		Casino.Blackjack.ActiveBets[steamid] = bet
		
		-- Créer une nouvelle partie
		local game = {
			deck = CreateDeck(),
			playerHand = {},
			dealerHand = {},
			bet = bet,
			doubled = false
		}
		
		ShuffleDeck(game.deck)
		
		-- Distribuer les cartes initiales
		table.insert(game.playerHand, table.remove(game.deck))
		table.insert(game.dealerHand, table.remove(game.deck))
		table.insert(game.playerHand, table.remove(game.deck))
		table.insert(game.dealerHand, table.remove(game.deck))
		
		Casino.Blackjack.ActiveGames[steamid] = game
		
		-- Envoyer la confirmation
		local newBalance = Casino.Currency.GetMoney(ply)
		SendResult(ply, true, newBalance, "Mise acceptée!")
		
		-- Envoyer l'état initial du jeu (carte du dealer cachée)
		SendGameState(ply, game, true)
		
		-- Vérifier le blackjack initial
		local playerValue = CalculateHandValue(game.playerHand)
		local dealerValue = CalculateHandValue(game.dealerHand)
		
		if IsBlackjack(game.playerHand) or IsBlackjack(game.dealerHand) then
			-- Révéler immédiatement
			timer.Simple(1, function()
				if not IsValid(ply) then return end
				ResolveGame(ply, steamid)
			end)
		end
		
		print(string.format("[Casino Blackjack] %s a misé %d$ (Solde: %d$)", 
			ply:Nick(), bet, newBalance))
	end)
	
	-- Fonction pour résoudre la partie
	function ResolveGame(ply, steamid)
		if not IsValid(ply) then return end
		
		local game = Casino.Blackjack.ActiveGames[steamid]
		if not game then return end
		
		local playerValue = CalculateHandValue(game.playerHand)
		local dealerValue = CalculateHandValue(game.dealerHand)
		local playerBlackjack = IsBlackjack(game.playerHand)
		local dealerBlackjack = IsBlackjack(game.dealerHand)
		
		local result = ""
		local winAmount = 0
		local betAmount = game.bet
		
		-- Déterminer le résultat
		if playerBlackjack and dealerBlackjack then
			result = "push"
			winAmount = betAmount
		elseif playerBlackjack then
			result = "blackjack"
			winAmount = math.floor(betAmount * 2.5)
		elseif dealerBlackjack or playerValue > 21 then
			result = "lose"
			winAmount = 0
		elseif dealerValue > 21 or playerValue > dealerValue then
			result = "win"
			winAmount = betAmount * 2
		elseif playerValue == dealerValue then
			result = "push"
			winAmount = betAmount
		else
			result = "lose"
			winAmount = 0
		end
		
		-- Payer le joueur
		if winAmount > 0 then
			Casino.Currency.AddMoney(ply, winAmount)
		end
		
		-- Enregistrer les statistiques
		if Casino.Stats then
			Casino.Stats:RecordGame(ply, "Blackjack", betAmount, result, winAmount)
		end
		
		-- Envoyer le résultat après un délai pour que le joueur voie les cartes
		timer.Simple(0.5, function()
			if not IsValid(ply) then return end
			
			net.Start("Casino_Blackjack_GameResult")
			net.WriteString(result)
			net.WriteInt(winAmount, 32)
			net.Send(ply)
			
			-- Mettre à jour le solde
			local newBalance = Casino.Currency.GetMoney(ply)
			net.Start("Casino_Blackjack_UpdateBalance")
			net.WriteInt(newBalance, 32)
			net.Send(ply)
			
			-- Log
			if result == "blackjack" then
				print(string.format("[Casino Blackjack] %s a fait BLACKJACK! Gains: %d$", ply:Nick(), winAmount))
			elseif result == "win" then
				print(string.format("[Casino Blackjack] %s a gagné! Gains: %d$", ply:Nick(), winAmount))
			elseif result == "push" then
				print(string.format("[Casino Blackjack] %s a fait égalité, mise rendue: %d$", ply:Nick(), winAmount))
			else
				print(string.format("[Casino Blackjack] %s a perdu %d$", ply:Nick(), betAmount))
			end
		end)
		
		-- Nettoyer
		Casino.Blackjack.ActiveBets[steamid] = nil
		Casino.Blackjack.ActiveGames[steamid] = nil
	end
	
	-- Gérer le Hit (tirer une carte)
	net.Receive("Casino_Blackjack_Hit", function(len, ply)
		if not IsValid(ply) then return end
		
		local steamid = ply:SteamID()
		
		-- Anti-spam
		if PlayerLastAction[steamid] and (CurTime() - PlayerLastAction[steamid]) < MIN_ACTION_DELAY then
			return
		end
		PlayerLastAction[steamid] = CurTime()
		
		local game = Casino.Blackjack.ActiveGames[steamid]
		
		if not game then
			print("[Casino Blackjack] ERROR: No active game for " .. ply:Nick())
			return
		end
		
		-- Tirer une carte
		table.insert(game.playerHand, table.remove(game.deck))
		
		-- Envoyer l'état mis à jour
		SendGameState(ply, game, true)
		
		-- Vérifier si le joueur a dépassé 21
		local playerValue = CalculateHandValue(game.playerHand)
		if playerValue > 21 then
			-- Bust! Le joueur a perdu
			timer.Simple(1, function()
				if not IsValid(ply) then return end
				
				-- Révéler les cartes du dealer
				SendGameState(ply, game, false)
				
				timer.Simple(0.5, function()
					if not IsValid(ply) then return end
					ResolveGame(ply, steamid)
				end)
			end)
		end
	end)
	
	-- Gérer le Stand (rester)
	net.Receive("Casino_Blackjack_Stand", function(len, ply)
		if not IsValid(ply) then return end
		
		local steamid = ply:SteamID()
		
		-- Anti-spam
		if PlayerLastAction[steamid] and (CurTime() - PlayerLastAction[steamid]) < MIN_ACTION_DELAY then
			return
		end
		PlayerLastAction[steamid] = CurTime()
		
		local game = Casino.Blackjack.ActiveGames[steamid]
		
		if not game then
			print("[Casino Blackjack] ERROR: No active game for " .. ply:Nick())
			return
		end
		
		-- Révéler d'abord la carte cachée du croupier
		SendGameState(ply, game, false)
		
		-- Fonction récursive pour tirer les cartes du croupier une par une
		local function DrawDealerCard()
			if not IsValid(ply) or not game then return end
			
			local dealerValue = CalculateHandValue(game.dealerHand)
			
			if dealerValue < 17 then
				-- Tirer une nouvelle carte
				table.insert(game.dealerHand, table.remove(game.deck))
				
				-- Envoyer l'état avec la nouvelle carte après 800ms
				timer.Simple(0.8, function()
					if IsValid(ply) and game then
						SendGameState(ply, game, false)
						-- Continuer à tirer si nécessaire
						DrawDealerCard()
					end
				end)
			else
				-- Le croupier a fini, résoudre la partie après 1 seconde
				timer.Simple(1, function()
					if not IsValid(ply) then return end
					ResolveGame(ply, steamid)
				end)
			end
		end
		
		-- Commencer à tirer les cartes du croupier après 800ms
		timer.Simple(0.8, function()
			DrawDealerCard()
		end)
	end)
	
	-- Gérer le Double Down
	net.Receive("Casino_Blackjack_Double", function(len, ply)
		if not IsValid(ply) then return end
		
		local steamid = ply:SteamID()
		
		-- Anti-spam
		if PlayerLastAction[steamid] and (CurTime() - PlayerLastAction[steamid]) < MIN_ACTION_DELAY then
			return
		end
		PlayerLastAction[steamid] = CurTime()
		
		local game = Casino.Blackjack.ActiveGames[steamid]
		
		if not game then
			print("[Casino Blackjack] ERROR: No active game for " .. ply:Nick())
			return
		end
		
		-- Vérifier que c'est autorisé (seulement avec 2 cartes)
		if #game.playerHand ~= 2 or game.doubled then
			return
		end
		
		-- Vérifier que le joueur a assez d'argent
		if not Casino.Currency.CanAfford(ply, game.bet) then
			SendResult(ply, false, Casino.Currency.GetMoney(ply), "Solde insuffisant pour doubler!")
			return
		end
		
		-- Retirer la mise supplémentaire
		if not Casino.Currency.TakeMoney(ply, game.bet) then
			return
		end
		
		-- Doubler la mise
		game.bet = game.bet * 2
		game.doubled = true
		Casino.Blackjack.ActiveBets[steamid] = game.bet
		
		-- Tirer UNE SEULE carte
		table.insert(game.playerHand, table.remove(game.deck))
		
		-- Envoyer l'état
		SendGameState(ply, game, true)
		
		-- Automatiquement stand après double
		timer.Simple(1, function()
			if not IsValid(ply) or not game then return end
			
			-- Le croupier tire
			while CalculateHandValue(game.dealerHand) < 17 do
				table.insert(game.dealerHand, table.remove(game.deck))
			end
			
			-- Révéler et résoudre
			SendGameState(ply, game, false)
			timer.Simple(0.5, function()
				if not IsValid(ply) then return end
				ResolveGame(ply, steamid)
			end)
		end)
	end)
	
	-- Ancien receiver (désormais obsolète, mais gardé pour compatibilité)
	net.Receive("Casino_Blackjack_GameResult", function(len, ply)
		-- Cette fonction n'est plus utilisée car le serveur gère tout
		-- Gardé pour éviter les erreurs si l'ancien JS est encore chargé
		print("[Casino Blackjack] WARNING: Ancien GameResult reçu de " .. ply:Nick() .. " - ignoré")
	end)
	
	-- Nettoyer les stats à la déconnexion
	hook.Add("PlayerDisconnected", "Casino_Blackjack_Cleanup", function(ply)
		local steamid = ply:SteamID()
		
		-- Rembourser la mise active si le joueur se déconnecte pendant une partie
		local activeBet = Casino.Blackjack.ActiveBets[steamid]
		if activeBet and activeBet > 0 then
			Casino.Currency.AddMoney(ply, activeBet)
			print(string.format("[Casino Blackjack] Remboursement de %d$ à %s (déconnexion)", activeBet, ply:Nick()))
		end
		
		Casino.Blackjack.PlayerStats[steamid] = nil
		Casino.Blackjack.ActiveBets[steamid] = nil
		Casino.Blackjack.ActiveGames[steamid] = nil
	end)
	
	-- Initialiser les stats au spawn
	hook.Add("PlayerInitialSpawn", "Casino_Blackjack_Init", function(ply)
		local steamid = ply:SteamID()
		if not Casino.Blackjack.PlayerStats[steamid] then
			Casino.Blackjack.PlayerStats[steamid] = {
				lastBet = 0,
				lastBetTime = 0,
				totalBets = 0
			}
		end
	end)
	
	-- Répondre aux demandes de solde
	net.Receive("Casino_Blackjack_RequestBalance", function(len, ply)
		if not IsValid(ply) then return end
		
		local balance = Casino.Currency.GetMoney(ply)
		net.Start("Casino_Blackjack_UpdateBalance")
		net.WriteInt(balance, 32)
		net.Send(ply)
	end)
	
	print("[Casino Blackjack] Module serveur chargé")
end
