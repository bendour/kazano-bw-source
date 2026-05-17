if SERVER then
    AddCSLuaFile("config/config.lua")
    AddCSLuaFile("client/cl_screens.lua")
    
    include("config/config.lua")
    include("server/sv_screens.lua")
else
    include("config/config.lua")
    include("client/cl_screens.lua")
end