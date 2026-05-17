-- Gestionnaire d'interface utilisateur du Casino
-- Gère le menu principal et les transitions entre jeux
-- Ce fichier n'est chargé que côté client

Casino.UI = Casino.UI or {}
Casino.UI.Frame = nil
Casino.UI.HTML = nil
Casino.UI.IsOpen = false
Casino.UI.CurrentGame = nil
	
	-- Ouvrir le menu principal
	function Casino.UI:Open()
		if self.IsOpen then return end
		
		-- Vérifier que le système de chargement HTML est prêt
		if not Casino.LoadHTML then
			-- Limiter les tentatives
			self.LoadAttempts = (self.LoadAttempts or 0) + 1
			
			if self.LoadAttempts > 10 then
				ErrorNoHalt("[Casino UI] ERREUR CRITIQUE: Le système de chargement HTML ne s'est pas initialisé après 10 tentatives!\n")
				ErrorNoHalt("[Casino UI] Vérifiez que html_loader.lua est bien chargé.\n")
				self.LoadAttempts = 0
				return
			end
			
			timer.Simple(0.5, function()
				self:Open()
			end)
			return
		end
		
		-- Réinitialiser le compteur
		self.LoadAttempts = 0
		
		-- Créer la fenêtre principale
		self.Frame = vgui.Create("DFrame")
		self.Frame:SetSize(ScrW() * 0.9, ScrH() * 0.9)
		self.Frame:SetTitle("")
		self.Frame:SetDraggable(false)
		self.Frame:ShowCloseButton(false)
		self.Frame:MakePopup()
		self.Frame:Center()
		self.Frame:SetDeleteOnClose(true)
		
		-- Retirer la barre de titre par défaut
		self.Frame.Paint = function(s, w, h) end
		
		-- Créer le panneau DHTML
		self.HTML = vgui.Create("DHTML", self.Frame)
		self.HTML:Dock(FILL)
		self.HTML:SetAllowLua(true)
		
		-- Charger le HTML
		Casino.LoadHTML("main/main.html", function(content)
			if IsValid(self.HTML) then
				self.HTML:SetHTML(content)
				
				-- Setup des fonctions JavaScript après le chargement
				timer.Simple(0.5, function()
					if self.IsOpen and IsValid(self.HTML) then
						self:SetupMainMenuFunctions()
						self:UpdatePlayerInfo()
					end
				end)
			end
		end)
		
		-- Gérer la fermeture
		self.Frame.OnClose = function()
			self.IsOpen = false
			self.Frame = nil
			self.HTML = nil
			self.CurrentGame = nil
		end
		
		self.IsOpen = true
	end
	
	-- Fermer le menu
	function Casino.UI:Close()
		if self.Frame and IsValid(self.Frame) then
			self.Frame:Close()
		end
		self.IsOpen = false
	end
	
	-- Basculer le menu
	function Casino.UI:Toggle()
		if self.IsOpen then
			self:Close()
		else
			self:Open()
		end
	end
	
	-- Setup des fonctions pour le menu principal
	function Casino.UI:SetupMainMenuFunctions()
		if not IsValid(self.HTML) then return end
		
		-- Obtenir les informations du joueur
		self.HTML:AddFunction("casino", "getPlayerInfo", function()
			self:UpdatePlayerInfo()
		end)
		
		-- Ouvrir un jeu
		self.HTML:AddFunction("casino", "openGame", function(gameName)
			self:OpenGame(gameName)
		end)
		
		-- Fermer le menu
		self.HTML:AddFunction("casino", "close", function()
			self:Close()
		end)
		
		-- Sauvegarder un paramètre
		self.HTML:AddFunction("casino", "saveSetting", function(key, value)
			self:SaveSetting(key, value)
		end)
	end
	
	-- Mettre à jour les informations du joueur
	function Casino.UI:UpdatePlayerInfo()
		if not IsValid(self.HTML) or not self.IsOpen then return end
		
		local balance = Casino.Currency.GetMoney(LocalPlayer())
		local balanceFormatted = Casino.Currency.Format(balance)
		
		-- Demander les statistiques au serveur
		net.Start("Casino_RequestStats")
		net.SendToServer()
		
		-- Demander l'historique au serveur
		net.Start("Casino_RequestHistory")
		net.SendToServer()
		
		-- Demander le leaderboard au serveur
		net.Start("Casino_RequestLeaderboard")
		net.SendToServer()
		
		-- Les stats seront reçues via le net message et updateront l'UI automatiquement
		-- Envoyer d'abord les infos de base
		self.HTML:Call(string.format("updatePlayerInfo(%d, '%s', null)", 
			balance,
			balanceFormatted))
	end
	
	-- Ouvrir un jeu spécifique
	function Casino.UI:OpenGame(gameName)
		local game = Casino.Games[gameName]
		
		if not game then
			return
		end
		
		if not game.htmlFile then
			return
		end
		
		if not Casino.LoadHTML then
			return
		end
		
		-- Charger l'interface du jeu
		self.CurrentGame = gameName
		
		-- Charger le HTML du jeu
		Casino.LoadHTML(game.htmlFile, function(content)
			if IsValid(self.HTML) then
				self.HTML:SetHTML(content)
				
				-- Setup des fonctions après le chargement
				timer.Simple(0.5, function()
					if self.IsOpen and IsValid(self.HTML) and self.CurrentGame == gameName then
						self:SetupGameFunctions(gameName)
					end
				end)
			end
		end)
	end
	
	-- Retourner au menu principal
	function Casino.UI:ReturnToMenu()
		if not self.IsOpen or not IsValid(self.HTML) then return end
		if not Casino.LoadHTML then return end
		
		self.CurrentGame = nil
		
		-- Charger le menu principal
		Casino.LoadHTML("main/main.html", function(content)
			if IsValid(self.HTML) then
				self.HTML:SetHTML(content)
				
				timer.Simple(0.5, function()
					if self.IsOpen and IsValid(self.HTML) then
						self:SetupMainMenuFunctions()
						self:UpdatePlayerInfo()
					end
				end)
			end
		end)
	end
	
	-- Setup des fonctions pour un jeu spécifique
	function Casino.UI:SetupGameFunctions(gameName)
		local game = Casino.Games[gameName]
		
		if game and game.setupFunctions then
			game.setupFunctions(self.HTML)
		end
	end
	
	-- Sauvegarder un paramètre
	function Casino.UI:SaveSetting(key, value)
		-- TODO: Sauvegarder les paramètres (cookie ou fichier)
		print("[Casino UI] Paramètre sauvegardé: " .. key .. " = " .. tostring(value))
	end
	
	-- Afficher un message dans l'UI
	function Casino.UI:ShowMessage(message, type)
		if not IsValid(self.HTML) or not self.IsOpen then return end
		
		type = type or "success"
		self.HTML:Call(string.format("showToast('%s', '%s')", 
			message:gsub("'", "\\'"), 
			type))
	end
	
	-- Ajouter une entrée à l'historique
	function Casino.UI:AddHistory(game, result, amount)
		if not IsValid(self.HTML) or not self.IsOpen then return end
		
		local timestamp = os.time() * 1000 -- Millisecondes pour JS
		self.HTML:Call(string.format("addHistoryEntry('%s', '%s', %d, %d)", 
			game, 
		result, 
		amount, 
		timestamp))
	end

-- Recevoir les statistiques du serveur
net.Receive("Casino_SendStats", function()
	local stats = net.ReadTable()
	
	if Casino.UI.IsOpen and IsValid(Casino.UI.HTML) then
		-- Mettre à jour les statistiques dans l'interface
		Casino.UI.HTML:Call(string.format("updatePlayerInfo(%d, '%s', %s)", 
			Casino.Currency.GetMoney(LocalPlayer()),
			Casino.Currency.Format(Casino.Currency.GetMoney(LocalPlayer())),
			util.TableToJSON(stats)))
	end
end)

-- Recevoir l'historique du serveur
net.Receive("Casino_SendHistory", function()
	local count = net.ReadUInt(16)
	local history = {}
	
	for i = 1, count do
		table.insert(history, {
			game = net.ReadString(),
			result = net.ReadString(),
			amount = net.ReadUInt(32),
			winAmount = net.ReadUInt(32),
			timestamp = net.ReadUInt(32)
		})
	end
	
	if Casino.UI.IsOpen and IsValid(Casino.UI.HTML) then
		-- Envoyer l'historique complet en JSON pour préserver l'ordre
		Casino.UI.HTML:Call(string.format([[
			if (typeof window.loadHistory === 'function') {
				window.loadHistory(%s);
			}
		]], util.TableToJSON(history)))
	end
end)

-- Recevoir le leaderboard du serveur
net.Receive("Casino_SendLeaderboard", function()
	local count = net.ReadUInt(8)
	local leaderboard = {}
	
	for i = 1, count do
		table.insert(leaderboard, {
			playerName = net.ReadString(),
			game = net.ReadString(),
			winAmount = net.ReadUInt(32),
			timestamp = net.ReadUInt(32)
		})
	end
	
	if Casino.UI.IsOpen and IsValid(Casino.UI.HTML) then
		-- Envoyer le leaderboard en JSON
		Casino.UI.HTML:Call(string.format([[
			if (typeof window.loadLeaderboard === 'function') {
				window.loadLeaderboard(%s);
			}
		]], util.TableToJSON(leaderboard)))
	end
end)

print("[Casino UI] UI Manager chargé avec succès")

