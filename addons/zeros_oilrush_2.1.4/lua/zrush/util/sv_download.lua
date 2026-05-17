if CLIENT then return end


if zrush.config.FastDL then
	zrush = zrush or {}
	zrush.force = zrush.force or {}

	function zrush.force.AddDir(path)
		local files, folders = file.Find(path .. "/*", "GAME")

		for k, v in pairs(files) do
			resource.AddFile(path .. "/" .. v)
		end

		for k, v in pairs(folders) do
			zrush.force.AddDir(path .. "/" .. v)
		end
	end

	resource.AddSingleFile("materials/entities/zrush_barrel.png")
	resource.AddSingleFile("materials/entities/zrush_drillpipe_holder.png")
	resource.AddSingleFile("materials/entities/zrush_npc.png")
	resource.AddSingleFile("materials/entities/zrush_machinecrate.png")

	resource.AddSingleFile("particles/zrush_burner_vfx.pcf")
	resource.AddSingleFile("particles/zrush_drill_vfx.pcf")
	resource.AddSingleFile("particles/zrush_oil_vfx.pcf")
	resource.AddSingleFile("particles/zrush_refinery_vfx.pcf")

	resource.AddSingleFile("resource/fonts/gothic.ttf")
	resource.AddSingleFile("resource/fonts/gothicb.ttf")
	resource.AddSingleFile("resource/fonts/gothicbi.ttf")
	resource.AddSingleFile("resource/fonts/gothici.ttf")


	zrush.force.AddDir("sound/zrush")

	zrush.force.AddDir("models/zerochain/props_oilrush")

	zrush.force.AddDir("materials/zerochain/zrush/particles")
	zrush.force.AddDir("materials/zerochain/zrush/ui")

	zrush.force.AddDir("materials/zerochain/props_oilrush")
	zrush.force.AddDir("materials/zerochain/props_oilrush/barrel")
	zrush.force.AddDir("materials/zerochain/props_oilrush/burner")
	zrush.force.AddDir("materials/zerochain/props_oilrush/drillhole")
	zrush.force.AddDir("materials/zerochain/props_oilrush/drillpipe")
	zrush.force.AddDir("materials/zerochain/props_oilrush/drilltower")
	zrush.force.AddDir("materials/zerochain/props_oilrush/machinecrate")
	zrush.force.AddDir("materials/zerochain/props_oilrush/modulebase")
	zrush.force.AddDir("materials/zerochain/props_oilrush/oilpump")
	zrush.force.AddDir("materials/zerochain/props_oilrush/oilspot")
	zrush.force.AddDir("materials/zerochain/props_oilrush/refinery")
else
end
