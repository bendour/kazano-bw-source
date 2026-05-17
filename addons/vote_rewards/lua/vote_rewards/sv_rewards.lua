-- Système de récompenses pour Vote Rewards
VoteRewards = VoteRewards or {}

-- Charger le module reqwest pour les webhooks Discord
require("reqwest")

util.AddNetworkString("VoteRewards_SpinWheel")
util.AddNetworkString("VoteRewards_SpinResult")
util.AddNetworkString("VoteRewards_GiveReward")

-- Calculer la récompense basée sur les probabilités
function VoteRewards.CalculateReward()
	local reward, _ = VoteRewards.CalculateRewardWithIndex()
	return reward
end

-- Calculer la récompense et retourner l'index
function VoteRewards.CalculateRewardWithIndex()
	local totalChance = 0
	for _, reward in ipairs(VoteRewards.Config.WheelRewards) do
		totalChance = totalChance + reward.chance
	end
	
	local roll = math.random(1, totalChance)
	local currentChance = 0
	
	for i, reward in ipairs(VoteRewards.Config.WheelRewards) do
		currentChance = currentChance + reward.chance
		if roll <= currentChance then
			return reward, i
		end
	end
	
	-- Fallback
	return VoteRewards.Config.WheelRewards[1], 1
end

-- Envoyer une notification Discord pour les coupons
local function SendCouponDiscordNotification(playerName, steamID)
	local webhook = VoteRewards.Config.CouponWebhook
	if not webhook or webhook == "VOTRE_WEBHOOK_ICI" then
		return
	end
	
	-- Envoyer le webhook Discord avec reqwest
	local embed = {
		username = "Vote Rewards",
		avatar_url = "https://i.imgur.com/4M34hi2.png",
		embeds = {{
			title = "🎉 Coupon 5€ Gagné!",
			description = string.format("**%s** a gagné un coupon de 5€ sur la boutique!\n\n**SteamID:** `%s`\n\nLe joueur doit créer un ticket Discord pour recevoir son coupon.", playerName, steamID),
			color = 16766720,
			timestamp = os.date("!%Y-%m-%dT%H:%M:%S"),
			footer = {
				text = "Vote Rewards System"
			}
		}}
	}
	
	local payload = util.TableToJSON(embed)
	
	-- Utiliser reqwest (bibliothèque chargée avec require)
	reqwest({
		method = "POST",
		url = webhook,
		timeout = 30,
		body = payload,
		type = "application/json",
		headers = {
			["User-Agent"] = "Garry's Mod Server",
		},
		success = function(status, body, headers)
		end,
		failed = function(err, errExt)
		end
	})
end

-- Donner une récompense à un joueur
function VoteRewards.GiveReward(ply, reward)
	local steamID = ply:SteamID64()
	local playerName = ply:Nick()
	
	if reward.type == "credits" then
		-- Donner des crédits
		if ply.AddCredit then
			ply:AddCredit(reward.value)
		end
		
		VoteRewards.AddToHistory(steamID, playerName, "credits", tostring(reward.value))
		
	elseif reward.type == "pointshop" then
		-- Donner des points Pointshop (BaseWars)
		if ply.AddPointshop then
			ply:AddPointshop(reward.value)
		end
		
		VoteRewards.AddToHistory(steamID, playerName, "pointshop", tostring(reward.value))
		
	elseif reward.type == "coupon" then
		-- Coupon boutique - Enregistrer dans la base de données
		local couponValue = tostring(reward.value) .. "€"
		VoteRewards.AddToHistory(steamID, playerName, "coupon", couponValue)
		VoteRewards.AddCoupon(steamID, playerName, couponValue)
		
		-- Envoyer notification Discord (peut échouer mais le coupon est sauvegardé)
		SendCouponDiscordNotification(playerName, steamID)
	end
end

-- Recevoir une demande de spin depuis le client
net.Receive("VoteRewards_SpinWheel", function(len, ply)
	local steamID = ply:SteamID64()
	
	VoteRewards.GetPlayerData(steamID, function(data)
		local wheelspins = tonumber(data and data.wheelspins or 0)
		if not data or wheelspins <= 0 then
			ply:ChatPrint("[Vote Rewards] Vous n'avez pas de Wheelspin disponible!")
			return
		end
		
		-- Utiliser un wheelspin
		VoteRewards.UseWheelspin(steamID, ply:Nick())
		
		-- Calculer la récompense et trouver son index
		local reward, rewardIndex = VoteRewards.CalculateRewardWithIndex()
		
		-- Envoyer immédiatement l'index au client pour l'animation
		net.Start("VoteRewards_SpinResult")
			net.WriteInt(rewardIndex, 8)
			net.WriteString(util.TableToJSON(reward))
		net.Send(ply)
		
		-- Donner la récompense après l'animation
		timer.Simple(VoteRewards.Config.WheelSpinDuration, function()
			if IsValid(ply) then
				net.Start("VoteRewards_GiveReward")
					net.WriteString(util.TableToJSON(reward))
				net.Send(ply)
				
				-- Donner la récompense
				VoteRewards.GiveReward(ply, reward)
			end
		end)
	end)
end)
