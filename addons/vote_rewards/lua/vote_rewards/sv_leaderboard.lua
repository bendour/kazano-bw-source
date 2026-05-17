-- Système de classement pour Vote Rewards
VoteRewards = VoteRewards or {}

-- Charger le module reqwest pour les webhooks Discord
require("reqwest")

util.AddNetworkString("VoteRewards_SendLeaderboard")

-- Récupérer le top des voteurs du mois
function VoteRewards.GetMonthlyLeaderboard(callback)
	MySQLite.query([[
		SELECT steam_id, player_name, monthly_votes 
		FROM vote_rewards_players 
		WHERE monthly_votes > 0 
		ORDER BY monthly_votes DESC 
		LIMIT ]] .. VoteRewards.Config.TopPlayersCount, 
	function(data)
		callback(data or {})
	end)
end

-- Envoyer le classement mensuel sur Discord
function VoteRewards.SendMonthlyLeaderboard()
	VoteRewards.GetMonthlyLeaderboard(function(leaderboard)
		if #leaderboard == 0 then
			print("[Vote Rewards] No votes this month, skipping Discord webhook")
			return
		end
		
		local monthName = os.date("%B %Y")
		local embed = {
			username = "Vote Rewards",
			avatar_url = "https://i.imgur.com/4M34hi2.png",
			embeds = {
				{
					title = "🏆 Top Voteurs - " .. monthName,
					description = "Voici le classement des meilleurs voteurs du mois !",
					color = 15844367, -- Gold
					fields = {},
					timestamp = os.date("!%Y-%m-%dT%H:%M:%S"),
					footer = {
						text = "Merci pour votre soutien !"
					}
				}
			}
		}
		
		local medals = {"🥇", "🥈", "🥉"}
		for i, player in ipairs(leaderboard) do
			table.insert(embed.embeds[1].fields, {
				name = medals[i] .. " #" .. i .. " - " .. player.player_name,
				value = player.monthly_votes .. " votes",
				inline = false
			})
		end
		
		-- Envoyer au webhook Discord avec reqwest
		local payload = util.TableToJSON(embed)
		
		reqwest({
			method = "POST",
			url = VoteRewards.Config.DiscordWebhook,
			timeout = 30,
			body = payload,
			type = "application/json",
			headers = {
				["User-Agent"] = "Garry's Mod Server",
			},
			success = function(status, body, headers)
				print("[Vote Rewards] ✓ Classement mensuel envoyé sur Discord! Statut:", status)
			end,
			failed = function(err, errExt)
				print("[Vote Rewards] ❌ Erreur webhook classement:", err, "(", errExt, ")")
			end
		})
	end)
end

-- Alias
hook.Add("PlayerSay", "VoteRewards_LeaderboardCommand", function(ply, text)
	local lower = string.lower(text)
	
	if lower == "!sendleaderboard" or lower == "/sendleaderboard" then
		if not ply:IsSuperAdmin() then
			ply:ChatPrint("[Vote Rewards] Cette commande est réservée aux super admins!")
			return ""
		end
		
		ply:ChatPrint("[Vote Rewards] Envoi du classement sur Discord...")
		VoteRewards.SendMonthlyLeaderboard()
		return ""
	end
end)

-- Commande admin pour forcer l'envoi du classement
concommand.Add("vote_send_leaderboard", function(ply)
	if IsValid(ply) and not ply:IsSuperAdmin() then
		ply:ChatPrint("Cette commande est réservée aux super admins!")
		return
	end
	
	VoteRewards.SendMonthlyLeaderboard()
	
	if IsValid(ply) then
		ply:ChatPrint("[Vote Rewards] Classement envoyé sur Discord!")
	else
		print("[Vote Rewards] Leaderboard sent to Discord!")
	end
end)

-- Commande admin pour reset manuel
concommand.Add("vote_reset_monthly", function(ply)
	if IsValid(ply) and not ply:IsSuperAdmin() then
		ply:ChatPrint("Cette commande est réservée aux super admins!")
		return
	end
	
	VoteRewards.SendMonthlyLeaderboard()
	
	local currentMonth = tonumber(os.date("%m"))
	MySQLite.query("UPDATE vote_rewards_players SET monthly_votes = 0, last_reset_month = " .. currentMonth)
	
	if IsValid(ply) then
		ply:ChatPrint("[Vote Rewards] Reset mensuel effectué!")
	else
		print("[Vote Rewards] Monthly reset completed manually!")
	end
end)

-- Commande admin pour donner des wheelspins
concommand.Add("vote_give_wheelspin", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then
		ply:ChatPrint("Cette commande est réservée aux super admins!")
		return
	end
	
	if not args[1] or not args[2] then
		if IsValid(ply) then
			ply:ChatPrint("Usage: vote_give_wheelspin <steamid64> <amount>")
		else
			print("Usage: vote_give_wheelspin <steamid64> <amount>")
		end
		return
	end
	
	local steamID = args[1]
	local amount = tonumber(args[2]) or 1
	
	VoteRewards.GetPlayerData(steamID, function(data)
		if not data then
			if IsValid(ply) then
				ply:ChatPrint("Joueur introuvable dans la base de données!")
			else
				print("Player not found in database!")
			end
			return
		end
		
		local newWheelspins = (data.wheelspins or 0) + amount
		VoteRewards.UpdatePlayerData(steamID, data.player_name, data.total_votes, data.monthly_votes, newWheelspins)
		
		local target = player.GetBySteamID64(steamID)
		if IsValid(target) then
			target:ChatPrint(string.format("[Vote Rewards] Un administrateur vous a donné %d Wheelspin(s) !", amount))
		end
		
		if IsValid(ply) then
			ply:ChatPrint(string.format("[Vote Rewards] %d Wheelspin(s) donnés à %s", amount, data.player_name))
		else
			print(string.format("[Vote Rewards] %d Wheelspin(s) given to %s", amount, data.player_name))
		end
	end)
end)
