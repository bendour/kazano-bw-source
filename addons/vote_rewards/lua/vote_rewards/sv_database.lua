-- Système de base de données pour Vote Rewards
VoteRewards = VoteRewards or {}

-- Initialisation de la base de données
function VoteRewards.InitDatabase()
	-- Table pour les votes des joueurs
	MySQLite.query([[
		CREATE TABLE IF NOT EXISTS vote_rewards_players (
			steam_id TEXT PRIMARY KEY,
			player_name TEXT NOT NULL,
			total_votes INTEGER DEFAULT 0,
			monthly_votes INTEGER DEFAULT 0,
			wheelspins INTEGER DEFAULT 0,
			last_vote_time INTEGER DEFAULT 0,
			last_reset_month INTEGER DEFAULT 0
		);
	]])
	
	-- Table pour l'historique des récompenses
	MySQLite.query([[
		CREATE TABLE IF NOT EXISTS vote_rewards_history (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			steam_id TEXT NOT NULL,
			player_name TEXT NOT NULL,
			reward_type TEXT NOT NULL,
			reward_value TEXT NOT NULL,
			timestamp INTEGER NOT NULL
		);
	]])
	
	-- Table pour les coupons gagnés
	MySQLite.query([[
		CREATE TABLE IF NOT EXISTS vote_rewards_coupons (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			steam_id TEXT NOT NULL,
			player_name TEXT NOT NULL,
			coupon_value TEXT NOT NULL,
			timestamp INTEGER NOT NULL,
			claimed INTEGER DEFAULT 0
		);
	]])
end

-- Récupérer les données d'un joueur
function VoteRewards.GetPlayerData(steamID, callback)
	MySQLite.query("SELECT * FROM vote_rewards_players WHERE steam_id = " .. MySQLite.SQLStr(steamID), function(data)
		if data and data[1] then
			callback(data[1])
		else
			callback(nil)
		end
	end)
end

-- Créer ou mettre à jour un joueur
function VoteRewards.UpdatePlayerData(steamID, playerName, votes, monthlyVotes, wheelspins)
	local currentMonth = tonumber(os.date("%m"))
	
	VoteRewards.GetPlayerData(steamID, function(data)
		if data then
			-- Mise à jour
			MySQLite.query(string.format([[
				UPDATE vote_rewards_players 
				SET player_name = %s, 
					total_votes = %d, 
					monthly_votes = %d, 
					wheelspins = %d,
					last_vote_time = %d,
					last_reset_month = %d
				WHERE steam_id = %s
			]], MySQLite.SQLStr(playerName), votes, monthlyVotes, wheelspins, os.time(), currentMonth, MySQLite.SQLStr(steamID)))
		else
			-- Insertion
			MySQLite.query(string.format([[
				INSERT INTO vote_rewards_players 
				(steam_id, player_name, total_votes, monthly_votes, wheelspins, last_vote_time, last_reset_month) 
				VALUES (%s, %s, %d, %d, %d, %d, %d)
			]], MySQLite.SQLStr(steamID), MySQLite.SQLStr(playerName), votes, monthlyVotes, wheelspins, os.time(), currentMonth))
		end
	end)
end

-- Ajouter un vote
function VoteRewards.AddVote(steamID, playerName)
	VoteRewards.GetPlayerData(steamID, function(data)
		local totalVotes = tonumber(data and data.total_votes or 0) + 1
		local monthlyVotes = tonumber(data and data.monthly_votes or 0) + 1
		local wheelspins = tonumber(data and data.wheelspins or 0) + 1
		
		VoteRewards.UpdatePlayerData(steamID, playerName, totalVotes, monthlyVotes, wheelspins)
	end)
end

-- Utiliser un wheelspin
function VoteRewards.UseWheelspin(steamID, playerName)
	VoteRewards.GetPlayerData(steamID, function(data)
		if not data then
			return false
		end
		
		local wheelspins = tonumber(data.wheelspins or 0)
		if wheelspins <= 0 then
			return false
		end
		
		-- Décrémenter
		VoteRewards.UpdatePlayerData(steamID, playerName, tonumber(data.total_votes or 0), tonumber(data.monthly_votes or 0), wheelspins - 1)
		return true
	end)
end

-- Ajouter à l'historique
function VoteRewards.AddToHistory(steamID, playerName, rewardType, rewardValue)
	MySQLite.query(string.format([[
		INSERT INTO vote_rewards_history 
		(steam_id, player_name, reward_type, reward_value, timestamp) 
		VALUES (%s, %s, %s, %s, %d)
	]], MySQLite.SQLStr(steamID), MySQLite.SQLStr(playerName), MySQLite.SQLStr(rewardType), MySQLite.SQLStr(rewardValue), os.time()))
end

-- Enregistrer un coupon gagné
function VoteRewards.AddCoupon(steamID, playerName, couponValue)
	MySQLite.query(string.format([[
		INSERT INTO vote_rewards_coupons 
		(steam_id, player_name, coupon_value, timestamp, claimed) 
		VALUES (%s, %s, %s, %d, 0)
	]], MySQLite.SQLStr(steamID), MySQLite.SQLStr(playerName), MySQLite.SQLStr(couponValue), os.time()))
	
	-- Écrire aussi dans un fichier log
	local logFile = "data/vote_rewards_coupons.txt"
	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	local logEntry = string.format("[%s] %s (%s) a gagné un coupon de %s\n", timestamp, playerName, steamID, couponValue)
	
	file.Append(logFile, logEntry)
end

-- Récupérer tous les coupons non réclamés
function VoteRewards.GetUnclaimedCoupons(callback)
	MySQLite.query("SELECT * FROM vote_rewards_coupons WHERE claimed = 0 ORDER BY timestamp DESC", function(data)
		callback(data or {})
	end)
end

-- Reset mensuel
function VoteRewards.CheckMonthlyReset()
	local currentMonth = tonumber(os.date("%m"))
	local currentDay = tonumber(os.date("%d"))
	
	if currentDay == VoteRewards.Config.ResetDay then
		MySQLite.query("SELECT * FROM vote_rewards_players WHERE last_reset_month != " .. currentMonth, function(players)
			if players and #players > 0 then
				-- Envoyer le top 3 au webhook Discord avant reset
				VoteRewards.SendMonthlyLeaderboard()
				
				-- Reset les votes mensuels
				MySQLite.query("UPDATE vote_rewards_players SET monthly_votes = 0, last_reset_month = " .. currentMonth)
			end
		end)
	end
end

-- Hook d'initialisation
hook.Add("Initialize", "VoteRewards_InitDB", function()
	VoteRewards.InitDatabase()
	
	-- Vérifier le reset mensuel toutes les heures
	timer.Create("VoteRewards_MonthlyCheck", 3600, 0, function()
		VoteRewards.CheckMonthlyReset()
	end)
end)
