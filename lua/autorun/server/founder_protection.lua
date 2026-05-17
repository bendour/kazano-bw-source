FPConfig = FPConfig or {}

-- Config des SteamID autorisés à avoir les grades FPConfig.Groups et protégés des bannissements
FPConfig.SteamID = {
	["STEAM_0:0:0"] = true, -- Binks
	["STEAM_0:0:0"] = true, -- JL
}

-- Config des grades dont les joueurs doivent être dans FPConfig.SteamID sinon sanction
FPConfig.Groups = {
	["superadmin"] = true
}

--[[
1 = Demote
2 = Ban
]]
FPConfig.Sanction = 2

-- Raison du bannissement
FPConfig.BanReason = "Tentative de Hack"

-- Activer/Désactiver l'arrêt automatique du serveur lorsque qu'un joueur est mis superadmin sans faire parti des SteamID autorisés
-- ou qu'un joueur faisant parti des SteamID protégés se fait bannir
FPConfig.StopServer = false

-- Affichage de l'alerte "X a tenté de bannir un fondateur" (*return true* pour que l'alerte s'affiche pour tout le monde)
FPConfig.Alert = function(ply)
	return FPConfig.Groups[ply:GetUserGroup()]
end

--[[-------------------------------------------------------------------
						FIN DE LA CONFIG 					
---------------------------------------------------------------------]]

local function sanctionBlocked(admin, addon, type)
	if admin and admin:IsValid() and admin:EntIndex() != 0 then
		admin:ChatPrint("Vous ne pouvez pas "..(isfunction(type) and "bannir" or "expulser").." un fondateur !")

		ServerLog("["..addon.."] (Founder Protection) "..admin:GetName().." ("..admin:SteamID()..") tried to "..(isfunction(type) and "ban" or "kick").." a founder\n")
		
		for _, v in ipairs(player.GetHumans()) do
			if IsValid(v) and FPConfig.Alert(v) then
				v:ChatPrint(admin:GetName().." a tenté "..(isfunction(type) and "de bannir" or "d'expulser").." un fondateur !")
			end
		end

		if FPConfig.Sanction == 1 then
			admin:SetUserGroup("user")
		elseif FPConfig.Sanction == 2 and isfunction(type) then
			type()
		end
	end

	if FPConfig.StopServer == true then
		timer.Simple(1, function()
			RunConsoleCommand("quit")
		end)
	end
end

local function FP_Initializing()
	print("Initializing Seefox Founder Protection 1.7")

	if ULib then
		hook.Add("ULibUserGroupChange", "Seefox:RankProtection", function(id, allows, denies, new_group, old_group)
			if FPConfig.Groups[new_group] then
				if FPConfig.SteamID[id] then
					print(id.." set in "..new_group.." (he is a founder)")
				else
					ServerLog("[ULX] (Founder Protection) removed all access rights from "..id.." because he is not a founder\n")
					ULib.ucl.removeUser(id)
					if FPConfig.Ban == true then
						ULib.addBan(id, 0, FPConfig.BanReason)
					end
					if FPConfig.StopServer == true then
						timer.Simple(1, function()
							RunConsoleCommand("quit")
						end)
					end
				end
			end
		end)
	
		local ulx_addban = ULib.addBan
	
		ULib.addBan = function(steamid32, length, reason, nick, admin)
			if FPConfig.SteamID[steamid32] then
				sanctionBlocked(admin, "ULX", ulx_addban(admin:SteamID(), 0, FPConfig.BanReason, admin:GetName()))
			else
				ulx_addban(steamid32, length, reason, nick, admin)
			end
		end
	
		local ulx_kick = ULib.kick
	
		ULib.kick = function(target, reason, admin)
			local steamid32 = target:SteamID()
	
			if FPConfig.SteamID[steamid32] then
				sanctionBlocked(admin, "ULX")
			else
				ulx_kick(target, reason, admin)
			end
		end
	end
	
	if evolve then
		local evolve_ban = evolve.Ban
	
		evolve.Ban = function(target, length, reason, admin)
			local steamid32 = target:SteamID()

			if FPConfig.SteamID[steamid32] then
				sanctionBlocked(admin, "Evolve", evolve_ban(target, 0, FPConfig.Reason))
			else
				evolve_ban(target, length, reason)
			end
		end
	end
	
	if serverguard then
		local serverguard_ban = serverguard["BanPlayer"]
	
		local function getPlayerByNick(nick)
			nick = string.lower(nick)
			
			for _, v in ipairs(player.GetHumans()) do
				if string.find(string.lower(v:Name()), nick, 1, true) != nil then
					return v
				end
			end
		end
	
		serverguard.BanPlayer = function(admin, ply_obj, length, reason)
			if ply_obj then
				local steamid32 = nil;
	
				if type(ply_obj) == "Player" then
					steamid32 = ply_obj:SteamID()
				elseif type(ply_obj) == "string" then
					local target = getPlayerByNick(ply_obj)
	
					if IsValid(target) then
						ply_obj = target
	
						steamid32 = ply_obj:SteamID()
					elseif string.find(ply_obj, "STEAM_(%d+):(%d+):(%d+)") then
						steamid32 = ply_obj
					end
				end
	
				if FPConfig.SteamID[steamid32] then
					sanctionBlocked(admin, "Serverguard", serverguard_ban(self, nil, admin, 0, FPConfig.BanReason))
				else
					serverguard_ban(self, admin, ply_obj, length, reason)
				end
			end
		end
	end
	
	if xAdmin and not xAdmin.Admin.RegisterBan then
		-- xAdmin 1
	
		local xadmin_registernewban = xAdmin.RegisterNewBan
	
		xAdmin.RegisterNewBan = function(target, admin, reason, length)
			local steamid32 = nil
			if isstring(target) then steamid32 = target elseif IsValid(target) then steamid32 = target:SteamID() end
	
			local admin = player.GetBySteamID(admin)
	
			if FPConfig.SteamID[steamid32] then
				sanctionBlocked(admin, "xAdmin", xadmin_registernewban(admin, nil, FPConfig.BanReason, 0))
			else
				xadmin_registernewban(target, admin, reason, length)
			end
		end
	elseif xAdmin and xAdmin.Admin.RegisterBan then	
		-- xAdmin 2
	
		local xadmin_registernewban = xAdmin.Admin.RegisterBan
	
		xAdmin.Admin.RegisterBan = function(target, admin, reason, length)
			local steamid32 = nil
			if isstring(target) then steamid32 = target elseif IsValid(target) then steamid32 = target:SteamID() end
	
			if FPConfig.SteamID[steamid32] then
				sanctionBlocked(admin, "xAdmin", xadmin_registernewban(admin, nil, FPConfig.BanReason, 0))
			else
				xadmin_registernewban(target, admin, reason, length)
			end
		end
	end
	
	if sam then
		local sam_ban = sam.player.ban
	
		sam.player.ban = function(target, length, reason, admin_steamid)
			local steamid32 = target:SteamID()
	
			if not sam.isstring(reason) then
				reason = DEFAULT_REASON
			end
	
			local admin = nil
	
			if sam.is_steamid(admin_steamid) then
				admin = player.GetBySteamID(admin_steamid)
			end
	
			if FPConfig.SteamID[steamid32] then
				sanctionBlocked(admin, "SAM", sam_ban(admin_steamid, 0, FPConfig.BanReason))
			else
				sam_ban(target, length, reason, admin_steamid)
			end
		end
	
		local sam_banid = sam.player.ban_id
	
		sam.player.ban_id = function(steamid32, length, reason, admin_steamid)
			if not sam.isstring(reason) then
				reason = DEFAULT_REASON
			end
	
			local admin = nil
	
			if sam.is_steamid(admin_steamid) then
				admin = player.GetBySteamID(admin_steamid)
			end
	
			if FPConfig.SteamID[steamid32] then
				sanctionBlocked(admin, "SAM", sam_ban(admin_steamid, 0, FPConfig.BanReason))
			else
				sam_banid(steamid32, length, reason, admin_steamid)
			end
		end
	end

    if sAdmin then
        local sadmin_banply = sAdmin.banPly

        sAdmin.banPly = function(ply, time, reason, admin)
            if FPConfig.SteamID[ply:SteamID()] then
				sanctionBlocked(admin, "sAdmin", sadmin_banply(admin, 0, FPConfig.BanReason))
			else
				sadmin_banply(ply, time, reason, admin)
			end
        end

        local sadmin_addban = sAdmin.addBan

        sAdmin.addBan = function(sid64, expire, reason, admin)
            if FPConfig.SteamID[util.SteamIDFrom64(sid64)] then
				sanctionBlocked(admin, "sAdmin", sadmin_banply(admin, 0, FPConfig.BanReason))
			else
				sadmin_addban(sid64, expire, reason, admin)
			end
        end
    end
end

hook.Add("InitPostEntity", "Seefox:FounderProtection", FP_Initializing)