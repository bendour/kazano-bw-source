resource.AddWorkshop( "3364597952" )

util.AddNetworkString( "CH_Advent_Net_OpenDashboard" )
util.AddNetworkString( "CH_Advent_Net_HUDPaintLoad" )
util.AddNetworkString( "CH_Advent_Net_NetworkSquares" )
util.AddNetworkString( "CH_Advent_Net_OpenSquare" )
util.AddNetworkString( "CH_Advent_Net_RetrieveHistory" )
util.AddNetworkString( "CH_Advent_Net_ShowHistory" )
util.AddNetworkString( "CH_Advent_Net_RetrieveLeaderboard" )
util.AddNetworkString( "CH_Advent_Net_ShowLeaderboard" )
util.AddNetworkString( "CH_Advent_Net_RequestSquareMenu" )

--[[
	Initialize our serverside directories
--]]
local map = string.lower( game.GetMap() )

local function CH_Advent_InitDirectories()
	if not file.IsDir( "craphead_scripts", "DATA" ) then
		file.CreateDir( "craphead_scripts", "DATA" )
	end

	if not file.IsDir( "craphead_scripts/ch_advent", "DATA" ) then
		file.CreateDir( "craphead_scripts/ch_advent", "DATA" )
	end

	if not file.IsDir( "craphead_scripts/ch_advent/".. map, "DATA" ) then
		file.CreateDir( "craphead_scripts/ch_advent/".. map, "DATA" )
		
		local Entity_Position = {
			EntityVector = {
				x = 0,
				y = 0,
				z = 0,
			},
			EntityAngles = {
				x = 0,
				y = 0,
				z = 0,
			},
		}
		
		file.Write( "craphead_scripts/ch_advent/".. map .."/npc.json", util.TableToJSON( Entity_Position ), "DATA" )
	end
end
hook.Add( "InitPostEntity", "CH_Advent_InitDirectories", CH_Advent_InitDirectories )