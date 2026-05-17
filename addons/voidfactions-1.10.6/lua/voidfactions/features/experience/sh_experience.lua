-- Helper functions

VoidFactions.XP = VoidFactions.XP or {}
VoidFactions.XP.Modules = {}

function VoidFactions.XP:GetRequiredXP(level)
	level = level or 0
	return VoidFactions.Config.LevelUpXP * level * VoidFactions.Config.LevelUpMultiplier
end

-- Enums

VOIDFACTIONS_PLAYERXP = 1
VOIDFACTIONS_FACTIONXP = 2

-- Class for creating new XP types
-- XP amount will be configurable in the admin panel

local XP_CLASS = {}
XP_CLASS.__index = XP_CLASS

function XP_CLASS:New()
	local object = setmetatable({}, XP_CLASS)
		object.id = "XP_BASEID"
		object.xpAmount = 10 -- XP amount will be set via an in-game config panel
		object.noTranslate = false
		object.timeBased = false

		object.isStatic = false
	return object
end

function XP_CLASS:SetID(id)
	self.id = id
end

function XP_CLASS:SetTimeBased()
	self.timeBased = true
end

function XP_CLASS:SetMember()
	self.isStatic = true
end

function XP_CLASS:SetXPAmount(xp)
	self.xpAmount = xp
end

function XP_CLASS:NoTranslate()
	self.noTranslate = true
end

function XP_CLASS:Setup(func)
	self.setupFunc = func
end

function XP_CLASS:AddXP(receiver)
	if (!SERVER) then return end

	-- Add XP depending on type
	-- This stuff would be useful with C# interfaces haha
	if (!receiver or !receiver.AddXP) then
		VoidFactions.PrintError("Receiver class doesn't implement AddXP meta function! XP ID: " .. self.id)
		return
	end


	-- Ignore members if dynamic factions and factions if static factions
	if (receiver.ply and VoidFactions.Settings:IsDynamicFactions()) then return end
	if (receiver.logo and VoidFactions.Settings:IsStaticFactions()) then return end


	receiver:AddXP(self.xpAmount)
	hook.Run("VoidFactions.PlayerReceivedXP", receiver.ply, self.xpAmount)
end

-- Public functions

function VoidFactions.XP:Module()
	return XP_CLASS:New()
end

local function handleAddModule(module)
	if (VoidFactions.Settings:IsDynamicFactions() and module.isStatic) then return end
	--if (VoidFactions.Settings:IsStaticFactions() and !module.isStatic) then return end

	VoidFactions.PrintDebug("Loaded experience module " .. module.id .. "!")
	VoidFactions.XP.Modules[module.id] = module

	local name = module.noTranslate and module.id or ("xp_" .. string.lower(module.id))
	local description = module.noTranslate and "No translation" or "xp_" .. string.lower(module.id) .. "_desc"


	VoidFactions.Settings:CreateConfigEntry("XP_" .. module.id, {
		name = name,
		description = description,
		type = module.timeBased and "timevalue" or "number",
		category = "xpmodules",
		default = module.timeBased and {10,10} or 10,
	})

	if (SERVER) then
		module.setupFunc()

		local config = VoidFactions.Config
		local loadedConfigs = VoidFactions.LoadedConfigs
		for key, v in pairs(VoidFactions.Settings.IGConfig) do
			if (loadedConfigs[key] == nil) then
				config[key] = v.default
				VoidFactions.SQL:AddSetting(key, v.default)
			end
		end

	end
end


function VoidFactions.XP:AddModule(module)
	if (!module.id or module.id == "XP_BASEID") then VoidFactions.PrintError("Tried to register an XP module, but no ID provided!") return end

	if (VoidFactions.Settings.ConfigLoaded) then
		handleAddModule(module)
	else
		hook.Add("VoidFactions.Settings.Loaded", "VoidFactions.XP.WaitForSettings" .. module.id, function ()
			handleAddModule(module)
		end)
	end
end
