-- Système de statistiques du Casino
-- Gère les stats des joueurs et l'historique

if SERVER then
	-- Enregistrer le réseau pour les statistiques
	util.AddNetworkString("Casino_RequestStats")
	util.AddNetworkString("Casino_SendStats")
	util.AddNetworkString("Casino_RequestHistory")
	util.AddNetworkString("Casino_SendHistory")
	util.AddNetworkString("Casino_RequestLeaderboard")
	util.AddNetworkString("Casino_SendLeaderboard")
	
	Casino.Stats = Casino.Stats or {}
	Casino.Stats.PlayerData = {}
	
	-- Créer la table de base de données si elle n'existe pas
	local function CreateStatsTable()
		sql.Query([[
			CREATE TABLE IF NOT EXISTS casino_stats (
				steamid TEXT PRIMARY KEY,
				total_wins INTEGER DEFAULT 0,
				total_losses INTEGER DEFAULT 0,
				total_games INTEGER DEFAULT 0,
				biggest_win INTEGER DEFAULT 0,
				biggest_loss INTEGER DEFAULT 0,
				total_wagered INTEGER DEFAULT 0,
				total_profit INTEGER DEFAULT 0,
				win_rate REAL DEFAULT 0,
				last_played INTEGER DEFAULT 0
			)
		]])
		
		-- Table pour l'historique des parties
		sql.Query([[
			CREATE TABLE IF NOT EXISTS casino_history (
				id INTEGER PRIMARY KEY AUTOINCREMENT,
				steamid TEXT NOT NULL,
				game TEXT NOT NULL,
				bet INTEGER NOT NULL,
				result TEXT NOT NULL,
				win_amount INTEGER NOT NULL,
				timestamp INTEGER NOT NULL
			)
		]])
		
		-- Index pour améliorer les performances de recherche
		sql.Query([[
			CREATE INDEX IF NOT EXISTS idx_history_steamid 
			ON casino_history(steamid, timestamp DESC)
		]])
	end
	
	-- Créer la table au démarrage
	CreateStatsTable()
	
	-- Charger les stats d'un joueur depuis la base de données
	local function LoadPlayerStatsFromDB(steamid)
		local result = sql.QueryRow("SELECT * FROM casino_stats WHERE steamid = " .. sql.SQLStr(steamid))
		
		if result then
			return {
				totalWins = tonumber(result.total_wins) or 0,
				totalLosses = tonumber(result.total_losses) or 0,
				totalGames = tonumber(result.total_games) or 0,
				biggestWin = tonumber(result.biggest_win) or 0,
				biggestLoss = tonumber(result.biggest_loss) or 0,
				totalWagered = tonumber(result.total_wagered) or 0,
				totalProfit = tonumber(result.total_profit) or 0,
				winRate = tonumber(result.win_rate) or 0,
				history = {},
				lastPlayed = tonumber(result.last_played) or os.time()
			}
		end
		
		return nil
	end
	
	-- Sauvegarder les stats d'un joueur dans la base de données
	local function SavePlayerStatsToDB(steamid, stats)
		local query = string.format([[
			INSERT OR REPLACE INTO casino_stats 
			(steamid, total_wins, total_losses, total_games, biggest_win, biggest_loss, total_wagered, total_profit, win_rate, last_played)
			VALUES (%s, %d, %d, %d, %d, %d, %d, %d, %.2f, %d)
		]], 
			sql.SQLStr(steamid),
			stats.totalWins,
			stats.totalLosses,
			stats.totalGames,
			stats.biggestWin,
			stats.biggestLoss,
			stats.totalWagered,
			stats.totalProfit,
			stats.winRate,
			stats.lastPlayed
		)
		
		sql.Query(query)
	end
	
	-- Charger l'historique d'un joueur depuis la base de données (50 dernières parties)
	local function LoadPlayerHistoryFromDB(steamid)
		local query = string.format([[
			SELECT game, bet, result, win_amount, timestamp 
			FROM casino_history 
			WHERE steamid = %s 
			ORDER BY timestamp DESC 
			LIMIT 50
		]], sql.SQLStr(steamid))
		
		local results = sql.Query(query)
		local history = {}
		
		if results then
			for _, row in ipairs(results) do
				table.insert(history, {
					game = row.game,
					bet = tonumber(row.bet) or 0,
					result = row.result,
					winAmount = tonumber(row.win_amount) or 0,
					timestamp = tonumber(row.timestamp) or os.time()
				})
			end
		end
		
		return history
	end
	
	-- Sauvegarder une entrée d'historique dans la base de données
	local function SaveHistoryEntryToDB(steamid, game, bet, result, winAmount, timestamp)
		local query = string.format([[
			INSERT INTO casino_history (steamid, game, bet, result, win_amount, timestamp)
			VALUES (%s, %s, %d, %s, %d, %d)
		]], 
			sql.SQLStr(steamid),
			sql.SQLStr(game),
			bet,
			sql.SQLStr(result),
			winAmount,
			timestamp
		)
		
		sql.Query(query)
		
		-- Limiter l'historique à 100 entrées par joueur pour économiser l'espace
		local deleteQuery = string.format([[
			DELETE FROM casino_history 
			WHERE steamid = %s 
			AND id NOT IN (
				SELECT id FROM casino_history 
				WHERE steamid = %s 
				ORDER BY timestamp DESC 
				LIMIT 100
			)
		]], sql.SQLStr(steamid), sql.SQLStr(steamid))
		
		sql.Query(deleteQuery)
	end
	
	-- Initialiser les stats d'un joueur
	function Casino.Stats:InitPlayer(ply)
		local steamid = ply:SteamID()
		
		if not self.PlayerData[steamid] then
			-- Essayer de charger depuis la base de données
			local dbStats = LoadPlayerStatsFromDB(steamid)
			
			if dbStats then
				-- Charger l'historique depuis la DB
				dbStats.history = LoadPlayerHistoryFromDB(steamid)
				self.PlayerData[steamid] = dbStats
				print(string.format("[Casino Stats] Stats chargées pour %s (DB)", ply:Nick()))
			else
				-- Créer de nouvelles stats
				self.PlayerData[steamid] = {
					totalWins = 0,
					totalLosses = 0,
					totalGames = 0,
					biggestWin = 0,
					biggestLoss = 0,
					totalWagered = 0,
					totalProfit = 0,
					winRate = 0,
					history = {},
					lastPlayed = os.time()
				}
				print(string.format("[Casino Stats] Nouvelles stats créées pour %s", ply:Nick()))
			end
		end
		
		return self.PlayerData[steamid]
	end
	
	-- Enregistrer un résultat de partie
	function Casino.Stats:RecordGame(ply, game, bet, result, winAmount)
		local steamid = ply:SteamID()
		local stats = self:InitPlayer(ply)
		
		stats.totalGames = stats.totalGames + 1
		stats.totalWagered = stats.totalWagered + bet
		stats.lastPlayed = os.time()
		
		if result == "win" or result == "blackjack" then
			stats.totalWins = stats.totalWins + 1
			local profit = winAmount - bet
			stats.totalProfit = stats.totalProfit + profit
			
			if profit > stats.biggestWin then
				stats.biggestWin = profit
			end
		elseif result == "lose" or result == "bust" then
			stats.totalLosses = stats.totalLosses + 1
			stats.totalProfit = stats.totalProfit - bet
			
			if bet > stats.biggestLoss then
				stats.biggestLoss = bet
			end
		end
		
		-- Calculer le taux de victoire
		stats.winRate = math.Round((stats.totalWins / stats.totalGames) * 100, 1)
		
		local currentTime = os.time()
		
		-- Ajouter à l'historique
		table.insert(stats.history, 1, {
			game = game,
			bet = bet,
			result = result,
			winAmount = winAmount,
			timestamp = currentTime
		})
		
		-- Limiter l'historique à 50 entrées en mémoire
		while #stats.history > 50 do
			table.remove(stats.history)
		end
		
		-- Sauvegarder l'entrée d'historique dans la DB
		SaveHistoryEntryToDB(steamid, game, bet, result, winAmount, currentTime)
		
		-- Sauvegarder dans la base de données
		SavePlayerStatsToDB(steamid, stats)
		
		-- Déclencher le hook pour les addons externes (aDaily Rewards, etc.)
		hook.Run("Casino.GameEnded", ply, game, result, bet, winAmount)
		
		-- Hook spécifique au blackjack pour compatibilité
		if game == "Blackjack" then
			hook.Run("Blackjack.GameEnded", ply, result, bet, winAmount)
		end
		
		print(string.format("[Casino Stats] %s - %s: %s (Mise: %d$, Gain: %d$)", 
			ply:Nick(), game, result, bet, winAmount))
	end
	
	-- Obtenir les stats d'un joueur
	function Casino.Stats:GetPlayerStats(ply)
		return self:InitPlayer(ply)
	end
	
	-- Envoyer les statistiques à un joueur
	function Casino.Stats:SendStatsToPlayer(ply)
		local stats = self:GetPlayerStats(ply)
		
		net.Start("Casino_SendStats")
		net.WriteTable({
			totalWins = stats.totalProfit, -- Profit total au lieu du nombre de victoires
			totalGames = stats.totalGames,
			winRate = stats.winRate,
			biggestWin = stats.biggestWin
		})
		net.Send(ply)
	end
	
	-- Envoyer l'historique à un joueur
	function Casino.Stats:SendHistoryToPlayer(ply)
		local stats = self:GetPlayerStats(ply)
		
		net.Start("Casino_SendHistory")
		net.WriteUInt(#stats.history, 16)
		
		for _, entry in ipairs(stats.history) do
			net.WriteString(entry.game)
			net.WriteString(entry.result)
			net.WriteUInt(entry.bet, 32)
			net.WriteUInt(entry.winAmount, 32)
			net.WriteUInt(entry.timestamp, 32)
		end
		
		net.Send(ply)
	end
	
	-- Recevoir une demande de stats
	net.Receive("Casino_RequestStats", function(len, ply)
		Casino.Stats:SendStatsToPlayer(ply)
	end)
	
	-- Recevoir une demande d'historique
	net.Receive("Casino_RequestHistory", function(len, ply)
		Casino.Stats:SendHistoryToPlayer(ply)
	end)
	
	-- Récupérer le leaderboard global (top 10 des plus gros gains)
	function Casino.Stats:GetGlobalLeaderboard()
		local query = [[
			SELECT h.steamid, h.game, h.win_amount, h.timestamp
			FROM casino_history h
			INNER JOIN (
				SELECT steamid, MAX(win_amount) as max_win
				FROM casino_history
				WHERE result = 'win'
				GROUP BY steamid
			) m ON h.steamid = m.steamid AND h.win_amount = m.max_win
			WHERE h.result = 'win'
			ORDER BY h.win_amount DESC
			LIMIT 10
		]]
		
		local results = sql.Query(query)
		local leaderboard = {}
		
		if results then
			for _, row in ipairs(results) do
				-- Récupérer le nom du joueur s'il est connecté, sinon utiliser SteamID
				local playerName = row.steamid
				for _, ply in ipairs(player.GetAll()) do
					if ply:SteamID() == row.steamid then
						playerName = ply:Nick()
						break
					end
				end
				
				table.insert(leaderboard, {
					steamid = row.steamid,
					playerName = playerName,
					game = row.game,
					winAmount = tonumber(row.win_amount) or 0,
					timestamp = tonumber(row.timestamp) or os.time()
				})
			end
		end
		
		return leaderboard
	end
	
	-- Envoyer le leaderboard à un joueur
	function Casino.Stats:SendLeaderboardToPlayer(ply)
		local leaderboard = self:GetGlobalLeaderboard()
		
		net.Start("Casino_SendLeaderboard")
		net.WriteUInt(#leaderboard, 8)
		
		for _, entry in ipairs(leaderboard) do
			net.WriteString(entry.playerName)
			net.WriteString(entry.game)
			net.WriteUInt(entry.winAmount, 32)
			net.WriteUInt(entry.timestamp, 32)
		end
		
		net.Send(ply)
	end
	
	-- Recevoir une demande de leaderboard
	net.Receive("Casino_RequestLeaderboard", function(len, ply)
		Casino.Stats:SendLeaderboardToPlayer(ply)
	end)
	
	-- Nettoyer les stats d'un joueur déconnecté
	hook.Add("PlayerDisconnected", "Casino_Stats_Cleanup", function(ply)
		local steamid = ply:SteamID()
		
		-- Sauvegarder avant de nettoyer
		if Casino.Stats.PlayerData[steamid] then
			SavePlayerStatsToDB(steamid, Casino.Stats.PlayerData[steamid])
			print(string.format("[Casino Stats] Stats sauvegardées pour %s (déconnexion)", ply:Nick()))
		end
		
		-- Nettoyer la mémoire
		Casino.Stats.PlayerData[steamid] = nil
	end)
	
	-- Sauvegarder périodiquement les stats de tous les joueurs
	timer.Create("Casino_Stats_AutoSave", 300, 0, function() -- Toutes les 5 minutes
		local count = 0
		for steamid, stats in pairs(Casino.Stats.PlayerData) do
			SavePlayerStatsToDB(steamid, stats)
			count = count + 1
		end
		
		if count > 0 then
			print(string.format("[Casino Stats] Auto-sauvegarde: %d joueur(s)", count))
		end
	end)
	
	print("[Casino] Système de statistiques chargé")
end
