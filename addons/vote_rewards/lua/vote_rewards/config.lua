-- Configuration SERVEUR UNIQUEMENT
-- Ce fichier n'est PAS envoyé au client pour protéger les webhooks/API keys

if CLIENT then return end -- Sécurité: ne pas exécuter côté client

VoteRewards = VoteRewards or {}

-- Configuration
VoteRewards.Config = {
	-- Discord Webhook pour le classement mensuel (SECRET)
	DiscordWebhook = "https://discord.com/api/webhooks/1389754268730261544/Gr4zoGrNwNQIxmUh1-CcO-a9VYCvxOatNHHgvmQ9n_SYdegHQywxkG7daUCEYoD0OKr9",
	
	-- Discord Webhook pour les coupons 5€ (SECRET)
	CouponWebhook = "https://discord.com/api/webhooks/1443300493895008387/ouRjt-aqZC5dFyoVqdsKxiYkb0XiZF6qtuX54OoS-lBIf2VJSJw2bpk4BKvt2v5YOWY8",
	
	-- Top-Serveur API (SECRET)
	TopServeurEnabled = true,
	TopServeurAPIKey = "7KMUP2NZIUOIVD",
	TopServeurServerID = "68f274c938d27",
	TopServeurCheckURL = "https://api.top-serveurs.net/v1/servers/%s/vote-verification/%s",
	TopServeurVoteURL = "https://top-serveurs.net/garrys-mod/kazano-basewars-68f274c938d27",
	
	-- Récompenses du wheelspin (envoyées au client via net message, pas de secrets ici)
	WheelRewards = {
		{ name = "50 Crédits", type = "credits", value = 50, chance = 50, color = Color(52, 152, 219) },
		{ name = "200 Crédits", type = "credits", value = 200, chance = 30, color = Color(46, 204, 113) },
		{ name = "250 Crédits", type = "credits", value = 250, chance = 20, color = Color(155, 89, 182) },
		{ name = "500 Crédits", type = "credits", value = 500, chance = 10, color = Color(155, 89, 182) },
		{ name = "1000 Crédits", type = "credits", value = 1000, chance = 5, color = Color(155, 89, 182) },
		{ name = "500 Pointshop", type = "pointshop", value = 500, chance = 50, color = Color(231, 76, 60) },
		{ name = "1000 Pointshop", type = "pointshop", value = 1000, chance = 30, color = Color(231, 76, 60) },
		{ name = "2500 Pointshop", type = "pointshop", value = 2500, chance = 20, color = Color(230, 126, 34) },
		{ name = "5000 Pointshop", type = "pointshop", value = 5000, chance = 10, color = Color(230, 126, 34) },
		{ name = "10000 Pointshop", type = "pointshop", value = 10000, chance = 5, color = Color(230, 126, 34) },
		{ name = "Coupon 5€", type = "coupon", value = 5, chance = 1, color = Color(255, 215, 0) },
		{ name = "JACKPOT 10K", type = "credits", value = 10000, chance = 1, color = Color(192, 57, 43) },
	},
	
	-- Classement
	TopPlayersCount = 3,
	ResetDay = 1,
	
	-- Interface
	WheelSpinDuration = 5,
	ShowParticles = true,
}

return VoteRewards.Config
