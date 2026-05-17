/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

if CLIENT then return end

// Zeros libary
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

resource.AddSingleFile("materials/entities/zmlab2_dropoff.png")
resource.AddSingleFile("materials/entities/zmlab2_equipment.png")
resource.AddSingleFile("materials/entities/zmlab2_item_autobreaker.png")
resource.AddSingleFile("materials/entities/zmlab2_item_crate.png")
resource.AddSingleFile("materials/entities/zmlab2_item_frezzertray.png")
resource.AddSingleFile("materials/entities/zmlab2_item_meth.png")
resource.AddSingleFile("materials/entities/zmlab2_item_palette.png")
resource.AddSingleFile("materials/entities/zmlab2_machine_filler.png")
resource.AddSingleFile("materials/entities/zmlab2_machine_filter.png")
resource.AddSingleFile("materials/entities/zmlab2_machine_frezzer.png")
resource.AddSingleFile("materials/entities/zmlab2_machine_furnace.png")
resource.AddSingleFile("materials/entities/zmlab2_machine_mixer.png")
resource.AddSingleFile("materials/entities/zmlab2_machine_ventilation.png")
resource.AddSingleFile("materials/entities/zmlab2_npc.png")
resource.AddSingleFile("materials/entities/zmlab2_storage.png")
resource.AddSingleFile("materials/entities/zmlab2_table.png")
resource.AddSingleFile("materials/entities/zmlab2_tent.png")

if zmlab2.config.FastDl then
	zmlab2 = zmlab2 or {}
	zmlab2.Download = zmlab2.Download or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 99958388d5b8bc21e4d7af1df39fd75077f0660617b3c526ce40ea9691a5fd3b

	function zmlab2.Download.AddDir(path)
		local files, folders = file.Find(path .. "/*", "GAME")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae

		for k, v in pairs(files) do
			resource.AddFile(path .. "/" .. v)
		end

		for k, v in pairs(folders) do
			zmlab2.Download.AddDir(path .. "/" .. v)
		end
	end

	zmlab2.Download.AddDir("sound/zmlab2/")
	zmlab2.Download.AddDir("models/zerochain/props_methlab/")
	zmlab2.Download.AddDir("materials/zerochain/props_methlab/")
	zmlab2.Download.AddDir("materials/zerochain/zmlab2/")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 99958388d5b8bc21e4d7af1df39fd75077f0660617b3c526ce40ea9691a5fd3b

	resource.AddSingleFile("particles/zmlab2_fx.pcf")

	resource.AddSingleFile("resource/fonts/nexa-bold.ttf")
	resource.AddSingleFile("resource/fonts/nexa-light-webfont.ttf")

else
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae
