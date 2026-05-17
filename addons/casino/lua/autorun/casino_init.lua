-- Casino Addon v2.0 - Initialization
-- Simple loading system inspired by adailyrewards

Casino = Casino or {}
Casino.Version = "2.0.0"
Casino.Games = Casino.Games or {}

-- Game registration function
function Casino.RegisterGame(name, gameData)
	if not name or not gameData then
		ErrorNoHalt("[Casino] Invalid game registration\n")
		return
	end
	
	Casino.Games[name] = gameData
end

-- SERVEUR: Envoyer les fichiers au client et charger les fichiers serveur
if SERVER then
	
	-- Core modules
	AddCSLuaFile("casino/config.lua")
	AddCSLuaFile("casino/html_loader.lua")
	AddCSLuaFile("casino/currency.lua")
	AddCSLuaFile("casino/ui_manager.lua")
	
	include("casino/config.lua")
	include("casino/html_loader.lua")
	include("casino/currency.lua")
	include("casino/statistics.lua")
	
	-- Blackjack game
	AddCSLuaFile("casino/games/blackjack/init.lua")
	AddCSLuaFile("casino/games/blackjack/client.lua")
	
	include("casino/games/blackjack/init.lua")
	include("casino/games/blackjack/server.lua")
	
	-- Mines game
	AddCSLuaFile("casino/games/mines/init.lua")
	AddCSLuaFile("casino/games/mines/client.lua")
	
	include("casino/games/mines/init.lua")
	include("casino/games/mines/server.lua")
	
	-- Slots game (Le Bandit)
	AddCSLuaFile("casino/games/slots/init.lua")
	AddCSLuaFile("casino/games/slots/client.lua")
	
	include("casino/games/slots/init.lua")
	include("casino/games/slots/server.lua")
	
	-- Roulette game
	AddCSLuaFile("casino/games/roulette/init.lua")
	AddCSLuaFile("casino/games/roulette/client.lua")
	
	include("casino/games/roulette/init.lua")
	include("casino/games/roulette/server.lua")
end

-- CLIENT: Charger les fichiers client
if CLIENT then
	
	include("casino/config.lua")
	include("casino/html_loader.lua")
	include("casino/currency.lua")
	include("casino/ui_manager.lua")
	
	-- Blackjack game
	include("casino/games/blackjack/init.lua")
	include("casino/games/blackjack/client.lua")
	
	-- Mines game
	include("casino/games/mines/init.lua")
	include("casino/games/mines/client.lua")
	
	-- Slots game (Le Bandit)
	include("casino/games/slots/init.lua")
	include("casino/games/slots/client.lua")
	
	-- Roulette game
	include("casino/games/roulette/init.lua")
	include("casino/games/roulette/client.lua")
	
	-- Console commands
	concommand.Add("casino", function()
		if Casino.UI then
			Casino.UI:Toggle()
		end
	end)
	
	concommand.Add("casino_reload", function()
		if Casino.UI then
			Casino.UI:Close()
		end
		include("autorun/casino_init.lua")
	end)
end

-- SERVER: Console command for clearing cache + chat command
if SERVER then
	concommand.Add("casino_clearcache", function()
		Casino.HTML = Casino.HTML or {}
		Casino.HTML.Cache = {}
	end)
	
	-- Commande chat !casino
	hook.Add("PlayerSay", "Casino_ChatCommand", function(ply, text)
		if string.lower(text) == "!casino" then
			ply:ConCommand("casino")
			return ""
		end
	end)
end
