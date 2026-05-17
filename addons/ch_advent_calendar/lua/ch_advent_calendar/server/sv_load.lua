--[[
	Called when a player joins.
	Check if we should create a new account or load an existing account
--]]
function CH_Advent.InitializePlayer( ply )
	local escaped_nick = CH_Advent.SQL.Escape( ply:Nick() )
	local sid64 = ply:SteamID64()

	CH_Advent.SQL.Query( "SELECT * FROM ch_advent_players WHERE SteamID64 = '".. sid64 .."';", function( data )
		if data then
			-- Load player
			ply.CH_Advent_Squares = util.JSONToTable( data.Squares )
			ply.CH_Advent_HasAccess = tobool( data.HasAccess or 0 )
			
			-- Update nickname
			CH_Advent.SQL.Query( "UPDATE ch_advent_players SET Nick = '".. escaped_nick .."' WHERE SteamID64 = '".. sid64 .."';" )
		else
			-- Write a new profile for the player
			CH_Advent.SQL.Query( "INSERT INTO ch_advent_players ( Nick, Squares, Coal, SteamID64, HasAccess ) VALUES( '".. escaped_nick .."', '{}', '0', '".. sid64 .."', 0 );" )
			
			-- Setup table
			ply.CH_Advent_Squares = {}
			ply.CH_Advent_HasAccess = false
		end
		
		-- Network
		CH_Advent.NetworkSquares( ply )
		
		-- Open if enabled
		if CH_Advent.Config.OpenMenuOnConnect then
			CH_Advent.OpenSquareMenu( ply )
		end
	end, true )
end

--[[
	Call this net when the player is actually loaded in properly
--]]
net.Receive( "CH_Advent_Net_HUDPaintLoad", function( len, ply )
	-- The player is fully loaded in
	CH_Advent.InitializePlayer( ply )
end )