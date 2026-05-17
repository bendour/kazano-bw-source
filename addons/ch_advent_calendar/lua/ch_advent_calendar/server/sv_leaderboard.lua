CH_Advent.Leaderboard = CH_Advent.Leaderboard or {}
CH_Advent.LeaderboardFetched = 0

--[[
	Net to retrieve the Leaderboard from DB and show the menu
--]]
net.Receive( "CH_Advent_Net_RetrieveLeaderboard", function( len, ply )
	-- Net delay
	local cur_time = CurTime()
	if ( ply.CH_Advent_NetDelay or 0 ) > cur_time then
		ply:ChatPrint( "You're running the command too fast. Slow down champ!" )
		return
	end
	ply.CH_Advent_NetDelay = cur_time + 0.5
	
	-- Read net
	local timeleft = net.ReadUInt( 32 )
	local day = net.ReadUInt( 5 )

	-- Fetch Leaderboard from DB or cached and show
	if os.time() > ( CH_Advent.LeaderboardFetched + CH_Advent.Config.LeaderboardCacheTime ) then
		CH_Advent.SQL.Query( "SELECT Nick, Coal FROM ch_advent_players ORDER BY Coal DESC LIMIT 10", function( data )
			if data then
				-- Update vars
				CH_Advent.LeaderboardFetched = os.time()
				CH_Advent.Leaderboard = data

				-- Show menu
				local board_len = #data
				
				net.Start( "CH_Advent_Net_ShowLeaderboard" )
					net.WriteUInt( timeleft, 32 )
					net.WriteUInt( day, 5 )
					net.WriteUInt( board_len, 32 )
					
					for k, v in ipairs( data ) do
						net.WriteString( v.Nick )
						net.WriteUInt( v.Coal, 5 )
					end
				net.Send( ply )
			end
		end, false )
	
	else
		-- Show menu
		local board_len = #CH_Advent.Leaderboard
		
		net.Start( "CH_Advent_Net_ShowLeaderboard" )
			net.WriteUInt( timeleft, 32 )
			net.WriteUInt( day, 5 )
			net.WriteUInt( board_len, 32 )
			
			for k, v in ipairs( CH_Advent.Leaderboard ) do
				net.WriteString( v.Nick )
				net.WriteUInt( v.Coal, 5 )
			end
		net.Send( ply )
	end
end )