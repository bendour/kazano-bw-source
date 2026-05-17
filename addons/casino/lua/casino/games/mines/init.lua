-- Initialisation du jeu Mines

-- Enregistrer le jeu dans le système Casino
Casino.RegisterGame("mines", {
	name = "Mines",
	displayName = "Mines",
	description = "Démineur style casino. Évitez les bombes et multipliez vos gains !",
	icon = "💣",
	minBet = 1,
	maxBet = 10000,
	htmlFile = "mines/mines.html",
	
	-- Setup des fonctions JavaScript/Lua
	setupFunctions = function(html)
		if not IsValid(html) then return end
		
		-- Obtenir les informations du joueur
		html:AddFunction("mines", "getPlayerInfo", function()
			if LocalPlayer() and LocalPlayer():IsValid() then
				net.Start("Casino_Blackjack_RequestBalance")
				net.SendToServer()
			end
		end)
		
		-- Placer une mise
		html:AddFunction("mines", "placeBet", function(amount, bombCount)
			net.Start("Casino_Mines_PlaceBet")
			net.WriteTable({
				bet = tonumber(amount) or 0,
				bombCount = tonumber(bombCount) or 3
			})
			net.SendToServer()
		end)
		
		-- Révéler une case
		html:AddFunction("mines", "revealTile", function(tileIndex)
			net.Start("Casino_Mines_RevealTile")
			net.WriteInt(tonumber(tileIndex) + 1, 8) -- +1 car JS utilise 0-24, Lua utilise 1-25
			net.SendToServer()
		end)
		
		-- Encaisser les gains
		html:AddFunction("mines", "cashOut", function()
			net.Start("Casino_Mines_CashOut")
			net.SendToServer()
		end)
		
		-- Retour au menu
		html:AddFunction("mines", "returnToMenu", function()
			if Casino.UI then
				Casino.UI:ReturnToMenu()
			end
		end)
		
		-- Demander le solde au chargement
		timer.Simple(0.1, function()
			if IsValid(html) and LocalPlayer() and LocalPlayer():IsValid() then
				net.Start("Casino_Blackjack_RequestBalance")
				net.SendToServer()
			end
		end)
	end
})

-- Charger les fichiers
if SERVER then
	include("casino/games/mines/server.lua")
	AddCSLuaFile("casino/games/mines/client.lua")
else
	include("casino/games/mines/client.lua")
end
