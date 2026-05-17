-- Configuration du Casino
-- Paramètres globaux pour tous les jeux

Casino.Config = Casino.Config or {}

Casino.Config = {
	-- Sécurité générale
	Security = {
		AntiSpamDelay = 1, -- Délai en secondes entre les actions
		MaxBetsPerSession = 1000,
		LogTransactions = true,
		EnableAntiCheat = true
	},
	
	-- Interface utilisateur
	UI = {
		WindowWidth = CLIENT and (ScrW() * 0.9) or 1600, -- Valeur par défaut pour serveur
		WindowHeight = CLIENT and (ScrH() * 0.9) or 900,
		Theme = "dark", -- dark, light
		Language = "fr", -- fr, en
		EnableAnimations = true,
		EnableSounds = true
	},
	
	-- Système de monnaie
	Currency = {
		Symbol = "$",
		Format = "%s %s", -- amount symbol
		MinimumBalance = 0,
		EnableNegativeBalance = false
	}
}

-- Fonction pour obtenir une configuration
function Casino:GetConfig(key)
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

-- Fonction pour définir une configuration
function Casino:SetConfig(key, value)
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

print("[Casino] Configuration chargée")
