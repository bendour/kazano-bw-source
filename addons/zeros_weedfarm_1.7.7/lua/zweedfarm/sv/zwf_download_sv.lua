if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

if zwf.config.EnableResourceAddfile then
	zwf = zwf or {}
	zwf.force = zwf.force or {}

	function zwf.force.AddDir(path)
		local files, folders = file.Find(path .. "/*", "GAME")

		for k, v in pairs(files) do
			resource.AddFile(path .. "/" .. v)
		end

		for k, v in pairs(folders) do
			zwf.force.AddDir(path .. "/" .. v)
		end
	end

	resource.AddSingleFile("particles/zwf_bong.pcf")
	resource.AddSingleFile("particles/zwf_generator.pcf")
	resource.AddSingleFile("particles/zwf_lighter.pcf")
	resource.AddSingleFile("particles/zwf_plant.pcf")
	resource.AddSingleFile("particles/zwf_seedlab.pcf")
	resource.AddSingleFile("particles/zwf_selling.pcf")
	resource.AddSingleFile("particles/zwf_ventilator.pcf")
	resource.AddSingleFile("particles/zwf_water.pcf")


	resource.AddSingleFile("materials/entities/zwf_autopacker.png")
	resource.AddSingleFile("materials/entities/zwf_bong01_ent.png")
	resource.AddSingleFile("materials/entities/zwf_bong02_ent.png")
	resource.AddSingleFile("materials/entities/zwf_bong03_ent.png")
	resource.AddSingleFile("materials/entities/zwf_buyer_npc.png")
	resource.AddSingleFile("materials/entities/zwf_doobytable.png")
	resource.AddSingleFile("materials/entities/zwf_drystation.png")
	resource.AddSingleFile("materials/entities/zwf_fuel.png")
	resource.AddSingleFile("materials/entities/zwf_generator.png")
	resource.AddSingleFile("materials/entities/zwf_jar.png")
	resource.AddSingleFile("materials/entities/zwf_lamp.png")
	resource.AddSingleFile("materials/entities/zwf_mixer.png")
	resource.AddSingleFile("materials/entities/zwf_outlet.png")
	resource.AddSingleFile("materials/entities/zwf_oven.png")
	resource.AddSingleFile("materials/entities/zwf_packingstation.png")
	resource.AddSingleFile("materials/entities/zwf_palette.png")
	resource.AddSingleFile("materials/entities/zwf_pot.png")
	resource.AddSingleFile("materials/entities/zwf_pot_hydro.png")
	resource.AddSingleFile("materials/entities/zwf_seed_bank.png")
	resource.AddSingleFile("materials/entities/zwf_soil.png")
	resource.AddSingleFile("materials/entities/zwf_splice_lab.png")
	resource.AddSingleFile("materials/entities/zwf_ventilator.png")
	resource.AddSingleFile("materials/entities/zwf_watertank.png")
	resource.AddSingleFile("materials/entities/zwf_weedblock.png")
	resource.AddSingleFile("materials/entities/zwf_weedstick.png")

	resource.AddSingleFile("materials/vgui/entities/zwf_bong01.vmt")
	resource.AddSingleFile("materials/vgui/entities/zwf_bong01.vtf")

	resource.AddSingleFile("materials/vgui/entities/zwf_bong02.vmt")
	resource.AddSingleFile("materials/vgui/entities/zwf_bong02.vtf")

	resource.AddSingleFile("materials/vgui/entities/zwf_bong03.vmt")
	resource.AddSingleFile("materials/vgui/entities/zwf_bong03.vtf")

	resource.AddSingleFile("materials/vgui/entities/zwf_cable.vmt")
	resource.AddSingleFile("materials/vgui/entities/zwf_cable.vtf")

	resource.AddSingleFile("materials/vgui/entities/zwf_shoptablet.vmt")
	resource.AddSingleFile("materials/vgui/entities/zwf_shoptablet.vtf")

	resource.AddSingleFile("materials/vgui/entities/zwf_sniffer.vmt")
	resource.AddSingleFile("materials/vgui/entities/zwf_sniffer.vtf")

	resource.AddSingleFile("materials/vgui/entities/zwf_wateringcan.vmt")
	resource.AddSingleFile("materials/vgui/entities/zwf_wateringcan.vtf")

	resource.AddSingleFile("resource/fonts/RUSAK.ttf")

	zwf.force.AddDir("sound/zwf/")
	zwf.force.AddDir("models/zerochain/props_weedfarm/")
	zwf.force.AddDir("materials/zerochain/zwf/")
	zwf.force.AddDir("materials/zerochain/props_weedfarm/")

else
	resource.AddWorkshop( "1741741175" ) // Zeros GrowOP Contentpack
	//https://steamcommunity.com/sharedfiles/filedetails/?id=1741741175
end
