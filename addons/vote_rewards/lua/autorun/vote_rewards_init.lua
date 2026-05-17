-- Chargement automatique de l'addon
if SERVER then
	-- Fichiers CLIENT (envoyés au client)
	AddCSLuaFile("vote_rewards/html_loader.lua")
	AddCSLuaFile("vote_rewards/cl_wheelspin.lua")
	
	-- NE PAS envoyer config.lua au client (contient webhooks/API keys)
	-- Le client reçoit les données nécessaires via net messages
	
	-- Fichiers SERVEUR
	include("vote_rewards/config.lua")
	include("vote_rewards/sv_database.lua")
	include("vote_rewards/sv_api.lua")
	include("vote_rewards/sv_rewards.lua")
	include("vote_rewards/sv_leaderboard.lua")
	include("vote_rewards/html_loader.lua")
else
	-- CLIENT: pas besoin du config, les données sont envoyées via net
	include("vote_rewards/html_loader.lua")
	include("vote_rewards/cl_wheelspin.lua")
end
