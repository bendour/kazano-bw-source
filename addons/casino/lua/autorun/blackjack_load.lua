-- Blackjack DHTML Addon
-- Charge le système de blackjack pour Gmod

Blackjack = Blackjack or {}
Blackjack.Config = Blackjack.Config or {}
Blackjack.Games = Blackjack.Games or {}

-- Fonctions pour inclure les fichiers
function Blackjack:IncludeClient(path)
	if (CLIENT) then
		include("blackjack/" .. path .. ".lua")
	end

	if (SERVER) then
		AddCSLuaFile("blackjack/" .. path .. ".lua")
	end
end

function Blackjack:IncludeServer(path)
	if (SERVER) then
		include("blackjack/" .. path .. ".lua")
	end
end

function Blackjack:IncludeShared(path)
	self:IncludeServer(path)
	self:IncludeClient(path)
end

-- Configuration par défaut
Blackjack.Config = {
	-- Mises minimales et maximales
	MinBet = 100,
	MaxBet = 10000,
	
	-- Multiplicateurs de gains
	BlackjackPayout = 2.5, -- 3:2 pour un blackjack naturel
	NormalPayout = 2, -- 1:1 pour une victoire normale
	
	-- Temps d'animation (en secondes)
	CardDealDelay = 0.5,
	ShowCardDelay = 0.3,
	
	-- Messages
	Messages = {
		Welcome = "Bienvenue au Blackjack!",
		Win = "Vous avez gagné!",
		Lose = "Vous avez perdu!",
		Push = "Match nul!",
		Blackjack = "Blackjack!",
		Bust = "Dépassement!",
		InsufficientFunds = "Fonds insuffisants!",
		InvalidBet = "Mise invalide!"
	}
}

-- Chargement des fichiers
local function Load()
	-- Inclure les fichiers principaux
	Blackjack:IncludeShared("config")
	Blackjack:IncludeShared("currency")
	
	-- Côté serveur
	Blackjack:IncludeServer("server")
	Blackjack:IncludeServer("game_logic")
	
	-- Côté client
	Blackjack:IncludeClient("client")
	Blackjack:IncludeClient("ui")
	
	MsgC(Color(0, 255, 0), "[Blackjack] Blackjack DHTML addon chargé avec succès!\n")
	
	Blackjack.FinishedLoading = true
	hook.Run("Blackjack.FinishedLoading")
end

-- Charger l'addon
Load()

-- Ajouter les ressources côté serveur
if (SERVER) then
	-- Ajouter les sons et matériaux
	resource.AddFile("sound/blackjack/card_place.wav")
	resource.AddFile("sound/blackjack/card_flip.wav")
	resource.AddFile("sound/blackjack/chip_stack.wav")
	resource.AddFile("sound/blackjack/win.wav")
	resource.AddFile("sound/blackjack/lose.wav")
	
	-- Créer la commande console
	concommand.Add("slots", function(ply, cmd, args)
		if IsValid(ply) then
			-- Ouvrir l'interface DHTML pour le joueur
			ply:ConCommand("blackjack_open")
		end
	end)
end
