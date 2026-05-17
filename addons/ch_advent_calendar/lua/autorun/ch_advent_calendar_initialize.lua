-- INITIALIZE SCRIPT
if SERVER then	
	for k, v in ipairs( file.Find( "ch_advent_calendar/shared/*.lua", "LUA" ) ) do
		include( "ch_advent_calendar/shared/".. v )
		AddCSLuaFile( "ch_advent_calendar/shared/".. v )
	end
	
	for k, v in ipairs( file.Find( "ch_advent_calendar/server/*.lua", "LUA" ) ) do
		include( "ch_advent_calendar/server/".. v )
	end

	for k, v in ipairs( file.Find( "ch_advent_calendar/client/*.lua", "LUA" ) ) do
		AddCSLuaFile( "ch_advent_calendar/client/".. v )
	end
end

if CLIENT then
	for k, v in ipairs( file.Find( "ch_advent_calendar/shared/*.lua", "LUA" ) ) do
		include( "ch_advent_calendar/shared/".. v )
	end
	
	for k, v in ipairs( file.Find( "ch_advent_calendar/client/*.lua", "LUA" ) ) do
		include( "ch_advent_calendar/client/".. v )
	end
end

-- 00000000000000000