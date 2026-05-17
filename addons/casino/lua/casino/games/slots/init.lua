-- Le Bandit - Machine à Sous Initialisation

Casino.RegisterGame("slots", {
	name = "slots",
	displayName = "Le Bandit",
	description = "Machine à sous Far West",
	icon = "🎰",
	minBet = 1,
	maxBet = 10000,
	htmlFile = "slots/slots.html",
	
	setupFunctions = function(html)
		if not IsValid(html) then return end
		
		-- Obtenir les informations du joueur
		html:AddFunction("slots", "getPlayerInfo", function()
			if LocalPlayer() and LocalPlayer():IsValid() then
				local balance = Casino.Currency.GetMoney(LocalPlayer())
				html:Call(string.format("updatePlayerInfo(%d)", balance))
			end
		end)
		
		-- Envoyer le solde immédiatement au chargement
		timer.Simple(0.1, function()
			if IsValid(html) and LocalPlayer() and LocalPlayer():IsValid() then
				-- Demander le solde au serveur pour être sûr d'avoir la bonne valeur
				net.Start("Casino_Blackjack_RequestBalance")
				net.SendToServer()
				
				-- Backup: utiliser le solde local aussi
				local balance = Casino.Currency.GetMoney(LocalPlayer())
				html:Call(string.format("updatePlayerInfo(%d)", balance))
			end
		end)
		
		-- Lancer un spin
		html:AddFunction("slots", "spin", function(bet)
			if LocalPlayer() and LocalPlayer():IsValid() then
				net.Start("Casino_Slots_Spin")
				net.WriteUInt(tonumber(bet) or 0, 32)
				net.SendToServer()
			end
		end)
		
		-- Retour au menu
		html:AddFunction("slots", "returnToMenu", function()
			if Casino.UI then
				Casino.UI:ReturnToMenu()
			end
		end)
	end
})

-- Charger les fichiers
if SERVER then
	AddCSLuaFile("client.lua")
	include("server.lua")
else
	include("client.lua")
end
