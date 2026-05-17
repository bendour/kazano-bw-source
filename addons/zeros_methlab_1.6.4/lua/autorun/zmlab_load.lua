zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

local function NicePrint(txt)
	if SERVER then
		MsgC(Color(98, 149, 193), txt .. "\n")
	else
		MsgC(Color(193, 193, 98), txt .. "\n")
	end
end

local IgnoreFileTable = {}
function zmlab.f.PreLoadFile(fdir,afile,info)
	IgnoreFileTable[afile] = true
	zmlab.f.LoadFile(fdir,afile,info)
end

function zmlab.f.LoadFile(fdir,afile,info)

	if info then
		local nfo = "// [ Initialize ]: " .. afile .. string.rep( " ", 30 - afile:len() ) .. "//"
		NicePrint(nfo)
	end

	if SERVER then
		AddCSLuaFile(fdir .. afile)
	end

	include(fdir .. afile)
end

function zmlab.f.LoadAllFiles(fdir)
	local files, dirs = file.Find(fdir .. "*", "LUA")

	for _, afile in ipairs(files) do
		if string.match(afile, ".lua") and not IgnoreFileTable[afile] then
			zmlab.f.LoadFile(fdir,afile,true)
		end
	end

	for _, dir in ipairs(dirs) do
		zmlab.f.LoadAllFiles(fdir .. dir .. "/")
	end
end

// Initializes the Script
function zmlab.f.Initialize()
	NicePrint(" ")
	NicePrint("///////////////////////////////////////////////////")
	NicePrint("///////////////// Zeros MethLab ///////////////////")
	NicePrint("///////////////////////////////////////////////////")

	zmlab.f.PreLoadFile("zmlab/sh/","zmlab_config.lua",true)
	zmlab.f.LoadAllFiles("zmlab_languages/")

	zmlab.f.LoadAllFiles("zmlab/sh/")
	if SERVER then
		zmlab.f.LoadAllFiles("zmlab/sv/")
	end
	zmlab.f.LoadAllFiles("zmlab/cl/")

	NicePrint("///////////////////////////////////////////////////")
	NicePrint("///////////////////////////////////////////////////")
end

if SERVER then

	timer.Simple(0,function()
		zmlab.f.Initialize()
	end)
else


	// This needs to be called instantly on client since client settings wont work otherwhise
	zmlab.f.PreLoadFile("zmlab/sh/","zmlab_materials.lua",false)
	zmlab.f.PreLoadFile("zmlab/cl/","zmlab_fonts.lua",false)
	zmlab.f.PreLoadFile("zmlab/cl/","zmlab_settings_menu.lua",false)

	timer.Simple(0,function()
		zmlab.f.Initialize()
	end)
end
