gProtect = gProtect or {}
gProtect.language = gProtect.language or {}

gProtect.PropClasses = {
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true,
	["prop_static"] = true
}

local cachedSID = {}

local function getBySteamID(sid)
	if cachedSID[sid] and IsValid(cachedSID[sid]) then return cachedSID[sid] end
	for k,v in ipairs(player.GetAll()) do
		if !IsValid(v) then continue end
		if v:SteamID() == sid then
			cachedSID[sid] = v
			return v
		end
	end
end

gProtect.GetOwner = function(ent)
	if !IsValid(ent) then return end
	local result = ent:GetNWString("gPOwner", "")
	local foundply = getBySteamID(result)
	
	foundply = !isstring(foundply) and (IsValid(foundply) and foundply:IsPlayer() and foundply) or foundply

	return (foundply and foundply) or nil
end

gProtect.HasPermission = function(ply, perm)
	local usergroup, result = ply:GetUserGroup(), false

	if gProtect.config.Permissions[perm][usergroup] then return true end

	if CAMI and isfunction(CAMI.PlayerHasAccess) then
		if CAMI.PlayerHasAccess(ply, perm, function(cbResult)
			result = cbResult
		end) then
			return true
		end
	end

	return result
end

gProtect.HandlePermissions = function(ply, ent, permission)
	if (!IsValid(ent) and !ent:IsWorld()) or !IsValid(ply) or !ply:IsPlayer() then return false end

	local owner = gProtect.GetOwner(ent)
	local weapon = permission and permission or IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() or "weapon_physgun"
	local ownsid = isstring(owner) and owner or IsValid(owner) and owner:SteamID() or ""

	if gProtect.IsBuddyWithOwner(ent, ply, weapon) then
		return true
	end
	
	if ent:IsWorld() then return nil end

	if gProtect.TouchPermission then
		local touchtbl = (owner and IsValid(owner) and owner:IsPlayer()) and (gProtect.PropClasses[ent:GetClass()] and gProtect.TouchPermission["targetPlayerOwnedProps"] or gProtect.TouchPermission["targetPlayerOwned"]) or gProtect.TouchPermission["targetWorld"]

		if touchtbl and touchtbl[weapon] then
			touchtbl = touchtbl[weapon]
		end

		if !touchtbl then return false end

		if touchtbl and touchtbl["*"] or touchtbl[ply:GetUserGroup()] then return true end
	end
	
	return false, true
end

gProtect.IsBuddyWithOwner = function(ent, ply, permission)
    local owner = gProtect.GetOwner(ent)

    if !owner then return false end

    if ply == owner then return true end

    local ownsid = isstring(owner) and owner or IsValid(owner) and owner:SteamID()

    if !ownsid then return false end
    
    if gProtect.TouchPermission[ownsid] and gProtect.TouchPermission[ownsid][permission] and istable(gProtect.TouchPermission[ownsid][permission]) and gProtect.TouchPermission[ownsid][permission][ply:SteamID()] then
        return true
    end
end

local cfg = SERVER and gProtect.getConfig(nil, "physgunsettings") or {}

hook.Add("PhysgunPickup", "gP:PhysgunPickupLogic", function(ply, ent, norun)
	if SERVER and !cfg.enabled then return nil end
	if TCF and TCF.Config and ent:GetClass() == "cocaine_cooking_pot" and IsValid( ent:GetParent() ) then return nil end --- Compatibilty with the cocaine factory.

	if ent:IsPlayer() then return nil end

	if SERVER then
		local servercheck = gProtect.HandlePhysgunPermission(ply, ent)
		if isbool(servercheck) then
			local result = false
		
			if servercheck then result = nil end

			return result
		end
	end
	
	return gProtect.HandlePermissions(ply, ent, "weapon_physgun")
end )

hook.Add("gP:ConfigUpdated", "gP:UpdatePhysgunSH", function(updated)
	if updated ~= "physgunsettings" or CLIENT then return end
	cfg = gProtect.getConfig(nil, "physgunsettings")
end)

local function registerPerm(name)
	if CAMI and isfunction(CAMI.RegisterPrivilege) then CAMI.RegisterPrivilege({Name = name, hasAccess = false, callback = function() end}) end
end

registerPerm("gProtect_Settings")
registerPerm("gProtect_StaffNotifications")
registerPerm("gProtect_DashboardAccess")