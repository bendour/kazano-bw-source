-- Gestion de la monnaie pour le Blackjack
-- S'intègre avec le système de monnaie existant (Basewars, DarkRP, etc.)

Blackjack.Currency = Blackjack.Currency or {}

-- Détection automatique du système de monnaie
local function DetectCurrencySystem()
	-- Vérifier si Basewars est disponible
	if Basewars and Basewars.GetPlayerMoney then
		return "basewars"
	end
	
	-- Vérifier si DarkRP est disponible
	if DarkRP and DarkRP.getMoney then
		return "darkrp"
	end
	
	-- Vérifier si PointShop 1 est disponible
	if PS and PS.FindPlayer then
		return "pointshop1"
	end
	
	-- Vérifier si PointShop 2 est disponible
	if PS2 and PS2.GetPlayerPoints then
		return "pointshop2"
	end
	
	-- Vérifier si XeninCoinflip est disponible (pour la compatibilité)
	if XeninCoinflip and XeninCoinflip.GetPlayerMoney then
		return "xenin"
	end
	
	-- Système par défaut
	return "default"
end

Blackjack.Currency.System = DetectCurrencySystem()

-- Fonctions pour obtenir l'argent du joueur
function Blackjack.Currency.GetMoney(ply)
	if not IsValid(ply) then return 0 end
	
	local system = Blackjack.Currency.System
	
	if system == "basewars" then
		return Basewars.GetPlayerMoney(ply) or 0
	elseif system == "darkrp" then
		return ply:getDarkRPVar("money") or 0
	elseif system == "pointshop1" then
		return PS.FindPlayer(ply):GetPoints() or 0
	elseif system == "pointshop2" then
		return PS2.GetPlayerPoints(ply) or 0
	elseif system == "xenin" then
		return XeninCoinflip.GetPlayerMoney(ply) or 0
	else
		-- Système par défaut - utiliser une variable de joueur personnalisée
		return ply:GetNWInt("Blackjack_Money", 1000) -- 1000 par défaut
	end
end

-- Fonctions pour donner de l'argent au joueur
function Blackjack.Currency.AddMoney(ply, amount)
	if not IsValid(ply) or amount <= 0 then return false end
	
	local system = Blackjack.Currency.System
	
	if system == "basewars" then
		Basewars.GivePlayerMoney(ply, amount)
	elseif system == "darkrp" then
		ply:addMoney(amount)
	elseif system == "pointshop1" then
		PS.FindPlayer(ply):GivePoints(amount)
	elseif system == "pointshop2" then
		PS2.GivePlayerPoints(ply, amount)
	elseif system == "xenin" then
		XeninCoinflip.GivePlayerMoney(ply, amount)
	else
		-- Système par défaut
		local current = ply:GetNWInt("Blackjack_Money", 0)
		ply:SetNWInt("Blackjack_Money", current + amount)
	end
	
	-- Logger la transaction
	if Blackjack:GetConfig("Security.LogTransactions") then
		print(string.format("[Blackjack] %s a reçu %d (Nouveau solde: %d)", ply:Nick(), amount, Blackjack.Currency.GetMoney(ply)))
	end
	
	return true
end

-- Fonctions pour retirer de l'argent au joueur
function Blackjack.Currency.TakeMoney(ply, amount)
	if not IsValid(ply) or amount <= 0 then return false end
	
	local currentMoney = Blackjack.Currency.GetMoney(ply)
	if currentMoney < amount then return false end
	
	local system = Blackjack.Currency.System
	
	if system == "basewars" then
		Basewars.TakePlayerMoney(ply, amount)
	elseif system == "darkrp" then
		ply:addMoney(-amount)
	elseif system == "pointshop1" then
		PS.FindPlayer(ply):TakePoints(amount)
	elseif system == "pointshop2" then
		PS2.TakePlayerPoints(ply, amount)
	elseif system == "xenin" then
		XeninCoinflip.TakePlayerMoney(ply, amount)
	else
		-- Système par défaut
		local current = ply:GetNWInt("Blackjack_Money", 0)
		ply:SetNWInt("Blackjack_Money", math.max(0, current - amount))
	end
	
	-- Logger la transaction
	if Blackjack:GetConfig("Security.LogTransactions") then
		print(string.format("[Blackjack] %s a perdu %d (Nouveau solde: %d)", ply:Nick(), amount, Blackjack.Currency.GetMoney(ply)))
	end
	
	return true
end

-- Fonction pour vérifier si le joueur a assez d'argent
function Blackjack.Currency.CanAfford(ply, amount)
	if not IsValid(ply) or amount <= 0 then return false end
	return Blackjack.Currency.GetMoney(ply) >= amount
end

-- Fonction pour formater l'argent
function Blackjack.Currency.FormatMoney(amount)
	local system = Blackjack.Currency.System
	
	if system == "darkrp" then
		return DarkRP.formatMoney(amount)
	elseif system == "pointshop1" or system == "pointshop2" then
		return tostring(amount) .. " points"
	else
		-- Format par défaut
		return "$" .. string.Comma(amount)
	end
end

-- Fonction pour obtenir le nom du système de monnaie
function Blackjack.Currency.GetSystemName()
	local names = {
		["basewars"] = "Basewars",
		["darkrp"] = "DarkRP",
		["pointshop1"] = "PointShop 1",
		["pointshop2"] = "PointShop 2",
		["xenin"] = "XeninCoinflip",
		["default"] = "Default"
	}
	
	return names[Blackjack.Currency.System] or "Unknown"
end

-- Initialisation des joueurs pour le système par défaut
if Blackjack.Currency.System == "default" then
	hook.Add("PlayerInitialSpawn", "Blackjack_InitMoney", function(ply)
		-- Donner de l'argent de départ aux nouveaux joueurs
		if ply:GetNWInt("Blackjack_Money", 0) == 0 then
			ply:SetNWInt("Blackjack_Money", 1000)
		end
	end)
end

print("[Blackjack] Système de monnaie détecté: " .. Blackjack.Currency.GetSystemName())
