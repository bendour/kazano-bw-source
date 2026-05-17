if (not SERVER) then return end

if zmlab.config.EnableResourceAddfile then
	zmlab = zmlab or {}
	zmlab.force = zmlab.force or {}

	function zmlab.force.AddDir(path)
		local files, folders = file.Find(path .. "/*", "GAME")

		for k, v in pairs(files) do
			resource.AddFile(path .. "/" .. v)
		end

		for k, v in pairs(folders) do
			zmlab.force.AddDir(path .. "/" .. v)
		end
	end

	zmlab.force.AddDir("materials/zerochain/particles/zmlab")
	zmlab.force.AddDir("materials/zerochain/zmlab")
	zmlab.force.AddDir("models/zerochain/zmlab")
	zmlab.force.AddDir("sound/zmlab")

	resource.AddSingleFile("particles/zerochain_zmlab_filter_vfx.pcf")
	resource.AddSingleFile("particles/zerochain_zmlab_liquids_vfx.pcf")
	resource.AddSingleFile("particles/zerochain_zmlab_meth_vfx.pcf")
	resource.AddSingleFile("particles/zerochain_zmlab_vfx.pcf")

	resource.AddSingleFile("materials/entities/zmlab_aluminium.png")
	resource.AddSingleFile("materials/entities/zmlab_collectcrate.png")
	resource.AddSingleFile("materials/entities/zmlab_combiner.png")
	resource.AddSingleFile("materials/entities/zmlab_filter.png")
	resource.AddSingleFile("materials/entities/zmlab_frezzer.png")
	resource.AddSingleFile("materials/entities/zmlab_meth.png")
	resource.AddSingleFile("materials/entities/zmlab_meth_baggy.png")
	resource.AddSingleFile("materials/entities/zmlab_methbuyer.png")
	resource.AddSingleFile("materials/entities/zmlab_methdropoff.png")
	resource.AddSingleFile("materials/entities/zmlab_methylamin.png")
	resource.AddSingleFile("materials/entities/zmlab_palette.png")

	resource.AddSingleFile("materials/vgui/entities/zmlab_extractor.vmt")
	resource.AddSingleFile("materials/vgui/entities/zmlab_extractor.vtf")


else
end
