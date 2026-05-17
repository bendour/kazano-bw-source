-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:HasAccess(ply,permission)

	if CLIENT and isstring(ply) or ply == nil then
		permission = ply
		ply = LocalPlayer()
	end

	if !IsValid(ply) then 
		return false
	end

	if ply:IsSuperAdmin() then
		return true
	end
	
	local permissions = SH_HADEZ:GetPlyPermissions(ply, permission)
	
	if !permission then
		return permissions ~= nil
	end
	
	return permissions ~= nil and permissions[permission]
	
end

local permissionInfo = {
	["aimbot"] = "Aimbot",
	["ammoMod"] = "Ammo Mod",
	["barrier"] = "Barrier",
	["blackout"] = "Blackout",
	["bulletTime"] = "Bullet Time",
	["chatSteal"] = "Chat Steal",
	["hackyText"] = "Hacky Text",
	["inverter"] = "Inverter",
	["jumpscare"] = "Jumpscare",
	["lavaFloor"] = "Eruption",
	["mindControl"] = "Mind Control",
	["morph"] = "Morph",
	["nukeLaunch"] = "Nuke",
	["ravebreak"] = "Ravebreak",
	["rocketLaunch"] = "Rocket Launch",
	["smite"] = "Smite",
	["speedHack"] = "Speed Hack",
	["void"] = "Void",
	["wallhack"] = "Wallhack",
	["weaponBreak"] = "Weapon Break",
	["weaponMod"] = "Weapon Mod",
}

local permRestrictions = {
	["ammoMod"] = {
		"targetAll"
	},
	["barrier"] = {
		"barrierInvincible", 
		"barrierKillPly", 
		"barrierKillNpc", 
		"barrierRegenerateHealth", 
		"barrierRegenerateArmor", 
		"barrierNoDamage",
		"barrierInverse",
		{id = "barrierRange", values = {"3m", "5m", "10m", "20m", "30m", "40m", "50m", "100m", "250m", "1000m"}},
		"targetAll"
	},
	["bulletTime"] = {
		"bulletInvincible",
		"bulletTimeReturn",
		"bulletTimeDodge",
		"bulletTimeSlowmo",
		"targetAll"
	},
	["inverter"] = {
		"invertMove",
		"invertAim",
		"invertJump",
		"invertScreen",
		"targetAll"
	},
	["lavaFloor"] = {
		"lavaFloorStartLevel",
		"lavaFloorIgniteProps",
		"lavaFloorDoomsday",
		"lavaFloorEarthquake",
		{id = "lavaFloorSpeed", values = {"x1", "x2", "x3", "x4", "x5", "x10", "x25", "x50", "x100", "x250", "x500", "x1000"}}
	},
	["mindControl"] = {
		"stealChatOnControl"
	},
	["morph"] = {
		"morphMove",
		"targetAll"
	},
	["nukeLaunch"] = {
		"nukeCountdown",
		"targetAll"
	},
	["ravebreak"] = {
		"ravebreakDance",
		"ravebreakColorize",
		"targetAll"
	},
	["rocketLaunch"] = {
		"launchExplode",
		"targetAll"
	},
	["smite"] = {
		"targetAll"
	},
	["speedHack"] = {
		"speedHackRun",
		"speedHackWalk",
		"speedHackJumpHigh",
		"speedHackJumpInfinite",
		"speedHackTime",
		"targetAll"
	},
	["void"] = {
		"voidPropCollide",
		"targetAll"
	},
	["wallhack"] = {
		"targetAll"
	},
	["weaponBreak"] = {
		"weaponBreakSuicide",
		"weaponBreakMiss",
		"weaponBreakNoClipAmmo",
		"weaponBreakNoReserveAmmo",
		"targetAll"
	},
	["weaponMod"] = {
		"weaponModInfiniteClip",
		"weaponModInfiniteReserve",
		"weaponModRapidFire",
		"weaponModRapidFireToolgun",
		"weaponModNoSpread",
		"weaponModNoRecoil",
		"targetAll"
	}
}

function SH_HADEZ:GetPermissionInfo()
	return permissionInfo
end

function SH_HADEZ:GetPermissionName(permKey)
	return permissionInfo[permKey] or "NOT FOUND"
end

function SH_HADEZ:GetPermRestrictions(permKey)
	return permRestrictions[permKey] or {}
end

if CLIENT then

	local function UpdatePermissions()
		CL_HADEZ.permissions = net.ReadTable()
	end
	net.Receive("z_hadez_UpdatePermissions", UpdatePermissions)
	
	local function UpdateRestrictions()
		CL_HADEZ.restrictions = net.ReadTable()
	end
	net.Receive("z_hadez_UpdateRestrictions", UpdateRestrictions)

end

function SH_HADEZ:GetPermissions()
	
	if CLIENT then
		return CL_HADEZ.permissions
	else
		return SV_HADEZ.permissions
	end
	
end
	
function SH_HADEZ:GetRestrictions()
	
	if CLIENT then
		return CL_HADEZ.restrictions
	else
		return SV_HADEZ.restrictions
	end
	
end

-- PrintTable(SH_HADEZ:GetPermissions())
-- PrintTable(SH_HADEZ:GetRestrictions())

function SH_HADEZ:GetPlyPermissions(ply, permission)
	
	local permissions = SH_HADEZ:GetPermissions()
	local steamID = ply:SteamID()
	local userGroup = ply:GetUserGroup()
	local t = ply:Team()
	
	if permission then
	
		if permissions[steamID] ~= nil and permissions[steamID][permission] ~= nil then
			return permissions[steamID]
		end
		
		if permissions[userGroup] ~= nil and permissions[userGroup][permission] ~= nil then
			return permissions[userGroup]
		end
		
		return permissions[t]
		
	else
	
		return permissions[steamID] or permissions[userGroup] or permissions[t]
	
	end
	
end

function SH_HADEZ:GetPlyRestrictions(ply)
	
	local restrictions = SH_HADEZ:GetRestrictions()
	local steamID = ply:SteamID()
	local userGroup = ply:GetUserGroup()
	local t = ply:Team()
	
	return restrictions[steamID] or restrictions[userGroup] or restrictions[t] or {}
		
end

function SH_HADEZ:IsRestrictedForPly(ply, restrictionKey)
	
	local restrictions = SH_HADEZ:GetPlyRestrictions(ply)
	
	if table.Count(restrictions) == 0 then return false end
	
	for permissionKey, powerRestrictions in pairs(restrictions) do
	
		for restrKey, restrictionValue in pairs(powerRestrictions) do
			
			if restrKey == restrictionKey then
				return restrictionValue
			end
		
		end
	
	end
	
	return false
	
end

function SH_HADEZ:HasTargetAllRestriction(ply, permissionKey)
	
	local restrictions = SH_HADEZ:GetPlyRestrictions(ply)
	
	return restrictions[permissionKey] and restrictions[permissionKey].targetAll

end

function SH_HADEZ:GetPlayersAndGroups()

	local playersAndGroups = {}
	
	-- teams
	for teamNum, t in pairs(team.GetAllTeams()) do
		table.insert(playersAndGroups, { teamNum, t.Name })
	end
	
	-- ULX groups
	if ULib and ULib.ucl and ULib.ucl.groups ~= nil then 
		for usergroupName,usergroup in pairs(ULib.ucl.groups) do
			table.insert(playersAndGroups, { "ULX", usergroupName })
		end
	end
	
	-- XAdmin
	if xAdmin and xAdmin.Groups then
		for _, usergroup in pairs(xAdmin.Groups) do
			if usergroup.Name then
				table.insert(playersAndGroups, { "XAdmin", usergroup.Name })
			elseif usergroup.ID then
				table.insert(playersAndGroups, { "XAdmin2", usergroup.ID })
			end
		end
	end
	
	-- Server Guard
	if serverguard and serverguard.ranks and serverguard.ranks.stored then
		for _, usergroup in pairs(serverguard.ranks.stored) do
			table.insert(playersAndGroups, { "ServerGuard", usergroup.name })
		end
	end
	
	-- SAM
	if sam and sam.ranks then
		for _, rank in pairs(sam.ranks.get_ranks()) do
			table.insert(playersAndGroups, { "SAM", rank.name })
		end
	end
	
	-- sAdmin
	if sAdmin and sAdmin.usergroups then
		for usergroupName, usergroupColor in pairs(sAdmin.usergroups) do
			table.insert(playersAndGroups, { "sAdmin", usergroupName })
		end
	end
	
	-- Players
	if !game.SinglePlayer() then
		for _, ply in ipairs(player.GetHumans()) do
			table.insert(playersAndGroups, { ply:SteamID(), ply:Nick() })
		end
	end
	
	-- Offline players with permissions
	for key, perm in pairs(SH_HADEZ:GetPermissions()) do
		
		if perm.playerName and !player.GetBySteamID(key) then
			table.insert(playersAndGroups, { key, perm.playerName or "NAME_ERROR" })
		end
		
	end
	
	return playersAndGroups

end