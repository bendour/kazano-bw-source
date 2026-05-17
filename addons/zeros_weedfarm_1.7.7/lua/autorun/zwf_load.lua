zwf = zwf or {}
zwf.f = zwf.f or {}

local function NicePrint(txt)
	if SERVER then
		MsgC(Color(98, 193, 98), txt .. "\n")
	else
		MsgC(Color(193, 193, 98), txt .. "\n")
	end
end

local IgnoreFileTable = {}
function zwf.f.PreLoadFile(fdir,afile,info)
	IgnoreFileTable[afile] = true
	zwf.f.LoadFile(fdir,afile,info)
end

function zwf.f.LoadFile(fdir,afile,info)

	if info then
		local nfo = "// [ Initialize ]: " .. afile .. string.rep( " ", 30 - afile:len() ) .. "//"
		NicePrint(nfo)
	end

	if SERVER then
		AddCSLuaFile(fdir .. afile)
	end

	include(fdir .. afile)
end

function zwf.f.LoadAllFiles(fdir)
	local files, dirs = file.Find(fdir .. "*", "LUA")

	for _, afile in ipairs(files) do
		if string.match(afile, ".lua") and not IgnoreFileTable[afile] then
			zwf.f.LoadFile(fdir,afile,true)
		end
	end

	for _, dir in ipairs(dirs) do
		zwf.f.LoadAllFiles(fdir .. dir .. "/")
	end
end


// Initializes the Script
function zwf.f.Initialize()
	NicePrint(" ")
	NicePrint("///////////////////////////////////////////////////")
	NicePrint("///////////////// Zeros GrowOP ////////////////////")
	NicePrint("///////////////////////////////////////////////////")
	NicePrint("//                                               //")
	NicePrint("//------------------ SHARED ---------------------//")
	NicePrint("//                                               //")
	zwf.f.PreLoadFile("zweedfarm/sh/", "zwf_materials.lua", true)
	zwf.f.PreLoadFile("", "zwf_config_main.lua", true)
	zwf.f.PreLoadFile("", "zwf_config_growing.lua", true)
	zwf.f.PreLoadFile("", "zwf_config_processing.lua", true)
	zwf.f.PreLoadFile("", "zwf_config_selling.lua", true)
	zwf.f.PreLoadFile("", "zwf_config_effects.lua", true)
	zwf.f.LoadAllFiles("zwf_languages/")
	zwf.f.PreLoadFile("", "zwf_config_shop.lua", true)
	zwf.f.PreLoadFile("zweedfarm/sh/", "zwf_precache.lua", true)
	zwf.f.LoadAllFiles("zweedfarm/sh/")

	if SERVER then
		NicePrint("//                                               //")
		NicePrint("//------------------ SERVER ---------------------//")
		NicePrint("//                                               //")
		zwf.f.LoadAllFiles("zweedfarm/sv/")
	end

	NicePrint("//                                               //")
	NicePrint("//------------------ CLIENT ---------------------//")
	NicePrint("//                                               //")
	zwf.f.LoadAllFiles("zweedfarm/cl/")
	NicePrint("///////////////////////////////////////////////////")
	NicePrint("///////////////////////////////////////////////////")
end
if SERVER then
	timer.Simple(0,function()
		zwf.f.Initialize()
	end)
else

	// This needs to be called instantly on client since client settings wont work otherwhise
	zwf.f.PreLoadFile("zweedfarm/sh/","zwf_materials.lua",false)
	zwf.f.PreLoadFile("zweedfarm/cl/","zwf_fonts.lua",false)
	zwf.f.PreLoadFile("zweedfarm/cl/","zwf_settings_menu.lua",false)

	timer.Simple(0,function()
		zwf.f.Initialize()
	end)
end
