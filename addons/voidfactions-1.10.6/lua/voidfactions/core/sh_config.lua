//////////////////////
///    WARNING    ////
//////////////////////

-- This file is not supposed to be edited.
-- Use the in-game configuration instead.
-- Only tweak something here if you are told to do so, or we will not provide you support if something breaks!

local L = VoidFactions.Lang.GetPhrase

-- Tables

VoidFactions.Settings = VoidFactions.Settings or {}
VoidFactions.Settings.IGConfig = {}
VoidFactions.Settings.IGConfigCategories = {}
VoidFactions.Settings.IGConfigPanels = {}
VoidFactions.Settings.IGConfigTypes = {}

VoidFactions.Settings.Hardcoded = {}

VoidFactions.UI = VoidFactions.UI or {}

-- Hardcoded values (you SHOULDNT TOUCH these unless absolutely sure)

VoidFactions.Settings.Hardcoded.MaxDynamicMembers = 150
VoidFactions.Settings.Hardcoded.MaxRanksInFaction = 25
VoidFactions.Settings.Hardcoded.MaxStaticFactions = 75
VoidFactions.Settings.Hardcoded.FactionNamePattern = "[^%w%$%%%[%] ]"
VoidFactions.Settings.Hardcoded.FactionTagPattern = "[^%w%$%%%[%] ]"

-- This only applies to static factions.
-- Max members for preloading the offline members of the faction into memory
-- Small factions will benefit from this, it will be pretty fast to update offline members
VoidFactions.Settings.Hardcoded.MembersMaxPreload = 100

-- Debug (this will log useful messages into your console)

VoidFactions.Debug = false

-- Enums

VOIDFACTIONS_STATICFACTIONS = 1
VOIDFACTIONS_DYNAMICFACTIONS = 2

-- Helper functions

function VoidFactions.Settings:IsStaticFactions()
	return VoidFactions.Config.FactionType == VOIDFACTIONS_STATICFACTIONS
end

function VoidFactions.Settings:IsDynamicFactions()
	return VoidFactions.Config.FactionType == VOIDFACTIONS_DYNAMICFACTIONS
end


-- Config codes


local sortOrder = 0
function VoidFactions.Settings:CreateConfigEntry(id, tbl)
	if (!tbl.category) then
		tbl.category = "Other"
	end
	VoidFactions.Settings.IGConfig[id] = {name = tbl.name, description = tbl.description, type = tbl.type, default = tbl.default, category = tbl.category, inputWidth = tbl.inputWidth, ddOptions = tbl.ddOptions, percentage = tbl.percentage, sortOrder = sortOrder, factionType = tbl.factionType}
	sortOrder = sortOrder + 1
end

function VoidFactions.Settings:CreateConfigCategory(id, sortOrder, panel, type)
	VoidFactions.Settings.IGConfigCategories[id] = sortOrder
	if (panel) then
		VoidFactions.Settings.IGConfigPanels[id] = panel
	end
	if (type) then
		VoidFactions.Settings.IGConfigTypes[id] = type
	end
end


////////////
//  CAMI  //
////////////

CAMI.RegisterPrivilege({
	Name = "VoidFactions_SaveNPCs",
	MinAccess = "admin",
	Description = "Can save VoidFactions NPCs?",
})


CAMI.RegisterPrivilege({
	Name = "VoidFactions_ManageFactions",
	MinAccess = "admin",
	Description = "Can manage VoidFactions factions (admin add/kick members)?",
})

CAMI.RegisterPrivilege({
	Name = "VoidFactions_EditFactions",
	MinAccess = "admin",
	Description = "Can create/edit VoidFactions factions?",
})

CAMI.RegisterPrivilege({
	Name = "VoidFactions_ManageCapturePoints",
	MinAccess = "admin",
	Description = "Can manage VoidFactions capture points?",
})

CAMI.RegisterPrivilege({
	Name = "VoidFactions_EditSettings",
	MinAccess = "superadmin",
	Description = "Can modify VoidFactions settings?",
})

CAMI.RegisterPrivilege({
	Name = "VoidFactions_AccessAllJobs",
	MinAccess = "admin",
	Description = "Can switch to any job, even without rank access?",
})

////////////////////////
// VoidChar 1 support //
////////////////////////

function VoidFactions.Settings:RefreshVoidCharFactions()
	if (!VoidChar) then return end
	if (!SERVER) then return end

	local factionJobs = {}
	local factionIcons = {}
	local factionDescs = {}
	local factionReqGroups = {}
	local totalDefaultFactions = 0

	for k, v in pairs(VoidFactions.Factions) do
		if (v.isDefaultFaction) then
			-- Get default rank jobs
			local rank = v:GetLowestRank()
			if (!rank) then continue end

			factionJobs[v.name] = {}
			factionIcons[v.name] = "https://" .. VoidLib.ImageProvider .. (v.logo or "") .. ".png"
			factionDescs[v.name] = v.description or "No description available!"
			factionReqGroups[v.name] = v.requiredUsergroups or {}

			local jobs = rank.jobs
			for _, job in ipairs(jobs) do
				factionJobs[v.name][job] = true
			end

			totalDefaultFactions = totalDefaultFactions + 1
		end
	end

	if (totalDefaultFactions < 2) then return end
	
	VoidChar.Config.DefaultJobs = {}
	for k, v in pairs(factionJobs) do
		for job, _ in pairs(v) do
			VoidChar.Config.DefaultJobs[job] = true
		end
	end

	VoidChar.Config.EnableUsingNonWhitelistedJobs = true
	VoidChar.Config.FactionSystem = true
	VoidChar.Config.UseBWhitelistFactions = false
	VoidChar.Config.RestrictF4Changing = false

	VoidChar.Config.DifferentFactionJobSwitch = false

	VoidChar.Config.Factions = factionJobs
	VoidChar.Config.FactionDescription = factionDescs
	VoidChar.Config.FactionIcons = factionIcons
	VoidChar.Config.FactionRequiredUsergroups = factionReqGroups

	-- Network later, and then on join
	VoidFactions.Settings:NetworkVoidCharFactions()
end

function VoidFactions.Settings:NetworkVoidCharFactions(ply)
	if (!VoidChar) then return end
	if (!SERVER) then return end

	local totalDefaultFactions = 0
	for k, v in pairs(VoidFactions.Factions) do
		if (v.isDefaultFaction) then
			local rank = v:GetLowestRank()
			if (!rank) then continue end
			
			totalDefaultFactions = totalDefaultFactions + 1
		end
	end

	if (totalDefaultFactions < 2) then return end

	net.Start("VoidFactions.Settings.NetworkVoidCharFactions")
		net.WriteTable(VoidChar.Config.Factions)
		net.WriteTable(VoidChar.Config.FactionDescription)
		net.WriteTable(VoidChar.Config.FactionIcons)
		net.WriteTable(VoidChar.Config.DefaultJobs)
		net.WriteTable(VoidChar.Config.FactionRequiredUsergroups or {})
	if (ply) then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

hook.Add("VoidFactions.SQL.StaticFactionsPreloaded", "VoidFactions.Settings.VoidCharSupport", function ()
	VoidFactions.Settings:RefreshVoidCharFactions()
end)

///////////////////////
// Server networking //
///////////////////////


if (SERVER) then
	util.AddNetworkString("VoidFactions.Settings.SendConfigData")
	util.AddNetworkString("VoidFactions.Settings.RequestConfigData")
	util.AddNetworkString("VoidFactions.Settings.ModifyConfig")
	util.AddNetworkString("VoidFactions.Settings.NetworkVoidCharFactions")


	function VoidFactions.Settings:UpdateConfig(len, ply)
		-- Has access to modify config?
		if (!CAMI.PlayerHasAccess(ply, "VoidFactions_EditSettings")) then return end

		local len = net.ReadUInt(32)
		local data = net.ReadData(len)

		data = util.Decompress(data)
		data = util.JSONToTable(data)

		local igConfig = VoidFactions.Settings.IGConfig[data.key]
		if (igConfig) then
			if (data.key == "FactionType" and VoidFactions.Config[data.key] != 0) then
				-- Delete all factions
				VoidFactions.SQL:DropDatabases(false, true)

				local restartTime = 5
				VoidLib.Notify(ply, "VoidFactions", L("restartingIn", restartTime), VoidUI.Colors.Red, 5)
				timer.Simple(restartTime, function ()
					RunConsoleCommand("_RESTART")

					timer.Simple(5, function ()
						VoidLib.Notify(ply, "VoidFactions", "RESTART FAILED, PLEASE RESTART MANUALLY", VoidUI.Colors.Red, 5)
					end)
				end)
			end

			VoidFactions.Config[data.key] = data.value

			-- XP Modules
			if (igConfig.category == "xpmodules") then
				local moduleId = string.Replace(data.key, "XP_", "")
				local xpModule = VoidFactions.XP.Modules[moduleId]
				if (!xpModule) then
					VoidFactions.PrintError("Tried to modify XP module config, but xp module doesn't exist! (" .. moduleId .. ")")
					return
				end


				-- If the type is timevalue, then the value is a table with two elements: {time, xpValue}, default unit is minutes
				if (igConfig.type == "timevalue") then
					xpModule:SetXPAmount(tonumber(data.value[2]))
				else
					xpModule:SetXPAmount(tonumber(data.value) or 0)
				end
				
			end
		end


		VoidFactions.Settings:BroadcastConfigData(VoidFactions.Config)
		VoidFactions.SQL:SetSetting(data.key, data.value)
		
	end
	net.Receive("VoidFactions.Settings.ModifyConfig", function (len, ply)
		VoidFactions.Settings:UpdateConfig(len, ply)
	end)

	function VoidFactions.Settings:SendConfigData(ply)

		local config = VoidFactions.Config

		config = util.TableToJSON(config)
		config = util.Compress(config)

		net.Start("VoidFactions.Settings.SendConfigData")
			net.WriteUInt(#config, 32)
			net.WriteData(config, #config)
		net.Send(ply)

	end 

	hook.Add("VoidLib.PlayerFullLoad", "VoidFactions.Settings.SendConfigData", function (ply)
		VoidFactions.Settings:SendConfigData(ply)
	end)

	function VoidFactions.Settings:BroadcastConfigData(config)
		
		config = util.TableToJSON(config)
		config = util.Compress(config)

		net.Start("VoidFactions.Settings.SendConfigData")
			net.WriteUInt(#config, 32)
			net.WriteData(config, #config)
		net.Broadcast()
	end
	
	function VoidFactions.Settings:LoadConfig()
		VoidFactions.SQL:GetSettings(function (config, configExists)
			if (table.Count(config) < 1) then
				VoidFactions.Print("Initializing in-game config..")
				VoidFactions.Settings:InitConfig()
				return
			end

			for key, v in pairs(VoidFactions.Settings.IGConfig) do
				if (configExists[key] == nil) then
					config[key] = v.default
					VoidFactions.SQL:AddSetting(key, v.default)
				end
			end

			VoidFactions.Config = config
			VoidFactions.LoadedConfigs = configExists

			VoidFactions.Settings.ConfigLoaded = true

			VoidFactions.PrintDebug("Loaded config!")
			hook.Run("VoidFactions.Settings.Loaded")

			for key, v in pairs(VoidFactions.Settings.IGConfig) do
				if (v.category == "xpmodules") then
					local moduleId = string.Replace(key, "XP_", "")
					local xpModule = VoidFactions.XP.Modules[moduleId]
					if (!xpModule) then return end
					if (v.type == "timevalue") then
						xpModule:SetXPAmount(tonumber(config[key][2]))
					else
						VoidFactions.PrintDebug("Setting XP amount of " .. moduleId .. " to " .. config[key] .. "!")
						xpModule:SetXPAmount(tonumber(config[key]))
					end
				end
			end

		end)
	end

	function VoidFactions.Settings:InitConfig()
		local config = {}
		for k, v in pairs(VoidFactions.Settings.IGConfig) do
			config[k] = v.default
			VoidFactions.SQL:AddSetting(k, v.default)
		end

		VoidFactions.Config = config
		VoidFactions.LoadedConfigs = config

		VoidFactions.Settings:BroadcastConfigData(config)
		hook.Run("VoidFactions.Settings.Loaded")
	end

end

if (CLIENT) then

	net.Receive("VoidFactions.Settings.NetworkVoidCharFactions", function ()
		local factionJobs = net.ReadTable()
		local factionDescs = net.ReadTable()
		local factionIcons = net.ReadTable()
		local defaultJobs = net.ReadTable()
		local requiredGroups = net.ReadTable()

		VoidChar.Config.EnableUsingNonWhitelistedJobs = true
		VoidChar.Config.FactionSystem = true
		VoidChar.Config.UseBWhitelistFactions = false

		VoidChar.Config.DifferentFactionJobSwitch = false

		for k, v in pairs(factionJobs) do
			if (requiredGroups[k] and #requiredGroups[k] > 0) then
				local strUg = LocalPlayer():GetUserGroup()
				local bMatches = false
				for k, v in pairs(requiredGroups[k]) do
					if (v == strUg) then
						bMatches = true
					end
				end
		
				if (!bMatches) then
					factionJobs[k] = nil
					factionIcons[k] = nil
					factionDescs[k] = nil
				end
			end
		end

		VoidChar.Config.Factions = factionJobs
		VoidChar.Config.FactionDescription = factionDescs
		VoidChar.Config.FactionIcons = factionIcons
		VoidChar.Config.DefaultJobs = defaultJobs
	end)

	function VoidFactions.Settings:UpdateConfig(key, value)
		local data = {key = key, value = value}

		data = util.TableToJSON(data)
		data = util.Compress(data)

		net.Start("VoidFactions.Settings.ModifyConfig")
			net.WriteUInt(#data, 32)
			net.WriteData(data, #data)
		net.SendToServer()
	end

	function VoidFactions.Settings:ReceiveConfigData()
		local len = net.ReadUInt(32)
		local config = net.ReadData(len)

		config = util.Decompress(config)
		config = util.JSONToTable(config)

		VoidFactions.Config = config

		VoidFactions.Settings.ConfigLoaded = true
		
		VoidFactions.PrintDebug("Received config data")

		if (VoidFactions.Menu.ReopenRequested) then
			VoidFactions.Menu:Open()
			VoidFactions.Menu.ReopenRequested = false
		end

		hook.Run("VoidFactions.Settings.DataReceived")
		hook.Run("VoidFactions.Settings.Loaded")
	end

	net.Receive("VoidFactions.Settings.SendConfigData", VoidFactions.Settings.ReceiveConfigData)

end

//////////////////////
//  In-game config  //
//////////////////////

-- Categories

VoidFactions.Settings:CreateConfigCategory("globals", 1) -- Special category (for static and dynamic factions)

VoidFactions.Settings:CreateConfigCategory("general", 5)
VoidFactions.Settings:CreateConfigCategory("commands", 10)
VoidFactions.Settings:CreateConfigCategory("factions", 12)
VoidFactions.Settings:CreateConfigCategory("deposit", 13, nil, VOIDFACTIONS_DYNAMICFACTIONS)
VoidFactions.Settings:CreateConfigCategory("capturepoints", 14)
VoidFactions.Settings:CreateConfigCategory("invites", 15)
VoidFactions.Settings:CreateConfigCategory("experience", 20)
VoidFactions.Settings:CreateConfigCategory("upgrades", 30, "VoidFactions.UI.UpgradesManage", VOIDFACTIONS_DYNAMICFACTIONS)
VoidFactions.Settings:CreateConfigCategory("upgradetree", 40, "VoidFactions.UI.UpgradeTreeManage", VOIDFACTIONS_DYNAMICFACTIONS)
VoidFactions.Settings:CreateConfigCategory("rewards", 45, "VoidFactions.UI.RewardsManage", VOIDFACTIONS_DYNAMICFACTIONS)
VoidFactions.Settings:CreateConfigCategory("xpmodules", 50)

-- Config entries

-- Globals

VoidFactions.Settings:CreateConfigEntry("FactionType", {
    type = "number",
    category = "globals",
	default = 0
})

-- Commands

VoidFactions.Settings:CreateConfigEntry("MenuCommand", {
	name = "settings_menucommand",
	description = "settings_menucommand_desc",
	type = "string",
	category = "commands",
	default = "!factions",
})

VoidFactions.Settings:CreateConfigEntry("MenuBind", {
	name = "settings_menubind",
	description = "settings_menubind_desc",
	type = "keybind",
	category = "commands",
	default = false,
})

-- Factions

VoidFactions.Settings:CreateConfigEntry("DefaultMaxMembers", {
	name = "settings_defaultmaxmembers",
	description = "settings_defaultmaxmembers_desc",
	type = "number",
	category = "factions",
	default = 5,
	factionType = VOIDFACTIONS_DYNAMICFACTIONS
})

VoidFactions.Settings:CreateConfigEntry("SkipFirstRank", {
	name = "settings_skipfirstrank",
	description = "settings_skipfirstrank_desc",
	type = "bool",
	category = "factions",
	default = false,
	factionType = VOIDFACTIONS_STATICFACTIONS,
})

VoidFactions.Settings:CreateConfigEntry("DefaultMaxItems", {
	name = "settings_defaultmaxitems",
	description = "settings_defaultmaxitems_desc",
	type = "number",
	category = "factions",
	default = 5,
	factionType = VOIDFACTIONS_DYNAMICFACTIONS
})

VoidFactions.Settings:CreateConfigEntry("PromoteCanSelect", {
	name = "settings_promotecanselect",
	description = "settings_promotecanselect_desc",
	type = "bool",
	category = "factions",
	default = true,
	factionType = VOIDFACTIONS_STATICFACTIONS
})

VoidFactions.Settings:CreateConfigEntry("UpgradesEnabled", {
	name = "settings_upgradesenabled",
	description = "settings_upgradesenabled_desc",
	type = "bool",
	category = "factions",
	default = false,
	factionType = VOIDFACTIONS_STATICFACTIONS
})

VoidFactions.Settings:CreateConfigEntry("DepositEnabled", {
	name = "settings_depositenabled",
	description = "settings_depositenabled_desc",
	type = "bool",
	category = "factions",
	default = true,
})

VoidFactions.Settings:CreateConfigEntry("FactionCreateCost", {
	name = "settings_factioncreatecost",
	description = "settings_factioncreatecost_desc",
	type = "number",
	category = "factions",
	default = 25000,
	factionType = VOIDFACTIONS_DYNAMICFACTIONS
})

VoidFactions.Settings:CreateConfigEntry("DefaultRankName", {
	name = "settings_defaultrankname",
	description = "settings_defaultrankname_desc",
	type = "string",
	category = "factions",
	default = "Boss",
	factionType = VOIDFACTIONS_DYNAMICFACTIONS
})

VoidFactions.Settings:CreateConfigEntry("MaxTagLength", {
	name = "settings_maxtaglength",
	description = "settings_maxtaglength_desc",
	type = "number",
	category = "factions",
	default = 5,
	factionType = VOIDFACTIONS_DYNAMICFACTIONS
})

VoidFactions.Settings:CreateConfigEntry("NametagsDisabled", {
	name = "settings_nametagsdisabled",
	description = "settings_nametagsdisabled_desc",
	type = "bool",
	category = "factions",
	default = false,
	factionType = VOIDFACTIONS_DYNAMICFACTIONS
})

-- Deposits

hook.Add("InitPostEntity", "VoidFactions.Settings.OnInitializeAddons", function ()

	local currencyOptions = {}
	local defaultOption = DarkRP and "DarkRP" or nil
	for k, v in pairs(VoidFactions.Currencies.List) do
		if (v.isInternal) then continue end
		if (!v:IsInstalled()) then continue end
		
		if (!defaultOption) then
			defaultOption = k
		end
		currencyOptions[#currencyOptions + 1] = k
	end

	VoidFactions.Settings:CreateConfigEntry("FactionCreateCurrency", {
		name = "settings_factioncreatecurrency",
		description = "settings_factioncreatecurrency_desc",
		type = "dropdown",
		category = "factions",
		default = defaultOption,
		ddOptions = currencyOptions,
		factionType = VOIDFACTIONS_DYNAMICFACTIONS
	})

	VoidFactions.Settings:CreateConfigEntry("DepositCurrency", {
		name = "settings_depositcurrency",
		description = "settings_depositcurrency_desc",
		type = "dropdown",
		category = "deposit",
		default = defaultOption,
		ddOptions = currencyOptions,
	})

	local inventoryOptions = {}
	local defaultOption = nil
	for k, v in pairs(VoidFactions.Inventories.List) do
		if (!v:IsInstalled()) then continue end

		if (!defaultOption) then
			defaultOption = k
		end
		
		inventoryOptions[#inventoryOptions + 1] = k
	end

	VoidFactions.Settings:CreateConfigEntry("DepositInventory", {
		name = "settings_depositinventory",
		description = "settings_depositinventory_desc",
		type = "dropdown",
		category = "deposit",
		default = defaultOption,
		ddOptions = inventoryOptions,
	})

end)

-- Invites

VoidFactions.Settings:CreateConfigEntry("InviteDuration", {
	name = "settings_inviteduration",
	description = "settings_inviteduration_desc",
	type = "number",
	category = "invites",
	default = 20,
})

-- Capture points

VoidFactions.Settings:CreateConfigEntry("CapturePointRenderDistance", {
	name = "settings_pointrenderdist",
	description = "settings_pointrenderdist_desc",
	type = "number",
	category = "capturepoints",
	default = 3000,
})

VoidFactions.Settings:CreateConfigEntry("ShowPointDistances", {
	name = "settings_showpointdistances",
	description = "settings_showpointdistances_desc",
	type = "bool",
	category = "capturepoints",
	default = true,
})

VoidFactions.Settings:CreateConfigEntry("CaptureTime", {
	name = "settings_pointcaptime",
	description = "settings_pointcaptime_desc",
	type = "number",
	category = "capturepoints",
	default = 60,
})

-- Experience (this applies both to static and dynamic factions)

VoidFactions.Settings:CreateConfigEntry("DisableXP", {
	name = "settings_disablexpsystem",
	description = "settings_disablexpsystem_desc",
	type = "bool",
	category = "experience",
	default = false,
})

VoidFactions.Settings:CreateConfigEntry("LevelUpXP", {
	name = "settings_baselevelupxp",
	description = "settings_baselevelupxp_desc",
	type = "number",
	category = "experience",
	default = 500,
})

VoidFactions.Settings:CreateConfigEntry("LevelUpMultiplier", {
	name = "settings_levelupmultiplier",
	description = "settings_levelupmultiplier_desc",
	type = "number",
	category = "experience",
	default = 1.05,
})

VoidFactions.Settings:CreateConfigEntry("MaxLevel", {
	name = "settings_maxlevel",
	description = "settings_maxlevel_desc",
	type = "number",
	category = "experience",
	default = 100,
})

-- General

hook.Add("VoidFactions.Lang.LanguagesLoaded", "VoidFactions.Settings.CreateLangEntry", function ()
	VoidFactions.PrintDebug("Languages loaded, creating language setting entry!")

	-- Make all the first letters uppercase
	local langTbl = table.GetKeys(VoidFactions.Lang.Langs)
	for k, v in ipairs(langTbl) do
		langTbl[k] = (v:gsub("^%l", string.upper))
	end

	VoidFactions.Settings:CreateConfigEntry("Language", {
		name = "settings_language",
		description = "settings_language_desc",
		type = "dropdown",
		category = "general",
		ddOptions = langTbl,
		default = "English",
	})

	VoidFactions.Settings:CreateConfigEntry("NPCModel", {
		name = "settings_npcmodel",
		description = "settings_npcmodel_desc",
		type = "string",
		category = "general",
		default = "models/humans/group01/male_03.mdl",
	})
end)

-- Config loading
hook.Add("VoidFactions.DatabaseConnected", "VoidFactions.LoadInGameConfig", function ()
	timer.Simple(5, function ()
		VoidFactions.Settings:LoadConfig()
	end)
end)
