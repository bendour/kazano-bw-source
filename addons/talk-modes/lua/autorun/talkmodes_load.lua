--[[-------------------------------------------

    Talk Modes - whisper/talk/yell 

    Licensed to 00000000000000000
	Version: 1.1.1

	By: SaturdaysHeroes & Djuk
	Special thanks to CupCakeR.

--]]-------------------------------------------
TalkModes = TalkModes || {}

local function Log(sMessage)
	MsgC(Color(255, 0, 0), "[Talk Modes] ", Color(255, 255, 255), string.format("%s.", sMessage.."\n"))
end

local function LoadClientFile(sFile)
	if (SERVER) then AddCSLuaFile(sFile) return end

	include(sFile)
	Log(string.format("Loaded file: %s (client)", sFile))
end

local function LoadSharedFile( sFile )
	AddCSLuaFile(sFile)
	include(sFile)
	Log(string.format("Loaded file: %s (shared)", sFile))
end

local function LoadServerFile( sFile )
	if (CLIENT) then return end

	include( sFile )
	Log(string.format("Loaded file: %s (server)", sFile))
end

local function LoadDirectory( wildCard )
	local wildCard = ( wildCard and ( wildCard .. "/*" ) or "*" )
	local tblFiles, tblDirectories = file.Find( wildCard, "LUA")

	for _, sFile in ipairs( tblFiles ) do
		local wildCard = string.TrimRight( wildCard, "/*" )
		if ( !string.EndsWith( sFile, ".lua" ) ) then continue end

		if ( string.StartWith( sFile, "cl_" ) ) then
			LoadClientFile( wildCard .. "/" .. sFile )
		elseif ( string.StartWith( sFile, "sv_" ) ) then
			LoadServerFile( wildCard .. "/" .. sFile )
		else
			LoadSharedFile( wildCard .. "/" .. sFile )
		end
	end

	for _, sDirectory in ipairs( tblDirectories ) do
		local wildCard = string.TrimRight( wildCard, "*" ) .. sDirectory

		LoadDirectory( wildCard )
	end
end

Log("Loading Talk Modes - version 1.1.1")

-- Config
LoadServerFile("talk_modes/config/sv_config.lua")
LoadSharedFile("talk_modes/config/sh_config.lua")

-- Language
LoadSharedFile("talk_modes/language/sh_languages.lua")
LoadDirectory("talk_modes/language")

-- Core
LoadSharedFile("talk_modes/core/sh_core.lua")
LoadServerFile("talk_modes/core/sv_core.lua")
LoadClientFile("talk_modes/core/cl_core.lua")

-- Networking
LoadServerFile("talk_modes/networking/sv_net.lua")
LoadClientFile("talk_modes/networking/cl_net.lua")

-- VGUI
LoadDirectory("talk_modes/vgui")

Log("Loaded Talk Modes - version 1.1.1")
