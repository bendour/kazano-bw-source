-- Chicken Road Initialization

Casino.RegisterGame("chicken", {
	displayName = "Chicken Road",
	description = "Évitez les os cachés et multipliez vos gains!",
	htmlFile = "chicken/chicken.html",
	
	setupFunctions = function(html)
		-- Fonctions Lua appelées depuis JavaScript
		html:AddFunction("chicken", "startGame", function(bet, difficulty)
			net.Start("Casino_Chicken_StartGame")
			net.WriteUInt(tonumber(bet) or 0, 32)
			net.WriteString(tostring(difficulty))
			net.SendToServer()
		end)
		
		html:AddFunction("chicken", "pickTile", function(tileIndex)
			net.Start("Casino_Chicken_PickTile")
			net.WriteUInt(tonumber(tileIndex) or 0, 8)
			net.SendToServer()
		end)
		
		html:AddFunction("chicken", "cashOut", function()
			net.Start("Casino_Chicken_CashOut")
			net.SendToServer()
		end)
		
		html:AddFunction("chicken", "getBalance", function()
			net.Start("Casino_Chicken_RequestBalance")
			net.SendToServer()
		end)
		
		html:AddFunction("chicken", "returnToMenu", function()
			if Casino.UI then
				Casino.UI:ReturnToMenu()
			end
		end)
		
		-- Créer une interface globale pour que le serveur puisse appeler les fonctions JS
		if CLIENT then
			ChickenJS = {
				updateGameState = function(state)
					if IsValid(html) then
						local stateJSON = util.TableToJSON(state)
						html:Call(string.format([[
							if (typeof window.updateGameState === 'function') {
								window.updateGameState(%s);
							}
						]], stateJSON))
					end
				end,
				
				gameResult = function(status, message, amount)
					if IsValid(html) then
						html:Call(string.format([[
							if (typeof window.gameResult === 'function') {
								window.gameResult('%s', '%s', %d);
							}
						]], status, message:gsub("'", "\\'"), amount))
					end
				end,
				
				updateBalance = function(balance)
					if IsValid(html) then
						html:Call(string.format([[
							if (typeof window.updateBalance === 'function') {
								window.updateBalance(%d);
							}
						]], balance))
					end
				end
			}
		end
	end
})

print("[Casino] Chicken game registered")
