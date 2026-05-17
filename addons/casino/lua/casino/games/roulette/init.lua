-- Roulette Synchronisée Initialization

Casino = Casino or {}
Casino.Roulette = Casino.Roulette or {}

if SERVER then
	AddCSLuaFile("client.lua")
	include("server.lua")
end

if CLIENT then
	include("client.lua")
end

-- Enregistrer le jeu dans le système Casino
Casino.RegisterGame("roulette", {
	name = "roulette",
	displayName = "Roulette Européenne",
	description = "Placez vos paris et tentez votre chance! Tous les joueurs parient sur le même spin.",
	icon = "🎡",
	minBet = 1,
	maxBet = 10000,
	htmlFile = "roulette/roulette.html",
	
	-- Setup des fonctions JavaScript/Lua
	setupFunctions = function(html)
		if not IsValid(html) then return end
		
		-- Obtenir les informations du joueur
		html:AddFunction("roulette", "getPlayerInfo", function()
			if LocalPlayer() and LocalPlayer():IsValid() then
				-- Demander le solde au serveur
				net.Start("Casino_Roulette_RequestBalance")
				net.SendToServer()
			end
		end)
		
		-- Envoyer le solde immédiatement au chargement
		timer.Simple(0.1, function()
			if IsValid(html) and LocalPlayer() and LocalPlayer():IsValid() then
				-- Demander le solde au serveur
				net.Start("Casino_Roulette_RequestBalance")
				net.SendToServer()
			end
		end)
		
		-- Placer un pari
		html:AddFunction("roulette", "placeBet", function(betType, betValue, amount)
			if tonumber(amount) then
				net.Start("Casino_Roulette_PlaceBet")
				net.WriteString(tostring(betType))
				net.WriteString(tostring(betValue))
				net.WriteUInt(tonumber(amount), 32)
				net.SendToServer()
			end
		end)
		
		-- Supprimer un pari
		html:AddFunction("roulette", "removeBet", function(betType, betValue, amount)
			if tonumber(amount) then
				net.Start("Casino_Roulette_RemoveBet")
				net.WriteString(tostring(betType))
				net.WriteString(tostring(betValue))
				net.WriteUInt(tonumber(amount), 32)
				net.SendToServer()
			end
		end)
		
		-- Supprimer tous les paris
		html:AddFunction("roulette", "clearAllBets", function()
			net.Start("Casino_Roulette_ClearAllBets")
			net.SendToServer()
		end)
		
		-- Retourner au menu
		html:AddFunction("roulette", "returnToMenu", function()
			if Casino.UI then
				Casino.UI:ReturnToMenu()
			end
		end)
		
		-- Créer une interface globale pour que le serveur puisse appeler les fonctions JS
		if CLIENT then
			RouletteJS = {
				startSpin = function(number, color)
					if IsValid(html) then
						html:Call(string.format([[
							if (typeof window.startSpin === 'function') {
								window.startSpin(%d, '%s');
							}
						]], number, color))
					end
				end,
				
				receiveSpinResult = function(result)
					if IsValid(html) then
						local winningBetsJSON = util.TableToJSON(result.winningBets or {})
						html:Call(string.format([[
							if (typeof window.receiveSpinResult === 'function') {
								window.receiveSpinResult({
									winningNumber: %d,
									winningColor: '%s',
									totalWin: %d,
									winningBets: %s
								});
							}
						]], result.winningNumber, result.winningColor, result.totalWin, winningBetsJSON))
					end
				end,
				
				updatePlayerInfo = function(balance)
					if IsValid(html) then
						html:Call(string.format([[
							if (typeof window.updatePlayerInfo === 'function') {
								window.updatePlayerInfo(%d);
							}
						]], balance))
					end
				end,
				
				betPlaced = function(status, message)
					if IsValid(html) then
						html:Call(string.format([[
							if (typeof window.betPlaced === 'function') {
								window.betPlaced('%s', '%s');
							}
						]], status, message))
					end
				end,
				
				updateTimer = function(timeRemaining, isSpinning)
					if IsValid(html) then
						html:Call(string.format([[
							if (typeof window.updateTimer === 'function') {
								window.updateTimer(%d, %s);
							}
						]], timeRemaining, isSpinning and "true" or "false"))
					end
				end
			}
		end
	end
})

print("[Casino] Roulette game registered")
