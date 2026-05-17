-- Chicken Road Server-Side
-- Jeu de style casino où le joueur doit éviter les os en choisissant des cases

if SERVER then
	util.AddNetworkString("Casino_Chicken_StartGame")
	util.AddNetworkString("Casino_Chicken_PickTile")
	util.AddNetworkString("Casino_Chicken_TileResult")
	util.AddNetworkString("Casino_Chicken_CashOut")
	util.AddNetworkString("Casino_Chicken_GameResult")
	util.AddNetworkString("Casino_Chicken_UpdateBalance")
	util.AddNetworkString("Casino_Chicken_RequestBalance")
end

-- Configuration du jeu
local GRID_SIZE = 5 -- Grille 5x5
local TOTAL_TILES = GRID_SIZE * GRID_SIZE -- 25 cases
local MIN_BET = 1
local MAX_BET = 100000

-- Multiplicateurs par niveau de difficulté (nombre d'os)
local DIFFICULTY_CONFIG = {
	facile = {
		bones = 3,
		multiplierPerTile = 1.15,
		name = "Facile"
	},
	normal = {
		bones = 5,
		multiplierPerTile = 1.30,
		name = "Normal"
	},
	difficile = {
		bones = 8,
		multiplierPerTile = 1.55,
		name = "Difficile"
	},
	extreme = {
		bones = 12,
		multiplierPerTile = 2.00,
		name = "Extrême"
	}
}

-- Namespace pour le jeu
Casino.Chicken = Casino.Chicken or {}
Casino.Chicken.ActiveGames = {}

-- Générer la grille avec des os aléatoires
local function GenerateGrid(boneCount)
	local grid = {}
	
	-- Initialiser toutes les cases comme sûres
	for i = 1, TOTAL_TILES do
		grid[i] = {
			hasBone = false,
			revealed = false
		}
	end
	
	-- Placer les os aléatoirement
	local bonesPlaced = 0
	while bonesPlaced < boneCount do
		local pos = math.random(1, TOTAL_TILES)
		if not grid[pos].hasBone then
			grid[pos].hasBone = true
			bonesPlaced = bonesPlaced + 1
		end
	end
	
	return grid
end

-- Calculer le multiplicateur actuel
local function CalculateMultiplier(revealedCount, multiplierPerTile)
	if revealedCount == 0 then return 1 end
	return math.pow(multiplierPerTile, revealedCount)
end

-- Envoyer l'état du jeu au joueur
local function SendGameState(ply, game)
	net.Start("Casino_Chicken_TileResult")
	net.WriteTable({
		grid = game.grid,
		revealedCount = game.revealedCount,
		currentMultiplier = game.currentMultiplier,
		potentialWin = math.floor(game.bet * game.currentMultiplier)
	})
	net.Send(ply)
end

-- Démarrer une nouvelle partie
net.Receive("Casino_Chicken_StartGame", function(len, ply)
	if not IsValid(ply) then return end
	
	local bet = net.ReadUInt(32)
	local difficulty = net.ReadString()
	local steamid = ply:SteamID()
	
	-- Vérifier que le joueur n'a pas déjà une partie en cours
	if Casino.Chicken.ActiveGames[steamid] and Casino.Chicken.ActiveGames[steamid].gameActive then
		net.Start("Casino_Chicken_GameResult")
		net.WriteString("error")
		net.WriteString("Vous avez déjà une partie en cours")
		net.WriteInt(0, 32)
		net.Send(ply)
		return
	end
	
	-- Valider la mise
	if bet < MIN_BET or bet > MAX_BET then
		net.Start("Casino_Chicken_GameResult")
		net.WriteString("error")
		net.WriteString(string.format("Mise invalide (min: %d💎, max: %d💎)", MIN_BET, MAX_BET))
		net.WriteInt(0, 32)
		net.Send(ply)
		return
	end
	
	-- Valider la difficulté
	local config = DIFFICULTY_CONFIG[difficulty]
	if not config then
		net.Start("Casino_Chicken_GameResult")
		net.WriteString("error")
		net.WriteString("Difficulté invalide")
		net.WriteInt(0, 32)
		net.Send(ply)
		return
	end
	
	-- Vérifier le solde
	local currentBalance = Casino.Currency.GetMoney(ply)
	if currentBalance < bet then
		net.Start("Casino_Chicken_GameResult")
		net.WriteString("error")
		net.WriteString("Solde insuffisant")
		net.WriteInt(0, 32)
		net.Send(ply)
		return
	end
	
	-- Déduire la mise
	if not Casino.Currency.TakeMoney(ply, bet) then
		net.Start("Casino_Chicken_GameResult")
		net.WriteString("error")
		net.WriteString("Erreur lors de la déduction de la mise")
		net.WriteInt(0, 32)
		net.Send(ply)
		return
	end
	
	-- Créer la partie
	local grid = GenerateGrid(config.bones)
	
	Casino.Chicken.ActiveGames[steamid] = {
		bet = bet,
		difficulty = difficulty,
		boneCount = config.bones,
		multiplierPerTile = config.multiplierPerTile,
		grid = grid,
		revealedCount = 0,
		currentMultiplier = 1,
		gameActive = true
	}
	
	-- Envoyer la confirmation
	net.Start("Casino_Chicken_GameResult")
	net.WriteString("started")
	net.WriteString(string.format("Partie démarrée! (%s - %d os)", config.name, config.bones))
	net.WriteInt(bet, 32)
	net.Send(ply)
	
	-- Mettre à jour le solde
	net.Start("Casino_Chicken_UpdateBalance")
	net.WriteInt(Casino.Currency.GetMoney(ply), 32)
	net.Send(ply)
	
	print(string.format("[Casino Chicken] %s a démarré une partie (Mise: %d💎, Difficulté: %s)", 
		ply:Nick(), bet, config.name))
end)

-- Choisir une case
net.Receive("Casino_Chicken_PickTile", function(len, ply)
	if not IsValid(ply) then return end
	
	local tileIndex = net.ReadUInt(8)
	local steamid = ply:SteamID()
	local game = Casino.Chicken.ActiveGames[steamid]
	
	if not game or not game.gameActive then
		return
	end
	
	-- Vérifier que l'index est valide
	if tileIndex < 1 or tileIndex > TOTAL_TILES then
		return
	end
	
	local tile = game.grid[tileIndex]
	
	-- Vérifier que la case n'a pas déjà été révélée
	if tile.revealed then
		return
	end
	
	-- Révéler la case
	tile.revealed = true
	
	if tile.hasBone then
		-- OS TROUVÉ! Le joueur a perdu
		game.gameActive = false
		
		-- Révéler tous les os
		for i, t in ipairs(game.grid) do
			if t.hasBone then
				t.revealed = true
			end
		end
		
		SendGameState(ply, game)
		
		timer.Simple(0.5, function()
			if not IsValid(ply) then return end
			
			net.Start("Casino_Chicken_GameResult")
			net.WriteString("lose")
			net.WriteString("💀 Oh non! Vous avez trouvé un os!")
			net.WriteInt(0, 32)
			net.Send(ply)
			
			-- Enregistrer les statistiques
			if Casino.Stats then
				Casino.Stats:RecordGame(ply, "Chicken", game.bet, "lose", 0)
			end
			
			print(string.format("[Casino Chicken] %s a perdu %d💎 (case %d)", 
				ply:Nick(), game.bet, tileIndex))
			
			Casino.Chicken.ActiveGames[steamid] = nil
		end)
	else
		-- CASE SÛRE! Augmenter le multiplicateur
		game.revealedCount = game.revealedCount + 1
		game.currentMultiplier = CalculateMultiplier(game.revealedCount, game.multiplierPerTile)
		
		-- Envoyer le nouvel état
		SendGameState(ply, game)
		
		-- Vérifier si toutes les cases sûres ont été révélées
		local maxSafeTiles = TOTAL_TILES - game.boneCount
		if game.revealedCount >= maxSafeTiles then
			-- VICTOIRE PARFAITE!
			game.gameActive = false
			local winAmount = math.floor(game.bet * game.currentMultiplier)
			Casino.Currency.AddMoney(ply, winAmount)
			
			-- Enregistrer les statistiques
			if Casino.Stats then
				Casino.Stats:RecordGame(ply, "Chicken", game.bet, "win", winAmount)
			end
			
			timer.Simple(0.5, function()
				if not IsValid(ply) then return end
				
				net.Start("Casino_Chicken_GameResult")
				net.WriteString("perfect")
				net.WriteString("🎉 PARFAIT! Toutes les cases sûres révélées!")
				net.WriteInt(winAmount, 32)
				net.Send(ply)
				
				net.Start("Casino_Chicken_UpdateBalance")
				net.WriteInt(Casino.Currency.GetMoney(ply), 32)
				net.Send(ply)
				
				print(string.format("[Casino Chicken] %s a gagné %d💎 (victoire parfaite, x%.2f)", 
					ply:Nick(), winAmount, game.currentMultiplier))
				
				Casino.Chicken.ActiveGames[steamid] = nil
			end)
		end
	end
end)

-- Encaisser les gains
net.Receive("Casino_Chicken_CashOut", function(len, ply)
	if not IsValid(ply) then return end
	
	local steamid = ply:SteamID()
	local game = Casino.Chicken.ActiveGames[steamid]
	
	if not game or not game.gameActive then
		return
	end
	
	if game.revealedCount == 0 then
		-- Aucune case révélée, rembourser la mise
		Casino.Currency.AddMoney(ply, game.bet)
		
		net.Start("Casino_Chicken_GameResult")
		net.WriteString("refund")
		net.WriteString("Mise remboursée")
		net.WriteInt(game.bet, 32)
		net.Send(ply)
		
		net.Start("Casino_Chicken_UpdateBalance")
		net.WriteInt(Casino.Currency.GetMoney(ply), 32)
		net.Send(ply)
		
		Casino.Chicken.ActiveGames[steamid] = nil
		return
	end
	
	-- Calculer et donner les gains
	game.gameActive = false
	local winAmount = math.floor(game.bet * game.currentMultiplier)
	Casino.Currency.AddMoney(ply, winAmount)
	
	-- Enregistrer les statistiques
	if Casino.Stats then
		Casino.Stats:RecordGame(ply, "Chicken", game.bet, "win", winAmount)
	end
	
	-- Révéler tous les os
	for i, tile in ipairs(game.grid) do
		if tile.hasBone then
			tile.revealed = true
		end
	end
	
	SendGameState(ply, game)
	
	timer.Simple(0.5, function()
		if not IsValid(ply) then return end
		
		net.Start("Casino_Chicken_GameResult")
		net.WriteString("cashout")
		net.WriteString(string.format("🐔 Retrait réussi! x%.2f", game.currentMultiplier))
		net.WriteInt(winAmount, 32)
		net.Send(ply)
		
		net.Start("Casino_Chicken_UpdateBalance")
		net.WriteInt(Casino.Currency.GetMoney(ply), 32)
		net.Send(ply)
		
		print(string.format("[Casino Chicken] %s a encaissé %d💎 (x%.2f)", 
			ply:Nick(), winAmount, game.currentMultiplier))
		
		Casino.Chicken.ActiveGames[steamid] = nil
	end)
end)

-- Demande de solde
net.Receive("Casino_Chicken_RequestBalance", function(len, ply)
	if not IsValid(ply) then return end
	
	net.Start("Casino_Chicken_UpdateBalance")
	net.WriteInt(Casino.Currency.GetMoney(ply), 32)
	net.Send(ply)
end)

print("[Casino] Chicken game server loaded")
