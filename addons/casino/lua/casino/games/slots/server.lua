-- Machine à Sous Classique Server-Side
-- Grille 5x5 avec lignes de paiement fixes

if SERVER then
	util.AddNetworkString("Casino_Slots_PlaceBet")
	util.AddNetworkString("Casino_Slots_Spin")
	util.AddNetworkString("Casino_Slots_SpinResult")
	util.AddNetworkString("Casino_Slots_UpdateBalance")
end

-- Anti-spam par joueur
local PlayerLastSpin = {} -- {steamID = lastSpinTime}
local MIN_SPIN_DELAY = 1 -- 1 seconde entre chaque spin

-- Configuration des symboles et leurs valeurs
local SYMBOLS = {
	-- Symboles de forte valeur
	{id = "wild", emoji = "🦝", name = "Smokey (Wild)", pays = {[5] = 100, [4] = 25, [3] = 5}},
	{id = "revolver", emoji = "🔫", name = "Revolver", pays = {[5] = 50, [4] = 12, [3] = 3}},
	{id = "chapeau", emoji = "🤠", name = "Chapeau", pays = {[5] = 40, [4] = 10, [3] = 2.5}},
	{id = "horseshoe", emoji = "🐴", name = "Fer à cheval", pays = {[5] = 30, [4] = 8, [3] = 2}},
	{id = "ace", emoji = "🂡", name = "As", pays = {[5] = 20, [4] = 6, [3] = 1.5}},
	-- Symboles de faible valeur
	{id = "king", emoji = "♔", name = "Roi", pays = {[5] = 15, [4] = 5, [3] = 1.2}},
	{id = "queen", emoji = "♕", name = "Dame", pays = {[5] = 10, [4] = 4, [3] = 1}},
	{id = "jack", emoji = "🃏", name = "Valet", pays = {[5] = 8, [4] = 3, [3] = 0.8}},
	{id = "ten", emoji = "🔟", name = "10", pays = {[5] = 5, [4] = 2, [3] = 0.5}},
}

-- Poids de distribution des symboles (RTP 94.5%)
-- Plus le poids est élevé, plus le symbole apparaît souvent
local SYMBOL_WEIGHTS = {
	wild = 2,      -- Très rare (Wild)
	revolver = 6,  -- Rare
	chapeau = 8,
	horseshoe = 12,
	ace = 15,
	king = 18,
	queen = 20,
	jack = 22,
	ten = 25,      -- Fréquent
}

-- Lignes de paiement (5x5 = 25 positions)
-- Format: position dans la grille (ligne 1-5, colonne 1-5)
-- Positions: [1][1] à [5][5]
local PAYLINES = {
	{1, 1, 1, 1, 1}, -- Ligne du haut
	{2, 2, 2, 2, 2}, -- Ligne 2
	{3, 3, 3, 3, 3}, -- Ligne centrale
	{4, 4, 4, 4, 4}, -- Ligne 4
	{5, 5, 5, 5, 5}, -- Ligne du bas
	{1, 2, 3, 4, 5}, -- Diagonale descendante
	{5, 4, 3, 2, 1}, -- Diagonale montante
	{2, 3, 3, 3, 2}, -- V inversé
	{4, 3, 3, 3, 4}, -- V normal
	{3, 2, 1, 2, 3}, -- Pic
	{3, 4, 5, 4, 3}, -- Creux
	{1, 2, 2, 2, 1}, -- Petite montagne haut
	{5, 4, 4, 4, 5}, -- Petite montagne bas
	{2, 1, 2, 1, 2}, -- Zigzag haut
	{4, 5, 4, 5, 4}, -- Zigzag bas
}

-- Génération d'un rouleau aléatoire basé sur les poids
local function GenerateReel()
	local totalWeight = 0
	for _, weight in pairs(SYMBOL_WEIGHTS) do
		totalWeight = totalWeight + weight
	end
	
	local rand = math.random() * totalWeight
	local current = 0
	
	for id, weight in pairs(SYMBOL_WEIGHTS) do
		current = current + weight
		if rand <= current then
			return id
		end
	end
	
	return "ten" -- Fallback
end

-- Générer une grille 5x5
local function GenerateGrid()
	local grid = {}
	for row = 1, 5 do
		grid[row] = {}
		for col = 1, 5 do
			grid[row][col] = GenerateReel()
		end
	end
	return grid
end

-- Obtenir le symbole par ID
local function GetSymbol(id)
	for _, symbol in ipairs(SYMBOLS) do
		if symbol.id == id then
			return symbol
		end
	end
	return SYMBOLS[#SYMBOLS] -- Fallback
end

-- Vérifier une ligne de paiement
local function CheckPayline(grid, payline)
	local symbols = {}
	
	-- Extraire les symboles de la ligne
	for col = 1, 5 do
		local row = payline[col]
		table.insert(symbols, grid[row][col])
	end
	
	-- Compter les symboles identiques consécutifs depuis la gauche
	local firstSymbol = symbols[1]
	local count = 1
	
	-- Le Wild peut substituer n'importe quel symbole
	for i = 2, 5 do
		local currentSymbol = symbols[i]
		
		if firstSymbol == "wild" then
			-- Si le premier est wild, prendre le premier non-wild
			firstSymbol = currentSymbol
			count = i
		elseif currentSymbol == firstSymbol or currentSymbol == "wild" then
			count = i
		else
			break
		end
	end
	
	-- Minimum 3 symboles pour gagner
	if count >= 3 then
		local symbol = GetSymbol(firstSymbol)
		return true, symbol, count
	end
	
	return false, nil, 0
end

-- Calculer tous les gains sur toutes les lignes
local function CalculateWinnings(grid, bet)
	local totalWin = 0
	local winningLines = {}
	
	for lineNum, payline in ipairs(PAYLINES) do
		local hasWin, symbol, count = CheckPayline(grid, payline)
		
		if hasWin then
			local multiplier = symbol.pays[count] or 0
			local lineWin = bet * multiplier
			
			if lineWin > 0 then
				totalWin = totalWin + lineWin
				table.insert(winningLines, {
					line = lineNum,
					symbol = symbol.id,
					count = count,
					win = lineWin,
					multiplier = multiplier,
					positions = payline
				})
			end
		end
	end
	
	-- Limiter le gain maximum à 5000x la mise
	local maxWin = bet * 5000
	if totalWin > maxWin then
		totalWin = maxWin
	end
	
	return totalWin, winningLines
end

-- Recevoir la mise et lancer le spin
net.Receive("Casino_Slots_Spin", function(len, ply)
	local bet = net.ReadUInt(32)
	
	if not IsValid(ply) or not ply:IsPlayer() then return end
	
	local steamID = ply:SteamID()
	
	-- Anti-spam: vérifier le délai entre les spins
	if PlayerLastSpin[steamID] and (CurTime() - PlayerLastSpin[steamID]) < MIN_SPIN_DELAY then
		net.Start("Casino_Slots_SpinResult")
		net.WriteString("error")
		net.WriteString("Veuillez attendre entre chaque spin")
		net.Send(ply)
		return
	end
	PlayerLastSpin[steamID] = CurTime()
	
	-- Debug
	print(string.format("[Casino Slots] %s veut parier %d💎", ply:Nick(), bet))
	
	-- Vérifications
	if bet < 1 or bet > 10000 then
		net.Start("Casino_Slots_SpinResult")
		net.WriteString("error")
		net.WriteString("Mise invalide (1-10000💎)")
		net.Send(ply)
		return
	end
	
	-- Utiliser le système de currency
	local balance = Casino.Currency.GetMoney(ply)
	print(string.format("[Casino Slots] Solde de %s: %d💎", ply:Nick(), balance))
	
	if not Casino.Currency.CanAfford(ply, bet) then
		print(string.format("[Casino Slots] %s n'a pas assez (solde: %d💎, mise: %d💎)", ply:Nick(), balance, bet))
		net.Start("Casino_Slots_SpinResult")
		net.WriteString("error")
		net.WriteString("Solde insuffisant")
		net.Send(ply)
		return
	end
	
	-- Déduire la mise
	if not Casino.Currency.TakeMoney(ply, bet) then
		net.Start("Casino_Slots_SpinResult")
		net.WriteString("error")
		net.WriteString("Erreur de transaction")
		net.Send(ply)
		return
	end
	
	-- Générer la grille 5x5
	local grid = GenerateGrid()
	
	-- Calculer les gains
	local totalWin, winningLines = CalculateWinnings(grid, bet)
	
	-- Arrondir le gain
	totalWin = math.floor(totalWin)
	
	-- Ajouter les gains au joueur
	if totalWin > 0 then
		Casino.Currency.AddMoney(ply, totalWin)
		
		-- Enregistrer les statistiques (victoire)
		if Casino.Stats then
			Casino.Stats:RecordGame(ply, "Slots", bet, "win", totalWin)
		end
	else
		-- Enregistrer les statistiques (défaite)
		if Casino.Stats then
			Casino.Stats:RecordGame(ply, "Slots", bet, "lose", 0)
		end
	end
	
	-- Convertir la grille en format compatible JSON
	local gridFlat = {}
	for row = 1, 5 do
		gridFlat["row" .. row] = {}
		for col = 1, 5 do
			gridFlat["row" .. row]["col" .. col] = grid[row][col]
		end
	end
	
	-- Envoyer le résultat
	net.Start("Casino_Slots_SpinResult")
	net.WriteString("success")
	net.WriteTable({
		grid = gridFlat,
		totalWin = totalWin,
		bet = bet,
		winningLines = winningLines
	})
	net.Send(ply)
	
	-- Mettre à jour le solde
	timer.Simple(0.1, function()
		if IsValid(ply) then
			local newBalance = Casino.Currency.GetMoney(ply)
			net.Start("Casino_Slots_UpdateBalance")
			net.WriteInt(newBalance, 32)
			net.Send(ply)
		end
	end)
	
	-- Log
	print(string.format("[Casino Slots] %s a misé %d💎 et gagné %d💎 (lignes gagnantes: %d)", ply:Nick(), bet, totalWin, #winningLines))
end)
