/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if CLIENT then return end
zpn = zpn or {}
zpn.force = zpn.force or {}
if zpn.config.FastDl then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

	function zpn.force.AddDir(path)

		local files, folders = file.Find(path .. "/*", "GAME")

		for k, v in pairs(files) do
			resource.AddFile(path .. "/" .. v)
		end

		for k, v in pairs(folders) do

			zpn.force.AddDir(path .. "/" .. v)
		end
	end

	zpn.force.AddDir("sound/zpn/")

	zpn.force.AddDir("models/zerochain/props_pumpkinnight/")
	zpn.force.AddDir("materials/zerochain/props_pumpkinnight/")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	zpn.force.AddDir("models/zerochain/props_christmas/")
	zpn.force.AddDir("materials/zerochain/props_christmas/")

	zpn.force.AddDir("materials/zerochain/zpn/")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

	resource.AddSingleFile("materials/entities/zpn_candy.png")
	resource.AddSingleFile("materials/entities/zpn_ghost.png")
	resource.AddSingleFile("materials/entities/zpn_npc.png")
	resource.AddSingleFile("materials/entities/zpn_destructable.png")
	resource.AddSingleFile("materials/entities/zpn_bomb.png")
	resource.AddSingleFile("materials/entities/zpn_boss.png")
	resource.AddSingleFile("materials/entities/zpn_minion.png")
	resource.AddSingleFile("materials/entities/zpn_scoreboard.png")
	resource.AddSingleFile("materials/entities/zpn_sign.png")

	resource.AddSingleFile("particles/zpn_candle_vfx.pcf")
	resource.AddSingleFile("particles/zpn_candy_vfx.pcf")
	resource.AddSingleFile("particles/zpn_fire_vfx.pcf")
	resource.AddSingleFile("particles/zpn_fuse_vfx.pcf")
	resource.AddSingleFile("particles/zpn_ghost_vfx.pcf")
	resource.AddSingleFile("particles/zpn_leafstorm.pcf")
	resource.AddSingleFile("particles/zpn_minion_vfx.pcf")
	resource.AddSingleFile("particles/zpn_partypopper_projectile.pcf")
	resource.AddSingleFile("particles/zpn_partypopper_vfx.pcf")
	resource.AddSingleFile("particles/zpn_pumpkin_vfx.pcf")
	resource.AddSingleFile("particles/zpn_pumpkinboss_vfx.pcf")


	resource.AddSingleFile("materials/vgui/entities/zpn_partypopper.vmt")
	resource.AddSingleFile("materials/vgui/entities/zpn_partypopper.vtf")

	resource.AddSingleFile("materials/vgui/entities/zpn_partypopper01.vmt")
	resource.AddSingleFile("materials/vgui/entities/zpn_partypopper01.vtf")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	resource.AddSingleFile("resource/fonts/JollyLodger-Regular.ttf")
	resource.AddSingleFile("resource/fonts/Vampire95.ttf")

else
	resource.AddWorkshop( "1890110902" ) // Zeros PumpkinNight Contentpack
	//https://steamcommunity.com/sharedfiles/filedetails/?id=1890110902
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

for k, v in pairs(zpn.config.Boss.MusicPaths) do
	resource.AddSingleFile("sound/" .. v)
end
