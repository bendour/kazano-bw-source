----------- // SCRIPT BY INJ3 
----------- // SCRIPT BY INJ3 
----------- // SCRIPT BY INJ3 
---- // https://steamcommunity.com/id/Inj3/

Improved_System_Map_Optimiser = Improved_System_Map_Optimiser or {}
Improved_System_Map_Optimiser.Version = "2.9"
Improved_System_Map_Optimiser.ExcludeClassConvert = {
    ["prop_physics"] = true,
    ["prop_dynamic"] = true,
    ["prop_physics_multiplayer"] = true,
    ["prop_physics_override"] = true,
    ["prop_dynamic_override"] = true,
}

do
    local ipr_config_sys = file.Find("improved_system_map_optimiser/configuration/*", "LUA")
    local ipr_client_file = file.Find("improved_system_map_optimiser/vgui/*", "LUA")
    local ipr_server_file = file.Find("improved_system_map_optimiser/lua_server/*", "LUA")
    
    if (SERVER) then
       resource.AddFile( "resource/fonts/Rajdhani-Bold.ttf" )
 
       for count, file in pairs(ipr_config_sys) do
          include("improved_system_map_optimiser/configuration/"..file)
          AddCSLuaFile("improved_system_map_optimiser/configuration/"..file)
       end
       for count, file in pairs(ipr_server_file) do
          include("improved_system_map_optimiser/lua_server/"..file)
       end
       for count, file in pairs(ipr_client_file) do
          AddCSLuaFile("improved_system_map_optimiser/vgui/"..file)
       end
    end
    if (CLIENT) then
       surface.CreateFont("Ipr_System_Map_Optmiser_Font",{
          font = "Rajdhani Bold",
          size = 18,
          weight = 250,
          antialias = true
       })

       for count, file in pairs(ipr_config_sys) do
          include("improved_system_map_optimiser/configuration/"..file)
       end
       for count, file in pairs(ipr_client_file) do
          include("improved_system_map_optimiser/vgui/"..file)
       end
    end
end
 