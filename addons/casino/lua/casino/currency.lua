-- Gestion de la monnaie pour le Casino
-- Utilise directement les crédits BaseWars

Casino.Currency = Casino.Currency or {}
Casino.Currency.System = "basewars"
Casino.Currency.Initialized = false

-- Initialiser le système de monnaie (attendre que BaseWars soit chargé)
local function InitializeCurrency()
	-- Vérifier que BaseWars et les fonctions de crédits existent
	if not BaseWars then
		print("[Casino] WARNING: BaseWars not found!")
		return false
	end
	
	-- Vérifier qu'un joueur a bien les fonctions nécessaires
	local testPly = player.GetAll()[1]
	if IsValid(testPly) and not testPly.GetCredit then
		print("[Casino] WARNING: BaseWars credit functions not available yet!")
		return false
	end
	
	Casino.Currency.Initialized = true
	print("[Casino] Currency system initialized: BaseWars Credits")
	return true
end

-- Attendre que BaseWars soit complètement chargé
if SERVER then
	-- Essayer d'initialiser après le gamemode
	hook.Add("Initialize", "Casino_InitCurrency", function()
		timer.Simple(2, function()
			-- Si ça échoue, réessayer toutes les secondes jusqu'à 10 secondes
			local attempts = 0
			local function TryInit()
				if InitializeCurrency() then
					return
				end
				
				attempts = attempts + 1
				if attempts < 10 then
					timer.Simple(1, TryInit)
				else
					ErrorNoHalt("[Casino] Failed to initialize currency system after 10 attempts!\n")
				end
			end
			TryInit()
		end)
	end)
	
	-- Aussi essayer quand un joueur spawn (au cas où)
	hook.Add("PlayerInitialSpawn", "Casino_InitCurrency_Backup", function(ply)
		if not Casino.Currency.Initialized then
			timer.Simple(1, InitializeCurrency)
		end
	end)
else
	-- Côté client, initialiser après un délai
	timer.Simple(3, function()
		InitializeCurrency()
	end)
end

-- Obtenir l'argent d'un joueur
function Casino.Currency.GetMoney(ply)
	if not IsValid(ply) then return 0 end
	return ply:GetCredit() or 0
end

-- Donner de l'argent à un joueur
function Casino.Currency.AddMoney(ply, amount)
	if not IsValid(ply) or amount <= 0 then return false end
	
	ply:AddCredit(amount)
	
	return true
end

-- Retirer de l'argent à un joueur
function Casino.Currency.TakeMoney(ply, amount)
	if not IsValid(ply) or amount <= 0 then return false end
	
	local currentMoney = Casino.Currency.GetMoney(ply)
	if currentMoney < amount then return false end
	
	-- BaseWars utilise AddCredit avec des valeurs négatives pour retirer
	ply:AddCredit(-amount)
	
	return true
end

-- Vérifier si un joueur peut payer
function Casino.Currency.CanAfford(ply, amount)
	if not IsValid(ply) or amount <= 0 then return false end
	return Casino.Currency.GetMoney(ply) >= amount
end

-- Formater un montant pour l'affichage
function Casino.Currency.Format(amount)
	if BaseWars and BaseWars.FormatCredit then
		return BaseWars:FormatCredit(amount, true)
	end
	-- Fallback si BaseWars:FormatCredit n'est pas disponible
	return string.Comma(amount) .. " Credits"
end

print("[Casino] Currency system loaded: BaseWars Credits")
