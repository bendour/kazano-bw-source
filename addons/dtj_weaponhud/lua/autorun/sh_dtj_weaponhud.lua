dtj = dtj or {}
dtj.weaponHud = dtj.weaponHud or {}

if( not file.Exists( "dtj/weaponhud", "DATA" ) ) then
	file.CreateDir( "dtj/weaponhud" );
end

if( CLIENT ) then
	dtj.weaponHud.settingsLoaded = false -- on refresh, unload client settings
	
	include( "sh_cami.lua" );
	include( "dtj_w_sh_config.lua" );
	include( "dtj_w_sh_util.lua" );
	include( "dtj_w_cl_themes.lua" );
	include( "dtj_w_cl_weaponhud.lua" );
	include( "dtj_w_cl_settings.lua" );
	
	-- themes
	local files, dir = file.Find( "themes/*.lua", "LUA" );
	for k, v in pairs( files ) do
		include( "themes/" .. v );
	end
end

-- server loading
if( SERVER ) then
	-- net messages
	util.AddNetworkString( "dtj_w_slotconfig" );
	
	-- resources
	-- will upload these to a workshop addon soon!
	local files, dirs = file.Find( "materials/dtj/weaponhud/*.png", "GAME" );
	for k, v in pairs( files ) do
		resource.AddSingleFile( "materials/dtj/weaponhud/" .. v );
	end
	
	AddCSLuaFile();
	AddCSLuaFile( "sh_cami.lua" );
	AddCSLuaFile( "dtj_w_sh_config.lua" )
	AddCSLuaFile( "dtj_w_sh_util.lua" );
	AddCSLuaFile( "dtj_w_cl_themes.lua" );
	AddCSLuaFile( "dtj_w_cl_weaponhud.lua" )
	AddCSLuaFile( "dtj_w_cl_settings.lua" );
	
	-- themes
	local files, dir = file.Find( "themes/*.lua", "LUA" );
	for k, v in pairs( files ) do
		AddCSLuaFile( "themes/" .. v );
	end
	
	include( "sh_cami.lua" );
	include( "dtj_w_sh_config.lua" );
	include( "dtj_w_sh_util.lua" );
end
