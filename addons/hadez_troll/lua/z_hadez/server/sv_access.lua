-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local permSaveDataPath = "z_hadez/permissions.txt"
local restrSaveDataPath = "z_hadez/restrictions.txt"

function SV_HADEZ:LoadAccessData()

	if file.Exists( permSaveDataPath, "DATA" ) then
	
		local saveData = file.Read( permSaveDataPath, "DATA" )
	
		self.permissions = util.JSONToTable(saveData) or {}
	
	else
		self.permissions = {}
	end
	
	if file.Exists( restrSaveDataPath, "DATA" ) then
	
		local saveData = file.Read( restrSaveDataPath, "DATA" )
	
		self.restrictions = util.JSONToTable(saveData) or {}
	
	else
		self.restrictions = {}
	end

end
hook.Add("Initialize", "z_hadez_LoadPermissions", function() SV_HADEZ:LoadAccessData() end)

function SV_HADEZ:SavePermissions()

	local saveData = util.TableToJSON( self.permissions )
	
	if !file.Exists( "z_hadez", "DATA" ) then
		file.CreateDir("z_hadez")
	end
	
	file.Write( permSaveDataPath, saveData )

end

function SV_HADEZ:SaveRestrictions()

	local saveData = util.TableToJSON( self.restrictions )
	
	if !file.Exists( "z_hadez", "DATA" ) then
		file.CreateDir("z_hadez")
	end
	
	file.Write( restrSaveDataPath, saveData )

end

util.AddNetworkString("z_hadez_UpdatePermissions")
function SV_HADEZ:UpdateClientPermissions(ply)
	
	-- Prevent broadcast spam
	timer.Create("z_hadez_UpdatePermissionsOnClientDelay"..(ply and ply:UniqueID() or ""), 1, 1, function()
	
		net.Start("z_hadez_UpdatePermissions")
			net.WriteTable(self.permissions)
			
		if ply then
			net.Send(ply)
		else
			net.Broadcast()
		end
	
	end)
	
end

util.AddNetworkString("z_hadez_UpdateRestrictions")
function SV_HADEZ:UpdateClientRestrictions(ply)
	
	-- Prevent broadcast spam
	timer.Create("z_hadez_UpdateRestrictionsOnClientDelay"..(ply and ply:UniqueID() or ""), 1, 1, function()
	
		net.Start("z_hadez_UpdateRestrictions")
			net.WriteTable(self.restrictions)
			
		if ply then
			net.Send(ply)
		else
			net.Broadcast()
		end
	
	end)
	
end

util.AddNetworkString("z_hadez_AddPermission")
local function AddPermission(len, ply)

	if !ply:IsSuperAdmin() then return end

	local id = net.ReadString()
	local permKey = net.ReadString()
	local playerName = net.ReadString()
	local permissions = SH_HADEZ:GetPermissions()
	
	permissions[id] = permissions[id] or {}
	
	-- Always update playerName
	if SH_HADEZ:IsSteamID(id) then
		permissions[id].playerName = playerName
	end
	
	permissions[id][permKey] = true
	
	SV_HADEZ:SavePermissions()
	SV_HADEZ:UpdateClientPermissions()
	
end
net.Receive("z_hadez_AddPermission", AddPermission)

util.AddNetworkString("z_hadez_RemovePermission")
local function RemovePermission(len, ply)

	if !ply:IsSuperAdmin() then return end
	
	local id = net.ReadString()
	local permKey = net.ReadString()
	
	local permissions = SH_HADEZ:GetPermissions()
	
	permissions[id] = permissions[id] or {}
	permissions[id][permKey] = nil
	
	SV_HADEZ:SavePermissions()
	SV_HADEZ:UpdateClientPermissions()

end
net.Receive("z_hadez_RemovePermission", RemovePermission)

util.AddNetworkString("z_hadez_ToggledPermissions")
local function ToggledPermissions(len, ply)

	if !ply:IsSuperAdmin() then return end
	
	local id = net.ReadString()
	local playerName = net.ReadString()
	local permsCount = table.Count(SH_HADEZ:GetPermissionInfo())
	local permissions = SH_HADEZ:GetPermissions()
	
	permissions[id] = permissions[id] or {}
	
	-- Always update playerName
	if SH_HADEZ:IsSteamID(id) then
		permissions[id].playerName = playerName
	end
	
	for i=1, permsCount do
		
		local permKey = net.ReadString()
		local permValue = net.ReadBool()
		
		if permValue then
			permissions[id][permKey] = true
		else
			permissions[id][permKey] = nil
		end
	
	end
	
	SV_HADEZ:SavePermissions()
	SV_HADEZ:UpdateClientPermissions()

end

util.AddNetworkString("z_hadez_UpdateRestrictions")
local function UpdateRestrictions()

	local id = net.ReadString()
	local permKey = net.ReadString()
	local restrKey = net.ReadString()
	local restrictedValue = net.ReadString()
	
	if tonumber(restrictedValue) then
		restrictedValue = tobool(restrictedValue)
	end

	local restrictions = SH_HADEZ:GetRestrictions()
	restrictions[id] = restrictions[id] or {}
	restrictions[id][permKey] = restrictions[id][permKey] or {}
	
	if isbool(restrictedValue) then
		restrictions[id][permKey][restrKey] = restrictedValue and true or nil
	else
		restrictions[id][permKey][restrKey] = restrictedValue
	end
	
	SV_HADEZ:SaveRestrictions()
	SV_HADEZ:UpdateClientRestrictions()
	
end
net.Receive("z_hadez_UpdateRestrictions", UpdateRestrictions)

local function PlayerInitialSpawn(ply)
	SV_HADEZ:UpdateClientPermissions(ply)
	SV_HADEZ:UpdateClientRestrictions(ply)
end
hook.Add( "PlayerInitialSpawn", "z_hadez_SendAccessData", PlayerInitialSpawn)