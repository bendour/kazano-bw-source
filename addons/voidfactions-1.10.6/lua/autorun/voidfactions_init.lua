
--[[---------------------------------------------------------
	Name: Setup
-----------------------------------------------------------]]
VoidFactions = VoidFactions or {}
VoidFactions.Config = VoidFactions.Config or {}
VoidFactions.Lang = VoidFactions.Lang or {}

function VoidFactions.Lang.GetPhrase(phrase, x)
	return VoidLib.Lang:GetLangPhrase("VoidFactions", phrase, x)
end

VoidFactions.Dir = "voidfactions"

VoidFactions.CurrentVersion = "1.10.6f"

if (CLIENT) then
	include(VoidFactions.Dir .. "/libs/cami.lua")
end

if (SERVER) then
	if (string.sub(VoidFactions.CurrentVersion, 1, 1) != "{") then
		resource.AddWorkshop("2078529432")
	end

	include("voidfactions_mysql.lua")

	include(VoidFactions.Dir .. "/libs/cami.lua")
	AddCSLuaFile(VoidFactions.Dir .. "/libs/cami.lua")
end

--[[---------------------------------------------------------
	Name: Main
-----------------------------------------------------------]]
function VoidFactions.Load(dir, svOnly, shOnly)
	local files = file.Find(dir.. "/".. "*", "LUA")

	for k, v in pairs(files) do
		if string.StartWith(v, "cl") then
			AddCSLuaFile(dir.. "/".. v)

			if CLIENT then
				local load = include(dir.. "/".. v)
				if load then load() end
			end
		end

		if string.StartWith(v, "sv") or svOnly then
			if SERVER then
				local load = include(dir.. "/".. v)
				if load then load() end
			end
		end

		if string.StartWith(v, "sh") or shOnly then
			AddCSLuaFile(dir.. "/".. v)

			local load = include(dir.. "/".. v)
			if load then load() end
		end
	end
end

function VoidFactions.LoadDirOfDirs(dir, msg, isCSDir)
	local files, dirs = file.Find(dir.. "/".. "*", "LUA")

	if (isCSDir) then
		VoidFactions.AddCSDir(dir)
	end

	for k, v in pairs(dirs) do
		if (isCSDir) then
			VoidFactions.AddCSDir(dir .. "/" .. v)
		else
			VoidFactions.Load(dir .. "/" .. v)
		end
		if (msg) then
			VoidFactions.PrintDebug(VoidLib.StringFormat(msg, v))
		end
	end
end

function VoidFactions.AddCSDir(dir)
	local files = file.Find(dir.. "/".. "*", "LUA")

	for k, v in pairs(files) do
		AddCSLuaFile(dir.. "/".. v)

		if CLIENT then
			include(dir.. "/".. v)
		end
	end
end

--[[---------------------------------------------------------
	Name: Functions (00000000000000000)
-----------------------------------------------------------]]
function VoidFactions.PrintError(...)
	MsgC(Color(192, 57, 43), "[VoidFactions] (ERROR): ", Color(255, 255, 255), ..., "\n")
end

function VoidFactions.PrintWarning(...)
	MsgC(Color(230, 126, 34), "[VoidFactions] (WARNING): ", Color(255, 255, 255), ..., "\n")
end

function VoidFactions.PrintDebug(...)
	if (!VoidFactions.Debug) then return end

	MsgC(Color(120, 255, 120), "[VoidFactions] (DEBUG): ", Color(255, 255, 255), ..., "\n")
end

function VoidFactions.Print(...)
	MsgC(Color(87, 180, 242), "[VoidFactions]: ", Color(255, 255, 255), ..., "\n")
end

--[[---------------------------------------------------------
	Name: Loading
-----------------------------------------------------------]]

local brandStr = [[
 __   __   _    _ ___        _   _             
 \ \ / /__(_)__| | __|_ _ __| |_(_)___ _ _  ___
  \ V / _ \ / _` | _/ _` / _|  _| / _ \ ' \(_-<
   \_/\___/_\__,_|_|\__,_\__|\__|_\___/_||_/__/
                                                                                                  
]]

local licenseInfo = [[
  Licensed to: 00000000000000000
  Version: 1.10.6f
]]

MsgC(Color(87, 180, 242), brandStr, Color(242, 113, 87), licenseInfo, Color(255, 255, 255), "\n")


function VoidFactions.LoadAll()
	VoidFactions.Load(VoidFactions.Dir.. "/libs")
	VoidFactions.Load(VoidFactions.Dir)

	VoidFactions.Load(VoidFactions.Dir .. "/core")

	VoidFactions.LoadDirOfDirs(VoidFactions.Dir .. "/features", "Loaded feature :module:!")

	VoidFactions.Load(VoidFactions.Dir .. "/classes")

	VoidFactions.Load(VoidFactions.Dir .. "/modules/currencies", false, true)
	hook.Run("VoidFactions.Currencies.Loaded")
	
	VoidFactions.Load(VoidFactions.Dir .. "/modules/experience", false, true)
	VoidFactions.Load(VoidFactions.Dir .. "/modules/upgrades", false, true)
	VoidFactions.Load(VoidFactions.Dir .. "/modules/rewards", false, true)
	hook.Run("VoidFactions.Rewards.Loaded")

	VoidFactions.Load(VoidFactions.Dir .. "/modules/inventories", false, true)
	hook.Run("VoidFactions.Inventories.Loaded")
	
	VoidFactions.LoadDirOfDirs(VoidFactions.Dir .. "/net", "Loaded net handler :net:!")

	VoidFactions.LoadDirOfDirs(VoidFactions.Dir .. "/vgui", "Loaded VGUI directory :vgui:!", true)
end


if (!VoidFactions.Loaded) then
	if (VoidLib) then
		VoidFactions.Print("VoidLib already loaded, loading..")
		VoidFactions.LoadAll()
	else
		VoidFactions.PrintDebug("VoidLib not loaded, waiting for hook")
		hook.Add("VoidLib.Loaded", "VoidFactions.Init.WaitForVoidLib", function ()
			VoidFactions.Print("VoidLib load hook called, loading..")
			VoidFactions.LoadAll()
		end)
	end

	-- By this time, VoidLib should be available.
	hook.Add("InitPostEntity", "VoidFactions.IsVoidLibLoaded", function ()
		if (!VoidLib) then
			VoidFactions.PrintError("--------------------------------------------------------------------------------")
			VoidFactions.PrintError("You are missing VoidLib! Subscribe to it at https://steamcommunity.com/sharedfiles/filedetails/?id=2078529432!")
			VoidFactions.PrintError("Without VoidLib the addon will not function properly.")
			VoidFactions.PrintError("You have been warned! This addon will not load until VoidLib is installed.")
			VoidFactions.PrintError("Do not open a support ticket unless you are 100% sure that VoidLib is installed.")
			VoidFactions.PrintError("--------------------------------------------------------------------------------")
		else
			if (!VoidLib.Database and SERVER) then
				VoidFactions.PrintError("--------------------------------------------------------------------------------")
				VoidFactions.PrintError("Your VoidLib IS OUTDATED! UPDATE TO THE LATEST ONE, PREFERABLY FROM THE WORKSHOP!")
				VoidFactions.PrintError("This addon is using VoidLib libraries utilizing a new database connection system.")
				VoidFactions.PrintError("Your VoidLib version is missing the new VoidLib database libraries.")
				VoidFactions.PrintError("Do not open a support ticket unless you are 100% sure that VoidLib is updated.")
				VoidFactions.PrintError("--------------------------------------------------------------------------------")
			end
		end
	end)
end

VoidFactions.Loaded = true

--[[---------------------------------------------------------
	Name: VoidLib loader
	Info: Don't touch this or the addon will break.
-----------------------------------------------------------]]

if (!SERVER) then return end
hook.Add("InitPostEntity", "VoidFactions.LibLoader", function ()
	VoidLib.Tracker:RegisterAddon("VoidFactions", "6c3eadb8-fb2a-4d76-ba23-d71fa54aa904", "86480918070603124")
end)
