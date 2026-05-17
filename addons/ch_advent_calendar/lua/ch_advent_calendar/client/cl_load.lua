--[[
	This is a method of ensuring that the player is loaded in, so we can network stuff to them (PlayerInitialSpawn is unreliable)
	-- 00000000000000000
--]]
function CH_Advent.IsPlayerLoadedIn()
	if IsValid( LocalPlayer() ) then
		net.Start( "CH_Advent_Net_HUDPaintLoad" )
		net.SendToServer()
		
		hook.Remove( "HUDPaint", "CH_Advent.IsPlayerLoadedIn" )
	end
end
hook.Add( "HUDPaint", "CH_Advent.IsPlayerLoadedIn", CH_Advent.IsPlayerLoadedIn )

--[[
	Receive the players squares
--]]
net.Receive( "CH_Advent_Net_NetworkSquares", function()
	local ply = LocalPlayer()
	
	-- Create an empty table
	ply.CH_Advent_Squares = {}
	
	-- Read net
	local len = net.ReadUInt( 5 )
	
	for i = 1, len do
		ply.CH_Advent_Squares[ net.ReadUInt( 5 ) ] = net.ReadString()
	end
end )