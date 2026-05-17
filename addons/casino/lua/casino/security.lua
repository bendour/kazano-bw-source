-- Système de sécurité centralisé pour le Casino
-- Protection contre les exploits et la triche

if SERVER then
	Casino = Casino or {}
	Casino.Security = Casino.Security or {}
	
	-- Configuration de sécurité
	Casino.Security.Config = {
		-- Limites de paris
		MinBet = 1,
		MaxBet = 10000,
		
		-- Anti-spam
		BetCooldown = 1, -- 1 seconde entre chaque pari
		
		-- Protection contre exploitation
		MaxBetsPerMinute = 60,
		MaxBetsPerSession = 1000,
		
		-- Logging
		LogAllTransactions = true,
		LogSuspiciousActivity = true,
		LogBigWins = true,
		BigWinThreshold = 50000,
		
		-- Protection déconnexion
		SaveOnDisconnect = true,
		RefundOnDisconnect = false, -- false = perte si déco pendant partie
	}
	
	-- Statistiques par joueur
	Casino.Security.PlayerData = Casino.Security.PlayerData or {}
	
	-- Initialiser les données d'un joueur
	function Casino.Security:InitPlayer(ply)
		if not IsValid(ply) then return end
		
		local steamID = ply:SteamID64()
		
		if not self.PlayerData[steamID] then
			self.PlayerData[steamID] = {
				lastBetTime = 0,
				betsThisMinute = 0,
				betsThisSession = 0,
				lastMinuteReset = CurTime(),
				sessionStart = CurTime(),
				totalWagered = 0,
				totalWon = 0,
				biggestWin = 0,
				suspiciousFlags = 0,
			}
		end
		
		return self.PlayerData[steamID]
	end
	
	-- Vérifier si un joueur peut parier
	function Casino.Security:CanPlayerBet(ply, amount, gameName)
		if not IsValid(ply) then return false, "Joueur invalide" end
		
		-- Vérifier le profil
		if not ply.basewarsProfileID then
			return false, "Profil non chargé"
		end
		
		-- Initialiser les données
		local data = self:InitPlayer(ply)
		
		-- Vérifier le cooldown
		if CurTime() - data.lastBetTime < self.Config.BetCooldown then
			return false, "Veuillez attendre avant de miser à nouveau"
		end
		
		-- Reset du compteur par minute
		if CurTime() - data.lastMinuteReset > 60 then
			data.betsThisMinute = 0
			data.lastMinuteReset = CurTime()
		end
		
		-- Vérifier les limites
		if data.betsThisMinute >= self.Config.MaxBetsPerMinute then
			data.suspiciousFlags = data.suspiciousFlags + 1
			return false, "Trop de paris en une minute"
		end
		
		if data.betsThisSession >= self.Config.MaxBetsPerSession then
			return false, "Limite de paris atteinte pour cette session"
		end
		
		-- Valider le montant
		if not amount or type(amount) ~= "number" then
			data.suspiciousFlags = data.suspiciousFlags + 5
			return false, "Montant invalide (type)"
		end
		
		if amount ~= math.floor(amount) or amount <= 0 then
			data.suspiciousFlags = data.suspiciousFlags + 5
			return false, "Montant invalide (non-entier ou négatif)"
		end
		
		if amount < self.Config.MinBet or amount > self.Config.MaxBet then
			return false, string.format("Montant hors limites (%d-%d)", self.Config.MinBet, self.Config.MaxBet)
		end
		
		if amount > 2^31 - 1 then
			data.suspiciousFlags = data.suspiciousFlags + 10
			ply:Kick("Casino bet overflow attempt")
			return false, "Overflow détecté"
		end
		
		return true, "OK"
	end
	
	-- Enregistrer un pari
	function Casino.Security:RecordBet(ply, amount, gameName)
		if not IsValid(ply) then return end
		
		local data = self:InitPlayer(ply)
		
		data.lastBetTime = CurTime()
		data.betsThisMinute = data.betsThisMinute + 1
		data.betsThisSession = data.betsThisSession + 1
		data.totalWagered = data.totalWagered + amount
		
		if self.Config.LogAllTransactions then
			MsgC(Color(100, 200, 255), string.format("[Casino Security] %s parie %d sur %s\n", ply:Nick(), amount, gameName))
		end
	end
	
	-- Enregistrer un gain
	function Casino.Security:RecordWin(ply, amount, gameName)
		if not IsValid(ply) then return end
		
		local data = self:InitPlayer(ply)
		
		data.totalWon = data.totalWon + amount
		
		if amount > data.biggestWin then
			data.biggestWin = amount
		end
		
		-- Logger les gros gains
		if self.Config.LogBigWins and amount >= self.Config.BigWinThreshold then
			MsgC(Color(255, 215, 0), string.format("[Casino Security] 🎰 GROS GAIN: %s a gagné %d sur %s!\n", ply:Nick(), amount, gameName))
		end
	end
	
	-- Détecter une activité suspecte
	function Casino.Security:CheckSuspiciousActivity(ply)
		if not IsValid(ply) then return false end
		
		local data = self:InitPlayer(ply)
		
		-- Vérifier les flags
		if data.suspiciousFlags >= 10 then
			if self.Config.LogSuspiciousActivity then
				MsgC(Color(255, 100, 100), string.format("[Casino Security] ⚠️ SUSPECT: %s a %d flags!\n", ply:Nick(), data.suspiciousFlags))
			end
			return true
		end
		
		-- Vérifier le ratio gain/pari
		if data.totalWagered > 100000 then
			local winRatio = data.totalWon / data.totalWagered
			
			-- Plus de 200% de gains = suspect
			if winRatio > 2.0 then
				if self.Config.LogSuspiciousActivity then
					MsgC(Color(255, 100, 100), string.format("[Casino Security] ⚠️ SUSPECT: %s a un ratio de %.1f%% (gagné: %d, misé: %d)\n", 
]]
				end
				return true
			end
		end
		
		return false
	end
	
	-- Nettoyer les données à la déconnexion
	hook.Add("PlayerDisconnected", "Casino_Security_Cleanup", function(ply)
		local steamID = ply:SteamID64()
		
		if Casino.Security.Config.SaveOnDisconnect then
			-- Sauvegarder les stats (optionnel)
			local data = Casino.Security.PlayerData[steamID]
			if data and data.totalWagered > 0 then
				MsgC(Color(200, 200, 200), string.format("[Casino Security] %s se déconnecte - Stats: Misé: %d, Gagné: %d, Ratio: %.1f%%\n", 
					ply:Nick(), data.totalWagered, data.totalWon, 
					data.totalWagered > 0 and (data.totalWon / data.totalWagered * 100) or 0))
			end
		end
		
		-- Nettoyer après 5 minutes
		timer.Simple(300, function()
			Casino.Security.PlayerData[steamID] = nil
		end)
	end)
	
	-- Réinitialiser les données à la connexion
	hook.Add("PlayerInitialSpawn", "Casino_Security_Init", function(ply)
		Casino.Security:InitPlayer(ply)
	end)
	
	-- Commande admin pour voir les stats de sécurité
	concommand.Add("casino_security_stats", function(ply, cmd, args)
		if IsValid(ply) and not ply:IsAdmin() then
			ply:ChatPrint("Cette commande est réservée aux administrateurs.")
			return
		end
		
		local targetName = args[1]
		if not targetName then
			local msg = "Usage: casino_security_stats <nom_du_joueur>"
			if IsValid(ply) then
				ply:ChatPrint(msg)
			else
				print(msg)
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
			if IsValid(ply) then
				ply:ChatPrint(msg)
			else
				print(msg)
			end
			return
		end
		
		local data = Casino.Security.PlayerData[target:SteamID64()]
		if not data then
			local msg = target:Nick() .. " n'a aucune donnée de sécurité"
			if IsValid(ply) then
				ply:ChatPrint(msg)
			else
				print(msg)
			end
			return
		end
		
		local msg = string.format("Security Stats de %s:\n" ..
			"- Paris cette session: %d\n" ..
			"- Total misé: %d\n" ..
			"- Total gagné: %d\n" ..
			"- Ratio: %.1f%%\n" ..
			"- Plus gros gain: %d\n" ..
			"- Flags suspects: %d", 
			target:Nick(),
			data.betsThisSession,
			data.totalWagered,
			data.totalWon,
			data.totalWagered > 0 and (data.totalWon / data.totalWagered * 100) or 0,
			data.biggestWin,
			data.suspiciousFlags)
		
		if IsValid(ply) then
			ply:ChatPrint(msg)
		else
			print(msg)
		end
	end)
	
	MsgC(Color(100, 255, 100), "[Casino Security] Système de sécurité chargé\n")
end
