if CLIENT then return end
zcm = zcm or {}
zcm.f = zcm.f or {}

if zcm.config.EnableResourceAddfile then
	zcm = zcm or {}
	zcm.force = zcm.force or {}

	function zcm.force.AddDir(path)
		local files, folders = file.Find(path .. "/*", "GAME")

		for k, v in pairs(files) do
			resource.AddFile(path .. "/" .. v)
		end

		for k, v in pairs(folders) do
			zcm.force.AddDir(path .. "/" .. v)
		end
	end

	zcm.force.AddDir("materials/particle/zcm/")
	zcm.force.AddDir("sound/zcm/")
	zcm.force.AddDir("models/zerochain/props_crackermaker/")
	zcm.force.AddDir("materials/zerochain/props_crackermachine/")
	zcm.force.AddDir("materials/zerochain/zcm/")

	resource.AddSingleFile("materials/entities/zcm_blackpowder.png")
	resource.AddSingleFile("materials/entities/zcm_box.png")
	resource.AddSingleFile("materials/entities/zcm_buyer_npc.png")
	resource.AddSingleFile("materials/entities/zcm_crackermachine.png")
	resource.AddSingleFile("materials/entities/zcm_firecracker.png")
	resource.AddSingleFile("materials/entities/zcm_palette.png")
	resource.AddSingleFile("materials/entities/zcm_paperroll.png")


else
end
