-- API Top-Serveurs pour Vote Rewards
VoteRewards = VoteRewards or {}

util.AddNetworkString("VoteRewards_VoteReceived")
util.AddNetworkString("VoteRewards_OpenWheel")
util.AddNetworkString("VoteRewards_RequestRewards")
util.AddNetworkString("VoteRewards_SendRewards")

-- Recevoir la demande de récompenses du client
net.Receive("VoteRewards_RequestRewards", function(len, ply)
	net.Start("VoteRewards_SendRewards")
		net.WriteString(util.TableToJSON(VoteRewards.Config.WheelRewards))
	net.Send(ply)
end)

-- Vérifier et réclamer un vote via Top-Serveurs API (SteamID)
-- manualCheck: true si c'est une vérification manuelle via /checkvote, false pour vérifications automatiques
function VoteRewards.CheckVote(steamID, ip, manualCheck)
	if not VoteRewards.Config.TopServeurEnabled then
		return
	end
	
	manualCheck = manualCheck or false
	
	-- Utiliser l'endpoint claim-steam pour réclamer le vote
	local url = string.format(
		"https://api.top-serveurs.net/v1/votes/claim-steam?server_token=%s&steam_id=%s",
		VoteRewards.Config.TopServeurAPIKey,
		steamID
	)
	
	http.Fetch(url, function(body, size, headers, code)
		local data = util.JSONToTable(body)
		
		if data then
			
			if data.success and data.claimed then
				-- claimed = 0 : Vote introuvable
				-- claimed = 1 : Vote réclamable
				-- claimed = 2 : Vote déjà réclamé
				
				if data.claimed == 1 then
					local ply = player.GetBySteamID64(steamID)
					if IsValid(ply) then
						VoteRewards.AddVote(steamID, ply:Nick())
						
						-- Une seule notification côté client
						net.Start("VoteRewards_VoteReceived")
						net.Send(ply)
						
						-- Notification globale à tous les joueurs
						for _, p in ipairs(player.GetAll()) do
							if IsValid(p) and p ~= ply then
								p:ChatPrint(string.format("[Vote Rewards] 🎉 %s vient de voter pour le serveur ! Tapez /vote pour voter aussi !", ply:Nick()))
							end
						end
					end
				elseif data.claimed == 2 then
					-- Ne notifier que lors de vérifications manuelles
					if manualCheck then
						local ply = player.GetBySteamID64(steamID)
						if IsValid(ply) then
							ply:ChatPrint("[Vote Rewards] ⚠ Ce vote a déjà été réclamé.")
						end
					end
				elseif data.claimed == 0 then
					-- Ne notifier que lors de vérifications manuelles
					if manualCheck then
						local ply = player.GetBySteamID64(steamID)
						if IsValid(ply) then
							ply:ChatPrint("[Vote Rewards] ✗ Aucun vote trouvé. Votez sur Top-Serveurs pour recevoir des récompenses !")
						end
					end
				end
			else
				local ply = player.GetBySteamID64(steamID)
				if IsValid(ply) then
					ply:ChatPrint("[Vote Rewards] Erreur lors de la vérification du vote.")
				end
			end
		end
	end, function(error)
	end)
end

-- Vérifier et réclamer un vote via Top-Serveurs API (Pseudo)
-- manualCheck: true si c'est une vérification manuelle via /checkvote, false pour vérifications automatiques
function VoteRewards.CheckVoteByUsername(username, ply, manualCheck)
	if not VoteRewards.Config.TopServeurEnabled then
		return
	end
	
	manualCheck = manualCheck or false
	
	-- Encoder l'URL manuellement (remplacer les espaces et caractères spéciaux)
	local encodedUsername = string.gsub(username, " ", "%%20")
	encodedUsername = string.gsub(encodedUsername, "#", "%%23")
	encodedUsername = string.gsub(encodedUsername, "&", "%%26")
	
	-- Utiliser l'endpoint claim-username pour réclamer le vote
	local url = string.format(
		"https://api.top-serveurs.net/v1/votes/claim-username?server_token=%s&playername=%s",
		VoteRewards.Config.TopServeurAPIKey,
		encodedUsername
	)
	
	http.Fetch(url, function(body, size, headers, code)
		local data = util.JSONToTable(body)
		
		if data then
			
			if data.success and data.claimed then
				if data.claimed == 1 then
					if IsValid(ply) then
						VoteRewards.AddVote(ply:SteamID64(), ply:Nick())
						ply:ChatPrint("[Vote Rewards] ✓ Merci d'avoir voté ! Vous avez reçu 1 Wheelspin !")
						
						net.Start("VoteRewards_VoteReceived")
						net.Send(ply)
					end
				elseif data.claimed == 2 then
					-- Ne pas afficher de message lors des vérifications automatiques
				elseif data.claimed == 0 then
					-- Ne pas afficher de message lors des vérifications automatiques
				end
			else
				if IsValid(ply) then
					ply:ChatPrint("[Vote Rewards] Erreur lors de la vérification du vote.")
				end
			end
		end
	end, function(error)
	end)
end

-- Vérification périodique des votes pour tous les joueurs en ligne
timer.Create("VoteRewards_CheckAllVotes", 60, 0, function() -- Toutes les minutes
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) then
			-- Vérifier par SteamID
			VoteRewards.CheckVote(ply:SteamID64(), ply:IPAddress())
			-- Vérifier aussi par pseudo
			timer.Simple(0.5, function()
				if IsValid(ply) then
					VoteRewards.CheckVoteByUsername(ply:Nick(), ply)
				end
			end)
		end
	end
end)

-- Commande pour ouvrir la roue
concommand.Add("vote_wheelspin", function(ply)
	if not IsValid(ply) then return end
	
	local steamID = ply:SteamID64()
	
	VoteRewards.GetPlayerData(steamID, function(data)
		local wheelspins = tonumber(data and data.wheelspins or 0)
		if not data or wheelspins <= 0 then
			ply:ChatPrint("[Vote Rewards] Vous n'avez pas de Wheelspin disponible. Votez sur Top-Serveurs pour en recevoir !")
			return
		end
		
		-- Ouvrir l'interface
		net.Start("VoteRewards_OpenWheel")
			net.WriteInt(wheelspins, 16)
		net.Send(ply)
	end)
end)

-- Alias
concommand.Add("wheelspin", function(ply)
	if not IsValid(ply) then return end
	
	local steamID = ply:SteamID64()
	
	VoteRewards.GetPlayerData(steamID, function(data)
		local wheelspins = tonumber(data and data.wheelspins or 0)
		
		if not data or wheelspins <= 0 then
			ply:ChatPrint("[Vote Rewards] Vous n'avez pas de Wheelspin disponible. Votez sur Top-Serveurs pour en recevoir !")
			return
		end
		
		-- Ouvrir l'interface
		net.Start("VoteRewards_OpenWheel")
			net.WriteInt(wheelspins, 16)
			net.WriteString(util.TableToJSON(VoteRewards.Config.WheelRewards))
		net.Send(ply)
	end)
end)

-- Commande chat
hook.Add("PlayerSay", "VoteRewards_ChatCommand", function(ply, text)
	local lower = string.lower(text)
	if lower == "!wheelspin" or lower == "/wheelspin" then
		ply:ConCommand("wheelspin")
		return ""
	elseif lower == "!vote" or lower == "/vote" then
		-- Ouvrir la page de vote avec le pseudo pré-rempli
		local voteURL = VoteRewards.Config.TopServeurVoteURL .. "?pseudo=" .. ply:Nick()
		ply:ChatPrint("[Vote Rewards] Ouverture de la page de vote...")
		ply:SendLua(string.format("gui.OpenURL(%q)", voteURL))
		return ""
	end
end)



-- Vérifier les votes au spawn
hook.Add("PlayerInitialSpawn", "VoteRewards_CheckVote", function(ply)
	timer.Simple(5, function()
		if IsValid(ply) then
			-- Vérifier par SteamID
			VoteRewards.CheckVote(ply:SteamID64(), ply:IPAddress())
			-- Vérifier aussi par pseudo
			timer.Simple(0.5, function()
				if IsValid(ply) then
					VoteRewards.CheckVoteByUsername(ply:Nick(), ply)
				end
			end)
		end
	end)
end)
