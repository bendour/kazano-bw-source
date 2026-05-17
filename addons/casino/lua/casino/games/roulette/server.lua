-- Roulette Synchronisée Server-Side
-- Tous les joueurs voient le même résultat en même temps

if SERVER then
	util.AddNetworkString("Casino_Roulette_PlaceBet")
	util.AddNetworkString("Casino_Roulette_SpinStart")
	util.AddNetworkString("Casino_Roulette_SpinResult")
	util.AddNetworkString("Casino_Roulette_UpdateBalance")
	util.AddNetworkString("Casino_Roulette_BetPlaced")
	util.AddNetworkString("Casino_Roulette_TimerUpdate")
	util.AddNetworkString("Casino_Roulette_RequestBalance")
end

-- Configuration de la roulette européenne (37 numéros: 0-36)
-- Numéros ROUGES: 1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36 (18 numéros)
-- Numéros NOIRS: 2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35 (18 numéros)
-- Numéro VERT: 0 (1 numéro)
local ROULETTE_NUMBERS = {
	-- Format: {number, color, position} - Ordre de la vraie roulette européenne
	{0, "green", 0},
	{32, "red", 1}, {15, "black", 2}, {19, "red", 3}, {4, "black", 4},
	{21, "red", 5}, {2, "black", 6}, {25, "red", 7}, {17, "black", 8},
	{34, "red", 9}, {6, "black", 10}, {27, "red", 11}, {13, "black", 12},
	{36, "red", 13}, {11, "black", 14}, {30, "red", 15}, {8, "black", 16},
	{23, "red", 17}, {10, "black", 18}, {5, "red", 19}, {24, "black", 20},
	{16, "red", 21}, {33, "black", 22}, {1, "red", 23}, {20, "black", 24},
	{14, "red", 25}, {31, "black", 26}, {9, "red", 27}, {22, "black", 28},
	{18, "red", 29}, {29, "black", 30}, {7, "red", 31}, {28, "black", 32},
	{12, "red", 33}, {35, "black", 34}, {3, "red", 35}, {26, "black", 36}
}

-- Mapping pour retrouver facilement les numéros
local NUMBER_TO_COLOR = {}
for _, data in ipairs(ROULETTE_NUMBERS) do
	NUMBER_TO_COLOR[data[1]] = data[2]
end

-- État de la roulette globale
local RouletteState = {
	isSpinning = false,
	currentBets = {}, -- {steamID = {bets = {}, totalBet = 0}}
	timeUntilSpin = 0,
	lastSpinTime = 0,
	spinDuration = 8, -- Durée du spin en secondes
	bettingTime = 15, -- Temps pour parier en secondes
}

-- Configuration de sécurité
local MAX_BETS_PER_PLAYER = 20 -- Maximum 20 paris par joueur par tour
local MAX_TOTAL_BET_PER_PLAYER = 50000 -- Maximum 50000💎 de mise totale par tour
local MIN_BET_AMOUNT = 1
local MAX_BET_AMOUNT = 10000

-- Anti-spam par joueur
local PlayerLastBet = {} -- {steamID = lastBetTime}

-- Types de paris et leurs gains
local BET_TYPES = {
	-- Paris simples (1:1)
	red = {payout = 2, name = "Rouge"},
	black = {payout = 2, name = "Noir"},
	even = {payout = 2, name = "Pair"},
	odd = {payout = 2, name = "Impair"},
	low = {payout = 2, name = "1-18"},
	high = {payout = 2, name = "19-36"},
	
	-- Colonnes et douzaines (2:1)
	dozen1 = {payout = 3, name = "1ère Douzaine"},
	dozen2 = {payout = 3, name = "2ème Douzaine"},
	dozen3 = {payout = 3, name = "3ème Douzaine"},
	column1 = {payout = 3, name = "1ère Colonne"},
	column2 = {payout = 3, name = "2ème Colonne"},
	column3 = {payout = 3, name = "3ème Colonne"},
	
	-- Numéro plein (35:1)
	straight = {payout = 36, name = "Numéro Plein"},
}

-- Vérifier si un numéro correspond à un type de pari
local function CheckBet(number, betType, betValue)
	if betType == "straight" then
		return number == tonumber(betValue)
	elseif betType == "red" then
		return NUMBER_TO_COLOR[number] == "red"
	elseif betType == "black" then
		return NUMBER_TO_COLOR[number] == "black"
	elseif betType == "even" then
		return number ~= 0 and number % 2 == 0
	elseif betType == "odd" then
		return number ~= 0 and number % 2 == 1
	elseif betType == "low" then
		return number >= 1 and number <= 18
	elseif betType == "high" then
		return number >= 19 and number <= 36
	elseif betType == "dozen1" then
		return number >= 1 and number <= 12
	elseif betType == "dozen2" then
		return number >= 13 and number <= 24
	elseif betType == "dozen3" then
		return number >= 25 and number <= 36
	elseif betType == "column1" then
		return number % 3 == 1 and number > 0
	elseif betType == "column2" then
		return number % 3 == 2 and number > 0
	elseif betType == "column3" then
		return number % 3 == 0 and number > 0
	end
	return false
end

-- Lancer la roulette (appelé automatiquement toutes les X secondes)
local function SpinRoulette()
	if RouletteState.isSpinning then return end
	
	RouletteState.isSpinning = true
	
	-- Générer le résultat (numéro aléatoire de 0 à 36)
	-- Probabilités réelles de roulette européenne:
	-- - Chaque numéro: 1/37 (2.70%)
	-- - Rouge/Noir: 18/37 (48.65%) - Le 0 fait perdre
	-- - Pair/Impair: 18/37 (48.65%)
	-- - Colonnes/Douzaines: 12/37 (32.43%)
	-- - Numéro plein: 1/37 (2.70%)
	-- RTP théorique: 97.3% (avantage maison: 2.7%)
	local winningNumber = math.random(0, 36)
	local winningColor = NUMBER_TO_COLOR[winningNumber]
	
	print(string.format("[Casino Roulette] Spin lancé! Numéro gagnant: %d (%s)", winningNumber, winningColor))
	
	-- Envoyer le début du spin à tous les joueurs
	net.Start("Casino_Roulette_SpinStart")
	net.WriteUInt(winningNumber, 8)
	net.WriteString(winningColor)
	net.Broadcast()
	
	-- Calculer les gains après la durée du spin
	timer.Simple(RouletteState.spinDuration, function()
		-- Calculer les gains pour chaque joueur
		for steamID, playerData in pairs(RouletteState.currentBets) do
			local ply = player.GetBySteamID(steamID)
			if IsValid(ply) then
				local totalWin = 0
				local winningBets = {}
				
				-- Vérifier chaque pari
				for _, bet in ipairs(playerData.bets) do
					if CheckBet(winningNumber, bet.type, bet.value) then
						local betInfo = BET_TYPES[bet.type]
						local win = bet.amount * betInfo.payout
						totalWin = totalWin + win
						
						table.insert(winningBets, {
							type = bet.type,
							value = bet.value,
							amount = bet.amount,
							win = win,
							name = betInfo.name
						})
					end
				end
				
				-- Ajouter les gains au joueur
				if totalWin > 0 then
					Casino.Currency.AddMoney(ply, totalWin)
					print(string.format("[Casino Roulette] %s a gagné %d💎", ply:Nick(), totalWin))
					
					-- Enregistrer les statistiques (victoire)
					if Casino.Stats then
						Casino.Stats:RecordGame(ply, "Roulette", playerData.totalBet, "win", totalWin)
					end
				else
					print(string.format("[Casino Roulette] %s a perdu %d💎", ply:Nick(), playerData.totalBet))
					
					-- Enregistrer les statistiques (défaite)
					if Casino.Stats then
						Casino.Stats:RecordGame(ply, "Roulette", playerData.totalBet, "lose", 0)
					end
				end
				
				-- Envoyer le résultat au joueur
				net.Start("Casino_Roulette_SpinResult")
				net.WriteUInt(winningNumber, 8)
				net.WriteString(winningColor)
				net.WriteUInt(totalWin, 32)
				net.WriteTable(winningBets)
				net.Send(ply)
				
				-- Mettre à jour le solde
				timer.Simple(0.1, function()
					if IsValid(ply) then
						local newBalance = Casino.Currency.GetMoney(ply)
						net.Start("Casino_Roulette_UpdateBalance")
						net.WriteInt(newBalance, 32)
						net.Send(ply)
					end
				end)
			end
		end
		
		-- Réinitialiser l'état
		RouletteState.currentBets = {}
		RouletteState.isSpinning = false
		RouletteState.lastSpinTime = CurTime()
		RouletteState.timeUntilSpin = RouletteState.bettingTime
		
		print("[Casino Roulette] Spin terminé, nouvelle période de paris commencée")
	end)
end

-- Timer pour gérer les spins automatiques
timer.Create("Casino_Roulette_AutoSpin", 1, 0, function()
	if RouletteState.isSpinning then return end
	
	-- Vérifier s'il y a des paris en cours
	local hasBets = false
	for steamID, playerData in pairs(RouletteState.currentBets) do
		if playerData.bets and #playerData.bets > 0 then
			hasBets = true
			break
		end
	end
	
	-- Si personne ne joue, réinitialiser le timer à 15 secondes
	if not hasBets then
		RouletteState.timeUntilSpin = RouletteState.bettingTime
		
		-- Envoyer le temps restant à tous les joueurs (avec statut "en attente")
		net.Start("Casino_Roulette_TimerUpdate")
		net.WriteUInt(RouletteState.timeUntilSpin, 16)
		net.WriteBool(false) -- Pas en train de spinner
		net.Broadcast()
		
		return
	end
	
	-- Décrémenter le timer seulement s'il y a des paris
	RouletteState.timeUntilSpin = RouletteState.timeUntilSpin - 1
	
	-- Envoyer le temps restant à tous les joueurs
	net.Start("Casino_Roulette_TimerUpdate")
	net.WriteUInt(RouletteState.timeUntilSpin, 16)
	net.WriteBool(RouletteState.isSpinning)
	net.Broadcast()
	
	-- Lancer le spin quand le temps est écoulé
	if RouletteState.timeUntilSpin <= 0 then
		SpinRoulette()
	end
end)

-- Initialiser le timer au démarrage
RouletteState.timeUntilSpin = RouletteState.bettingTime

-- Recevoir un pari d'un joueur
net.Receive("Casino_Roulette_PlaceBet", function(len, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	
	local steamID = ply:SteamID()
	
	-- Anti-spam: 0.2 seconde entre chaque pari
	if PlayerLastBet[steamID] and (CurTime() - PlayerLastBet[steamID]) < 0.2 then
		net.Start("Casino_Roulette_BetPlaced")
		net.WriteString("error")
		net.WriteString("Veuillez attendre entre chaque pari")
		net.Send(ply)
		return
	end
	PlayerLastBet[steamID] = CurTime()
	
	-- Ne pas accepter de paris pendant le spin
	if RouletteState.isSpinning then
		net.Start("Casino_Roulette_BetPlaced")
		net.WriteString("error")
		net.WriteString("Le spin est en cours, attendez le prochain tour")
		net.Send(ply)
		return
	end
	
	local betType = net.ReadString()
	local betValue = net.ReadString()
	local betAmount = net.ReadUInt(32)
	
	print(string.format("[Casino Roulette] %s parie %d💎 sur %s (%s)", ply:Nick(), betAmount, betType, betValue))
	
	-- Initialiser les données du joueur si nécessaire
	if not RouletteState.currentBets[steamID] then
		RouletteState.currentBets[steamID] = {
			bets = {},
			totalBet = 0
		}
	end
	
	-- Vérifier le nombre de paris
	if #RouletteState.currentBets[steamID].bets >= MAX_BETS_PER_PLAYER then
		net.Start("Casino_Roulette_BetPlaced")
		net.WriteString("error")
		net.WriteString(string.format("Maximum %d paris par tour", MAX_BETS_PER_PLAYER))
		net.Send(ply)
		return
	end
	
	-- Vérifier la mise totale du joueur
	if RouletteState.currentBets[steamID].totalBet + betAmount > MAX_TOTAL_BET_PER_PLAYER then
		net.Start("Casino_Roulette_BetPlaced")
		net.WriteString("error")
		net.WriteString(string.format("Mise totale maximum: %d💎 par tour", MAX_TOTAL_BET_PER_PLAYER))
		net.Send(ply)
		return
	end
	
	-- Vérifications de base
	if betAmount < MIN_BET_AMOUNT or betAmount > MAX_BET_AMOUNT then
		net.Start("Casino_Roulette_BetPlaced")
		net.WriteString("error")
		net.WriteString(string.format("Mise invalide (%d-%d💎)", MIN_BET_AMOUNT, MAX_BET_AMOUNT))
		net.Send(ply)
		return
	end
	
	-- Vérifier le type de pari
	if not BET_TYPES[betType] then
		net.Start("Casino_Roulette_BetPlaced")
		net.WriteString("error")
		net.WriteString("Type de pari invalide")
		net.Send(ply)
		return
	end
	
	-- Validation supplémentaire pour les paris "straight" (numéro plein)
	if betType == "straight" then
		local num = tonumber(betValue)
		if not num or num < 0 or num > 36 then
			net.Start("Casino_Roulette_BetPlaced")
			net.WriteString("error")
			net.WriteString("Numéro invalide (0-36)")
			net.Send(ply)
			return
		end
	end
	
	-- Vérifier le solde
	if not Casino.Currency.CanAfford(ply, betAmount) then
		net.Start("Casino_Roulette_BetPlaced")
		net.WriteString("error")
		net.WriteString("Solde insuffisant")
		net.Send(ply)
		return
	end
	
	-- Déduire la mise
	if not Casino.Currency.TakeMoney(ply, betAmount) then
		net.Start("Casino_Roulette_BetPlaced")
		net.WriteString("error")
		net.WriteString("Erreur lors du retrait de la mise")
		net.Send(ply)
		return
	end
	
	-- Enregistrer le pari
	table.insert(RouletteState.currentBets[steamID].bets, {
		type = betType,
		value = betValue,
		amount = betAmount
	})
	
	RouletteState.currentBets[steamID].totalBet = RouletteState.currentBets[steamID].totalBet + betAmount
	
	-- Confirmer le pari
	net.Start("Casino_Roulette_BetPlaced")
	net.WriteString("success")
	net.WriteString(string.format("Pari de %d💎 placé sur %s", betAmount, BET_TYPES[betType].name))
	net.Send(ply)
	
	-- Mettre à jour le solde
	timer.Simple(0.1, function()
		if IsValid(ply) then
			local newBalance = Casino.Currency.GetMoney(ply)
			net.Start("Casino_Roulette_UpdateBalance")
			net.WriteInt(newBalance, 32)
			net.Send(ply)
		end
	end)
end)

-- Demande du solde par le client
net.Receive("Casino_Roulette_RequestBalance", function(len, ply)
	if not IsValid(ply) then return end
	
	local balance = Casino.Currency.GetMoney(ply)
	net.Start("Casino_Roulette_UpdateBalance")
	net.WriteInt(balance, 32)
	net.Send(ply)
end)

-- Supprimer un pari spécifique
util.AddNetworkString("Casino_Roulette_RemoveBet")
net.Receive("Casino_Roulette_RemoveBet", function(len, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	
	-- Ne pas permettre la suppression pendant le spin
	if RouletteState.isSpinning then
		return
	end
	
	local betType = net.ReadString()
	local betValue = net.ReadString()
	local betAmount = net.ReadUInt(32)
	
	local steamID = ply:SteamID()
	if not RouletteState.currentBets[steamID] then return end
	
	-- Trouver et supprimer le pari
	for i, bet in ipairs(RouletteState.currentBets[steamID].bets) do
		if bet.type == betType and bet.value == betValue and bet.amount == betAmount then
			table.remove(RouletteState.currentBets[steamID].bets, i)
			RouletteState.currentBets[steamID].totalBet = RouletteState.currentBets[steamID].totalBet - betAmount
			
			-- Rembourser le joueur
			Casino.Currency.AddMoney(ply, betAmount)
			
			print(string.format("[Casino Roulette] %s a supprimé un pari de %d💎", ply:Nick(), betAmount))
			
			-- Mettre à jour le solde
			timer.Simple(0.1, function()
				if IsValid(ply) then
					local newBalance = Casino.Currency.GetMoney(ply)
					net.Start("Casino_Roulette_UpdateBalance")
					net.WriteInt(newBalance, 32)
					net.Send(ply)
				end
			end)
			
			break
		end
	end
	
	-- Supprimer l'entrée si plus de paris
	if #RouletteState.currentBets[steamID].bets == 0 then
		RouletteState.currentBets[steamID] = nil
	end
end)

-- Supprimer tous les paris
util.AddNetworkString("Casino_Roulette_ClearAllBets")
net.Receive("Casino_Roulette_ClearAllBets", function(len, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	
	-- Ne pas permettre la suppression pendant le spin
	if RouletteState.isSpinning then
		return
	end
	
	local steamID = ply:SteamID()
	if not RouletteState.currentBets[steamID] then return end
	
	local totalRefund = RouletteState.currentBets[steamID].totalBet
	
	-- Rembourser tous les paris
	Casino.Currency.AddMoney(ply, totalRefund)
	
	-- Supprimer tous les paris
	RouletteState.currentBets[steamID] = nil
	
	print(string.format("[Casino Roulette] %s a supprimé tous ses paris (%d💎 remboursés)", ply:Nick(), totalRefund))
	
	-- Mettre à jour le solde
	timer.Simple(0.1, function()
		if IsValid(ply) then
			local newBalance = Casino.Currency.GetMoney(ply)
			net.Start("Casino_Roulette_UpdateBalance")
			net.WriteInt(newBalance, 32)
			net.Send(ply)
		end
	end)
end)

print("[Casino Roulette] Module serveur chargé")
