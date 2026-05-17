-- Configuration du Blackjack DHTML
-- Ce fichier contient tous les paramètres configurables

Blackjack.Config = Blackjack.Config or {}

-- Surcharge de la configuration avec des valeurs plus détaillées
Blackjack.Config = {
	-- Paramètres de jeu
	Game = {
		MinBet = 100,
		MaxBet = 10000,
		DefaultBet = 500,
		BlackjackPayout = 2.5, -- 3:2 pour blackjack naturel
		NormalPayout = 2.0, -- 1:1 pour victoire normale
		InsurancePayout = 2.0, -- 1:1 pour assurance
		DealerStandOn = 17, -- Le croupier s'arrête à 17
		AllowDoubleDown = true,
		AllowSplit = true,
		AllowInsurance = true,
		MaxSplits = 3
	},
	
	-- Paramètres d'interface
	UI = {
		WindowWidth = 900,
		WindowHeight = 650,
		CardWidth = 71,
		CardHeight = 96,
		ChipValues = {10, 25, 50, 100, 500, 1000},
		AnimationSpeed = 0.3,
		AutoCloseDelay = 5 -- Fermeture auto après victoire/défaite
	},
	
	-- Messages localisés
	Messages = {
		Welcome = "Bienvenue au Blackjack!",
		PlaceBet = "Placez votre mise",
		YourTurn = "Votre tour",
		DealerTurn = "Tour du croupier",
		Win = "Vous avez gagné!",
		Lose = "Vous avez perdu!",
		Push = "Match nul!",
		Blackjack = "Blackjack!",
		Bust = "Dépassement!",
		InsufficientFunds = "Fonds insuffisants!",
		InvalidBet = "Mise invalide!",
		DealerBlackjack = "Blackjack du croupier!",
		YouBlackjack = "Votre Blackjack!",
		DoubleDown = "Double",
		Stand = "Rester",
		Hit = "Tirer",
		Split = "Diviser",
		Insurance = "Assurance"
	},
	
	-- Sons
	Sounds = {
		CardPlace = "blackjack/card_place.wav",
		CardFlip = "blackjack/card_flip.wav",
		ChipStack = "blackjack/chip_stack.wav",
		Win = "blackjack/win.wav",
		Lose = "blackjack/lose.wav",
		ButtonClick = "ui/buttonclick.wav"
	},
	
	-- Couleurs du thème
	Theme = {
		Background = "#0d5f0d",
		Table = "#1a7a1a",
		CardBack = "#8b0000",
		CardFront = "#ffffff",
		Text = "#ffffff",
		ButtonText = "#000000",
		ButtonHover = "#4CAF50",
		WinColor = "#4CAF50",
		LoseColor = "#f44336",
		ChipColors = {
			[10] = "#ffffff",
			[25] = "#ff0000",
			[50] = "#0000ff",
			[100] = "#000000",
			[500] = "#ff00ff",
			[1000] = "#ffa500"
		}
	},
	
	-- Paramètres de sécurité
	Security = {
		MaxGamesPerMinute = 10,
		MaxBetsPerSession = 1000, -- Nombre maximum de paris par session
		AntiSpamDelay = 1,
		LogTransactions = true,
		MinPlayTime = 30 -- Temps minimum entre deux parties
	}
}

-- Fonction pour obtenir une configuration
function Blackjack:GetConfig(key)
	if not key then return self.Config end
	
	local keys = string.Explode(".", key)
	local value = self.Config
	
	for _, k in ipairs(keys) do
		if value and value[k] then
			value = value[k]
		else
			return nil
		end
	end
	
	return value
end

-- Fonction pour mettre à jour une configuration
function Blackjack:SetConfig(key, value)
	if not key then return false end
	
	local keys = string.Explode(".", key)
	local config = self.Config
	
	for i = 1, #keys - 1 do
		local k = keys[i]
		if not config[k] then
			config[k] = {}
		end
		config = config[k]
	end
	
	config[keys[#keys]] = value
	return true
end
