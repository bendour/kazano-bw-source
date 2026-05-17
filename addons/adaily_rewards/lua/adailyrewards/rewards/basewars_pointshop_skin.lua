local Reward = {}

Reward.Name = "BaseWars Pointshop Skin"

Reward.MaxAmount = 1

Reward.CanTaskReward = false

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Reward.GiveReward = function(ply, amount, key)
	-- key contient l'ID du skin (ex: "1", "2", "3")
	if BaseWars and BaseWars.PS then
		local steamID = ply:SteamID64()
		local skinID = tonumber(key)
		
		if skinID then
			BaseWars.PS:GiveSkinToPlayer(steamID, skinID, "0")
		end
	end
end

-- Envoie les données du skin au client pour afficher le modèle 3D
Reward.NetWrite = function(rewardVal)
	local skinID = tonumber(rewardVal)
	if not skinID then 
		net.WriteBool(false)
		return 
	end
	
	-- Récupérer le modèle depuis la base de données
	MySQLite.query(Format("SELECT model FROM basewars_pointshop WHERE skin_id = %d", skinID), function(result)
		-- Cette requête est asynchrone, donc on doit broadcaster à tous les clients
		if result and result[1] and result[1].model then
			-- Le modèle sera mis en cache côté client via NetRead
		end
	end)
	
	-- Envoyer l'ID pour que le client puisse l'utiliser avec le cache
	net.WriteBool(true)
	net.WriteUInt(skinID, 16)
end

-- Hook pour synchroniser les skins au démarrage
hook.Add("PlayerInitialSpawn", "ADRewards_SyncPointshopSkins", function(ply)
	timer.Simple(5, function()
		if not IsValid(ply) then return end
		if not BaseWars or not BaseWars.PS then return end
		
		BaseWars.PS:GetShopData(function(skins)
			if not skins or table.IsEmpty(skins) then return end
			
			net.Start("adrewards_BWPSSkins")
			net.WriteUInt(table.Count(skins), 16)
			for skinID, data in pairs(skins) do
				net.WriteUInt(skinID, 16)
				net.WriteString(data.model or "")
			end
			net.Send(ply)
		end)
	end)
end)

util.AddNetworkString("adrewards_BWPSSkins")
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
-- Cache des modèles de skins
Reward.SkinModels = Reward.SkinModels or {}

Reward.DrawType = 3 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;

Reward.DrawFunc = function(key)
	local skinID = tonumber(key)
	if not skinID then return nil end
	
	local model = Reward.SkinModels[skinID]
	if not model or model == "" then
		-- Fallback si le modèle n'est pas encore chargé
		return "models/player/kleiner.mdl"
	end
	
	-- Retourne: model, campos, lookang, lookat, fov, skin, color
	return model, Vector(50, 0, 35), Angle(0, 180, 0), nil, 45
end

Reward.DrawKey = "Skin ID"

Reward.GetKey = function(name)
	local key = tonumber(name)
	if key then return tostring(key) end
	return false
end

Reward.NetRead = function(rewardVal)
	local valid = net.ReadBool()
	if not valid then return end
	
	local skinID = net.ReadUInt(16)
	return tostring(skinID)
end

-- Recevoir les données des skins depuis le serveur
net.Receive("adrewards_BWPSSkins", function()
	local count = net.ReadUInt(16)
	for i = 1, count do
		local skinID = net.ReadUInt(16)
		local model = net.ReadString()
		Reward.SkinModels[skinID] = model
	end
end)

Reward.LangPhrase = "BWPointshopSkin_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Enter the Skin ID number from the BaseWars Pointshop."
ADRLang.fr[Reward.LangPhrase] = "Entrez le numéro d'ID du skin du Pointshop BaseWars."
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if BaseWars and BaseWars.PS then return true end
	return false
end

ADRewards.CreateReward(Reward)
