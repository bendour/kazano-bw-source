-- Client Wheelspin pour Vote Rewards
VoteRewards = VoteRewards or {}
VoteRewards.CurrentRewards = VoteRewards.CurrentRewards or "[]"

local wheelPanel = nil
local wheelspinsAvailable = 0

-- Recevoir le HTML compilé
net.Receive("VoteRewards_LoadHTML", function()
	local html = net.ReadString()
	
	if IsValid(wheelPanel) then
		wheelPanel:Remove()
	end
	
	-- Créer le panel
	wheelPanel = vgui.Create("DFrame")
	wheelPanel:SetSize(ScrW(), ScrH())
	wheelPanel:SetTitle("")
	wheelPanel:SetDraggable(false)
	wheelPanel:ShowCloseButton(false)
	wheelPanel:MakePopup()
	wheelPanel:Center()
	
	wheelPanel.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
	end
	
	wheelPanel.OnClose = function()
	end
	
	-- Créer le DHTML
	local dhtml = vgui.Create("DHTML", wheelPanel)
	wheelPanel.DHTML = dhtml -- Sauvegarder la référence
	dhtml:Dock(FILL)
	dhtml:SetAllowLua(true)
	
	-- Exposer les fonctions Lua au JavaScript AVANT de charger le HTML
	dhtml:AddFunction("voterewards", "close", function()
		if IsValid(wheelPanel) then
			wheelPanel:Close()
		end
	end)
	
	dhtml:AddFunction("voterewards", "spin", function()
		net.Start("VoteRewards_SpinWheel")
		net.SendToServer()
	end)
	
	dhtml:AddFunction("voterewards", "getWheelspins", function()
		return wheelspinsAvailable
	end)
	
	dhtml:AddFunction("voterewards", "getRewards", function()
		local rewardsJSON = VoteRewards.CurrentRewards or "[]"
		return rewardsJSON
	end)
	
	-- Charger le HTML APRÈS avoir exposé les fonctions
	dhtml:SetHTML(html)
	
	-- Injecter les données directement après le chargement du HTML
	timer.Simple(0.5, function()
		if IsValid(dhtml) and IsValid(wheelPanel) then
			local rewardsJSON = VoteRewards.CurrentRewards or "[]"
			-- Échapper les guillemets pour éviter les erreurs JavaScript
			rewardsJSON = string.gsub(rewardsJSON, "'", "\\'")
			
			dhtml:Call(string.format([[
				try {
					console.log('Injecting rewards...');
					rewards = %s;
					wheelspins = %d;
					console.log('Rewards injected:', rewards);
					console.log('Wheelspins injected:', wheelspins);
					updateWheelspins(wheelspins);
					drawWheel();
				} catch(e) {
					console.error('Error injecting data:', e);
				}
			]], rewardsJSON, wheelspinsAvailable))
		end
	end)
end)

-- Ouvrir le wheelspin
net.Receive("VoteRewards_OpenWheel", function()
	wheelspinsAvailable = net.ReadInt(16)
	local rewardsJSON = net.ReadString()
	
	-- Stocker les récompenses pour le DHTML
	VoteRewards.CurrentRewards = rewardsJSON
	
	-- Demander le HTML au serveur
	net.Start("VoteRewards_LoadHTML")
	net.SendToServer()
end)

-- Recevoir le résultat du spin (index de la récompense)
net.Receive("VoteRewards_SpinResult", function()
	local rewardIndex = net.ReadInt(8)
	local rewardJSON = net.ReadString()
	
	-- Envoyer l'index au JavaScript pour faire tourner la roue vers la bonne case
	if IsValid(wheelPanel) and IsValid(wheelPanel.DHTML) then
		wheelPanel.DHTML:Call("spinToReward(" .. rewardIndex .. ")")
	end
end)

-- Recevoir une récompense
net.Receive("VoteRewards_GiveReward", function()
	local rewardJSON = net.ReadString()
	local reward = util.JSONToTable(rewardJSON)
	
	if IsValid(wheelPanel) and IsValid(wheelPanel.DHTML) then
		wheelPanel.DHTML:Call("showReward(" .. rewardJSON .. ")")
	end
	
	-- Notification différente selon le type de récompense
	if reward.type == "coupon" then
		chat.AddText(Color(255, 215, 0), "[Vote Rewards] ", Color(255, 255, 255), "🎉 FÉLICITATIONS ! Vous avez gagné un ", Color(255, 215, 0), "COUPON DE 5€", Color(255, 255, 255), " !")
		chat.AddText(Color(255, 215, 0), "[Vote Rewards] ", Color(255, 255, 255), "📋 Créez un ticket Discord pour recevoir votre code promo !")
	else
		chat.AddText(Color(255, 215, 0), "[Vote Rewards] ", Color(255, 255, 255), "Vous avez gagné: ", Color(reward.color.r, reward.color.g, reward.color.b), reward.name)
	end
	
	-- Effet sonore
	surface.PlaySound("buttons/button14.wav")
end)

-- Recevoir les récompenses du serveur
net.Receive("VoteRewards_SendRewards", function()
	local rewardsJSON = net.ReadString()
	
	-- Mettre à jour le DHTML si ouvert
	if IsValid(wheelPanel) and IsValid(wheelPanel.DHTML) then
		wheelPanel.DHTML:Call("rewards = " .. rewardsJSON .. "; drawWheel();")
	end
end)

-- Recevoir un vote
net.Receive("VoteRewards_VoteReceived", function()
	-- Un seul message combiné
	chat.AddText(Color(255, 215, 0), "[Vote Rewards] ", Color(0, 255, 100), "✓ ", Color(255, 255, 255), "Merci d'avoir voté ! Vous avez reçu ", Color(255, 215, 0), "1 Wheelspin", Color(255, 255, 255), " ! Tapez ", Color(100, 200, 255), "/wheelspin", Color(255, 255, 255), " pour tourner la roue.")
	surface.PlaySound("buttons/button15.wav")
end)

-- Recevoir le classement
net.Receive("VoteRewards_SendLeaderboard", function()
	local leaderboardJSON = net.ReadString()
	local leaderboard = util.JSONToTable(leaderboardJSON)
	
	-- Créer un panel pour afficher le classement
	local frame = vgui.Create("DFrame")
	frame:SetSize(500, 400)
	frame:SetTitle("🏆 Top Voteurs du Mois")
	frame:Center()
	frame:MakePopup()
	
	local scroll = vgui.Create("DScrollPanel", frame)
	scroll:Dock(FILL)
	
	local list = vgui.Create("DListView", scroll)
	list:Dock(FILL)
	list:AddColumn("Rang")
	list:AddColumn("Joueur")
	list:AddColumn("Votes")
	
	local medals = {"🥇", "🥈", "🥉"}
	for i, player in ipairs(leaderboard) do
		list:AddLine(medals[i] or "#" .. i, player.player_name, player.monthly_votes)
	end
end)

-- Fonction pour charger le HTML (appelée par le serveur)
function VoteRewards.LoadHTML()
	-- Le serveur envoie le HTML compilé via le net message
end
