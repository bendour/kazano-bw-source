-- Côté serveur du jeu Mines
-- Gère les transactions financières et la logique du jeu

if SERVER then
	util.AddNetworkString("Casino_Mines_PlaceBet")
	util.AddNetworkString("Casino_Mines_RevealTile")
	util.AddNetworkString("Casino_Mines_CashOut")
	util.AddNetworkString("Casino_Mines_GameState")
	util.AddNetworkString("Casino_Mines_GameResult")
	util.AddNetworkString("Casino_Mines_UpdateBalance")
	
	Casino.Mines = Casino.Mines or {}
	Casino.Mines.ActiveGames = {}
	
	-- Anti-spam
	local PlayerLastAction = {} -- {steamID = lastActionTime}
	local MIN_ACTION_DELAY = 0.3 -- 0.3 seconde entre chaque action
	
	-- Configuration
	local GRID_SIZE = 5
	local TOTAL_TILES = GRID_SIZE * GRID_SIZE -- 25 cases
	
	-- Table des multiplicateurs réels du jeu Mines
	-- [nombre de mines][nombre de diamants révélés] = multiplicateur
	local MULTIPLIERS = {
		[1] = {1.01, 1.08, 1.12, 1.18, 1.24, 1.3, 1.37, 1.46, 1.55, 1.65, 1.77, 1.9, 2.06, 2.25, 2.47, 2.75, 3.09, 3.54, 4.12, 4.95, 6.19, 8.25, 12.37, 24.75},
		[2] = {1.08, 1.17, 1.29, 1.41, 1.56, 1.74, 1.94, 2.18, 2.47, 2.83, 3.26, 3.81, 4.5, 5.4, 6.6, 8.19, 10.61, 14.14, 19.8, 29.7, 49.5, 99, 297},
		[3] = {1.12, 1.29, 1.48, 1.71, 2, 2.35, 2.79, 3.35, 4.07, 5, 6.26, 7.96, 10.35, 13.8, 18.97, 27.11, 40.66, 65.06, 113.9, 227.7, 569.3, 2277},
		[4] = {1.18, 1.41, 1.71, 2.09, 2.58, 3.23, 4.09, 5.26, 6.88, 9.17, 12.51, 17.52, 25.3, 37.95, 59.64, 99.39, 178.91, 357.81, 834.9, 2504, 12523},
		[5] = {1.24, 1.56, 2, 2.58, 3.39, 4.52, 6.14, 8.5, 12.04, 17.52, 26.77, 40.87, 66.41, 113.85, 208.7, 417.45, 939.3, 2504, 8766},
		[6] = {1.3, 1.74, 2.35, 3.23, 4.52, 6.46, 9.44, 14.17, 21.89, 35.03, 58.38, 102.17, 189.75, 379.5, 834.9, 2087, 6261, 25047, 175329},
		[7] = {1.37, 1.94, 2.79, 4.09, 6.14, 9.44, 14.95, 24.37, 41.6, 73.95, 138.66, 277.33, 600.87, 1442, 3965, 12410, 52986, 475893},
		[8] = {1.46, 2.18, 3.35, 5.26, 8.5, 14.17, 24.47, 44.05, 83.2, 166.4, 356.56, 831.98, 2163, 6489, 23794, 118973, 1070759},
		[9] = {1.55, 2.47, 4.07, 6.88, 12.04, 21.89, 41.6, 83.2, 176.8, 404.1, 1010, 2828, 9193, 36773, 202254, 2022545},
		[10] = {1.65, 2.83, 5, 9.17, 17.52, 35.03, 73.95, 166.4, 404.1, 1077, 3232, 11314, 49031, 294188, 3236072},
		[11] = {1.77, 3.26, 6.26, 12.51, 26.77, 58.38, 138.66, 356.56, 1010, 3232, 12123, 56574, 367735, 4412826},
		[12] = {1.9, 3.81, 7.96, 17.52, 40.87, 102.17, 277.33, 831.98, 2828, 11314, 56574, 396092, 5148297},
		[13] = {2.06, 4.5, 10.35, 25.3, 66.41, 189.75, 600.87, 2163, 9193, 49031, 367735, 5148297},
		[14] = {2.25, 5.4, 13.8, 37.95, 113.9, 379.5, 1442, 6489, 36773, 294188, 4412826},
		[15] = {2.47, 6.6, 18.97, 59.64, 208.7, 834.9, 3965, 23794, 202254, 3236072},
		[16] = {2.75, 8.25, 27.11, 99.39, 417.5, 2087, 12410, 118973, 2022545},
		[17] = {3.09, 10.61, 40.66, 178.91, 939.3, 6261, 52986, 1070759},
		[18] = {3.54, 14.14, 65.06, 357.8, 2504, 25047, 475893},
		[19] = {4.12, 19.8, 113.9, 834.9, 8766, 175329},
		[20] = {4.95, 29.7, 227.7, 2504, 52986},
		[21] = {6.19, 49.5, 569.3, 12523},
		[22] = {8.25, 99, 2277},
		[23] = {12.38, 297},
		[24] = {24.75}
	}
	
	-- Calculer le multiplicateur basé sur le nombre de cases révélées et de bombes
	local function CalculateMultiplier(revealedCount, bombCount)
		if revealedCount < 1 then return 1.0 end
		
		-- Récupérer le multiplicateur depuis la table
		if MULTIPLIERS[bombCount] and MULTIPLIERS[bombCount][revealedCount] then
			return MULTIPLIERS[bombCount][revealedCount]
		end
		
		-- Fallback (ne devrait jamais arriver)
		return 1.0
	end
	
	-- Créer une nouvelle grille
	local function CreateGrid(bombCount)
		local grid = {}
		
		-- Initialiser toutes les cases comme sûres
		for i = 1, TOTAL_TILES do
			grid[i] = { isBomb = false, revealed = false }
		end
		
		-- Placer les bombes aléatoirement
		local bombsPlaced = 0
		while bombsPlaced < bombCount do
			local pos = math.random(1, TOTAL_TILES)
			if not grid[pos].isBomb then
				grid[pos].isBomb = true
				bombsPlaced = bombsPlaced + 1
			end
		end
		
		return grid
	end
	
	-- Envoyer l'état du jeu au client (sans révéler les bombes)
	local function SendGameState(ply, game)
		net.Start("Casino_Mines_GameState")
		
		-- Créer un état sécurisé (ne pas révéler les bombes non découvertes)
		local safeGrid = {}
		for i, tile in ipairs(game.grid) do
			safeGrid[i] = {
				revealed = tile.revealed,
				isBomb = tile.revealed and tile.isBomb or false
			}
		end
		
		net.WriteTable({
			grid = safeGrid,
			bet = game.bet,
			bombCount = game.bombCount,
			revealedCount = game.revealedCount,
			currentMultiplier = game.currentMultiplier,
			potentialWin = math.floor(game.bet * game.currentMultiplier)
		})
		net.Send(ply)
	end
	
	-- Placer une mise et commencer une partie
	net.Receive("Casino_Mines_PlaceBet", function(len, ply)
		if not IsValid(ply) then return end
		
		local steamid = ply:SteamID()
		
		-- Anti-spam
		if PlayerLastAction[steamid] and (CurTime() - PlayerLastAction[steamid]) < MIN_ACTION_DELAY then
			net.Start("Casino_Mines_GameResult")
			net.WriteString("error")
			net.WriteString("Veuillez attendre entre chaque action")
			net.WriteInt(0, 32)
			net.Send(ply)
			return
		end
		PlayerLastAction[steamid] = CurTime()
		
		local data = net.ReadTable()
		local bet = data.bet
		local bombCount = data.bombCount
		
		-- Validation
		if bet < 1 or bet > 10000 then
			net.Start("Casino_Mines_GameResult")
			net.WriteString("error")
			net.WriteString("Mise invalide! (1💎 - 10000💎)")
			net.WriteInt(0, 32)
			net.Send(ply)
			return
		end
		
		if bombCount < 1 or bombCount > 24 then
			net.Start("Casino_Mines_GameResult")
			net.WriteString("error")
			net.WriteString("Nombre de bombes invalide! (1-24)")
			net.WriteInt(0, 32)
			net.Send(ply)
			return
		end
		
		-- Vérifier les fonds
		if not Casino.Currency.CanAfford(ply, bet) then
			net.Start("Casino_Mines_GameResult")
			net.WriteString("error")
			net.WriteString("Solde insuffisant!")
			net.WriteInt(0, 32)
			net.Send(ply)
			return
		end
		
		-- Retirer la mise
		if not Casino.Currency.TakeMoney(ply, bet) then
			net.Start("Casino_Mines_GameResult")
			net.WriteString("error")
			net.WriteString("Erreur lors du retrait de la mise")
			net.WriteInt(0, 32)
			net.Send(ply)
			return
		end
		
		-- Créer la partie
		Casino.Mines.ActiveGames[steamid] = {
			grid = CreateGrid(bombCount),
			bet = bet,
			bombCount = bombCount,
			revealedCount = 0,
			currentMultiplier = 1.0,
			gameActive = true
		}
		
		print(string.format("[Casino Mines] %s a commencé une partie avec %d💎 et %d bombes", 
			ply:Nick(), bet, bombCount))
		
		-- Envoyer l'état initial
		SendGameState(ply, Casino.Mines.ActiveGames[steamid])
		
		-- Mettre à jour le solde
		net.Start("Casino_Mines_UpdateBalance")
		net.WriteInt(Casino.Currency.GetMoney(ply), 32)
		net.Send(ply)
	end)
	
	-- Révéler une case
	net.Receive("Casino_Mines_RevealTile", function(len, ply)
		if not IsValid(ply) then return end
		
		local steamid = ply:SteamID()
		
		-- Anti-spam pour révéler les tuiles
		if PlayerLastAction[steamid] and (CurTime() - PlayerLastAction[steamid]) < MIN_ACTION_DELAY then
			return
		end
		PlayerLastAction[steamid] = CurTime()
		
		local game = Casino.Mines.ActiveGames[steamid]
		
		if not game or not game.gameActive then
			return
		end
		
		local tileIndex = net.ReadInt(8)
		
		if tileIndex < 1 or tileIndex > TOTAL_TILES then
			return
		end
		
		local tile = game.grid[tileIndex]
		
		if tile.revealed then
			return -- Case déjà révélée
		end
		
		-- Révéler la case
		tile.revealed = true
		game.revealedCount = game.revealedCount + 1
		
		if tile.isBomb then
			-- BOOM! Le joueur a perdu
			game.gameActive = false
			
			-- Révéler toutes les bombes
			for i, t in ipairs(game.grid) do
				if t.isBomb then
					t.revealed = true
				end
			end
			
			SendGameState(ply, game)
			
			timer.Simple(0.5, function()
				if not IsValid(ply) then return end
				
				net.Start("Casino_Mines_GameResult")
				net.WriteString("lose")
				net.WriteString("BOOM! Vous avez touché une bombe!")
				net.WriteInt(0, 32)
				net.Send(ply)
				
				-- Enregistrer les statistiques
				if Casino.Stats then
					Casino.Stats:RecordGame(ply, "Mines", game.bet, "lose", 0)
				end
				
				print(string.format("[Casino Mines] %s a perdu %d💎 (touché une bombe)", 
					ply:Nick(), game.bet))
				
				Casino.Mines.ActiveGames[steamid] = nil
			end)
		else
			-- Case sûre! Calculer le nouveau multiplicateur
			game.currentMultiplier = CalculateMultiplier(game.revealedCount, game.bombCount)
			
			-- Envoyer le nouvel état
			SendGameState(ply, game)
			
			-- Vérifier si toutes les cases sûres ont été révélées
			local maxSafeTiles = TOTAL_TILES - game.bombCount
			if game.revealedCount >= maxSafeTiles then
				-- Victoire automatique!
				game.gameActive = false
				local winAmount = math.floor(game.bet * game.currentMultiplier)
				Casino.Currency.AddMoney(ply, winAmount)
				
				-- Enregistrer les statistiques
				if Casino.Stats then
					Casino.Stats:RecordGame(ply, "Mines", game.bet, "win", winAmount)
				end
				
				timer.Simple(0.5, function()
					if not IsValid(ply) then return end
					
					net.Start("Casino_Mines_GameResult")
					net.WriteString("win")
					net.WriteString("Toutes les cases sûres révélées!")
					net.WriteInt(winAmount, 32)
					net.Send(ply)
					
					net.Start("Casino_Mines_UpdateBalance")
					net.WriteInt(Casino.Currency.GetMoney(ply), 32)
					net.Send(ply)
					
					print(string.format("[Casino Mines] %s a gagné %d💎 (toutes cases révélées, x%.2f)", 
						ply:Nick(), winAmount, game.currentMultiplier))
					
					Casino.Mines.ActiveGames[steamid] = nil
				end)
			end
		end
	end)
	
	-- Encaisser les gains
	net.Receive("Casino_Mines_CashOut", function(len, ply)
		if not IsValid(ply) then return end
		
		local steamid = ply:SteamID()
		
		-- Anti-spam
		if PlayerLastAction[steamid] and (CurTime() - PlayerLastAction[steamid]) < MIN_ACTION_DELAY then
			return
		end
		PlayerLastAction[steamid] = CurTime()
		
		local game = Casino.Mines.ActiveGames[steamid]
		
		if not game or not game.gameActive then
			return
		end
		
		if game.revealedCount == 0 then
			-- Aucune case révélée, rembourser la mise
			Casino.Currency.AddMoney(ply, game.bet)
			
			net.Start("Casino_Mines_GameResult")
			net.WriteString("push")
			net.WriteString("Mise remboursée")
			net.WriteInt(game.bet, 32)
			net.Send(ply)
			
			net.Start("Casino_Mines_UpdateBalance")
			net.WriteInt(Casino.Currency.GetMoney(ply), 32)
			net.Send(ply)
			
			Casino.Mines.ActiveGames[steamid] = nil
			return
		end
		
		-- SÉCURITÉ: Recalculer le multiplicateur côté serveur pour éviter la manipulation
		local serverMultiplier = CalculateMultiplier(game.revealedCount, game.bombCount)
		game.currentMultiplier = serverMultiplier -- Forcer le multiplicateur serveur
		
		-- Calculer et donner les gains
		game.gameActive = false
		local winAmount = math.floor(game.bet * game.currentMultiplier)
		
		-- Validation finale: limite maximale de gains
		local MAX_WIN = 10000000 -- 10M max
		if winAmount > MAX_WIN then
			winAmount = MAX_WIN
			print(string.format("[Casino Mines] WARN: Gains limités à %d pour %s", MAX_WIN, ply:Nick()))
		end
		
		Casino.Currency.AddMoney(ply, winAmount)
		
		-- Enregistrer les statistiques
		if Casino.Stats then
			Casino.Stats:RecordGame(ply, "Mines", game.bet, "win", winAmount)
		end
		
		-- Révéler toutes les bombes
		for i, tile in ipairs(game.grid) do
			if tile.isBomb then
				tile.revealed = true
			end
		end
		
		SendGameState(ply, game)
		
		timer.Simple(0.5, function()
			if not IsValid(ply) then return end
			
			net.Start("Casino_Mines_GameResult")
			net.WriteString("win")
			net.WriteString(string.format("Gains encaissés! x%.2f", game.currentMultiplier))
			net.WriteInt(winAmount, 32)
			net.Send(ply)
			
			net.Start("Casino_Mines_UpdateBalance")
			net.WriteInt(Casino.Currency.GetMoney(ply), 32)
			net.Send(ply)
			
			print(string.format("[Casino Mines] %s a encaissé %d💎 (x%.2f, %d cases révélées)", 
				ply:Nick(), winAmount, game.currentMultiplier, game.revealedCount))
			
			Casino.Mines.ActiveGames[steamid] = nil
		end)
	end)
	
	-- Nettoyer les parties en cours lors de la déconnexion
	hook.Add("PlayerDisconnected", "Casino_Mines_Cleanup", function(ply)
		local steamid = ply:SteamID()
		local game = Casino.Mines.ActiveGames[steamid]
		
		if game and game.gameActive then
			-- Rembourser la mise si le joueur se déconnecte
			Casino.Currency.AddMoney(ply, game.bet)
			print(string.format("[Casino Mines] Remboursement de %d💎 à %s (déconnexion)", 
				game.bet, ply:Nick()))
		end
		
		Casino.Mines.ActiveGames[steamid] = nil
	end)
end
