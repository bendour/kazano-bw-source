-- Côté serveur du Blackjack DHTML
-- Gère uniquement les transactions financières et la sécurité

if SERVER then
	util.AddNetworkString("Blackjack_PlaceBet")
	util.AddNetworkString("Blackjack_TransactionComplete")
	
	-- Statistiques des joueurs pour la sécurité
	Blackjack.PlayerStats = Blackjack.PlayerStats or {}
	
	-- Vérifier la sécurité (anti-spam, limites, etc.)
	function Blackjack.CheckSecurity(ply)
		if not IsValid(ply) then return false end
		
		local steamid = ply:SteamID()
		local stats = Blackjack.PlayerStats[steamid] or {
			lastBet = 0,
			lastBetTime = 0,
			totalBets = 0,
			sessionStart = CurTime()
		}
		
		-- Récupérer les valeurs de configuration
		local antiSpamDelay = Blackjack:GetConfig("Security.AntiSpamDelay") or 1
		local maxBetsPerSession = Blackjack:GetConfig("Security.MaxBetsPerSession") or 1000
		
		-- Vérifier l'anti-spam
		if CurTime() - stats.lastBetTime < antiSpamDelay then
			Blackjack.SendTransactionResult(ply, false, 0, "Veuillez attendre avant de miser à nouveau.")
			return false
		end
		
		-- Vérifier les limites de paris par session
		if stats.totalBets >= maxBetsPerSession then
			Blackjack.SendTransactionResult(ply, false, 0, "Limite de paris atteinte pour cette session.")
			return false
		end
		
		-- Mettre à jour les stats
		stats.lastBetTime = CurTime()
		Blackjack.PlayerStats[steamid] = stats
		
		return true
	end
	
	-- Envoyer le résultat d'une transaction au client
	function Blackjack.SendTransactionResult(ply, success, newBalance, message)
		if not IsValid(ply) then return end
		
		net.Start("Blackjack_TransactionComplete")
		net.WriteBool(success)
		net.WriteInt(newBalance, 32)
		net.WriteString(message or "")
		net.Send(ply)
	end
	
	-- Gérer les demandes de mise
	net.Receive("Blackjack_PlaceBet", function(len, ply)
		if not Blackjack.CheckSecurity(ply) then return end
		
		local bet = net.ReadInt(32)
		local minBet = Blackjack:GetConfig("Game.MinBet") or 100
		local maxBet = Blackjack:GetConfig("Game.MaxBet") or 10000
		
		-- EXPLOIT FIX: Vérifier que le profil est chargé
		if not ply.basewarsProfileID then
			Blackjack.SendTransactionResult(ply, false, 0, "Votre profil n'est pas chargé!")
			return
		end
		
		-- EXPLOIT FIX: Vérifier qu'il n'y a pas de pari en cours
		if ply.blackjackBetInProgress then
			Blackjack.SendTransactionResult(ply, false, Blackjack.Currency.GetMoney(ply), "Une partie est déjà en cours!")
			return
		end
		
		-- EXPLOIT FIX: Validation stricte du montant
		if not bet or type(bet) ~= "number" then
			ply:Kick("Invalid blackjack bet data type")
			return
		end
		
		-- EXPLOIT FIX: Vérifier que c'est un entier positif
		if bet ~= math.floor(bet) or bet <= 0 then
			ply:Kick("Invalid blackjack bet amount (non-integer or negative)")
			return
		end
		
		-- EXPLOIT FIX: Vérifier overflow
		if bet > 2^31 - 1 then
			ply:Kick("Blackjack bet overflow")
			return
		end
		
		-- Valider la mise
		if bet < minBet or bet > maxBet then
			Blackjack.SendTransactionResult(ply, false, Blackjack.Currency.GetMoney(ply), 
				string.format("Mise invalide! Minimum: %d, Maximum: %d", minBet, maxBet))
			return
		end
		
		-- Vérifier si le joueur a assez d'argent
		if not Blackjack.Currency.CanAfford(ply, bet) then
			Blackjack.SendTransactionResult(ply, false, Blackjack.Currency.GetMoney(ply), "Solde insuffisant!")
			return
		end
		
		-- EXPLOIT FIX: Marquer le pari en cours AVANT de retirer l'argent
		ply.blackjackBetInProgress = true
		ply.blackjackCurrentBet = bet
		
		-- Retirer l'argent de la mise IMMÉDIATEMENT
		if not Blackjack.Currency.TakeMoney(ply, bet) then
			ply.blackjackBetInProgress = false
			ply.blackjackCurrentBet = nil
			Blackjack.SendTransactionResult(ply, false, Blackjack.Currency.GetMoney(ply), "Erreur lors du retrait de l'argent.")
			return
		end
		
		-- Mettre à jour les statistiques du joueur
		local steamid = ply:SteamID()
		local stats = Blackjack.PlayerStats[steamid]
		stats.totalBets = stats.totalBets + 1
		stats.lastBet = bet
		
		-- Envoyer la confirmation au client
		local newBalance = Blackjack.Currency.GetMoney(ply)
		Blackjack.SendTransactionResult(ply, true, newBalance, "Mise acceptée!")
		
		print(string.format("[Blackjack] %s a misé %d (Nouveau solde: %d)", ply:Nick(), bet, newBalance))
	end)
	
	-- Nettoyer les stats des joueurs déconnectés
	hook.Add("PlayerDisconnected", "Blackjack_Cleanup", function(ply)
		local steamid = ply:SteamID()
		
		-- EXPLOIT FIX: Si le joueur avait un pari en cours, logger (argent déjà déduit = perte)
		if ply.blackjackBetInProgress then
			print(string.format("[Blackjack] %s s'est déconnecté avec une partie en cours (mise: %d)", ply:Nick(), ply.blackjackCurrentBet or 0))
		end
		
		Blackjack.PlayerStats[steamid] = nil
		ply.blackjackBetInProgress = nil
		ply.blackjackCurrentBet = nil
	end)
	
	-- Réinitialiser les stats des joueurs reconnectés
	hook.Add("PlayerInitialSpawn", "Blackjack_ResetStats", function(ply)
		local steamid = ply:SteamID()
		if not Blackjack.PlayerStats[steamid] then
			Blackjack.PlayerStats[steamid] = {
				lastBet = 0,
				lastBetTime = 0,
				totalBets = 0,
				sessionStart = CurTime()
			}
		end
	end)
	
	print("[Blackjack] Serveur chargé avec succès (mode transaction uniquement)")
end
