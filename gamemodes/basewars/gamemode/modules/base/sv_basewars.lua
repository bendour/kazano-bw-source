local PLAYER = FindMetaTable("Player")

function BaseWars:Refund(ply)
	local all = 0
	for k, v in pairs(ents.GetAll()) do
		if not IsValid(v) then continue end
		if not v.CPPIGetOwner then continue end
		if v:CPPIGetOwner() != ply then continue end

		all = all + v:GetCurrentValue()

		SafeRemoveEntity(v)
	end

	ply:AddMoney(all)
	BaseWars:Notify(ply, "#command_refund_refundPlayer", NOTIFICATION_WARNING, 10, BaseWars:FormatMoney(all))
	BaseWars:ServerLog("Refunded " .. BaseWars:FormatMoney(all) .. " to " .. ply:Name())
end

function BaseWars:RefundAll()
	for k, ply in player.Iterator() do
		self:Refund(ply)
	end
end

function GM:PreCleanupMap()
	BaseWars:RefundAll()
end

function BaseWars:UnLockAllDoors()
	for _, door in pairs(ents.FindByClass("*door*")) do
		door:Fire("unlock")
	end

	BaseWars:NotifyAll("#unlockalldoor", NOTIFICATION_WARNING, 5)
end

function BaseWars:SaveConfig(ply, config)
	if not BaseWars:IsSuperAdmin(ply) then
		BaseWars:BanPlayer(ply:SteamID64(), 0, "Probably hacking (Gamemode Config)", 0)
		return
	end

	local oldConfig = BaseWars.Config
	hook.Run("BaseWars:PreConfigurationModified", ply, oldConfig, config)

	file.Write("basewars/basewars_config.json", util.TableToJSON(config, true))
	BaseWars.Config = config

	hook.Run("BaseWars:ConfigurationModified", ply, oldConfig, config)

	local compressed = util.Compress(util.TableToJSON(config))
	net.Start("BaseWars:GamemodeConfigModified")
		net.WriteData(compressed, #compressed)
	net.Broadcast()

	if BaseWars.Config.NotifyAllWhenConfigModified then
		BaseWars:NotifyAll("#gamemodeConfig_updated", NOTIFICATION_ADMIN, 5)
	else
		BaseWars:Notify(ply, "#gamemodeConfig_updated", NOTIFICATION_ADMIN, 5)
	end
end

function BaseWars:RemoveAllProps()
	if not BaseWars.Config.RemoveProps then
		return
	end

	for k, v in pairs(ents.GetAll()) do
		if v:IsClass("prop_physics") then
			SafeRemoveEntity(v)
		end
	end
end

function BaseWars:EntityTakeDamage(ent, damageInfo, destroyFunc)
	-- Éviter les doubles appels pour les récompenses
	if ent.BWRewardProcessed then return end
	
	local att = damageInfo:GetAttacker()
	local owner = ent:CPPIGetOwner()

	if owner == att and not owner:GetBaseWarsConfig("damageOwnEntities") then
		return
	end

	if BaseWars:RaidGoingOn() then
		if owner:IsPlayer() and att:IsPlayer() and not owner:Enemy(att) then
			return
		end
	else
		if owner != att then
			return
		end
	end

	ent:SetHealth(ent:Health() - damageInfo:GetDamage())

	if ent:Health() <= 0 then
		-- Marquer comme traité pour éviter les doubles récompenses
		ent.BWRewardProcessed = true
		
		local originalValue = ent:GetCurrentValue()
		local currentValue = math.floor(originalValue * BaseWars.Config.DestroyReturn)
		
		-- Récompense pour le défenseur (70% de la valeur originale)
		local defenderRefund = math.floor(originalValue * 0.7)
		
		if att:IsPlayer() and owner:IsPlayer() and att ~= owner then
			-- Si l'attaquant est en faction, partager les récompenses entre tous les membres
			if att:InFaction() then
				local factionMembers = BaseWars:GetFactionMembers(att:GetFaction(), true) -- Inclut le leader
				local memberCount = #factionMembers
				
				if memberCount > 1 then
					-- Partager équitablement entre tous les membres de la faction
					local sharePerMember = math.floor(currentValue / memberCount)
					
					for k, member in pairs(factionMembers) do
						if IsValid(member) and member:Alive() then
							member:GiveMoney(sharePerMember)
							BaseWars:Notify(member, "#raid_destroyEntity", NOTIFICATION_GENERIC, 5, BaseWars:FormatMoney(sharePerMember), BaseWars:GetValidName(ent))
						end
					end
				else
					-- Seul dans sa faction, il récupère tout
					att:GiveMoney(currentValue)
					BaseWars:Notify(att, "#raid_destroyEntity", NOTIFICATION_GENERIC, 5, BaseWars:FormatMoney(currentValue), BaseWars:GetValidName(ent))
				end
			else
				-- Pas en faction, il récupère tout
				att:GiveMoney(currentValue)
				BaseWars:Notify(att, "#raid_destroyEntity", NOTIFICATION_GENERIC, 5, BaseWars:FormatMoney(currentValue), BaseWars:GetValidName(ent))
			end
			
			-- Le défenseur reçoit 70% de la valeur originale
			owner:GiveMoney(defenderRefund)
			BaseWars:Notify(owner, "#raid_receivedForEntituDestroyed", NOTIFICATION_GENERIC, 5, BaseWars:FormatMoney(defenderRefund), BaseWars:GetValidName(ent))
		elseif att:IsPlayer() and att == owner then
			-- Le joueur détruit sa propre entité, il récupère tout
			att:GiveMoney(currentValue)
			BaseWars:Notify(att, "#raid_destroyEntity", NOTIFICATION_GENERIC, 5, BaseWars:FormatMoney(currentValue), BaseWars:GetValidName(ent))
		end

		hook.Run("BaseWars:PlayerDestroyEntity", ent, owner, att, damageInfo:GetInflictor(), currentValue)

		if isfunction(destroyFunc) then
			destroyFunc()
		end
	end
end

function PLAYER:SetAFKTime(time)
	self:SetNWFloat("BaseWar.AFKTime", time)
end

hook.Add("PlayerButtonDown", "BaseWars:AFK", function(ply, key)
	ply:SetAFKTime(CurTime())
end)

timer.Create("BaseWars.StopFire", 2, 0, function()
	for k, v in ents.Iterator() do
		if not IsValid(v) then continue end
		if not v:IsOnFire() then continue end

		v:Extinguish()
	end
end)