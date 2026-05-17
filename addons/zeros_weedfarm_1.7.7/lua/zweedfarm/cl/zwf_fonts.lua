if SERVER then return end

zwf = zwf or {}
zwf.f = zwf.f or {}
zwf.LoadedFonts = {}
zwf.FontData = {}

function zwf.f.GetFont(id)
	if zwf.LoadedFonts[id] then
		// Font already exists
		return id
	else

		// Create Font
		surface.CreateFont(id, zwf.FontData[id])
		zwf.LoadedFonts[id] = true

		print("[Zero´s GrowOP] Font " .. id .. " cached!")
		return id
	end
end

////////////////////////////////////////////
////////////////////////////////////////////
zwf.FontData["zwf_vgui_font01"] = {
	font = "Arial",
	extended = true,
	size = ScreenScale( 10 ),
	weight = ScreenScale( 300 ),
	antialias = true
}
zwf.FontData["zwf_vgui_font02"] = {
	font = "Arial",
	extended = true,
	size = ScreenScale( 7 ),
	weight = ScreenScale( 100 ),
	antialias = true
}
zwf.FontData["zwf_vgui_font03"] = {
	font = "RUSAK",
	extended = true,
	size = ScreenScale( 14 ),
	weight = ScreenScale( 300 ),
	antialias = true
}
zwf.FontData["zwf_vgui_font04"] = {
	font = "Arial",
	extended = true,
	size = ScreenScale( 7 ),
	weight = ScreenScale( 1000 ),
	antialias = true
}
zwf.FontData["zwf_vgui_font05"] = {
	font = "RUSAK",
	extended = true,
	size = ScreenScale( 10 ),
	weight = ScreenScale( 300 ),
	antialias = true
}
zwf.FontData["zwf_vgui_font06"] = {
	font = "Arial",
	extended = true,
	size = ScreenScale( 12 ),
	weight = ScreenScale( 300 ),
	antialias = true
}
zwf.FontData["zwf_vgui_font07"] = {
	font = "RUSAK",
	extended = true,
	size = ScreenScale( 20 ),
	weight = ScreenScale( 300 ),
	antialias = true
}
zwf.FontData["zwf_vgui_font08"] = {
	font = "Arial",
	extended = true,
	size = ScreenScale( 6 ),
	weight = ScreenScale( 100 ),
	antialias = true
}
zwf.FontData["zwf_vgui_font09"] = {
	font = "Arial",
	extended = true,
	size = ScreenScale( 8 ),
	weight = ScreenScale( 500 ),
	antialias = true
}
zwf.FontData["zwf_vgui_font10"] = {
	font = "RUSAK",
	extended = true,
	size = ScreenScale( 9 ),
	weight = ScreenScale( 300 ),
	antialias = true
}
zwf.FontData["zwf_vgui_font12"] = {
	font = "RUSAK",
	extended = true,
	size = ScreenScale( 9 ),
	weight = ScreenScale( 300 ),
	antialias = true
}
zwf.FontData["zwf_vgui_font13"] = {
	font = "RUSAK",
	extended = true,
	size = ScreenScale( 12 ),
	weight = ScreenScale( 100 ),
	antialias = true
}
////////////////////////////////////////////
////////////////////////////////////////////
zwf.FontData["zwf_wateringcan_font01"] = {
	font = "Arial",
	extended = true,
	size = ScreenScale( 10 ),
	weight = ScreenScale( 300 ),
	antialias = true
}
zwf.FontData["zwf_ventilator_font01"] = {
	font = "Arial",
	extended = true,
	size = 15,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_watertank_font01"] = {
	font = "Arial",
	extended = true,
	size = 50,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_lamp01_font01"] = {
	font = "Arial",
	extended = true,
	size = 20,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_palette_font01"] = {
	font = "Arial",
	extended = true,
	size = 100,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_palette_font02"] = {
	font = "Arial",
	extended = true,
	size = 100,
	weight = 1000,
	blursize = 15,
	antialias = true
}
zwf.FontData["zwf_flowerpot_font01"] = {
	font = "Arial",
	extended = true,
	size = 21,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_flowerpot_font03"] = {
	font = "Arial",
	extended = true,
	size = 14,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_flowerpot_font04"] = {
	font = "Arial",
	extended = true,
	size = 29,
	weight = 1000,
	antialias = true
}

zwf.FontData["zwf_generator_font01"] = {
	font = "RUSAK",
	extended = true,
	size = 75,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_generator_font02"] = {
	font = "RUSAK",
	extended = true,
	size = 80,
	weight = 1000,
	blursize = 15,
	antialias = true
}
zwf.FontData["zwf_generator_font03"] = {
	font = "Arial",
	extended = true,
	size = 40,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_plant_font01"] = {
	font = "RUSAK",
	extended = true,
	size = 100,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_plant_font02"] = {
	font = "Arial",
	extended = true,
	size = 90,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_seed_font01"] = {
	font = "Arial",
	extended = true,
	size = 100,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_seed_font02"] = {
	font = "Arial",
	extended = true,
	size = 55,
	weight = 100,
	antialias = true
}
zwf.FontData["zwf_packingstation_font01"] = {
	font = "Arial",
	extended = true,
	size = 75,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_packingstation_font02"] = {
	font = "Arial",
	extended = true,
	size = 55,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_npc_font01"] = {
	font = "RUSAK",
	extended = true,
	size = 75,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_npc_font02"] = {
	font = "RUSAK",
	extended = true,
	size = 25,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_jar_font01"] = {
	font = "Arial",
	extended = true,
	size = 100,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_jar_font02"] = {
	font = "Arial",
	extended = true,
	size = 70,
	weight = 1000,
	antialias = true
}
zwf.FontData["zwf_splicelab_font02"] = {
	font = "Arial",
	extended = true,
	size = 25,
	weight = 1000,
	antialias = true
}
////////////////////////////////////////////
////////////////////////////////////////////
zwf.FontData["zwf_seedbank_vgui_font01"] = {
	font = "Arial",
	extended = true,
	size = ScreenScale( 5 ),
	weight = ScreenScale( 300 ),
	antialias = true
}
zwf.FontData["zwf_settings_font01"] = {
	font = "Arial",
	extended = true,
	size = ScreenScale( 12 ),
	weight = ScreenScale( 300 ),
	antialias = true
}
zwf.FontData["zwf_settings_font02"] = {
	font = "Arial",
	extended = true,
	size = ScreenScale( 8 ),
	weight = ScreenScale( 5 ),
	antialias = true
}
////////////////////////////////////////////
////////////////////////////////////////////
