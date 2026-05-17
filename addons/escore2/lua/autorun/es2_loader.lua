escore2 = escore2 or {} -- initialize
escore2.config = escore2.config or {}
escore2.Materials = escore2.Materials or {}
escore2.download_path = "escore2"

local errorMat = Material("error")
function escore2:GetMaterial(filename)
	return self.Materials[filename] or errorMat
end

if ( SERVER ) then
	--content (materials)
	resource.AddWorkshop( "3319452278" ) -- https://steamcommunity.com/sharedfiles/filedetails/?id=3319452278
end

local function loader()
	print("[escoreboard v2 loader]")
	--Using esclib loader system
		esclib.loader:New("escore2","escore2/",function(load)
		--fonts used in addon
		load:Resource("resource/fonts/montserrat_regular.ttf")

		load:MaterialFolder("materials/escore2",false,true) --load.Materials params: path, isrecurse, download
		esclib:SafeMerge(escore2.Materials, load.Materials, true)
		
		--CONFIGS
		load:Shared("config/es2_meta.lua") -- creating addon instance
		load:Shared("config/es2_config.lua")
		load:Shared("config/es2_tags.lua") -- custom SteamID64 tags config
		load:Shared("core/common/es2_column_meta.lua") --we need to load columns before ingame cfg
		load:Shared("core/es2_columns.lua")
		load:Shared("config/es2_ingame_cfg.lua")
		load:Client("config/es2_themes.lua")
		load:Shared("config/es2_languages.lua")

		--ALL VGUI's
		load:ClientFolder("vgui")

		--MAIN FILES
		load:Client("core/common/es2_sort_meta.lua")
		load:Client("core/common/es2_button_meta.lua")

		load:Client("core/es2_buttons.lua")
		load:Client("core/es2_build.lua")
		
	end)
end

--disable original escoreboard
timer.Simple(0, function()
	hook.Remove("ScoreboardShow", "escoreboard.show")
	hook.Remove("ScoreboardHide", "escoreboard.hide")
end)

--lua refresh compat
if esclib && esclib.loader then
	if esclib.loader:IsLoaded("escore2") then
		loader()
	end
end

hook.Add("esclib_loaded", "escore2_load", function()
	loader()
end)